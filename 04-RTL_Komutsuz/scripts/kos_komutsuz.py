"""Komutsuz prototip regresyonu (Icarus Verilog). Kullanim (kok: 04-RTL_Komutsuz):  python scripts/kos_komutsuz.py [--hizli]
Adimlar: akis uret (Python CRC) -> derle -> (1) dogru akis, tam hiz  (2) dogru akis, flas hizi (8 cevrim/bayt)  (3) hatali akis.
Sonuclar sim/komutsuz_sonuc.json dosyasina yazilir.
"""
import json, os, subprocess, sys, re, time

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.abspath(os.path.join(KOK, ".."))
RTL3 = os.path.join(PROJE, "03-RTL", "rtl")
VEK = os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar", "test_vektorleri").replace("\\", "/")
SIM = os.path.join(KOK, "sim")
os.makedirs(SIM, exist_ok=True)
hizli = "--hizli" in sys.argv


def calistir(komut, **kw):
    return subprocess.run(komut, capture_output=True, text=True, **kw)


mevcut = [os.path.join(RTL3, f + ".v") for f in
          ("islem_elemani", "sistolik_dizi", "cift_kapili_bellek", "panel_tamponu", "tile_denetleyici",
           "yeniden_olcekle", "gelu_tablosu", "cikis_sozcuk_toplayici", "dogrusal_katman")]
yeni = [os.path.join(KOK, "rtl", f + ".v") for f in ("akis_ayristirici", "cizelge_siralayici", "komutsuz_ust")]
vvp = os.path.join(SIM, "tb_komutsuz.vvp")
r = calistir(["iverilog", "-g2005", "-Wall", "-o", vvp, os.path.join(KOK, "tb", "tb_komutsuz_ust.v")] + yeni + mevcut)
if r.returncode != 0:
    print(r.stdout, r.stderr); sys.exit(1)
uyari = [l for l in r.stderr.splitlines() if "komutsuz" in l.lower() or "akis_ayristirici" in l or "cizelge_siralayici" in l]
if uyari: print("derleme uyarilari (yeni dosyalar):"); print("\n".join(uyari))

ns = 1 if hizli else 4
dogru = os.path.join(SIM, "akis_dogru.hex")
hatali = os.path.join(SIM, "akis_hatali.hex")
calistir([sys.executable, os.path.join(KOK, "scripts", "akis_uret.py"), dogru, "--ns", str(4)])
calistir([sys.executable, os.path.join(KOK, "scripts", "akis_uret.py"), hatali, "--ns", str(4), "--hata", "20", "3"])

sonuc = {"etiket": "benzetim (Icarus)", "tarih": time.strftime("%Y-%m-%d %H:%M"), "kosular": []}
tum = True
for ad, akis, arg, bekle in (
        ("tam_hiz_1bayt_cevrim", dogru, ["+aralik=1", f"+ns={ns}"], "KOMUTSUZ PROTOTIP TEST"),
        ("flas_hizi_8cevrim_bayt", dogru, ["+aralik=8", "+ns=1"], "KOMUTSUZ PROTOTIP TEST"),
        ("hatali_akis_crc", hatali, ["+hatali=1", "+ns=4"], "CRC HATA ENJEKSIYONU TEST")):
    t0 = time.time()
    r = calistir(["vvp", vvp, f"+akis={akis.replace(chr(92), '/')}", f"+vdir={VEK}"] + arg)
    cikti = r.stdout
    ok = (bekle + ": PASS" in cikti) or (bekle + " (ns=" in cikti and "PASS" in cikti.split(bekle)[-1].splitlines()[0])
    tum &= ok
    bilgi = [l for l in cikti.splitlines() if l.startswith(("BILGI", "TOPLAM", "HATALI", "KOMUTSUZ", "CRC"))]
    print(f"[{'PASS' if ok else 'FAIL'}] {ad} ({time.time()-t0:.0f} s)")
    for l in bilgi: print("   ", l)
    sonuc["kosular"].append({"ad": ad, "gecti": ok, "satirlar": bilgi})
sonuc["genel"] = "PASS" if tum else "FAIL"
json.dump(sonuc, open(os.path.join(SIM, "komutsuz_sonuc.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("KOMUTSUZ TOPLAM:", sonuc["genel"])
sys.exit(0 if tum else 1)
