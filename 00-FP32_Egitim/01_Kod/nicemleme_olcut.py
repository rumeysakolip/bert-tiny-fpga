"""Niceleme (INT8) başarı ölçütleri — hoca geri bildirimi, madde 1.

Kabul kriterleri
  HEDEF  : FP32'ye göre doğruluk kaybı <= 1 puan
  SINIR  : FP32'ye göre doğruluk kaybı <= 2 puan (üst sınır)
  MLPerf : INT8 doğruluğu >= FP32 doğruluğunun %99'u (BERT için MLPerf kabul eşiği)
Ek rapor: FP32–INT8 tahmin uyuşma oranı. 872 cümlelik doğrulama kümesinde 1 puan ≈ 8,72 cümle
olduğu için tüm farklar cümle sayısı olarak da verilir.

Kullanım
  # yalnızca eşik tablosu (G1):
  python yazilim/nicemleme_olcut.py --fp32_csv deneyler/fp32_baz/dogrulama_tahminleri.csv \
         --out deneyler/int8_ptq/kriterler.json
  # bir INT8 koşusunu değerlendirmek için (G3'te nicele_ptq.py bunu kendisi çağırır):
  python yazilim/nicemleme_olcut.py --fp32_csv ... --int8_csv deneyler/int8_ptq/<kosu>/int8_tahminleri.csv
"""

from __future__ import annotations

import argparse
import csv
import json
import math
from typing import Dict, List, Sequence

HEDEF_PUAN = 1.0
SINIR_PUAN = 2.0
MLPERF_ORAN = 0.99


def oku_fp32_csv(path: str) -> Dict[str, List[int]]:
    """egit_fp32.py çıktısını (idx, cumle, etiket, tahmin, logit_olumsuz, logit_olumlu) okur."""
    etiket, tahmin = [], []
    with open(path, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            etiket.append(int(row["etiket"]))
            tahmin.append(int(row["tahmin"]))
    return {"etiket": etiket, "tahmin": tahmin}


def esikler(n: int, dogru_fp32: int) -> Dict[str, float]:
    """n cümlelik kümede, FP32'nin `dogru_fp32` doğrusuna göre izin verilen en çok kayıp (cümle)."""
    puan = n / 100.0  # 1 puan kaç cümle
    # INT8 doğru sayısı en az şu kadar olmalı:
    min_hedef = math.ceil(dogru_fp32 - HEDEF_PUAN * puan - 1e-9)
    min_sinir = math.ceil(dogru_fp32 - SINIR_PUAN * puan - 1e-9)
    min_mlperf = math.ceil(MLPERF_ORAN * dogru_fp32 - 1e-9)
    return {
        "bir_puan_cumle": puan,
        "min_dogru_hedef": min_hedef, "en_cok_kayip_cumle_hedef": dogru_fp32 - min_hedef,
        "min_dogru_sinir": min_sinir, "en_cok_kayip_cumle_sinir": dogru_fp32 - min_sinir,
        "min_dogru_mlperf": min_mlperf, "en_cok_kayip_cumle_mlperf": dogru_fp32 - min_mlperf,
    }


def degerlendir(etiket: Sequence[int], fp32: Sequence[int], int8: Sequence[int]) -> Dict:
    n = len(etiket)
    assert len(fp32) == n and len(int8) == n, "uzunluklar uyuşmuyor"
    d_fp32 = sum(int(p == e) for p, e in zip(fp32, etiket))
    d_int8 = sum(int(p == e) for p, e in zip(int8, etiket))
    uyusan = sum(int(a == b) for a, b in zip(fp32, int8))
    # FP32 doğru -> INT8 yanlış  /  FP32 yanlış -> INT8 doğru  (McNemar tablosunun ayrışan hücreleri)
    bozulan = sum(int(a == e and b != e) for a, b, e in zip(fp32, int8, etiket))
    duzelen = sum(int(a != e and b == e) for a, b, e in zip(fp32, int8, etiket))
    kayip_puan = 100.0 * (d_fp32 - d_int8) / n
    es = esikler(n, d_fp32)
    return {
        "n": n,
        "dogruluk_fp32": round(d_fp32 / n, 4), "dogruluk_int8": round(d_int8 / n, 4),
        "dogru_fp32": d_fp32, "dogru_int8": d_int8,
        "kayip_puan": round(kayip_puan, 2), "kayip_cumle": d_fp32 - d_int8,
        "uyusma_orani": round(uyusan / n, 4), "uyusmayan_cumle": n - uyusan,
        "fp32_dogru_int8_yanlis": bozulan, "fp32_yanlis_int8_dogru": duzelen,
        "mlperf_orani": round(d_int8 / d_fp32, 4) if d_fp32 else None,
        "hedef_saglandi": kayip_puan <= HEDEF_PUAN + 1e-9,
        "sinir_saglandi": kayip_puan <= SINIR_PUAN + 1e-9,
        "mlperf_saglandi": d_int8 >= es["min_dogru_mlperf"],
        "esikler": es,
        "karar": ("HEDEF sağlandı (<=1 puan)" if kayip_puan <= HEDEF_PUAN + 1e-9 else
                  "SINIR içinde ama hedef aşıldı (1–2 puan) -> hata analizi (G5)" if kayip_puan <= SINIR_PUAN + 1e-9 else
                  "SINIR aşıldı (>2 puan) -> hata analizi (G5), gerekirse QAT (G6)"),
    }


def main():
    ap = argparse.ArgumentParser(description="INT8 niceleme başarı ölçütleri")
    ap.add_argument("--fp32_csv", default="deneyler/fp32_baz/dogrulama_tahminleri.csv")
    ap.add_argument("--int8_csv", default=None, help="idx,...,int8_tahmin sütunlu dosya (nicele_ptq.py çıktısı)")
    ap.add_argument("--out", default=None)
    a = ap.parse_args()

    fp = oku_fp32_csv(a.fp32_csv)
    n, d = len(fp["etiket"]), sum(int(p == e) for p, e in zip(fp["tahmin"], fp["etiket"]))
    sonuc: Dict = {"fp32": {"n": n, "dogru": d, "dogruluk": round(d / n, 4)}, "esikler": esikler(n, d)}
    if a.int8_csv:
        with open(a.int8_csv, encoding="utf-8", newline="") as f:
            int8 = [int(r["int8_tahmin"]) for r in csv.DictReader(f)]
        sonuc["int8"] = degerlendir(fp["etiket"], fp["tahmin"], int8)
    txt = json.dumps(sonuc, ensure_ascii=False, indent=2)
    print(txt)
    if a.out:
        with open(a.out, "w", encoding="utf-8") as f:
            f.write(txt)


if __name__ == "__main__":
    main()
