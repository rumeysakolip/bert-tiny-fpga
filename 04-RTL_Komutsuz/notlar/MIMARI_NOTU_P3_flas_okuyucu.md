# Mimari Notu P3 — Flaştan dört hatlı okuma (ağırlık kaynağı)

Tarih: 6 Kasım 2026 · Karar kaynağı: `Tasarim_Kararlari_Arastirma_Raporu.docx`, Karar 1.

## 1. Amaç ve ölçülen sorun
Ağırlıklar çipe sığmaz (93,5 blok bellek gerekir, kartta 50 var); seri hatta aktarım hesap süresinin 54–700 katıdır. Karar: ağırlıklar kartın seri flaşından (Spansion S25FL032, 32 megabit, dört hatlı bağlantı) sıralı okunacak. Hedef: okuma süresi / hesap süresi ≤ 10 (25 megahertz dört hatlı okumada hesapla 5,1; 50 megahertz'te 2,6).

## 2. Çözüm
`qspi_okuyucu`: tek bir okuma işlemiyle akışın tamamını çeker.
1. Seçim ucu aşağı; tek hat üzerinde 8 bit komut (0x6B, dört hatlı çıkış okuması) ve 24 bit adres gönderilir.
2. 8 saat darbesi boşluk (dummy).
3. Veri evresi: her saat darbesinde 4 bit; iki darbe bir bayt (yüksek yarım önce). Flaş adresi kendisi artırır; yeni komut gerekmez.
4. Alıcı hazır değilse saat durdurulur (saat, mod 0'da boşta alçak tutulabilir); bayt akışı `bayt_gecerli / bayt_hazir` el sıkışmasıyla `komutsuz_ust`'e verilir.
5. İstenen bayt sayısı bitince seçim ucu yukarı çekilir.
Saat bölücü: `BOL` sistem saati = SCK yarım periyodu. `BOL=2` → SCK = sistem/4 (100 MHz'de 25 MHz, bayt başına 8 çevrim); `BOL=1` → 50 MHz (bayt başına 4 çevrim).

Bayt arabirimi aynı kaldığından `komutsuz_ust` değişmez: kaynak seri hat ya da flaş olabilir.

## 3. Arayüz
Çıkış: `sck`, `cs_n`, `io0_o` (komut/adres için tek hat). Giriş: `io_i[3:0]` (veri evresi). Kart pinlerinde çift yönlü tampon ve flaşın saat ucu için özel devre öğesi (STARTUPE2) gerekir; bu prototipte yalnız mantık sınanır, pin sarmalayıcısı kart aşamasına bırakıldı.

## 4. Beklenen süre (hesap)
Bayt başına 8 çevrim (BOL=2): 60 514 baytlık cümle akışı için ≥ 484 112 çevrim (≈4,84 ms @100 MHz); BOL=1: ≥ 242 056 çevrim. Yalnız ağırlık kısmı (3×16×1 088 = 52 224 bayt) 417 792 / 208 896 çevrim.

## 5. Doğrulama
Benzetimde `tb` içinde S25FL032'nin okuma davranışını (komut, adres, boşluk, nibble sırası) taklit eden basit bir flaş modeli kullanılır; içeriği Python'un ürettiği bayt akışıdır. Kabul: Q, K, V çıkışı altın modelle bit-birebir; ölçülen çevrim ≈ hesap; hatalı içerikte CRC hatası.

## 6. Riskler ve kapsam dışı
Flaş modeli veri sayfasının tüm zamanlamasını taklit etmez (yalnız komut yapısı ve bit sırası); gerçek çıkış gecikmesi, saatin kullanıcı mantığına verilmesi (STARTUPE2) ve ağırlıkları flaşa yazma kartta doğrulanacak. Dört hat yerine tek hatlı okuma ve çift hızlı okuma bu prototipte yoktur.
