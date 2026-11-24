"""Rapor gorselleri g18 (kaynak kullanimi) ve g19 (agirlik akisi suresi, flas hizina gore).
g18: sentez ve yerlestirme raporlarindan (sentez/cikti/ust_impl_kullanim.txt, sentez/buyuk_*/impl_kullanim.txt) DSP, blok bellek ve LUT doluluk yuzdeleri.
g19: cumle basina agirlik bayti / flas bant genisligi (hesap) ile islemci ve ust model hesap suresi.
Kullanim (cwd: 04-RTL_Komutsuz):  python scripts/ciz_kaynak_flas.py"""
import os
import re

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(os.path.dirname(KOK), "raporlar", "gorseller")
plt.rcParams.update({"font.family": "Times New Roman", "font.size": 10.5, "axes.spines.top": False, "axes.spines.right": False})
MAVI, TURUNCU, YESIL, GRI = "#1f77b4", "#e69f00", "#009e73", "#555555"


def tr(x, n=1):
    return f"{x:,.{n}f}".replace(",", "_").replace(".", ",").replace("_", " ")


def oku_kullanim(yol):
    t = open(yol, encoding="utf-8", errors="replace").read()
    def al(ad):
        m = re.search(r"^\|\s*" + re.escape(ad) + r"\s*\|\s*([\d.]+)\s*\|[^|]*\|[^|]*\|\s*([\d.]+)\s*\|\s*([\d.]+)\s*\|", t, re.M)
        return (float(m.group(1)), float(m.group(2)), float(m.group(3))) if m else None
    return {"LUT": al("Slice LUTs"), "FF": al("Slice Registers"), "BRAM": al("Block RAM Tile"), "DSP": al("DSPs")}


KAYNAKLAR = [
    ("Basys 3\nXC7A35T\n1 dizi", os.path.join(KOK, "sentez", "cikti", "ust_impl_kullanim.txt")),
    ("XC7A100T\n2 dizi", os.path.join(KOK, "sentez", "buyuk_a100_na2", "impl_kullanim.txt")),
    ("XC7A200T\n8 dizi\n(üst model)", os.path.join(KOK, "sentez", "buyuk_na8_att", "impl_kullanim.txt")),
]
veriler = []
for ad, yol in KAYNAKLAR:
    if os.path.exists(yol):
        veriler.append((ad, oku_kullanim(yol)))
if veriler:
    fig, ax = plt.subplots(figsize=(5.7, 3.3))
    genislik = 0.26
    for j, (anahtar, etiket, renk) in enumerate((("DSP", "Çarpma bloğu (DSP)", MAVI), ("BRAM", "Blok bellek", TURUNCU), ("LUT", "Arama tablosu (LUT)", YESIL))):
        xs = [i + (j - 1) * genislik for i in range(len(veriler))]
        ys = [v[anahtar][2] if v[anahtar] else 0 for _, v in veriler]
        ax.bar(xs, ys, genislik, color=renk, label=etiket, edgecolor="white", lw=0.4)
        for x, y, (_, v) in zip(xs, ys, veriler):
            ax.text(x, y + 1.5, f"{tr(v[anahtar][0], 0)}" if v[anahtar] else "", ha="center", fontsize=8)
    ax.set_xticks(range(len(veriler))); ax.set_xticklabels([a for a, _ in veriler])
    ax.set_ylabel("Parçanın doluluğu (yüzde)"); ax.set_ylim(0, 112)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.28), ncol=3, frameon=False, fontsize=9)
    fig.savefig(os.path.join(OUT, "g18_kaynak_kullanimi.png"), dpi=200, facecolor="white", bbox_inches="tight")
    plt.close(fig)
    print("g18 yazildi")

# ---- g19: agirlik akisi ----
AGIRLIK_BAYT = 410624            # 14 katmanin agirlik panelleri (INT8), uret_agirlik_rom.py NA=1 banka boyutu x 8 bayt
secenekler = [("Basys 3 kartı\n12,5 MHz, 4 hat", 12.5 / 2), ("25 MHz\n4 hat", 25 / 2), ("50 MHz\n4 hat", 50 / 2), ("100 MHz\n4 hat", 100 / 2), ("200 MHz\n8 hat, çift hız", 200 * 1.0)]   # MB/s: SCK/2 (dört hat), son: 8 hat x iki kenar = 2 bayt/çevrim x 200
fig, ax = plt.subplots(figsize=(5.7, 3.2))
sureler = [AGIRLIK_BAYT / (bw * 1e6) * 1e3 for _, bw in secenekler]
ax.bar(range(len(secenekler)), sureler, color=GRI, width=0.6)
for i, s in enumerate(sureler):
    ax.text(i, s * 1.05, tr(s, 1), ha="center", fontsize=9)
ax.axhline(1.0, color=YESIL, lw=1.6); ax.text(1.5, 0.72, "üst model hesap süresi ≈ 1,0 ms (64 belirteç)", ha="center", fontsize=8.5, color=YESIL)
ax.axhline(1.4, color="black", lw=1.2, ls="--"); ax.text(1.5, 1.52, "işlemci ≈ 1,4 ms (64 belirteç)", ha="center", fontsize=8.5)
ax.set_yscale("log"); ax.set_ylim(0.5, 150)
ax.set_xticks(range(len(secenekler))); ax.set_xticklabels([a for a, _ in secenekler], fontsize=8.5)
ax.set_ylabel("Ağırlıkları flaştan akıtma süresi (ms)")
fig.savefig(os.path.join(OUT, "g19_agirlik_akisi.png"), dpi=200, facecolor="white", bbox_inches="tight")
plt.close(fig)
print("g19 yazildi")
