# BERT-Tiny INT8 FPGA Hızlandırıcı (Basys 3, Artix-7 XC7A35T)

BIL 401 bitirme projesi. SST-2 duygu sınıflandırması yapan BERT-Tiny modelinin çıkarımını sekiz bitlik tamsayılarla yapan, komutsuz akışlı ve tek paylaşımlı çekirdekli bir FPGA hızlandırıcısı. Cümle ve ağırlıklar kartın seri flaş belleğinden bayt akışı olarak okunur; her veri bloğunun sonunda 16 bit CRC denetlenir.

Projede anlatılan bütün çalışmaların kodu, verisi ve sonuç dosyaları bu depoda bulunur. Raporlar depoya konmamıştır. Aşağıdaki tabloda "Konu" sütunu, çalışmanın ara rapordaki bölüm numarasını gösterir.

## Önemli sonuçlar

| Ölçüt | Değer | Dosya |
|---|---|---|
| Altın model ile bit düzeyinde karşılaştırma | 328 716 kontrol, 0 hata (2 katman, 4 cümle) | `04-RTL_Komutsuz/sim/xs_ust/gunluk.txt` |
| Doğruluk (SST-2, 872 cümle) | FP32 719, INT8 718 (kayıp 0,11 puan) | `03-RTL/sim/g18_ozet.json` |
| Hesap süresi | 785 750 çevrim = 7,86 ms @100 MHz | `04-RTL_Komutsuz/sim/xs_olcum_1/gunluk.txt` |
| Cümle süresi (flaş dahil) | 70,5 ms (SCK 12,5 MHz), 20,2 ms (50 MHz) | `04-RTL_Komutsuz/notlar/KART_KULLANIM.md` |
| Kaynak (Vivado, yerleştirme+yönlendirme) | 87/90 DSP, 25/50 BRAM, 5 185 LUT, 6 605 FF | `04-RTL_Komutsuz/sentez/cikti_kart/impl_kullanim.txt` |
| Dizi boyutu deneyi (4×4, 8×8, 16×16) | 69 120 / 18 304 / 5 088 çevrim | `03-RTL/sim/g20_ozet.json` |
| İşlemci gecikmesi (i7-12650H, PyTorch FP32) | 1,53 ms (64 öğe), 0,77 ms (8 öğe) | `04-RTL_Komutsuz/notlar/islemci_gecikme_sonuc_tur*.json` |

## Dizin yapısı

| Dizin | İçerik | Konu (rapor bölümü) |
|---|---|---|
| `00-FP32_Egitim/` | FP32 BERT-Tiny eğitimi (SST-2) | 4.1, 4.2 |
| `01-INT8_Nicemleme/` | Eğitim sonrası ve eğitim sırasında niceleme (PTQ, QAT), girdi modeli | 2.2, 4.3 |
| `02-RTL_Altin_Model/` | Python altın model (tam tamsayı hat), test vektörleri üreticisi | 3.3, 4.3 |
| `03-RTL/` | İlk (komutlu) tasarım, bileşen testleri, G0–G20 deneyleri, dizi boyutu deneyi, hızlandırma notları | 3.2, 4.4 |
| `04-RTL_Komutsuz/` | **Son tasarım:** komutsuz akış, sabit çizelge, ortak çekirdek, kart üst modülü, QSPI flaş okuyucu | 3.4, 3.5, 4.4 |
| `belgeler/plan/` | Nihai plan ve yol haritası | 1.6, 8 |
| `host/` | İlk tasarımın bilgisayar tarafı (UART) betikleri | 3.2 |

### Son tasarımın (`04-RTL_Komutsuz/`) iç yapısı

| Alt dizin | İçerik |
|---|---|
| `rtl/` | Verilog: `ortak_ust.v` (akış ayrıştırıcı + çizelge + çekirdek), `cizelge_ortak.v`, `ortak_cekirdek.v`, `kart_ust.v`, `kart_mantik.v`, `qspi_okuyucu.v` ve alt modüller; gömülü sabit tablolar (`*.mem`) |
| `tb/` | Test düzenekleri (altın model karşılaştırması, hata enjeksiyonu, flaş modeli) |
| `scripts/` | Akış ve vektör üreticileri, regresyon koşturucuları, işlemci gecikme ölçümü |
| `vektor_*/` | Altın modelden üretilen test vektörleri ve flaş akışı (`vektor_akis/`) |
| `sim/` | Benzetim günlükleri ve çıktıları |
| `sentez/` | Vivado betikleri (`kart_uret.tcl` vb.), kısıt dosyası, kullanım ve zamanlama raporları, kart bit dosyası ve flaş imajı (`cikti_kart/`) |
| `vivado/` | Vivado xsim toplu çalıştırma betikleri (`sim_*.bat`) |
| `notlar/` | Mimari notları, kart kullanım kılavuzu, işlemci ölçüm sonuçları |

## Çalıştırma

Gerekenler: Python 3 (`requirements.txt` dosyaları ilgili dizinlerde), Icarus Verilog, Vivado 2025.1 (hedef çip `xc7a35tcpg236-1`).

```bash
# Altın model ve test vektörleri
cd 02-RTL_Altin_Model/01_Kod && python 04_test_vektoru_uret.py

# Komutsuz tasarım regresyonu (Icarus Verilog)
cd 04-RTL_Komutsuz && python scripts/kos_komutsuz.py

# Kart tasarımını Vivado ile üret (sentez, yerleştirme, bitstream, flaş imajı)
cd 04-RTL_Komutsuz && vivado -mode batch -source sentez/kart_uret.tcl
```

Kartta çalıştırma adımları ve anahtarların anlamı: `04-RTL_Komutsuz/notlar/KART_KULLANIM.md`.

## Kaynaklar

1. Anthropic, Claude (yapay zekâ asistanı), yardımcı araç olarak kullanılmıştır.
2. J. Devlin, M.-W. Chang, K. Lee, K. Toutanova, "BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding," NAACL-HLT 2019.
3. I. Turc, M.-W. Chang, K. Lee, K. Toutanova, "Well-Read Students Learn Better," arXiv:1908.08962.
4. R. Socher vd., "Recursive Deep Models for Semantic Compositionality Over a Sentiment Treebank," EMNLP 2013 (SST-2).
5. Z. Li, "Dataflow & Tiling Strategies in Edge-AI FPGA Accelerators," arXiv:2505.08992.
6. R. Li, S. Chen vd., KV260 üzerinde döşemeli matris çarpımı hızlandırıcısı, arXiv:2503.16731.
7. Z. Liu, Z. Ren, P. Yin vd., Swin Transformer FPGA hızlandırıcısı.
8. SwiftTron, IJCNN 2023.
9. I-ViT, ICCV 2023.
10. Ling vd., AIoT 2024.
11. QUARK, ICCAD 2025.
12. A. Vaswani vd., "Attention Is All You Need," NIPS 2017.
13. B. Jacob vd., "Quantization and Training of Neural Networks for Efficient Integer-Arithmetic-Only Inference," CVPR 2018.
14. Intel, Core i7-12650H işlemci özellikleri (Intel ARK).



## Lisans ve atıf

Depo, proje tamamlandığında lisanslanacaktır; `LICENSE` dosyası henüz eklenmemiştir. Kullanılan üçüncü taraf varlıkların kendi lisansları geçerlidir:
- SST-2 veri kümesi (Stanford Sentiment Treebank) ve önceden eğitilmiş BERT-Tiny modeli, kendi yayın koşullarıyla kullanılmıştır. Kullanım ve dağıtım koşulları ilgili sayfalarda belirtilmiştir.
- Telif haklı makaleler ve okul belgeleri bu depoda yer almaz.
