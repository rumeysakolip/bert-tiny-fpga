#!/usr/bin/env python3
"""G10 koşturucu: Q·Kᵀ ve P·V (UINT8 olasılık, 9 bit A) tile denetleyici + dizi ile, 2 katman x 2 baş x 2 işlem.
Ön koşul: python scripts/g10_hazirla.py.  Sonuç: sim/g10_sonuc.json, son satır "G10 TOPLAM: PASS (...)"."""
import json, os, re, subprocess, sys, time
from concurrent.futures import ThreadPoolExecutor

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
VEK = os.path.join("..", "02-RTL_Altin_Model", "03_Sonuclar", "test_vektorleri")
SRC = ["rtl/islem_elemani.v", "rtl/sistolik_dizi.v", "rtl/cift_kapili_bellek.v", "rtl/panel_tamponu.v", "rtl/tile_denetleyici.v", "tb/tb_tile.v"]


def kos(ad, aisgz):
    vvp = f"sim/tb_dikkat_{ad}.vvp"
    d = subprocess.run(["iverilog", "-g2001", "-Ptb_tile.K=64", "-Ptb_tile.C=64", "-Ptb_tile.NS=4", "-Ptb_tile.PER_S=1",
                        f"-Ptb_tile.AISGZ={aisgz}", "-o", vvp] + SRC, capture_output=True, text=True)
    if d.returncode:
        return {"ad": ad, "pass": False, "ayrinti": d.stderr[-200:]}
    t = time.time()
    r = subprocess.run(["vvp", vvp, f"+vdir={VEK}", f"+pdir={VEK}", f"+ad={ad}"], capture_output=True, text=True, encoding="utf-8", errors="replace")
    m = re.search(r"TILE DENETLEYICI TEST .*?(PASS|FAIL)\s*\((.*?)\)", r.stdout)
    c = re.search(r"cumle basina (\d+)", r.stdout)
    return {"ad": ad, "a_isaretsiz": aisgz, "pass": bool(m and m.group(1) == "PASS"), "ayrinti": m.group(2) if m else r.stdout[-200:],
            "cevrim": int(c.group(1)) if c else None, "sure_sn": round(time.time() - t, 1)}


def main():
    isler = [(f"l{i}_{op}_h{h}", 1 if op == "av" else 0) for i in range(2) for h in range(2) for op in ("qk", "av")]
    with ThreadPoolExecutor(max_workers=8) as ex:
        s = list(ex.map(lambda a: kos(*a), isler))
    json.dump({"sonuclar": s}, open("sim/g10_sonuc.json", "w"), indent=1)
    hata = sum(not x["pass"] for x in s)
    for x in s:
        print(("  PASS " if x["pass"] else "  FAIL ") + f"{x['ad']:12s} {x['ayrinti']}  cevrim/cumle={x['cevrim']}")
    print(f"G10 TOPLAM: {'PASS' if hata == 0 else 'FAIL'} ({len(s)} koşu, {hata} başarısız)")
    return 0 if hata == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
