# Mimari notu — hesap süresini kısaltma seçenekleri (19 Kasım 2026)

Bu not bir karar belgesidir; RTL değiştirilmedi. Sayı etiketleri: **ölçüldü** (günlük veya rapor dosyası), **hesap** (formülle), **tahmin**. Karar Rümeysa'nındır.

## Özet

Dolgu atlamadan sonra 25–32 token'lık tipik bir cümlede saf hesap süresi 3,43 ms (ölçüldü, 342 918 çevrim, 100 MHz); işlemci aynı uzunlukta 1,18–1,22 ms (ölçüldü). Fark 2,8–2,9 kat. Süre iki katmanın toplamında şöyle dağılıyor (nb=4, satır sürelerinden): matris çarpımları 233 714 çevrim (yüzde 68; bunun 142 618'i ileri besleme katmanı), LayerNorm 86 708 (yüzde 25), Softmax yaklaşık 19 480 (yüzde 6), pooler ve sınıflandırıcı 3 015. Matris çarpımları tek 8×8 dizide 64 çarpma/çevrim hızıyla ve yaklaşık yüzde 90 verimle çalışıyor; yani süre dizinin boyutuna bağlı, program hatalarına değil.

Beş seçenek inceledim. Sonuç: tek bir seçenek hedefi tutturmuyor. Hedefe (≈ 1,2 ms) yaklaşmak için LayerNorm yeniden düzenlemesi, ek LUT çarpmalı diziler ve saat artırımı birlikte gerekiyor; en iyi senaryoda bile işlemciyle başa baş (hesap, belirsizlik büyük). 64 token'da Basys3 ile işlemciyi geçmek bu seçeneklerle görünmüyor; orada Vivado çıktılarıyla büyük FPGA göstermek gerekecek. Önerim: önce LayerNorm'u (düşük risk), sonra ek LUT dizisini bir sentez deneyiyle (bu not için yaptım) ve saat çalışmasıyla birlikte değerlendirmek.

## Mevcut durum (nb=4 için; iki katman, bir cümle)

Satır süreleri `sim/xs_saf_1_1/gunluk_kume_2_32_49.txt` günlüğünden (ölçüldü): Q ve K dört satır 4 773'er, V 9 399, çıkış doğrusalı 9 389, Q·Kᵀ+Softmax 6 414'er (iki baş), P·V 2 290'ar, LayerNorm 21 933 ve 21 421, ileri besleme 1 37 344, ileri besleme 2 33 965; katman toplamı 169 951.

Kaynak kullanımı (ölçüldü, `ortak_ust`): 87 DSP (64 dizi, 4 yeniden ölçekleme, 7 Softmax, 12 LayerNorm), 5 060 LUT, 6 450 yazmaç, 25 blok bellek. Boş: 3 DSP, 15 740 LUT, 25 blok bellek.

## Seçenek A — LayerNorm: satırları üst üste bindirmek ve kareler toplamını yükleme sırasında biriktirmek

Bir LayerNorm satırı ≈ 683 çevrim sürüyor (ölçüldü: 43 725 ÷ 64). Aşamaları koddan çıkarıldı (hesap): iki akışın (x ve a) ortak yeniden ölçekleme devresinden geçişi 256 çevrim (tek devre, çevrimde bir eleman), sonra ortalama 1, kareler toplamı 130, varyans 1, karekök 60 (yineleme başına 3 çevrim), ters değer 37, elemanları akıtma 128, boşaltma 11, blok yazma payı 16. Bu aşamalar sırayla çalışıyor: yükleme sırasında LayerNorm birimi boşta, hesap sırasında yükleme devresi boşta.

İki değişiklik önerilir:
- Kareler toplamını yükleme sırasında biriktirmek. Ortalama tamsayı olduğundan Σ(q−m)² = Σq² − 2mΣq + 128m² tamsayıda tam eşittir; yani sonuç bit-birebir aynı kalır, ayrı 130 çevrimlik geçiş kalkar (kazanç ≈ 130 çevrim/satır, hesap). Bunun için yükleme yolunda bir karesini alma (1 DSP, 3 boş DSP içinde) ve sonda iki küçük çarpma gerekir.
- Bir sonraki satırın yüklenmesini mevcut satırın hesabıyla örtüştürmek (giriş tamponu iki kopya; küçük bir bellek). Ortak yeniden ölçekleme devresi satır başına yaklaşık 384 işlem (256 giriş + 128 çıkış) yaptığından süre bu devreyle sınırlanır.

Beklenen satır süresi ≈ 400 çevrim (tahmin; 683'ten yaklaşık yüzde 41 kısa). nb=4'te LayerNorm 86 708 → ≈ 51 200, yani ≈ 35 500 çevrim kazanç (tahmin). Maliyet: küçük (birkaç yüz LUT, bir DSP, iki küçük bellek). Risk: orta; LayerNorm denetim durumları yeniden yazılır, altın modelle bit-birebir testler (4 LayerNorm × cümle) hazır, yeniden kullanılabilir. İkinci bir yeniden ölçekleme devresi LUT'ta (≈ 1 000 LUT, DSP yok) satırı ≈ 250 çevrime indirebilir (tahmin, denenmedi).

## Seçenek B — Softmax

Satır başına ≈ 3L+58 çevrim (L = anahtar sayısı; nb=4'te 154; ölçüldü: 16 010/64 = 250 L=64 için). Giriş yükleme ile hesabın üst üste bindirilmesi ≈ yüzde 25 kazandırabilir; nb=4'te en çok ≈ 5 000 çevrim (tahmin). Katkısı küçük; diğer işlerden sonra değerlendirilir.

## Seçenek C — Ek 8×8 çarpma dizileri, çarpmalar LUT'ta (DSP kullanmadan)

Matris çarpımları çevrimin yüzde 68'i; tek yol çarpma sayısını artırmak. DSP kalmadığı için çarpmaları LUT'ta yapan ek dizi fikri. Bunu ölçmek için tek başına bir 8×8 dizi (dizi başına 64 işlem elemanı, 9×8 bit çarpma, 32 bit biriktirici, çarpma LUT'ta) sentezledim (`sentez/deney/lut_dizi_deneme.v`, `sentez_lut_dizi.tcl`; tasarıma bağlı değil):
- **Ölçüldü (100 MHz, yerleştirme sonrası):** 6 271 LUT, 3 000 yazmaç, 0 DSP, WNS +1,204 ns (en kötü yol 8,77 ns, çarpma ve biriktirme tek çevrimde). İşlem elemanı başına yaklaşık 98 LUT.
- Boş LUT 15 740 olduğundan en fazla iki ek dizi sığar (toplam LUT ≈ 17 600, yüzde 85; yerleşim ve yönlendirme riski yüksek). Bir ek dizi ≈ yüzde 30 doluluk ekler.

Ek diziler aynı aktivasyon akışını paylaşıp farklı ağırlık panellerini aynı anda işler (çıkış panelleri paralel). Üç kısıt:
- **Yeniden ölçekleme darboğazı (önemli):** Çıkış aşaması tile sonunda 64 elemanı tek ortak yeniden ölçekleme devresinden çevrimde bir eleman hızıyla geçiriyor. k dizi paralel çalışırsa tile başına 64k eleman gelir; K=128 satırlarında tile süresi 144 çevrim olduğundan k=3'te (192 eleman) yeniden ölçekleme sınırlayıcı olur: kazanç 3 yerine ≈ 2,25 kat; K=64 dikkat çarpımlarında (tile 80 çevrim) k=2'de bile ≈ 1,25 kat. Yani k=2 neredeyse tam 2 kat veriyor, k=3 doymaya başlıyor; ikinci bir yeniden ölçekleme devresi (LUT'ta ≈ 1 000 LUT) gerekir.
- Panel tamponu okuma portları ve gölge biriktirici (dizi başına 2 048 yazmaç) çoğalır; blok bellek yeterli (25 boş).
- Zamanlama: 100 MHz'de ek diziler tek başına rahat (yukarıdaki WNS); bütünleşik tasarımda yönlendirme baskısı belirsiz.

Hesap (nb=4, iki katman): k=2 → matris çarpımları 233 714 → ≈ 122 000; toplam ≈ 231 000 çevrim (yüzde 33 kısa). k=3 (tek yeniden ölçekleme) → toplam ≈ 211 000. Bunlar tahmin; çarpımlar paralelleşirken panel sayıları k'ya tam bölünmediğinde (Q için 8 panel, ileri besleme 2 için 16 panel) yüzde 5–10 ek kayıp beklenir.

## Seçenek D — DSP paketleme (bir DSP'de iki INT8 çarpma)

Artix-7'nin DSP48E1 bloğunda A girişi 25 bit, çıkış 48 bit. Aynı ağırlıkla iki aktivasyonu tek DSP'de çarpmak mümkün ama alt alandaki toplam üst alana taşar; K=128–512 uzunluğunda biriktirme DSP içinde yapılamaz, her çevrimde LUT'ta ayrıştırma ve iki ayrı toplayıcı gerekir. Kazanç aynı DSP ile 2 kat, ama dizi veri yolu ve bellek okuma düzeni (bir çevrimde iki token bloğu) yeniden tasarlanır; risk yüksek ve C'nin verdiği kazancı C'ye göre daha karmaşık bir yolla elde eder. Önerilmiyor.

## Seçenek E — Saat frekansını artırmak (100 → 125–150 MHz)

Tüm süreyi (çevrim sayısı aynı kalarak) oranında kısaltır, alan istemez. Mevcut en kötü yol 8,94 ns (bellek adres yolu, 9 mantık seviyesi); 150 MHz için 6,67 ns'nin altına inmek, 125 MHz için 8 ns'nin altına inmek gerekir (125 MHz'e giden yol kısa görünüyor, bellek adresi yazmaçlanırsa). Kart saati 100 MHz'dir; yeni saat MMCM ile üretilir. Yöntem: kritik yolları tek tek yazmaçlayıp yeniden sentez; her tur ≈ 6 dakika. Çevrim sayısı birkaç çevrim artar. Belirsiz kısım: DSP, blok bellek ve LayerNorm yollarının kaçının 6,67 ns'yi aşacağı henüz ölçülmedi (ilk adım yol dağılımının çıkarılması). Risk: orta; kazanç 1,25–1,5 kat (tahmin).

## Senaryolar (nb=4: 25–32 token; çevrim ve süre; hepsi tahmin, temelleri ölçüldü sayılar)

- Şimdiki durum: 342 918 çevrim, 3,43 ms @100 MHz.
- A (LayerNorm): ≈ 307 000, 3,07 ms.
- C (k=2): ≈ 231 000, 2,31 ms; k=3: ≈ 211 000, 2,11 ms.
- A + C (k=2): ≈ 195 000, 1,95 ms; A + C (k=3): ≈ 175 000, 1,75 ms.
- A + C (k=3) ve 125 MHz: 1,40 ms; 150 MHz: 1,17 ms.
- İşlemci (25–32 token): 1,18–1,22 ms.

Yani işlemciyle başa baş ancak üç şeyin hepsi (LayerNorm, ek diziler ve ≈ 150 MHz) tutarsa; her biri kendi riski olan üç ayrı çalışma. 64 token'da aynı yığın ≈ 2,3 ms verir (tahmin) ve işlemci 1,4 ms olduğundan oran ≈ 1,6; Basys3'te geçmek görünmüyor.

## Yedek plan: büyük FPGA

Çevrim modeli (tahmin): matris çarpımı çevrimi ≈ şimdiki değer ÷ dizi sayısı (8×8 dizilerle), LayerNorm ve Softmax satır sayısı kadar paralellenebilir. Örnek: XC7A200T gibi 700'ün üzerinde DSP'li bir parçada 8×8'lik ≈ 10 dizi, nb=4'te matris çarpımları 233 714 → ≈ 25 000 çevrim (hesap). LayerNorm yalnız A ile düzenlenir (≈ 51 200), Softmax ve pooler değişmez (≈ 22 500) varsayılırsa toplam yaklaşık 99 000 çevrim; 150 MHz'de ≈ 0,66 ms (tahmin). Bu durumda LayerNorm toplamın yarısı olur; büyük parçada LayerNorm satırlarının paralel işlenmesi de gerekir. Bunu kanıtlamak için hedef parçada N dizili `ortak_cekirdek` sentezi ve yerleştirmesi gerekir (DSP, zamanlama); çevrim sayısı için benzetim yeterli. Henüz yapılmadı.

## Öneri ve karar noktaları

Önerilen sıra:
1. **A (LayerNorm).** Düşük risk, nb ile doğrusal ölçeklenen kazanç, DSP bütçesi içinde; testler hazır.
2. **C (k=2).** Önce bütünleşik bir sentez deneyi (iki dizi + paylaşılan yeniden ölçekleme) ile LUT ve zamanlamayı ölçmek; sonra uygulamak.
3. **E (saat).** Önce yol dağılımını çıkarmak; kaç yolun 6,67 ns'yi aştığına göre karar.
4. **Yedek plan** (büyük FPGA) ile paralel hazırlık: N dizili sentezi bu çalışmalardan bağımsız yapılabilir.

Karar gereken noktalar: (a) A'dan başlayalım mı? (b) C'yi bütünleşik sentez deneyiyle mi başlatalım? (c) Büyük FPGA planı için hedef parça seçimi (ör. hangi Xilinx parçasına göre rapor edeceğiz?).

## Hâlâ belirsiz

- A'nın satır süresi (400 çevrim) bir tahmin; yeniden ölçekleme devresinin satır başına gerçek işlem sayısı kodla doğrulanmadı.
- C'nin ölçümü tek başına dizi; bütünleşik tasarımda LUT ve zamanlama farklı olabilir.
- İşlemci tarafı dalgalı ölçüldü (D09); karşılaştırma oranları bu aralıkla birlikte okunmalı.
- 150 MHz LUT dizisi sentezi (ölçüldü): çarpma ve biriktirme tek çevrimde bırakıldığında 6 790 LUT, WNS −0,987 ns (en kötü yol 7,63 ns, 12 mantık seviyesi); yani 150 MHz için LUT çarpmalı elemanların boru hattına bölünmesi (ek yazmaç, ek gecikme çevrimi) gerekir. Boru hattı eklenmiş sürüm denenmedi. Bu nedenle 150 MHz senaryosu LUT dizisiyle birlikte olduğunda ek bir tasarım işi içerir.
