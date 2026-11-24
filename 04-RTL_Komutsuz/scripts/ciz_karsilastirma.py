"""Islemci ve FPGA yapilandirmalarinin cumle uzunluguna gore saf hesap suresi karsilastirmasi (rapor gorselleri g14..g16).
Girdi: notlar/sonuclar/sure_tarama.csv (scripts/tarama_sure.py), notlar/islemci_token_sonuc_kosu*.json (scripts/olc_islemci_token.py).
Cikti: raporlar/gorseller/g14_sure_uzunluk.png, g15_hizlanma.png, g16_hat_olcekleme.png ; kesisim noktalari notlar/sonuclar/kesisim.txt
Kullanim (cwd: 04-RTL_Komutsuz):  python scripts/ciz_karsilastirma.py [saat_MHz_buyuk]
Stil ara rapor sekilleriyle aynidir (Times New Roman, 5,7 inc genislik)."""
import csv
import glob
import json
import os
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.dirname(KOK)
OUT = os.path.join(PROJE, "raporlar", "gorseller")
os.makedirs(OUT, exist_ok=True)
W, FS, FK = 5.7, 11, 10
plt.rcParams.update({"font.family": "Times New Roman", "mathtext.fontset": "stix", "font.size": FS,
                     "axes.spines.top": False, "axes.spines.right": False, "axes.titlesize": FS, "axes.labelsize": FK,
                     "xtick.labelsize": FK, "ytick.labelsize": FK, "legend.fontsize": FK - 1})
MAVI, TURUNCU, YESIL, GRI, MOR, KIRMIZI = "#1f77b4", "#e69f00", "#009e73", "#555555", "#cc79a7", "#d55e00"


def tr(x, n=2):
    return f"{x:,.{n}f}".replace(",", "_").replace(".", ",").replace("_", " ")


# ---------------- veri ----------------
# birinci islemci kosusu (ekran ciktisi; ham dosyasi sonraki kosular ustune yazildi), ortalama ms
ILK_KOSU = {1: {8: 1.053, 16: 1.142, 25: 1.216, 32: 1.330, 56: 1.673, 64: 1.794},
            10: {8: 1.130, 16: 1.158, 25: 1.182, 32: 1.215, 56: 1.365, 64: 1.398}}
cpu_en_iyi, cpu_en_kotu = {}, {}
for dosya in sorted(glob.glob(os.path.join(KOK, "notlar", "islemci_token_sonuc_kosu*.json"))):
    d = json.load(open(dosya, encoding="utf-8"))
    for r in d["sonuclar"]:
        for n, v in r["olcumler"].items():
            cpu_en_iyi.setdefault(int(n), []).append(v["ortalama_ms"])
for it in ILK_KOSU.values():
    for n, v in it.items():
        cpu_en_iyi.setdefault(n, []).append(v)
cpu = {n: min(v) for n, v in cpu_en_iyi.items()}
cpu_kotu = {n: max(v) for n, v in cpu_en_iyi.items()}

satirlar = {}
yol = os.path.join(KOK, "notlar", "sonuclar", "sure_tarama.csv")
for r in csv.DictReader(open(yol, encoding="utf-8")):
    satirlar[(r["yapilandirma"], int(r["NA"]), int(r["token"]))] = int(r["cevrim"])


def egri(ad, na, mhz=100.0):
    xs = sorted(t for (a, n, t) in satirlar if a == ad and n == na and t % 8 == 0)       # 25 belirteç 32 ile aynı blok sayısı: eğriden çıkarıldı
    return xs, [satirlar[(ad, na, t)] / (mhz * 1e3) for t in xs]


YAPILANDIRMALAR = [
    ("basys3", 1, "Basys 3: 1 dizi (ağırlık akışı beklemesi hariç)", GRI, "-", "o"),
    ("temel", 2, "2 paralel dizi", TURUNCU, "-", "s"),
    ("temel", 8, "8 paralel dizi (yalnız doğrusal katmanlar)", MOR, "-", "^"),
    ("tam", 8, "8 paralel dizi + paralel LayerNorm ve Softmax", MAVI, "-", "D"),
    ("tamatt", 8, "8 paralel dizi + LayerNorm, Softmax ve dikkat paralel (üst model)", YESIL, "-", "*"),
]


def kesisim(xs, ys, cpu_f):
    """ilk x: FPGA suresi islemciden kucuk oldugu en buyuk uzunluk (linear arakesit); [None, hep]"""
    fark = [y - cpu_f(x) for x, y in zip(xs, ys)]
    if all(f > 0 for f in fark):
        return "hiçbirinde"
    if all(f <= 0 for f in fark):
        return "hepsinde (8–64)"
    for i in range(len(xs) - 1):
        if fark[i] <= 0 < fark[i + 1]:
            x0, x1 = xs[i], xs[i + 1]
            return f"{x0 + (x1 - x0) * (-fark[i]) / (fark[i + 1] - fark[i]):.0f} belirteçe kadar"
    return "belirsiz"


def cpu_f(x):
    ks = sorted(cpu)
    if x <= ks[0]:
        return cpu[ks[0]]
    for a, b in zip(ks, ks[1:]):
        if a <= x <= b:
            return cpu[a] + (cpu[b] - cpu[a]) * (x - a) / (b - a)
    return cpu[ks[-1]]


def kaydet(fig, ad):
    fig.savefig(os.path.join(OUT, ad), dpi=200, facecolor="white", bbox_inches="tight")
    plt.close(fig)


# ---------------- g14: sure - uzunluk ----------------
fig, ax = plt.subplots(figsize=(W, 3.5))
ks = sorted(cpu)
ax.fill_between(ks, [cpu[k] for k in ks], [min(cpu_kotu[k], 2.2) for k in ks], color="#dddddd", alpha=0.6, lw=0, label="İşlemci, olası dalgalanma aralığı")
ax.plot(ks, [cpu[k] for k in ks], color="black", lw=2.0, marker="x", label="İşlemci (en iyi ölçüm, tek cümle)")
kesisim_metin = []
for ad, na, etiket, renk, cizgi, isaret in YAPILANDIRMALAR:
    xs, ys = egri(ad, na)
    if not xs:
        continue
    ax.plot(xs, ys, color=renk, ls=cizgi, marker=isaret, ms=4, lw=1.4, label=etiket)
    kesisim_metin.append(f"{etiket}: FPGA işlemciden hızlı olduğu uzunluklar: {kesisim(xs, ys, cpu_f)}")
ax.set_yscale("log")
ax.set_xlabel("Cümle uzunluğu (belirteç sayısı)")
ax.set_ylabel("Çıkarım süresi (ms, 100 MHz)")
ax.set_xticks([8, 16, 24, 32, 40, 48, 56, 64])
ax.set_yticks([0.2, 0.5, 1, 2, 5, 10])
ax.get_yaxis().set_major_formatter(matplotlib.ticker.FuncFormatter(lambda v, p: tr(v, 1 if v < 1 else 0)))
ax.grid(True, which="both", color="#dddddd", lw=0.6)
ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.2), ncol=2, frameon=False)
kaydet(fig, "g14_sure_uzunluk.png")

# ---------------- g15: hizlanma ----------------
fig, ax = plt.subplots(figsize=(W, 3.0))
ax.axhline(1.0, color="black", lw=1.4)
ax.text(8.3, 1.04, "eşitlik", ha="left", va="bottom", fontsize=FK - 1)
for ad, na, etiket, renk, cizgi, isaret in YAPILANDIRMALAR:
    xs, ys = egri(ad, na)
    if not xs:
        continue
    ax.plot(xs, [cpu_f(x) / y for x, y in zip(xs, ys)], color=renk, ls=cizgi, marker=isaret, ms=4, lw=1.4, label=etiket)
ax.set_xlabel("Cümle uzunluğu (belirteç sayısı)")
ax.set_ylabel("İşlemci süresi ÷ FPGA süresi")
ax.set_xticks([8, 16, 24, 32, 40, 48, 56, 64])
ax.set_yscale("log")
ax.set_yticks([0.2, 0.5, 1, 2, 5])
ax.get_yaxis().set_major_formatter(matplotlib.ticker.FuncFormatter(lambda v, p: tr(v, 1 if v < 1 else 0)))
ax.grid(True, which="both", color="#dddddd", lw=0.6)
ax.legend(loc="upper center", frameon=False, bbox_to_anchor=(0.5, -0.2), ncol=2)
kaydet(fig, "g15_hizlanma.png")

# ---------------- g16: hat sayisina gore olcekleme ----------------
fig, ax = plt.subplots(figsize=(W, 3.0))
for tok, renk in ((32, MAVI), (64, KIRMIZI)):
    nas, ys = [], []
    for na in (1, 2, 4, 8):
        k = ("temel", na, tok)
        if k in satirlar:
            nas.append(na); ys.append(satirlar[k] / 1e5)
    if nas:
        ax.plot(nas, ys, color=renk, marker="o", lw=1.4, label=f"{tok} belirteç, yalnız doğrusal katmanlar paralel")
        ax.plot(nas, [ys[0] / n for n in nas], color=renk, ls=":", lw=1.0)
    nas, ys = [], []
    for na in (2, 4, 8):
        k = ("tam", na, tok)
        if k in satirlar:
            nas.append(na); ys.append(satirlar[k] / 1e5)
    if nas:
        ax.plot(nas, ys, color=renk, marker="D", ls="--", lw=1.4, label=f"{tok} belirteç, LayerNorm ve Softmax da paralel")
ax.set_xscale("log", base=2)
ax.set_xticks([1, 2, 4, 8]); ax.get_xaxis().set_major_formatter(matplotlib.ticker.FuncFormatter(lambda v, p: f"{int(v)}"))
ax.set_yscale("log")
ax.set_yticks([0.5, 1, 2, 5]); ax.get_yaxis().set_major_formatter(matplotlib.ticker.FuncFormatter(lambda v, p: tr(v, 1 if v < 1 else 0)))
ax.set_xlabel("Paralel doğrusal dizi sayısı")
ax.set_ylabel("Çıkarım süresi (ms, 100 MHz)")
ax.grid(True, which="both", color="#dddddd", lw=0.6)
ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.22), ncol=1, frameon=False, fontsize=FK - 2)
kaydet(fig, "g16_hat_olcekleme.png")

with open(os.path.join(KOK, "notlar", "sonuclar", "kesisim.txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(kesisim_metin) + "\n")
print("\n".join(kesisim_metin))
print("g14, g15, g16 yazildi:", OUT)
