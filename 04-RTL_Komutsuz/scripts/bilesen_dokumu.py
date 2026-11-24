"""Cizelge satir surelerinden bilesen dokumu (rapor gorseli g17): yapilandirma x cumle uzunlugu.
Her yapilandirma icin 32 ve 64 belirteclik ilk cumle (sure kipi) kosulur; gunlukteki "SATIR katman K satir R basladi cevrim C" satirlarindan
satir sureleri cikarilir ve bilesenlere toplanir:
  dogrusal: Q, K, V ve dikkat cikisi (satir 0-4, 9)   ileri besleme: satir 11, 12   dikkat: satir 5-8 (Q.K^T + Softmax, P.V)
  LayerNorm: satir 10, 13   son: pooler ve siniflandirici + karar   diger: toplam - ustekilerin toplami (ilk satir ve aktarma payi)
Kullanim (cwd: 04-RTL_Komutsuz):  python scripts/bilesen_dokumu.py          -> notlar/sonuclar/bilesen_dokumu.csv, raporlar/gorseller/g17_sure_dokumu.png
"""
import csv
import os
import re
import subprocess
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.dirname(KOK)
OUT = os.path.join(PROJE, "raporlar", "gorseller")
YAPILAR = [  # etiket, rom, na, ln_par, smp, hizli_olcum
    ("Basys 3 (1 dizi)", 0, 1, 0, 0, 1),
    ("2 paralel dizi", 1, 2, 0, 0, 0),
    ("8 paralel dizi", 1, 8, 0, 0, 0),
    ("8 dizi + LayerNorm + Softmax paralel", 1, 8, 1, 1, 0),
]
KUMELER = [("kume_2_32_49", 32), ("kume_4_64_64", 64)]
BILESEN = [("dogrusal", "Q, K, V, çıkış", "#1f77b4"), ("ffn", "İleri besleme", "#e69f00"), ("dikkat", "Dikkat (Q·Kᵀ, Softmax, P·V)", "#009e73"),
           ("ln", "LayerNorm", "#cc79a7"), ("son", "Havuzlama ve sınıflandırıcı", "#7f7f7f"), ("diger", "Diğer", "#dddddd")]


def kos(etiket, rom, na, ln, smp, hz, kume, ilk):
    komut = [sys.executable, os.path.join(KOK, "scripts", "kos_xsim.py"), "--na", str(na), "--rom", str(rom), "--dolgu", "1", "--hizli-olcum", str(hz),
             "--ln-par", str(ln), "--smp", str(smp), "--kume", kume, "--mod", "sure", "--etiket", f"dokum_{na}_{rom}_{ln}_{smp}"]
    if not ilk:
        komut.append("--derleme-atla")
    r = subprocess.run(komut, cwd=KOK, capture_output=True, text=True, encoding="utf-8", errors="replace")
    m = re.search(r"SAF HESAP .*?(\d+) cevrim", r.stdout)
    toplam = int(m.group(1)) if m else None
    g = open(os.path.join(KOK, "sim", f"xs_k_dokum_{na}_{rom}_{ln}_{smp}", "gunluk.txt"), encoding="utf-8", errors="replace").read()
    s = [(int(a), int(b), int(c)) for a, b, c in re.findall(r"SATIR katman (\d+) satir (\d+) basladi cevrim (\d+)", g)]
    return toplam, s


def hesapla(toplam, s):
    sure = {}
    for (k, r, c), (k2, r2, c2) in zip(s, s[1:]):
        sure[(k, r)] = c2 - c
    # ilk satirin (0, 0) suresi: satir 1 ile ayni say (Q basi 0 ve 1 ayni isi yapar)
    sure[(0, 0)] = sure.get((0, 1), 0)
    d = {a: 0 for a, _, _ in BILESEN}
    for (k, r), v in sure.items():
        if r in (0, 1, 2, 3, 4, 9):
            d["dogrusal"] += v
        elif r in (11, 12):
            d["ffn"] += v
        elif r in (5, 6, 7, 8):
            d["dikkat"] += v
        elif r in (10, 13):
            d["ln"] += v
        elif r in (14, 15):
            d["son"] += v
    d["diger"] = max(0, toplam - sum(d.values()))
    return d


sonuc = []
for kume, tok in KUMELER:
    for i, (etiket, rom, na, ln, smp, hz) in enumerate(YAPILAR):
        toplam, s = kos(etiket, rom, na, ln, smp, hz, kume, ilk=(kume == KUMELER[0][0]))
        d = hesapla(toplam, s)
        sonuc.append((etiket, tok, toplam, d))
        print(etiket, tok, toplam, d, flush=True)
os.makedirs(os.path.join(KOK, "notlar", "sonuclar"), exist_ok=True)
with open(os.path.join(KOK, "notlar", "sonuclar", "bilesen_dokumu.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["yapilandirma", "token", "toplam"] + [a for a, _, _ in BILESEN])
    for etiket, tok, toplam, d in sonuc:
        w.writerow([etiket, tok, toplam] + [d[a] for a, _, _ in BILESEN])

# ---- gorsel ----
plt.rcParams.update({"font.family": "Times New Roman", "font.size": 10, "axes.spines.top": False, "axes.spines.right": False})
fig, eksenler = plt.subplots(1, 2, figsize=(5.7, 3.6), sharey=False)
for ax, (kume, tok) in zip(eksenler, KUMELER):
    alt = None
    satirlar = [x for x in sonuc if x[1] == tok]
    xs = list(range(len(satirlar)))
    taban = [0.0] * len(satirlar)
    for ad, aciklama, renk in BILESEN:
        yuk = [x[3][ad] / 1e5 for x in satirlar]
        ax.bar(xs, yuk, bottom=taban, color=renk, width=0.65, label=aciklama if tok == 32 else None, edgecolor="white", lw=0.4)
        taban = [t + y for t, y in zip(taban, yuk)]
    for x, t in zip(xs, taban):
        ax.text(x, t + max(taban) * 0.015, f"{t:.2f}".replace(".", ","), ha="center", fontsize=9)
    ax.set_xticks(xs)
    ax.set_xticklabels(["Basys 3\n1 dizi", "2\ndizi", "8\ndizi", "8 dizi,\ntam\nparalel"], fontsize=8.5)
    ax.set_title(f"{tok} belirteç", fontsize=10.5)
    ax.set_ylabel("Süre (ms, 100 MHz)" if tok == 32 else "")
handles, etiketler = eksenler[0].get_legend_handles_labels()
fig.legend(handles, etiketler, loc="lower center", ncol=3, frameon=False, fontsize=8.5, bbox_to_anchor=(0.5, -0.04))
fig.tight_layout(rect=(0, 0.1, 1, 1))
fig.savefig(os.path.join(OUT, "g17_sure_dokumu.png"), dpi=200, facecolor="white", bbox_inches="tight")
print("g17 yazildi")
