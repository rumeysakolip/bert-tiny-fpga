# BERT-Tiny INT8 FPGA Hızlandırıcısı

BIL 401 bitirme tasarımı. BERT-Tiny modelinin SST-2 duygu sınıflandırma görevindeki çıkarımı INT8
tamsayı aritmetiğine indiriliyor ve matris çarpımları FPGA üzerinde çıkış-sabit bir sistolik dizi ile
hızlandırılıyor. Depo; eğitim ve niceleme betiklerini, deney çıktılarını, RTL kaynaklarını ve raporları içerir.

## Durum (15 Ekim 2026)

| Aşama | Durum | Sonuç |
|---|---|---|
| FP32 baz eğitimi | tamamlandı | 719 / 872 = %82,45 |
| Statik INT8 PTQ (6 ayar) | tamamlandı | 716–718 doğru, kayıp 0,11–0,34 puan; hedef ve MLPerf eşiği sağlandı |
| Softmax/GELU/LayerNorm bit genişliği (I-BERT) | tamamlandı | GELU 12 bit · Softmax 12→16 bit · LayerNorm 16 bit · 4 Newton yinelemesi |
| QAT (ön koşular, CPU) | kısmi | 710–712 doğru; PTQ'dan geride, zorunlu değil |
| PE + 4×4 sistolik dizi (RTL) | tamamlandı (benzetim) | PE 1012 kontrol / 0 hata; dizi 264 test / 0 hata; 10 hesap çevrimi |
| Sentez, kart üzerinde çalıştırma | yapılmadı | — |

Başarı ölçütleri: hedef ≤1 puan kayıp (≥711 doğru), üst sınır ≤2 puan (≥702), MLPerf eşiği ≥712.
872 cümlelik kümede 1 puan ≈ 8,72 cümledir; 1–2 cümlelik farklar gürültü sayılır.

## Dizin yapısı

| Dizin | İçerik |
|---|---|
| `yazilim/` | Eğitim, niceleme ve analiz betikleri (`egit_fp32.py`, `nicele_ptq.py`, `nicele_qat.py`, `ibert_*.py`, `hesap_yuku_analizi.py`) |
| `notebooks/` | Colab not defterleri: FP32 eğitim, INT8 PTQ, QAT |
| `deneyler/fp32_baz/` | FP32 sonuçları, eğitim günlüğü, 872 cümlenin tahminleri, başarı ölçütleri |
| `deneyler/int8_ptq/` | PTQ koşuları — kalibrasyon SST-2'nin GitHub kopyasından (6.920 cümle) |
| `deneyler/int8_ptq_gercek_glue/` | PTQ koşuları — kalibrasyon gerçek GLUE eğitim kümesinden (67.349); iki kaynağın karşılaştırması |
| `deneyler/g4/` | Softmax/GELU/LayerNorm hassasiyet analizi ve uçtan uca doğruluk |
| `deneyler/int8_qat/` | QAT ön koşuları (CPU) ve PTQ ile karşılaştırma |
| `deneyler/hesap_yuku/` | MAC ve CPU süresi dağılımı |
| `donanim/` | Verilog kaynakları (`rtl/`), testbench'ler (`tb/`), benzetim günlükleri (`sim/`) |
| `belgeler/` | Raporlar (.docx) ve kaynakça |

Model ağırlıkları (`model.safetensors`, 17 MB) ve veri kümesi dosyaları depoda tutulmaz; Drive'da
saklanır. Dalga formları (`.vcd`) ve INT8 ağırlık arşivleri (`.npz`) yeniden üretilebilir olduğu için
depo dışıdır.

## Kurulum

```bash
pip install -r requirements.txt     # torch, transformers, datasets, numpy
```

RTL tarafı için Icarus Verilog ve GTKWave gerekir.

## Çalıştırma

FP32 eğitim (Colab, T4 önerilir):

```bash
python yazilim/egit_fp32.py --out_dir deneyler/fp32_baz --epochs 4 --lr 1e-4 --seed 42
```

INT8 PTQ (tek koşu; model `deneyler/fp32_baz/model/` konumunda olmalı):

```bash
python yazilim/nicele_ptq.py \
  --model_dir deneyler/fp32_baz/model \
  --fp32_csv  deneyler/fp32_baz/dogrulama_tahminleri.csv \
  --out_dir   deneyler/int8_ptq \
  --observer minmax --n_kalib 512
```

Altı ayarın tamamı için `notebooks/02_nicele_ptq_colab.ipynb`, QAT için `notebooks/03_nicele_qat_colab.ipynb`.

RTL benzetimi (`donanim/` dizininden):

```bash
iverilog -g2001 -Wall -o sim/tb_pe.vvp rtl/pe.v tb/tb_pe.v && vvp sim/tb_pe.vvp
iverilog -g2001 -Wall -o sim/tb_systolic_4x4.vvp rtl/pe.v rtl/systolic_4x4.v tb/tb_systolic_4x4.v && vvp sim/tb_systolic_4x4.vvp
```

## Yöntem özeti

Niceleme statik ve kalibrasyonludur: ağırlıklar çıkış kanalı başına simetrik INT8, aktivasyonlar
tensör başına sabit ölçekli INT8, bias INT32 (ölçeği aktivasyon × ağırlık). Dinamik niceleme,
ölçeği çalışma anında hesapladığı ve sabit noktalı donanıma uymadığı için kullanılmamıştır.
Ölçekler kalibrasyon cümleleriyle bir kez belirlenir; doğrulama kümesi kalibrasyonda kullanılmaz.

Şu an nicelenen işlemler 14 doğrusal katmandır. Gömme tabloları, artık toplamlar, QK^T ve Softmax·V
çarpımları FP32 kalmaktadır; bu nedenle buradaki doğruluk sayıları tam tamsayı bir hattın doğruluğu
değildir.

## Kaynaklar

Kim ve ark. (2021) I-BERT, arXiv:2101.01321 · Zafrir ve ark. (2019) Q8BERT, arXiv:1910.06188 ·
Bondarenko ve ark. (2021) arXiv:2109.12948 · Turc ve ark. (2019) arXiv:1908.08962 ·
Kung (1982) Why Systolic Architectures? · MLCommons, MLPerf Inference Rules

Ayrıntılı kaynakça: `belgeler/kaynaklar.md`
