# Deney raporu — BERT-Tiny hızlandırıcısında hesap süresi çalışması (16–24 Kasım 2026)

Bu belge, `notlar/DENEY_KAYDI.md` içindeki ham deney kayıtlarının (D01–D20) rapor biçiminde özetidir. Sayıların hepsi bu depodaki betiklerle yeniden üretilebilir
(`scripts/`), her sayının kaynağı aşağıda belirtilmiştir. **Önemli sınırlama: bütün FPGA süreleri Vivado xsim benzetiminden ve sentez raporlarından gelir; kartta (donanımda)
ölçüm yapılmamıştır.** Kart elde bulunmadığı ve maliyeti yüksek olduğu için benzetim sonuçlarıyla ilerlenmiştir. İşlemci süreleri gerçek ölçümdür.

## 1. Amaç ve ölçüt
Bilgisayar–FPGA iletişim süresi ve ağırlık akışı hariç, yalnızca FPGA'nın hesap süresi; işlemciyle aynı cümle uzunluğunda karşılaştırılır. Önce Basys 3 (XC7A35T) ile
işlemciyi geçmek denenmiş; geçilemeyince daha büyük bir FPGA (XC7A200T), daha büyük/paralel dizi ve yonga içi ağırlık belleği ile "üst model" benzetimde gösterilmiştir.
İşlemci, modeli önceden yüklenmiş (ısınmış) bir PyTorch FP32 çıkarımıdır; üst modelde de ağırlıklar yonga içi bellekte hazır varsayılır (açılışta flaştan yüklenir, çıkarım süresine girmez).

## 2. Yöntem
- **Süre ölçümü:** `tb/tb_ortak_ust.v` süre kipi; "saf hesap" = aktivasyon bloğunun denetim kodunun doğrulandığı çevrimden sonuç darbesine kadar. 100 MHz varsayımıyla ms'ye çevrilmiştir. Her ölçüm tek cümle (ilk cümle).
- **Doğruluk:** her yapılandırma, nb = 1…8 blok sayısını kapsayan dokuz uzunluk (8, 9, 16, 24, 25, 32, 40, 48, 49, 56, 57, 64 belirteç) üzerinde altın modelle bit bit karşılaştırılmıştır (0 hata, sınıflar doğru). 8–49 belirteçlik cümleler gerçek SST-2 cümleleridir; 56, 57 ve 64 belirteçlik girdiler 54–55 belirteçlik cümlelerin dikkat maskesi uzatılarak üretilmiştir (`scripts/uret_dolgu_vektorleri.py`).
- **Sentez:** Vivado 2025.1, bağlamsız, yerleştirme ve yönlendirme sonrası rapor (`sentez/raporlar_son/`).
- **İşlemci:** i7-12650H, PyTorch FP32, 1 ve 10 iplik, `scripts/olc_islemci_token.py`; üç/dört koşu; ölçüm iki seviyeli dalgalandığından (1–1,6 ms ve 3–6 ms) en iyi ortalama alınmıştır.

## 3. Yapılan tasarım değişiklikleri
1. **Ölçüm kipi** (`HIZLI_OLCUM`) ve **dolgu atlama** (`DOLGU_ATLA`): cümlenin gerçek blok sayısı kadar hesap; 64 belirteçte 7,16 ms → LayerNorm iyileştirmesiyle 6,84 ms (Basys 3).
2. **LayerNorm**: varyans, yükleme sırasında biriken kareler toplamıyla (satır başına −126 çevrim; çarpım zamanlama için iki yarıma bölündü).
3. **Paralel doğrusal hatlar** (`NA`): her hat bir paneli hesaplar; kendi ağırlık bankası, panel tamponu, dizisi, yeniden ölçekleme devresi.
4. **Paralel LayerNorm** (`LN_PAR`): bir bloğun 8 satırı 8 hatta; **paralel Softmax** (`SMP`); **dikkat 8 hatta** (`ATTP`).

## 4. Sonuçlar
### 4.1 Saf hesap süresi (ms, 100 MHz; FPGA: benzetim, işlemci: ölçüm)
| Yapılandırma | 8 | 16 | 24 | 32 | 40 | 48 | 56 | 64 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| İşlemci, en iyi ölçüm | 0,99 | 1,12 | 1,20 | 1,22 | 1,36 | 1,33 | 1,36 | 1,40 |
| İşlemci, en kötü ölçüm | 4,16 | 4,08 | 4,20 | 4,29 | 4,71 | 5,19 | 5,42 | 6,17 |
| Basys 3 (1 dizi) | 0,86 | 1,64 | 2,44 | 3,27 | 4,12 | 4,99 | 5,90 | 6,84 |
| 2 hat | 0,71 | 1,16 | 1,69 | 2,25 | 2,83 | 3,43 | 4,07 | 4,75 |
| 8 hat, yalnız doğrusal paralel | 0,42 | 0,73 | 1,06 | 1,42 | 1,79 | 2,19 | 2,64 | 3,11 |
| 8 hat + LayerNorm + Softmax paralel | 0,25 | 0,37 | 0,50 | 0,64 | 0,79 | 0,95 | 1,14 | 1,33 |
| **Üst model**: 8 hat + LayerNorm + Softmax + dikkat paralel | 0,24 | 0,34 | 0,45 | 0,56 | 0,67 | 0,78 | 0,90 | 1,02 |

İşlemci süresi FPGA süresine oranı (1'den büyük: FPGA daha hızlı):

| Belirteç | 8 | 16 | 24 | 32 | 40 | 48 | 56 | 64 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| İşlemci ÷ üst model | 4,10 | 3,29 | 2,68 | 2,19 | 2,04 | 1,72 | 1,52 | 1,37 |
| İşlemci ÷ Basys 3 | 1,16 | 0,68 | 0,49 | 0,37 | 0,33 | 0,27 | 0,23 | 0,20 |

![Süre ve cümle uzunluğu](notlar/gorseller/g14_sure_uzunluk.png)

![İşlemci ÷ FPGA süresi](notlar/gorseller/g15_hizlanma.png)

**Kesişim noktaları** (`notlar/sonuclar/kesisim.txt`): Basys 3 ≈ 10 belirteçe kadar işlemciden hızlı; 2 hat ≈ 15; 8 hat yalnız doğrusal paralel ≈ 27; 8 hat + paralel LayerNorm ve Softmax ve üst model 8–64'ün hepsinde (ilkinde 64 belirteçte yalnızca başa baş: 1,33 ms, işlemci 1,40 ms).

### 4.2 Hat sayısıyla ölçekleme
![Hat sayısı ve süre](notlar/gorseller/g16_hat_olcekleme.png)

### 4.3 Süre dökümü (çevrim)
| Yapılandırma | Belirteç | Doğrusal | İleri besleme | Dikkat | LayerNorm | Son | Toplam (çevrim) |
|---|---:|---:|---:|---:|---:|---:|---:|
| Basys 3 (1 dizi) | 32 | 75 760 | 142 618 | 34 816 | 70 452 | 3 015 | 326 662 |
| 2 paralel dizi | 32 | 42 382 | 74 598 | 34 816 | 70 452 | 2 649 | 224 898 |
| 8 paralel dizi | 32 | 13 358 | 21 570 | 34 816 | 70 452 | 1 434 | 141 631 |
| 8 dizi + LayerNorm + Softmax paralel | 32 | 13 358 | 21 570 | 17 952 | 9 940 | 1 434 | 64 255 |
| 8 dizi + hepsi paralel | 32 | 13 370 | 21 570 | 9 276 | 9 940 | 1 434 | 55 591 |
| Basys 3 (1 dizi) | 64 | 149 488 | 283 930 | 107 152 | 140 340 | 3 015 | 683 926 |
| 2 paralel dizi | 64 | 79 246 | 145 254 | 107 152 | 140 340 | 2 649 | 474 642 |
| 8 paralel dizi | 64 | 22 574 | 39 234 | 107 152 | 140 340 | 1 434 | 310 735 |
| 8 dizi + LayerNorm + Softmax paralel | 64 | 22 574 | 39 234 | 50 896 | 19 316 | 1 434 | 133 455 |
| 8 dizi + hepsi paralel | 64 | 22 586 | 39 234 | 19 132 | 19 316 | 1 434 | 101 703 |

![Süre dökümü](notlar/gorseller/g17_sure_dokumu.png)

### 4.4 Sentez ve yerleştirme
| Tasarım | Parça | Saat (MHz) | DSP | LUT | Blok bellek (karo) | WNS / WHS (ns) |
|---|---|---:|---:|---:|---:|---:|
| Basys 3 son tasarım (`ortak_ust_basys3`) | XC7A35T | 100 | 88 (%97,8) | 5 662 (%27,2) | 25,0 (%50,0) | 0,418 / 0,039 |
| Kart üst modülü (`kart_ust`) | XC7A35T | 100 | 88 (%97,8) | 5 928 (%28,5) | 25,0 (%50,0) | 0,357 / 0,019 |
| Üst model (`ortak_ust_ustmodel`) | XC7A200T | 100 | 720 (%97,3) | 34 217 (%25,6) | 251,5 (%68,9) | 0,221 / 0,046 |
| Üst model | XC7A200T | 125 | 720 (%97,3) | 34 633 (%25,9) | 251,5 (%68,9) | -0,517 / 0,060 |
| Üst model | XC7A200T | 150 | 720 (%97,3) | 35 160 (%26,3) | 251,5 (%68,9) | -1,484 / 0,055 |
| 8 hat + LayerNorm + Softmax (dikkat seri) | XC7A200T | 100 | 720 (%97,3) | 33 213 (%24,8) | 223,5 (%61,2) | 0,370 / 0,065 |
| 2 hat (LayerNorm ve Softmax seri) | XC7A100T | 100 | 156 (%65,0) | 20 456 (%32,3) | 145,5 (%107,8) | — |

XC7A100T denemesi sığmadı (blok bellek %107,8): ağırlıklar tek başına ≈ 410 KB (≈ 91 karo). XC7A200T'de 125 MHz (WNS −0,517 ns) ve 150 MHz (WNS −1,484 ns) tutmadı; yönlendirmede tutan en yüksek saat ≈ 117 MHz olarak kestirildi (iki başarısız koşudan; 100–117 MHz arası kısıtla yerleştirme yapılmadı).

![Kaynak kullanımı](notlar/gorseller/g18_kaynak_kullanimi.png)

![Saat etkisi](notlar/gorseller/g20_saat_etkisi.png)

### 4.5 Ağırlık akışı
Ağırlıklar flaştan her cümlede akıtılırsa süre flaş hızıyla sınırlanır (dört hatlı flaş: 12,5 MHz'de ≈ 66 ms, 100 MHz'de ≈ 8 ms; hesap); bu yüzden üst modelde ağırlıklar yonga içindedir.

![Ağırlık akışı](notlar/gorseller/g19_agirlik_akisi.png)

## 5. Sınırlar ve dürüst notlar
- Kartta ölçüm yok; süreler benzetim çevrimlerinin 100 MHz ile çevrilmesidir. Saat sınırı (≈ 117 MHz) kestirimdir.
- XC7A200T sentezi, LayerNorm çarpımının son boru hattı bölünmesinden önceki RTL ile yapıldı (yalnız boru hattı ekleyen bir değişiklik; yeniden sentezlenmedi).
- Süre ölçümleri ilk cümle ile; 56–64 belirteçlik üç girdi maske uzatmasıyla üretilmiştir.
- İşlemci ölçümü dalgalıdır (en iyi ortalama alındı); üst modelin 64 belirteçteki 1,4 kat avantajı bu seçime duyarlıdır.
- Güç ve enerji ölçülmemiştir.
- Ağırlıkların yonga içinde olduğu varsayımı XC7A100T ve Basys 3'e sığmaz.
