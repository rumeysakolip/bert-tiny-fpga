# Adım 5d — ortak çekirdek, sabit çizelge, uçtan uca (12 Kasım 2026)

## Yapı
Bayt akışı → akış ayrıştırıcı (CRC-16/CCITT-FALSE, bias ve çarpanlar gömülü: panel = K×8 bayt + 2 bayt CRC) → sabit çizelge (`cizelge_ortak.v`) → ortak çekirdek (`ortak_cekirdek.v`: tek 8×8 dizi, tek yeniden ölçekleme, Softmax, LayerNorm, 48 KB bellek, iki okuma portu). Üst modül `ortak_ust.v`.

## Çizelge (komutsuz)
Katman başına 14 satır: Q(2 baş), K(2 baş), V(devrik), Q·Kᵀ+Softmax ve P·V (her baş), çıkış doğrusalı, LayerNorm 1, ileri besleme 1 (GELU), ileri besleme 2, LayerNorm 2. Son katmandan sonra 2 satır: pooler (tanh, yalnız ilk token), sınıflandırıcı (2 çıkış 8'e tamamlı, tek panel), sonra karar (iki puanın karşılaştırılması).
Akıştaki panel sırası çizelge sırasıyla aynıdır (Q 16, K 16, V 16, çıkış 16, ileri besleme 1: 64, ileri besleme 2: 16 panel; son katmandan sonra pooler 16, sınıflandırıcı 1).

## Bellek yerleşimi (1024 sözcüklük birimler)
0 katman girdisi ve çıkışı; 1 Q (iki baş) ve çıkış doğrusalı; 2 K; 3 V (devrik); 4 olasılıklar (tek baş); 5 bağlam ve LayerNorm 1 ham çıkışı; ileri besleme 1 çıkışı birim 1–4. Q·Kᵀ ve P·V'de iki işlenen farklı birimlerdedir (okuma portu çakışması yok).

## Alınan kararlar
- GELU ve ileri besleme 2 girdi ölçeklemesi tek tabloda (altın modelle 131 072/131 072 eşit): ek geçiş yok.
- Altın modelin ikinci LayerNorm'u birinci LayerNorm'un yeniden ölçeklenmemiş çıkışını kullandığından LayerNorm ham çıkışı ikinci bölgeye de yazılır.
- Altın modelin ileri besleme / pooler ara vektör dosyaları zincirleme girdiyle üretilmemiştir; pooler ve sınıflandırıcı beklenen değerleri `scripts/uret_sinif_vektor.py` ile (formül ara dosyaların kendi girdileriyle birebir doğrulanarak) kurulur.
- Dolgu atlama ve Softmax hızlandırma yapılmadı: cümle başına akış 419 429 bayttır; dörtlü hatlı flaşta (~25 MB/s) ≈ 17 ms, hesap 100 MHz'de ≈ 8 ms. Darboğaz ağırlık akışıdır; hesabı kısaltmak toplam süreyi değiştirmez.

## Sonuçlar
- Benzetim (Icarus ve Vivado xsim): 2 katman, 4 cümle (uzunluklar 4, 4, 5, 6), 328 716 kontrol, 0 hata; dört cümlenin sınıfı altın modelle aynı; her cümle 817 318 çevrim civarı. Hatalı akışta (tek bit) ilk bozuk blokta CRC hatası, çizelge durur.
- Vivado (100 MHz, bağlamsız): 87 DSP, 25 blok bellek, 4 960 LUT, 6 399 kayıtçık, WNS +0,279 ns, WHS +0,059 ns.
