"""Konu 5 -- LayerNorm 12 mi 16 bit mi: altin modelde dogruluk karsilastirmasi -> sim/layernorm_bit_dogruluk.json

Calistirma:  python scripts/konu5_ln_bit.py        (cwd: 03-RTL)
Altin modelin dosyalari ve varsayilanlari DEGISTIRILMEZ. g_bit varsayilani (12) yalniz bu surecin bellegindeki
`dogrusal_olmayan.katman_norm_tam` cagrisina functools.partial ile sarilarak degistirilir; ln_bit Ayarlar'in mevcut parametresidir.
Yapilandirma: tam tamsayi hat = Ayarlar.B_kipi(m0_bit=31, tasima_adim=TASIMA_ADIMLARI) (RTL'in uydugu hat; varsayilan g_bit=12, ln_bit=12).
  g_bit : d/std'nin kesir bit sayisi ve gamma'nin sabit nokta olcegi (RTL parametresi G)
  ln_bit: LayerNorm girdisinin (artik toplam) veri yolu genisligi (Ayarlar.ln_bit)
Kural: 872 cumlede 1 puan ~ 8,72 cumle; 1-2 cumle farki gurultudur, ustunluk sayilmaz.
"""
import argparse
import functools
import json
import os
import sys
import time

import numpy as np

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJE = os.path.dirname(KOK)
sys.path.insert(0, os.path.join(PROJE, "02-RTL_Altin_Model", "01_Kod"))
import ortak  # noqa: E402
from altin import dogrusal_olmayan as dol  # noqa: E402
from altin import model, nicem, veri  # noqa: E402

SINIR = 1 << 62


def main():
    os.chdir(KOK)
    args = ortak.ortak_argumanlar(argparse.ArgumentParser()).parse_args([])
    p, _, cumleler, etiket, ids, maske, _ = ortak.yukle_hepsi(args)
    ara = json.load(open(os.path.join(args.cikis, "ara_olcekler.json"), encoding="utf-8"))["olcekler"]
    orijinal = dol.katman_norm_tam
    carp_orijinal = nicem.sabit_nokta_carp
    n = len(etiket)
    asim = {"say": 0}

    def carp_genis(birikec, M0, nn):
        """Ara carpim int64'e sigmiyorsa Python tamsayisi (object) ile hesaplar; sigiyorsa orijinal fonksiyon. Sonuc ayni, taşma yok."""
        b = np.asarray(birikec)
        if b.size and int(np.abs(b.astype(np.int64)).max()) * int(np.max(M0)) < SINIR:
            return carp_orijinal(birikec, M0, nn)
        asim["say"] += 1
        c = b.astype(object) * np.asarray(M0).astype(object)
        nn = int(nn)
        return ((c + (1 << (nn - 1))) >> nn).astype(np.int64) if nn > 0 else c.astype(np.int64)

    def kos(g_bit, ln_bit, genis=False):
        dol.katman_norm_tam = functools.partial(orijinal, g_bit=g_bit)
        nicem.sabit_nokta_carp = carp_genis if genis else carp_orijinal
        asim["say"] = 0
        try:
            ayar = model.Ayarlar.B_kipi(m0_bit=31, tasima_adim=model.TASIMA_ADIMLARI, ln_bit=ln_bit)
            m = model.AltinModel(p, ayar, ara)
            lg = np.concatenate([m.ileri(i, k) for i, k in veri.yiginla(ids, maske, 128)])
        finally:
            dol.katman_norm_tam = orijinal
            nicem.sabit_nokta_carp = carp_orijinal
        return lg

    kosular = {}
    t0 = time.time()
    tanim = {"g12_ln12 (varsayilan)": (12, 12, False), "g12_ln12_genis (yama denetimi)": (12, 12, True),
             "g16_ln12_int64 (TASAR, gecersiz)": (16, 12, False), "g16_ln12": (16, 12, True),
             "g12_ln16": (12, 16, True), "g16_ln16": (16, 16, True)}
    for ad, (g, l, gn) in tanim.items():
        lg = kos(g, l, gn)
        pr = lg.argmax(1)
        kosular[ad] = {"g_bit": g, "ln_bit": l, "genis_tamsayi": gn, "genis_cagri_sayisi": asim["say"], "logit": lg, "tahmin": pr,
                       "dogru": int((pr == etiket).sum())}
        print(f"{ad:34s} dogru {kosular[ad]['dogru']}/{n}  genis cagri {asim['say']}  ({time.time() - t0:.0f} sn)")
    ref = kosular["g12_ln12 (varsayilan)"]
    sonuc = {"etiket": "altin model (NumPy), 872 cumle", "cumle": n, "fp32_dogru": 719,
             "yapilandirma": "Ayarlar.B_kipi(m0_bit=31, tasima_adim=TASIMA_ADIMLARI); g_bit ve ln_bit disinda varsayilan",
             "gurultu_kurali": "1 puan ~ 8,72 cumle; 1-2 cumle farki gurultu", "kosular": {}}
    for ad, k in kosular.items():
        sonuc["kosular"][ad] = {
            "g_bit": k["g_bit"], "ln_bit": k["ln_bit"], "genis_tamsayi": k["genis_tamsayi"], "genis_cagri_sayisi": k["genis_cagri_sayisi"],
            "dogru": k["dogru"], "dogruluk": round(k["dogru"] / n, 4),
            "kayip_puan_fp32e_gore": round(100 * (719 - k["dogru"]) / n, 2),
            "varsayilandan_ayrisan_cumle": int((k["tahmin"] != ref["tahmin"]).sum()),
            "varsayilanla_dogru_yanlis_degisen": {"dogruyken_yanlis": int(((ref["tahmin"] == etiket) & (k["tahmin"] != etiket)).sum()),
                                                   "yanlisken_dogru": int(((ref["tahmin"] != etiket) & (k["tahmin"] == etiket)).sum())},
            "maks_logit_farki": round(float(np.abs(k["logit"] - ref["logit"]).max()), 4),
            "ortalama_logit_farki": round(float(np.abs(k["logit"] - ref["logit"]).mean()), 5)}
    json.dump(sonuc, open("sim/layernorm_bit_dogruluk.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    yama_ok = bool(np.array_equal(kosular["g12_ln12 (varsayilan)"]["logit"], kosular["g12_ln12_genis (yama denetimi)"]["logit"]))
    sonuc["yama_denetimi_g12_logitler_ayni"] = yama_ok
    sonuc["not"] = ("g16_ln12_int64: altin modelin int64 ara carpimi tasar (y*gamma_q*M0 ~ 2^63..2^67) ve sonuc GECERSIZDIR; "
                    "g_bit=16 sonuclari buyuk tamsayi (object) carpimi ile hesaplandi, 12 bit sonucu ayni (yama denetimi)")
    json.dump(sonuc, open("sim/layernorm_bit_dogruluk.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print("yama denetimi (g12 logitleri ayni):", yama_ok)
    for ad, k in sonuc["kosular"].items():
        print(ad, k)


if __name__ == "__main__":
    main()
