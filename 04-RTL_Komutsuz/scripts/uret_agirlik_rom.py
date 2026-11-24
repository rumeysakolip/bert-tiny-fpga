"""Yonga ici agirlik ROM'u imajlari (buyuk FPGA senaryosu): NA banka, banka i her satirin i, i+NA, i+2NA ... numarali panellerini tutar.
Kaynak: 02-RTL_Altin_Model/03_Sonuclar/test_vektorleri/l<L>_<ad>_w_panel.mem, pooler_w_panel.mem, classifier_w_panel.mem (model sabitleri,
cumleden bagimsiz). Satir sirasi cizelge_ortak.v'nin katman_tablosu sirasidir (kidx 0..13): l0_q, l0_k, l0_v, l0_attn_out, l0_ffn1, l0_ffn2, l1_..., pooler, classifier.
NA'ya bolunmeyen panel sayilari (siniflandirici 1 panel) sifir panelle tamamlanir; cizelge ayni tabani rom_taban() ile hesaplar.
Kullanim (cwd: 04-RTL_Komutsuz):  python scripts/uret_agirlik_rom.py <NA>      -> vektor_rom/na<NA>/agirlik_rom_b<i>.mem ; banka derinligi yazdirilir
"""
import os
import sys

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
VEK = os.path.join(os.path.dirname(KOK), "02-RTL_Altin_Model", "03_Sonuclar", "test_vektorleri")
ADLAR = ["q", "k", "v", "attn_out", "ffn1", "ffn2"]


def oku(yol):
    s = []
    with open(yol, encoding="utf-8") as f:
        for ln in f:
            ln = ln.strip()
            if ln and not ln.startswith("//"):
                s.append(int(ln, 16))
    return s


NA = int(sys.argv[1]) if len(sys.argv) > 1 else 1
assert NA in (1, 2, 4, 8), "NA 1, 2, 4 ya da 8 olmali"
satirlar = []
for L in range(2):
    for a in ADLAR:
        satirlar.append((oku(os.path.join(VEK, f"l{L}_{a}_w_panel.mem")), 512 if a == "ffn2" else 128))
for a in ("pooler", "classifier"):
    satirlar.append((oku(os.path.join(VEK, f"{a}_w_panel.mem")), 128))
assert len(satirlar) == 14
cikti = os.path.join(KOK, "vektor_rom", f"na{NA}")
os.makedirs(cikti, exist_ok=True)
D = None
for i in range(NA):
    kelimeler = []
    for w, K in satirlar:
        np_ = len(w) // K
        assert np_ * K == len(w)
        grup = -(-np_ // NA)
        for j in range(grup):
            p = j * NA + i
            kelimeler += w[p * K:(p + 1) * K] if p < np_ else [0] * K
    if D is None:
        D = len(kelimeler)
    assert len(kelimeler) == D
    with open(os.path.join(cikti, f"agirlik_rom_b{i}.mem"), "w") as f:
        f.write("\n".join(f"{x:016x}" for x in kelimeler) + "\n")
print(f"NA={NA}: {NA} banka, banka derinligi (ROM_D) = {D} sozcuk ({D * 8} bayt/banka); dizin {cikti}")
