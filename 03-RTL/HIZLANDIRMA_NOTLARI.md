# Hızlandırma çalışması notları

Başlangıç: 2 Kasım 2026. Etiketler: **benzetim** (Icarus), **Vivado** (rapor dosyası), **hesap** (formül), **altın model** (NumPy). Hiçbir sayı CPU ile kıyaslanmaz. Kart elde yok; hiçbir sonuç kartta doğrulanmadı.
Süre modeli: toplam süre = hesap çevrimi ÷ frekans + ağırlık aktarım süresi (+ host, ölçülmedi).

## Konu 1 — Başlangıç ölçümü

Taban değerleri `sim/hizlandirma_oncesi.json` içinde (betik: `scripts/konu1_baslangic.py`). Taban RTL, `0375cf3` numaralı commit'tir (önceki oturumdan commit'lenmemiş `bert_tiny_ust.v`, `komut_cozucu.v` Softmax/LayerNorm komutları vb. burada ilk kez kayda girdi).

| Test | Sonuç | Kaynak |
|---|---|---|
| Softmax birimi (benzetim) | PASS, 325 satır, 20 800 kontrol, 0 hata, 2 049 çevrim/satır | `sim/g11_sonuc.json` |
| LayerNorm birimi (benzetim) | PASS, 485 satır, 62 080 kontrol, 0 hata, 5 274 çevrim/satır | `sim/g11_sonuc.json` |
| Mutantlar | 5 mutantın 3'ü yakalandı (sm1, ln1, ln2); 2'si açıklanmış eşdeğer (sm2, ln3) | `sim/g11_sonuc.json` |
| `tb_bert_tiny_ust` (benzetim) | PASS, 175 390 kontrol, 0 hata, 4 200 546 çevrim | `sim/tb_bert_tiny_ust_konu1_log.txt` |
| Host döngüsü (benzetim) | PASS, 6 katman, 602 paket, 283 905 bayt, 0 hata | `sim/host_dongusu_konu1_log.txt` |

Bölüm 2 tablosuyla uyum: Softmax ve LayerNorm satır çevrimleri (2 049, 5 274), bölme aşamaları (1 664 ve 4 352) ve toplam (2 682 200 çevrim = 26,822 ms @100 MHz, hesap) aynı çıktı. Doğrusal (428 928) ve dikkat (41 048) çevrimleri bu çalışmada yeniden ölçülmedi, `sim/g19_ozet.json`'dan alındı.

Vivado (100 MHz kısıtı, xc7a35tcpg236-1; yeniden koşturulmadı, mevcut raporlar kullanıldı: rapor 29 Ekim 21:15, en son RTL düzenlemesi 29 Ekim 20:57):

| Tasarım | LUT | LUT (bellek) | FF | DSP | BRAM | WNS | Hold |
|---|---|---|---|---|---|---|---|
| Tam sistem `bert_tiny_uart_ust` (yerleştirme+yönlendirme) | 5 540 | 1 937 | 5 390 | 77 | 15,5 | +0,587 ns | +0,024 ns |
| Doğrusal katman sistemi `hizlandirici_uart_ust` (eski komut çözücü) | 3 702 | 1 576 | 4 219 | 68 | 15 | +0,721 ns | +0,026 ns |
| Softmax tek başına (yalnız sentez) | 561 | 225 | 198 | 3 | 0 | +3,186 ns | – |
| LayerNorm tek başına (yalnız sentez) | 1 129 | 124 | 604 | 6 | 0 | +1,383 ns | – |

Tam sistem ile doğrusal katman sistemi aynı RTL değildir (ikincisi Softmax/LayerNorm komutlarından önceki komut çözücüyü içerir). Softmax ve LayerNorm satırları yalnız sentezdir: yerleştirme yönlendirme yok, hold raporu yok. 77 DSP = 68 (doğrusal sistem) + 3 + 6.
Kritik yollar (Vivado): ilk beşin üçü LayerNorm `p2_reg` → `p2s_reg` (9,10–9,31 ns, 19–20 mantık seviyesi), biri PE dizisi (5,51 ns), biri komut çözücü `cmd_reg` → `ln_m0_reg` CE (8,93 ns, %78 yönlendirme).

Gözlem (hata değil): `g9_host_dongusu.py` çıktısında `HIZLANDIRICI YANIT KARSILASTIRMA: FAIL (66615 fark)` satırı görünür. Bu satır testbench'in tek katmanlı varsayılan senaryosu (8 337 bayt) için gömülü bir karşılaştırmadır; 6 katman gönderilince doğal olarak uyuşmaz. Asıl karşılaştırma Python tarafında yapılır ve 0 fark verir.

## Konu 2 — Ağırlık aktarımı

Betik `scripts/sure_modeli.py`; çıktılar `sim/sure_modeli.json`, `sim/sure_modeli.csv` (84 satır), `sim/uart_kombinasyonlari.csv` (12 satır). Tüm süreler **hesap**; yalnız N=8 çevrim kalibrasyonu ve 100 MHz zamanlama ölçülmüştür.

Çevrim modeli: karo çevrimi = K + 2N − 1, karo sayısı = ⌈64/N⌉·⌈C/N⌉. N=8'de formül, ölçülenden doğrusalda 1 152, dikkatte 600 çevrim azdır; bu fark sabit ek sayıldı. N=4 ve N=16 için ölçüm yoktur.

| Dizi | Hesap çevrimi | ms @100 MHz | DSP (tahmin) | Basys3'e sığar |
|---|---|---|---|---|
| 4×4 | 3 996 760 | 39,968 | 29 | evet |
| 8×8 | 2 682 200 | 26,822 | 77 | evet |
| 16×16 | 2 342 296 | 23,423 | 269 | hayır (90 DSP) |

8×8'den 16×16'ya geçiş çevrimi yalnız %12,7 azaltır, çünkü Softmax ile LayerNorm (2 212 224 çevrim) diziden bağımsızdır.

Aktarım süresi (8×8, 100 MHz; iki ağırlık varsayımı): ağırlık/bias/M0 tabloları 420,7 KB (istemdeki değer, hesap) ve ölçülen host trafiği (6 doğrusal katman: 283 905 gönderilen + 73 758 alınan bayt, iki katmana çarpılmış = 715 326 bayt; aktivasyonlar ve paket başlıkları dahil, dikkat ve Softmax/LayerNorm gidiş-dönüşü dahil değil).

| Baud | 420,7 KB | 715 326 bayt | Not |
|---|---|---|---|
| 921 600 | 4,565 sn | 7,762 sn | |
| 3 000 000 | 1,402 sn | 2,384 sn | |
| 12 000 000 | 0,351 sn | 0,596 sn | 100 MHz'de "çalışmaz" kuralı (aşağıda); 96 MHz'de tam bölünür |

Hesap süresi 26,8 ms, aktarım en az 0,35 sn; aktarım 12 Mbaud'da bile hesabın ≈13 katıdır (hesap). Ağırlık çipte dursaydı (varsayım, yapılmadı) toplam ≈ hesap süresi olurdu.

UART kombinasyonları (`CLKS_PER_BIT` = en yakın tam sayı; eşikler: ≤%2 güvenli, ≤%4 sınırda, >%4 çalışmaz):

| Saat | 921 600 baud | 3 Mbaud | 12 Mbaud |
|---|---|---|---|
| 100 MHz | 109, %−0,45 güvenli | 33, %+1,01 güvenli | 8, %+4,17 **çalışmaz** |
| 96 MHz | 104, %+0,16 güvenli | 32, %0 güvenli | 8, %0 güvenli |
| 125 MHz | 136, %−0,27 güvenli | 42, %−0,79 güvenli | 10, %+4,17 **çalışmaz** |
| 150 MHz | 163, %−0,15 güvenli | 50, %0 güvenli | 13, %−3,85 sınırda |

Benzetim (`tb/tb_uart_baud.v`, PC bit süresi gerçek nanosaniyeyle): 12 kombinasyonun 12'si PASS, 12'si eski `tb/tb_uart.v` ile de PASS. Dikkat: benzetim, "çalışmaz" işaretlenen 100 ve 125 MHz / 12 Mbaud kombinasyonunu da geçti. Sapma taramasında (e = (PC baud − FPGA baud)/FPGA baud) `CLKS_PER_BIT=8` için pencere −5…+2 %, 33 için −5…+4 %, 109 için −5…+5 %; 100 MHz'deki 12 Mbaud için e = −4 olduğundan pencerenin içindedir ama payı yaklaşık 1 puandır. Kart saat toleransı, FT2232H bölücü hatası ve kablo etkisi benzetimde yoktur; bu yüzden istemdeki %4 kuralına uyup bu iki kombinasyonu "çalışmaz" bıraktım. Akış testi: `tb_bert_tiny_ust` UART kipinde `CLKS_PER_BIT=8` ve 33 ile PASS (709 ve 706 kontrol, 0 hata, 3 satır).

Modelde olmayanlar (bilinmeyen): FT2232H/pyserial'in Windows'ta 12 Mbaud'u gerçekten vermesi doğrulanmadı. Dur-ve-bekle protokolünde her paket bir yanıt bekler (602 paket / 6 katman); paket başına USB gecikmesi ölçülmedi ve modele girmedi, gerçek süreyi uzatır. Host süresi (numpy) girmedi. 125 ve 150 MHz'in kapanıp kapanmadığı Konu 6'da belirlenecek.

Sürücü: `host/hizlandirici_surucu.py` içinde `baud` zaten kurucu parametresiydi; `uart_ayari(f_clk_hz, baud)` ve `SeriArkaUc(..., f_clk_hz=)` eklendi (eşik aşılırsa hata, sınırdaysa uyarı). Kartta denenmedi.

### Flaş tasarım notu (RTL yazılmadı, kart gerekir)

Amaç: ağırlıkları her çıkarımda UART'tan akıtmak yerine karttaki SPI flaştan okumak.
- Kapasite (ölçüldü/hesap): flaş 32 Mbit = 4 194 304 bayt; bitstream `bert_tiny_uart_ust.bit` 2 192 142 bayt (Vivado); boş 2 002 162 bayt (%47,7). Ağırlıklar 420 700 bayt (hesap); sığar.
- Yerleşim önerisi: ağırlık bölgesi bitstream sonundan sonra 64 KiB sınırına hizalı, ofset 0x220000 (hesap). Başlık: sihirli sayı, sürüm, katman sayısı, her katman için (K, C, panel sayısı, bayt ofseti), tablo CRC. Veri düzeni mevcut panel paketleriyle (`YUKLE_PANEL` yükü) aynı olursa mevcut panel tamponuna doğrudan akıtılır.
- Okuma modülü arayüzü (taslak): `adres[23:0]`, `uzunluk[15:0]`, `basla`, `veri[7:0]`, `veri_gecerli`, `bitti`; panel tamponu yazma arayüzü (`pw_en`, `pw_addr`, `pw_data`) ile birleşir.
- Hız (hesap): 4 hatlı okuma 80 MHz'de ≈40 MB/s → 420,7 KB için ≈10,5 ms; tek hat 50 MHz'de ≈6,25 MB/s → ≈67 ms. İkisi de 26,8 ms'lik hesap süresi ile aynı büyüklüktedir.
- Kartla doğrulanacaklar: yapılandırma sonrası flaş saatine erişim için STARTUPE2 gerektiği (hafızadan, **doğrulanmadı**) ve kart şemasında flaş veri/CS uçlarının kullanıcı G/Ç'si olarak erişilebilirliği; dört hatlı kipin etkinleştirilmesi (durum yazmacı biti); flaş programlama dosyasının (.mcs) birleştirilmesi.

### Yapılmayanlar

4 bit ağırlık: yeniden eğitim gerektirir; BERT-Tiny için denenmemiş; 210 KB yine çipin boş belleğine (≈157 KB) sığmaz. Yapılmadı.

## Konu 3 — Dolgu token'larını atla

Betikler: `scripts/konu3_token_uzunluk.py`, `scripts/konu3_dolgu_denetimi.py`, `scripts/kos_konu3_nb.py`, `scripts/konu3_cevrim_tablosu.py`.

**1. Uzunluk dağılımı (ölçüldü: tokenizer ve `dev.tsv`, `sim/token_uzunluk.json`, `sim/token_uzunluk.png`).** 872 cümle; token sayısı ([CLS] ve [SEP] dahil) ortalama 25,16, medyan 24,5, yüzde 90'ı 40, yüzde 99'u 51,3, en kısa 4, en uzun 55; 64'e kırpılan cümle yok. Blok sayısı (⌈uzunluk/8⌉) ortalama 3,59, medyan 3,5, yüzde 90'ı 5, en çok 7. T=64 üzerinden dolgu oranı %60,7, blok düzeyinde %55,1. İstemdeki "test cümleleri 4–6 token" gözlemi gerçek dağılımı temsil etmiyor: ortalama 25 token.

**2. Mantık denetimi (altın model, tam tamsayı hat, `sim/dolgu_denetimi.json`).** 872 cümlede her cümle ⌈uzunluk/8⌉×8 tokena kısaltıldı (anahtar maskesi korundu): logit farklı cümle 0, geçerli token satırlarının son gizli durumu farklı cümle 0, doğruluk tam dizide de kısaltılmışta da 718/872. Dolgu konumlarına (33 865 konum) rastgele token kimliği yazıldı: logit ve geçerli satırlar yine 0 fark. Sınıflandırma yalnız ilk token satırına bağlı (kod incelemesi: `02-RTL_Altin_Model/01_Kod/altin/model.py:327`, `h[:, 0, :]`); bu bilgi son katmanda yalnız [CLS] sorgu satırının hesaplanabileceğini gösterir, yapılmadı (ileri çalışma).

**3. RTL.** `NB` sabit parametreydi (`tile_denetleyici.v`). Eklenen: `cfg_nb` girişi (`tile_denetleyici`, `dogrusal_katman`), `komut_cozucu` çıkışı, CFG paketinin "bayrak" baytının bit 5:2 alanı. 0 ya da 8'den büyük değer 8 blok demektir; bu yüzden eski paketler ve eski sürücüler değişmeden aynı davranışı verir (paket biçimi, uzunluk ve diğer komutlar aynı). `host/hizlandirici_surucu.py` `cfg(..., nb=)`, `host/g9_host_dongusu.py` `--nb` aldı. Softmax ve LayerNorm komutları satır satır çalıştığı için host yalnız geçerli satırları gönderir; RTL değişikliği gerekmedi.
Doğrulama (benzetim): `tb_katman.v` (+`NBE`) ile 3 katman şekli × nb ∈ {1, 2, 4, 7, 8} = 15 koşu, hepsi PASS; yalnız ilk nb×8 token altın çıktıyla bit-birebir karşılaştırıldı, kalan (dolgu) blokların çıktısı hesaplanmadığı için karşılaştırmaya dahil değil. Host döngüsü (UART paketleriyle) nb = 1, 4, 7, 8 için 6 katmanda PASS, 0 uyuşmayan. Gerileme: G7 (12 katman), G10 (8 koşu), G4 (11 koşu) PASS ve nb=8 çevrimleri tabanla aynı (18 392 / 73 352 / 67 544).
Testbench düzeltmesi: `tb_katman.v` panel yükleyici, bir panel yüklenirken gelen `pan_bitti` darbesini kaçırıyordu (nb=1'de ilk denemede FAIL verdi). Darbeler sıraya alındı. Gerçek host'ta bu sorun yok: `komut_cozucu` `pan_bos`'u seviye olarak tutar.

Ölçülen doğrusal katman çevrimleri (benzetim, kos→layer_done):

| nb | q/k/v/attn_out | ffn1 | ffn2 | 12 katman toplamı |
|---|---|---|---|---|
| 1 | 2 838 | 11 334 | 8 982 | 63 336 |
| 2 | 4 664 | 18 440 | 16 952 | 108 096 |
| 4 | 9 240 | 36 744 | 33 816 | 215 040 |
| 7 | 16 104 | 64 200 | 59 112 | 375 456 |
| 8 | 18 392 | 73 352 | 67 544 | 428 928 |

nb ≥ 2 için toplam tam olarak 53 472·nb + 1 152 (iki, dört, yedi, sekiz blokta ölçülenle birebir). nb=1'de ölçülen değer formülün (54 624) üstündedir: bu kadar kısa karolarda katman, testbench'in panel yükleme hızıyla (sözcük/çevrim) sınırlı kalıyor; gerçek UART'ta yükleme çok daha yavaştır (aktarım süresi Konu 2'de).

**4. Tam çıkarım çevrimi (`sim/token_atlama_onceki.json`).** Doğrusal: ölçüldü (nb=3, 5, 6 için formül). Dikkat çarpımları: hesap, nb ile orantılı (5 056·nb + 600; nb=8'de ölçülen 41 048 ile aynı; nb<8 ölçülmedi). Softmax ve LayerNorm: satır çevrimi ölçüldü, satır sayısı 4·token ve 5·token (hesap). Eski satır çevrimleriyle (2 049, 5 274):

| Token | nb | Toplam çevrim (hesap) |
|---|---|---|
| 4 | 1 | 207 256 |
| 6 | 1 | 276 388 |
| 25 | 4 | 1 100 014 |
| 64 | 8 | 2 682 200 |

Gerçek dağılımla ağırlıklı ortalama: 1 082 028 çevrim (10,82 ms @100 MHz, hesap), 64 token'a göre 2,48 kat az. Yeni satır çevrimleriyle (Konu 4) sonuç Konu 4 bölümünde.

## Konu 4 — Softmax ve LayerNorm bölmesi (hız) ve tablolar (alan)

### 4a — Bölme (hız)

**Seçenekler (başlangıç: bölme aşaması Softmax'ta 1 664/2 049, LayerNorm'de 4 352/5 274 çevrim).** Gözlem: Softmax'ta bölüm 255'i aşamaz (pay = 255·e + ⌊toplam/2⌋ ve e ≤ toplam), LayerNorm'de bölüm 17 bite sığar; ama eski seri bölücü 24 ve 32 yineleme yapıyordu. Aşağıdaki çevrim değerleri B, C, D için **hesap** (aşama süreleri ölçülen fazlardan), A için **ölçüldü** (benzetim).

| Seçenek | Softmax çevrim/satır | LayerNorm çevrim/satır | Ek DSP | Not |
|---|---|---|---|---|
| Eski seri bölücü (1 bit/çevrim, 24/32 yineleme) | 2 049 (ölçüldü) | 5 274 (ölçüldü) | 0 | taban |
| B. Seri bölücü, yalnız bölüm genişliği kadar yineleme (8 ve 17) | ≈1 025 | ≈3 354 | 0 | küçük LUT, her koşulda tam |
| C. Çevrimde 2 bit (taban-4) ve bölüm genişliği | ≈769 | ≈2 330 | 0 | B'den hızlı, kritik yol uzar |
| D. İki paralel seri bölücü (B ile) | ≈705 | ≈3 098 | 0 | iki bölücü alanı |
| **A. Satırda bir kez ters değer + eleman başına çarpma ve tek düzeltme (seçildi)** | **357 (ölçüldü)** | **329 (ölçüldü)** | **+10** | cevap kesin, boru hatlı |

Seçim nedeni: A, iki birimde toplam çevrimi en çok düşürür ve DSP bütçesine sığdı (tam sistem 87/90). B/C, DSP gerekirse (ör. saat artırma Konu 6) geri dönüş seçeneğidir; yapılmadı.

**Uygulama (`rtl/bolucu_ters.v`).** Bölme x = n/d (n, d işaretsiz): R = ⌊2^NW/d⌋ satırda bir kez, mevcut seri bölücü ile (NW+1 çevrim); her eleman için q0 = (n·R) >> NW, r = n − q0·d, q = q0 + (r ≥ d), kalan = r mod d ≠ 0. Kanıt: n < 2^NW ise q0 ∈ {q−1, q}, yani tek düzeltme yeter, yaklaşık sonuç yok. Çarpmalar giriş/çıkış yazmaçlıdır (`use_dsp`); gecikme 7 çevrim, her çevrimde bir eleman. Bölüm genişliğine sığmazsa doyar (Softmax'ta eski `min(q,255)` ile aynı). Softmax: NW=24, bölen 22 bit, bölüm 8 bit. LayerNorm: NW=31, bölen 20 bit, bölüm 17 bit (negatif pay için taban: −⌈|pay|/std⌉ düzeltmesi korundu). LayerNorm elemanları artık kesintisiz boru hattından geçer (bölme → ×gamma → ×M0 → yuvarla/kaydır → +beta, kırp); aritmetik ifadeler değişmedi. Durum numaraları 4 bitte kaldı; faz anlamları değişti.

**Doğrulama (benzetim).** Bölücü birim testi (`scripts/kos_bolucu_ters.py`, `tb/tb_bolucu_ters.v`, `sim/bolucu_ters_sonuc.json`): her yapılandırmada 125 000 bölen × 8 bölünen = 1 000 000 çift (uniform, bit uzunluğu uniform, ⌊k·d⌋−1, k·d, (k+1)·d−1, doyma sınırı, köşe değerleri; art arda ve rastgele boşluklu besleme), Softmax ve LayerNorm yapılandırmalarında 0 hata (Softmax'ta 119 135, LayerNorm'de 113 851 çift doyma durumunda). 6 mutantın hepsi yakalandı (tek düzeltme silindi; ters değerin en düşük biti silindi; kalan bayrağı düzeltmeden önce alındı; doyma kontrolü silindi; `≥` yerine `>`; taslak bölümde taşma bayrağı silindi). İlk koşuda bir mutant kaçtı: taslak bölümdeki doyurma gereksizdi (taşma bayrağı çıkışı zaten doyuruyor), eşdeğerdi; gereksiz mantık kaldırıldı ve mutant, anlamlı bir bozulmayla değiştirildi.
Sistem testleri: `kos_g11.py` PASS (Softmax 325 satır/20 800 kontrol, LayerNorm 485 satır/62 080 kontrol, 0 hata); `tb_bert_tiny_ust` PASS (karşılaştırılan çıkış baytları aynı: Softmax 20 820, LayerNorm 62 108; toplam çevrim 4 200 546 → 1 260 711, benzetim). Kontrol sayısı 175 390 → 95 935 düştü çünkü testbench DURUM sorgularını da sayıyor ve birimler çabuk bittiği için daha az sorgu yapılıyor. G11 mutantları: eski 5 mutantın 3'ü yakalandı, 2'si önceki gibi açıklanmış eşdeğer; 4 yeni mutantın (gerçek veri vektörleriyle) 2'si (tek düzeltme silindi; `≥` yerine `>`) yakalandı; diğer ikisi (ters değerin en düşük biti, kalan bayrağı) gerçek veride etkisiz kaldı, bölücü birim testinde yakalandı. Bunlar eşdeğer değildir, kaydın ayrı etiketi var (`birim_testinde_yakalandi`).

**Sonuç (satır başına çevrim; benzetim; hesap çevrimi: son girişten son çıkışa).**

| Birim | Önce | Sonra | Fazlar (sonra) |
|---|---|---|---|
| Softmax | 2 049 | 357 | fark/indeks/üs 192, ters değer 1+28, besleme 64, toplama 64, boşaltma 7 |
| LayerNorm | 5 274 | 329 | ortalama 1, kareler 130, varyans 1, karekök 20, std 1, ters değer 1+35, besleme 128, boşaltma 11 |

Softmax toplamı (256 satır) 524 544 → 91 392, LayerNorm toplamı (320 satır) 1 687 680 → 105 280 çevrim (hesap: ölçülen satır × satır sayısı). 64 token için toplam: 2 682 200 → 666 648 çevrim (6,666 ms @100 MHz, hesap; doğrusal ve dikkat çevrimleri değişmedi). Gerçek uzunluk dağılımıyla ve token atlamayla birlikte (`sim/token_atlama_yeni.json`): 4 token 81 284, 6 token 87 430, 25 token 312 689, 64 token 666 648; dağılım ortalaması 289 538 çevrim (2,895 ms @100 MHz, hesap), 64 token'a göre 2,30 kat az.

**Kaynak ve zamanlama (Vivado).**

| Ölçüm | Önce | Sonra |
|---|---|---|
| Softmax tek başına (yalnız sentez): LUT / FF / DSP / WNS | 561 / 198 / 3 / +3,186 ns | 602 / 271 / 7 / +3,186 ns |
| LayerNorm tek başına (yalnız sentez): LUT / FF / DSP / WNS | 1 129 / 604 / 6 / +1,383 ns | 1 296 / 734 / 12 / +0,634 ns |
| Tam sistem (yerleştirme+yönlendirme): LUT / FF / DSP / BRAM | 5 540 / 5 390 / 77 / 15,5 | 5 712 / 5 582 / 87 / 15,5 |
| Tam sistem WNS / hold (100 MHz) | +0,587 / +0,024 ns | +0,628 / +0,024 ns |

DSP 87/90: 3 DSP boş. Ek DSP maliyeti: Softmax +4, LayerNorm +6. Tam sistemde en kötü setup yolu artık LayerNorm değil: `u_cd/pw_addr_reg` → `u_panel/w0_reg_*/RAM*/WADR5` (8,98 ns; %95 yönlendirme, mantık seviyesi 0); LayerNorm ters değer yolu (`u_ln/cnt_reg` → `u_dv/pm10..`, 9,07 ns, 12 seviye) +0,637 ns payla hemen arkada (`sim/zamanlama_konu4a.json`; ilk 5 setup ve 5 hold yolu). Saat artırma için (Konu 6) bunların ikisi de sınırdır.

## Konu 7 — Q·Kᵀ → Softmax çip içi zincirleme (yapılmadı, yalnız fizibilite)

Varsayılan karar: yapma; Q·Kᵀ sonucunun bilgisayar üzerinden taşınması bilinen sınır olarak kalır. Maliyet tahmini (kod yazılmadan; `dogrusal_katman.v`, `tile_denetleyici.v`, `softmax_birim.v` ve `TOP_NOTLARI.md` satır 46'ya bakılarak; hepsi **tahmin**): INT32 birikeç (`out_acc`) modülde zaten var ama çıkışta yalnız INT8'e yeniden ölçeklenmiş değer var (`cikis_paketle`, 8 token/64 bit). Çıkış akışı kanal dış, token iç döngüsünde ve karolar panel dış, blok iç sırasıyla gelir; Softmax bir sorgu satırının 64 anahtar skorunu birlikte ister, bu yüzden 64×64 INT32 skor matrisi (131 072 bit) bir kafa için tamamen tamponlanmak zorunda: ≈4 RAMB36 (BRAM 19,5 → ≈23,5 karo / 50), ek adres/çoğullayıcı ≈100–200 LUT. INT32 skoru Softmax girişine (INT32, kendi M0 ölçeği) indirgeyen yeniden ölçekleme için `yeniden_olcekle` benzeri bir ikinci birim gerekir (mevcut örnek 424 LUT ve 4 DSP). P (UINT8) çıkışını sonraki P·V karosunun aktivasyon BRAM düzenine yazmak için `cikis_paketle` benzeri bir paketleyici ve aktivasyon BRAM'ine ikinci yazma kapısı gerekir (≈10 LUT + çoğullayıcı). DSP ise darboğazdır: Konu 4a sonrası tam sistem 87/90 DSP kullanıyor; ek yeniden ölçekleme birimi (4 DSP) 90'ı aşar (91). Çözüm, mevcut `u_rq` birimini zamanda paylaşmak ya da Konu 4a'yı DSP'siz seçeneğe (B/C) çevirmektir; ikisi de bu çalışmanın kapsamı dışında. Kapsam büyüdüğü için başlanmadı.

## Konu 5 — LayerNorm 12 mi 16 bit mi (karar Rümeysa'nın)

Betikler: `scripts/konu5_ln_bit.py` (doğruluk), `sentez/konu5_sentez.tcl` (alan), `scripts/konu5_karar.py` (tablo: `sim/layernorm_bit_karari.json`, `sim/layernorm_bit_dogruluk.json`). Altın modelin dosyaları ve varsayılanları değiştirilmedi. `g_bit` (d/std'nin kesir biti ve gamma ölçeği, RTL'de `G`) 12 ve 16 ile, `ln_bit` (LayerNorm girdi veri yolu) 12 ve 16 ile koşuldu; tam tamsayı hat, 872 cümle (1 puan ≈ 8,72 cümle; 1–2 cümle farkı gürültüdür).

**Dikkat — ilk koşu geçersizdi.** `g_bit=16` ilk denemede 610/872 verdi. Neden: altın modelin `sabit_nokta_carp` fonksiyonu ara çarpımı int64'te tutuyor (yorumunda "birikeç 32 bit, M0 ≤ 31 bit"), g_bit=16'da `y·gamma_q·M0` 2^63'ü aşıyor ve taşıyor. Taşma güvenli (gerekirse Python büyük tamsayısı kullanan, yalnız bu betiğin sürecinde geçerli) hesapla `g_bit=16` 718/872 çıktı. 12 bit sonucunun bu yamayla değişmediği denetlendi (logitler birebir aynı). Taşma 35 çağrıda oldu; yani 16 bit seçilirse altın modelin ara çarpımı da genişlemelidir.

| Seçenek | Doğru / 872 | Varsayılandan ayrışan cümle | LUT | FF | DSP | BRAM (karo) | WNS @100 MHz (yalnız sentez) |
|---|---|---|---|---|---|---|---|
| g_bit=12, ln_bit=12 (varsayılan) | 718 | 0 | 1 205 | 676 | 12 | 1 | +0,372 ns |
| g_bit=16, ln_bit=12 | 718 | 2 (1 doğrudan yanlışa, 1 yanlıştan doğruya) | 1 508 | 785 | 13 | 0,5 | +0,138 ns |
| g_bit=12, ln_bit=16 | 717 | 5 | – | – | – | – | – |
| g_bit=16, ln_bit=16 | 718 | 4 | – | – | – | – | – |

Alan farkı (16 − 12): LUT +303, FF +109, DSP +1, WNS −0,234 ns. `ln_bit=16` için RTL sentezlenmedi. G=12 parametreli RTL, parametreleştirmeden önceki sürümle birebir aynı sentez sonucunu verdi (LUT 1 205, FF 676, DSP 12, WNS +0,372). G=16 sürümü benzetimde doğrulanmadı (yalnız sentez).

**Öneri (karar sizin).** g_bit=12'de kalınması: doğruluk 718 ile 718, iki cümle fark gürültüdür; 16 bit LUT'u %25, FF'yi %16 artırır, 1 DSP ve zamanlama payı (−0,23 ns) ekler, altın modelde de geniş çarpım gerektirir. ln_bit=16 de kazanç göstermiyor (717 ve 718).

### 4b — Tabloları BRAM'e taşıma (alan; hız kazandırmaz)

Taşınanlar: Softmax `lut` (512×16) ve LayerNorm `gam`, `bet` (128×16). Okuma eşzamanlı yapıldı ve adres, mevcut boru hattının bir önceki aşamasından sunuldu; bu yüzden **ek çevrim yok** (Softmax 357, LayerNorm 329 çevrim/satır aynı; `tb_bert_tiny_ust` toplam 1 260 711 çevrim aynı; `kos_g11.py` PASS, 0 hata). Taşınmayanlar: `sbuf`, `ebuf`, `mbuf` (Softmax) ve `buf_q` (LayerNorm); bunlar eleman döngüsünde asenkron okunuyor, eşzamanlı okuma ya eleman başına çevrim ekler ya da döngüyü yeniden yazmayı gerektirir. Hepsi toplam 64×32, 64×16 ve 128×18 bitliktir.

| Ölçüm (Vivado) | Önce (4a) | Sonra (4b) |
|---|---|---|
| Softmax tek başına (yalnız sentez): LUT / LUT-bellek / FF / BRAM karosu / WNS | 602 / 250 / 271 / 0 / +3,186 ns | 427 / 82 / 239 / 0,5 / +1,851 ns |
| LayerNorm tek başına (yalnız sentez): LUT / LUT-bellek / FF / BRAM karosu / WNS | 1 296 / 167 / 734 / 0 / +0,634 ns | 1 205 / 96 / 676 / 1 / +0,372 ns |
| Tam sistem (yerleştirme+yönlendirme): LUT / LUT-bellek / FF / BRAM karosu / DSP | 5 712 / 1 987 / 5 582 / 15,5 / 87 | 5 438 / 1 723 / 5 592 / 17 / 87 |
| Tam sistem WNS / hold (100 MHz) | +0,628 / +0,024 ns | +0,309 / +0,032 ns |

Ölçülen tasarruf 274 LUT'tur (%4,8); raporun önceki tahmini olan ≈1 940 LUT'a ulaşılmaz. Neden: tam sistemdeki 1 987 LUT-bellek'in 1 464'ü `u_panel` (`panel_tamponu`, ağırlık paneli) içindedir ve bu modül 4b aday listesinde yoktur; Softmax ve LayerNorm tablolarının payı yaklaşık 417 LUT'tur (bundan 264'ü taşındı). `panel_tamponu` Konu 6'da zamanlama gerekçesiyle ele alındı (aşağıda). BRAM kullanımı 15,5 → 17 karo (%34). Zamanlama payı 4b ile düştü: tam sistemde +0,628 → +0,309 ns; en kötü iki yol LayerNorm'de: ters değer girişinden önceki hazırlık zinciri (`u_ln/cnt_reg` → `u_dv/..`, 9,37 ns) ve BRAM çıkışından `+beta` toplamı ile kırpmaya giden zincir (`bet_reg` → `out_data_reg`, 9,09 ns, 21 seviye) (`sim/zamanlama_konu4b.json`). Kapsam notu: hız ve alan sonuçları ayrı değerlendirilir; 4b yalnız alan kazancıdır.

## Konu 6 — Saat frekansı

Tüm sonuçlar Vivado yerleştirme+yönlendirme çıktısıdır (`xc7a35tcpg236-1`, `sentez/impl_periyot.tcl`: `basys3.xdc`'deki saat periyodu geçici bir kopyada değiştirilir); **kartta denenmedi**. Kısıtlama durumu: `rx`, `rst` giriş gecikmeleri ve `tx` çıkış gecikmesi XDC'de tanımlı değildir (`check_timing`: `no_input_delay` 2, `no_output_delay` 1), bu yüzden bu üç yol zamanlama sonucuna girmez. Kapanma payları çok dardır (150 MHz'de +0,012 ns).

**Başlangıç (4b durumu, 100 MHz, en kötü 20 setup yolu: `sim/zamanlama_yollari.json`).** WNS +0,309, hold +0,032 ns. 20 yolun 17'si LayerNorm (ters değer girişi öncesi hazırlık zinciri 9,37 ns; `bet` BRAM → toplama → kırpma 9,09 ns; yuvarlama+kaydırma 9,32 ns), 3'ü `yeniden_olcekle` girişi (`u_tile/o_idx → u_rq/prod`, 8,69 ns, %73 yönlendirme).

**Kök neden bulguları.** (1) İstemde "PE dizisi (≈5,5 ns) sorun değil" deniyordu; 100 MHz için doğru, ama bu yolun payı yalnız ≈0,7 ns idi: `pe.v` çarpma-toplamayı tek çevrimde yapıyor ve DSP48E1 `acc_reg` hücresinin B girişindeki kurulum süresi **3,738 ns** (giriş/M yazmacı kullanılmıyor), yani yol 5,5 + 3,7 ≈ 9,2 ns eşdeğeridir. 125 MHz'de PE yolu +0,071 ns ile sınırdaydı. (2) Vivado, çıkış yazmaçlarını DSP giriş yazmacına emiyor; bu yüzden tile çıkışındaki 64:1 çoğullayıcı + bias toplamı DSP girişine bindi. (3) `panel_tamponu` ağırlık dizileri dağıtık RAM'di (1 464 LUT) ve yazma adresinin yayılımı kritik yoldu.

**Yapılan değişiklikler (hepsinde ilgili testler PASS; ayrı commit'ler).**
1. `panel_tamponu`: iki dizi + okuma çoğullayıcısı yerine tek bellek `{tampon, k}`, eşzamanlı okuma → BRAM (okuma gecikmesi aynı, 1 çevrim). `komut_cozucu`: CRC baytında karar zincirinin (komut geçerli, bayt şekli) önceden yazmaca alınması. LayerNorm: boru hattı bölündü (ters değer girişi öncesi 3 aşamalı hazırlık; yuvarlama toplamı, kaydırma ve `+beta`/kırpma ayrı aşamalar).
2. `tile_denetleyici`: golge eleman seçimi ve bias toplaması ayrı aşamalarda (katman başına +1 çevrim).
3. LayerNorm: karekök yinelemesi 2, sonra 3 çevrim/yineleme; `p1·M0` çarpması iki kısmi çarpım + toplama; `gam` BRAM çıkışı ile DSP girişi arasına yazmaç.
4. `systolic_nxn`: satır/sütun besleme yazmaçlarına bir aşama eklendi (göreli kayma aynı); tile süresi K+2N−2 → K+2N−1.
5. Softmax eleman döngüsü (eleman başına 4 durum) kesintisiz boru hattına çevrildi (357 → 171 çevrim/satır); `yeniden_olcekle`: kaydırma ile kırpma ayrı aşamalar; `tile_denetleyici`: son blok indeksi kayıtlı.
Her adım bit-birebirdir: G4 (11), G7 (12 katman), G10 (8), G11 (Softmax 325, LayerNorm 485 satır; mutantlar aynı sonuç), `tb_bert_tiny_ust` (94 795 kontrol), host döngüsü (6 katman) PASS, G13 mutantlarının 5'i yakalandı.

**Basamaklar (Vivado, yerleştirme+yönlendirme).**

| Kısıt | RTL durumu | WNS (ns) | Hold (ns) | LUT / FF / BRAM / DSP | Sonuç |
|---|---|---|---|---|---|
| 100 MHz | 4b başlangıç | +0,309 | +0,032 | 5 438 / 5 592 / 17 / 87 | kapandı |
| 100 MHz | 1. grup (panel BRAM, LayerNorm bölme, komut çözücü) | +0,716 | +0,031 | 3 774 / 5 720 / 19 / 87 | kapandı |
| 125 MHz (8 ns) | + tile ara aşama | −0,248 (TNS −0,88; 10 uç nokta) | +0,007 | 3 826 / 5 795 / 19 / 87 | **kapanmadı**: LayerNorm karekök döngüsü (`one_reg → res_reg`, 22 seviye) |
| 125 MHz | + karekök 2 çevrim | +0,033 | +0,025 | 3 811 / 5 836 / 19 / 87 | **kapandı** |
| 125 MHz, MMCM'li üst modül | (aynı RTL) | +0,116 | +0,016 | 3 824 / 5 959 / 19 / 87 | **kapandı** (`MMCME2_ADV` 1; türetilmiş saat 125 MHz) |
| 150 MHz (6,67 ns) | + PE yazmacı | −0,443 (TNS −55,9; 240 uç) | +0,020 | 3 881 / 6 032 / 19 / 87 | kapanmadı: LayerNorm `p1·M0` DSP→DSP zinciri |
| 150 MHz | + çarpma iki aşama | −0,480 (TNS −18,7; 160 uç) | +0,031 | 3 869 / 6 048 / 19 / 87 | kapanmadı: Softmax, `yeniden_olcekle`, `gam`→DSP |
| 150 MHz | + Softmax boru hattı, `rq`, `gam` yazmacı | −0,325 (TNS −21,2; 202 uç) | +0,017 | 3 799 / 6 198 / 19,5 / 87 | kapanmadı: Softmax bölücü girişi, tile blok sayacı |
| 150 MHz | + besleme yazmacı, `son_blk` | −0,009 (1 uç) | +0,020 | 3 797 / 6 109 / 19,5 / 87 | kapanmadı: karekök `t_sum → res` |
| 150 MHz | + karekök 3 çevrim | **+0,012** (TNS 0) | +0,051 | 3 785 / 6 121 / 19,5 / 87 | **kapandı**, pay çok dar |
| 150 MHz, MMCM'li | (aynı RTL) | −0,162 (TNS −1,1; 64 uç) | +0,023 | 3 780 / 6 260 / 19,5 / 87 | **kapanmadı**: `u_rq/prod` DSP zinciri; MMCM saatinde ayrık jitter 0,126 ns |
| 175 MHz (5,71 ns) | (aynı RTL) | −1,017 (TNS −354,9; 870 uç) | +0,020 | 3 859 / 6 369 / 19,5 / 87 | **kapanmadı**: komut çözücü `cmd_reg → *_reg/CE` (8 seviye, %71 yönlendirme) |

Özet: **kartta kullanılacak MMCM'li yolda en yüksek kapanan frekans 125 MHz**; MMCM'siz kısıtla (yalnız çizelgeleme denemesi) 150 MHz +0,012 ns ile kapandı; 150 MHz'in MMCM'li sürümü 0,162 ns geride kaldı; kapanmayan ilk basamak 175 MHz: ilk 20 yolun tamamı komut çözücüdeki geniş CE yayılımıdır (ölçüldü); MMCM'li 150 MHz koşusunda ayrıca `yeniden_olcekle` çarpımı ve tile→PE yolu sınırdaydı. Bunların düzeltilmesi (komut çözücü çözümlemesinin yazmaçlanması, `rq` çarpımının bölünmesi) yapılmadı. İstemdeki "gerçekçi hedef 150–200 MHz" için 150 MHz sınırında, 200 MHz'den çok uzaktır. Artix-7 -1'de DSP48E1/BRAM'in tam boru hatlı sınırı için veri sayfasında ≈450 MHz civarı değeri (hafızadan) doğrulamadım; bu çalışmanın ölçtüğü sınır PE'nin tek çevrimli çarpma-toplaması (DSP B kurulumu 3,74 ns) ve komut çözücüdür. Hold payı 0,007–0,051 ns aralığında kaldı (4b: +0,032).

**MMCM üst modülü (`rtl/bert_tiny_mmcm_ust.v`).** `MMCME2_BASE`, giriş saati `clk` (100 MHz, `basys3.xdc` aynı), çıkış 100·CARPAN/BOLEN (parametreler 1/8 adımlı tamsayı), `locked` iç reset'e bağlı (2 kademeli senkron bırakma), UART `CLKS_PER_BIT` parametre. Icarus'ta MMCM modeli olmadığından `-DMMCM_YOK` ile MMCM atlanır ve saat doğrudan geçer (benzetimde frekans değişmez); MMCM yalnız Vivado'da sınandı, kartta denenmedi. UART bölücüleri (Konu 2 tablosu): 125 MHz'de 921 600 baud için 136, 3 Mbaud için 42, 12 Mbaud için 10 (hata %+4,17, "çalışmaz"); 150 MHz'de 163, 50 ve 13 (hata %−3,85, "sınırda"). `tb_uart_baud` ile (109/100, 163/150, 50/150, 13/150, 136/125, 8/96) ve `tb_uart` ile son RTL üzerinde PASS.

**Süre = çevrim ÷ frekans (hesap; çevrim artışları ile birlikte).** Konu 4a sonrası → Konu 6 sonrası çevrim değişimi: Softmax 357 → 171 çevrim/satır; LayerNorm 329 → 377 (boru hattı aşamaları +8, karekök 20 → 60 çevrim); doğrusal katmanlar 428 928 → 431 256 (+%0,54, tile +1); dikkat çarpımları 41 048 → 41 568.

| Durum | Frekans | Çevrim (64 token) | Süre |
|---|---|---|---|
| Konu 1 başlangıç | 100 MHz | 2 682 200 | 26,822 ms |
| Konu 4a sonrası | 100 MHz | 666 648 | 6,666 ms |
| Konu 6 sonrası | 100 MHz | 637 240 | 6,372 ms |
| Konu 6 sonrası | 125 MHz (MMCM'li, Vivado'da kapandı) | 637 240 | 5,098 ms |
| Konu 6 sonrası | 150 MHz (yalnız MMCM'siz kısıtta kapandı) | 637 240 | 4,248 ms |

Gerçek uzunluk dağılımı ve token atlama ile (`sim/token_atlama_son.json`): 4 token 79 520, 6 token 84 658, 25 token 301 529 çevrim; 872 cümlelik ortalama 278 148 çevrim (100 MHz'de 2,781 ms, 125 MHz'de 2,225 ms, 150 MHz'de 1,854 ms; hesap), 64 token'a göre 2,29 kat az. Bu süreler yalnız hesap süresidir; ağırlık aktarımı (Konu 2: 420,7 KB için 921 600 baud'da 4,565 sn, 12 Mbaud'da 0,351 sn) ayrıca eklenir ve hesap süresinin yüzlerce katıdır.

## Konu 8 — Birleşik sonuç

Toplam süre modeli: **hesap süresi + ağırlık aktarım süresi (+ host, ölçülmedi)**. Üç terim ayrı:

| Terim | Önce | Sonra | Etiket |
|---|---|---|---|
| Hesap çevrimi (64 token, N=8) | 2 682 200 | 637 240 | doğrusal ve dikkat ölçüldü (benzetim); Softmax/LayerNorm satır ölçüldü, toplam hesap |
| Hesap süresi @100 MHz | 26,822 ms | 6,372 ms | hesap |
| Hesap süresi @125 MHz (MMCM'li, Vivado'da kapandı) | – | 5,098 ms | hesap |
| Hesap süresi @150 MHz (yalnız MMCM'siz kısıtta kapandı) | – | 4,248 ms | hesap |
| Hesap süresi, gerçek uzunluk ortalaması (25,2 token), @100 MHz | – | 2,781 ms | hesap (token atlama + ölçülmüş çevrimler) |
| Ağırlık aktarımı (420,7 KB, 8N1) | 4,565 sn @921 600 baud | 0,351 sn @12 Mbaud (96 MHz'de tam bölünür; ölçülen trafik 715 kB ile 0,596 sn) | hesap (kartta denenmedi) |
| Host | ölçülmedi | ölçülmedi | – |

Hesap süresi 26,8 ms → 6,4 ms (1 çevrim = 10 ns) düştü, ama ağırlık aktarımı hesap süresinden hâlâ en az iki büyüklük mertebesi uzun (0,351 sn / 6,4 ms ≈ 55; 4,565 sn / 6,4 ms ≈ 716). Bu mimaride bilgisayar işlemcisine göre hız kazancı beklenmez; bu çalışma darboğazı ölçüp daraltmıştır, kazanç iddiası yoktur.

**Konu başına etki (tüm kalemler `sim/etki_tablosu.csv` içinde, makine tarafından üretilmiştir).**

| Konu | Değişen kalem | Önce | Sonra | Yöntem | Etiket |
|---|---|---|---|---|---|
| 2 | UART: 12 Mbaud için `CLKS_PER_BIT` ve hata | 100 MHz'de 8, %+4,17 ("çalışmaz") | 96 MHz'de 8, %0 | `sure_modeli`, `tb_uart_baud` | hesap / benzetim |
| 3 | Doğrusal çevrim, 25 token (4 blok) | 428 928 | 216 216 | `tb_katman +NBE`, `kos_konu3_nb` | benzetim |
| 4a | Softmax çevrim/satır | 2 049 | 357 (Konu 6 sonrası 171) | `tb_softmax` | benzetim |
| 4a | LayerNorm çevrim/satır | 5 274 | 329 (Konu 6 sonrası 377) | `tb_layernorm` | benzetim |
| 4a | Tam sistem DSP | 77 | 87 | Vivado | Vivado |
| 4b | Tam sistem LUT / LUT-bellek / BRAM | 5 712 / 1 987 / 15,5 | 5 438 / 1 723 / 17 | Vivado | Vivado |
| 6 | Tam sistem LUT / LUT-bellek / BRAM (100 MHz) | 5 438 / 1 723 / 17 | 3 774 / 356 / 19 | Vivado | Vivado |
| 6 | Tam sistem WNS / hold @100 MHz | +0,309 / +0,032 ns | +0,716 / +0,031 ns | Vivado | Vivado |
| 6 | En yüksek kapanan frekans (MMCM'li) | 100 MHz (denenmedi) | 125 MHz (+0,116 ns) | Vivado | Vivado |
| 8 | Toplam çevrim, 64 token | 2 682 200 | 637 240 | ölçülen parçalar | hesap |

Nihai tam sistem (150 MHz kısıtlı koşu, `konu6i_p6_67`): LUT 3 785, FF 6 121, BRAM 19,5, DSP 87/90 (başlangıç: 5 540 / 5 390 / 15,5 / 77). 4b ve Konu 6 başlangıcı arasındaki LUT düşüşünün (5 438 → 3 774 = 1 664) 1 367'si LUT-bellek düşüşüdür ve `panel_tamponu`'nun BRAM'e geçmesinden gelir; bu bir alan kazancıdır ve hız kazancıyla aynı cümlede anılmaz.

## Giriş/çıkış kısıtları ve sentez sonrası benzetim (3 Kasım 2026)

**150 MHz kapandı (Vivado).** LayerNorm ölçek çarpımının çıkışına bir yazmaç aşaması eklendi; 150 MHz'de WNS −0,017 → +0,174 ns, hold +0,024 ns, DSP 87. Bedeli: LayerNorm 377 → 378 çevrim/satır (benzetim, G11).

**Giriş/çıkış kısıtları.** `check_timing` öncesi: 2 girişte giriş gecikmesi, 1 çıkışta çıkış gecikmesi yoktu. `sentez/basys3.xdc`'e `rx`, `tx` ve `rst` için `set_false_path` eklendi (gerekçeleri dosyada; kart devresinden alınmış gecikme değeri olmadığı için `set_input_delay` değeri uydurulmadı). `bert_tiny_uart_ust.v`'ye 2 kademeli reset senkronlayıcı eklendi. Sonuç (Vivado, 6,667 ns): kısıtsız port 0, 3 port false path ile kapsanıyor; WNS +0,014 ns, hold +0,029 ns; LUT 3 559, FF 6 072, BRAM 19,5, DSP 87. UART testleri (`tb_uart`, `tb_uart_baud`) PASS. Pin atamaları kartta denenmedi.

**Sentez sonrası benzetim (xsim).** Ağ listeleri `sentez/ps_ust_sentez.tcl` ile üretildi. UART testbench'i (`sim/postsynth_ust/tb_ps_ust.v`, 8 kontrol; ağ listesinde hiyerarşik yazmaç okunamadığı için asıl testten 2 kontrol çıkarıldı): sentez sonrası işlevsel PASS (50 sn), yerleştirme-yönlendirme sonrası SDF'li PASS (1 214 sn, duvar saati). Testbench 100 MHz saatle koşar, ağ listesi 150 MHz kısıtla yönlendirilmiştir. Tam vektör kümesi (175 390 kontrol) ağ listesinde **koşturulmadı**; ham sayılar `sim/io_ve_zamanlamali_benzetim.json`.

## Soldan sağa zincirleme (Q·Kᵀ → Softmax → P·V) tasarım notu — ONAY BEKLİYOR, kod yazılmadı (3 Kasım 2026)

Bu bölüm, istemdeki zincirleme konusunun zorunlu tasarım notudur. Onay verilmeden RTL'e dokunulmayacak. Sayıların hepsi **hesap** ya da **tahmin**dir; ölçüm yoktur.

1. **Skor tamponu.** Tile sırası panel dış, token bloğu iç döngüdür; bir panel yalnız 8 anahtar kanalı üretir, bir sorgu satırı için 64 anahtarın tamamı sekiz panel sonunda hazır olur. Bu yüzden bir kafa için 64 sorgu × 64 anahtar × 32 bit = 131 072 bit = 128 Kbit tampon gerekir; bu 4 RAMB36'dır (hesap; 3,6 → 4). Tam sistemde şu an 19,5 BRAM kullanılıyor (Vivado, 150 MHz koşusu), 4 eklenince ≈23,5/50 olur. Döngü sırası değiştirilirse (token bloğu dış, panel iç) tampon 8 sorgu × 64 anahtar × 32 bit = 16 Kbit olur (yarım RAMB36), fakat anahtar panelleri her token bloğunda yeniden yüklenmek zorunda kalır; bu yeniden yükleme maliyeti ölçülmeden karar verilemez. Önerilen: önce 4 RAMB36'lık tam tampon (daha az risk), BRAM bütçesi yeterli.
2. **Çıkış düzeni.** Tile 8 token × 8 kanal verir (kanal dış, token iç); Softmax bir satırı (64 anahtar) sırayla ister. Skor tamponu satır-öncelikli adreslenirse (adres = sorgu×64 + anahtar) yazma kanal-öncelikli gelir, okuma satır sırasıyla yapılır; ek dönüşüm tamponu gerekmez, dönüşümü adresleme yapar. Softmax çıkışı UINT8 olasılıktır; P·V aktivasyon sözcüğü (`b*K+k`, bayt i = P[b*8+i][k]) 8 bayt/sözcük olduğundan 8 sorgu satırı bir araya gelmeden sözcük yazılamaz: 8 satır × 64 bayt = 512 bayt ara tampon (hesap; 1 RAMB18 ya da dağıtık RAM).
3. **Anahtar maskesi.** Dolgu anahtarlarının skoru Softmax'a maske biti ile gitmeli (`softmax_giris_maske` zaten var). Etkin blok sayısı (`ayar_blok_sayisi`) ile birlikte: etkin olmayan anahtar sütunları maskelenir, etkin olmayan sorgu satırları hiç işlenmez. Maske kaynağı CFG alanı olacak (yeni alan değil, mevcut etkin blok sayısından türetilir).
4. **Eski yolun korunması.** Zincirleme kipi yeni bir CFG alanıyla (ya da yeni komutla) açılır; kapalıyken veri yolundaki yeni yazma kapıları pasif kalır ve `tb_hizlandirici` ile `tb_bert_tiny_ust` değişmeden PASS olmalıdır. Bu, ilk uygulama basamağında yeniden koşturulur.
5. **Hata, CRC, iptal.** Zincirleme sürerken geçersiz paket gelirse mevcut kurtarma (`softmax_iptal`) skor tamponunu geçersiz sayıp zinciri iptal eder ve HATA yanıtı döner; tampon içeriği bir sonraki başlatmada baştan yazıldığından ayrıca temizlik gerekmez. Bu davranış mutantlarla sınanacak.
6. **Kazanç ve maliyet (hesap).** Cihaz içi çevrim sayısı büyük ölçüde değişmez (Softmax 171 çevrim/satır × 64 satır × 2 kafa × 2 katman = 43 776 çevrim, zaten çalışıyor). Kazanç, skorun bilgisayara gidip dönmesinin kalkmasıdır: bir kafa için 4 096 skor × 4 bayt = 16 384 bayt; 921 600 baud'da 16 384 × 10 ÷ 921 600 ≈ 0,178 sn, 4 kafa için ≈0,71 sn (yalnızca skorun INT32 olarak taşındığı varsayımıyla; gerçek taşıma boyutu uygulamanın 6. basamağında ölçülecek). Ek kaynak tahmini: 4 RAMB36, ≈100–300 LUT. DSP 87/90: skoru Softmax ölçeğine indirgemek için yeni çarpma birimi eklenirse 90 aşılır; bu yüzden mevcut `yeniden_olcekle` birimi zamanda paylaşılmalı. Bu paylaşım karmaşıklığı ve DSP sınırı, zincirleme için en büyük risktir.

Onaydan sonra uygulama sırası: (a) birikecin dışarı verilmesi ve `l*_qk_birikec` karşılaştırması, (b) skor tamponu ve Softmax beslemesi (`l*_olasilik_u8` karşılaştırması), (c) P'nin aktivasyon düzenine yazılması ve P·V (`l*_av_birikec` karşılaştırması), (d) `bert_tiny_ust` içine bağlama, (e) en az iki yeni mutant, (f) zincirleme ve host yolu çevrim ölçümü.

## Mimari yeniden yapılandırma ve ad değişiklikleri (3 Kasım 2026)
**Not:** Bu dosyanın yukarıdaki bölümleri ölçümlerin yapıldığı andaki adları kullanır (`komut_cozucu` tek parça, `pe`, `systolic_nxn`, `cikis_tamponu` vb.). Aşağıdaki tablo eski adlardan yeniye çeviridir.

**Yeni yapı.** Komut baytı önce veri yolundaki gelen bayt yazmacına, oradan komut/uzunluk/başlık yazmaçlarına alınır. Komut yazmacı ve başlık `komut_cozucu`'ye verilir; çözücünün kontrol sinyalleri `kontrol_birimi`'ne, veri alanları veri yolundaki yazmaçlara gider. Yük sözcükleri veri yolunda toplanır ve veri yolu üzerinden belleklere (aktivasyon, ağırlık paneli, GELU tablosu, Softmax tablosu, LayerNorm parametreleri) yazılır. CRC doğruysa kontrol birimi komutu uygular (ayar yazmaçlarına yükleme, birim darbeleri, yanıt isteği). İşlem birimleri (`dogrusal_katman`, `softmax_birim`, `layernorm_birim`) ve sonuç tamponları `veri_yolu` içindedir. Host protokolü (komut kodları, bayt biçimi, CRC8, yanıt biçimi) değişmedi.

Her baytın işlenmesi bir çevrim gecikir (gelen bayt yazmacı); iki bayt arası UART'ta en az 80 çevrim olduğundan çıkarım süresi ve doğrusal/dikkat/Softmax/LayerNorm çevrim sayıları değişmedi (G11: Softmax 171, LayerNorm 377 çevrim/satır; G7 ve G10 çevrimleri öncekiyle aynı).

| Eski ad | Yeni ad |
|---|---|
| `komut_cozucu` (tek parça) | `komut_cozucu` (yalnız çözme) + `kontrol_birimi` (durum makineleri) + `veri_yolu` (yazmaçlar, bellekler, birimler) |
| `hizlandirici_ust`, `hizlandirici_uart_ust` | kaldırıldı; aynı komutlar `bert_tiny_ust` / `bert_tiny_uart_ust` ile çalışır |
| `pe` | `islem_elemani` |
| `systolic_nxn` | `sistolik_dizi` |
| `bram_sdp` | `cift_kapili_bellek` |
| `gelu_lut` | `gelu_tablosu` |
| `cikis_paketle` | `cikis_sozcuk_toplayici` |
| `cikis_tamponu` (iki örnek: `u_smb`, `u_lnb`) | `sonuc_tamponu` (`u_softmax_sonuc_tamponu`, `u_layernorm_sonuc_tamponu`) |
| `bolucu_ters`, `bolucu_seri` | `ters_bolucu`, `seri_bolucu` |
| `uart_rx`, `uart_tx` | `uart_alici`, `uart_verici` |
| `tb_pe`, `tb_systolic_nxn`, `tb_bolucu_ters`, `tb_requant` | `tb_islem_elemani`, `tb_sistolik_dizi`, `tb_ters_bolucu`, `tb_yeniden_olcekle` |

Başlıca sinyal adları: `kos`→`calistir`, `busy`→`mesgul`, `layer_done`→`katman_bitti`, `cfg_k/np/nb/n`→`ayar_k/ayar_panel_sayisi/ayar_blok_sayisi/ayar_kaydirma`, `aw_*`→`aktivasyon_yaz_*`, `pw_*`→`panel_yaz_*`, `lw_*`→`gelu_yaz_*`, `cr_addr/cr_data`→`cikis_oku_adres/cikis_oku_veri`, `pan_*`→`panel_*`, `sm_*`→`softmax_*`, `ln_*`→`layernorm_*`, Softmax/LayerNorm girişleri `in_*`→`giris_*`, çıkışları `out_*`→`cikis_*`, `m0`→`olcek_m0`. Parametreler: `AW/KW/PW`→`ADRES_GENISLIGI/K_GENISLIGI/PANEL_GENISLIGI`, `N/NB`→`DIZI_BOYUTU/BLOK_SAYISI` (sistolik dizi, tile), `L`→`SATIR_UZUNLUGU` (Softmax), `N/G/Q_W`→`KANAL_SAYISI/KESIR_BITI/GIRIS_GENISLIGI` (LayerNorm). Modül içi yazmaç ve ara sinyal adları da açık Türkçe adlara çevrildi (örn. Softmax `carp`→`carpim1`, LayerNorm `y_v`→`bolum_a_gecerli`, tile `o_run`→`akitma_suruyor`).

Vivado projesi: eski dosya adları projeden çıkarılıp yenileri eklenmelidir; `sentez/proje_guncelle.tcl` bunu yapar. `sentez/*.tcl` dosya listeleri ve `-generic` adları, `scripts/` altındaki koşturucular ve mutant denetimleri yeni adlara uyarlandı. G13 mutant denetimi artık `veri_yolu`, `kontrol_birimi` ve `komut_cozucu` dosyalarını bozar (7 mutant).

## Yapılmayanlar ve nedenleri

- 4 bit ağırlık: yeniden eğitim gerektirir, BERT-Tiny için denenmemiş; 210 KB yine çip belleğine sığmaz.
- Flaş okuma modülü RTL'i: kart gerekir; yalnız tasarım notu yazıldı.
- Q·Kᵀ → Softmax çip içi zincirleme: kapsam dışı; fizibilite (Konu 7): ek BRAM ≈4 karo, ek DSP yeniden ölçekleme için 4 → toplam 91 > 90.
- Softmax `sbuf`, `ebuf`, `mbuf` ve LayerNorm `buf_q` BRAM'e taşınmadı: eleman başına eşzamanlı okuma gecikmesi ya çevrim ekler ya döngü yeniden yazımı gerektirir.
- Son kodlayıcı katmanında yalnız [CLS] sorgu satırını hesaplamak (sınıflandırma yalnız ilk token'a bağlı): yapılmadı, ileri çalışma.
- SWAT/SALTS (payda P·V sonrası), tablo tabanlı Softmax, QUARK: büyük yeniden yazım, ileri çalışma.
- 150 MHz'in MMCM'li sürümü ve 175 MHz: komut çözücünün geniş CE çözümlemesinin yazmaçlanması, `yeniden_olcekle` çarpımının bölünmesi, PE reset yayılımı yapılmadı.
- LayerNorm g_bit=16: öneri 12'de kalmak (karar Rümeysa'nın); 16 bit RTL benzetimde doğrulanmadı.
- Flaş/DDR dışında ağırlık sıkıştırması, daha büyük FPGA'ya ölçekleme: bu çalışmanın konusu değil.

## Açık kalanlar ve doğrulanmayanlar

- **Hiçbir sonuç kartta denenmedi.** Frekans sonuçları Vivado çıktısıdır, kartta çalışma kanıtı değildir. `rx`, `rst`, `tx` giriş/çıkış gecikmeleri XDC'de hâlâ tanımsızdır.
- FT2232H'nin ve Windows pyserial'in 12 Mbaud'u gerçekten vermesi doğrulanmadı. Paket başına USB gecikmesi (dur-ve-bekle protokolü, 6 katmanda 602 paket) ve host süresi ölçülmedi; aktarım süresini uzatırlar.
- Dikkat çarpımlarının `nb` ile ölçeklenmesi (token atlama) ölçülmedi, hesaptır (doğrusal katmanlar ölçüldü). `nb=1` doğrusal ölçümü testbench panel yükleme hızıyla sınırlı.
- G=16 RTL ve `ln_bit=16` RTL alanı benzetimde doğrulanmadı / sentezlenmedi.
- Konu 6 pay değerleri çok dar (125 MHz'de +0,033 / +0,116 ns, 150 MHz'de +0,012 ns); farklı Vivado sürümü ya da yerleşim bunu değiştirebilir.
- Altın modelin `sabit_nokta_carp` ara çarpımı int64'tür; g_bit=16 gibi daha geniş yapılandırmalarda taşar (Konu 5).
- Çalışma ağacında bu çalışmadan önce commit'lenmemiş G13 değişiklikleri bulundu ve ayrı bir commit olarak kaydedildi (`0375cf3`).

## Sayıların kaynakları

Ham sayılar `03-RTL/sim/` altındadır: `hizlandirma_oncesi.json`, `hizlandirma_sonrasi.json`, `etki_tablosu.csv`, `sure_modeli.json` (taban) ve `sure_modeli_son.json` (son RTL), `uart_kombinasyonlari.csv`, `token_uzunluk.json`, `dolgu_denetimi.json`, `nb_olcum.json`, `token_atlama_onceki.json` ve `token_atlama_son.json`, `bolucu_ters_sonuc.json`, `g11_sonuc.json`, `g7_sonuc.json`, `g10_sonuc.json`, `layernorm_bit_dogruluk.json`, `layernorm_bit_karari.json`, `zamanlama_*.json` (Vivado yolları), `g19_ozet.json` (+ `g19_ozet_onceki.json`). Vivado metin raporları `03-RTL/sentez/cikti/` altında `konu4a_*`, `konu4b_*`, `konu5_*`, `konu6*_*` adlarıyla. Test günlükleri `sim/*_log.txt`. Betikler `03-RTL/scripts/` ve `03-RTL/sentez/*.tcl`.
