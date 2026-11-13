"""Pooler (tanh) ve sinifla ndirici icin zincirleme beklenen degerler: son LayerNorm'un yeniden olcekli ilk-token cikisi (vektor_ln/ln4_cikis.mem) girdi alinir.
Altin modelin ara vektor dosyalari baska girdi yolundan uretildigi icin zincir burada tamsayi hesabiyla yeniden kurulur; formul, ara dosyalarin kendi girdileriyle
(pooler_birikec, pooler_cikis, classifier_girdi) birebir dogrulanir.
Cikti: vektor_sinif/pooler_tanh_zincir.mem ([n][128] INT8), classifier_zincir.mem ([n][2] INT8), sinif_zincir.mem ([n] 0/1)."""
import os
import numpy as np
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
V = os.path.join(KOK, "..", "02-RTL_Altin_Model", "03_Sonuclar", "test_vektorleri")
P = os.path.join(KOK, "..", "02-RTL_Altin_Model", "03_Sonuclar", "parametreler")
def oku(p): return [int(l, 16) for l in (x.strip() for x in open(p)) if l and not l.startswith("//")]
def s8(v): return v - 256 if v > 127 else v
def s32(v): return v - (1 << 32) if v >= (1 << 31) else v
def agirlik(ad, kan, K=128):
    wp = oku(os.path.join(V, ad + "_w_panel.mem")); W = np.zeros((kan * 8, K), dtype=np.int64)
    for p in range(kan):
        for k in range(K):
            for j in range(8): W[p * 8 + j, k] = s8((wp[p * K + k] >> (8 * j)) & 0xFF)
    return W
tl = [s8(v) for v in oku(os.path.join(KOK, "rtl", "tanh.mem"))[:256]]
def katman(x, ad, kan, n, tanh, c):
    W = agirlik(ad, kan); b = np.array([s32(v) for v in oku(os.path.join(P, ad + "_b.mem"))]); m0 = np.array([s32(v) for v in oku(os.path.join(P, ad + "_m0.mem"))])
    acc = x @ W[:c].T + b[:c]
    o = np.clip((acc * m0[:c] + (1 << (n - 1))) >> n, -128, 127)
    return np.array([[tl[v + 128] for v in r] for r in o]) if tanh else o
# dogrulama: ara dosyalarin kendi girdileriyle
pg = np.array([s8(v) for v in oku(os.path.join(V, "pooler_girdi.mem"))]).reshape(-1, 128)
cg = np.array([s8(v) for v in oku(os.path.join(V, "classifier_girdi.mem"))]).reshape(-1, 128)
assert (katman(pg, "pooler", 16, 38, True, 128) == cg).all()
cc = np.array([s8(v) for v in oku(os.path.join(V, "classifier_cikis.mem"))]).reshape(-1, 2)
assert (katman(cg, "classifier", 1, 42, False, 2) == cc).all()
# zincir
z4 = np.array([s8(v) for v in oku(os.path.join(KOK, "vektor_ln", "ln4_cikis.mem"))]).reshape(-1, 64, 128)[:, 0, :]
pt = katman(z4, "pooler", 16, 38, True, 128); lg = katman(pt, "classifier", 1, 42, False, 2)
os.makedirs(os.path.join(KOK, "vektor_sinif"), exist_ok=True)
def yaz(ad, a): open(os.path.join(KOK, "vektor_sinif", ad), "w").write("\n".join(f"{int(v) & 0xFF:02x}" for v in a.flatten()) + "\n")
yaz("pooler_tanh_zincir.mem", pt); yaz("classifier_zincir.mem", lg); yaz("sinif_zincir.mem", (lg[:, 1] > lg[:, 0]).astype(int))
print("zincir logit:", lg.tolist(), "sinif:", (lg[:, 1] > lg[:, 0]).astype(int).tolist(), "| ara dosya tahmini:", (cc[:, 1] > cc[:, 0]).astype(int).tolist())
