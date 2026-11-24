# Deney kaydı — hesap süresi çalışması (16 Kasım 2026 kararından itibaren)

Bu dosya, final raporu hazırlanırken kullanılacak ham deney notlarıdır. Her kayıtta: amaç, yöntem, sonuç, yorum, dosyalar, rapora not.
Sayı etiketleri: **ölçüldü** (günlük veya rapor dosyasından), **hesap** (formülle), **tahmin**. Yeni kayıt dosyanın sonuna eklenir; eski kayıt silinmez, düzeltme gerekirse altına "Düzeltme" notu yazılır.

Çalışmanın amacı (16 Kasım 2026 kararı): bilgisayar–FPGA iletişimi hariç, yalnızca FPGA hesap süresini, işlemci ile aynı token sayısında karşılaştırmak. Önce Basys3 ile işlemciyi geçmeye çalışmak; olmazsa büyük FPGA ve büyük sistolik dizi için Vivado çıktılarıyla göstermek.

---

## D01 — Eski ölçümün (xs_olcum_1) çözümlenmesi: 785 750 çevrim neyi içeriyor?
**Tarih:** analiz 19 Kasım 2026 (ölçüm 12 Kasım 2026).
**Amaç:** Günlükteki 785 750 çevrimin saf hesap mı, yoksa ağırlık akışı beklemesini de içeren süre mi olduğunu belirlemek.
**Yöntem:** `sim/xs_olcum_1/gunluk.txt` satır başlangıç çevrimlerinden satır süreleri çıkarıldı; çekirdeğin tile modeli (tile süresi = K + 16) ile karşılaştırıldı.
**Sonuç:**
- Cümle başına 785 748 çevrim (ölçüldü) = 8 202 (aktivasyon girişi, bilgisayar tarafı) + 2 × 379 271 (katman) + 17 705 (pooler) + 1 305 (sınıflandırıcı) (ölçüldü, satır başlangıçlarından).
- Doğrusal satırlarda çekirdek, iki panel de tampona gelince başlıyor; bu yüzden her satır başında yaklaşık iki panelin akış süresi bekleniyor (Q satırı: ölçülen 11 433, tile modeli 9 216, fark 2 217 ≈ 2 × 1 026 bayt + parametre yükleme; hesap). Kararlı durumda panel başına hesap (1 152) akıştan (1 026) uzun, yani hesap sınırlı.
- Pooler ve sınıflandırıcı neredeyse tamamen akış sınırlı (pooler hesap süresi ≈ 2 304, ölçülen 17 705).
- Katman başına MAC alt sınırı (MAC ÷ 64) 212 992 çevrim (hesap); ölçülen 379 271. Fark: LayerNorm 86 426, Softmax 32 020, akış başlangıcı ve tablo yükleme 24 229, tile başı K+16 yükü 18 432, dikkat çarpımı yükü 5 172 (hesap; akış kalemi farktan çıkarıldı).
**Yorum:** Ölçüm saf hesap değildi ama akış payı küçüktü (yaklaşık yüzde 8). Asıl yük LayerNorm (yüzde 23) ve Softmax (yüzde 8,5) idi.
**Rapora not:** "Verim yüzde 56" tespiti ve kayıp dağılımı mimari değerlendirme bölümüne girebilir.

## D02 — Ölçüm kipi (HIZLI_OLCUM) ve saf hesap tabanı
**Tarih:** 19 Kasım 2026.
**Amaç:** Ağırlık paneli akışı beklenmeden hesap süresini ölçmek. Karar: ağırlıklar hızlı bellekte hazır sayılır, flaş gecikmesi eklenmez; çünkü işlemci ölçümü de modeli önceden yüklenmiş, ısınmış ve 200+ tekrarla yapıyor (modelin diskten yüklenmesi sayılmıyor).
**Yöntem:** `akis_ayristirici.v` içine `HIZLI_OLCUM` parametresi (varsayılan 0): 1 iken ağırlık paneli blokları bayt tüketmeden 1 çevrimde tamam sayılır, aktivasyon bloğu normal akar. Testbench `tb_ortak_ust.v` aktivasyon denetim kodunun doğrulandığı çevrimden `sonuc_gecerli`'ye kadar sayar ("SAF HESAP"). Ölçüm kipinde panel tamponu benzetimde sıfırlanır (başlatılmamış bellekten X yayılmasın diye). Koşturucu: `vivado/sim_ortak_ust_saf_hesap.bat <0|1>`.
**Sonuç (ölçüldü, xsim, cümle 0, 64 token'lık sabit dolgu):**
- Kip kapalı (0): toplam 785 748 çevrim (eski ölçümle birebir), saf hesap 777 553.
- Kip açık (1): saf hesap **716 438 çevrim = 7,16 ms @100 MHz**. Ön tahmin 712 000 idi (hesap), fark yüzde 0,6.
- Akış beklemesi payı 61 115 çevrim (yüzde 7,9).
- Akış beklemeyen satırlar (Q·Kᵀ+Softmax 21 394, P·V 5 394, LayerNorm 43 725 ve 42 701) iki kipte aynı: ölçüm kipi hesabı bozmuyor.
- Kip açıkken satır süreleri: Q, K 9 381; V 18 615; dikkat çıkışı 18 605; FFN1 74 208; FFN2 67 757; pooler 2 736; sınıflandırıcı 279.
- Dağılım (hesap): LayerNorm 172 852 (yüzde 24), Softmax ≈ 64 040 (yüzde 9), FFN1+FFN2 283 930 (yüzde 40), Q/K/V/çıkış doğrusalları 149 488 (yüzde 21), dikkat çarpımları 43 112 (yüzde 6), pooler+sınıflandırıcı 3 015.
**Yorum:** İşlemciye (1,53 ms, 64 token, ölçüldü) göre yaklaşık 4,7 kat yavaş (hesap). 
**Dosyalar:** `rtl/akis_ayristirici.v`, `rtl/ortak_ust.v`, `tb/tb_ortak_ust.v`, `vivado/sim_ortak_ust_saf_hesap.bat`, `sim/xs_saf_hesap_0/`, `sim/xs_saf_hesap_1/`.
**Rapora not:** Süre ölçütünün tanımı (iletişim ve ağırlık akışı hariç) ve işlemci ile eşit koşul gerekçesi burada.

## D03 — Ölçüm kipi eklendikten sonra eski regresyon ve sentez
**Tarih:** 19 Kasım 2026.
**Sonuç (ölçüldü):**
- Uçtan uca regresyon (`tb_ortak_ust`, xsim): 2 katman, 4 cümle, 328 716 kontrol, 0 hata, bellek çarpışması 0, dört cümlenin sınıfı doğru; cümle başına ≈ 817 285 çevrim (gözlem kipi).
- Sentez ve yerleştirme (`sentez/sentez_ust.tcl`, 100 MHz, bağlamsız): 4 960 LUT, 6 399 yazmaç, 25 blok bellek, 87 DSP, WNS +0,279 ns, WHS +0,059 ns. Önceki (12 Kasım) sonuçla birebir aynı: ölçüm kipi sentezde silinen sabit bir koşul.
**Rapora not:** Ölçüm amaçlı değişikliğin donanım maliyeti sıfır.

## D04 — Kart testi (tb_kart) bulguları
**Tarih:** 19 Kasım 2026.
**Bulgu 1:** Vivado proje koşusunda test "okunan bayt 7" ile hemen bitti; neden: bekleme döngüsü `!led[8] && !led[6]` koşuluyla yazılmıştı, başlangıçta X olan led değerinde döngü hemen çıkıyor olabilir (hipotez). `!==` ile düzeltildi; düzeltilmiş testbench Icarus'ta gerçekten sonucu bekledi: cümle 0, sınıf 1, puanlar −65 ve 73 (altın modelle aynı), 419 429 bayt, **70,5 ms** (7 052 276 çevrim; ölçüldü). Bu süre ağırlıkların flaştan (SCK 12,5 MHz, dört hatlı) akmasıyla belirleniyor; hesap bu sürenin içinde gizli, yani bu sayı işlemci karşılaştırmasında kullanılmaz.
**Bulgu 2:** Gösterge modları 0, 1, 2 "----" gösterdi. Neden (hesap): yeniden başlatma sonrası tire süresi 2²⁴ çevrim (≈ 0,17 s), benzetim ise 7,05 milyon çevrimde bitiyor. Kartta flaş okuması 70 ms olduğundan sorun yok; tire süresi `GOR_BIT` parametresiyle benzetimde kısaltıldı (varsayılan 24, kart davranışı değişmedi). Kod yorumundaki "0,33 s" ifadesi hatalıydı, düzeltildi. Gösterge kontrolü testbench ile kart kodu aynı gün güncellendiği için daha önce hiç geçmemiş olabilir (bilinmiyor).
**Durum:** Düzeltilmiş koşu sonucu bu kayda eklenecek.

## D05 — İşlemci tabanı (13 Kasım 2026 ölçümü)
**Ölçüldü:** i7-12650H, PyTorch FP32, gerçek ağırlıklar, 30 ısınma + 300 tekrar. 1 iplik: 64 token 1,544 ms (ortanca 1,496), 8 token 0,780 ms. 10 iplik: 1,535 / 1,044 ms. 16 iplik: 2,756 / 1,844 ms. En hızlı ayar 1 iplik.
**Not:** 16 ve 25 token ölçülmemişti; `scripts/olc_islemci_token.py` ile 8, 16, 25, 32, 56, 64 token ölçülecek (D06 öncesi hazırlık).

---

## D04 devamı — Kart testi düzeltmesi sonrası (19 Kasım 2026)
Düzeltilmiş `tb_kart` (Icarus, cümle 0, SCK 12,5 MHz): `KART TESTI: BASARILI`. Sınıf 1, puanlar −65 ve 73 (altın modelle aynı), 419 429 bayt, 70,5 ms (7 052 276 çevrim; ölçüldü). Gösterge modları 0, 1, 2 ve 3 beklenen karakterleri gösterdi (puan −065, 073; süre 70,4 ms; okunan 0409 KB). Önceki başarısızlıkların nedeni: (1) bekleme döngüsü koşulu, (2) test süresinin tire sayacından kısa olması (yukarıdaki bulgu). Tire süresi parametresi `GOR_BIT` kartta 24 kaldı.

## D06 — Dolgu atlama (nb): devre ve doğruluk
**Tarih:** 19 Kasım 2026.
**Amaç:** Cümlenin gerçek token sayısına göre blok sayısını nb = ⌈token/8⌉ çizelgeye ve çekirdeğe vermek; dolgu bloklarını hesaplamamak. Kararlar: LayerNorm satır sayısı 8·nb (blok hizalı); `DOLGU_ATLA` parametresi (varsayılan 1; 0 eski davranış); karşılaştırma yalnız geçerli token satırlarında.
**Yapılan değişiklikler:**
- `cizelge_ortak.v`: akış ayrıştırıcının doğruladığı `cumle_uzunluk`'tan nb hesabı (geçersiz uzunluk 0 ya da 64'ten büyük: 8 blok); her satıra `ayar_blok_sayisi`.
- `ortak_cekirdek.v`: nb kilitleme; sistolik dizi blok sayısı nb; Q·Kᵀ'de anahtar paneli sayısı nb; P·V'de anahtar sayısı 8·nb ve olasılık belleği adım adresi; Softmax uzunluğu çalışma zamanında (8·nb).
- `softmax_birim_gomulu.v` (`DINAMIK` parametresi + `satir_uz` girişi), `panel_kopyalayici.v` (`K_DINAMIK`, `k_uz`, `k_pad`), `artik_ln_ortak.v` (`ayar_blok_sayisi`; üretici `scripts/uret_ln_ortak.py` güncellendi).
- Önemli bulgu (tasarım): sistolik dizinin gölge biriktiricisi 64 çevrimde boşaldığı için tile süresi (K+16) en az 64 olmalı, yani K ≥ 48. P·V'de K = 8·nb, nb ≤ 5 için bunun altına düşer. Çözüm: P·V'nin K'si en az 48 alınır, fazla olasılık sözcükleri ve değer paneli sözcükleri sıfırla doldurulur (sonuç değişmez). Ek maliyet küçük (nb=1 için baş başına yaklaşık 320 çevrim, hesap). Bu, 03'te "nb ≥ 2" aralığında K=64 dikkat çarpımı kullanıldığı için görünmeyen bir kısıttı.
- Yeni DSP yok; değişiklikler sabit karşılaştırmaları yazmaç karşılaştırmasına çevirdi.
**Doğruluk (ölçüldü, xsim, altın modelle bit-birebir, yalnız geçerli bloklar/tokenlar):**
- Eski regresyon (DOLGU_ATLA=0): 4 cümle, 328 716 kontrol, 0 hata, 3 269 230 çevrim (değişiklik öncesiyle birebir aynı).
- 4 test cümlesi (4, 4, 5, 6 token; nb=1) DOLGU_ATLA=1: 30 348 kontrol, 0 hata, sınıflar doğru.
- Uzun cümleler (iki cümlelik beş küme, her biri 0 hata, sınıflar doğru): (8, 9 token) 24 966 kontrol; (16, 25) 55 686; (32, 49) 106 886; (56, 57) 147 846; (64, 64) 164 358. nb = 1, 2, 4, 7, 8 ve sınır değerleri (8→9, 56→57) kapsandı. 8, 9, 16, 25, 32 ve 49 token'lık cümleler gerçek SST-2 geliştirme cümleleri; 56, 57 ve 64 token'lık girdiler (en uzun gerçek cümle 55 token) 54–55 token'lık cümlelerin dikkat maskesi uzatılarak üretildi (uzatılan konumlar [PAD] kimliğiyle gerçek token gibi işlenir).
**Saf hesap süresi (ölçüldü, HIZLI_OLCUM=1, @100 MHz):**
- nb=1 (8 token): 89 694 çevrim = 0,90 ms
- nb=2 (16 token): 171 654 = 1,72 ms
- nb=4 (32 token): 342 918 = 3,43 ms
- nb=7 (56 token): 618 322 = 6,18 ms
- nb=8 (64 token): 716 438 = 7,16 ms (DOLGU_ATLA=0 ile birebir aynı)
Hızlanma (nb=8'e göre, hesap): nb=1 için 8,0 kat, nb=2 için 4,2 kat, nb=4 için 2,1 kat, nb=7 için 1,16 kat. Önceki ön tahminler (hesap) 84 000, 166 000, 339 000; gerçekleşen değerler yüzde 1–6 yukarıda (panel başına sabit yükler).
**Dağılım nb=1'de (satır süreleri, ölçüldü, katman başına):** Q/K 1 317 ×4, V 2 487, Q·Kᵀ+Softmax 901 ×2, P·V 969 ×2, çıkış 2 477, LayerNorm 1 5 589, FFN1 9 696, FFN2 8 621, LayerNorm 2 5 461; katman toplamı 43 339. LayerNorm payı yüzde 25, ileri besleme payı yüzde 42.
**Dağılım nb=4'te:** Q/K 4 773 ×4, V 9 399, Q·Kᵀ+Softmax 6 414 ×2, P·V 2 290 ×2, çıkış 9 389, LayerNorm 21 933 ve 21 421, FFN1 37 344, FFN2 33 965; katman toplamı 169 951.
**Yorum:** Kısa cümlelerde (8 token) hızlanma çok büyük; 64 token'da hiç yok. Gerçek dağılımın ortalaması 3,6 blok olduğundan ortalama süre yaklaşık 3 ms civarı bekleniyor (tahmin, nb=3, 5, 6 ölçülmedi). Bundan sonra baskın yük nb=4'te FFN (yüzde 42) ve LayerNorm (yüzde 25); LayerNorm satır başı ≈ 683 çevrim ve nb ile doğrusal ölçekleniyor.
**Dosyalar:** `rtl/cizelge_ortak.v`, `rtl/ortak_cekirdek.v`, `rtl/ortak_ust.v`, `rtl/softmax_birim_gomulu.v`, `rtl/panel_kopyalayici.v`, `rtl/artik_ln_ortak.v`, `scripts/uret_ln_ortak.py`, `scripts/uret_dolgu_vektorleri.py`, `vektor_dolgu/`, `vivado/sim_ortak_ust_dolgu.bat`, `vivado/sim_ortak_ust_saf_hesap.bat`, `tb/tb_ortak_ust.v` (`DOLGU_ATLA` parametresi), günlükler `sim/xs_dolgu/gunluk_kume_*.txt` ve `sim/xs_saf_1_1/gunluk_kume_*.txt`.
**Rapora not:** "Tile süresi ≥ 64 kısıtı ve sıfır dolgu" tasarım kararı olarak anlatılmalı; ölçüm kipi ile dolgu atlamanın birlikte değerlendirilmesi.

## D07 — Dolgu atlama sonrası sentez ve yerleştirme
**Tarih:** 19 Kasım 2026. `sentez/sentez_ust.tcl` (ortak_ust, 100 MHz, bağlamsız), ölçüldü.
**Sonuç (önceki ile):** DSP 87 → 87 (≤ 90); LUT 4 960 → 5 064 (+104); yazmaç 6 399 → 6 441 (+42); blok bellek 25 → 25; **WNS +0,279 ns → +0,010 ns** (kısıtlar sağlandı); WHS +0,059 → +0,055 ns.
**Kritik yol:** kaynak `u_cekirdek/tip_reg[0]`, hedef `u_cekirdek/u_bellek/birim[5]` blok bellek adres girişi; veri yolu gecikmesi 9,34 ns (11 mantık seviyesi, yüzde 67'si yönlendirme). Yol dolgu atlamadan önce de benzer bir adres çoklayıcısı üzerindeydi; nb ile eklenen karşılaştırıcılar ve çoklayıcılar payı daralttı (neden hesap/gözlem; kesin atıf yapılmadı).
**Yorum:** Zamanlama sağlandı ama pay 10 ps. Sonraki değişikliklerde (ör. LayerNorm hızlandırma) bu yol önce düzeltilmeli (bellek adres seçicisini kayıtlı yapmak gibi bir yol denenebilir; denenmedi).

## D08 — İşlemci tabanı, token sayısına göre (19 Kasım 2026)
**Yöntem:** `scripts/olc_islemci_token.py`; PyTorch FP32, i7-12650H, 50 ısınma + 300 tekrar, dikkat maskesi hepsi 1; 1 ve 10 iplik. Sonuç dosyası `notlar/islemci_token_sonuc.json`. Ölçüm sırasında başka ağır iş çalışmıyordu.
**Sonuç (ölçüldü, ortalama ms; 1 iplik / 10 iplik):** 8 token 1,053 / 1,130; 16 token 1,142 / 1,158; 25 token 1,216 / 1,182; 32 token 1,330 / 1,215; 56 token 1,673 / 1,365; 64 token 1,794 / 1,398.
**Not (tutarsızlık):** 13 Kasım ölçümünde 1 iplikte 8 token 0,78 ms ve 64 token 1,54 ms çıkmıştı; bugün 1,05 ve 1,79 ms. İki oturum arasında yüzde 15–35 fark var (güç planı, ısı ya da arka plan yükü olabilir; neden araştırılmadı). Karşılaştırmada iki ölçüm aralık olarak kullanılmalı.
**FPGA ile karşılaştırma (saf hesap, 100 MHz; FPGA ölçüldü, oran hesap):**
- 8 token: FPGA 0,90 ms; işlemci 0,78–1,05 ms → oran 0,85–1,15 (başa baş).
- 16 token: FPGA 1,72 ms; işlemci 1,14–1,16 ms → yaklaşık 1,5 kat yavaş.
- 32 token: FPGA 3,43 ms; işlemci 1,22–1,33 ms → 2,6–2,8 kat yavaş.
- 56 token: FPGA 6,18 ms; işlemci 1,37–1,67 ms → 3,7–4,5 kat yavaş.
- 64 token: FPGA 7,16 ms; işlemci 1,40–1,79 ms → 4,0–5,1 kat yavaş.
**Rapora not:** Basys3'te yalnız çok kısa cümlelerde işlemciye eşitlik var; token arttıkça fark açılıyor. Orta uzunlukta (25–32 token) açık yaklaşık 2,7 kat.
**Düzeltme (D09):** Bu kayıttaki işlemci sayıları tek koşudan alınmıştı; sonradan tekrarlanan koşularda ölçümün bimodal (iki farklı seviyeli) olduğu görüldü. Kesin tablo D09'dadır.

## D09 — Bütün blok sayıları (FPGA) ve işlemci tekrar ölçümleri
**Tarih:** 19 Kasım 2026.
**FPGA, saf hesap (ölçüldü, HIZLI_OLCUM=1, DOLGU_ATLA=1, 100 MHz):** nb=1 (8 token) 89 694 çevrim; nb=2 (16) 171 654; nb=3 (24) 256 162; nb=4 (25 ve 32 token ikisi de) 342 918; nb=5 (40) 431 850; nb=6 (48) 522 958; nb=7 (56) 618 322; nb=8 (64) 716 438. Blok başına artış 82 000 ile 98 000 çevrim arasında. n=25 ve n=32 aynı çevrimi verdi: süre yalnız nb'ye bağlı (LayerNorm satır sayısı blok hizalı 8·nb olduğundan beklenen).
**Doğruluk (nb=3, 5, 6; ölçüldü, xsim):** (24, 40 token) 82 438 kontrol 0 hata; (48, 48 token) 123 398 kontrol 0 hata; sınıflar doğru. nb=5 (K=40 < 48) sıfır dolgu yolunu da kapsıyor. Böylece nb = 1…8'in tamamı altın modelle doğrulanmış oldu.
**Sınırlama:** Ölçüm kipi (HIZLI_OLCUM=1) iki cümlelik akışta ikinci cümlede kilitlenir, çünkü ağırlık baytları akıştan tüketilmediği için ikinci aktivasyon bloğu yanlış konumdan okunur. Bu yüzden her ölçüm tek cümleyle (ns=1) yapıldı.
**Sentez çıkış kodu 255 (D07):** Vivado günlüğünde `SENTEZ_BITTI` ve normal çıkış görüldü; kod büyük olasılıkla komut satırındaki çıktı süzme borusundan geliyor. Sentez sonucu geçerli.
**İşlemci tekrar ölçümü (ölçüldü):** `olc_islemci_token.py` üç kez koşuldu (her biri 1 ve 10 iplik, token başına 300 tekrar). Sonuçlar bimodal: bazı koşularda 1,0–1,6 ms, bazı koşularda aynı ayarda 3–6 ms (ör. 1 iplikte 8 token: 1,05 / 0,99 / 3,21 ms; 10 iplikte 8 token: 1,13 / 4,16 / 1,20 ms). Neden araştırılmadı; olası nedenler: Intel 12. nesil karma çekirdek yapısında iş parçacığının yavaş çekirdeğe düşmesi veya arka plan yükü (Vivado grafik arayüzü, tarayıcı açıktı). Dalgalanma kayıtlı JSON dosyalarında: `notlar/islemci_token_sonuc_kosu1.json`, `_kosu2.json`, `_kosu3.json`. 13 Kasım ölçümü (8 token 0,78 ms, 64 token 1,54 ms) bu aralığın içinde en iyi uca yakın.
**Karşılaştırma yöntemi:** İşlemci için en iyi ortalama (tüm koşular ve iplik ayarları üzerinden en küçük ortalama) alındı; yavaş mod bir ölçüm artefaktı sayıldı çünkü temiz mod bağımsız koşularda tekrar görüldü. Medyan kullanılmadı (iki seviyeli dağılımda anlamsız). Tam ölçülmeyen ayarlarda (24, 40, 48 token) en iyi değer yalnız iki-üç koşudan geliyor, gerçek en iyi daha düşük olabilir; bu yüzden oranlar alt sınır sayılmalı.
**Sonuç tablosu (FPGA ölçüldü; CPU en iyi ortalama ölçüldü; oran hesap):**
- 8 token (nb=1): FPGA 0,90 ms; işlemci 0,99 ms; oran 0,90 (FPGA biraz hızlı)
- 16 token (nb=2): 1,72 / 1,12 ms; 1,5
- 24 token (nb=3): 2,56 / 1,20 ms; 2,1
- 25 token (nb=4): 3,43 / 1,18 ms; 2,9
- 32 token (nb=4): 3,43 / 1,22 ms; 2,8
- 40 token (nb=5): 4,32 / 1,36 ms; 3,2
- 48 token (nb=6): 5,23 / 1,33 ms; 3,9
- 56 token (nb=7): 6,18 / 1,37 ms; 4,5
- 64 token (nb=8): 7,16 / 1,40 ms; 5,1
**Yorum:** FPGA süresi nb ile neredeyse doğrusal (blok başına yaklaşık 0,85–0,98 ms), işlemci süresi ise token sayısına çok az bağlı (8 token 1,0 ms, 64 token 1,4 ms; yüzde 40 artış). Bu yüzden işlemciyi geçmek için FPGA'nın blok başına süresini yaklaşık 5 ila 6 kat azaltmak gerekir (25 token için hedef ≈ 1,2 ms; şu an 3,43 ms). Baskın kalemler nb=4'te FFN (yüzde 42 civarı) ve LayerNorm (yüzde 25).

## D10 — Zamanlama payının açılması (19 Kasım 2026)
**Amaç:** Dolgu atlamadan sonra setup payı +0,010 ns'ye düşmüştü (D07); sonraki değişiklikler için pay açmak.
**Kritik yol (D07, ölçüldü):** `tip_reg` (yük 177) → panel hazır seçimi → tile başlatma → aktivasyon adresi toplayıcısı (13 bit) → bellek birimi seçimi → blok bellek adres girişi; veri yolu 9,34 ns, 11 mantık seviyesi.
**Yapılan iki değişiklik (`rtl/ortak_cekirdek.v`, işlev değişmez):**
1. İş türü: tek 3 bitlik `tip` kaydı yerine bir-sıcak ayrı kayıtlar (`t_lin`, `t_qk`, `t_pv`, `t_ln`, `t_att`), her biri `max_fanout = 24` ile sınırlı yükle.
2. A operandı adresi `taban + tile adresi`: tüm tabanlar 512'nin katı (0, 1024, 1536, 4096, 5120) olduğundan alt 9 bit toplamaya girmez; toplama yalnız ust 4 bitte yapılır (13 bitlik tam toplayıcı yerine). Benzetimde taban 512'nin katı değilse uyarı yazan bir denetim eklendi (sentezde yok sayılır).
**Doğruluk ve çevrim (ölçüldü, xsim):** eski regresyon 328 716 kontrol 0 hata, 3 269 230 çevrim (değişmedi); saf hesap nb=8 716 438 ve nb=1 89 694 çevrim (değişmedi); dolgu atlama kümeleri (8–9, 24–40, 64–64 token) 0 hata; taban uyarısı çıkmadı.
**Sentez (ölçüldü, `ortak_ust`, 100 MHz):** WNS +0,010 → **+0,411 ns** (dolgu atlama öncesi +0,279 idi); WHS +0,055 → +0,053 ns; LUT 5 064 → 5 060; yazmaç 6 441 → 6 450; blok bellek 25; DSP 87 (≤ 90). Yeni en kötü yol `u_tile/blok_no_reg` → bellek adres girişi, 8,94 ns, 9 mantık seviyesi.
**Yorum:** Pay 0,41 ns ile dolgu atlama öncesinden de geniş. Yeni en kötü yol yine bellek adresi üzerinde; sonraki değişikliklerde yeniden daralırsa bellek birim seçimi yazmaçlanabilir (denenmedi).

## D11 — LUT çarpmalı 8×8 dizi sentez deneyi (19 Kasım 2026; mimari notu için)
**Amaç:** `MIMARI_NOTU_hizlandirma_secenekleri.md` içindeki "ek dizi LUT'ta" seçeneğinin alan ve zamanlama maliyetini ölçmek. Tasarıma bağlı değil; kaynak `sentez/deney/lut_dizi_deneme.v`, betik `sentez/deney/sentez_lut_dizi.tcl`, çıktılar `sentez/deney/cikti/`.
**Yöntem:** 64 işlem elemanlı çıkış-sabit dizi, her eleman 9×8 bit çarpma + 32 bit biriktirici, `use_dsp = "no"`; `xc7a35tcpg236-1`, bağlamsız, sentez + yerleştirme + yönlendirme, 100 MHz kısıtıyla (150 MHz kısıtlı koşu ayrıca yapıldı, sonucu aşağıda).
**Sonuç (ölçüldü, 100 MHz):** 6 271 LUT, 3 000 yazmaç, 0 DSP, WNS +1,204 ns (en kötü yol 8,77 ns, çarpma ve biriktirme tek çevrimde); işlem elemanı başına yaklaşık 98 LUT.
**Yorum:** Boş LUT 15 740; en fazla iki ek dizi sığar (toplam doluluk ≈ yüzde 85). Matris çarpımlarını iki katına çıkarmak (k=2) mümkün görünüyor; asıl sınır tile sonundaki ortak yeniden ölçekleme devresi (çevrimde 1 eleman). Ayrıntı mimari notunda.
**Mimari notu:** `notlar/MIMARI_NOTU_hizlandirma_secenekleri.md` yazıldı (seçenekler A–E, senaryolar, yedek plan, karar noktaları); RTL değiştirilmedi.

**150 MHz sonucu (ölçüldü, D11 devamı):** aynı dizi 6,667 ns kısıtıyla: 6 790 LUT, 3 000 yazmaç, 0 DSP, **WNS −0,987 ns** (en kötü yol 7,63 ns, 12 mantık seviyesi, setup ihlali 1 164 uç noktada). Hold +0,216 ns. Yorum: LUT çarpmalı eleman çarpma+biriktirmeyi tek çevrimde yaparken en fazla ≈ 115–125 MHz'e çıkar; 150 MHz için boru hattı (ek yazmaç) gerekir. Boru hattı eklenmiş sürüm denenmedi.

## D12 — LayerNorm: varyansı yükleme sırasında hesaplamak (24 Kasım 2026)
**Amaç:** Mimari notundaki seçenek A'nın ilk adımı. LayerNorm satırında ayrı 130 çevrimlik "fark karesi toplama" geçişini kaldırmak.
**Yöntem:** Σ(q−m)² = Σq² − 2m·Σq + 128·m² (m tamsayı olduğundan tam eşitlik). Σq² yükleme sırasında biriktirilir (18×18 çarpma ve toplama, eski fark-kare çarpımının yerini aldı; DSP sayısı aynı), ortalamadan sonra dört adımda (ortalama, 2Σq−128m, m×t1 LUT'ta, çıkarma) kareler toplamı bulunur. Değişiklik `scripts/uret_ln_duzeltilmis.py` üretecine eklendi, `rtl/layernorm_birim_dz.v` yeniden üretildi.
**Sonuç (ölçüldü, xsim):** eski regresyon 328 716 kontrol, 0 hata (altın modelle bit-birebir); nb=8 saf hesap 716 438 → **683 926 çevrim** (−32 512 = 4 LayerNorm × 64 satır × ≈ 127 çevrim); LayerNorm satır süresi ≈ 683 → ≈ 557 çevrim (hesap, satır sürelerinden).
**Yorum:** Beklenen kazanç (≈ 130 çevrim/satır) gerçekleşti. Sıradaki adım (satır örtüştürme) ≈ 557 → ≈ 400 hedefliyor.

---

# 24 Kasım 2026 — üst model (büyük FPGA) çalışması

Kararlar (Rümeysa, 24 Kasım): hedef parça XC7A200T (740 DSP, 365 blok bellek); büyük tasarımda matris dizileri, LayerNorm ve Softmax paralel; ağırlıklar yonga içi blok bellekte (açılışta flaştan yüklenir, çıkarım süresine girmez; işlemcinin modeli önceden belleğe yüklemesiyle eşit koşul); değişiklikler ayrı dalda (`hizlandirma`) aşama başı yerel commit.
Ortak ölçüm yöntemi: tek cümle, `tb_ortak_ust` süre kipi; "saf hesap" = aktivasyon bloğunun doğrulandığı çevrimden sonuç darbesine kadar; hepsi xsim; 100 MHz varsayımıyla çevrimden ms'ye çevrildi (frekans sentez sonuçlarından ayrıca irdelendi).

## D13 — Paralel doğrusal hatlar (NA) ve yonga içi ağırlık belleği
**Amaç:** Matris çarpımlarını (çevrimin ≈ yüzde 68'i) birden çok 8×8 dizide paralel yapmak.
**Tasarım (`rtl/ek_hat.v`, `agirlik_rom_banka.v`, `yaz_fifo.v`; `cizelge_ortak.v`, `ortak_cekirdek.v`, `ortak_ust.v`):** Doğrusal satırda NA hat birlikte çalışır; hat h her panel grubunun h numaralı panelini (genel panel = grup·NA + h) hesaplar. Her hat kendi ağırlık bankasına (banka h, her satırın h, h+NA, h+2NA… numaralı panelleri), panel tamponuna, parametre okuyucusuna, tile denetleyicisine, sistolik dizisine, yeniden ölçekleme devresine, GELU tablosuna ve çıkış toplayıcısına sahiptir. Aktivasyon sözcüğü (A işleneni) ve panel hazır işareti tüm hatlarda ortaktır; hatlar aynı denetim durum makinesini aynı girdilerle sürdüğünden adım adım eşgüdümlüdür. Hatların çıkış sözcükleri 64 derinlikli FIFO'lardan geçip tek bellek yazma portuna sıralanır. Ağırlık imajları `scripts/uret_agirlik_rom.py NA` ile modelin `*_w_panel.mem` dosyalarından üretilir (NA'ya bölünmeyen panel sayıları sıfır panelle tamamlanır, bu panellerin çıkışı yazılmaz).
**Doğrulama (ölçüldü, xsim, altın modelle bit-birebir):** NA=1 (ağırlık ROM kipi) ve NA=8 için yedi vektör kümesinin hepsi (8–64 token, nb=1…8) 0 hata, sınıflar doğru (24 966 / 55 686 / 106 886 / 147 846 / 164 358 / 82 438 / 123 398 kontrol). Eski bayt akışı kipi (NA=1) regresyonu: 4 cümle, 328 716 kontrol, 0 hata, 3 139 182 çevrim.
**Saf hesap süreleri (ölçüldü, 100 MHz; yalnız doğrusal katmanlar paralel, LayerNorm ve Softmax seri; çevrim):**
NA=1: 8 token 107 014; 16 token 170 974; 24 token 251 418; 32 token 334 110; 40 token 418 978; 48 token 506 022; 56 token 597 322; 64 token 691 374.
NA=2: 70 954; 115 522; 169 086; 224 898; 282 886; 343 050; 407 470; 474 642.
NA=4: 52 660; 87 844; 127 968; 170 340; 214 888; 261 612; 312 592; 366 324.
NA=8: 42 433; 72 587; 105 991; 141 643; 179 471; 219 475; 263 735; 310 747.
(Basys 3 akış kipi, ölçüm kipi: 85 630; 163 526; 243 970; 326 662; 411 530; 498 574; 589 874; 683 926.) Süre hat sayısıyla ideal oranda azalmıyor: NA=8'de 64 token için 2,2 kat (691 374 → 310 747); kalan süre LayerNorm, Softmax ve dikkat çarpımlarında.

## D14 — Paralel LayerNorm (artik_ln_par)
**Amaç:** LayerNorm bir blogun 8 satırını ayrı ayrı (satır başına ≈ 557 çevrim) işliyordu.
**Tasarım:** Bir aktivasyon sözcüğü (8 token'ın aynı kanalı) bir kez okunur, hat i sözcüğün i. baytını alır; her hat kendi yeniden ölçekleme devresine ve LayerNorm birimine sahiptir (8 hat), çıkış sözcüğü (8 hattın aynı kanalı) doğrudan yazılır, yeniden ölçeklenmemiş çıkış (ham LayerNorm 1 çıkışı) bir tamponda biriktirilip blok sonunda yazılır. Aynı sabitler ve aynı hesap; bit-birebir.
**Doğrulama (ölçüldü):** NA=8 + paralel LayerNorm: yedi küme 0 hata.
## D15 — Paralel Softmax
**Tasarım:** Bir blogun 8 satırı 8 Softmax biriminde birlikte işlenir; skor belleği token'a göre 8 bankaya bölünür (hat i, bloğun i. token'ının satırını okur); 8 birimin aynı sütundaki çıkışları tek olasılık sözcüğü olarak yazılır (K≥48 sıfır dolgusu korunur).
**Doğrulama (ölçüldü):** NA=8 + paralel LayerNorm + paralel Softmax: yedi küme 0 hata.
## D16 — Dikkat (Q·Kᵀ, P·V) 8 hatta
**Tasarım:** Q·Kᵀ'de hat h, h. anahtar bloğunun paneli; P·V'de hat h, h. değer kanal paneli. K^T ve V panelleri aktivasyon belleğinden hatlara sırayla kopyalanır, sonra tüm hatlar birlikte hesaplar. Skorlar hat bankalarına (hat, token) yazılır, Softmax 8 token'ı tek okumada alır; P·V bağlam sözcükleri FIFO'lardan sıralanır.
**Doğrulama (ölçüldü):** NA=8 + hepsi paralel: yedi küme 0 hata.

## D17 — Büyük FPGA sentez ve yerleştirme (ilk koşu: 8 hat + paralel LayerNorm ve Softmax, ağırlık ROM)
**Yöntem:** `sentez/sentez_buyuk.tcl` (ortak_ust, bağlamsız, 100 MHz, Vivado 2025.1); parça XC7A200T (`xc7a200tfbg676-2`).
**Sonuç (ölçüldü, yerleştirme ve yönlendirme sonrası):** 720 DSP (740'ın yüzde 97,3'ü), 33 213 LUT (yüzde 24,8), 43 418 yazmaç (yüzde 16,2), 223,5 blok bellek (yüzde 61,2); **WNS +0,370 ns, WHS +0,065 ns** (kısıtlar sağlandı). En kötü yol mantıksız (0 mantık seviyesi), tamamı yönlendirme (9,1 ns): hat 1'in yeniden ölçekleme devresindeki kaydırma yazmacının yayılımı, DSP sütunları arasında uzun bir yol; DSP doluluğu yüzde 97 olduğundan yönlendirme baskılı. (Bu koşuda dikkat hatları (ATTP) yoktu; son tasarımın sentezi D18'de.)
**XC7A100T (`xc7a100tcsg324-1`) denemesi (2 hat, LayerNorm ve Softmax seri):** 156 DSP (yüzde 65), 20 456 LUT (yüzde 32), **145,5 blok bellek (yüzde 107,8)** → sığmıyor. Yalnız modelin ağırlıkları 410 624 bayttır (≈ 91 blok bellek karosu); aktivasyon belleği, panel tamponları ve tablolarla 135 karoluk bellek yetmiyor. Sonuç: ağırlıkların yonga içinde tutulduğu tasarım XC7A100T'ye ve (50 karo bellek) Basys 3'e sığmaz; büyük parça gerekli.

## D18 — Üst modelin (8 hat + paralel LayerNorm, Softmax ve dikkat) süre taraması ve sentezi
**Saf hesap süreleri (ölçüldü, xsim, 100 MHz, çevrim):** 8 token 24 205; 16 token 34 071; 24 token 44 767; 32 token (ve 25) 55 591; 40 token 66 543; 48 token 77 623; 56 token 89 535; 64 token 101 703 (1,02 ms). Aradaki yapılandırmalar: yalnız LayerNorm ve Softmax paralel (NA=8): 25 201 … 133 467 çevrim (64 token 1,33 ms); NA=4: 35 356 … 188 972; NA=2: 53 722 … 297 362.
**Bileşen dökümü (ölçüldü, 32 ve 64 token, çevrim; `notlar/sonuclar/bilesen_dokumu.csv`, görsel g17):** 64 token için Basys 3: doğrusal 149 488, ileri besleme 283 930, dikkat 107 152, LayerNorm 140 340, son 3 015 (toplam 683 926); üst model: doğrusal 22 586, ileri besleme 39 234, dikkat 19 132, LayerNorm 19 316, son 1 434 (toplam 101 703). Üst modelde dört ana kalem (doğrusal, ileri besleme, dikkat, LayerNorm) dengeli.
**Sentez ve yerleştirme (ölçüldü, XC7A200T, bağlamsız, tam tasarım: NA=8, ağırlık ROM, LN_PAR, SMP, ATTP):** 100 MHz: **WNS +0,221 ns**, WHS +0,046 ns; 720 DSP (yüzde 97,3), 34 217 LUT (yüzde 25,6), 44 653 yazmaç (yüzde 16,7), 251,5 blok bellek (yüzde 68,9). 150 MHz kısıtıyla: WNS −1,484 ns (2 272 ihlalli uç nokta) → en yüksek saat ≈ 1/(6,667+1,484 ns) ≈ 123 MHz (hesap, tek koşu). Bu iki koşu LayerNorm'un çarpımını iki yarıma bölen son değişiklikten önceki RTL ile yapıldı; bölme yalnız boru hattı ekliyor (DSP ve bellek aynı).
**Yorum:** Üst model 100 MHz'de her uzunlukta işlemciden hızlı (8 token 4,1×, 32 token 2,2×, 64 token 1,4×). Saat 120 MHz'e çıkarsa 64 token için ≈ 0,85 ms (hesap, 1,02 ms × 100/120); işlemci 1,40 ms.

## D19 — Basys 3 son tasarım: sentez, yerleştirme ve kart dosyaları
**Değişiklik:** LayerNorm'un satır başına yapılan m·t1 çarpımı (D12) tek çevrimde LUT'ta olduğundan Basys 3 yerleştirmesinde en kötü yol oldu (16 mantık seviyesi, WNS −0,176 ns, 5 uç nokta). Çarpım iki yarım çarpıma ve bir toplamaya bölündü (satır başına +1 çevrim; `scripts/uret_ln_duzeltilmis.py`).
**Doğruluk (ölçüldü):** eski regresyon 328 716 kontrol, 0 hata, 3 140 206 çevrim (önce 3 139 182; +1 çevrim × 1 024 LayerNorm satırı).
**Sentez (ölçüldü, `ortak_ust`, 100 MHz, bağlamsız):** 5 662 LUT, 6 633 yazmaç, 25 blok bellek, 88 DSP, **WNS +0,418 ns**, WHS +0,039 ns. DSP 87'den 88'e çıktı (LayerNorm'daki kareler toplamı çarpma-biriktirme birimi). Aşama D10'daki 87 DSP, WNS +0,411 ns ile karşılaştırılabilir.
**Kart üst modülü (`kart_ust`, `sentez/kart_uret.tcl`, ölçüldü):** 5 928 LUT, 6 904 yazmaç, 25 blok bellek, 88 DSP, **WNS +0,357 ns**, WHS +0,019 ns; `sentez/cikti_kart/kart_ust.bit`, `kart_akis.mcs`, `kart_tam.mcs` üretildi (24 Kasım). Kartta henüz denenmedi (en sona bırakıldı).

## D20 — Saat sınırı, kart testi ve kesişim özeti (24 Kasım 2026)
**Saat (ölçüldü, XC7A200T, tam tasarım):** 100 MHz WNS +0,221 ns (tutuyor); 125 MHz WNS −0,517 ns (201 ihlalli uç nokta); 150 MHz WNS −1,484 ns. Yönlendirmeye göre kestirilen en yüksek saat: 125 MHz koşusundan ≈ 117 MHz, 150 MHz koşusundan ≈ 123 MHz (iki kestirim tutarsız; yakın olan 117 MHz alındı). 100 ile 117 MHz arasında bir saat kısıtıyla yerleştirme yapılmadı; bu aralıkta kapanış doğrulanmadı. 117 MHz'de 64 token ≈ 0,87 ms (hesap). D18'deki "≈ 123 MHz" ifadesi bu kayıtla düzeltilmiştir.
**Kart testi (`tb_kart`, Icarus, cümle 0, son tasarım):** `KART TESTI: BASARILI`; sınıf 1, puanlar −65 ve 73 (altın modelle aynı), 419 429 bayt, gösterge süresi 67,4 ms (7 034 812 çevrim; önceki 70,5 ms'den kısa: LayerNorm ve dolgu atlama hesabı kısalttı, akış hızı aynı). Gösterge modları doğru.
**Kesişim (FPGA'nın işlemciden hızlı olduğu cümle uzunlukları, saf hesap, 100 MHz):** Basys 3 ≈ 10 belirteçe kadar; 2 hat ≈ 15; 8 hat yalnız doğrusal paralel ≈ 27; 8 hat + paralel LayerNorm ve Softmax 8–64'ün hepsi (64 belirteçte 1,33 ms, işlemci 1,40); tam üst model 8–64'ün hepsi (64 belirteçte 1,02 ms). Görseller g14–g20.
