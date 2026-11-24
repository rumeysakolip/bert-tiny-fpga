#!/usr/bin/env python3
"""VCD dosyasından seçilen sinyalleri matplotlib ile dalga formu olarak çizer.

Kullanım:
  python scripts/vcd_ciz.py sim/tb_systolic_4x4.vcd -s tb_systolic_4x4.clk tb_systolic_4x4.start \
         tb_systolic_4x4.busy tb_systolic_4x4.done -t 0 400 -o sekil.png
  python scripts/vcd_ciz.py sim/x.vcd --liste            # sinyal adlarını listele

Sinyal adı: kapsam.ad (ör. tb_systolic_4x4.dut.cnt). Çok bitli sinyaller hex bus olarak,
1 bitlik sinyaller dijital dalga olarak çizilir. Zaman argümanları ve eksen ns cinsindendir.
Raporlarda kullanım için başka betikler `vcd_oku` ve `dalga_ciz` fonksiyonlarını içe aktarır.
"""
import argparse
import re
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# renk körü dostu palet (mavi / turuncu / yeşil / gri)
PALET = ["#0072B2", "#E69F00", "#009E73", "#56B4E9", "#D55E00", "#7F7F7F"]


def vcd_oku(yol):
    """VCD'yi okur. Dönüş: (sinyaller, olaylar, zaman_birimi)
    sinyaller: {tam_ad: (kod, genislik)}  olaylar: {kod: [(zaman, deger_str), ...]}"""
    kapsam, sinyaller, kodlar = [], {}, {}
    olaylar = {}
    birim = "1ns"
    t = 0
    with open(yol, "r", encoding="utf-8", errors="replace") as f:
        belirtge = f.read().split()
    i, n = 0, len(belirtge)
    while i < n:
        s = belirtge[i]
        if s == "$scope":
            kapsam.append(belirtge[i + 2])
            i += 4
        elif s == "$upscope":
            kapsam.pop()
            i += 2
        elif s == "$var":
            genislik, kod, ad = int(belirtge[i + 2]), belirtge[i + 3], belirtge[i + 4]
            tam = ".".join(kapsam + [ad])
            sinyaller[tam] = (kod, genislik)
            olaylar.setdefault(kod, [])
            # $var ... $end ; ad sonrası [msb:lsb] olabilir
            while belirtge[i] != "$end":
                i += 1
            i += 1
        elif s == "$timescale":
            j = i + 1
            parca = []
            while belirtge[j] != "$end":
                parca.append(belirtge[j])
                j += 1
            birim = "".join(parca)
            i = j + 1
        elif s.startswith("$"):
            # $dumpvars, $dumpoff, $dumpon, $end, $date, $version, ...
            if s in ("$dumpvars", "$dumpon", "$dumpoff", "$end", "$enddefinitions", "$comment"):
                i += 1
            else:
                while i < n and belirtge[i] != "$end":
                    i += 1
                i += 1
        elif s[0] == "#":
            t = int(s[1:])
            i += 1
        elif s[0] in "bBrR":
            kod = belirtge[i + 1]
            if kod in olaylar:
                olaylar[kod].append((t, s[1:].lower()))
            i += 2
        elif s[0] in "01xXzZ":
            kod = s[1:]
            if kod in olaylar:
                olaylar[kod].append((t, s[0].lower()))
            i += 1
        else:
            i += 1
    return sinyaller, olaylar, birim


def _ns_carpani(birim):
    """VCD zaman biriminin (ör. '1ps') ns cinsinden değeri."""
    m = re.match(r"(\d+)\s*(fs|ps|ns|us|ms|s)", birim)
    if not m:
        return 1.0
    return int(m.group(1)) * {"fs": 1e-6, "ps": 1e-3, "ns": 1.0, "us": 1e3, "ms": 1e6, "s": 1e9}[m.group(2)]


def _bus_str(deger, genislik):
    if any(c in deger for c in "xz"):
        return deger.upper()
    return "%0*X" % ((genislik + 3) // 4, int(deger, 2))


def dalga_ciz(yol, secili, t0=None, t1=None, cikti=None, baslik=None, ax=None, imza=False):
    """Seçili sinyalleri (tam ad listesi) [t0, t1] aralığında çizer; cikti verilirse PNG kaydeder."""
    sinyaller, olaylar, birim = vcd_oku(yol)
    for ad in secili:
        if ad not in sinyaller:
            raise KeyError("sinyal yok: %s (listelemek için --liste)" % ad)
    ns = _ns_carpani(birim)                      # tik başına ns
    tmax = max((o[-1][0] for o in olaylar.values() if o), default=1)
    t0 = 0 if t0 is None else int(round(t0 / ns))      # t0, t1 ns cinsinden verilir
    t1 = tmax if t1 is None else int(round(t1 / ns))
    sahip = ax is None
    if sahip:
        fig, ax = plt.subplots(figsize=(6.3, 0.55 * len(secili) + 1.0), dpi=200)
    for sira, ad in enumerate(reversed(secili)):
        kod, w = sinyaller[ad]
        ev = olaylar[kod]
        y0 = sira * 1.5
        renk = PALET[sira % len(PALET)]
        # zaman çizelgesi: (t, deger) -> [t0,t1] içinde kes
        ev = sorted(ev)
        parca = []
        onceki = None
        for k, (tz, dz) in enumerate(ev):
            if tz <= t0:
                onceki = (tz, dz)
        baslangic = onceki[1] if onceki else "x"
        parca.append((t0, baslangic))
        for tz, dz in ev:
            if t0 < tz <= t1:
                parca.append((tz, dz))
        parca.append((t1, None))
        if w == 1:
            xs, ys = [], []
            for (ta, da), (tb, _) in zip(parca[:-1], parca[1:]):
                v = {"0": 0, "1": 1}.get(da, 0.5)
                xs += [ta, tb]
                ys += [y0 + v, y0 + v]
            ax.step(xs, ys, where="post", color=renk, lw=1.1)
        else:
            for (ta, da), (tb, _) in zip(parca[:-1], parca[1:]):
                ax.fill_between([ta, tb], y0, y0 + 1, facecolor=renk, alpha=0.18, edgecolor=renk, lw=0.8)
                if tb - ta > (t1 - t0) * 0.03:
                    ax.text((ta + tb) / 2, y0 + 0.5, _bus_str(da, w)[-8:], ha="center", va="center", fontsize=5.5)
    ax.set_yticks([sira * 1.5 + 0.5 for sira in range(len(secili))])
    ax.set_yticklabels([ad.split(".")[-1] for ad in reversed(secili)], fontsize=7)
    ax.set_xlim(t0, t1)
    ticks = ax.get_xticks()
    ax.set_xticks(ticks)
    ax.set_xticklabels(["%g" % round(x * ns, 3) for x in ticks])
    ax.set_xlim(t0, t1)
    ax.set_xlabel("Zaman (ns)", fontsize=8)
    ax.tick_params(axis="x", labelsize=7)
    ax.grid(True, axis="x", color="#cccccc", lw=0.4)
    if baslik:
        ax.set_title(baslik, fontsize=9)
    if sahip:
        plt.tight_layout()
        if cikti:
            plt.savefig(cikti, dpi=200)
            plt.close()
        return cikti


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("vcd")
    ap.add_argument("-s", "--sinyal", nargs="+", help="çizilecek tam sinyal adları")
    ap.add_argument("-t", "--zaman", nargs=2, type=int, metavar=("T0", "T1"))
    ap.add_argument("-o", "--cikti", default="dalga.png")
    ap.add_argument("--baslik")
    ap.add_argument("--liste", action="store_true", help="sinyalleri listele ve çık")
    a = ap.parse_args()
    sinyaller, olaylar, birim = vcd_oku(a.vcd)
    if a.liste or not a.sinyal:
        for ad, (kod, w) in sorted(sinyaller.items()):
            print("%-60s %4d bit  %6d olay" % (ad, w, len(olaylar[kod])))
        return 0
    t0, t1 = a.zaman if a.zaman else (None, None)
    dalga_ciz(a.vcd, a.sinyal, t0, t1, a.cikti, a.baslik)
    print("yazıldı:", a.cikti)
    return 0


if __name__ == "__main__":
    sys.exit(main())
