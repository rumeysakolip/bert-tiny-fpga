"""Uretilen sabit tablolari (LN, parametre haritasi) ilgili .v dosyalarinin icindeki isaretli bolgeye yazar.
Isaretler:  // >>> ln_harita basla  ...  // <<< ln_harita bitti   (bolgenin icini degistirir; dosya baska yere dokunulmaz)"""
import re


def yerlestir(dosyalar, ad, metin):
    bas, bit = f"// >>> {ad} basla", f"// <<< {ad} bitti"
    for d in dosyalar:
        t = open(d, encoding="utf-8").read()
        d1 = t.find(bas)
        d2 = t.find(bit)
        assert d1 >= 0 and d2 > d1, f"{d}: {ad} isaretleri yok"
        t = t[:d1] + bas + "\n" + metin.rstrip("\n") + "\n" + t[d2:]
        open(d, "w", encoding="utf-8").write(t)
