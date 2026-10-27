"""G11 -- Softmax ve LayerNorm RTL regresyonu + mutant denetimi -> sim/g11_sonuc.json.

Calistirma:  python scripts/kos_g11.py        (cwd: 03-RTL; once g11_vektor_uret.py)
Mutant: RTL'de kasitli bir bozulma yapilir; testin FAIL vermesi beklenir. PASS veren mutant
'esdeger' sayilir ve nedeni elle aciklanir (asagidaki ACIKLAMA).
"""
import json
import os
import re
import subprocess
import sys

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
VD = "tb/vektor_g11"

BIRIM = {"softmax": ("softmax_birim", "tb/tb_softmax.v"), "layernorm": ("layernorm_birim", "tb/tb_layernorm.v")}
MUTANT = [
    ("sm1", "softmax", "(top_k >> 1)", "22'd0", "bolme oncesi yuvarlama yarimi silindi"),
    ("sm2", "softmax", "? 9'd511 : carp[24:16]", "? 9'd510 : carp[24:16]", "LUT doyum indisi 511 yerine 510"),
    ("ln1", "layernorm", "((dv_r != 0) ? 17'd1 : 17'd0)", "17'd0", "negatif bolmede taban (floor) duzeltmesi silindi"),
    ("ln2", "layernorm", "(66'sd1 <<< (n_r - 6'd1))", "66'sd0", "yeniden olceklemede yuvarlama sabiti silindi"),
    ("ln3", "layernorm", "std <= (res == 0) ? 32'd1 : res[31:0]", "std <= res[31:0] + 32'd0", "std >= 1 kirpmasi kaldirildi"),
]
ACIKLAMA = {
    "sm2": "esdeger mutant: exp tablosunun 510. ve 511. girisleri ayni degerde (15 bit yuvarlamadan sonra), doyum indisi cikisi degistirmez",
    "ln3": "esdeger mutant: eps_q >= 1 oldugundan var + eps_q >= 1 ve karekok >= 1; std >= 1 kirpmasi bu parametrelerde hic devreye girmez (savunma amacli)",
}


def derle_kos(ad, rtl, tb, ekstra=()):
    vvp = f"sim/mutant/{ad}.vvp"
    r = subprocess.run(["iverilog", "-g2001", "-o", vvp, tb, rtl, "rtl/bolucu_seri.v"], capture_output=True, text=True)
    if r.returncode:
        return None, r.stderr
    o = subprocess.run(["vvp", vvp, f"+vdir={VD}", *ekstra], capture_output=True, text=True, timeout=1800).stdout
    return o, ""


def ayristir(o):
    m = re.search(r"TEST: (PASS|FAIL)\s+\((\d+) satir, (\d+) kontrol, (\d+) hata\)\s+hesap_cevrimi=(\d+)\.\.(\d+)", o)
    faz = {int(a): int(b) for a, b in re.findall(r"FAZ (\d+) (\d+)", o)}
    return {"sonuc": m.group(1), "satir": int(m.group(2)), "kontrol": int(m.group(3)), "hata": int(m.group(4)),
            "cevrim_min": int(m.group(5)), "cevrim_maks": int(m.group(6)), "faz_cevrimleri": faz}


def main():
    os.makedirs("sim/mutant", exist_ok=True)
    sonuc = {"birim": {}, "mutant": []}
    for ad, (mod, tb) in BIRIM.items():
        o, e = derle_kos(f"g11_{ad}", f"rtl/{mod}.v", tb)
        s = ayristir(o)
        sonuc["birim"][ad] = s
        print(f"{ad}: {s['sonuc']} {s['satir']} satir, {s['kontrol']} kontrol, {s['hata']} hata, {s['cevrim_maks']} cevrim")
    for mad, birim, eski, yeni, tanim in MUTANT:
        mod, tb = BIRIM[birim]
        kaynak = open(f"rtl/{mod}.v", encoding="utf-8").read()
        assert eski in kaynak, mad
        yol = f"sim/mutant/{mad}.v"
        open(yol, "w", encoding="utf-8").write(kaynak.replace(eski, yeni))
        o, e = derle_kos(mad, yol, tb)
        s = ayristir(o)
        kayit = {"ad": mad, "birim": birim, "tanim": tanim, "sonuc": s["sonuc"], "hata": s["hata"],
                 "yakalandi": s["sonuc"] == "FAIL", "aciklama": ACIKLAMA.get(mad, "")}
        sonuc["mutant"].append(kayit)
        print(f"mutant {mad}: {s['sonuc']} ({s['hata']} hata)")
    json.dump(sonuc, open("sim/g11_sonuc.json", "w"), indent=1)
    ok = all(b["sonuc"] == "PASS" for b in sonuc["birim"].values())
    kacan = [m["ad"] for m in sonuc["mutant"] if not m["yakalandi"] and m["ad"] not in ACIKLAMA]
    print("G11 TOPLAM:", "PASS" if ok and not kacan else "FAIL", "| aciklanmamis kacan mutant:", kacan)
    sys.exit(0 if ok and not kacan else 1)


if __name__ == "__main__":
    main()
