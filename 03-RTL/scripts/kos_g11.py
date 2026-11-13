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
    ("sm1", "softmax", "(bolen_toplam >> 1)", "22'd0", "bolme oncesi yuvarlama yarimi silindi"),
    ("sm2", "softmax", "? 9'd511 : carpim2[24:16]", "? 9'd510 : carpim2[24:16]", "LUT doyum indisi 511 yerine 510"),
    ("ln1", "layernorm", "((bolum_kalan_var) ? {{(BOLUM_A_GENISLIGI-1){1'b0}}, 1'b1} : {BOLUM_A_GENISLIGI{1'b0}})", "{BOLUM_A_GENISLIGI{1'b0}}", "negatif bolmede taban (floor) duzeltmesi silindi"),
    ("ln2", "layernorm", "({{(OLCEK_TOPLAM_GENISLIGI-1){1'b0}}, 1'b1} <<< (kaydirma_kayit - 6'd1))", "{OLCEK_TOPLAM_GENISLIGI{1'b0}}", "yeniden olceklemede yuvarlama sabiti silindi"),
    ("ln3", "layernorm", "standart_sapma <= (karekok_sonucu == 0) ? 32'd1 : karekok_sonucu[31:0]", "standart_sapma <= karekok_sonucu[31:0] + 32'd0", "std >= 1 kirpmasi kaldirildi"),
    # Konu 4a: yeni bolucu (rtl/ters_bolucu.v) mutantlari; her iki birim testinde kosulur, birinde FAIL yeterlidir
    ("tr1", "bolucu", "bolum <= taslak_bolum5 + (duzeltme_gerekli ? 1'b1 : 1'b0);", "bolum <= taslak_bolum5;", "bolme: tek duzeltme (q0+1) silindi"),
    ("tr2", "bolucu", "ters_deger <= seri_bolum;", "ters_deger <= {seri_bolum[TERS_GENISLIGI-1:1], 1'b0};", "bolme: ters degerin en dusuk biti silindi (ters deger bir bit kisaldi)"),
    ("tr3", "bolucu", "wire             duzeltme_gerekli = (kalan5 >= $signed(bolen_genis));", "wire             duzeltme_gerekli = (kalan5 > $signed(bolen_genis));", "bolme: duzeltme kosulu >= yerine >"),
    ("tr4", "bolucu", "kalan_var <= (kalan_duzeltilmis != 0);", "kalan_var <= (kalan5 != 0);", "bolme: kalan bayragi duzeltme oncesi kalandan alindi"),
]
# Bolucu mutantlari gercek veri vektorlerinde (kok sistem testi) etkisiz kalabilir; esdeger DEGILDIR. Ayni bozulma bolucu birim testinde
# (kos_bolucu_ters.py, sim/bolucu_ters_sonuc.json) yakalaniyorsa kayda "birim testinde yakalandi" yazilir ve kacan sayilmaz.
BIRIM_ESLES = {"tr1": "t1", "tr2": "t2", "tr3": "t5", "tr4": "t3"}
ACIKLAMA = {
    "sm2": "esdeger mutant: exp tablosunun 510. ve 511. girisleri ayni degerde (15 bit yuvarlamadan sonra), doyum indisi cikisi degistirmez",
    "ln3": "esdeger mutant: eps_q >= 1 oldugundan var + eps_q >= 1 ve karekok >= 1; std >= 1 kirpmasi bu parametrelerde hic devreye girmez (savunma amacli)",
}


def derle_kos(ad, rtl, tb, ekstra=(), ters="rtl/ters_bolucu.v"):
    vvp = f"sim/mutant/{ad}.vvp"
    r = subprocess.run(["iverilog", "-g2001", "-o", vvp, tb, rtl, "rtl/seri_bolucu.v", ters], capture_output=True, text=True)
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
        if birim == "bolucu":                       # ortak bolucu: Softmax ve LayerNorm testlerinin ikisinde de kosulur
            kaynak = open("rtl/ters_bolucu.v", encoding="utf-8").read()
            assert eski in kaynak, mad
            yol = f"sim/mutant/{mad}.v"
            open(yol, "w", encoding="utf-8").write(kaynak.replace(eski, yeni))
            ss = {}
            for ub, (mod, tb) in BIRIM.items():
                o, e = derle_kos(f"{mad}_{ub}", f"rtl/{mod}.v", tb, ters=yol)
                ss[ub] = ayristir(o)
            fail = [ub for ub, v in ss.items() if v["sonuc"] == "FAIL"]
            kayit = {"ad": mad, "birim": "softmax+layernorm", "tanim": tanim, "sonuc": "FAIL" if fail else "PASS",
                     "hata": {ub: v["hata"] for ub, v in ss.items()}, "yakalandi": bool(fail), "aciklama": ACIKLAMA.get(mad, "")}
            sonuc["mutant"].append(kayit)
            print(f"mutant {mad}: " + ", ".join(f"{ub}={v['sonuc']}({v['hata']} hata)" for ub, v in ss.items()))
            continue
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
    bt = {}
    if os.path.exists("sim/bolucu_ters_sonuc.json"):
        bt = {m["ad"]: m["yakalandi"] for m in json.load(open("sim/bolucu_ters_sonuc.json", encoding="utf-8")).get("mutant", [])}
    for m in sonuc["mutant"]:
        if not m["yakalandi"] and m["ad"] in BIRIM_ESLES:
            m["birim_testinde_yakalandi"] = bool(bt.get(BIRIM_ESLES[m["ad"]], False))
    json.dump(sonuc, open("sim/g11_sonuc.json", "w"), indent=1)
    ok = all(b["sonuc"] == "PASS" for b in sonuc["birim"].values())
    kacan = [m["ad"] for m in sonuc["mutant"] if not m["yakalandi"] and not m.get("birim_testinde_yakalandi") and m["ad"] not in ACIKLAMA]
    print("G11 TOPLAM:", "PASS" if ok and not kacan else "FAIL", "| aciklanmamis kacan mutant:", kacan)
    sys.exit(0 if ok and not kacan else 1)


if __name__ == "__main__":
    main()
