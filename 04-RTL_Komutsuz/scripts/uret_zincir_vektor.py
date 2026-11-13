"""Katman zinciri (ileri besleme 1 -> ileri besleme 2) icin beklenen cikis uretir.
Neden: altin modelin tek-katman test vektorlerinde ileri besleme 2'nin girdisi (l0_ffn2_girdi) ile ileri besleme 1'in GELU cikisi
(l0_ffn1_gelu_cikis) FARKLI olceklerdedir (her katman kendi kalibrasyonuyla uretilmistir). Bellek zincirini sinamak icin ileri besleme 2'nin
beklenen cikisi, ileri besleme 1'in GERCEK GELU cikisindan, ayni tamsayi formulle hesaplanir:
    y = clip8( (sum_k x[t][k]*W[c][k] + bias[c]) * M0[c] + 2^(n-1) >> n )
Formul once ileri besleme 2'nin kendi vektoruyle (l0_ffn2_girdi -> l0_ffn2_cikis) dogrulanir; uyusmazsa durur.
Cikti: 04-RTL_Komutsuz/vektor_birlesik/ffn2_zincir_cikis.mem   ([n][64][128] INT8)
"""
import os
import numpy as np

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.abspath(os.path.join(KOK, ".."))
SON = os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar")
V, PAR = os.path.join(SON, "test_vektorleri"), os.path.join(SON, "parametreler")
OUT = os.path.join(KOK, "vektor_birlesik")
os.makedirs(OUT, exist_ok=True)


def oku(p):
    return [int(l.strip(), 16) for l in open(p, encoding="utf-8") if l.strip() and not l.startswith("//")]


def s8(a):
    return np.array([x - 256 if x >= 128 else x for x in a], dtype=np.int64)


def s32(a):
    return np.array([x - (1 << 32) if x >= (1 << 31) else x for x in a], dtype=np.int64)


K, C, NSHIFT = 512, 128, 37
# agirlik paneli: [C/8][K] 64 bit sozcuk, bayt j = W[p*8+j][k]
wp = oku(os.path.join(V, "l0_ffn2_w_panel.mem"))
W = np.zeros((C, K), dtype=np.int64)
for p in range(C // 8):
    for k in range(K):
        sozcuk = wp[p * K + k]
        for j in range(8):
            b = (sozcuk >> (8 * j)) & 0xFF
            W[p * 8 + j, k] = b - 256 if b >= 128 else b
bias = s32(oku(os.path.join(PAR, "l0_ffn2_b.mem")))
m0 = np.array(oku(os.path.join(PAR, "l0_ffn2_m0.mem")), dtype=np.int64)


def katman(x):                                    # x: [n][64][512] INT8
    acc = x @ W.T + bias                          # [n][64][128]
    y = (acc * m0 + (1 << (NSHIFT - 1))) >> NSHIFT
    return np.clip(y, -128, 127)


x_kendi = s8(oku(os.path.join(V, "l0_ffn2_girdi.mem"))).reshape(-1, 64, K)
bek_kendi = s8(oku(os.path.join(V, "l0_ffn2_cikis.mem"))).reshape(-1, 64, C)
assert np.array_equal(katman(x_kendi), bek_kendi), "formul ileri besleme 2'nin kendi vektoruyle uyusmuyor"
print("formul dogrulandi: l0_ffn2_girdi -> l0_ffn2_cikis birebir", x_kendi.shape[0], "cumle")

x_zincir = s8(oku(os.path.join(V, "l0_ffn1_gelu_cikis.mem"))).reshape(-1, 64, K)
y = katman(x_zincir)
open(os.path.join(OUT, "ffn2_zincir_cikis.mem"), "w").write("\n".join(f"{int(v) & 0xFF:02x}" for v in y.reshape(-1)) + "\n")
fark = int((x_zincir != x_kendi).sum())
print(f"zincir beklenen cikis yazildi (ileri besleme 1 GELU cikisi ile ileri besleme 2 vektor girdisi {fark} elemanda farkli)")
