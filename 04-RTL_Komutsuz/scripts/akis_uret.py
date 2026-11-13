"""Komutsuz prototip icin bayt akisi uretir (altin model test vektorlerinden).

Akis (her cumle): [aktivasyon blogu] + her satir (Q, K, V) icin 16 x [agirlik paneli blogu]
  aktivasyon blogu : 1 bayt cumle uzunlugu + 1024 sozcuk x 8 bayt = 8193 bayt + CRC16 (2 bayt)
  agirlik paneli   : K=128 sozcuk x 8 bayt + 8 bias x 4 bayt + 8 M0 x 4 bayt = 1088 bayt + CRC16 (2 bayt)
Bayt sirasi sozcuk icinde kucuk-uclu. CRC: binascii.crc_hqx(veri, 0xFFFF) = CRC-16/CCITT-FALSE, yuksek bayt once.
(CRC burada Python'un kendi uygulamasiyla hesaplanir; devredeki hesap ayri yazilmistir -> bagimsiz dogrulama.)

Kullanim: python akis_uret.py <cikis.hex> [--ns N] [--hata PANEL_SIRASI [BIT]]
  --hata: akis icinde (0 tabanli, cumle 0'in satirlari arasinda duz sayilan) panel sirasindaki bir bayta bit hatasi ekler.
"""
import binascii, os, sys

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
VEK = os.path.join(KOK, "02-RTL_Altin_Model", "03_Sonuclar", "test_vektorleri")
PAR = os.path.join(KOK, "02-RTL_Altin_Model", "03_Sonuclar", "parametreler")
SATIRLAR = ["l0_q", "l0_k", "l0_v"]
K, P, NB = 128, 16, 8


def oku(yol):
    s = []
    with open(yol, encoding="utf-8") as f:
        for ln in f:
            ln = ln.strip()
            if ln and not ln.startswith("//"):
                s.append(int(ln, 16))
    return s


def sozcuk_bayt(v, n):
    return list(v.to_bytes(n, "little"))


def crc_ekle(veri):
    c = binascii.crc_hqx(bytes(veri), 0xFFFF)
    return list(veri) + [c >> 8, c & 0xFF]


def uret(ns, hata_panel=None, hata_bit=0):
    akt = {a: oku(os.path.join(VEK, f"{a}_girdi_blok.mem")) for a in SATIRLAR}
    # Q, K, V girdisi ayni gizli durum olmali
    assert akt["l0_q"] == akt["l0_k"] == akt["l0_v"], "Q/K/V girdileri ayni degil"
    w = {a: oku(os.path.join(VEK, f"{a}_w_panel.mem")) for a in SATIRLAR}
    b = {a: oku(os.path.join(PAR, f"{a}_b.mem")) for a in SATIRLAR}
    m = {a: oku(os.path.join(PAR, f"{a}_m0.mem")) for a in SATIRLAR}
    akis, panel_sirasi = [], 0
    maske = oku(os.path.join(VEK, "maske.mem"))
    for s in range(ns):
        uzunluk = sum(1 for m in maske[s * 64:(s + 1) * 64] if m)          # cumlenin gercek token sayisi
        veri = [uzunluk]                                                      # giris blogunun ilk baytı: cumle uzunlugu (denetim koduna dahil)
        for t in range(NB * K):
            veri += sozcuk_bayt(akt["l0_q"][s * NB * K + t], 8)
        akis += crc_ekle(veri)
        for a in SATIRLAR:
            for p in range(P):
                veri = []
                for t in range(K):
                    veri += sozcuk_bayt(w[a][p * K + t], 8)
                for j in range(8):
                    veri += sozcuk_bayt(b[a][p * 8 + j] & 0xFFFFFFFF, 4)
                for j in range(8):
                    veri += sozcuk_bayt(m[a][p * 8 + j] & 0xFFFFFFFF, 4)
                blok = crc_ekle(veri)
                if hata_panel is not None and panel_sirasi == hata_panel:
                    blok[100] ^= (1 << hata_bit)          # blok icindeki 100. bayta bit hatasi
                akis += blok
                panel_sirasi += 1
    return akis


if __name__ == "__main__":
    cikis = sys.argv[1]
    ns = int(sys.argv[sys.argv.index("--ns") + 1]) if "--ns" in sys.argv else 4
    hp = hb = None
    if "--hata" in sys.argv:
        i = sys.argv.index("--hata")
        hp = int(sys.argv[i + 1])
        hb = int(sys.argv[i + 2]) if i + 2 < len(sys.argv) and not sys.argv[i + 2].startswith("--") else 0
    a = uret(ns, hp, hb or 0)
    with open(cikis, "w") as f:
        f.write("\n".join(f"{x:02x}" for x in a) + "\n")
    print(f"{cikis}: {len(a)} bayt, ns={ns}" + (f", hata: panel {hp} bit {hb}" if hp is not None else ""))
