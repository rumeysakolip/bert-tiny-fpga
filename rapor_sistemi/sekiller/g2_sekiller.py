"""G2 şekilleri: birimler arası taşımanın tamsayıya alınmasının adım adım doğruluk etkisi (02-RTL_Altin_Model/03_Sonuclar/tasima_kayip.json)."""
import csv

import numpy as np

from tr_ortak import *   # noqa


def g2():
    d = json_oku(os.path.join(SONUC, "tasima_kayip.json"))
    k = d["kosular"]
    kum = [("B (float taşıma)", "B_float_tasima")] + [(a, f"kumulatif_{i}_{a}") for i, a in enumerate(d["adimlar"], 1)]
    deger = [k[x[1]]["dogru"] for x in kum]
    n, fp = d["n_cumle"], d["fp32_dogru"]

    fig, ax = plt.subplots(figsize=(6.3, 3.2))
    ax.plot(range(len(kum)), deger, "o-", color=MAVI, lw=1.5)
    for i, v in enumerate(deger):
        ax.text(i, v + 0.35, str(v), ha="center", fontsize=7)
    ax.axhline(fp, color=GRI, ls="--", lw=1); ax.text(len(kum) - 0.5, fp + 0.3, f"FP32 {fp}", ha="right", fontsize=7, color=GRI)
    ax.axhline(711, color=YESIL, ls=":", lw=1); ax.text(len(kum) - 0.5, 711.3, "hedef 711 (≤1 puan)", ha="right", fontsize=7, color=YESIL)
    ax.axhline(702, color=KIRMIZI, ls=":", lw=1); ax.text(len(kum) - 0.5, 702.3, "sınır 702 (≤2 puan)", ha="right", fontsize=7, color=KIRMIZI)
    ax.set_xticks(range(len(kum))); ax.set_xticklabels([x[0] for x in kum], rotation=30, ha="right", fontsize=6.5)
    ax.set_ylim(698, 722); ax.set_ylabel(f"Doğru cümle ({n} içinden)")
    ax.set_title("Taşıma adımları tamsayıya alındıkça doğruluk (kümülatif; ±1–2 cümle gürültü)")
    kaydet(fig, "g2_s1_kumulatif.png")

    tek = [(a, k[f"tek_{a}"]) for a in d["adimlar"]]
    fig, ax = plt.subplots(figsize=(6.0, 3.0))
    ax.bar([a for a, _ in tek], [v["B_float_ile_ayrisan_cumle"] for _, v in tek], color=TURUNCU)
    for i, (_, v) in enumerate(tek):
        ax.text(i, v["B_float_ile_ayrisan_cumle"] + 0.05, f"maks Δlogit {v['maks_logit_farki_B_floata_gore']:.3f}", ha="center", fontsize=6.5)
    ax.set_ylabel("B(float) ile farklı karar veren cümle"); plt.setp(ax.get_xticklabels(), rotation=25, ha="right", fontsize=7)
    ax.set_title("Her adım tek başına açıldığında karar değişen cümle sayısı")
    kaydet(fig, "g2_s2_tek_adim.png")

    satir = list(csv.DictReader(open(os.path.join(SONUC, "tasima_ayrisan_cumleler.csv"), encoding="utf-8")))
    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    x = np.arange(len(satir)); w = 0.38
    ax.bar(x - w / 2, [float(s["logit_fark_B_float"]) for s in satir], w, label="B (float taşıma)", color=ACIK_MAVI)
    ax.bar(x + w / 2, [float(s["logit_fark_tam"]) for s in satir], w, label="tam tamsayı hat", color=TURUNCU)
    ax.axhline(0, color="k", lw=0.6)
    ax.set_xticks(x); ax.set_xticklabels([f"#{s['idx']}\n(etiket {s['etiket']})" for s in satir], fontsize=7)
    ax.set_ylabel("logit(olumlu) − logit(olumsuz)"); ax.legend(fontsize=7)
    ax.set_title(f"Kararı değişen {len(satir)} cümle: marjin sıfıra çok yakın (gürültü düzeyi)")
    kaydet(fig, "g2_s3_ayrisan.png")


if __name__ == "__main__":
    g2()
