# 00 — FP32 Eğitim (referans model)

Bu dizin, projenin **başlangıç noktasını** tutar: SST-2 ile ince ayar yapılmış FP32 BERT-Tiny modeli,
eğitim sonuçları, eğitimi üreten kod ve hocaya gönderilen raporlar. Buradaki 719/872 sayısı,
sonraki bütün INT8 karşılaştırmalarının referansıdır.

## Düzen

| Klasör | İçerik |
|---|---|
| `01_Kod/` | `egit_fp32.py` (eğitim betiği), `sst2_veri.py` (veri yükleyici), `nicemleme_olcut.py` (başarı eşiklerini üretir), iki Colab not defteri, `requirements.txt` |
| `02_Model/` | Eğitilmiş FP32 model: `model.safetensors` (17,5 MB), `config.json`, tokenizer |
| `03_Sonuclar/` | `sonuclar.json`, `egitim_log.txt`, `dogrulama_tahminleri.csv` (872 cümlenin FP32 tahminleri), `kriterler.md/json` (eşikler) |
| `04_Rapor/` | `G3_FP32_Baz_Dogruluk_Raporu.docx` (FP32 baz raporu), `Rapor_BIL401_Ara_Rapor_16Ekim2026.docx/pdf` (16 Ekim ara raporu) |
| `_ham_drive_indirmesi.zip` | Drive'dan indirilen paketin bozulmamış hâli |

## Sonuç özeti

| Büyüklük | Değer |
|---|---|
| Model | BERT-Tiny (2 katman, gizli 128, 2 başlık), 4.386.178 parametre, 16,73 MB |
| Veri | GLUE SST-2 — eğitim 67.349, doğrulama 872 cümle |
| Ayarlar | 4 epoch, lr 1e-4, batch 32, max_len 64, weight_decay 0,01, warmup %10, tohum 42 |
| Ortam | Tesla T4, 96,2 sn |
| **Doğruluk** | **719 / 872 = %82,45** (en iyi epoch: 4) |
| Literatür | Turc ve ark. (2019): %83,2 (test kümesi — farklı küme, fark ≈6,5 cümle) |

Epoch epoch doğrulama: %81,65 → %81,77 → %81,77 → **%82,45**.
Dikkat: son epoch'ta hâlâ yükseliyor; 4 epoch erken kesilmiş olabilir. Daha uzun eğitim +
çoklu tohum denemesi "sonraki adımlar" listesinde.

## Eşikler (bu modele göre türetildi)

| Ölçüt | Eşik | En az doğru |
|---|---|---|
| Hedef | ≤1 puan kayıp | 711 |
| Üst sınır | ≤2 puan | 702 |
| MLPerf | FP32'nin %99'u | 712 |

1 puan ≈ 8,72 cümle.

## Yeniden eğitmek istersen (Colab)

1. `02_Model/`, `03_Sonuclar/` ve `01_Kod/` içeriğini Drive'da `MyDrive/bert-tiny-fpga/` altına koy.
2. `01_Kod/01b_fp32_egitim_drive.ipynb` not defterini Colab'da aç, çalışma zamanı **T4 GPU**.
3. Hücreleri sırayla çalıştır; çıktı `MyDrive/bert-tiny-fpga/deneyler/fp32_baz/` altına yazılır.
4. Komut satırından koşmak istersen: `python egit_fp32.py --out_dir deneyler/fp32_baz --epochs 4 --lr 1e-4 --seed 42`

**Uyarı:** Bu modeli yeniden eğitip 719 sayısı değişirse, eşikler (711/702/712) ve bütün INT8
karşılaştırmaları da yeniden hesaplanmalıdır. Yeni koşuyu ayrı bir klasöre yaz, bu klasörü bozma.
