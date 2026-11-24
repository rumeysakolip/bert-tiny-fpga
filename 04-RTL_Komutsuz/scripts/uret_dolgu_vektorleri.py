"""Dolgu atlama (nb) sinamasi icin uzun cumle vektorleri: her kume 2 cumle, ayri dizinde (mevcut vektorlere dokunulmaz).

Kumeler (hedef token sayisi): (8, 9) nb=1 ve 2 siniri | (16, 25) nb=2 ve 4 | (32, 49) nb=4 ve 7 | (56, 57) nb=7 ve 8 siniri | (64, 64) nb=8 | (24, 40) nb=3 ve 5 | (48, 48) nb=6.
SST-2 gelistirme kumesindeki en uzun cumle 55 token oldugu icin hedefe ulasmayan cumlelerin dikkat maskesi 04_test_vektoru_uret.py --uzat ile
hedef uzunluga uzatilir (uzatilan konumlar [PAD] kimligiyle gercek token gibi islenir; altin model ve devre ayni girdiyi gorur).
Adimlar (her kume): 1) altin model test vektorleri 2) dikkat ara dosyalari (03-RTL/scripts/g10_hazirla.py) 3) LayerNorm vektorleri 4) sinif zinciri 5) bayt akisi.
Kullanim (cwd: 04-RTL_Komutsuz):  python scripts/uret_dolgu_vektorleri.py [kume numaralari]   -> vektor_dolgu/kume_<i>_<n1>_<n2>/ (numara verilmezse hepsi)
"""
import json
import os
import shutil
import subprocess
import sys

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.dirname(KOK)
KOD = os.path.join(PROJE, "02-RTL_Altin_Model", "01_Kod")
ARA = os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar", "ara_olcekler.json")
KUMELER = [(8, 9), (16, 25), (32, 49), (56, 57), (64, 64), (24, 40), (48, 48), (40, 40), (25, 25)]      # 5-6: nb = 3, 5, 6 icin; 7: nb=5 ilk cumle olarak (sure); 8: n=25 (nb=4) ayni nb'de ayni sure kontrolu

sys.path.insert(0, KOD)
import argparse  # noqa: E402
import ortak  # noqa: E402
a = ortak.ortak_argumanlar(argparse.ArgumentParser()).parse_args([])
_, _, _, _, _, maske, _ = ortak.yukle_hepsi(a)
uz = maske.sum(1)


def sec(hedef, kullanilan):
    """uzunlugu hedefe en yakin (hedefi asmayan) cumle; ayni cumle iki kez secilmez."""
    aday = [i for i in range(len(uz)) if uz[i] <= hedef and i not in kullanilan]
    return max(aday, key=lambda i: (uz[i], -i))


def kos(args, env_ek=None, cwd=KOK):
    env = dict(os.environ, PYTHONIOENCODING="utf-8", **(env_ek or {}))
    r = subprocess.run([sys.executable] + args, cwd=cwd, env=env, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.returncode != 0:
        print(r.stdout[-1500:], r.stderr[-2500:])
        raise SystemExit("adim basarisiz: " + " ".join(args))
    return r.stdout


SECILI = [int(x) for x in sys.argv[1:]] or list(range(len(KUMELER)))
for k, hedefler in enumerate(KUMELER):
    if k not in SECILI:
        continue
    kul, idx = set(), []
    for h in hedefler:
        i = sec(h, kul); kul.add(i); idx.append(int(i))
    uzat = [int(h) for h in hedefler]
    d = os.path.join(KOK, "vektor_dolgu", f"kume_{k}_{hedefler[0]}_{hedefler[1]}")
    os.makedirs(d, exist_ok=True)
    shutil.copyfile(ARA, os.path.join(d, "ara_olcekler.json"))
    print(f"[kume {k}] hedef token {hedefler}, secilen cumle {idx} (gercek token {[int(uz[i]) for i in idx]}) -> {d}", flush=True)
    kos([os.path.join(KOD, "04_test_vektoru_uret.py"), "--cikis", d, "--ara_olcek", ARA, "--idx"] + [str(i) for i in idx] + ["--uzat"] + [str(u) for u in uzat])
    env = {"DOLGU_CIKIS": d, "DOLGU_LN": os.path.join(d, "vektor_ln"), "DOLGU_RTL_YAZMA": "0",
           "DOLGU_VEK": os.path.join(d, "test_vektorleri"), "DOLGU_SINIF": os.path.join(d, "vektor_sinif")}
    print("   ", kos([os.path.join(PROJE, "03-RTL", "scripts", "g10_hazirla.py")], env).strip(), flush=True)      # l*_av_h*_w_panel.mem (V devrik referansi) ve Q.K^T / P.V ara dosyalari
    kos([os.path.join(KOK, "scripts", "uret_ln_vektor.py")], env)
    kos([os.path.join(KOK, "scripts", "uret_sinif_vektor.py")], env)
    kos([os.path.join(KOK, "scripts", "uret_katman_akis.py"), os.path.join(d, "akis.hex"), "--ns", "2", "--katman", "2"], env)
    ky = json.load(open(os.path.join(d, "test_vektorleri", "kunye.json"), encoding="utf-8"))
    print(f"   token sayilari: {ky['gercek_token_sayisi']}  logit: {ky['logit']}", flush=True)
print("tamam")
