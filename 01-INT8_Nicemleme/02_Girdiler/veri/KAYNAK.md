# Veri kaynağı notu

- `train.tsv` (6.920 cümle, başlıklı `sentence<TAB>label`): kalibrasyon için kullanıldı. Kaynak: SST-2'nin cümle düzeyindeki
  eğitim kopyası, GitHub `clairett/pytorch-sentiment-classification` (`data/SST2/train.tsv`), başlık satırı eklenerek GLUE biçimine getirildi.
  GLUE'nun 67.349 ifadelik eğitim kümesi DEĞİLDİR (Hugging Face çalışma ortamından erişilemedi).
- `dev.tsv` (872 cümle): `deneyler/fp32_baz/dogrulama_tahminleri.csv` içindeki `cumle` ve `etiket` sütunlarından üretildi
  (GLUE SST-2 doğrulama kümesi, aynı sırada). Eğitim kopyasıyla kesişim: 0.
- Betik bu klasörü `--data_dir` ile okur (train.tsv / dev.tsv).
