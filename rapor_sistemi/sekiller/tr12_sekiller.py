"""TR12 şekilleri: Vivado post-sentez kullanımı (03-RTL/sentez/cikti)."""
import re

import numpy as np

from tr_ortak import *   # noqa

CIKTI = os.path.join(RTL, "sentez", "cikti")


def oku():
    k = open(os.path.join(CIKTI, "hizlandirici_uart_ust_kullanim.txt"), encoding="utf-8").read()
    g = lambda kalip: float(re.search(kalip, k).group(1))
    top = {"LUT": g(r"\|\s*Slice LUTs\*\s*\|\s*(\d+)"), "FF": g(r"\|\s*Slice Registers\s*\|\s*(\d+)"),
           "BRAM36": g(r"\|\s*Block RAM Tile\s*\|\s*([\d.]+)"), "DSP": g(r"\|\s*DSPs\s*\|\s*(\d+)")}
    z = open(os.path.join(CIKTI, "hizlandirici_uart_ust_zamanlama.txt"), encoding="utf-8").read()
    top["WNS"] = float(re.search(r"WNS\(ns\).*?\n.*?\n\s*(-?[\d.]+)", z, re.S).group(1))
    top["yol_gecikme"] = float(re.search(r"Data Path Delay:\s*([\d.]+)ns", z).group(1))
    h = open(os.path.join(CIKTI, "hizlandirici_uart_ust_kullanim_hiyerarsik.txt"), encoding="utf-8").read()
    mod = {}
    for ad in ("u_cd", "u_tile", "u_dizi", "u_rq", "u_lut", "u_pk", "u_girdi", "u_cikis", "u_panel", "u_rx", "u_tx"):
        m = re.search(r"\|\s*" + ad + r"\s*\|\s*\w+\s*\|\s*(\d+)\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)", h)
        if m:
            mod[ad] = {"LUT": int(m.group(1)), "FF": int(m.group(2)), "RAMB36": int(m.group(3)), "RAMB18": int(m.group(4)), "DSP": int(m.group(5))}
    return top, mod


def tr12():
    top, mod = oku()
    mevcut = {"LUT": 20800, "FF": 41600, "BRAM36": 50, "DSP": 90}
    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    ad = list(mevcut)
    yuzde = [100 * top[a] / mevcut[a] for a in ad]
    ax.bar(ad, yuzde, color=[TURUNCU, ACIK_MAVI, YESIL, MAVI])
    for i, a in enumerate(ad):
        ax.text(i, yuzde[i] + 1.5, f"{top[a]:g} / {mevcut[a]}\n%{yuzde[i]:.1f}", ha="center", fontsize=7)
    ax.axhline(100, color=KIRMIZI, ls="--", lw=1); ax.set_ylim(0, 120); ax.set_ylabel("Kullanım (%)")
    ax.set_title("XC7A35T post-sentez kaynak kullanımı (yerleştirme yok)")
    kaydet(fig, "tr12_s1_kaynak.png")

    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    etk = ["DSP", "BRAM36"]
    tahmin = [72, 29]      # plan 6.3 tahmini (DSP ≈72, BRAM36 27–30)
    olc = [top["DSP"], top["BRAM36"]]
    x = np.arange(2)
    ax.bar(x - 0.2, tahmin, 0.4, label="plan tahmini (6.3)", color=GRI); ax.bar(x + 0.2, olc, 0.4, label="Vivado sentez", color=TURUNCU)
    for i in range(2):
        ax.text(i - 0.2, tahmin[i] + 1, str(tahmin[i]), ha="center", fontsize=7); ax.text(i + 0.2, olc[i] + 1, f"{olc[i]:g}", ha="center", fontsize=7)
    ax.set_xticks(x); ax.set_xticklabels(etk); ax.legend(fontsize=7)
    ax.set_title("Tahmin ve ölçüm: use_dsp ipucuyla 64 PE çarpıcısı DSP48E1'e eşlendi")
    kaydet(fig, "tr12_s2_tahmin.png")

    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    adlar = [("systolic dizi (64 PE)", mod["u_dizi"]["LUT"]), ("tile_denetleyici (gölge vb.)", mod["u_tile"]["LUT"] - mod["u_dizi"]["LUT"]),
             ("komut_cozucu", mod["u_cd"]["LUT"]), ("uart_rx", mod["u_rx"]["LUT"])]
    kalan = top["LUT"] - sum(v for _, v in adlar)
    adlar.append(("diğer (requant, LUT, paketle, bellek)", kalan))
    ax.barh([a for a, _ in adlar][::-1], [v for _, v in adlar][::-1], color=MAVI)
    for i, (_, v) in enumerate(adlar[::-1]):
        ax.text(v + 80, i, str(int(v)), va="center", fontsize=7)
    ax.set_xlabel("LUT"); ax.set_title("LUT dağılımı (hiyerarşik rapor)")
    kaydet(fig, "tr12_s3_dagilim.png")

    fig, ax = plt.subplots(figsize=(6.0, 2.4))
    ax.bar(["hedef 10,0 ns\n(100 MHz)", "kritik yol\n(sentez sonrası)"], [10.0, top["yol_gecikme"]], color=[YESIL, YESIL if top['WNS'] >= 0 else KIRMIZI])
    ax.text(1, top["yol_gecikme"] + 0.2, f"{top['yol_gecikme']:.2f} ns, WNS {top['WNS']} ns", ha="center", fontsize=7)
    ax.set_ylabel("ns"); ax.set_ylim(0, 12.5)
    ax.set_title("Zamanlama: 100 MHz kısıtı sentez sonrası sağlanıyor (kaba tahmin, yönlendirme yok)")
    kaydet(fig, "tr12_s4_zamanlama.png")
    json.dump({"top": top, "modul": mod}, open(os.path.join(RTL, "sim", "g12_ozet.json"), "w"), indent=1)


if __name__ == "__main__":
    tr12()
