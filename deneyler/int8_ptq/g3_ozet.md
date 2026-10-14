# G3 — Statik INT8 PTQ sonuçları (14 Ekim 2026)

**Önemli not (dürüstlük):** Bu sonuçlar yalnızca **Linear katmanlar INT8** iken ölçüldü. **Softmax, GELU, LayerNorm, artık (residual) toplamlar, QK^T ve Softmax·V matris çarpımları ve gömme tabloları FP32** kaldı. Tam tamsayı (integer-only) bir FPGA hattının doğruluğu bu sayılar değildir; G4'teki I-BERT yaklaşımlarıyla ayrıca ölçülmelidir.

## Ana tablo (SST-2 doğrulama, 872 cümle; FP32 referansı 719 doğru, %82,45)

| Koşu | Observer | Aktivasyon | Kalib. | INT8 doğru | Doğruluk | Kayıp (puan / cümle) | Uyuşma | FP32 doğru→INT8 yanlış | FP32 yanlış→INT8 doğru | MLPerf (≥712) |
|---|---|---|---|---|---|---|---|---|---|---|
| FP32 baz | – | – | – | 719 | %82,45 | – | – | – | – | – |
| minmax_sim_n128 | minmax | simetrik | 128 | 719 | %82.45 | 0.00 / 0 | %99.77 (870/872) | 1 | 1 | evet |
| minmax_sim_n512 | minmax | simetrik | 512 | 719 | %82.45 | 0.00 / 0 | %100.00 (872/872) | 0 | 0 | evet |
| percentile99.99_sim_n128 | percentile 99.99 | simetrik | 128 | 718 | %82.34 | 0.11 / 1 | %99.43 (867/872) | 3 | 2 | evet |
| percentile99.99_sim_n512 | percentile 99.99 | simetrik | 512 | 719 | %82.45 | 0.00 / 0 | %99.54 (868/872) | 2 | 2 | evet |
| minmax_asim_n512 | minmax | asimetrik | 512 | 718 | %82.34 | 0.11 / 1 | %99.66 (869/872) | 2 | 1 | evet |
| percentile99.99_asim_n512 | percentile 99.99 | asimetrik | 512 | 718 | %82.34 | 0.11 / 1 | %99.89 (871/872) | 1 | 0 | evet |

Ayrışan hücreler (doğrulama kümesi satır indeksleri, `dogrulama_tahminleri.csv` idx):

- minmax_sim_n128: FP32 doğru→INT8 yanlış [301], FP32 yanlış→INT8 doğru [509]
- minmax_sim_n512: FP32 doğru→INT8 yanlış [], FP32 yanlış→INT8 doğru []
- percentile99.99_sim_n128: FP32 doğru→INT8 yanlış [142, 301, 800], FP32 yanlış→INT8 doğru [60, 509]
- percentile99.99_sim_n512: FP32 doğru→INT8 yanlış [301, 800], FP32 yanlış→INT8 doğru [60, 509]
- minmax_asim_n512: FP32 doğru→INT8 yanlış [618, 734], FP32 yanlış→INT8 doğru [509]
- percentile99.99_asim_n512: FP32 doğru→INT8 yanlış [618], FP32 yanlış→INT8 doğru []

## Yorum

- Altı koşunun hepsi 718–719 doğru: kayıp 0–1 cümle (0–0,11 puan). **Hedef (≤1 puan, ≥711) ve MLPerf eşiği (≥712) hepsinde sağlandı.**
- Koşular arasındaki fark en çok 1 cümle; hocanın kuralına göre **gürültüdür**. Observer/simetri/kalibrasyon sayısı arasında anlamlı bir üstünlük iddia edilemez.
- En iyi koşu: **minmax_sim_n512** (719 doğru, kayıp 0, 872/872 uyuşma). 719'a ulaşan üç koşudan biri; seçim gerekçesi 'en çok uyuşma' ve en basit ayar olmasıdır. Uyuşma oranı farkı da (%99,5–%100) 0–5 cümlelik tek tek değişimlerden ibarettir.
- Logit farkları küçük (ortalama mutlak ≈0,02; en büyük 0,2–0,35), niceleme gerçekten uygulanıyor ve tahminleri çok az değiştiriyor.
- Cümle 301 ve 509 iki ya da daha çok koşuda tekrar ediyor: sınıf sınırına çok yakın cümleler olmalı; küçük nicemleme hatası bunları çeviriyor.

## Karar

**Hedef (≤1 puan) sağlandı → G5 (katman bazlı hassasiyet) ve G6 (QAT) gerekmez.** `--fp32_katmanlar 'classifier|pooler'` denemesi yapılmadı, çünkü yalnızca 1–2 puan durumunda isteniyordu. Bu karar, Softmax/GELU/LayerNorm/artık toplamlar FP32 iken verildi; bu işlemler tamsayıya geçince (G4) ölçüm tekrarlanmalıdır.

## Yöntem ve sınırlar

- Model: Drive'dan indirilen `fp32_baz-…/fp32_baz/model` (repodaki `deneyler/fp32_baz/model/` konumuna **taşınmadı**). Betik `yazilim/nicele_ptq.py` değiştirilmeden çalıştırıldı; FP32 yeniden hesap 719/872 çıktı ve `dogrulama_tahminleri.csv` ile **0 farklı tahmin** verdi.
- **Kalibrasyon verisi farkı:** Hugging Face'e bu ortamdan erişilemediği için GLUE SST-2 eğitim kümesi (67.349 ifade) indirilemedi. Kalibrasyon cümleleri, SST-2'nin GitHub'daki cümle düzeyindeki eğitim kopyasından (6.920 cümle, clairett/pytorch-sentiment-classification) `--seed 42` karıştırmasıyla seçildi. Bu, betiğin HF verisiyle seçeceği 128/512 cümleden farklıdır; sonuçlar küçük farklarla değişebilir. Doğrulama kümesi olarak `dogrulama_tahminleri.csv`'deki 872 cümle (GLUE doğrulama) kullanıldı; eğitim kopyasıyla kesişimi 0.
- Ortam: Linux, CPU, torch 2.14.1, transformers 5.17.0 (FP32 eğitimdeki sürümle aynı).
- Kalibrasyon seçimi için tek tohum (42) kullanıldı; kalibrasyon cümlesi seçiminin etkisi (farklı tohumlar) ölçülmedi.

## Ek deney: classifier ve pooler FP32 (`--fp32_katmanlar 'classifier|pooler'`)

Karar kuralına göre bu deney yalnızca 1–2 puan kayıpta zorunluydu; sonradan isteğiniz üzerine iki koşuda yapıldı (nicelenen Linear katman sayısı 14 → 12).

| Koşu | Doğru | Kayıp (puan / cümle) | Uyuşma | FP32 doğru→INT8 yanlış | FP32 yanlış→INT8 doğru | Karşılaştırılan koşu (tüm Linear INT8) |
|---|---|---|---|---|---|---|
| minmax_sim_n512_fp32cls | 719 | 0.00 / 0 | %100.00 (872/872) | 0 [] | 0 [] | minmax_sim_n512: 719, uyuşma 872 |
| percentile99.99_sim_n128_fp32cls | 718 | 0.11 / 1 | %99.43 (867/872) | 3 [142, 301, 800] | 2 [60, 509] | percentile99.99_sim_n128: 718, uyuşma 867 |

Sonuç: pooler ve classifier'ı FP32 bırakmak hiçbir şeyi değiştirmedi (aynı doğru sayısı, aynı ayrışan cümleler; ortalama logit farkı ≈0,02). Bu iki katmanda INT8 sorun çıkarmıyor; ek hassasiyet gerekmiyor. Karar değişmedi: G5/G6 gerekmez.
