"""Altın model — BERT-Tiny / SST-2 ileri yolu, donanım veri yolu düzeninde.

Kipler
------
"fp32" : Hiç nicemleme yok. Yalnızca referans.
"A"    : PTQ ile BİT-BİREBİR aynı. 14 Linear katman INT8 matmul + INT32
         birikeç + gerçel ölçekle geri açma; LayerNorm/Softmax/GELU/Tanh FP32.
         Doğrulama ölçütü: `02_dogrula_ptq.py`, 872 cümlede %100 tahmin uyuşması.
"B"    : Donanım-sadık kip. Her birimin girdisi/çıkışı kalibre edilmiş ölçeklerle
         tamsayıya indirgenir ve birim kendi TAMSAYI algoritmasını çalıştırır
         (sabit noktalı yeniden ölçekleme, tamsayı LayerNorm, LUT'lu softmax/GELU).
         Birimler arasındaki taşıma float kalır; böylece her yaklaşımın doğruluk
         maliyeti TEK TEK ölçülebilir. Tüm birimler geçtikten sonra taşımayı da
         tamsayıya çevirmek mekanik bir adımdır (İP5 sonu).

Taşıma (G2): `Ayarlar.tasima_adim` boş değilse birimler arası float taşıma, adım adım
tamsayı yeniden ölçeklemeyle (M0/n, kırpma) değiştirilir; adımlar TASIMA_ADIMLARI'nda.
Adımlar bağımsız açılıp kapanır, böylece her adımın doğruluk maliyeti ayrı ölçülür.

B-kipi ara tensör ölçek tablosu ister (`01_kalibre_ara_olcek.py` üretir).
Tablo verilmezse açık hata verir — sessizce yanlış sonuç üretmez.

RTL karşılığı: `ileri()` içindeki her blok bir FSM durumuna karşılık gelir.
`izle_ara_tensor=True` iken her ara tensör `izle` sözlüğüne kaydedilir;
`03_test_vektoru_uret.py` bunları testbench vektörüne dönüştürür.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from . import dogrusal_olmayan as dol
from . import nicem, sabitler as S
from .birimler import SistolikDizi, YenidenOlcekle
from .parametreler import Parametreler


# Float taşımanın tamsayıya alındığı adımlar (sıra = veri akışı sırası)
TASIMA_ADIMLARI = ("gomme", "ln_cikis", "artik", "qk", "av", "gelu_tanh")
TASIMA_ACIKLAMA = {
    "gomme": "gömme LN çıkışı -> L0 Q/K/V girdisi",
    "ln_cikis": "LN çıkışı -> sonraki Linear girdisi (ffn1, L1 Q/K/V, pooler)",
    "artik": "artık toplamlar (h + attn_out, h + ffn2) tamsayıda",
    "qk": "Q·Kᵀ INT32 -> skor (tamsayı yeniden ölçekleme)",
    "av": "P(UINT8)·V INT32 -> bağlam INT8",
    "gelu_tanh": "GELU/tanh çıkışı -> sonraki Linear girdisi",
}


@dataclass
class Ayarlar:
    """Hangi birimin hangi sürümünün kullanılacağı."""
    kip: str = "A"                      # "fp32" | "A" | "B"
    yeniden_olcekle: str = "float"      # "float" | "sabit"
    layer_norm: str = "float"           # "float" | "tam"
    softmax: str = "float"              # "float" | "tam"
    gelu: str = "float"                 # "float" | "lut"
    tanh: str = "float"                 # "float" | "lut"
    m0_bit: int = S.M0_BIT
    skor_bit: int = 12                  # dikkat skoru veri yolu genişliği
    ln_bit: int = 12                    # LayerNorm girdi veri yolu genişliği
    paylasimli_kaydirma: bool = True
    sistolik: bool = False              # True: döngüsel systolic dizi (yavaş)
    tasima_adim: tuple = ()             # tamsayıya alınan taşıma adımları (TASIMA_ADIMLARI)
    izle_ara_tensor: bool = False

    @staticmethod
    def B_kipi(**kw) -> "Ayarlar":
        v = dict(kip="B", yeniden_olcekle="sabit", layer_norm="tam",
                 softmax="tam", gelu="lut", tanh="lut")
        v.update(kw)
        return Ayarlar(**v)

    def tamsayi_birim_var(self) -> bool:
        return (self.yeniden_olcekle != "float" or self.layer_norm != "float"
                or self.softmax != "float" or self.gelu != "float"
                or self.tanh != "float")


class AltinModel:
    def __init__(self, p: Parametreler, ayar: Ayarlar | None = None,
                 ara_olcekler: dict | None = None):
        self.p = p
        self.ayar = ayar or Ayarlar()
        self.ara_olcekler = ara_olcekler or {}
        self.kayit = nicem.TasmaKaydi()
        self.izle: dict[str, np.ndarray] = {}
        self._dizi = SistolikDizi() if self.ayar.sistolik else None
        self._olcekleyici: dict[str, YenidenOlcekle] = {}
        self._lut: dict[str, np.ndarray] = {}
        self._adim = frozenset(self.ayar.tasima_adim)
        bilinmeyen = self._adim - set(TASIMA_ADIMLARI)
        if bilinmeyen:
            raise ValueError(f"bilinmeyen taşıma adımı: {sorted(bilinmeyen)}")
        if self._adim and not (self.ayar.yeniden_olcekle == "sabit" and self.ayar.layer_norm == "tam"
                               and self.ayar.softmax == "tam" and self.ayar.gelu == "lut"
                               and self.ayar.tanh == "lut"):
            raise ValueError("tamsayı taşıma yalnızca tam B-kipinde (tüm birimler tamsayı) çalışır")
        self._son_cikis = None            # son _lineer çıkışı: (INT8 cikis_q, ölçek)
        self._ln_son = None               # son _ln çıkışı: (INT8 cikis_q, ölçek)
        if self.ayar.tamsayi_birim_var() and not self.ara_olcekler:
            raise ValueError(
                "B-kipi ara tensör ölçek tablosu ister. Önce "
                "`python 01_kalibre_ara_olcek.py` çalıştırıp çıkan JSON'u verin.")

    # ------------------------------------------------------------------
    # yardımcılar
    # ------------------------------------------------------------------
    def _kaydet(self, ad: str, x: np.ndarray):
        if self.ayar.izle_ara_tensor:
            self.izle[ad] = np.asarray(x)

    def _olcek(self, ad: str) -> float:
        try:
            return float(self.ara_olcekler[ad])
        except KeyError:
            raise KeyError(f"'{ad}' için kalibre edilmiş ölçek yok. "
                           f"01_kalibre_ara_olcek.py yeniden koşturulmalı.") from None

    def _olcek_birimi(self, kat, cikis_olcek: float | None) -> YenidenOlcekle:
        """Katman başına yeniden ölçekleme birimi (bir kez kurulur, saklanır).

        float kipinde çarpan doğrudan a_olcek*w_olcek'tir.
        sabit kipinde çarpan (a_olcek*w_olcek)/cikis_olcek olur; sonuç INT8.
        """
        if kat.ad not in self._olcekleyici:
            M = kat.cikis_olcek if cikis_olcek is None else kat.cikis_olcek / cikis_olcek
            self._olcekleyici[kat.ad] = YenidenOlcekle(
                M_gercel=M, kip=self.ayar.yeniden_olcekle,
                m0_bit=self.ayar.m0_bit,
                paylasimli_kaydirma=self.ayar.paylasimli_kaydirma)
        return self._olcekleyici[kat.ad]

    def _ln_girdi_olcegi(self, ad: str) -> float:
        return self._olcek(f"{ad}.girdi") * 127.0 / (2 ** (self.ayar.ln_bit - 1) - 1)

    def _tam_yeniden(self, q, s_kaynak: float, s_hedef: float,
                     alt: int = S.AKT_MIN, ust: int = S.AKT_MAX) -> np.ndarray:
        """Tamsayıyı s_kaynak ölçeğinden s_hedef ölçeğine taşır: kirp((q*M0 + 2^(n-1)) >> n).

        Ölçekler eşitse çarpma yoktur (yalnızca kırpma). Donanım karşılığı: yeniden ölçekleme
        biriminin skaler-M0 hali (tek çarpıcı + kaydırma)."""
        q = np.asarray(q, dtype=np.int64)
        oran = float(s_kaynak) / float(s_hedef)
        if abs(oran - 1.0) < 1e-12:
            y = q
        else:
            M0, n = nicem.carpani_ayristir(oran, self.ayar.m0_bit)
            y = nicem.sabit_nokta_carp(q, M0, n)
        return nicem.kirp(y, alt, ust).astype(np.int64)

    def _lineer(self, kat, x_float: np.ndarray, ad: str, xq: np.ndarray | None = None) -> np.ndarray:
        """Nicemlenmiş Linear. Girdi FP32, çıkış FP32 (iç yol tamamen tamsayı).

        float kipi : cikis = birikec * (a_olcek * w_olcek)        [PTQ ile birebir]
        sabit kipi : cikis_q = kirp(birikec * M0 >> n), cikis = cikis_q * cikis_olcek
        """
        if xq is None:
            xq = kat.girdiyi_nicele(x_float)
        self._kaydet(f"{ad}.girdi_q", xq)
        self._son_cikis = None
        acc = kat.birikec(xq, self._dizi, self.kayit)
        self._kaydet(f"{ad}.birikec", acc)

        if self.ayar.yeniden_olcekle == "float":
            birim = self._olcek_birimi(kat, None)
            y = (acc.astype(np.float64) * kat.cikis_olcek).astype(np.float32)
        else:
            s_out = self._olcek(f"{ad}.cikis")
            birim = self._olcek_birimi(kat, s_out)
            yq = birim.uygula(acc)                       # INT8
            self._kaydet(f"{ad}.cikis_q", yq)
            self._son_cikis = (yq, s_out)
            y = (yq.astype(np.float32) * np.float32(s_out))
        self._kaydet(f"{ad}.cikis", y)
        return y

    def _ln(self, x_float: np.ndarray | None, gamma, beta, ad: str,
            q: np.ndarray | None = None) -> np.ndarray:
        if self.ayar.layer_norm == "float":
            y = dol.katman_norm_fp(x_float, gamma, beta)
        else:
            # LayerNorm girdisi artık toplamdan gelir ve 8 bitte çözünürlüğü
            # yetmez (ölçüm: 8 bit -> 0.125, 12 bit -> 0.037 maks hata)
            s_in = (self._olcek(f"{ad}.girdi") * 127.0
                    / (2 ** (self.ayar.ln_bit - 1) - 1))
            s_out = self._olcek(f"{ad}.cikis")
            if q is None:
                q = nicem.nicele(x_float, s_in, alt=-(2**31), ust=2**31 - 1)
            yq = dol.katman_norm_tam(q, s_in, gamma, beta, s_out)
            self._kaydet(f"{ad}.cikis_q", yq)
            self._ln_son = (yq, s_out)
            y = (yq.astype(np.float32) * np.float32(s_out))
        self._kaydet(ad, y)
        return y

    # ------------------------------------------------------------------
    # ileri yol
    # ------------------------------------------------------------------
    def ileri(self, ids: np.ndarray, maske: np.ndarray,
              tip_ids: np.ndarray | None = None) -> np.ndarray:
        """(B, S) token kimlikleri -> (B, 2) logit."""
        if self.ayar.kip == "fp32":
            return self._ileri_fp32(ids, maske, tip_ids)

        p = self.p
        B, Sq = ids.shape

        # --- ANA BİLGİSAYAR TARAFI: gömme araması (3.9 MB tablo FPGA'ya girmez)
        h = p.gomme_ileri(ids, tip_ids)
        self._kaydet("gomme.ln.girdi", h)
        h = self._ln(h, p.gomme_ln_gamma, p.gomme_ln_beta, "gomme.ln")
        hq, hs = self._ln_son if self._adim else (None, None)
        self._kaydet("fpga.girdi", h)
        adim = self._adim
        tam = self._tam_yeniden

        # --- FPGA TARAFI ---
        maske_sapma = ((1.0 - np.asarray(maske, np.float32)[:, None, None, :])
                       * np.float32(np.finfo(np.float32).min))
        maske_b = np.asarray(maske, dtype=bool)[:, None, None, :]

        def bol(t):
            return t.reshape(B, Sq, S.BASLIK_SAYISI, S.BASLIK_BOYU).transpose(0, 2, 1, 3)

        for i, kat in enumerate(p.katmanlar):
            on = f"l{i}"
            kaynak = "gomme" if i == 0 else "ln_cikis"
            gx = (lambda k_: tam(hq, hs, k_.a_olcek)) if kaynak in adim else (lambda k_: None)
            qh = bol(self._lineer(kat.q, h, f"{on}.q", gx(kat.q)))
            q_q, s_q = self._son_cikis if adim else (None, None)
            kh = bol(self._lineer(kat.k, h, f"{on}.k", gx(kat.k)))
            k_q, s_k = self._son_cikis if adim else (None, None)
            vh = bol(self._lineer(kat.v, h, f"{on}.v", gx(kat.v)))
            v_q, s_v = self._son_cikis if adim else (None, None)

            skor = ((qh @ kh.transpose(0, 1, 3, 2)).astype(np.float32)
                    / np.float32(np.sqrt(S.BASLIK_BOYU)))
            self._kaydet(f"{on}.skor", skor)

            if self.ayar.softmax == "float":
                olasilik = dol.softmax_fp(skor + maske_sapma)
            else:
                # kalibrasyon ölçeği 8 bit varsayımıyla yazılır; skor yolu daha
                # geniş tutulduğunda adım buna göre daralır (bkz. test_birimler)
                s_skor = (self._olcek(f"{on}.skor") * 127.0
                          / (2 ** (self.ayar.skor_bit - 1) - 1))
                if "qk" in adim:
                    qk_acc = bol(q_q).astype(np.int64) @ bol(k_q).astype(np.int64).transpose(0, 1, 3, 2)
                    skor_q = tam(qk_acc, s_q * s_k / np.sqrt(S.BASLIK_BOYU), s_skor,
                                 alt=-(2**31), ust=2**31 - 1)
                    self._kaydet(f"{on}.qk_birikec", qk_acc)
                else:
                    skor_q = nicem.nicele(skor, s_skor, alt=-(2**31), ust=2**31 - 1)
                p_q = dol.softmax_tam(skor_q, s_skor, maske_b)
                self._kaydet(f"{on}.olasilik_q", p_q)
                olasilik = p_q.astype(np.float32) * np.float32(S.SOFTMAX_CIKIS_OLCEK)
            self._kaydet(f"{on}.olasilik", olasilik)

            baglam = ((olasilik.astype(np.float32) @ vh).transpose(0, 2, 1, 3)
                      .reshape(B, Sq, S.GIZLI_BOYUT).astype(np.float32))
            self._kaydet(f"{on}.baglam", baglam)

            if "av" in adim:
                av_acc = p_q.astype(np.int64) @ bol(v_q).astype(np.int64)      # (B,H,T,D) INT32
                self._kaydet(f"{on}.av_birikec", av_acc)
                baglam_q = tam(av_acc, s_v * S.SOFTMAX_CIKIS_OLCEK, kat.attn_cikis.a_olcek)
                baglam_q = baglam_q.transpose(0, 2, 1, 3).reshape(B, Sq, S.GIZLI_BOYUT)
                a = self._lineer(kat.attn_cikis, baglam, f"{on}.attn_out", baglam_q)
            else:
                a = self._lineer(kat.attn_cikis, baglam, f"{on}.attn_out")
            a_q, s_a = self._son_cikis if adim else (None, None)

            if "artik" in adim:
                s_ln = self._ln_girdi_olcegi(f"{on}.ln1")
                q1 = (tam(hq, hs, s_ln, alt=-(2**31), ust=2**31 - 1)
                      + tam(a_q, s_a, s_ln, alt=-(2**31), ust=2**31 - 1))
                self._kaydet(f"{on}.ln1.girdi_q", q1)
                h = self._ln(None, kat.attn_ln_gamma, kat.attn_ln_beta, f"{on}.ln1", q=q1)
            else:
                artik1 = h + a                   # artık (residual) toplam
                self._kaydet(f"{on}.ln1.girdi", artik1)
                h = self._ln(artik1, kat.attn_ln_gamma, kat.attn_ln_beta, f"{on}.ln1")
            if adim:
                hq, hs = self._ln_son

            ara = self._lineer(kat.ffn1, h, f"{on}.ffn1",
                               tam(hq, hs, kat.ffn1.a_olcek) if "ln_cikis" in adim else None)
            ara_q1 = self._son_cikis[0] if adim else None
            if self.ayar.gelu == "float":
                g = dol.gelu_fp(ara)
            else:
                s_in = self._olcek(f"{on}.ffn1.cikis")
                s_out = self._olcek(f"{on}.gelu")
                anahtar = f"{on}.gelu"
                if anahtar not in self._lut:
                    self._lut[anahtar] = dol.gelu_lut_uret(s_in, s_out)
                if "gelu_tanh" in adim:
                    ara_q = ara_q1               # ffn1.cikis ile GELU girdisi aynı ölçek: taşıma yok
                else:
                    ara_q = nicem.nicele(ara, s_in)
                g_q = dol.gelu_tam(ara_q, self._lut[anahtar])
                g = g_q.astype(np.float32) * np.float32(s_out)
            self._kaydet(f"{on}.gelu", g)

            o = self._lineer(kat.ffn2, g, f"{on}.ffn2",
                             tam(g_q, s_out, kat.ffn2.a_olcek) if "gelu_tanh" in adim else None)
            o_q, s_o = self._son_cikis if adim else (None, None)
            if "artik" in adim:
                s_ln = self._ln_girdi_olcegi(f"{on}.ln2")
                q2 = (tam(hq, hs, s_ln, alt=-(2**31), ust=2**31 - 1)
                      + tam(o_q, s_o, s_ln, alt=-(2**31), ust=2**31 - 1))
                self._kaydet(f"{on}.ln2.girdi_q", q2)
                h = self._ln(None, kat.cikis_ln_gamma, kat.cikis_ln_beta, f"{on}.ln2", q=q2)
            else:
                artik2 = h + o
                self._kaydet(f"{on}.ln2.girdi", artik2)
                h = self._ln(artik2, kat.cikis_ln_gamma, kat.cikis_ln_beta, f"{on}.ln2")
            if adim:
                hq, hs = self._ln_son

        self._kaydet("fpga.cikis", h)

        # --- havuzlama + sınıflandırma ---
        havuz_ham = self._lineer(p.pooler, h[:, 0, :], "pooler",
                                 tam(hq[:, 0, :], hs, p.pooler.a_olcek) if "ln_cikis" in adim else None)
        ham_q1 = self._son_cikis[0] if adim else None
        if self.ayar.tanh == "float":
            havuz = dol.tanh_fp(havuz_ham)
        else:
            s_in = self._olcek("pooler.cikis")
            s_out = self._olcek("pooler.tanh")
            if "tanh" not in self._lut:
                self._lut["tanh"] = dol.tanh_lut_uret(s_in, s_out)
            ham_q = ham_q1 if "gelu_tanh" in adim else nicem.nicele(havuz_ham, s_in)
            t_q = dol.tanh_tam(ham_q, self._lut["tanh"])
            havuz = t_q.astype(np.float32) * np.float32(s_out)
        self._kaydet("pooler.tanh", havuz)

        logit = self._lineer(p.siniflandirici, havuz, "classifier",
                             tam(t_q, s_out, p.siniflandirici.a_olcek) if "gelu_tanh" in adim else None)
        self._kaydet("logit", logit)
        return logit

    # ------------------------------------------------------------------
    def _ileri_fp32(self, ids, maske, tip_ids):
        """Saf FP32 referans — nicemlemenin hiç devreye girmediği yol."""
        p, sd = self.p, self.p.fp32
        B, Sq = ids.shape
        h = dol.katman_norm_fp(p.gomme_ileri(ids, tip_ids),
                               p.gomme_ln_gamma, p.gomme_ln_beta)
        maske_sapma = ((1.0 - np.asarray(maske, np.float32)[:, None, None, :])
                       * np.float32(np.finfo(np.float32).min))

        def lin(ad, x):
            return (x @ sd[f"{ad}.weight"].T + sd[f"{ad}.bias"]).astype(np.float32)

        def bol(t):
            return t.reshape(B, Sq, S.BASLIK_SAYISI, S.BASLIK_BOYU).transpose(0, 2, 1, 3)

        for i in range(S.KATMAN_SAYISI):
            pre = f"bert.encoder.layer.{i}"
            qh, kh, vh = (bol(lin(f"{pre}.attention.self.{n}", h))
                          for n in ("query", "key", "value"))
            skor = (qh @ kh.transpose(0, 1, 3, 2)) / np.float32(np.sqrt(S.BASLIK_BOYU))
            olasilik = dol.softmax_fp(skor + maske_sapma)
            baglam = (olasilik @ vh).transpose(0, 2, 1, 3).reshape(B, Sq, S.GIZLI_BOYUT)
            a = lin(f"{pre}.attention.output.dense", baglam.astype(np.float32))
            h = dol.katman_norm_fp(h + a, sd[f"{pre}.attention.output.LayerNorm.weight"],
                                   sd[f"{pre}.attention.output.LayerNorm.bias"])
            g = dol.gelu_fp(lin(f"{pre}.intermediate.dense", h))
            o = lin(f"{pre}.output.dense", g)
            h = dol.katman_norm_fp(h + o, sd[f"{pre}.output.LayerNorm.weight"],
                                   sd[f"{pre}.output.LayerNorm.bias"])

        havuz = dol.tanh_fp(lin("bert.pooler.dense", h[:, 0, :]))
        return lin("classifier", havuz)
