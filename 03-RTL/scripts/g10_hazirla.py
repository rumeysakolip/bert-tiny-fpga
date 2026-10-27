#!/usr/bin/env python3
"""G10: dikkat çekirdeği (Q·Kᵀ ve P·V) için tile-denetleyici düzeninde vektörler üretir ve bağımsız denetler.

Altın vektörler (04_test_vektoru_uret.py): l<i>_qk_{q,k,birikec}, l<i>_av_{p,v,birikec}  ([n][2][T][..]).
Burada her (katman i, baş h, işlem) için tb_tile'ın okuyacağı dosyalar yazılır (hepsi test_vektorleri/ altına):
  l<i>_qk_h<h>_girdi_blok.mem  A = Q_h, blok düzeni (sözcük b*64+d, bayt t = Q[b*8+t][d])         K=64
  l<i>_qk_h<h>_w_panel.mem     B = K_h (C=64 anahtar), panel düzeni; cümle başına (PER_S=1)
  l<i>_qk_h<h>_b.mem           sıfır bias (64)
  l<i>_qk_h<h>_birikec.mem     beklenen Q·Kᵀ [n][64][64] INT32
  l<i>_av_h<h>_*               A = P (UINT8, a_isaretsiz=1, K=64 anahtar), B = Vᵀ (C=64 boyut); beklenen P·V [n][64][64]
Notlar: P·V'de B işleneni V'nin TRANSPOZUdur (panel sözcüğü = bir anahtar token'ın 8 boyutu); FPGA çıkış BRAM'i token'ları
sözcüğe koyduğu için V, host tarafında yeniden düzenlenip panel olarak akıtılır (bkz. TR09).
Çıktı: sim/g10_hazir.json; son satır "G10 HAZIRLIK: PASS" (üretilen vektörlerin numpy altınıyla denetimi dahil).
"""
import json
import os
import sys

import numpy as np

KOK = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
VEK = os.path.join(KOK, "02-RTL_Altin_Model", "03_Sonuclar", "test_vektorleri")


def mem(ad, bit, imzali=True):
    v = [int(s.strip(), 16) for s in open(os.path.join(VEK, ad), encoding="ascii") if s.strip() and not s.startswith("//")]
    a = np.array(v, dtype=np.int64)
    return np.where(a >= (1 << (bit - 1)), a - (1 << bit), a) if imzali else a


def yaz(ad, dizi, bit, ac):
    with open(os.path.join(VEK, ad), "w", encoding="ascii", errors="replace") as f:
        f.write(f"// {ac}\n")
        for v in np.asarray(dizi).ravel():
            f.write(f"{int(v) & ((1 << bit) - 1):0{(bit + 3) // 4}x}\n")


def paketle(satirlar):
    u = (np.asarray(satirlar, dtype=np.int64) & 0xFF).astype(np.uint64)
    kay = np.arange(8, dtype=np.uint64) * np.uint64(8)
    return [int(v) for v in (u << kay).sum(axis=1, dtype=np.uint64)]


def kelime_yaz(ad, kel, ac):
    with open(os.path.join(VEK, ad), "w", encoding="ascii", errors="replace") as f:
        f.write(f"// {ac}\n")
        for w in kel:
            f.write(f"{w:016x}\n")


def blok(X):        # (n, T=64, K) -> sözcük (s, b, k) bayt t
    n, T, K = X.shape
    return paketle(X.reshape(n, T // 8, 8, K).transpose(0, 1, 3, 2).reshape(-1, 8))


def panel(W):       # (n, C, K) -> sözcük (s, p, k) bayt j = W[s, p*8+j, k]
    n, C, K = W.shape
    return paketle(W.reshape(n, C // 8, 8, K).transpose(0, 1, 3, 2).reshape(-1, 8))


def main():
    kunye = json.load(open(os.path.join(VEK, "kunye.json"), encoding="utf-8"))
    n = len(kunye["cumle_idx"])
    T, hata, rapor = 64, 0, {}
    for i in range(2):
        q = mem(f"l{i}_qk_q.mem", 8).reshape(n, 2, T, 64)
        k = mem(f"l{i}_qk_k.mem", 8).reshape(n, 2, T, 64)
        v = mem(f"l{i}_av_v.mem", 8).reshape(n, 2, T, 64)
        p = mem(f"l{i}_av_p.mem", 8, imzali=False).reshape(n, 2, T, T)
        qk = mem(f"l{i}_qk_birikec.mem", 32).reshape(n, 2, T, T)
        av = mem(f"l{i}_av_birikec.mem", 32).reshape(n, 2, T, 64)
        for h in range(2):
            on = f"l{i}_qk_h{h}"
            kelime_yaz(f"{on}_girdi_blok.mem", blok(q[:, h]), f"Q baş {h} blok düzeni [n][8][64]")
            kelime_yaz(f"{on}_w_panel.mem", panel(k[:, h]), f"K baş {h} panel düzeni (anahtar=kanal) [n][8][64]")
            yaz(f"{on}_b.mem", np.zeros(64), 32, "sıfır bias")
            yaz(f"{on}_birikec.mem", qk[:, h], 32, f"Q.K^T baş {h} [n][64][64]")
            # bağımsız denetim: yazılan düzenden Q·Kᵀ yeniden hesapla
            hata += int(not np.array_equal(q[:, h] @ k[:, h].transpose(0, 2, 1), qk[:, h]))
            on = f"l{i}_av_h{h}"
            kelime_yaz(f"{on}_girdi_blok.mem", blok(p[:, h]), f"P (UINT8) baş {h} blok düzeni [n][8][64]")
            vt = v[:, h].transpose(0, 2, 1)                                  # (n, d=64, j=64): W[c=d][k=j] = V[j][d]
            kelime_yaz(f"{on}_w_panel.mem", panel(vt), f"V^T baş {h} panel düzeni (boyut=kanal) [n][8][64]")
            yaz(f"{on}_b.mem", np.zeros(64), 32, "sıfır bias")
            yaz(f"{on}_birikec.mem", av[:, h], 32, f"P.V baş {h} [n][64][64]")
            hata += int(not np.array_equal(p[:, h] @ v[:, h], av[:, h]))
            rapor[f"l{i}_h{h}"] = {"qk_maks": int(np.abs(qk[:, h]).max()), "av_maks": int(np.abs(av[:, h]).max()),
                                   "p_min": int(p.min()), "p_maks": int(p.max()),
                                   "p_ort_satir_toplam": float(p[:, h].sum(-1).mean())}
    os.makedirs(os.path.join(KOK, "03-RTL", "sim"), exist_ok=True)
    json.dump(rapor, open(os.path.join(KOK, "03-RTL", "sim", "g10_hazir.json"), "w"), indent=1)
    print(f"G10 HAZIRLIK: {'PASS' if hata == 0 else 'FAIL'} (8 vektör kümesi, bağımsız numpy denetiminde {hata} hata)")
    return 0 if hata == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
