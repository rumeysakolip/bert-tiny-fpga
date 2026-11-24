# PROMPT — BERT-Tiny FPGA hızlandırıcısını hızlandırma çalışması (araştırma + uygulama, tek dosya)

Sahibi: Rümeysa Kolip · Çalışma klasörü: `C:\Users\rumey\Documents\biitirme-projem` (bundan sonra `PROJE/`) · Başlangıç: 2 Kasım 2026 · Hedef: 13 Kasım 2026 ara raporuna girecek ölçülmüş sonuçlar
Bu dosya Claude Code için tek başına yeterlidir. Önce bölüm 0–3'ü oku, sonra bölüm 4'teki konuları sırayla yürüt.

---

## 0. Nasıl çalışacaksın

Danışman sayısal tasarım kararlarında destek veremiyor; kararlar bu çalışmada **maliyet ve hız** ölçütüyle, ölçerek verilecek. Her konuda aynı döngüyü uygula:

1. **Ölç:** mevcut durumu ölç ve kaydet (tahmin değil).
2. **Seçenekleri karşılaştır:** yazılı olarak kısa bir tablo (seçenek, beklenen kazanç, maliyet, kart gerekir mi). Önceki araştırma sonuçları bölüm 3'te; onları başlangıç al, yeni bulgunla düzelt.
3. **En ucuz ve en hızlı seçeneği uygula;** bit-birebir doğrulamayı koru.
4. **Ölç ve kaydet:** önce/sonra sayısını aynı yöntemle al.
5. **Yapmadığın seçenekleri** nedenleriyle birlikte "ileri çalışma" olarak yaz.

Konuları bölüm 4'teki sırayla yap: önce en ucuz ve kart gerektirmeyenler. **Zaman daralırsa kesme sırası:** Konu 8, sonra 6, sonra 5, sonra 7. Asgari teslim: Konu 1, 2, 3 (ölçüm ve mantık denetimi), 4. Bir konunun kabul ölçütü sağlanmadan sonrakine geçme; sağlanamıyorsa nedenini yaz ve bölüm 6'ya göre dur.

## 1. Kurallar

1. `00-FP32_Egitim/`, `01-INT8_Nicemleme/`, `02-RTL_Altin_Model/` ve `old/` klasörlerine **dokunma**, yalnız oku. Yeni iş `03-RTL/`, `host/` ve `rapor_sistemi/` altında yapılır.
2. **Ölçülmeyen sayı yazma.** Benzetim "benzetim", Vivado çıktısı "Vivado", hesapla bulunan "hesap" ya da "tahmin" diye etiketlenir. Hız iddiası yalnız ölçülen çevrim ve süreyle yazılır.
3. **Bit-birebir kural:** RTL çıktıları altın modelle (`02-RTL_Altin_Model/01_Kod/altin/`) birebir aynı kalmalı, hata sayısı 0 olmalı. Uyuşmazlıkta suç RTL'dedir. Altın modelin varsayılan davranışını **değiştirme**; yalnız mevcut parametrelerle (ör. LayerNorm bit genişliği) karşılaştırma koşusu yapabilirsin. Bit-birebir tutturulamazsa dur ve sor.
4. Başarısızlığı olduğu gibi raporla; uydurma. Eşdeğer çıkan mutantı "yakalandı" diye sayma.
5. Kod, yorum, commit ve not dili Türkçe. RTL Verilog-2001, Icarus uyumlu, parametrik, magic number yok.
6. Raporda ve kodda anlamı metinden anlaşılmayan gönderme kullanma (açıklamasız görev kodu, "madde N" işareti). Neye atıf yapıldığını her seferinde yaz.
7. Her konu bitince: kabul ölçütünü koştur, son satırı (PASS ve hata sayısı) kanıt olarak kaydet, **küçük bir `git commit`** at (Türkçe, tek satır). **`git push` yapma.**
8. Belirsizlik veya eksik girdi varsa **dur ve sor**.
9. Hız iddiasını CPU'ya göre yazma. CPU 2,49 ms; mevcut FPGA hesabı ≈11 kat uzun, ağırlık aktarımı ayrıca bunun üstüne biniyor. Bu çalışma "darboğazı ölçüp daraltmak" içindir.

## 2. Mevcut durum (başlangıç değerleri; Konu 1'de yeniden ölç, farklıysa durumu bildir)

Süre modeli: `toplam süre = hesap çevrimi ÷ frekans + ağırlık aktarım süresi (+ host)`. Üç terimi ayrı ölç, ayrı raporla.

| Kalem | Değer | Kaynak ve etiket |
|---|---|---|
| Doğrusal katmanlar (12) | 428 928 çevrim | `sim/g19_ozet.json`, ölçüldü (benzetim) |
| Dikkat çarpımları (Q·Kᵀ, P·V) | 41 048 çevrim | ölçüldü (benzetim) |
| Softmax | 524 544 çevrim = 2 049 çevrim/satır × 256 satır | satır ölçüldü, toplam **hesap** |
| LayerNorm | 1 687 680 çevrim = 5 274 çevrim/satır × 320 satır | satır ölçüldü, toplam **hesap** |
| Toplam | 2 682 200 çevrim ≈ 26,822 ms @100 MHz | hesap |
| Softmax bölme aşaması | 1 664 / 2 049 çevrim (≈%81) | `sim/g11_sonuc.json` |
| LayerNorm bölme aşaması | 4 352 / 5 274 çevrim (≈%83) | `sim/g11_sonuc.json` |
| Ağırlık aktarımı | ≈420,7 KB; 921 600 baud'da ≈4,6 sn | hesap |
| Zamanlama | 100 MHz'de setup payı +0,587 ns (en uzun yol ≈9,41 ns, en çok ≈106 MHz), hold +0,024 ns | `sentez/cikti/bert_tiny_uart_ust_impl_zamanlama.txt`, Vivado |
| Kaynak | tam sistem 5 540 LUT, 77/90 DSP (rapor); doğrusal katman sistemi 3 702 LUT, 68 DSP | `sentez/cikti/*kullanim.txt`; ikisinden hangisinin neyi ölçtüğünü yaz |

Kritik yollar (Vivado, 100 MHz kısıtı): ilk beşten üçü LayerNorm çarpma-toplama zincirinde (`u_ust/u_ln/p2_reg__0` → `p2s_reg[*]`, ≈9,1–9,3 ns, 19–20 mantık seviyesi, 14'ü CARRY4); biri komut çözücüde (`u_ust/u_cd/cmd_reg` → `ln_m0_reg` CE, gecikmenin %78'i yönlendirme); biri PE dizisinde (≈5,5 ns, sorun değil).

Kart: elde yok. Tüm sonuçlar benzetim ve Vivado çıktısıdır.

## 3. Araştırma sonuçları (başlangıç noktası; konularda bunları kullan)

Kaynaklar açılıp okundu (2 Kasım 2026), bunların dışında kaynak uydurma.

**Ağırlık aktarımı**
- Karttaki USB-seri çip FT2232H UART kipinde 12 Mbaud'a kadar destekliyor ([FT2232H veri sayfası](https://www.physics.umd.edu/hep/drew/495/ft2232hq_datasheet.pdf)). 12 Mbaud'da 420,7 KB ≈0,35 sn (hesap: 420,7 KB × 10 bit ÷ 12 Mbit/s). 100 MHz saat 12 Mbaud'a tam bölünmez (≈8,33); 96 MHz bölünür (96 ÷ 12 = 8). Windows'ta pyserial'in 12 Mbaud'u gerçekten verip vermediği **doğrulanmadı**.
- Basys3'te 32 Mbit (4 MB) flaş var; 35T bitstream'i ≈2 MB, flaşın ≈%48'i kullanıcı verisine boş ([Basys 3 Reference Manual](https://www.fdi.ucm.es/profesor/mendias/das/docs/basys3_rm.pdf)). Ağırlıklar 420,7 KB; sığar. Flaş (S25FL032P) dört hatlı okuma 80 MHz ≈40 MB/s ([veri sayfası](https://www.fdi.ucm.es/profesor/mendias/das/docs/Infineon-S25FL032P_32-Mbit_3.0_V_Flash_Memory-DataSheet-v13_00-EN%20(3).pdf)) → teorik ≈10 ms. Yapılandırmadan sonra flaşı FPGA'dan okumak için saat pinine erişim gerektiği bilgisi hafızadan, **doğrulanmadı**. Kart gerekir.
- 4 bit ağırlık önerilmez: yeniden eğitim gerekir; BERT-base'te 4 bit yeniden eğitimle kayıpsız ([Wu ve ark., ICML 2023](https://arxiv.org/pdf/2301.12017)) ama BERT-Tiny'de denenmemiş; 210 KB yine de çipin boş belleğine (≈35 BRAM ≈157 KB) sığmaz. **Yapma.**
- BRAM toplamı 1 800 Kbit (225 KB), 420,7 KB'lık ağırlıklar çipe sığmaz; mimari karar (PC host, FPGA hızlandırıcı) bunun üzerine kurulu.

**Softmax ve LayerNorm**
- Bir satırdaki tüm elemanlar aynı paydayı kullanır (Softmax: toplam; LayerNorm: standart sapma). Satır başına bir kez ters değer + eleman başına düzeltme ile bit-birebir bölme mümkün; genel tasarım tekniği.
- Literatürde bunun dışındaki seçenekler (bir anket üzerinden, özgün makaleler okunmadı): paydayı P·V'den sonra uygulamak (SWAT, SALTS, 2024), tablo tabanlı Softmax (Li, 2024), ortak devre paylaşımı (QUARK, 2025, ZCU102'de denendi, küçük kartta sığması kanıtlanmadı) ([QUARK](https://arxiv.org/pdf/2511.06767), [anket](https://arxiv.org/pdf/2609.01212)). Büyük yeniden yazım gerektirir; "ileri çalışma".

**Dolgu token'ları**
- Uzunluğa duyarlı çizelgeleme ile uzunluğu bilmeyen tabana göre ortalama 3,1× hızlanma bildirilmiş ([Peng ve ark., 2022](https://arxiv.org/abs/2208.03646), Alveo U280).
- Bizdeki ucuz yol: host yalnızca gerçek uzunluğa yetecek kadar 8'lik token bloğu gönderir. Test cümleleri 4–6 token iken T=64 üzerinden hesap yapılıyor; gerçek SST-2 ortalaması daha uzun, **ölçmeden sayı yazma**.

**Diğer**
- LayerNorm 12 mi 16 bit mi: literatürle çözülmez; kendi verinle karar verilecek (doğruluk ve alan).
- Q·Kᵀ → Softmax çip içi zincirleme: literatürde yaygın ama doğrusal katmandan 32 bitlik çıkış portu ve skor tamponu gerekir. En ucuz yol yapmamaktı; kullanıcı yapılmasını istedi, bu yüzden Konu 8'de tasarım notu + onay + basamaklı uygulama olarak yer alıyor.

## 4. Konular (bu sırayla)

### Konu 1 — Başlangıç ölçümü (kabul ölçütü olmadan sonrakine geçme)
- `python scripts/g11_vektor_uret.py`, `python scripts/kos_g11.py`, `python ../host/g9_host_dongusu.py`, `tb/tb_bert_tiny_ust.v` (cwd: `03-RTL`). Softmax ve LayerNorm `PASS`, hata 0; 5 mutantın 3'ü yakalanır, 2'si açıklanmış eşdeğer; host döngüsü 0 fark.
- Çevrim sayıları bölüm 2'deki tabloyla uyuşmalı. Uyuşmuyorsa dur ve bildir.
- Başlangıç Vivado değerleri: Softmax ve LayerNorm yalnız (`sentez/g11_sentez.tcl` örnek) ve tam sistem (`sentez/sentez.tcl`, `sentez/impl.tcl`) için LUT, FF, DSP, BRAM, WNS, hold. Hepsini `sim/hizlandirma_oncesi.json` içine yaz; sonraki bütün karşılaştırmaların tabanı bu.
- Kabul: dosya var, çevrimler tabloyla uyumlu, testler PASS.

### Konu 2 — Ağırlık aktarımı (UART) · kart gerektirmeyen kısım
Yapılacaklar (ucuzdan pahalıya):
1. **Hesap/projeksiyon (en ucuz):** küçük bir Python betiği (`scripts/sure_modeli.py`) yaz: toplam süre = hesap çevrimi ÷ frekans + ağırlık aktarımı, parametreler baud (921 600, 3 M, 12 M), frekans, ağırlık "çipte duruyor" varsayımı, dizi boyutu 4/8/16 (mevcut çevrim modeliyle). Çıktıyı `sim/sure_modeli.json` ve CSV olarak ver; her satırda "hesap/tahmin" etiketi.
2. **UART hızı:** `uart_rx.v` / `uart_tx.v` ve üst modüllerdeki `CLKS_PER_BIT` zaten parametrik. Seçilen frekanslarda (100, 96, 125, 150 MHz) 3 ve 12 Mbaud için `CLKS_PER_BIT = f ÷ baud` ve **hata yüzdesini** hesapla; hata ≈%4'ü aşıyorsa o kombinasyon "çalışmaz" diye işaretle. `tb_uart.v`'yi seçilen kombinasyonlarda koştur; PASS. `host/hizlandirici_surucu.py` baud'u parametre yapsın.
3. **Flaş:** yalnızca tasarım notu yaz (okuma modülü arayüzü, ağırlık yerleşimi, bitstream boyutu hesabı, kartla doğrulanacaklar). RTL yazma; kart gerekir, kapsam dışı.
4. **4 bit:** yapma. Sadece gerekçeyi notlara bir satır yaz.

Kabul: süre modeli üretildi; UART kombinasyonları tablosu hata yüzdeleriyle yazıldı; benzetim PASS; flaş notu var.

### Konu 3 — Dolgu token'larını atla (ölçüm → uygulama)
1. **Ölç (kod yazmadan önce):** 872 cümlelik doğrulama kümesinde token uzunluğu dağılımı (ortalama, medyan, yüzde 90, en uzun), `02-RTL_Altin_Model/01_Kod/altin/veri.py` ve tokenizer ile; `sim/token_uzunluk.json` + histogram. Bu dağılımla beklenen blok sayısı (`ceil(uzunluk ÷ 8)`) ve kazanç tahmini (**hesap**).
2. **Mantık denetimi (Python, altın model):** dolgu satırları atlanınca geçerli token çıktılarının değişmediğini, sınıflandırmanın yalnız ilk token'a bağlı olduğunu (pooler) ve doğrulama doğruluğunun 718/872 kaldığını göster. Dikkatte anahtar maskesi korunur. Bunu bozan bir durum bulursan dur.
3. **RTL uygulaması:** `tile_denetleyici.v` token blok sayısı (`NB`, şu an parametre) çalışma zamanında ayarlanabilir mi? Değilse `CFG` komutuna "etkin blok sayısı" alanı ekleme ihtimalini incele (`komut_cozucu.v`, `hizlandirici_surucu.py`, `g9_host_dongusu.py`). Softmax ve LayerNorm yalnız geçerli satırlar için çalışsın. Geçerli satırlarda çıktı altın modelle **bit-birebir**; dolgu satırlarının çıktısı karşılaştırmadan hariç tutulur ve bu açıkça yazılır.
4. **Ölç:** 4, 6, 25 ve 64 token için çevrim sayısını benzetimde al; dağılımla ağırlıklı ortalama (hesap) yaz.
- Kabul: dağılım ölçüldü; mantık denetimi geçti; RTL değişikliği varsa bit-birebir PASS ve ölçülmüş çevrimler tabloda. RTL yapılamazsa neden yazılı ve yalnız dağılım+hesap raporlanır.

### Konu 4 — Softmax ve LayerNorm bölmesini hızlandır (hız) + tabloları BRAM'e taşı (alan)
Bu iki iş aynı dosyalarda; ayrı commit'lerle yap, ayrı ölç. Darboğaz tablo erişimi değil, `rtl/bolucu_seri.v` (1 bit/çevrim).

**4a — Bölme (hedef: çevrim kazancı)**
1. Satırın paydası bilindiğinde bir kez `R ≈ 2^K ÷ payda` hesapla (mevcut seri bölücüyle, satır başına bir kez).
2. Her eleman için taslak bölüm `q0 = (pay × R) >> K` (DSP çarpımı).
3. Kalan `r = pay − q0 × payda`; `r < 0` ise `q0 − 1`, `r ≥ payda` ise `q0 + 1`, aksi halde `q0`. Yetmezse `K` genişliğini artır; yaklaşık sonuç bırakma.
4. LayerNorm'de işaretli paydada **taban (floor)** semantiğini koru (mevcut `dv_r != 0` düzeltmesine bak).
5. **Yeni çarpmaları baştan boru hatlı yaz** (DSP girişinde ve çıkışında yazmaç; `(* use_dsp = "yes" *)`).
6. Alternatif (DSP sığmazsa): çevrim başına 2–4 bit çıkaran bölücü ya da 2 paralel bölücü. Seçimi ve nedenini yaz.
- Doğrulama: yeni bölücü modülü ayrı testbench'te Python referansıyla tüm sınır değerler + ≥1 000 000 rastgele çift (Softmax: pay < 2^24, payda 1…2^22; LayerNorm: RTL'deki işaretli genişlikler), hata 0. Sonra `kos_g11.py` PASS, hata 0. **En az 2 yeni mutant** ekle (ör. düzeltme yönlerinden birini sil, ters değer genişliğini bir bit kısalt); test onları yakalamalı.
- Ölç: satır başına çevrim (Softmax, LayerNorm), eski 2 049 / 5 274 ile yan yana.
- DSP uyarısı: tam sistem 77/90 DSP. 90'ı aşıyorsa dur ve bildir.

**4b — BRAM (hedef: alan, hız değil)**
- Adaylar: Softmax `lut [0:511]`, `sbuf`, `ebuf`; LayerNorm `gam`, `bet`, `buf_q`. `bram_sdp.v` kalıbını ve Vivado'nun RAM çıkarım kurallarını kullan (eşzamanlı okuma, sıfırlamasız dizi). Okuma gecikmesi bir çevrim artabilir; ölç ve yaz.
- Ölç: LUT, FF, BRAM önce/sonra (`sim/hizlandirma_oncesi.json` ile). Raporun önceki tahmini ≈1 940 LUT serbest kalır; **ölçülen** sayıyı yaz, tahmini değil.
- Bu iş hız kazandırmaz; hız ve alan sonuçlarını aynı cümlede birleştirme.

**4c — Sistem içinde ölçüm (hesap yerine ölçüm):** rapordaki "çevrimlerin %82'si Softmax ve LayerNorm'de" payı şu an satır çevrimi × satır sayısı ile **hesaplanmış** durumda (bu birimler doğrusal katmanla zincirli değil). `tb_bert_tiny_ust.v` host sürümlü akışı içinde Softmax ve LayerNorm satırlarının BASLAT'tan son çıkışa çevrimini ölç, kullanılan sayıların hangi log'dan geldiğini yaz. Tek benzetimde bütün çıkarım koşturulamıyorsa toplam payı hesap olarak bırak ve bunu açıkça etiketle. Konu 8 yapılırsa zincirleme yolun payını da ölç.

Kabul: testler PASS, hata 0, yeni mutantlar yakalandı, önce/sonra çevrim ve kaynak tabloda.

### Konu 5 — LayerNorm 12 mi 16 bit mi (kendi verinle karar)
- Altın modelde bu zaten parametre (`g_bit`); varsayılanı değiştirme, yalnız 12 ve 16 ile iki koşu yap: 872 cümlede doğruluk (kaç cümle fark etti, "gürültü: 1–2 cümle farkı üstünlük sayılmaz" kuralı), RTL'de LUT/FF/DSP/WNS (16 bit sürümü bir kez sentezle).
- Çıktı: karar tablosu (`sim/layernorm_bit_karari.json`) ve tek paragraf öneri. Kararı Rümeysa verir; sen tabloyu ve gerekçeli öneriyi sun, kararı kendin uygulama.
- Kabul: iki koşu da var, sayılar kaynak dosyalardan.

### Konu 6 — Saat frekansı (hedef: çevrim süresi)
Sırayı bozma: Konu 4 ve 3'ten sonra yap; çünkü yeni çarpıcılar yeni uzun yollar yaratır.
1. En kötü 20 yolu al (`report_timing_summary -max_paths 20`), modül bazında grupla → `sim/zamanlama_yollari.json`.
2. **LayerNorm çarpma-toplama zincirini böl:** çarpım, yuvarlama toplama ve kaydırma/kırpma ayrı boru hattı aşamalarına. Yalnız yazmaç eklenir, aritmetik aynı; mevcut `S_M1`, `S_M2`, `S_SH` durumlarına bak.
3. **Komut çözücüdeki yüksek yayılımı azalt** (`komut_cozucu.v`: kayıt çoğaltma, CE'yi önceden hesaplama, kod çözmeyi erken yapma). Davranış aynı.
4. Hold (+0,024 ns): LUT-RAM yerine BRAM'e geçiş (Konu 4b) bunu rahatlatabilir; her değişiklikten sonra hold'u yaz.
5. Her değişiklikten sonra testler PASS; sonra `sentez/impl.tcl` ile WNS/hold ölç.
6. **Saati kademeli yükselt:** önce yalnızca `create_clock` periyodunu düşürerek (8 ns = 125 MHz, 6,67 ns = 150 MHz) yolu kısıtla sına; kapanırsa MMCM'li gerçek tasarıma geç. **Kapanmayan en düşük basamağı ve nedenini de raporla.**
7. MMCM: Basys3 osilatörü 100 MHz; `MMCME2_BASE` ile hedef frekans; `locked` sinyali reset'e bağlı. Icarus'ta MMCM modeli yoksa `ifdef` ile benzetimde atlayan ince bir sarmalayıcı yaz ve bunu açıkça not et.
8. UART bölücüsünü yeni frekansa göre yeniden hesapla (Konu 2 tablosu); 12 Mbaud yalnız 96 MHz gibi 8'e bölünen saatte tam tutar. `tb_uart.v` yeni parametrelerle PASS.
9. Boru hattı aşamaları çevrim sayısını artırır: **süre = çevrim ÷ frekans** tablosunu çevrim artışıyla birlikte göster. Artix-7 -1'de DSP48E1 ve BRAM tam boru hatlı bile yaklaşık 450 MHz civarında sınırlı (hafızadan; veri sayfasından doğrula); gerçekçi hedef 150–200 MHz. Daha yüksek iddia yazma.
- Kabul: testler PASS; 100 MHz'de en uzun yol <9 ns ya da olmaması yazılı; en yüksek kapanan frekans ve kapanmayan ilk basamak Vivado raporundan alıntıyla; süre tablosu.

### Konu 7 — Giriş/çıkış zamanlama kısıtları ve sentez sonrası zamanlamalı benzetim (tam sistem)
Son tasarım üzerinde yap (Konu 6'dan sonra), çünkü frekans ve boru hattı değişiklikleri zamanlamayı değiştirir. Bu, ara raporun "Sınırlar" bölümündeki iki açığı kapatır: giriş/çıkış kısıtlanmadı; üst modülün sentez sonrası ve zamanlamalı benzetimi yapılmadı.

**7a — Giriş/çıkış kısıtları**
1. Başlangıç: `sentez/cikti/bert_tiny_uart_ust_impl_zamanlama.txt` içindeki `check_timing` bölümünde `no_input_delay (2)` ve `no_output_delay (1)` var (rx, rst, tx). Bunları sayıp not et.
2. `sentez/basys3.xdc` için kısıt öner ve uygula. UART (`uart_rx_pin`, `uart_tx_pin`) saatle eşzamansızdır; `uart_rx.v` girişi 2 FF ile senkronlar. Bu durumda gerekçesi yazılı `set_false_path` (rx için `-from`, tx için `-to`) doğru yaklaşımdır; her kısıtın yanına neden yazılı olsun. Alternatif olarak `set_input_delay` / `set_output_delay` kullanacaksan değerlerin kaynağını (kart devresi, çip veri sayfası) yaz; uydurma değer koyma.
3. `rst` (btnC, düğme) eşzamansızdır ve tasarımda doğrudan kullanılıyorsa **reset senkronlayıcı yoksa** `bert_tiny_uart_ust.v` içine 2 FF'li bir reset senkronlayıcı eklemek gerekir. Bu RTL değişikliğidir: ayrı commit'te yap, bütün testler PASS kalsın (`rst` düğmesi basılıyken davranış aynı, bırakma saatle hizalı).
4. Kısıtlardan sonra `impl.tcl`'yi yeniden koştur: `check_timing` çıktısında `no_input_delay` / `no_output_delay` sayıları 0 olmalı ya da kalan her biri nedenle açıklanmalı. WNS ve hold değişimini yaz.
5. **Kartta denenmedi:** pin atamaları (`basys3.xdc`) kartta doğrulanmadı. Bu uyarıyı kısıt dosyasının başında bırak.

**7b — Sentez sonrası ve zamanlamalı benzetim**
1. Önce `sentez/ps_sentez.tcl` (8×8 dizi için kurulmuş, `write_verilog -mode funcsim`) örneğini incele; tam sistem `bert_tiny_uart_ust` için benzeri bir betik yaz (`sentez/ps_ust_sentez.tcl`): sentez sonrası ağ listesi (`-mode funcsim`) ve yerleştirme-yönlendirme sonrası ağ listesi + SDF (`write_verilog -mode timesim`, `write_sdf`).
2. **Sentez sonrası işlevsel benzetim:** `tb/tb_bert_tiny_ust.v` ağ listesi üzerinde xsim ile koşar (`TOP_NOTLARI.md` bölüm 4'te xsim komutları var). GSR için testbench başlangıcına gecikme gerekir (8×8 dizi çalışmasında 200 ns kullanılmıştı; `sim/postsynth/tb_ps.v`). Beklenen: `PASS (… kontrol, 0 hata)`, aynı kontrol sayısı.
3. **Zamanlamalı (SDF) benzetim:** tam vektör kümesi (175 390 kontrol) çok yavaşsa **küçültülmüş** bir koşu yap (ör. gerçek UART'lı 2+2 satırlık sürüm, 448 kontrol) ve küçültüldüğünü açıkça yaz. Süreleri (duvar saati) kaydet. Çok yavaşsa ya da araç lisansı/bellek sorunu varsa dur, nedeniyle bildir; uydurma.
4. Ağ listesi benzetiminin davranışsal sonuçla bit-birebir aynı çıktığını göster. Farklı çıkarsa nedeni (GSR, başlangıç değerleri, eşzamansız reset) incele; sebebi bulamazsan dur.
- Kabul: kısıtlı `check_timing` sayıları, sentez sonrası işlevsel `PASS` ve (varsa) SDF'li küçültülmüş koşu `PASS`, hepsi sayılarla `sim/io_ve_zamanlamali_benzetim.json` içinde; yapılamayan kısım nedeniyle yazılı.

### Konu 8 — Q·Kᵀ → Softmax çip içi zincirleme (en riskli; Konular 1–7 bittikten sonra)
Şu an: `dogrusal_katman` çıkış BRAM'i INT8 tutar; INT32 birikeç (`out_acc`) modül içinde var ama dışarı verilmiyor (`TOP_NOTLARI.md` bölüm 3). Softmax girişi INT32 skor ister; veri bilgisayar üzerinden taşınıyor. Hedef: Q·Kᵀ birikeçlerinin Softmax'a, Softmax'ın UINT8 olasılıklarının P·V çarpımına çip içinde akması.

**Önce tasarım notu yaz ve kod yazmadan dur; kullanıcı (Rümeysa) onaylasın.** Not şunları içermeli:
1. Tile denetleyici sırası "panel dış döngü, token bloğu iç döngü" (`tile_denetleyici.v`): bir panel yalnız 8 anahtar kanalı verir. Bir sorgu satırı için 64 anahtarın hepsi gelene kadar Softmax başlayamaz. Bu yüzden skor tamponu gerekir; boyutu (64 sorgu × 64 anahtar × 32 bit = 16 KB = 4 BRAM36 mi, döngü sırası değişirse daha küçük mü?) hesapla, BRAM (şu an 15) ve DSP (77/90) bütçesiyle karşılaştır.
2. Çıkış düzeni: tile 8 token × 8 kanal verir (kanal dış, token iç); Softmax bir satırı (64 elemanı) sırayla ister; sonuç UINT8 olasılıklar P·V girdisi için aktivasyon BRAM sözcüğü düzenine (`b*K+k`, bayt i = P[b*8+i][k]) dönüştürülmeli. Dönüşüm için kaç satırlık ara tampon gerektiğini yaz.
3. Anahtar maskesi (dolgu) Softmax'a nasıl taşınacak? Konu 3'teki etkin blok sayısı ile birlikte düşün.
4. Mevcut host yolunun bozulmaması: yeni zincirleme kipi bir CFG alanı/komutuyla açılsın; kapalıyken eski davranış **birebir** korunsun (`tb_hizlandirici` ve `tb_bert_tiny_ust` değişmeden PASS).
5. Hata/CRC/iptal davranışı (`softmax_iptal` vb.) zincirleme kipinde ne olur?
6. Tahmini çevrim kazancı (**hesap**) ve ek kaynak.

**Onaydan sonra uygulama, her basamakta bit-birebir:**
1. `out_acc`'ı dışa ver; testbench'te Q·Kᵀ birikeçlerini `l*_qk_birikec` ile karşılaştır (mevcut `tb_dikkat_qk.v`, `scripts/kos_g10.py` düzeni örnek).
2. Skor tamponu + Softmax beslemesi (anahtar maskesi dahil); çıkışı `l*_olasilik_u8` ile karşılaştır.
3. P'yi aktivasyon düzenine yaz; P·V'yi `a_isaretsiz` bayrağıyla (UINT8 olasılık için 9 bit A) koştur; `l*_av_birikec` ile karşılaştır (`tb_dikkat_av.v`).
4. Hepsini `bert_tiny_ust` içine bağla; tam sistem testleri PASS.
5. **En az 2 yeni mutant** (ör. maske bitini sabitle, tampon indeksini bir kaydır); testler yakalamalı.
6. Ölç: zincirleme yol çevrimi (yalnız cihaz içi çevrim; UART baytlarını ayrı say) ile host üzerinden taşıma yolunun cihaz içi çevrimi yan yana. Kazancı ölçülen sayıyla yaz.
- Kabul: dört karşılaştırma `PASS`, 0 hata; eski yol değişmeden PASS; mutantlar yakalandı; DSP ≤ 90, zamanlama ihlali yok. Bir basamak bit-birebir tutmuyorsa dur, ne denediğini yaz, kısmi sonucu raporla.

### Konu 9 — Birleşik sonuç tablosu ve rapor girdisi
- `sim/g19_ozet.json` ve `rapor_sistemi/g19_tablo.csv`: Softmax ve LayerNorm satırları **ölçülen yeni satır çevrimleriyle** yeniden hesaplanır (hâlâ hesap; bu birimler sisteme bağlı değil, etiketle). `rtl_toplam_cevrim` ve ms değeri eski (2 682 200 çevrim, 26,822 ms) ile yan yana.
- Konu başına etki: tek bir tablo (konu, değişen kalem, önce, sonra, ölçüm yöntemi, etiket).
- Toplam süre modeli (bölüm 2 formülü): hesap süresi, ağırlık aktarım süresi ve (varsa) host süresi ayrı satırlarda. CPU ile **kıyaslamayı** yalnız "bu mimaride kazanç beklenmiyor" gerçeğiyle yaz.
- `03-RTL/HIZLANDIRMA_NOTLARI.md` (kısa, Türkçe, görsel ağırlıklı değil, sayı ağırlıklı): her konunun sonucu, yapılmayanlar ve nedenleri, açık kalanlar, her sayının hangi log/json dosyasından geldiği.

## 5. Çıktılar

1. `03-RTL/HIZLANDIRMA_NOTLARI.md`
2. `sim/hizlandirma_oncesi.json`, `sim/hizlandirma_sonrasi.json`, `sim/token_uzunluk.json`, `sim/sure_modeli.json`, `sim/layernorm_bit_karari.json`, `sim/zamanlama_yollari.json`, `sim/io_ve_zamanlamali_benzetim.json`, `sim/zincir_sonuc.json` (Konu 8 yapılırsa)
3. Güncellenmiş `rtl/`, `tb/`, `scripts/kos_g11.py` (yeni mutantlarla), `host/hizlandirici_surucu.py` (baud parametresi), `sentez/basys3.xdc` (giriş/çıkış kısıtları), `sentez/ps_ust_sentez.tcl`
4. Konu başına ayrı, küçük commit'ler (push yok)
5. Her konunun sonunda sohbette üç satırlık özet: ne değişti, ne ölçüldü, kabul geçti mi

## 6. Dur ve bana sor

- Bit-birebir tutmuyor ve neden RTL'de değil, altın modeldeyse.
- DSP 90'ı aşıyor, ya da zamanlama (setup/hold) ihlali oluşuyor.
- Bir konunun kabul ölçütü sağlanamıyorsa (denediklerini ve nedeni yaz, uydurma).
- Saat/MMCM/UART/kısıt gibi karta özgü bir değişiklik kartsız doğrulanamıyorsa: ayrı commit'te yap ve "kartta denenmedi" diye işaretle.
- Kapsam büyüyorsa (ör. flaş okuma modülü yazmak, yeniden eğitim, LayerNorm'ü de zincire bağlamak, P·V sonrası çıkış izdüşümüne kadar tam zincir) bu çalışmanın kapsamında **değil**; sormadan başlama. Konu 8 (Q·Kᵀ → Softmax) için tasarım notunu bitirince onay beklemek zorunludur.

## 7. Rapora girerken dürüstlük notları

- Bu çalışma CPU'ya karşı hız kazancı iddiası taşımaz; yalnız ölçülen çevrim ve süre düşüşünü gösterir.
- BRAM taşıma alan kazancıdır; hız kazancıyla aynı cümlede anılmaz.
- Frekans artışı yerleştirme-yönlendirme (Vivado) sonucudur; kartta çalışma kanıtı değildir. Giriş/çıkış gecikmeleri (rx, rst, tx) hâlâ kısıtlanmamışsa bunu yaz.
- Hesapla bulunan her sayı "hesap/tahmin" etiketli; ölçülen yalnız benzetim veya Vivado çıktısından gelenler.
- 872 cümlede 1 puan ≈ 8,72 cümle; 1–2 cümlelik farklar gürültüdür, üstünlük iddia etme.
