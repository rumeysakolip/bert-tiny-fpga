"""Bayt akisi hex dosyasini (satir basina bir bayt) ikili dosyaya cevirir: flasa yazilacak cumle akisi.
Kullanim: python scripts/uret_flas_bin.py   -> vektor_akis/akis_katman2.bin  (4 cumle x 419 429 bayt = 1 677 716 bayt)"""
import os
KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
g = os.path.join(KOK, "vektor_akis", "akis_katman2.hex")
c = os.path.join(KOK, "vektor_akis", "akis_katman2.bin")
b = bytearray()
for s in open(g, encoding="ascii"):
    s = s.strip()
    if s:
        b.append(int(s, 16))
open(c, "wb").write(b)
print("yazildi:", c, len(b), "bayt")
assert len(b) == 4 * 419429
