# Uç Cihazlar İçin FPGA Tabanlı BERT-Tiny Hızlandırıcısı

BIL 401 Bilgisayar Mühendisliği Tasarımı — Rümeysa Kolip (23010903093)
Danışman: Dr. Öğr. Üyesi Emin Güney

BERT-Tiny modelini SST-2 duygu analizi görevinde eğitip 8 bitlik tamsayıya (INT8) indirgemek ve
matris çarpımlarını FPGA üzerinde sistolik dizi ile hızlandırmak.

## Klasör yapısı

| Klasör | İçerik |
|---|---|
| `yazilim/` | Python: veri yükleme, eğitim, niceleme, referans hesaplama modeli |
| `notebooks/` | Google Colab not defterleri |
| `donanim/` | Verilog RTL, testbench'ler, Vivado projeleri |
| `deneyler/` | Deney çıktıları (sonuçlar, tahminler, grafikler) |
| `belgeler/` | Kaynak listesi, karar notları, raporlar |

## Hızlı başlangıç (Colab)

1. `notebooks/01_ortam_ve_fp32_egitim.ipynb` dosyasını Colab'da açın.
2. İlk hücredeki `REPO_URL` değerini bu deponun adresiyle değiştirin.
3. Çalışma zamanı türünü T4 GPU yapın ve tüm hücreleri çalıştırın.

Yerelde:

```bash
pip install -r requirements.txt
python yazilim/egit_fp32.py --out_dir deneyler/fp32_baz
```

## Model ve veri

- **Model:** [`prajjwal1/bert-tiny`](https://huggingface.co/prajjwal1/bert-tiny): Google'ın resmi BERT-Tiny
  (`uncased_L-2_H-128_A-2`) ağırlıklarının PyTorch'a çevrilmiş hâli. 2 katman, gizli boyut 128, 2 dikkat başı, ~4,4 M parametre.
- **Veri:** [GLUE SST-2](https://huggingface.co/datasets/nyu-mll/glue) — eğitim 67.349, doğrulama 872 cümle; 0 = olumsuz, 1 = olumlu.
  Test kümesinin etiketleri açık olmadığı için doğruluk **doğrulama kümesinde** ölçülür.
- **Referans:** Turc ve ark. (2019), BERT-Tiny SST-2 test doğruluğu %83,2.

## İlerleme

| Görev | Durum |
|---|---|
| G1 Depo yapısı | ✅ |
| G2 Colab ortamı + SST-2 | Not defteri hazır, Colab'da çalıştırılacak |
| G3 FP32 baz doğruluk | Eğitim betiği hazır, Colab'da çalıştırılacak |
| G8 INT8 eğitim sonrası niceleme | Sırada |
