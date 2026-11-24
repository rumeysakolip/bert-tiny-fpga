# 01 — INT8 Nicemleme (PTQ, gerekirse QAT)

Bu dizin, FP32 modeli (`../00-FP32_Egitim/02_Model/`) INT8'e indirme adımını tutar.
Senin çalıştıracağın kısım burası.

## Danışmanın önerdiği yol

| Danışman ne dedi | Burada karşılığı |
|---|---|
| "Önce PTQ, gerekirse QAT" | Önce `00_ptq_colab.ipynb`, sonuca göre `01_qat_colab.ipynb` |
| "PyTorch'un dinamik nicelemesi donanıma uymaz" | Dinamik niceleme **kullanılmıyor** |
| "Kalibrasyonlu statik niceleme kullan" | Ölçekler kalibrasyon cümleleriyle bir kez belirlenip sabitleniyor |
| "FP32–INT8 uyuşma oranını mutlaka raporla" | Her koşu uyuşma oranını ve ayrışan cümleleri yazıyor |
| "Hedef ≤1 puan, üst sınır ≤2 puan, MLPerf ≥%99" | `02_Girdiler/kriterler.md`; her koşuda otomatik kontrol ediliyor |
| "Kayıp yüksekse artık bağlantılardaki aykırı değerlere bak" | `olcekler.json` içinde kayıt noktası başına aykırı değer istatistiği var |

**Önemli ayrım:** PTQ'da model **eğitilmez**. Eğitilmiş FP32 model alınır, kalibre edilir, nicelenir.
Gerçek "eğitim" yalnızca QAT adımında (sahte niceleme ile yeniden eğitim) vardır ve yalnız PTQ
hedefi tutturamazsa gerekir.

## Düzen

| Klasör | İçerik |
|---|---|
| `01_Kod/00_ptq_colab.ipynb` | **Buradan başla** — statik kalibrasyonlu PTQ, 6 ayar |
| `01_Kod/01_qat_colab.ipynb` | Gerekirse ikinci adım — nicelemeye duyarlı eğitim (T4 GPU) |
| `01_Kod/*.py` | `nicele_ptq.py`, `nicele_qat.py`, `nicemleme_olcut.py`, `egit_fp32.py`, `sst2_veri.py` |
| `02_Girdiler/model/` | FP32 model (00 dizininin kopyası) |
| `02_Girdiler/dogrulama_tahminleri.csv` | FP32'nin 872 cümledeki tahminleri — uyuşma oranı bununla hesaplanır |
| `02_Girdiler/kriterler.md/json` | Başarı eşikleri |
| `02_Girdiler/veri/` | Yerel `train.tsv` / `dev.tsv` — yalnızca internet kısıtlıysa. Colab'da gerek yok |
| `03_Sonuclar/` | Senin koşuların buraya (Drive'dan indirdikten sonra) |

## Niceleme şeması (kodda ne oluyor)

- **Ağırlık:** kanal başına (per-channel) simetrik INT8 → `ölçek[k] = max|W[k,:]| / 127`
- **Aktivasyon:** tensör başına (per-tensor) **sabit** ölçek; minmax ya da %99,99 yüzdelik; simetrik veya asimetrik
- **Bias:** INT32, ölçeği `aktivasyon_ölçeği × ağırlık_ölçeği` (donanımdaki birikeçle aynı)
- **Bu adımda FP32 kalanlar:** Softmax, GELU, LayerNorm, artık toplamlar, QK^T, Softmax·V, gömme tabloları

## Karar kuralı (koşu sonrası)

| Kayıp | Sonraki adım |
|---|---|
| ≤1 puan (≥711 doğru) | Hedef sağlandı → QAT gerekmez, G4'e (nonlineer bit genişliği) geç |
| 1–2 puan (≥702) | Hata analizi: hangi katman, hangi aykırı değer? Sonra QAT |
| >2 puan | QAT (`01_qat_colab.ipynb`) + katman bazlı hassasiyet analizi |

## Çıktı dosyaları (her koşu klasöründe)

| Dosya | Ne |
|---|---|
| `sonuclar.json` | Doğruluk, kayıp (puan/cümle), uyuşma oranı, ayrışan cümleler, logit farkları, ayarlar |
| `olcekler.json` | Katman katman ölçekler + aktivasyon aykırı değer istatistikleri — **donanıma gidecek tablo budur** |
| `int8_tahminleri.csv` | 872 cümlenin INT8 tahminleri ve logitleri |
| `int8_agirliklar.npz` | INT8 ağırlıklar (≈461 KB; FP32 modelin 17,5 MB'si ile karşılaştır) |

## Not: Colab'da veri farkı düzeliyor

Önceki koşularda Hugging Face'e erişilemediği için kalibrasyon cümleleri SST-2'nin 6.920 cümlelik
GitHub kopyasından alınmıştı. Colab'ın interneti var; not defteri `DATA_DIR = None` ile **gerçek GLUE
eğitim kümesini (67.349 cümle)** kullanır. Bu, raporda "veri sapması" diye yazdığımız açık maddeyi kapatır.
Sonuçlar bir-iki cümle oynayabilir — bu beklenen bir şey, raporda belirt.
