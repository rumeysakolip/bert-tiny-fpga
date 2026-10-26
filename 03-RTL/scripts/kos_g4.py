#!/usr/bin/env python3
"""G4 toplu koşturucu: eski regresyon + parametrik PE + N=4/N=8 akışlı dizi (K taraması).

Kök: 03-RTL (bu betik nereden çağrılırsa çağrılsın oraya geçer). Sonuç: sim/g4_sonuc.json
Kullanım:  python scripts/kos_g4.py [--hizli]
Son satır: "G4 TOPLAM: PASS (...)" ya da "FAIL".
"""
import argparse
import json
import os
import re
import subprocess
import sys
import time

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
os.makedirs("sim", exist_ok=True)

CONFIG = [(4, 4), (4, 16), (4, 64), (8, 8), (8, 64), (8, 128), (8, 512)]


def calistir(komut, **kw):
    return subprocess.run(komut, capture_output=True, text=True, encoding="utf-8", errors="replace", **kw)


def derle_kos(ad, kaynaklar, params=(), plusargs=()):
    vvp = f"sim/{ad}.vvp"
    d = calistir(["iverilog", "-g2001", "-Wall", *[f"-P{p}" for p in params], "-o", vvp, *kaynaklar])
    if d.returncode != 0 or "error" in d.stderr.lower():
        return {"ad": ad, "durum": "DERLEME_HATASI", "cikti": d.stderr[-800:]}
    t = time.time()
    r = calistir(["vvp", vvp, *plusargs])
    return {"ad": ad, "sure_sn": round(time.time() - t, 1), "cikti": r.stdout, "uyari": d.stderr.strip()}


def pass_mu(cikti, kalip):
    m = re.search(kalip + r".*?(PASS|FAIL)\s*\((.*?)\)", cikti)
    return (m.group(1) == "PASS", m.group(2)) if m else (False, "satır bulunamadı")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--hizli", action="store_true", help="K=512'yi atla")
    a = ap.parse_args()
    sonuc, toplam_hata = [], 0

    # 1) eski modüller (regresyon tabanı)
    r = derle_kos("tb_pe_eski", ["legacy/rtl/pe_eski.v", "legacy/tb/tb_pe_eski.v"])
    ok, ayr = pass_mu(r["cikti"], "PE TEST:")
    sonuc.append({"ad": "eski PE (8x8)", "pass": ok, "ayrinti": ayr}); toplam_hata += (not ok)
    r = derle_kos("tb_sys_eski", ["legacy/rtl/pe_eski.v", "legacy/rtl/systolic_4x4_eski.v", "legacy/tb/tb_systolic_4x4_eski.v"])
    ok, ayr = pass_mu(r["cikti"], "SYSTOLIC 4x4 TEST:")
    sonuc.append({"ad": "eski systolic_4x4", "pass": ok, "ayrinti": ayr}); toplam_hata += (not ok)

    # 2) yeni PE
    r = derle_kos("tb_pe", ["rtl/pe.v", "tb/tb_pe.v"])
    ok, ayr = pass_mu(r["cikti"], r"PE \(9b x 8b -> 32b\) TEST:")
    sonuc.append({"ad": "pe 9b x 8b", "pass": ok, "ayrinti": ayr, "cikti": r["cikti"].strip().splitlines()[-2:]}); toplam_hata += (not ok)

    # 3) N=4 regresyon (yeni == eski)
    r = derle_kos("tb_regresyon_n4", ["legacy/rtl/pe_eski.v", "legacy/rtl/systolic_4x4_eski.v", "rtl/pe.v",
                                      "rtl/systolic_nxn.v", "tb/tb_regresyon_n4.v"])
    ok, ayr = pass_mu(r["cikti"], "REGRESYON N=4 TEST:")
    sonuc.append({"ad": "N=4 regresyon (yeni==eski)", "pass": ok, "ayrinti": ayr}); toplam_hata += (not ok)

    # 4) NxN dizi, K taraması
    for n, k in CONFIG:
        if a.hizli and k == 512:
            continue
        vd = f"tb/vektor_nxn/n{n}_k{k}"
        if not os.path.exists(os.path.join(vd, "C.mem")):
            calistir([sys.executable, "tb/gen_vektor_nxn.py", "--N", str(n), "--K", str(k)])
        pa = [f"+vdir={vd}"]
        if (n, k) in ((4, 4), (8, 64)):
            pa.append(f"+vcd=sim/tb_systolic_nxn_n{n}_k{k}.vcd")
        r = derle_kos(f"tb_nxn_n{n}_k{k}", ["rtl/pe.v", "rtl/systolic_nxn.v", "tb/tb_systolic_nxn.v"],
                      params=(f"tb_systolic_nxn.N={n}", f"tb_systolic_nxn.KT={k}"), plusargs=pa)
        ok, ayr = pass_mu(r["cikti"], r"SYSTOLIC NxN TEST \(N=\d+,K=\d+\):")
        m = re.search(r"olculen (\d+)\.\.(\d+)", r["cikti"])
        sonuc.append({"ad": f"nxn N={n} K={k}", "N": n, "K": k, "pass": ok, "ayrinti": ayr,
                      "tile_cevrim_min": int(m.group(1)) if m else None,
                      "tile_cevrim_max": int(m.group(2)) if m else None,
                      "beklenen_cevrim": k + 2 * n - 2, "sure_sn": r.get("sure_sn")})
        toplam_hata += (not ok)

    with open("sim/g4_sonuc.json", "w", encoding="utf-8") as f:
        json.dump({"sonuclar": sonuc, "toplam_hata": toplam_hata}, f, ensure_ascii=False, indent=1)
    for s in sonuc:
        print(("  PASS " if s["pass"] else "  FAIL ") + s["ad"] + "  " + str(s.get("ayrinti", "")) +
              (f"  tile={s['tile_cevrim_min']}..{s['tile_cevrim_max']} (K+2N-2={s['beklenen_cevrim']})" if "N" in s else ""))
    print(f"G4 TOPLAM: {'PASS' if toplam_hata == 0 else 'FAIL'} ({len(sonuc)} koşu, {toplam_hata} başarısız)")
    return 0 if toplam_hata == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
