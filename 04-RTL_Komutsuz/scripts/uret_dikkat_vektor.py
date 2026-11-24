"""Dikkat zinciri (Q.K^T -> yeniden olcekleme -> Softmax) test vektorlerini uretir.
Altin model: skor_q = (birikec*M0 + 2^(n-1)) >> n ; olasilik = softmax_tam(skor_q, s_skor, maske).
Uretilen hesap, altin modelin olasilik dosyasiyla (l<k>_olasilik_u8.mem) BIREBIR karsilastirilir; uyusmazsa durur.
Cikti (04-RTL_Komutsuz/vektor_dikkat): skor_l0.mem, skor_l1.mem  ([n][2][64][64] 32 bit), param.mem (katman basina M0_qk, n_qk, M0_softmax), uzunluk.mem
Kullanim: python scripts/uret_dikkat_vektor.py
"""
import json, os, sys
import numpy as np

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.abspath(os.path.join(KOK, ".."))
sys.path.insert(0, os.path.join(PROJE, "02-RTL_Altin_Model", "01_Kod"))
from altin import nicem, dogrusal_olmayan as dol

SON = os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar")
V = os.path.join(SON, "test_vektorleri")
OUT = os.path.join(KOK, "vektor_dikkat")
os.makedirs(OUT, exist_ok=True)
ol = json.load(open(os.path.join(SON, "ara_olcekler.json"), encoding="utf-8"))["olcekler"]


def oku(p):
    return [int(l.strip(), 16) for l in open(p, encoding="utf-8") if l.strip() and not l.startswith("//")]


def s32(a):
    return np.array([x - (1 << 32) if x >= 1 << 31 else x for x in a], dtype=np.int64)


def s8(a):
    return np.array([x - 256 if x >= 128 else x for x in a], dtype=np.int64)


maske = s8(oku(os.path.join(V, "maske.mem"))).reshape(-1, 64)
n = maske.shape[0]
open(os.path.join(OUT, "uzunluk.mem"), "w").write("\n".join(f"{int(maske[i].sum()):02x}" for i in range(n)) + "\n")
for i in range(n):
    # maske, dolgu sonda ardisik olmali (uzunluk = ilk 'uzunluk' token gercek)
    assert (maske[i][: int(maske[i].sum())] == 1).all() and (maske[i][int(maske[i].sum()):] == 0).all()

param = []
for L in (0, 1):
    s_q, s_k = ol[f"l{L}.q.cikis"], ol[f"l{L}.k.cikis"]
    s_skor = ol[f"l{L}.skor"] * 127.0 / (2 ** 11 - 1)
    M0, nn = nicem.carpani_ayristir(s_q * s_k / np.sqrt(64) / s_skor)
    M0sm = int(round(s_skor * dol.SOFTMAX_LUT_BOYU / dol.SOFTMAX_MENZIL * (1 << 16)))
    acc = s32(oku(os.path.join(V, f"l{L}_qk_birikec.mem"))).reshape(n, 2, 64, 64)
    sq = (acc * M0 + (1 << (nn - 1))) >> nn
    p_bek = np.array(oku(os.path.join(V, f"l{L}_olasilik_u8.mem")), dtype=np.int64).reshape(n, 2, 64, 64)
    mb = maske.astype(bool)[:, None, None, :] * np.ones((n, 2, 64, 64), bool)
    p = dol.softmax_tam(sq, s_skor, mb)
    assert np.array_equal(p, p_bek), f"katman {L}: Softmax altin dosya ile uyusmuyor"
    assert sq.min() >= -(1 << 15) and sq.max() < (1 << 15), "skor 16 bite sigmiyor"
    open(os.path.join(OUT, f"skor_l{L}.mem"), "w").write("\n".join(f"{int(x) & 0xFFFFFFFF:08x}" for x in sq.reshape(-1)) + "\n")
    param += [M0, nn, M0sm]
    print(f"katman {L}: M0_qk={M0} n={nn} M0_softmax={M0sm} skor araligi [{sq.min()},{sq.max()}]  Softmax == altin dosya: True")
open(os.path.join(OUT, "param.mem"), "w").write("\n".join(f"{x:08x}" for x in param) + "\n")
print("cumle sayisi:", n, "| uzunluklar:", [int(maske[i].sum()) for i in range(n)])

# ---- olasilik x deger (P.V) yeniden olceklemesi: baglam_q = tam(av_acc, s_v * (1/255), a_olcek(attn_out)) ----
bm = json.load(open(os.path.join(SON, "parametreler", "bellek_haritasi.json"), encoding="utf-8"))["katmanlar"]
pv_param = []
for L in (0, 1):
    s_v = ol[f"l{L}.v.cikis"]
    a_ao = bm[f"l{L}_attn_out"]["a_olcek"]
    M0, nn = nicem.carpani_ayristir(s_v * (1.0 / 255.0) / a_ao)
    acc = s32(oku(os.path.join(V, f"l{L}_av_birikec.mem"))).reshape(n, 2, 64, 64)        # [n][bas][token][kanal]
    y = np.clip((acc * M0 + (1 << (nn - 1))) >> nn, -128, 127)
    bag = y.transpose(0, 2, 1, 3).reshape(n, 64, 128)                                       # bas kanallari yan yana
    bek = s8(oku(os.path.join(V, f"l{L}_attn_out_girdi.mem"))).reshape(n, 64, 128)
    assert np.array_equal(bag, bek), f"katman {L}: P.V yeniden olcekleme attn_out girdisiyle uyusmuyor"
    pv_param += [M0, nn]
    print(f"katman {L}: P.V M0={M0} n={nn}  baglam == l{L}_attn_out_girdi: True")
open(os.path.join(OUT, "param_pv.mem"), "w").write("\n".join(f"{x:08x}" for x in pv_param) + "\n")
