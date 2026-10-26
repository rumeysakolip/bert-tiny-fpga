"""Nicemleme ilkel işlemleri — RTL'deki tek tek operatörlerin Python karşılığı.

Buradaki her fonksiyon, Verilog'da birkaç satırla yazılabilecek kadar küçük
olacak şekilde tasarlandı. Float aritmetiği SADECE kalibrasyon/analiz
yollarında kullanılır; veri yolunda (`sabit_nokta_carp`, `nicele`, `kirp`)
her şey tamsayıdır.

Yuvarlama kuralları — RTL'e birebir taşınabilmesi için açıkça ayrılmıştır:
  * `yuvarla_cifte`  : bankacı yuvarlaması (yarım -> çift). PyTorch'un
                       `torch.round` davranışı budur; PTQ ile bit-birebir
                       eşleşmek için nicemleme adımlarında bu kullanılır.
  * `yuvarla_yukari` : yarım -> yukarı (+0.5 ekle, aşağı kaydır). Donanımda
                       tek bir toplayıcı + kaydırma ile yapılır; sabit
                       noktalı yeniden ölçeklemede bu kullanılır.
"""

from __future__ import annotations

import numpy as np

from . import sabitler as S


# ---------------------------------------------------------------------------
# Yuvarlama
# ---------------------------------------------------------------------------
def yuvarla_cifte(x: np.ndarray) -> np.ndarray:
    """Yarım değerleri en yakın ÇİFT tam sayıya yuvarlar (torch.round ile aynı)."""
    return np.rint(x)


def yuvarla_yukari_tamsayi(carpim: np.ndarray, n: int) -> np.ndarray:
    """`carpim / 2^n` değerini yarım-yukarı yuvarlayarak tamsayı döndürür.

    Donanım karşılığı:  (carpim + (1 << (n-1))) >>> n   (aritmetik kaydırma)
    Negatif sayılarda da aynı sonucu vermesi için numpy'de >> operatörü
    aritmetik kaydırmadır, bu yüzden doğrudan kullanılabilir.
    """
    if n == 0:
        return carpim
    yuvarlama = np.int64(1) << np.int64(n - 1)
    return (carpim + yuvarlama) >> np.int64(n)


# ---------------------------------------------------------------------------
# Nicemleme / nicem çözme
# ---------------------------------------------------------------------------
def nicele(x: np.ndarray, olcek: float, sifir: int = 0,
           alt: int = S.AKT_MIN, ust: int = S.AKT_MAX) -> np.ndarray:
    """Float tensörü INT8'e indirger.  q = kirp(round(x/olcek) + sifir)

    PTQ'daki `QLinear.forward` ile birebir aynı: float64 üzerinde bölme,
    bankacı yuvarlaması, sonra kırpma.
    """
    q = yuvarla_cifte(np.asarray(x, dtype=np.float64) / olcek) + sifir
    return np.clip(q, alt, ust).astype(np.int32)


def nicem_coz(q: np.ndarray, olcek, sifir: int = 0) -> np.ndarray:
    """Tamsayıyı float'a geri çevirir. Yalnızca A-kipinde / analizde kullanılır."""
    return (np.asarray(q, dtype=np.float64) - sifir) * olcek


def kirp(x: np.ndarray, alt: int, ust: int) -> np.ndarray:
    """Doyumlu kırpma (saturating clamp) — RTL'de karşılaştırıcı + çoklayıcı."""
    return np.clip(x, alt, ust)


# ---------------------------------------------------------------------------
# Sabit noktalı çarpan ayrıştırma:  M  ~=  M0 * 2^-n
# ---------------------------------------------------------------------------
def carpani_ayristir(M: float, m0_bit: int = S.M0_BIT) -> tuple[int, int]:
    """Gerçel çarpanı (M0, n) tamsayı çiftine ayırır.

    M0, `m0_bit` bitlik işaretli bir sayıya sığacak kadar büyük tutulur;
    n ise M0 taşmadan alınabilecek EN BÜYÜK kaydırma miktarıdır, yani
    mümkün olan en yüksek hassasiyet seçilir.
    """
    if M <= 0:
        return 0, 0
    sinir = (1 << (m0_bit - 1)) - 1          # M0 bu değeri aşmamalı
    n = 0
    while n < S.MAKS_KAYDIRMA and round(M * (1 << (n + 1))) <= sinir:
        n += 1
    M0 = int(round(M * (1 << n)))
    return M0, n


def carpan_tablosu(M: np.ndarray, m0_bit: int = S.M0_BIT,
                   paylasimli_kaydirma: bool = True) -> tuple[np.ndarray, np.ndarray | int]:
    """Kanal başına çarpan dizisi için (M0[], n) üretir.

    paylasimli_kaydirma=True  -> tüm kanallar için TEK bir n (donanımda ucuz:
                                 kaydırma miktarı sabit tellenir). n, hiçbir
                                 kanal taşmasın diye kanalların en küçüğüdür.
    paylasimli_kaydirma=False -> kanal başına (M0, n) çifti (daha hassas,
                                 ama her kanal için n'i de saklamak gerekir).
    """
    M = np.asarray(M, dtype=np.float64)
    ciftler = [carpani_ayristir(float(m), m0_bit) for m in M.ravel()]
    M0 = np.array([c[0] for c in ciftler], dtype=np.int64)
    n = np.array([c[1] for c in ciftler], dtype=np.int64)
    if not paylasimli_kaydirma:
        return M0.reshape(M.shape), n.reshape(M.shape)

    ortak_n = int(n.min())
    M0_ortak = np.rint(M * (1 << ortak_n)).astype(np.int64)
    return M0_ortak.reshape(M.shape), ortak_n


def sabit_nokta_carp(birikec: np.ndarray, M0, n) -> np.ndarray:
    """INT32 birikeci sabit noktalı çarpanla ölçekler: round(birikec * M0 / 2^n).

    Donanım karşılığı: bir geniş çarpıcı + bir toplayıcı + bir aritmetik
    kaydırma. Ara çarpım int64'te tutulur (birikec 32 bit, M0 <= 31 bit).
    """
    birikec = np.asarray(birikec, dtype=np.int64)
    M0 = np.asarray(M0, dtype=np.int64)
    carpim = birikec * M0
    if np.isscalar(n) or np.ndim(n) == 0:
        return yuvarla_yukari_tamsayi(carpim, int(n))
    n = np.asarray(n, dtype=np.int64)
    yuvarlama = np.where(n > 0, np.int64(1) << np.maximum(n - 1, 0), 0)
    return (carpim + yuvarlama) >> n


# ---------------------------------------------------------------------------
# Taşma denetimi — RTL'e geçmeden önce bit genişliklerini kanıtlamak için
# ---------------------------------------------------------------------------
class TasmaKaydi:
    """Veri yolundaki tensörlerin gördüğü en uç değerleri biriktirir."""

    def __init__(self):
        self.kayit: dict[str, dict] = {}

    def gozle(self, ad: str, x: np.ndarray, bit: int):
        x = np.asarray(x)
        alt, ust = -(2 ** (bit - 1)), 2 ** (bit - 1) - 1
        mn, mx = int(np.min(x)), int(np.max(x))
        k = self.kayit.setdefault(ad, {"bit": bit, "min": mn, "max": mx, "tasma": 0})
        k["min"] = min(k["min"], mn)
        k["max"] = max(k["max"], mx)
        k["tasma"] += int(np.count_nonzero((x < alt) | (x > ust)))

    def rapor(self) -> dict:
        out = {}
        for ad, k in sorted(self.kayit.items()):
            genislik = max(int(abs(k["min"])).bit_length() + 1,
                           int(abs(k["max"])).bit_length() + 1)
            out[ad] = {**k, "gereken_bit": genislik,
                       "bos_pay_bit": k["bit"] - genislik}
        return out
