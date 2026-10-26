"""Donanım birimleri — RTL modül hiyerarşisinin Python karşılığı.

Hiyerarşi (RTL'de de aynı olacak):

    pe_mac            : tek bir işlem elemanı (DSP48 ya da LUT çarpıcı)
    SistolikDizi      : PE_SATIR x PE_SUTUN'luk çıkış-duralı (output-stationary)
                        dizi; K_DILIM uzunluğunda iç çarpım dilimlerini birikeçler
    YenidenOlcekle    : INT32 birikeç -> INT8 aktivasyon (M0/kaydırma + kırpma)
    LineerKatman      : yukarıdakileri birleştiren tam nicemlenmiş Linear

Önemli: `SistolikDizi.carp` döngüsel (yavaş ama donanıma birebir benzeyen)
uygulamadır; `hizli_matmul` ise aynı sonucu veren vektörel uygulamadır.
`testler/test_birimler.py` ikisinin BİT-BİREBİR aynı olduğunu kanıtlar, bu
yüzden 872 cümlelik tam koşuda hızlı yol gönül rahatlığıyla kullanılır.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from . import nicem, sabitler as S


# ---------------------------------------------------------------------------
# 1) İşlem elemanı
# ---------------------------------------------------------------------------
def pe_mac(a: int, w: int, birikec: int) -> int:
    """Tek PE: birikec += a * w.  a INT8, w INT8, birikec INT32.

    Donanımda bu bir DSP48E1 (ya da LUT tabanlı 8x8 çarpıcı + 32 bit toplayıcı).
    """
    return int(birikec) + int(a) * int(w)


# ---------------------------------------------------------------------------
# 2) Systolic dizi
# ---------------------------------------------------------------------------
@dataclass
class SistolikDizi:
    """Çıkış-duralı systolic dizi benzetimi.

    satir  : aynı anda hesaplanan çıkış kanalı sayısı (ağırlık yönü)
    sutun  : aynı anda hesaplanan token sayısı (aktivasyon yönü)
    k_dilim: bir yüklemede akıtılan iç çarpım uzunluğu
    """

    satir: int = S.PE_SATIR
    sutun: int = S.PE_SUTUN
    k_dilim: int = S.K_DILIM

    def cevrim_sayisi(self, T: int, C: int, K: int) -> dict:
        """Bir (T x K) @ (K x C) çarpımının kaba çevrim maliyeti.

        Gerçek RTL'de boru hattı dolma/boşalma gecikmeleri eklenecek; burada
        yalnızca veri akışı çevrimleri sayılır (İP6 başarım tahmini için).
        """
        t_blok = -(-T // self.sutun)
        c_blok = -(-C // self.satir)
        k_blok = -(-K // self.k_dilim)
        akis = t_blok * c_blok * k_blok * self.k_dilim
        doldurma = t_blok * c_blok * (self.satir + self.sutun)
        return {
            "token_blok": t_blok, "kanal_blok": c_blok, "k_blok": k_blok,
            "akis_cevrimi": akis, "doldurma_cevrimi": doldurma,
            "toplam_cevrim": akis + doldurma,
            "pe_kullanimi": (T * C * K) / max(akis * self.satir * self.sutun, 1),
        }

    def carp(self, X: np.ndarray, W: np.ndarray, kayit: nicem.TasmaKaydi | None = None) -> np.ndarray:
        """(T, K) INT8 aktivasyon x (C, K) INT8 ağırlık -> (T, C) INT32.

        Döngüler bilerek açık bırakıldı: dıştan içe blok -> blok -> dilim -> PE.
        RTL'deki FSM'in durumları bu döngülere birebir karşılık gelir.
        """
        X = np.asarray(X, dtype=np.int64)
        W = np.asarray(W, dtype=np.int64)
        T, K = X.shape
        C, K2 = W.shape
        assert K == K2, f"iç boyutlar uyuşmuyor: {K} != {K2}"

        Y = np.zeros((T, C), dtype=np.int64)
        for t0 in range(0, T, self.sutun):            # token blokları
            t1 = min(t0 + self.sutun, T)
            for c0 in range(0, C, self.satir):        # çıkış kanalı blokları
                c1 = min(c0 + self.satir, C)
                birikec = np.zeros((t1 - t0, c1 - c0), dtype=np.int64)
                for k0 in range(0, K, self.k_dilim):  # iç çarpım dilimleri
                    k1 = min(k0 + self.k_dilim, K)
                    for k in range(k0, k1):           # PE dizisine akan çevrimler
                        birikec += np.outer(X[t0:t1, k], W[c0:c1, k])
                        if kayit is not None:
                            kayit.gozle("sistolik.birikec", birikec, S.BIRIKEC_BIT)
                Y[t0:t1, c0:c1] = birikec
        return Y


def hizli_matmul(X: np.ndarray, W: np.ndarray) -> np.ndarray:
    """SistolikDizi.carp ile BİT-BİREBİR aynı sonuç, vektörel hesap.

    int64 üzerinde tam tamsayı çarpımı yapılır; ara hiçbir yerde float yok.
    """
    return np.asarray(X, dtype=np.int64) @ np.asarray(W, dtype=np.int64).T


# ---------------------------------------------------------------------------
# 3) Yeniden ölçekleme birimi
# ---------------------------------------------------------------------------
@dataclass
class YenidenOlcekle:
    """INT32 birikeci bir sonraki katmanın INT8 girdisine indirger.

    kip = "float" : birikec * (a_olcek * w_olcek) -> float32
                    (PTQ ile birebir aynı; altın modelin A-kipi)
    kip = "sabit" : birikec * M0 >> n -> INT8
                    (tamsayı-only veri yolu; donanımın gerçekte yapacağı)
    """

    M_gercel: np.ndarray            # kanal başına gerçel çarpan
    kip: str = "float"
    m0_bit: int = S.M0_BIT
    paylasimli_kaydirma: bool = True

    def __post_init__(self):
        self.M0, self.n = nicem.carpan_tablosu(
            self.M_gercel, self.m0_bit, self.paylasimli_kaydirma)

    def bagil_hata(self) -> dict:
        """Sabit noktalı çarpanın gerçel çarpandan sapması (rapor için)."""
        n = self.n if np.ndim(self.n) else int(self.n)
        yaklasik = np.asarray(self.M0, dtype=np.float64) / (2.0 ** np.asarray(n, dtype=np.float64))
        hata = np.abs(yaklasik - self.M_gercel) / np.maximum(np.abs(self.M_gercel), 1e-30)
        return {"maks_bagil_hata": float(hata.max()),
                "ort_bagil_hata": float(hata.mean()),
                "kaydirma": int(n) if np.ndim(n) == 0 else [int(v) for v in np.ravel(n)][:4]}

    def uygula(self, birikec: np.ndarray) -> np.ndarray:
        if self.kip == "float":
            return (np.asarray(birikec, dtype=np.float64) * self.M_gercel)
        q = nicem.sabit_nokta_carp(birikec, self.M0, self.n)
        return nicem.kirp(q, S.AKT_MIN, S.AKT_MAX).astype(np.int32)


# ---------------------------------------------------------------------------
# 4) Nicemlenmiş Linear katman
# ---------------------------------------------------------------------------
@dataclass
class LineerKatman:
    """Tam nicemlenmiş Linear: girdi nicemleme + INT8 matmul + bias + ölçekleme.

    w_q     : (C, K) INT8 ağırlık
    bias_q  : (C,)   INT32 bias (ölçeği a_olcek * w_olcek)
    a_olcek : girdi aktivasyon ölçeği (tensör başına)
    w_olcek : (C,)   ağırlık ölçeği (çıkış kanalı başına)
    """

    ad: str
    w_q: np.ndarray
    bias_q: np.ndarray
    a_olcek: float
    w_olcek: np.ndarray
    a_sifir: int = 0

    @property
    def cikis_olcek(self) -> np.ndarray:
        """Birikeç biriminin gerçel karşılığı: a_olcek * w_olcek (kanal başına)."""
        return self.a_olcek * np.asarray(self.w_olcek, dtype=np.float64)

    def girdiyi_nicele(self, x_float: np.ndarray) -> np.ndarray:
        return nicem.nicele(x_float, self.a_olcek, self.a_sifir)

    def birikec(self, xq: np.ndarray, sistolik: SistolikDizi | None = None,
                kayit: nicem.TasmaKaydi | None = None) -> np.ndarray:
        """INT8 girdiden INT32 birikece. Bias burada eklenir (donanımda da öyle)."""
        xq = np.asarray(xq, dtype=np.int64)
        if self.a_sifir:
            xq = xq - self.a_sifir
        duz = xq.reshape(-1, xq.shape[-1])
        if sistolik is None:
            acc = hizli_matmul(duz, self.w_q)
        else:
            acc = sistolik.carp(duz, self.w_q, kayit)
        acc = acc + np.asarray(self.bias_q, dtype=np.int64)
        acc = acc.reshape(*xq.shape[:-1], self.w_q.shape[0])
        if kayit is not None:
            kayit.gozle(f"{self.ad}.birikec", acc, S.BIRIKEC_BIT)
        return acc

    def ileri_float(self, x_float: np.ndarray,
                    sistolik: SistolikDizi | None = None,
                    kayit: nicem.TasmaKaydi | None = None) -> np.ndarray:
        """A-kipi: PTQ'nun `QLinear.forward` fonksiyonu ile bit-birebir aynı."""
        xq = self.girdiyi_nicele(x_float)
        acc = self.birikec(xq, sistolik, kayit)
        return (acc.astype(np.float64) * self.cikis_olcek).astype(np.float32)
