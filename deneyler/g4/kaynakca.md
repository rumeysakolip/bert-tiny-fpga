# G4 — Kaynakça ve veri kaynakları

## Literatür
- Kim, S., Gholami, A., Yao, Z., Mahoney, M. W., Keutzer, K. (2021). I-BERT: Integer-only BERT Quantization. https://arxiv.org/abs/2101.01321 (i-GELU, i-Softmax, tamsayı LayerNorm)
- Zafrir, O. ve ark. (2019). Q8BERT: Quantized 8Bit BERT. https://arxiv.org/abs/1910.06188 (QAT, PTQ karşılaştırması)
- Bondarenko, Y., Nagel, M., Blankevoort, T. (2021). Understanding and Overcoming the Challenges of Efficient Transformer Quantization. https://arxiv.org/abs/2109.12948 (artık bağlantılardaki aktivasyon aykırı değerleri)
- MLCommons, MLPerf Inference Rules (BERT kabul eşiği: FP32 doğruluğunun %99'u). https://raw.githubusercontent.com/mlcommons/inference_policies/master/inference_rules.adoc
- Turc, I. ve ark. (2019). Well-Read Students Learn Better (BERT-Tiny). https://arxiv.org/abs/1908.08962
- Empirical Evaluation of Post-Training Quantization Methods for Language Tasks (2022). https://arxiv.org/abs/2210.16621
- PyTorch Dynamic Quantization Recipe (dinamik niceleme donanıma uymaz, kullanılmadı). https://pytorch.org/tutorials/recipes/recipes/dynamic_quantization.html

## Veri ve model
- GLUE SST-2 doğrulama kümesi (872 cümle): `03_girdi_veri/dogrulama_tahminleri.csv` (G3 çıktısı). Wang ve ark. (2019), GLUE, https://arxiv.org/abs/1804.07461; Socher ve ark. (2013), Stanford Sentiment Treebank.
- Kalibrasyon cümleleri: SST-2 cümle düzeyi eğitim kopyası (6.920 cümle), https://github.com/clairett/pytorch-sentiment-classification (data/SST2/train.tsv) → `03_girdi_veri/kalibrasyon_train.tsv`. Hugging Face'e erişilemediği için GLUE eğitim kümesi yerine kullanıldı.
- Model: prajjwal1/bert-tiny (Hugging Face), G3'te SST-2 ile ince ayarlı: `03_girdi_veri/model/`.

## Geri bildirim
- Emin Güney'in (danışman) Ekim 2026 geri bildirimi: hedef ≤1 puan / üst sınır 2 puan, MLPerf %99 eşiği, FP32–INT8 uyuşma oranı, önce statik kalibrasyonlu PTQ sonra gerekirse QAT, aktivasyon aykırı değerleri, Softmax/GELU/LayerNorm hassasiyeti. Özeti: `04_sonuclar/onceki_ptq_g3/kriterler.md`.
