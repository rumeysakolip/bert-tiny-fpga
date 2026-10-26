"""G2 — Birimler arası taşımayı tamsayıya al ve adım adım kaybı ölç.

Altın B-kipinde birimler arası taşıma float'tı (gömme çıkışı, artık toplamlar,
Q·Kᵀ, P·V, GELU/tanh çıkışı). Bu betik her taşıma adımını sırayla tamsayı yeniden
ölçeklemeye çevirir ve 872 cümlede doğruluk/kayıp/çapraz entropi ölçer:

  * KÜMÜLATİF: B(float taşıma) -> +gömme -> +ln_cikis -> +artik -> +qk -> +av -> +gelu_tanh
  * TEK ADIM : B + yalnızca o adım (her adımın bağımsız etkisi)

Çıktılar (03_Sonuclar/): tasima_kayip.json, tasima_kayip.csv, tasima_ayrisan_cumleler.csv
Çalıştırma:  python 06_tasima_olc.py   [--m0_bit 31] [--n 872]
"""

from __future__ import annotations

import argparse
import csv
import importlib.util
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ortak  # noqa: E402
from altin import model, veri  # noqa: E402
from altin.model import TASIMA_ADIMLARI, TASIMA_ACIKLAMA  # noqa: E402


def _karsilastir_modulu():
    yol = os.path.join(ortak.HERE, "05_karsilastir.py")
    spec = importlib.util.spec_from_file_location("karsilastir05", yol)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main():
    ap = ortak.ortak_argumanlar(argparse.ArgumentParser(description=__doc__))
    ap.add_argument("--m0_bit", type=int, default=31, help="31 = RTL parametre paketi (parametreler.vh)")
    ap.add_argument("--ara_olcek", default=None)
    ap.add_argument("--yigin", type=int, default=128)
    ap.add_argument("--n", type=int, default=None, help="yalnız ilk n cümle (hızlı deneme)")
    a = ap.parse_args()
    k5 = _karsilastir_modulu()

    p, _, cumleler, etiket, ids, maske, y = ortak.yukle_hepsi(a)
    if a.n:
        cumleler, etiket, ids, maske = cumleler[:a.n], etiket[:a.n], ids[:a.n], maske[:a.n]
    etiket = np.asarray(etiket)
    ara_yol = a.ara_olcek or os.path.join(a.cikis, "ara_olcekler.json")
    with open(ara_yol, encoding="utf-8") as f:
        ara = json.load(f)["olcekler"]

    def kos(ayar):
        m = model.AltinModel(p, ayar, ara)
        return np.concatenate([m.ileri(i, k) for i, k in veri.yiginla(ids, maske, a.yigin)])

    lg32 = kos(model.Ayarlar(kip="fp32"))
    pr32 = lg32.argmax(1)
    d32 = int((pr32 == etiket).sum())
    print(f"FP32 referansı: {d32}/{len(etiket)}")

    kosular = [("B_float_tasima", ())]
    for k in range(1, len(TASIMA_ADIMLARI) + 1):
        kosular.append((f"kumulatif_{k}_{TASIMA_ADIMLARI[k - 1]}", TASIMA_ADIMLARI[:k]))
    for ad in TASIMA_ADIMLARI:
        kosular.append((f"tek_{ad}", (ad,)))

    sonuc = {"m0_bit": a.m0_bit, "n_cumle": int(len(etiket)), "fp32_dogru": d32,
             "adimlar": {k: TASIMA_ACIKLAMA[k] for k in TASIMA_ADIMLARI}, "kosular": {}}
    tahmin, logit = {}, {}
    onceki_kumul = None
    print(f"{'koşu':32s}{'doğru':>7s}{'kayıp':>8s}{'CE':>8s}{'önceki ile fark':>17s}{'maks|dlogit|':>14s}")
    for ad, adim in kosular:
        lg = kos(model.Ayarlar.B_kipi(m0_bit=a.m0_bit, tasima_adim=adim))
        pr = lg.argmax(1)
        tahmin[ad], logit[ad] = pr, lg
        ref = tahmin["B_float_tasima"]
        o = k5.degerlendir(etiket, pr32, pr)
        ce = k5.capraz_entropi(lg, etiket)["kayip"]
        onc = onceki_kumul if ad.startswith("kumulatif") else None
        fark_onc = int((pr != tahmin[onc]).sum()) if onc else None
        dlg = float(np.abs(lg - logit["B_float_tasima"]).max())
        sonuc["kosular"][ad] = {
            "adim": list(adim), "dogru": o["dogru"], "kayip_puan_fp32e_gore": o["kayip_puan"],
            "kayip_cumle": o["kayip_cumle"], "capraz_entropi": ce,
            "B_float_ile_ayrisan_cumle": int((pr != ref).sum()),
            "onceki_kumulatif_ile_ayrisan": fark_onc,
            "fp32_ile_uyusma": o["uyusma_orani"],
            "maks_logit_farki_B_floata_gore": round(dlg, 4),
            "ortalama_logit_farki": round(float(np.abs(lg - logit["B_float_tasima"]).mean()), 5),
            "hedef_711": o["dogru"] >= 711, "sinir_702": o["dogru"] >= 702,
            "mlperf_712": o["dogru"] >= 712,
        }
        if ad.startswith("kumulatif") or ad == "B_float_tasima":
            onceki_kumul = ad
        print(f"{ad:32s}{o['dogru']:7d}{o['kayip_puan']:7.2f}p{ce:8.4f}"
              f"{'' if fark_onc is None else fark_onc:>17}{dlg:14.4f}")

    son = kosular[len(TASIMA_ADIMLARI)][0]          # son kümülatif koşu = tam tamsayı hat
    sonuc["tam_hat"] = {"kosu": son, **sonuc["kosular"][son]}

    os.makedirs(a.cikis, exist_ok=True)
    with open(os.path.join(a.cikis, "tasima_kayip.json"), "w", encoding="utf-8") as f:
        json.dump(sonuc, f, ensure_ascii=False, indent=1)
    with open(os.path.join(a.cikis, "tasima_kayip.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["kosu", "dogru", "kayip_puan", "capraz_entropi", "B_float_ile_ayrisan", "onceki_ile_ayrisan",
                    "maks_logit_farki"])
        for k, v in sonuc["kosular"].items():
            w.writerow([k, v["dogru"], v["kayip_puan_fp32e_gore"], v["capraz_entropi"],
                        v["B_float_ile_ayrisan_cumle"], v["onceki_kumulatif_ile_ayrisan"], v["maks_logit_farki_B_floata_gore"]])
    # tam hat ile B(float) arasında ayrışan cümleler
    ref, tam = tahmin["B_float_tasima"], tahmin[son]
    with open(os.path.join(a.cikis, "tasima_ayrisan_cumleler.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["idx", "etiket", "fp32", "B_float", "tam_hat", "logit_fark_B_float", "logit_fark_tam", "cumle"])
        for i in np.where(ref != tam)[0]:
            lf = logit["B_float_tasima"][i]
            lt = logit[son][i]
            w.writerow([int(i), int(etiket[i]), int(pr32[i]), int(ref[i]), int(tam[i]),
                        round(float(lf[1] - lf[0]), 3), round(float(lt[1] - lt[0]), 3), cumleler[i]])
    t = sonuc["tam_hat"]
    print(f"\nTAM TAMSAYI HAT: {t['dogru']}/{len(etiket)} (FP32 {d32}); kayıp {t['kayip_puan_fp32e_gore']} puan; "
          f"hedef>=711: {t['hedef_711']}, sınır>=702: {t['sinir_702']}")


if __name__ == "__main__":
    main()
