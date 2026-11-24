# Basys 3 üzerinde çalıştırma kılavuzu

Üst modül `kart_ust` (rtl/kart_ust.v). Asıl iş `kart_mantik.v` içinde; `kart_ust.v` yalnızca pin ilkellerini içerir.
Kısıt dosyası: `sentez/kart_basys3.xdc`. Tüm akışı toplu üretmek için: `vivado -mode batch -source sentez/kart_uret.tcl` (cwd: 04-RTL_Komutsuz).

## Üretilen dosyalar (sentez/cikti_kart)
- `kart_ust.bit` : yalnızca tasarım (1,4 MB, sıkıştırılmış)
- `kart_tam.mcs` : bit dosyası (adres 0) + dört cümlenin akışı (adres 0x240000) — kartı flaştan kendi kendine açar
- `kart_akis.mcs` : yalnızca dört cümlenin akışı (adres 0x240000)

## Çalışma düzeni
1. Güç gelince kart tasarımı yükler; kısa süre sonra seçili cümlenin akışı flaştan okunur (4 cümle × 419 429 bayt, adres 0x240000'dan).
2. Hızlandırıcı iki katmanı, pooler'ı ve sınıflandırıcıyı çalıştırır. Sonuç LED'lerde ve göstergede görünür.
3. Cümle anahtarlarını (sw[1:0]) değiştirince hesap kendiliğinden baştan başlar. Orta düğme (btnC) de aynı şekilde baştan başlatır. Yeniden başlayınca gösterge yaklaşık 0,3 saniye "----" gösterir, sonra sonuç gelir.

## Anahtarlar
- sw[1:0] : cümle (0, 1, 2, 3). Değişince kart cümleyi flaştan yeniden okuyup baştan hesaplar.
- sw[15:14] : gösterge
  - 00 → birinci puan, 01 → ikinci puan (örn. "-065", " 073")
  - 10 → süre milisaniye cinsinden, ondalık noktalı (örn. "067.0")
  - 11 → flaştan okunan kilobayt (çalışırken canlı artar, bitince 0409)
  - İşlem bitene kadar 00/01/10 modlarında "----" görünür; akış hatası olursa "Err".

- sw13 yukarı : tanı modu (sw[15:14] ile)
  - 00 → akıştan okunan cümle uzunluğu: cümle 0, 1, 2, 3 için sırasıyla 4, 4, 5, 6
  - 01 → akış denetim hatası sayısı (0 olmalı)
  - 10 → "ab": a okunan cümle, b anahtarların gördüğü değer (ikisi aynı olmalı)
  - 11 → şu an çalışan satır (katman*100 + satır)

## LED'ler
- LED0–3 : şu an çalışan satır numarası (0–15)
- LED4 : katman numarası (0 veya 1)
- LED5 : flaştan okuma sürüyor
- LED6 : akış hatası (CRC) — yanarsa veri bozuk
- LED7 : taşma veya bellek çatışması bildirimi
- LED8 : sonuç hazır
- LED9 : karar sınıf 1, LED10 : karar sınıf 0
- LED11 : iki puan da altın modelle aynı (asıl doğrulama göstergesi)
- LED12–13 : seçili cümle
- LED14 : flaştan okuma tamamen bitti
- LED15 : canlılık (saniyede yaklaşık bir kez yanıp söner)

## Beklenen sonuçlar (altın model)
- cümle 0 : sınıf 1, puanlar -65 ve 73
- cümle 1 : sınıf 0, puanlar 95 ve -108
- cümle 2 : sınıf 0, puanlar 101 ve -112
- cümle 3 : sınıf 0, puanlar 18 ve -33
Doğru çalışınca LED8 ve LED11 yanar, LED14 yanar, LED6 ve LED7 sönük kalır. Süre yaklaşık 70 ms (benzetim).

## Flaşa yazma (Vivado Hardware Manager)
1. Kartı USB ile bağla, Hardware Manager → Open Target → Auto Connect.
2. Flaş cihazını ekle: cihaza sağ tık → Add Configuration Memory Device. Parça listesinden, kartın üzerindeki flaş yongasının adıyla başlayanı seç (Spansion S25FL032 ya da Macronix MX25L3233F; ikisi de x1_x2_x4 olanı).
3. Program Configuration Memory Device: dosya `kart_tam.mcs`; Erase, Program ve Verify işaretli. Birkaç dakika sürer.
4. JP1 köprüsünü QSPI konumuna getir, kartı yeniden aç (ya da PROG düğmesi). Tasarım flaştan yüklenir.

Alternatif: tasarımı her seferinde JTAG ile `kart_ust.bit` üzerinden yükle (Program Device). Bu durumda flaşta yalnızca akış verisinin bulunması yeter (`kart_akis.mcs`).

## Çalışmazsa
- LED15 yanıp sönmüyor : tasarım yüklenmemiş ya da saat yok.
- LED5 yanıyor ama LED14 hiç yanmıyor : flaştan veri gelmiyor. Flaştaki dosya (adres 0x240000), JP1 konumu ve flaşın dört hatlı kip bitinin açık olması denetlenmeli.
- LED6 yanıyor ("Err") : flaştan gelen veri bozuk. Okuma hızını düşürmek için `kart_ust.v` içinde `BOL(4)` değerini 8 yap, yeniden üret.
- Puanlar yanlış ama hata yok : cümle seçimini ve flaştaki dosyayı denetle.
