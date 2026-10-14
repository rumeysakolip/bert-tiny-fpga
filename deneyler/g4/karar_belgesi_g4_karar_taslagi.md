# G4 — Softmax / GELU / LayerNorm hassasiyet kararı

Durum: **tamamlandı (14 Ekim 2026).** Karar iki düzeyde doğrulandı: (1) gerçek model aktivasyonlarıyla işlem düzeyinde sayısal hata,
(2) Linear katmanları INT8 PTQ olan modelde üç nonlineer işlem tamsayıya geçirilerek SST-2 doğruluğu (aşağıda). Kapsam sınırı: gömme tabloları,
residual toplamlar, QK^T ve Softmax·V matris çarpımları FP32 bırakıldı; bu sonuçlar bu üç işlemin etkisidir, tam tamsayı hattın doğruluğu değildir.

Kanıt
- `yazilim/ibert_hata_analizi.py` → `g4_hata_analizi.json`: RASTGELE girdi (önceki taslak).
- `yazilim/ibert_gercek_aktivasyon.py` → `g4_gercek_aktivasyon.{json,md}`: G3 FP32 modeli (SST-2, doğrulama 872 cümle, yalnızca
  dolgu olmayan token'lar) üzerinde forward hook ile kaydedilen GELU girdileri (2 katman × ~11,2 M değer), dikkat skorları
  (2 katman × ~1,29 M satır-eleman) ve 5 LayerNorm girdisi (~2,8 M değer). Yüklenen model doğrulandı: %82,45, G3 tahminlerinden 0/872 fark.
- `yazilim/ibert_uctan_uca.py` → `g4_uctan_uca/`: aynı model, Linear INT8 (nicele_ptq.py şeması) + tamsayı GELU/Softmax/LayerNorm; 3 kalibrasyon seed'i.
- Niceleme: kayıt noktası başına statik maks-mutlak ölçek (tüm doğrulama kümesi), yani aykırı değerler ölçeği belirler.
  Hatalar FP64 referansa göredir (LayerNorm: γ,β uygulanmamış normalize çıktı üzerinden; γ,β'lı hata da JSON'da).

## Karar tablosu (rastgele ve gerçek girdi yan yana)

| İşlem | Ölçüt | Rastgele girdi (eski taslak) | GERÇEK aktivasyon (en kötü katman/nokta) | Karar |
|---|---|---|---|---|
| GELU | maks hata, girdi 8 / 12 / 16 / 22 bit | 0,048 / 0,020 / 0,018 / — | **0,075 / 0,021 / 0,0183 / 0,0182** | Girdi **12 bit**. 16 bitten sonra kazanç yok: ~0,018'lik taban i-erf polinomunun kendi hatası. 8 bit gerçekte rastgeleden kötü (4× taban) |
| Softmax | argmax uyuşması, çıkış 16 bit; girdi 8 / 12 / 16 / 22 | %97,5 / %99,8 / %99,98 / — | **%98,05 / %99,86 / %99,99 / %99,99** | Girdi **12 bit** yeterli, 16 bit pay bırakır; **çıkış 16 bit** |
| Softmax | satır toplamı, çıkış 8 bit | ort ≈0,89–0,91 | **ort ≈0,90, en kötü satır 0,72** | 8 bit çıkış yalnızca yeniden normalizasyon/yuvarlama ile; aksi hâlde çıkış 16 bit. 16 bit çıkışta satır toplamı 0,9988–0,9995 |
| Softmax | maks mutlak hata, girdi/çıkış 16/16 | 0,00087 | **0,00087** | — |
| LayerNorm | maks hata, girdi 8 / 12 / 16 / 22 | — / 0,0127 / 0,0008 / ~0 | **1,15 / 0,063 / 0,0040 / 0,00008** | Girdi **16 bit**. 12 bit gerçekte 5× kötü (0,063), 8 bit kullanılamaz |
| LayerNorm | RMS hata, 12 / 16 / 22 bit | 0,0022 / 0,00014 / 0,00002 | **0,0085 / 0,00052 / 0,000017** | — |
| LayerNorm | Newton karekökü, tam sonuç için sabit yineleme | 4 | **4** (16 bit; 22 bitte 5) | 4 yineleme (monoton güncelleme ile) |

Okuma notları
- Hata ölçeği için: 16 bit LayerNorm hatası (0,004 maks, 0,0005 RMS) GELU'nun kendi yaklaşım tabanının (0,018) altında kalıyor;
  bu yüzden 16 biti yeterli buluyorum. Bu bir değerlendirmedir, SST-2 doğruluk kaybıyla henüz doğrulanmadı.
- Rastgele taslak LayerNorm'da 16 bit hatasını ~5× düşük gösteriyordu (0,0008 vs 0,0040): gerçek girdide aykırı değerler ölçeği büyütüyor.

## SST-2 uçtan uca doğrulama (Linear INT8 PTQ + tamsayı nonlineerlikler)

FP32 719/872 (%82,45). Üç değer = kalibrasyon seed'leri 42/43/44 (512 eğitim cümlesi; ölçekler eğitim cümlelerinden, doğrulama kümesi kullanılmadı).
Hedef ≤1 puan = ≤8 cümle; üst sınır ≤2 puan = ≤17 cümle; MLPerf ≥712 doğru.

| Koşu | Doğru | Kayıp (cümle) | En düşük FP32–INT8 uyuşma | Hedef | MLPerf |
|---|---|---|---|---|---|
| Nonlineer FP32 (yalnız Linear INT8 PTQ) | 719/717/720 | +0/+2/−1 | %99,54 | evet | evet |
| **Öneri: GELU 12 · Softmax 12→16 · LN 16** | **717/718/720** | **+2/+1/−1** | **%99,66** | **evet** | **evet** |
| Geniş: GELU 16 · Softmax 16→16 · LN 22 | 715/717/719 | +4/+2/+0 | %99,54 | evet | evet |
| GELU 12 · Softmax 12→16 · LN 12 | 716/719/718 | +3/+0/+1 | %99,66 | evet | evet |
| Hepsi 8 bit (Softmax çıkışı 8 bit) | 698/699/694 | +21/+20/+25 | %96,22 | HAYIR | HAYIR |
| Yalnız GELU 8 bit | 715/721/720 | +4/−2/−1 | %99,54 | evet | evet |
| Yalnız Softmax 12 giriş → 8 çıkış | 711/714/709 | +8/+5/+10 | %98,62 | HAYIR | HAYIR |
| Yalnız LN 12 bit | 718/718/717 | +1/+1/+2 | %99,66 | evet | evet |
| Yalnız LN 8 bit | 706/704/704 | +13/+15/+15 | %97,36 | HAYIR | HAYIR |

Okuma
- Öneri konfigürasyonu Linear INT8 PTQ'nun üstüne anlamlı kayıp eklemiyor: 3 seed'in üçünde de hedef ve MLPerf eşiği sağlandı; farklar ±2 cümle, yani doğrulama kümesi gürültüsü (kriterler.md).
- Bozan iki ayar: **LayerNorm girdisi 8 bit** (13–15 cümle) ve **Softmax çıkışı 8 bit** (5–10 cümle; satır toplamı ≈0,9). İkisi birlikte "hepsi 8 bit" koşusunu 2 puanlık sınırın dışına taşıyor (20–25 cümle).
- Doğruluk açısından GELU 8 bit ve LayerNorm 12 bit de hedef içinde kaldı; yani 12 (GELU) ve 16 (LayerNorm) önerisi doğruluk eşiği değil, sayısal hata payı (işlem düzeyi tablo) gözetilerek verilmiştir. Bu doğrulama kümesi (872 cümle) bu iki ayarı öneriden ayıracak çözünürlüğe sahip değil.
- Doyma (kalibrasyon aralığını aşan doğrulama değeri) önemsiz: en kötü işlem için oran ≤6e-5.

## Aykırı değer dağılımı (açık nokta 1'in yanıtı)

| Kayıt noktası | min | max | p0,1 / p99,9 | maks/p99,9 | std/adım (8 / 12 / 16 bit) |
|---|---|---|---|---|---|
| GELU girdisi, katman 0 | −11,3 | 10,9 | −7,35 / 5,60 | 1,5 | 16 / 262 / 4190 |
| GELU girdisi, katman 1 | −10,8 | 6,5 | −5,55 / 3,20 | 1,9 | 15 / 238 / 3810 |
| Dikkat skoru, katman 0 | −6,1 | 9,4 | −4,12 / 6,24 | 1,5 | 21 / 333 / 5330 |
| Dikkat skoru, katman 1 | −11,2 | 10,4 | −5,66 / 8,42 | 1,3 | 24 / 389 / 6220 |
| LN girdisi, gömme | −1,02 | 0,36 | −0,37 / 0,20 | 2,8 | 8,3 / 134 / 2150 |
| LN girdisi, K0 dikkat çıkışı (residual) | −12,0 | 9,7 | −5,95 / 5,08 | 2,0 | 17 / 271 / 4340 |
| **LN girdisi, K0 FFN çıkışı (residual)** | **−28,9** | 10,1 | −9,57 / 4,37 | **3,0** | **6,6 / 106 / 1700** |
| LN girdisi, K1 dikkat çıkışı (residual) | −12,7 | 10,2 | −5,47 / 5,81 | 2,2 | 17 / 278 / 4450 |
| LN girdisi, K1 FFN çıkışı (residual) | −6,0 | 5,5 | −3,89 / 3,82 | 1,5 | 27 / 434 / 6950 |

- En belirgin aykırı değer: gizli boyut **2** (gömme, K0 dikkat ve K0 FFN LayerNorm girdilerinde en büyük |değer|; K0 FFN'de −28,9).
  Bu kanal std'nin 19 katı; 12 bitte tipik değer yalnız ~106 adıma yayılıyor, 8 bitte ~7 adıma. 16 bitte 1700 adım: yeterli.
- Dikkat skorları ve GELU girdisi |değer| ≤ ~11 civarında; aykırı değer oranı (maks/p99,9) ≤ 2.
- Dolgu token'ları hariç tutuldu. Sabit uzunlukta (64) donanım dolgu konumlarını da işleyecekse, bu konumların dağılımı ayrıca bakılmalı.

## Donanım maliyeti (yalnızca niteliksel)

- Sayısal LUT/DSP/gecikme tahmini yapılmadı.
- En pahalı adımlar bölme ve karekök: Softmax'ta satır toplamıyla bölme, LayerNorm'da normalizasyon bölmesi ve Newton karekökü
  (4 yinelemenin her biri bir bölme içerir). GELU ve i-exp yalnızca küçük polinom (çarpma/toplama) ve kaydırma gerektirir.
- Girdi bit genişliği kararı (12 vs 16) çarpıcı genişliğini ve bellek yolunu etkiler; ayrıntılı kaynak tahmini sentez sonrası.

## Açık noktalar
1. Kapsam: QK^T, Softmax·V, residual toplam ve gömme tablolarının INT8/tamsayı yapılması ayrıca ölçülmeli; mevcut sonuçlar bunları FP32 varsayar.
2. Alternatif (üç işlemi FP32/FP16 bırakmak) doğruluk açısından denendi: fark gürültü düzeyinde (tablonun ilk iki satırı), yani doğruluk bu seçimi ayırt etmiyor. Karar kaynak kullanımına (sentez sonrası) göre verilecek.
3. Statik ölçek maks-mutlak alındı (en kötü durum). Yüzdelik kırpma (örn. p99,99) denenmedi.
4. Kalibrasyon cümleleri GLUE eğitim kümesi yerine SST-2'nin GitHub'daki cümle düzeyi kopyasından (6920 cümle, clairett/pytorch-sentiment-classification) alındı; Hugging Face'e erişilemedi.

Kaynak: Kim ve ark., 2021, I-BERT: Integer-only BERT Quantization (https://arxiv.org/abs/2101.01321)
