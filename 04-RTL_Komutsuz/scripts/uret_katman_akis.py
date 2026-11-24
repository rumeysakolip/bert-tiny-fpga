"""Komutsuz hizlandirici icin tam katman bayt akisi (bias ve olcek carpani akista YOK; bitstream'e gomulu).
Akis (her cumle): [aktivasyon blogu] + her katman icin cizelge sirasiyla agirlik panelleri: Q(16) K(16) V(16) cikis(16) ileri besleme 1 (64) ileri besleme 2 (16).
  aktivasyon blogu : 1 bayt cumle uzunlugu + 1024 sozcuk x 8 bayt (8 bayt/sozcuk, kucuk-uclu) + CRC-16 (yuksek bayt once)
  agirlik paneli   : K sozcuk x 8 bayt + CRC-16     (K = 128; ileri besleme 2 icin 512)
CRC: binascii.crc_hqx(veri, 0xFFFF) = CRC-16/CCITT-FALSE (devredeki hesap ayri yazilmistir -> bagimsiz dogrulama).
Kullanim: python scripts/uret_katman_akis.py <cikis.hex> [--ns N] [--katman L] [--hata BAYT_SIRASI BIT]
"""
import binascii, os, sys

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
VEK = os.environ.get("DOLGU_VEK") or os.path.join(KOK, "02-RTL_Altin_Model", "03_Sonuclar", "test_vektorleri")
SATIRLAR = ["q", "k", "v", "attn_out", "ffn1", "ffn2"]
SON = ["pooler", "classifier"]            # son katmandan sonra: pooler (16 panel), siniflandirici (1 panel)


def oku(yol):
    s = []
    with open(yol, encoding="utf-8") as f:
        for ln in f:
            ln = ln.strip()
            if ln and not ln.startswith("//"):
                s.append(int(ln, 16))
    return s


def crc_ekle(veri):
    c = binascii.crc_hqx(bytes(veri), 0xFFFF)
    return list(veri) + [c >> 8, c & 0xFF]


def uret(ns, katman_sayisi):
    akt = oku(os.path.join(VEK, "l0_q_girdi_blok.mem"))
    maske = oku(os.path.join(VEK, "maske.mem"))
    w = {}
    for L in range(katman_sayisi):
        for a in SATIRLAR:
            w[(L, a)] = oku(os.path.join(VEK, f"l{L}_{a}_w_panel.mem"))
    for a in SON:
        w[(katman_sayisi - 1, a)] = oku(os.path.join(VEK, f"{a}_w_panel.mem"))
    akis = []
    for s in range(ns):
        uzunluk = sum(1 for m in maske[s * 64:(s + 1) * 64] if m)
        veri = [uzunluk]
        for t in range(1024):
            veri += list(akt[s * 1024 + t].to_bytes(8, "little"))
        akis += crc_ekle(veri)
        for L in range(katman_sayisi):
            for a in SATIRLAR + (SON if L == katman_sayisi - 1 else []):
                K = 512 if a == "ffn2" else 128
                kan = len(w[(L, a)]) // K
                for p in range(kan):
                    veri = []
                    for t in range(K):
                        veri += list(w[(L, a)][p * K + t].to_bytes(8, "little"))
                    akis += crc_ekle(veri)
    return akis


if __name__ == "__main__":
    cikis = sys.argv[1]
    ns = int(sys.argv[sys.argv.index("--ns") + 1]) if "--ns" in sys.argv else 1
    nk = int(sys.argv[sys.argv.index("--katman") + 1]) if "--katman" in sys.argv else 1
    a = uret(ns, nk)
    if "--hata" in sys.argv:
        i = sys.argv.index("--hata")
        a[int(sys.argv[i + 1])] ^= 1 << int(sys.argv[i + 2])
    with open(cikis, "w") as f:
        f.write("\n".join(f"{x:02x}" for x in a) + "\n")
    print(f"{cikis}: {len(a)} bayt, cumle={ns}, katman={nk}")
