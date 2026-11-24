#!/usr/bin/env python3
"""Konu 4a -- ters_bolucu birim testi (Python tam tamsayi bolme referansi) + mutant denetimi -> sim/bolucu_ters_sonuc.json

Calistirma:  python scripts/kos_bolucu_ters.py [--bolen 125000] [--mutant 1]        (cwd: 03-RTL)
Iki yapilandirma: Softmax (NW=24, DW=22, QB=8: pay < 2^24, bolen 1..2^22-1) ve LayerNorm (NW=31, DW=20, QB=17).
Her bolen icin 8 bolunen (toplam bolen*8 cift; varsayilan 125 000 -> 1 000 000 cift): uniform, k*bolen-1, k*bolen, (k+1)*bolen-1,
doyma siniri (2^QB-1)*bolen..2^QB*bolen, kose degerler. Referans: q = min(n // bolen, 2^QB - 1), kalan_var = (n % bolen != 0), tasma = (n // bolen >= 2^QB).
Doyma durumunda kalan_var = 1 beklenir (modul dokumani).
Mutant: ters_bolucu.v'de kasitli bozulma; testin FAIL vermesi beklenir.
"""
import argparse
import json
import os
import random
import re
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
NPER = 8
YAPILANDIRMA = {"sm": (24, 22, 8), "ln": (31, 20, 17)}
MUTANT = [
    ("t1", "bolum <= taslak_bolum5 + (duzeltme_gerekli ? 1'b1 : 1'b0);", "bolum <= taslak_bolum5;", "tek duzeltme (q0+1) silindi"),
    ("t2", "ters_deger <= seri_bolum;", "ters_deger <= {seri_bolum[TERS_GENISLIGI-1:1], 1'b0};", "ters degerin en dusuk biti silindi (R bir bit kisaldi)"),
    ("t3", "kalan_var <= (kalan_duzeltilmis != 0);", "kalan_var <= (kalan5 != 0);", "kalan bayragi duzeltme oncesi kalandan alindi"),
    ("t4", "else if (duzeltme_gerekli && taslak_bolum5 == BOLUM_EN_BUYUK)", "else if (1'b0)", "duzeltmeden sonra doyma kontrolu silindi (q QB bitte sarar)"),
    ("t5", "wire             duzeltme_gerekli = (kalan5 >= $signed(bolen_genis));", "wire             duzeltme_gerekli = (kalan5 > $signed(bolen_genis));", "duzeltme kosulu >= yerine >"),
    ("t6", "doygun3 <= taslak_tasar;", "doygun3 <= 1'b0;", "taslak bolumde tasma bayragi silindi (doyma yok)"),
]


def vektor_uret(ad, nden, tohum):
    NW, DW, QB = YAPILANDIRMA[ad]
    rng = random.Random(tohum)
    nmax, dmax, qmax = (1 << NW) - 1, (1 << DW) - 1, (1 << QB) - 1
    ozel = [1, 2, 3, 4, 5, 7, 8, 9, 15, 16, 17, 255, 256, 257, 4095, 4096, 4097, 65535, 65536, 65537, dmax, dmax - 1, 1 << (DW - 1), (1 << (DW - 1)) + 1, (1 << (DW - 1)) - 1]
    ozel = [d for d in ozel if 1 <= d <= dmax]
    dens, ns = [], []
    for i in range(nden):
        if i < len(ozel):
            d = ozel[i]
        elif i % 2:
            d = rng.randint(1, dmax)                           # uniform
        else:
            d = rng.randint(1, (1 << rng.randint(1, DW)) - 1)  # bit uzunlugu uniform
        k = rng.randint(0, min(qmax + 3, nmax // d))
        kop = [(rng.choice([0, 1, nmax, d, d - 1, nmax - 1, 1 << (NW - 1), (1 << (NW - 1)) - 1, qmax * d, (qmax + 1) * d]))]
        adaylar = [rng.randint(0, nmax), k * d, k * d - 1, (k + 1) * d - 1, qmax * d + rng.randint(0, d - 1), (qmax + 1) * d - 1,
                   (qmax + 1) * d, kop[0]]
        ns.extend(min(max(a, 0), nmax) for a in adaylar)
        dens.append(d)
    return dens, ns


def ref(dens, ns, QB):
    qmax = (1 << QB) - 1
    q, kal, tas = [], [], []
    for i, n in enumerate(ns):
        d = dens[i // NPER]
        b, r = divmod(n, d)
        if b > qmax:
            q.append(qmax); kal.append(1); tas.append(1)
        else:
            q.append(b); kal.append(1 if r else 0); tas.append(0)
    return q, kal, tas


def yaz(yol, degerler, bas=8):
    with open(yol, "w") as f:
        f.write("\n".join(f"{v:0{bas}x}" for v in degerler) + "\n")


def hazirla(ad, nden, tohum):
    NW, DW, QB = YAPILANDIRMA[ad]
    d = f"sim/ters_vek_{nden}"
    os.makedirs(d, exist_ok=True)
    dens, ns = vektor_uret(ad, nden, tohum)
    q, kal, tas = ref(dens, ns, QB)
    yaz(f"{d}/{ad}_den.mem", dens); yaz(f"{d}/{ad}_n.mem", ns); yaz(f"{d}/{ad}_q.mem", q)
    yaz(f"{d}/{ad}_kal.mem", kal, 2); yaz(f"{d}/{ad}_tas.mem", tas, 2)
    return d, {"cift": len(ns), "doyan_cift": int(sum(tas)), "kalansiz_cift": int(len(ns) - sum(kal) + sum(tas)),
               "bolen_min": min(dens), "bolen_maks": max(dens), "n_maks": max(ns)}


def kos(ad, vdir, nden, rtl="rtl/ters_bolucu.v", etiket="temel"):
    NW, DW, QB = YAPILANDIRMA[ad]
    vvp = f"sim/ters_vek_{nden}/{etiket}_{ad}.vvp"
    r = subprocess.run(["iverilog", "-g2001", f"-Ptb_ters_bolucu.PAY_GENISLIGI={NW}", f"-Ptb_ters_bolucu.BOLEN_GENISLIGI={DW}", f"-Ptb_ters_bolucu.BOLUM_GENISLIGI={QB}",
                        "-Ptb_ters_bolucu.MAXD=%d" % max(nden, 1), "-o", vvp, "rtl/seri_bolucu.v", rtl, "tb/tb_ters_bolucu.v"],
                       capture_output=True, text=True)
    if r.returncode:
        return {"sonuc": "DERLEME", "ayrinti": r.stderr[-300:]}
    o = subprocess.run(["vvp", vvp, f"+vdir={vdir}", f"+ad={ad}", f"+nden={nden}"], capture_output=True, text=True, timeout=3600).stdout
    m = re.search(r"BOLUCU_TERS TEST .*?: (PASS|FAIL)\s+\((\d+) bolen, (\d+) kontrol, (\d+) hata, (\d+) cevrim\)", o)
    if not m:
        return {"sonuc": "BELIRSIZ", "ayrinti": o[-300:]}
    return {"sonuc": m.group(1), "bolen": int(m.group(2)), "kontrol": int(m.group(3)), "hata": int(m.group(4)), "cevrim": int(m.group(5))}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bolen", type=int, default=125000, help="bolen sayisi (x8 cift)")
    ap.add_argument("--mutant-bolen", type=int, default=6000)
    ap.add_argument("--mutant", type=int, default=1)
    a = ap.parse_args()
    t0 = time.time()
    sonuc = {"etiket": "benzetim (Icarus); referans: Python tam tamsayi bolme", "yapilandirma": {k: dict(zip(("NW", "DW", "QB"), v)) for k, v in YAPILANDIRMA.items()},
             "birim": {}, "mutant": []}
    with ThreadPoolExecutor(max_workers=4) as ex:
        hazir = {ad: hazirla(ad, a.bolen, 11 + i) for i, ad in enumerate(YAPILANDIRMA)}
        isler = {ad: ex.submit(kos, ad, hazir[ad][0], a.bolen) for ad in YAPILANDIRMA}
        for ad in YAPILANDIRMA:
            s = isler[ad].result()
            s["vektor"] = hazir[ad][1]
            sonuc["birim"][ad] = s
            print(f"{ad}: {s['sonuc']} {s.get('bolen')} bolen, {s.get('kontrol')} cift, {s.get('hata')} hata | {s['vektor']}")
    if a.mutant:
        mh = {ad: hazirla(ad, a.mutant_bolen, 31 + i) for i, ad in enumerate(YAPILANDIRMA)}
        kaynak = open("rtl/ters_bolucu.v", encoding="utf-8").read()
        for mad, eski, yeni, tanim in MUTANT:
            assert eski in kaynak, mad
            yol = f"sim/ters_vek_{a.mutant_bolen}/{mad}.v"
            open(yol, "w", encoding="utf-8").write(kaynak.replace(eski, yeni))
            with ThreadPoolExecutor(max_workers=4) as ex:
                f = {ad: ex.submit(kos, ad, mh[ad][0], a.mutant_bolen, yol, mad) for ad in YAPILANDIRMA}
                sonlar = {ad: f[ad].result() for ad in YAPILANDIRMA}
            yakalandi = any(s["sonuc"] != "PASS" for s in sonlar.values())
            sonuc["mutant"].append({"ad": mad, "tanim": tanim, "sonuclar": {ad: (s["sonuc"], s.get("hata")) for ad, s in sonlar.items()},
                                    "yakalandi": yakalandi})
            print(f"mutant {mad}: " + ", ".join(f"{ad}={s['sonuc']}({s.get('hata')} hata)" for ad, s in sonlar.items()) + f"  -> {'yakalandi' if yakalandi else 'KACTI'}")
    sonuc["sure_sn"] = round(time.time() - t0)
    ok = all(b["sonuc"] == "PASS" and b["hata"] == 0 for b in sonuc["birim"].values())
    kacan = [m["ad"] for m in sonuc["mutant"] if not m["yakalandi"]]
    sonuc["gecti"] = bool(ok and not kacan)
    json.dump(sonuc, open("sim/bolucu_ters_sonuc.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print("BOLUCU_TERS TOPLAM:", "PASS" if sonuc["gecti"] else "FAIL", "| kacan mutant:", kacan, f"| {sonuc['sure_sn']} sn")
    sys.exit(0 if sonuc["gecti"] else 1)


if __name__ == "__main__":
    main()
