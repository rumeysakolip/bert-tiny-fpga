#!/usr/bin/env python3
"""Konu 3, adim 3-4 -- etkin token blogu sayisi (cfg_nb) ile dogrusal katman: bit-birebir kontrol + katman cevrimi olcumu -> sim/nb_olcum.json

Calistirma:  python scripts/kos_konu3_nb.py [--nb 1 2 4 7 8] [--ns 1]        (cwd: 03-RTL)
tb_katman.v, +NBE ile yalniz ilk NBE token blogunu isletir; cikis, altin <ad>_cikis.mem'in ILK NBE*8 token satiriyla BIT-BIREBIR
karsilastirilir. Kalan bloklarin (dolgu satirlari) cikisi karsilastirmaya DAHIL DEGILDIR (hesaplanmadiklari icin; bilerek disarida).
Cevrim = kos darbesinden layer_done'a (kos_g7.py ile ayni tanim; UART/host dahil degil).
Katman sekilleri: q/k/v/attn_out ayni (K=128, C=128); ffn1 (K=128, C=512); ffn2 (K=512, C=128). 12 katmanlik toplam =
8*q + 2*ffn1 + 2*ffn2 (Konu 1 tabanindaki 428 928 de bu toplamdir).
"""
import argparse
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
sys.path.insert(0, os.path.join(KOK, "scripts"))
import kos_g7  # noqa: E402

SEKILLER = {"q": "l0_q", "ffn1": "l0_ffn1", "ffn2": "l0_ffn2"}
ADET = {"q": 8, "ffn1": 2, "ffn2": 2}


def kos(ad, K, C, SH, nb, ns, etiket):
    vvp = f"sim/mutant/nb_{ad}_{nb}.vvp"
    os.makedirs("sim/mutant", exist_ok=True)
    d = subprocess.run(["iverilog", "-g2001", f"-Ptb_katman.K={K}", f"-Ptb_katman.C={C}", f"-Ptb_katman.NS={ns}",
                        f"-Ptb_katman.SH={SH}", f"-Ptb_katman.NBE={nb}", "-o", vvp, *kos_g7.SRC],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    if d.returncode:
        return {"ad": ad, "nb": nb, "pass": False, "ayrinti": "DERLEME: " + d.stderr[-300:]}
    r = subprocess.run(["vvp", vvp, f"+vdir={kos_g7.VEK}", f"+pdir={kos_g7.PAR}", f"+ad={ad}"], capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    m = re.search(r"DOGRUSAL KATMAN TEST .*?(PASS|FAIL)\s*\((.*?)\)", r.stdout)
    cy = re.search(r"cumle basina (\d+) ; teorik \(K\+14\)\*P\*NB = (\d+)", r.stdout)
    return {"sekil": etiket, "ad": ad, "K": K, "C": C, "nb": nb, "ns": ns, "pass": bool(m and m.group(1) == "PASS"),
            "ayrinti": m.group(2) if m else r.stdout[-300:], "cevrim": int(cy.group(1)) if cy else None,
            "teorik_K14_P_NB": int(cy.group(2)) if cy else None}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--nb", type=int, nargs="*", default=[1, 2, 4, 7, 8])
    ap.add_argument("--ns", type=int, default=1)
    a = ap.parse_args()
    kay, kl = kos_g7.kaydirmalar(), kos_g7.katman_listesi()
    isler = [(ad, *kl[ad], kay[ad], nb, a.ns, sekil) for sekil, ad in SEKILLER.items() for nb in a.nb]
    with ThreadPoolExecutor(max_workers=8) as ex:
        sonuc = list(ex.map(lambda x: kos(*x), isler))
    tablo = {}
    for s in sonuc:
        tablo.setdefault(s["nb"], {})[s["sekil"]] = s["cevrim"]
    toplam = {nb: sum(ADET[k] * v[k] for k in ADET) for nb, v in tablo.items() if all(v.get(k) for k in ADET)}
    hata = [s for s in sonuc if not s["pass"]]
    cikti = {"etiket": "benzetim (Icarus)", "yontem": "tb_katman.v +NBE; cevrim = kos->layer_done; yalniz ilk nb*8 token karsilastirildi, dolgu bloklari disarida",
             "sonuclar": sonuc, "katman_cevrimi_nb": {str(k): v for k, v in sorted(tablo.items())},
             "dogrusal_12_katman_toplam_cevrim": {str(k): v for k, v in sorted(toplam.items())},
             "gecti": not hata}
    json.dump(cikti, open("sim/nb_olcum.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    for s in sorted(sonuc, key=lambda s: (s["sekil"], s["nb"])):
        print(("  PASS " if s["pass"] else "  FAIL ") + f"{s['ad']:8s} nb={s['nb']} {s['ayrinti']}  cevrim={s['cevrim']}")
    print("12 katman toplam cevrim (nb -> cevrim):", cikti["dogrusal_12_katman_toplam_cevrim"])
    print(f"KONU3 NB: {'PASS' if not hata else 'FAIL'} ({len(sonuc)} kosu, {len(hata)} basarisiz)")
    return 0 if not hata else 1


if __name__ == "__main__":
    sys.exit(main())
