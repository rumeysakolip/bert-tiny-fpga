#!/usr/bin/env python3
"""G1 kabul denetimi: test vektörleri .mem dosyalarından BAĞIMSIZ olarak yeniden hesaplanır.

Altın modelin Python kodunu kullanmaz; yalnızca .mem dosyaları ve parametreler.vh okunur.
Denetimler (her katman, her cümle):
  1) birikeç == girdi @ Wᵀ + bias                  (INT64 tam çarpım)
  2) cikis   == kirp((birikeç*M0 + 2^(n-1)) >> n)  (kanal başına M0, katman başına n)
  3) girdi_blok / w_panel düzeni, açılınca girdi / W ile birebir
  4) dikkat: qk_birikec == Q·Kᵀ ve av_birikec == P·V
Son satır: "G1 DOGRULAMA: PASS (N kontrol, 0 hata)".  Çıktı json: _kontrol yerine 03-RTL/sim/g1_dogrulama.json
"""
import json
import os
import re
import sys

import numpy as np

KOK = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SONUC = os.path.join(KOK, "02-RTL_Altin_Model", "03_Sonuclar")
VEK = os.path.join(SONUC, "test_vektorleri")
PAR = os.path.join(SONUC, "parametreler")
CIKTI = os.path.join(KOK, "03-RTL", "sim", "g1_dogrulama.json")


def mem_oku(yol, bit, isaretli=True):
    """$readmemh biçimi: '//' satırları yorum; satır başına bir sözcük (bit>64 desteklenmez)."""
    deg = []
    with open(yol, encoding="ascii") as f:
        for s in f:
            s = s.strip()
            if not s or s.startswith("//"):
                continue
            deg.append(int(s, 16))
    a = np.array(deg, dtype=np.uint64 if bit == 64 else np.int64)
    if bit == 64:
        return a
    if isaretli:
        a = np.where(a >= (1 << (bit - 1)), a - (1 << bit), a)
    return a.astype(np.int64)


def kaydirmalar():
    d = {}
    for s in open(os.path.join(PAR, "parametreler.vh"), encoding="ascii"):
        m = re.match(r"localparam integer KAYDIRMA_(\w+)\s*=\s*(\d+);", s)
        if m:
            d[m.group(1).lower()] = int(m.group(2))
    return d


def ac64(a, genislik=8):
    """(N,) uint64 sözcük -> (N, 8) INT8 (bayt j = sütun j)."""
    kay = np.arange(genislik, dtype=np.uint64) * np.uint64(8)
    b = ((a[:, None] >> kay) & np.uint64(0xFF)).astype(np.int64)
    return np.where(b >= 128, b - 256, b)


def main():
    kunye = json.load(open(os.path.join(VEK, "kunye.json"), encoding="utf-8"))
    n = len(kunye["cumle_idx"])
    T = kunye["dizi_uzunlugu"]
    kay = kaydirmalar()
    kontrol, hata, ozet = 0, 0, {}

    def esit(ad, a, b):
        nonlocal kontrol, hata
        kontrol += 1
        if a.shape != b.shape or not np.array_equal(a, b):
            hata += 1
            fark = int(np.count_nonzero(a != b)) if a.shape == b.shape else -1
            print(f"  FAIL {ad}: uyusmayan eleman={fark}")
            return False
        return True

    for kisa, d in kunye["dosyalar"].items():
        K = d["girdi_sekil"][-1]
        C = d["beklenen_sekil"][-1]
        Tk = d["girdi_sekil"][1] if len(d["girdi_sekil"]) == 3 else 1   # pooler/classifier: 1 token
        X = mem_oku(os.path.join(VEK, d["girdi"]), 8).reshape(n, Tk, K)
        acc = mem_oku(os.path.join(VEK, d["beklenen"]), 32).reshape(n, Tk, C)
        cik = mem_oku(os.path.join(VEK, d["cikis"]), 8).reshape(n, Tk, C)
        W = mem_oku(os.path.join(PAR, f"{kisa}_w.mem"), 8).reshape(C, K)
        b = mem_oku(os.path.join(PAR, f"{kisa}_b.mem"), 32)
        m0 = mem_oku(os.path.join(PAR, f"{kisa}_m0.mem"), 31, isaretli=False)
        sh = kay[kisa]

        ok1 = esit(f"{kisa}.birikec", X @ W.T + b, acc)
        yeni = (acc * m0 + (1 << (sh - 1))) >> sh
        ok2 = esit(f"{kisa}.cikis", np.clip(yeni, -128, 127), cik)
        # düzen denetimleri
        B = -(-Tk // 8)
        blok = ac64(mem_oku(os.path.join(VEK, f"{kisa}_girdi_blok.mem"), 64)).reshape(n, B, K, 8)
        blok = blok.transpose(0, 1, 3, 2).reshape(n, B * 8, K)
        ok3 = esit(f"{kisa}.girdi_blok", blok[:, :Tk], X) and esit(f"{kisa}.girdi_blok_dolgu", blok[:, Tk:], np.zeros_like(blok[:, Tk:]))
        P = -(-C // 8)
        pan = ac64(mem_oku(os.path.join(VEK, f"{kisa}_w_panel.mem"), 64)).reshape(P, K, 8)
        Wp = pan.transpose(0, 2, 1).reshape(P * 8, K)
        ok4 = esit(f"{kisa}.w_panel", Wp[:C], W) and esit(f"{kisa}.w_panel_dolgu", Wp[C:], np.zeros_like(Wp[C:]))
        doy = int(np.count_nonzero(np.abs(yeni) > 127))
        ozet[kisa] = {"K": K, "C": C, "cumle": n, "vektor": int(n * Tk * C),
                      "birikec_ok": bool(ok1), "cikis_ok": bool(ok2), "blok_ok": bool(ok3), "panel_ok": bool(ok4),
                      "kirpilan_eleman": doy, "kaydirma_n": sh, "birikec_maks": int(np.abs(acc).max())}

    # dikkat çekirdeği
    for i in range(2):
        pf = f"l{i}"
        if not os.path.exists(os.path.join(VEK, f"{pf}_qk_q.mem")):
            continue
        q = mem_oku(os.path.join(VEK, f"{pf}_qk_q.mem"), 8).reshape(n, 2, T, 64)
        k = mem_oku(os.path.join(VEK, f"{pf}_qk_k.mem"), 8).reshape(n, 2, T, 64)
        v = mem_oku(os.path.join(VEK, f"{pf}_av_v.mem"), 8).reshape(n, 2, T, 64)
        pr = mem_oku(os.path.join(VEK, f"{pf}_av_p.mem"), 8, isaretli=False).reshape(n, 2, T, T)
        qk = mem_oku(os.path.join(VEK, f"{pf}_qk_birikec.mem"), 32).reshape(n, 2, T, T)
        av = mem_oku(os.path.join(VEK, f"{pf}_av_birikec.mem"), 32).reshape(n, 2, T, 64)
        esit(f"{pf}.qk_birikec", q @ k.transpose(0, 1, 3, 2), qk)
        esit(f"{pf}.av_birikec", pr @ v, av)
        esit(f"{pf}.olasilik_u8_esit_av_p", mem_oku(os.path.join(VEK, f"{pf}_olasilik_u8.mem"), 8, isaretli=False).reshape(pr.shape), pr)
        ozet[f"{pf}_dikkat"] = {"qk_maks": int(np.abs(qk).max()), "av_maks": int(np.abs(av).max()),
                                "p_aralik": [int(pr.min()), int(pr.max())]}

    os.makedirs(os.path.dirname(CIKTI), exist_ok=True)
    json.dump({"kontrol": kontrol, "hata": hata, "katmanlar": ozet}, open(CIKTI, "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    durum = "PASS" if hata == 0 else "FAIL"
    print(f"G1 DOGRULAMA: {durum} ({kontrol} kontrol, {hata} hata)")
    return 0 if hata == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
