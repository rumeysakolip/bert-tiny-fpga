#!/usr/bin/env python3
"""G7 koşturucu: dogrusal_katman, her katman için altın <ad>_cikis.mem ile bit-birebir (4 cümle).
Katmanlar paralel koşar. Sonuç: sim/g7_sonuc.json.  Kullanım: python scripts/kos_g7.py [--katman l0_q l0_k ...] [--ns 4]
Son satır: "G7 TOPLAM: PASS (...)".
"""
import argparse
import json
import os
import re
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
SON = os.path.join("..", "02-RTL_Altin_Model", "03_Sonuclar")
VEK, PAR = os.path.join(SON, "test_vektorleri"), os.path.join(SON, "parametreler")

# (ad, K, C): bellek_haritasi.json'dan okunur
SRC = ["rtl/pe.v", "rtl/systolic_nxn.v", "rtl/bram_sdp.v", "rtl/panel_tamponu.v", "rtl/tile_denetleyici.v",
       "rtl/yeniden_olcekle.v", "rtl/gelu_lut.v", "rtl/cikis_paketle.v", "rtl/dogrusal_katman.v", "tb/tb_katman.v"]


def kaydirmalar():
    d = {}
    for s in open(os.path.join(PAR, "parametreler.vh"), encoding="ascii"):
        m = re.match(r"localparam integer KAYDIRMA_(\w+)\s*=\s*(\d+);", s)
        if m:
            d[m.group(1).lower()] = int(m.group(2))
    return d


def katman_listesi():
    h = json.load(open(os.path.join(PAR, "bellek_haritasi.json"), encoding="utf-8"))["katmanlar"]
    return {k: (v["girdi"], v["cikis_kanali"]) for k, v in h.items()}


def kos(ad, K, C, SH, ns):
    os.makedirs("sim", exist_ok=True)
    vvp = f"sim/tb_katman_{ad}.vvp"
    d = subprocess.run(["iverilog", "-g2001", "-Wall", f"-Ptb_katman.K={K}", f"-Ptb_katman.C={C}",
                        f"-Ptb_katman.NS={ns}", f"-Ptb_katman.SH={SH}", "-o", vvp, *SRC],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    if d.returncode != 0:
        return {"ad": ad, "pass": False, "ayrinti": "DERLEME: " + d.stderr[-300:]}
    t = time.time()
    r = subprocess.run(["vvp", vvp, f"+vdir={VEK}", f"+pdir={PAR}", f"+ad={ad}"],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    m = re.search(r"DOGRUSAL KATMAN TEST .*?(PASS|FAIL)\s*\((.*?)\)", r.stdout)
    cy = re.search(r"cumle basina (\d+) ; teorik \(K\+14\)\*P\*NB = (\d+) ; kirpilan eleman \(toplam\) (\d+)", r.stdout)
    return {"ad": ad, "K": K, "C": C, "n": SH, "pass": bool(m and m.group(1) == "PASS"),
            "ayrinti": m.group(2) if m else r.stdout[-300:],
            "cevrim_olculen": int(cy.group(1)) if cy else None, "cevrim_teorik": int(cy.group(2)) if cy else None,
            "kirpilan_eleman": int(cy.group(3)) if cy else None, "sure_sn": round(time.time() - t, 1)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--katman", nargs="*", default=None)
    ap.add_argument("--ns", type=int, default=4)
    ap.add_argument("--cikti", default="sim/g7_sonuc.json")
    a = ap.parse_args()
    kay, kl = kaydirmalar(), katman_listesi()
    secili = a.katman or [k for k in kl if k.startswith("l0_") or k.startswith("l1_")]
    with ThreadPoolExecutor(max_workers=12) as ex:
        sonuc = list(ex.map(lambda k: kos(k, kl[k][0], kl[k][1], kay[k], a.ns), secili))
    json.dump({"ns": a.ns, "sonuclar": sonuc}, open(a.cikti, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    hata = 0
    for s in sonuc:
        print(("  PASS " if s["pass"] else "  FAIL ") + f"{s['ad']:12s} {s.get('ayrinti', '')}  cevrim={s.get('cevrim_olculen')}/{s.get('cevrim_teorik')}  ({s.get('sure_sn')} sn)")
        hata += (not s["pass"])
    print(f"G7 TOPLAM: {'PASS' if hata == 0 else 'FAIL'} ({len(sonuc)} katman, {hata} başarısız)")
    return 0 if hata == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
