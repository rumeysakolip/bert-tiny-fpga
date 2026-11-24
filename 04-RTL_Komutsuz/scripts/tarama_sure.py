"""Saf hesap suresi taramasi: yapilandirmalar x cumle uzunluklari -> notlar/sonuclar/sure_tarama.csv
Her koşu tek cumle (ilk cumle) ve agirlik ROM modunda (agirliklar yonga ici bellekte, akis beklemesi yok).
Kullanim (cwd: 04-RTL_Komutsuz):  python scripts/tarama_sure.py "NA=1,2,4,8" [etiket_eki]
Ek komut satiri bayraklari ortam degiskeni TARAMA_BAYRAK ile (ornek: "--ln-par 1 --smp 1"), etiket TARAMA_AD ile verilir.
Yapilandirma anahtarlari: NA (paralel dogrusal hat sayisi) ve --ek ile iletilen ek generic'ler (ornek: LN=1) ortam degiskeni TARAMA_EK ile verilebilir.
"""
import csv
import os
import re
import subprocess
import sys

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
KUMELER = ["kume_0_8_9", "kume_1_16_25", "kume_5_24_40", "kume_8_25_25", "kume_2_32_49", "kume_7_40_40", "kume_6_48_48", "kume_3_56_57", "kume_4_64_64"]
CIKTI = os.path.join(KOK, "notlar", "sonuclar", "sure_tarama.csv")


def main():
    nalar = [int(x) for x in (sys.argv[1] if len(sys.argv) > 1 else "1,2,4,8").split(",")]
    ek = os.environ.get("TARAMA_EK", "").split()
    ek_ad = os.environ.get("TARAMA_AD", "temel")
    os.makedirs(os.path.dirname(CIKTI), exist_ok=True)
    yeni = not os.path.exists(CIKTI)
    with open(CIKTI, "a", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        if yeni:
            w.writerow(["yapilandirma", "NA", "token", "nb", "cevrim"])
        for na in nalar:
            for i, k in enumerate(KUMELER):
                etiket = f"tara_{ek_ad}_na{na}"
                komut = [sys.executable, os.path.join(KOK, "scripts", "kos_xsim.py"), "--na", str(na), "--rom", os.environ.get("TARAMA_ROM", "1"), "--dolgu", "1", "--kume", k, "--mod", "sure", "--etiket", etiket]
                if i > 0:
                    komut.append("--derleme-atla")
                komut += os.environ.get("TARAMA_BAYRAK", "").split()
                if ek:
                    komut += ["--ek"] + ek
                r = subprocess.run(komut, cwd=KOK, capture_output=True, text=True, encoding="utf-8", errors="replace")
                m = re.search(r"SAF HESAP .*?(\d+) cevrim .*?cumle_uzunluk=(\d+)", r.stdout)
                if not m:
                    print("OKUNAMADI", na, k, r.stdout[-600:], flush=True)
                    continue
                cev, tok = int(m.group(1)), int(m.group(2))
                nb = -(-tok // 8)
                w.writerow([ek_ad, na, tok, nb, cev])
                f.flush()
                print(f"{ek_ad} NA={na} token={tok} nb={nb} cevrim={cev} ({cev / 1e5:.3f} ms @100 MHz)", flush=True)


if __name__ == "__main__":
    main()
