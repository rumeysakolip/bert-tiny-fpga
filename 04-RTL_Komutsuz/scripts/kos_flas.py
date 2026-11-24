"""Flas kaynakli komutsuz prototip regresyonu (Icarus). Kullanim (kok: 04-RTL_Komutsuz):  python scripts/kos_flas.py
Onkosul: sim/akis_dogru.hex ve sim/akis_hatali.hex (python scripts/kos_komutsuz.py ya da scripts/akis_uret.py ile uretilir).
Kosular: BOL=2 (SCK 25 MHz), BOL=1 (SCK 50 MHz), hatali flas icerigi. Sonuc: sim/flas_sonuc.json
"""
import json, os, subprocess, sys, time

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.abspath(os.path.join(KOK, ".."))
RTL3 = os.path.join(PROJE, "03-RTL", "rtl")
VEK = os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar", "test_vektorleri").replace("\\", "/")
SIM = os.path.join(KOK, "sim")
dogru, hatali = [os.path.join(SIM, f).replace("\\", "/") for f in ("akis_dogru.hex", "akis_hatali.hex")]
for f in (dogru, hatali):
    if not os.path.exists(f):
        subprocess.run([sys.executable, os.path.join(KOK, "scripts", "akis_uret.py"), f, "--ns", "4"] + (["--hata", "20", "3"] if "hatali" in f else []), check=True)

mevcut = [os.path.join(RTL3, f + ".v") for f in
          ("islem_elemani", "sistolik_dizi", "cift_kapili_bellek", "panel_tamponu", "tile_denetleyici",
           "yeniden_olcekle", "gelu_tablosu", "cikis_sozcuk_toplayici", "dogrusal_katman")]
yeni = [os.path.join(KOK, "rtl", f + ".v") for f in ("akis_ayristirici", "cizelge_siralayici", "komutsuz_ust", "qspi_okuyucu", "komutsuz_flas_ust")]
tb = [os.path.join(KOK, "tb", f) for f in ("tb_flas_ust.v", "flas_modeli.v")]

sonuc = {"etiket": "benzetim (Icarus), flas modeli", "tarih": time.strftime("%Y-%m-%d %H:%M"), "kosular": []}
tum = True
for ad, bol, ns, icerik, extra, bekle in (
        ("flas_sck25MHz", 2, 1, dogru, [], "FLAS KAYNAKLI KOMUTSUZ TEST"),
        ("flas_sck50MHz", 1, 1, dogru, [], "FLAS KAYNAKLI KOMUTSUZ TEST"),
        ("flas_hatali_icerik", 2, 4, hatali, ["+hatali=1"], "FLAS CRC HATA ENJEKSIYONU TEST")):
    vvp = os.path.join(SIM, f"tb_{ad}.vvp")
    r = subprocess.run(["iverilog", "-g2005", "-o", vvp, f"-Ptb_flas_ust.BOL={bol}", f"-Ptb_flas_ust.NS={ns}"] + tb + yeni + mevcut, capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stderr); sys.exit(1)
    t0 = time.time()
    r = subprocess.run(["vvp", vvp, f"+flas={icerik}", f"+vdir={VEK}"] + extra, capture_output=True, text=True)
    ok = (bekle in r.stdout) and ("PASS" in [l for l in r.stdout.splitlines() if l.startswith(bekle)][-1])
    tum &= ok
    bilgi = [l for l in r.stdout.splitlines() if l.startswith(("BILGI", "TOPLAM", "HATALI", "FLAS"))]
    print(f"[{'PASS' if ok else 'FAIL'}] {ad} ({time.time()-t0:.0f} s)")
    for l in bilgi: print("   ", l)
    sonuc["kosular"].append({"ad": ad, "gecti": ok, "satirlar": bilgi})
sonuc["genel"] = "PASS" if tum else "FAIL"
json.dump(sonuc, open(os.path.join(SIM, "flas_sonuc.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("FLAS TOPLAM:", sonuc["genel"])
sys.exit(0 if tum else 1)
