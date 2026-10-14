# Statik INT8: PTQ ve QAT yan yana — qat_onizleme_cpu_lr5e-5_e3_s42

| Ölçüt | FP32 | PTQ | QAT |
|---|---|---|---|
| Doğru cümle (872 içinde) | 719 | 719 | 711 |
| Doğruluk | %82.45 | %82.45 | %81.54 |
| FP32'ye göre kayıp (puan) | — | 0.0 | 0.92 |
| FP32'ye göre kayıp (cümle) | — | 0 | 8 |
| FP32–INT8 tahmin uyuşma oranı | — | %100.00 (0 cümle farklı) | %96.79 (28 cümle farklı) |
| FP32 doğru → INT8 yanlış | — | 0 | 18 |
| FP32 yanlış → INT8 doğru | — | 0 | 10 |
| Maks / ort. mutlak logit farkı (FP32'ye göre) | — | 0.3548 / 0.0224 | 2.3509 / 0.1769 |
| Hedef (≤1 puan, ≥711 doğru) | — | ✔ | ✔ |
| Üst sınır (≤2 puan, ≥702 doğru) | — | ✔ | ✔ |
| MLPerf (≥%99 FP32) | — | ✔ | ✘ |

QAT için karar: HEDEF sağlandı (<=1 puan)

Tutarlılık (QAT sahte niceleme ↔ tamsayı yolu, doğrulama kümesi): tahmin uyuşması %100.00, maks mutlak logit farkı 0.03759, ort. 0.000532.

Not: 872 cümlelik kümede 1–2 cümlelik farklar gürültüdür (1 puan ≈ 8,72 cümle).