"""G20 -- dizi boyutu deneyi (N=4, 8, 16): sentez sonuclari, tile suresi, l0_q katman cevrimi.
Girdiler: 03-RTL/sentez/cikti/g20_n*_*.txt (Vivado), benzetim: 03-RTL/tb (tb_systolic_nxn, K=64) loglari elle degil
03-RTL/sim/g20_sonuc.json (bu betik yazar; benzetim sonuclarini ISTENEN SIRAYLA scripts/kos_g20.py uretir)."""
import json
import re

import numpy as np

from tr_ortak import *   # noqa: E402

CIKTI = os.path.join(RTL, "sentez", "cikti")
SIM = os.path.join(RTL, "sim")
NLER = [4, 8, 16]


def kaynak(n, kip):
    f = os.path.join(CIKTI, f"g20_n{n}_{kip}_kullanim.txt")
    if not os.path.exists(f):
        return None
    k = open(f, encoding="utf-8").read()
    g = lambda kalip: int(re.search(kalip, k).group(1))
    z = open(os.path.join(CIKTI, f"g20_n{n}_{kip}_zamanlama.txt"), encoding="utf-8").read()
    wns = float(re.search(r"WNS\(ns\).*?\n.*?\n\s*(-?[\d.]+)", z, re.S).group(1))
    return {"LUT": g(r"\|\s*Slice LUTs\*?\s*\|\s*(\d+)"), "FF": g(r"\|\s*Slice Registers\s*\|\s*(\d+)"),
            "DSP": g(r"\|\s*DSPs\s*\|\s*(\d+)"), "WNS": wns, "fmax_tahmin": 1000.0 / (10.0 - wns)}


def main():
    bench = json_oku(os.path.join(SIM, "g20_sonuc.json"))
    veri = {}
    K, C, T = 128, 128, 64                              # l0_q: K girdi, C kanal, T token
    for n in NLER:
        tile = bench[str(n)]["tile_cevrim"]
        tilesay = (T // n) * (C // n)
        veri[n] = {"sentez": kaynak(n, "sentez"), "impl": kaynak(n, "impl"), "tile_cevrim": tile,
                   "dogrulama": bench[str(n)]["pass"], "kontrol": bench[str(n)]["kontrol"],
                   "l0_q_tile_sayisi": tilesay, "l0_q_cevrim_hesap": tilesay * (K + 2 * n - 2 + 1)}
    veri[8]["l0_q_cevrim_olculen"] = 18392       # tb_katman (g7_sonuc.json), cumle basina
    json.dump(veri, open(os.path.join(SIM, "g20_ozet.json"), "w"), indent=1)

    # S1: kaynak kullanimi (sentez), DSP siniri
    fig, ax = plt.subplots(1, 3, figsize=(6.8, 2.5))
    for a, anah, bas, sinir in ((ax[0], "LUT", "LUT", 20800), (ax[1], "FF", "FF", 41600), (ax[2], "DSP", "DSP48E1", 90)):
        v = [veri[n]["sentez"][anah] for n in NLER]
        a.bar([f"{n}×{n}" for n in NLER], v, color=[ACIK_MAVI, MAVI, KIRMIZI if anah == "DSP" else MAVI])
        for i, y in enumerate(v):
            a.text(i, y, str(y), ha="center", va="bottom", fontsize=7)
        a.axhline(sinir, color=KIRMIZI, ls="--", lw=0.9)
        a.set_title(f"{bas} (kesikli: XC7A35T = {sinir})", fontsize=7.5)
        if anah != "DSP":
            a.set_yscale("log")
        a.set_ylim(top=max(max(v), sinir) * (1.6 if anah == "DSP" else 8))
    fig.suptitle("Dizi boyutuna göre kaynak (yalnızca dizi, sentez sonrası)", fontsize=9)
    fig.tight_layout(); kaydet(fig, "g20_s1_kaynak.png")

    # S2: tile suresi ve l0_q katman cevrimi
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.8, 2.6))
    a1.bar([f"{n}×{n}" for n in NLER], [veri[n]["tile_cevrim"] for n in NLER], color=MAVI)
    for i, n in enumerate(NLER):
        a1.text(i, veri[n]["tile_cevrim"], f"{veri[n]['tile_cevrim']}\n(K+2N−2)", ha="center", va="bottom", fontsize=7)
    a1.set_ylim(0, 115); a1.set_title("Tile süresi, K=64 (benzetimde ölçüldü)", fontsize=8); a1.set_ylabel("çevrim")
    cev = [veri[n]["l0_q_cevrim_hesap"] for n in NLER]
    b = a2.bar([f"{n}×{n}" for n in NLER], cev, color=[ACIK_MAVI, MAVI, GRI])
    for i, n in enumerate(NLER):
        et = f"{cev[i]}\n(hesap)" if n != 8 else f"{veri[8]['l0_q_cevrim_olculen']}\n(ölçüldü)"
        a2.text(i, cev[i], et, ha="center", va="bottom", fontsize=7)
    a2.set_ylim(0, max(cev) * 1.25); a2.set_title("l0_q katmanı, cümle başına (K=128, C=128, 64 token)", fontsize=8)
    fig.tight_layout(); kaydet(fig, "g20_s2_cevrim.png")

    # S3: zamanlama
    fig, ax = plt.subplots(figsize=(6.0, 2.4))
    etiket, deger = [], []
    for n in NLER:
        for kip, ad in (("sentez", "sentez"), ("impl", "yer.+yönl.")):
            v = veri[n][kip]
            etiket.append(f"{n}×{n}\n{ad}"); deger.append(v["WNS"] if v else np.nan)
    ax.bar(range(len(deger)), [0 if np.isnan(x) else x for x in deger], color=[GRI if np.isnan(x) else (YESIL if x >= 0 else KIRMIZI) for x in deger])
    for i, x in enumerate(deger):
        ax.text(i, 0.05 if np.isnan(x) else x, "yapılamadı\n(256 DSP > 90)" if np.isnan(x) else f"{x:.2f}", ha="center", va="bottom", fontsize=6.5)
    ax.set_xticks(range(len(deger))); ax.set_xticklabels(etiket, fontsize=6.5); ax.set_ylabel("WNS (ns), 100 MHz")
    ax.set_title("Zamanlama payı: yalnızca dizi, bağlam dışı (out-of-context)", fontsize=8.5)
    kaydet(fig, "g20_s3_zamanlama.png")
    print(json.dumps(veri, indent=1, default=str)[:1500])


if __name__ == "__main__":
    main()
