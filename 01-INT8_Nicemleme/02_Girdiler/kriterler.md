# INT8 niceleme başarı ölçütleri (hoca geri bildirimi, madde 1)

Referans: FP32 BERT-Tiny, SST-2 doğrulama (872 cümle) → **719 doğru, %82,45** (`deneyler/fp32_baz/`).
1 puan ≈ 8,72 cümle.

| Ölçüt | Eşik | INT8'de en az doğru | FP32'ye göre en çok kayıp |
|---|---|---|---|
| **Hedef** | ≤ 1 puan | 711 (%81,54) | 8 cümle |
| **Üst sınır** | ≤ 2 puan | 702 (%80,50) | 17 cümle |
| MLPerf kabul eşiği | ≥ FP32'nin %99'u | 712 (%81,65) | 7 cümle (≈0,8 puan) |

Her INT8 koşusunda raporlanacaklar:
1. INT8 doğruluğu ve FP32'ye göre kayıp (puan ve cümle).
2. FP32–INT8 tahmin uyuşma oranı ve ayrışan hücreler (FP32 doğru→INT8 yanlış / tersi).
3. Karar: hedef sağlandı / sınır içinde / sınır aşıldı.

Not: Kayıp net farktır; uyuşma oranı net fark küçük görünse bile birbirini götüren çok sayıda
değişimi yakalar. Doğrulama kümesi küçük olduğu için 1–2 cümlelik farklar gürültü sayılmalıdır.

Literatür referansları: BERT-base SST-2 statik INT8 PTQ ≈ 0,6 puan kayıp (Bondarenko ve ark., 2021);
QAT, PTQ'nun ≈1,3 puanlık kaybını ≈0,1 puana indirmiş (Zafrir ve ark., 2019). BERT-Tiny çok küçük
olduğu için bu sayılar doğrudan beklenti değil, yalnızca yön göstergesidir.

Üretim: `python yazilim/nicemleme_olcut.py --out deneyler/int8_ptq/kriterler.json`
