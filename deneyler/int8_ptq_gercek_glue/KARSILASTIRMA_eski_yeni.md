# PTQ koşuları: kalibrasyon kaynağı karşılaştırması (14 Ekim 2026)

FP32 baz 719/872 (%82,45) — her iki koşuda da aynı model, aynı doğrulama kümesi.
Her yeni koşuda FP32 yeniden hesaplandı ve `dogrulama_tahminleri.csv` ile **0 farklı tahmin** verdi
(yani model doğru yüklendi, baz birebir yeniden üretildi).

| Koşu | ESKİ: 6.920 cümlelik GitHub kopyası | YENİ: gerçek GLUE train (67.349) |
|---|---|---|
| minmax_sim_n128 | 719 — 0,00 puan — uyuşma %99,77 | **718 — 0,11 — %99,66** |
| minmax_sim_n512 | 719 — 0,00 — %100,00 | **718 — 0,11 — %99,66** |
| percentile99.99_sim_n128 | 718 — 0,11 — %99,43 | **717 — 0,23 — %99,54** |
| percentile99.99_sim_n512 | 719 — 0,00 — %99,54 | **717 — 0,23 — %99,54** |
| minmax_asim_n512 | 718 — 0,11 — %99,66 | **716 — 0,34 — %99,43** |
| percentile99.99_asim_n512 | 718 — 0,11 — %99,89 | **718 — 0,11 — %99,89** |

## Okuma

- **Altı koşunun altısı da hedefi (≤1 puan, ≥711) ve MLPerf eşiğini (≥712) sağlıyor.** En kötü koşu
  716 doğru = 0,34 puan kayıp. Karar değişmiyor: PTQ yeterli, QAT zorunlu değil.
- Yeni sonuçlar 1–3 cümle daha düşük. Kendi gürültü kuralımıza göre (1 puan ≈ 8,72 cümle) bu fark
  **gürültü sınırında**; "eski kalibrasyon daha iyiydi" denemez.
- `percentile99.99_asim_n512` iki kaynakta da birebir aynı çıktı (718, %99,89) — kalibrasyon
  kaynağına en az duyarlı ayar bu. Yüzdelik kırpma aykırı değerleri budadığı için beklenen bir davranış.
- Logit farkları her iki koşuda da küçük: ortalama 0,019–0,026, en büyük 0,22–0,39.

## Neden hafif düştü (ölçeklerden kanıt)

`minmax_sim_n512` koşusunda 14 katmanın ölçekleri karşılaştırıldı:

- 10 katmanda ölçek **aynı** kaldı (aktivasyon aralığını belirleyen uç değer değişmemiş).
- 4 katmanda aralık büyüdü; en belirgin olanı `layer.0.attention.output.dense` girişi: **×1,26**.
  Ölçek büyüyünce aynı 255 adım daha geniş bir aralığa yayılıyor, yani niceleme adımı kabalaşıyor.
- Aktivasyon mutlak maksimumlarının oranı (yeni/eski): ortanca 1,00, en büyük 1,26, en küçük 0,90.

Muhtemel sebep: GLUE SST-2 eğitim kümesi cümle değil **ifade (phrase)** düzeyindedir; GitHub kopyası
ise tam cümlelerden oluşuyordu. Farklı uzunluk dağılımı birkaç katmanda daha geniş aktivasyon
aralığı üretmiş. Bu bir hipotezdir; kesinleştirmek istersen iki kaynağın token uzunluğu dağılımını
karşılaştır.

## Ne değişti, ne değişmedi

| Konu | Durum |
|---|---|
| Hedef (≤1 puan) | Sağlandı (her iki kaynakta da) |
| MLPerf (≥712) | Sağlandı (her iki kaynakta da) |
| "Veri sapması" açık maddesi | **KAPANDI** — kalibrasyon artık gerçek GLUE eğitim kümesinden |
| En iyi koşu | Eski: minmax_sim_n512 · Yeni: percentile99.99_asim_n512 (718, en yüksek uyuşma) |
| G4/G6 sonuçları | Etkilenmedi — onlar ayrı kalibrasyonla koşuldu, yeniden ölçülürse benzer kayma beklenir |

Not: Altı ayarın en iyisini doğrulama kümesine bakarak seçmek iyimser bir seçimdir; raporda altı
koşunun hepsini birden ver.
