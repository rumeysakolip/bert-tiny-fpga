"""G18 -- dogruluk deneyi: FP32 / INT8 PTQ (yazilim) / altin model / tam tamsayi donanim hatti, 872 SST-2 dev cumlesi.
Girdiler (OKUNUR): 01-INT8_Nicemleme/03_Sonuclar/int8_ptq/ozet_tablo.csv (6 PTQ kosusu),
02-RTL_Altin_Model/03_Sonuclar/tasima_kayip.json (G2 tasima adimlari), karsilastirma_ozet.csv (FP32, PTQ, altin A/B).
QAT CALISTIRILMADI: PTQ karar kurali (kriterler.md): kayip <= 1 puan ise QAT gerekmez.
Cikti: 03-RTL/sim/g18_ozet.json, rapor_sistemi/g18_tablo.csv, sekiller/g18_s1_dogruluk.png, g18_s2_tasima.png"""
import csv

from tr_ortak import *   # noqa: E402

PTQ = os.path.join(PROJE, "01-INT8_Nicemleme", "03_Sonuclar", "int8_ptq", "ozet_tablo.csv")
TAS = os.path.join(SONUC, "tasima_kayip.json")
KAR = os.path.join(SONUC, "karsilastirma_ozet.csv")
N = 872
HEDEF, SINIR = 711, 702          # kriterler: <= 1 puan, <= 2 puan (nihai plan)


def main():
    ptq = list(csv.DictReader(open(PTQ, encoding="utf-8")))
    kar = {r["model"]: r for r in csv.DictReader(open(KAR, encoding="utf-8"))}
    tas = json_oku(TAS)
    fp32 = int(tas["fp32_dogru"])
    satirlar = [("FP32 referans", fp32, 1.0)]
    for r in ptq:
        satirlar.append((f"PTQ {r['kosu']}", int(r["dogru_int8"]), float(r["uyusma_orani"])))
    satirlar.append(("Altın model A (PTQ eşdeğeri)", int(kar["Altın-A (PTQ eşdeğeri)"]["dogru"]), float(kar["Altın-A (PTQ eşdeğeri)"]["uyusma_orani"])))
    th = tas["tam_hat"]
    satirlar.append(("Tam tamsayı hat (donanım düzeni)", th["dogru"], th["fp32_ile_uyusma"]))

    with open(os.path.join(AY, "g18_tablo.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(["yapilandirma", "dogru", "dogruluk_yuzde", "kayip_puan", "fp32_ile_uyusma_yuzde", "hedef_<=1puan", "sinir_<=2puan"])
        for ad, d, u in satirlar:
            w.writerow([ad, d, f"{100 * d / N:.2f}", f"{100 * (fp32 - d) / N:.2f}", f"{100 * u:.2f}", d >= HEDEF, d >= SINIR])
    json.dump({"n_cumle": N, "fp32": fp32, "satirlar": [{"ad": a, "dogru": d, "uyusma": u} for a, d, u in satirlar],
               "tam_hat": th, "qat_calistirildi": False, "gurultu_kurali": "1 puan ~ 8,72 cumle; 1-2 cumle farki gurultu"},
              open(os.path.join(RTL, "sim", "g18_ozet.json"), "w", encoding="utf-8"), indent=1, ensure_ascii=False)

    # S1: doğru sayisi, esikler
    fig, ax = plt.subplots(figsize=(6.8, 3.2))
    ad = [a for a, _, _ in satirlar]; d = [x for _, x, _ in satirlar]
    renk = [GRI] + [MAVI] * len(ptq) + [TURUNCU, YESIL]
    ax.barh(range(len(ad))[::-1], d, color=renk)
    for i, y in zip(range(len(ad))[::-1], d):
        ax.text(y + 0.3, i, f"{y}  ({100 * y / N:.2f}%)", va="center", fontsize=7)
    ax.axvline(HEDEF, color=KIRMIZI, ls="--", lw=1); ax.text(HEDEF - 0.3, len(ad) - 0.4, f"hedef ≥{HEDEF}\n(≤1 puan)", color=KIRMIZI, fontsize=6.5, ha="right")
    ax.set_yticks(range(len(ad))[::-1]); ax.set_yticklabels(ad, fontsize=7)
    ax.set_xlim(705, 726); ax.set_xlabel(f"doğru sınıflanan cümle ({N} SST-2 doğrulama cümlesi)")
    ax.set_title("Doğruluk deneyi: FP32 ile 8 bit tamsayı varyantları (eksen 705'ten başlar)", fontsize=8.5)
    kaydet(fig, "g18_s1_dogruluk.png")

    # S2: tasima adimlari
    adlar = ["B (float taşıma)", "+gömme", "+LN çıkışı", "+artık", "+Q·Kᵀ", "+P·V", "+GELU/tanh"]
    anah = ["B_float_tasima", "kumulatif_1_gomme", "kumulatif_2_ln_cikis", "kumulatif_3_artik", "kumulatif_4_qk", "kumulatif_5_av", "kumulatif_6_gelu_tanh"]
    dv = [tas["kosular"][k]["dogru"] for k in anah]
    uy = [100 * tas["kosular"][k]["fp32_ile_uyusma"] for k in anah]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.7))
    a1.plot(range(len(dv)), dv, "o-", color=MAVI); a1.axhline(fp32, color=GRI, ls="--", lw=1); a1.text(0, fp32 + 0.2, f"FP32 {fp32}", fontsize=7, color=GRI)
    a1.set_ylim(714, 721); a1.set_xticks(range(len(adlar))); a1.set_xticklabels(adlar, rotation=40, ha="right", fontsize=6.5); a1.set_ylabel("doğru cümle")
    a1.set_title("Tamsayı taşıma adımları (kümülatif)", fontsize=8.5)
    a2.plot(range(len(uy)), uy, "s-", color=TURUNCU); a2.set_ylim(99.2, 100.05)
    a2.set_xticks(range(len(adlar))); a2.set_xticklabels(adlar, rotation=40, ha="right", fontsize=6.5); a2.set_ylabel("FP32 ile uyuşma (%)")
    a2.set_title("FP32 ile aynı tahmin oranı", fontsize=8.5)
    fig.tight_layout(); kaydet(fig, "g18_s2_tasima.png")
    for a, x, u in satirlar:
        print(f"{a:40s} {x} {100 * (fp32 - x) / N:.2f} puan  uyusma %{100 * u:.2f}")


if __name__ == "__main__":
    main()
