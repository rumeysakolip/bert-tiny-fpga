"""tb_ortak_ust'u Vivado xsim ile derleyip kosturan ortak betik (hat sayisi NA, agirlik ROM, dolgu atlama, olcum / dogruluk kipi).
Kullanim (cwd: 04-RTL_Komutsuz):
  python scripts/kos_xsim.py --na 8 --kume kume_4_64_64 --mod dogruluk          # altin modelle bit-birebir sinama (2 cumle)
  python scripts/kos_xsim.py --na 8 --kume kume_2_32_49 --mod sure             # saf hesap suresi (ilk cumle; agirlik ROM'da gercek hesap, akis beklemesi yok)
  python scripts/kos_xsim.py --na 1 --rom 0 --hizli-olcum 1 --kume kume_0_8_9 --mod sure   # Basys3 akisinda olcum kipi
Cikti: sim/xs_k_<etiket>/ dizininde derleme ve gunluk; son satirlar ekrana yazilir.
"""
import argparse
import os
import re
import subprocess
import sys

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.dirname(KOK)
VIVADO = r"C:\Xilinx\2025.1\Vivado\bin"
RTL3 = os.path.join(PROJE, "03-RTL", "rtl")
RTL4 = os.path.join(KOK, "rtl")
TB = os.path.join(KOK, "tb", "tb_ortak_ust.v")
DOSYA4 = ["ortak_ust", "cizelge_ortak", "akis_ayristirici", "ortak_cekirdek", "ek_hat", "yaz_fifo", "agirlik_rom_banka", "artik_ln_par", "birlesik_bellek_2o", "artik_ln_ortak",
          "yeniden_olcekle_ortak", "layernorm_birim_dz", "panel_kopyalayici", "panel_parametre_yukleyici", "parametre_rom", "gelu_yukleyici",
          "cikis_sozcuk_toplayici_devrik", "softmax_birim_gomulu"]
DOSYA3 = ["ters_bolucu", "seri_bolucu", "cift_kapili_bellek", "cikis_sozcuk_toplayici", "panel_tamponu", "tile_denetleyici", "gelu_tablosu", "sistolik_dizi", "islem_elemani"]


def calistir(komut, cwd, cikti=None):
    # cmd '=' isaretini ayirici sayar (NA=1 -> NA 1): '=' iceren her arguman tirnaga alinir
    s = " ".join(('"%s"' % x) if (("=" in x) or (" " in x) or ("\\" in x)) else x for x in komut)
    r = subprocess.run(s, cwd=cwd, shell=True, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if cikti:
        with open(os.path.join(cwd, cikti), "w", encoding="utf-8") as f:
            f.write(r.stdout + r.stderr)
    return r


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--na", type=int, default=1)
    ap.add_argument("--rom", type=int, default=None, help="agirlik ROM modu (varsayilan: NA>1 ise 1, degilse 0)")
    ap.add_argument("--dolgu", type=int, default=1)
    ap.add_argument("--hizli-olcum", type=int, default=0)
    ap.add_argument("--kume", default=None, help="vektor_dolgu/<kume> (verilmezse 4 test cumlesi: vektor_dolgu/dort_cumle yalniz ROM modunda)")
    ap.add_argument("--mod", choices=["dogruluk", "sure"], default="dogruluk")
    ap.add_argument("--ns", type=int, default=None)
    ap.add_argument("--etiket", default=None)
    ap.add_argument("--ln-par", type=int, default=0)
    ap.add_argument("--smp", type=int, default=0)
    ap.add_argument("--attp", type=int, default=0)
    ap.add_argument("--derleme-atla", action="store_true")
    ap.add_argument("--ek", nargs="*", default=[], help="ek xelab generic (ad=deger)")
    a = ap.parse_args()
    rom = a.rom if a.rom is not None else (1 if a.na > 1 else 0)
    etiket = a.etiket or f"na{a.na}_r{rom}_d{a.dolgu}_h{a.hizli_olcum}_l{a.ln_par}_s{a.smp}_a{a.attp}"
    dizin = os.path.join(KOK, "sim", "xs_k_" + etiket)
    os.makedirs(dizin, exist_ok=True)
    # bellek dosyalari
    for f in os.listdir(RTL4):
        if f.endswith(".mem"):
            with open(os.path.join(RTL4, f), "rb") as s, open(os.path.join(dizin, f), "wb") as d:
                d.write(s.read())
    romd = 8192
    if rom:
        rd = os.path.join(KOK, "vektor_rom", f"na{a.na}")
        for f in os.listdir(rd):
            with open(os.path.join(rd, f), "rb") as s, open(os.path.join(dizin, f), "wb") as d:
                d.write(s.read())
        with open(os.path.join(rd, "agirlik_rom_b0.mem")) as f:
            romd = sum(1 for _ in f)
    if not a.derleme_atla:
        dosyalar = [TB] + [os.path.join(RTL4, x + ".v") for x in DOSYA4] + [os.path.join(RTL3, x + ".v") for x in DOSYA3]
        r = calistir([os.path.join(VIVADO, "xvlog.bat"), "-i", RTL4] + dosyalar, dizin, "cikti_xvlog.txt")
        gen = [f"NA={a.na}", f"AGIRLIK_ROM={rom}", f"ROM_D={romd}", f"DOLGU_ATLA={a.dolgu}", f"HIZLI_OLCUM={a.hizli_olcum}", f"LN_PAR={a.ln_par}", f"SMP={a.smp}", f"ATTP={a.attp}"] + a.ek
        komut = [os.path.join(VIVADO, "xelab.bat"), "tb_ortak_ust", "-s", "snap", "-debug", "typical"]
        for g in gen:
            komut += ["-generic_top", g]
        r = calistir(komut, dizin, "cikti_xelab.txt")
        with open(os.path.join(dizin, "cikti_xelab.txt"), encoding="utf-8") as f:
            x = f.read()
        if "ERROR" in x:
            print("DERLEME HATASI:\n" + "\n".join(l for l in x.splitlines() if "ERROR" in l)[:3000])
            sys.exit(1)
    kume = a.kume
    args = []
    if kume:
        d = os.path.join(KOK, "vektor_dolgu", kume).replace("\\", "/")
        akis = d + ("/akis_akt.hex" if rom else "/akis.hex")
        args += [f"akis={akis}", f"vdir={d}/test_vektorleri", f"ldir={d}/vektor_ln", f"sdir={d}/vektor_sinif"]
    elif rom:
        args += [f"akis={KOK.replace(chr(92), '/')}/vektor_dolgu/dort_cumle/akis_akt.hex"]
    ns = a.ns if a.ns else (1 if a.mod == "sure" else 2 if kume else 4)
    args += [f"ns={ns}"]
    if a.mod == "sure":
        args += ["hizli=1", "aralik=1"]
    komut = [os.path.join(VIVADO, "xsim.bat"), "snap", "-R"]
    for x in args:
        komut += ["-testplusarg", x]
    r = calistir(komut, dizin, "gunluk.txt")
    with open(os.path.join(dizin, "gunluk.txt"), encoding="utf-8", errors="replace") as f:
        g = f.read()
    ozet = [l for l in g.splitlines() if re.search(r"SAF HESAP|UCTAN UCA TEST|HATA|toplam .* cevrim|tasma|FIFO", l)]
    print(f"[{etiket}] {kume or 'dort_cumle'} mod={a.mod}")
    print("\n".join(ozet[-12:]))


if __name__ == "__main__":
    main()
