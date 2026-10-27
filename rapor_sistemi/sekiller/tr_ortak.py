"""Rapor şekilleri için ortak yardımcılar (renk körü dostu palet, kutu/ok çizimi, JSON okuma)."""
import json
import os
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

AY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))          # rapor_sistemi
PROJE = os.path.dirname(AY)
RTL = os.path.join(PROJE, "03-RTL")
SONUC = os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar")
sys.path.insert(0, os.path.join(RTL, "scripts"))

MAVI, TURUNCU, YESIL, GRI, ACIK_MAVI, KIRMIZI = "#0072B2", "#E69F00", "#009E73", "#7F7F7F", "#56B4E9", "#D55E00"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 8, "axes.titlesize": 9, "axes.labelsize": 8,
                     "axes.spines.top": False, "axes.spines.right": False})


def json_oku(yol):
    return json.load(open(yol, encoding="utf-8"))


def kutu(ax, x, y, w, h, metin, renk=ACIK_MAVI, fs=7.5, ec="#333333", bold=False):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02,rounding_size=0.08", fc=renk, ec=ec, lw=0.8, alpha=0.9))
    ax.text(x + w / 2, y + h / 2, metin, ha="center", va="center", fontsize=fs, fontweight="bold" if bold else "normal")


def ok(ax, x0, y0, x1, y1, renk="#333333", metin=None, fs=6.5, lw=1.0):
    ax.annotate("", xy=(x1, y1), xytext=(x0, y0), arrowprops=dict(arrowstyle="-|>", color=renk, lw=lw))
    if metin:
        ax.text((x0 + x1) / 2, (y0 + y1) / 2 + 0.07, metin, ha="center", va="bottom", fontsize=fs, color=renk)


def kaydet(fig, ad):
    yol = os.path.join(AY, "sekiller", ad)
    fig.savefig(yol, dpi=200, bbox_inches="tight")
    plt.close(fig)
    print("şekil:", yol)
    return yol
