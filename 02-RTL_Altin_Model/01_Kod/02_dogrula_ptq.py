"""D1 — Altın modeli PTQ çıktısıyla doğrula.

Bu betik altın modelin TEK geçerlilik ölçütüdür. Geçmeden RTL yazmaya
başlanmaz: altın model yanlışsa, testbench'in neyi yanlış bulduğunu
anlayamazsın.

Üç ölçüt:
  1. FP32 yolu     -> 719/872 (kriterler.json'daki taban)
  2. A-kipi        -> 718/872 ve PTQ tahminleriyle 872/872 uyuşma
  3. Tamsayı yolu  -> systolic dizi ile vektörel matmul bit-birebir aynı;
                      hiçbir INT32 birikeçte taşma yok

Çalıştırma:
    python 02_dogrula_ptq.py
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ortak  # noqa: E402
from altin import birimler, model, veri  # noqa: E402


def ptq_oku(yol: str):
    satirlar = list(csv.DictReader(open(yol, encoding="utf-8")))
    tahmin = np.array([int(s["int8_tahmin"]) for s in satirlar], dtype=np.int64)
    fp32 = np.array([int(s["fp32_tahmin"]) for s in satirlar], dtype=np.int64)
    logit = np.array([[float(s["logit_olumsuz"]), float(s["logit_olumlu"])]
                      for s in satirlar], dtype=np.float64)
    return tahmin, fp32, logit


def kos(m, ids, maske, yigin=128):
    return np.concatenate([m.ileri(i, k) for i, k in veri.yiginla(ids, maske, yigin)])


def main():
    ap = ortak.ortak_argumanlar(argparse.ArgumentParser(description=__doc__))
    ap.add_argument("--yigin", type=int, default=128)
    a = ap.parse_args()

    p, _, cumleler, etiket, ids, maske, y = ortak.yukle_hepsi(a)
    ptq_tahmin, ptq_fp32, ptq_logit = ptq_oku(y["ptq_csv"])
    print(f"Veri: {len(cumleler)} cümle, dizi uzunluğu {ids.shape[1]}\n")

    rapor = {"kosu": a.kosu, "olcutler": {}}
    basarili = True

    # ---- 1) FP32 ----------------------------------------------------------
    t = time.time()
    m32 = model.AltinModel(p, model.Ayarlar(kip="fp32"))
    pr32 = kos(m32, ids, maske, a.yigin).argmax(1)
    d32 = int((pr32 == etiket).sum())
    u32 = int((pr32 == ptq_fp32).sum())
    ok = (d32 == 719)
    basarili &= ok
    print(f"[{'GEÇTİ' if ok else 'KALDI'}] FP32 yolu: {d32}/872 doğru "
          f"(beklenen 719) | PTQ'nun FP32 tahminleriyle uyuşma {u32}/872 "
          f"| {time.time()-t:.1f}s")
    rapor["olcutler"]["fp32"] = {"dogru": d32, "beklenen": 719,
                                 "fp32_tahmin_uyusma": u32, "gecti": ok}

    # ---- 2) A-kipi --------------------------------------------------------
    t = time.time()
    mA = model.AltinModel(p, model.Ayarlar(kip="A"))
    lgA = kos(mA, ids, maske, a.yigin)
    prA = lgA.argmax(1)
    dA = int((prA == etiket).sum())
    uA = int((prA == ptq_tahmin).sum())
    fark = np.abs(lgA - ptq_logit)
    ok = (dA == 718) and (uA == len(etiket))
    basarili &= ok
    print(f"[{'GEÇTİ' if ok else 'KALDI'}] A-kipi: {dA}/872 doğru (beklenen 718) "
          f"| PTQ ile tahmin uyuşması {uA}/872 | {time.time()-t:.1f}s")
    print(f"         logit farkı: ortanca {np.median(fark):.2e}  "
          f"%99 {np.percentile(fark,99):.2e}  en büyük {fark.max():.2e}")
    print("         (fark yalnızca FP32 kalan birimlerin — LayerNorm/softmax/GELU — "
          "numpy ile torch arasındaki yuvarlama sırasından gelir; tamsayı yolu birebirdir)")
    rapor["olcutler"]["A_kipi"] = {
        "dogru": dA, "beklenen": 718, "ptq_tahmin_uyusma": uA,
        "kayip_puan": round(100 * (719 - dA) / 872, 2),
        "logit_fark_ortanca": float(np.median(fark)),
        "logit_fark_maks": float(fark.max()), "gecti": ok}

    # ---- 3) Tamsayı veri yolu --------------------------------------------
    rng = np.random.default_rng(0)
    X = rng.integers(-128, 128, size=(23, 128), dtype=np.int64)
    W = rng.integers(-127, 128, size=(41, 128), dtype=np.int64)
    birebir = bool(np.array_equal(birimler.SistolikDizi().carp(X, W),
                                  birimler.hizli_matmul(X, W)))
    tasmalar = {k: v for k, v in mA.kayit.rapor().items() if v["tasma"] > 0}
    ok = birebir and not tasmalar
    basarili &= ok
    print(f"[{'GEÇTİ' if ok else 'KALDI'}] Tamsayı yolu: systolic dizi == vektörel "
          f"matmul: {birebir} | taşan birikeç: {len(tasmalar)}")

    gb = mA.kayit.rapor()
    en_genis = max(gb.items(), key=lambda kv: kv[1]["gereken_bit"])
    print(f"         en geniş birikeç: {en_genis[0]} -> {en_genis[1]['gereken_bit']} bit "
          f"gerekiyor, INT32'de {en_genis[1]['bos_pay_bit']} bit boş pay var")
    rapor["olcutler"]["tamsayi_yolu"] = {
        "sistolik_birebir": birebir, "tasan_birikec": len(tasmalar),
        "en_genis_birikec": en_genis[0],
        "gereken_bit": en_genis[1]["gereken_bit"],
        "bos_pay_bit": en_genis[1]["bos_pay_bit"], "gecti": ok}
    rapor["birikec_genislikleri"] = gb

    os.makedirs(a.cikis, exist_ok=True)
    yol = os.path.join(a.cikis, "dogrulama_raporu.json")
    with open(yol, "w", encoding="utf-8") as f:
        json.dump(rapor, f, ensure_ascii=False, indent=2)

    print(f"\n{'TÜM ÖLÇÜTLER GEÇTİ' if basarili else 'DOĞRULAMA BAŞARISIZ'} — rapor: {yol}")
    return 0 if basarili else 1


if __name__ == "__main__":
    raise SystemExit(main())
