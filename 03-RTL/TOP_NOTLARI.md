# TOP_NOTLARI — `bert_tiny_ust` / `bert_tiny_uart_ust` (G13)

> **Güncel adlar için:** Bu belge G13 sürümünün modül adlarıyla (`komut_cozucu` tek parça, `u_cd`, `u_kat`, `cikis_tamponu` vb.) yazılmıştır. Komut çözücü `komut_cozucu` + `kontrol_birimi` + `veri_yolu` olarak bölündü ve modüller yeniden adlandırıldı; eski-yeni ad tablosu `HIZLANDIRMA_NOTLARI.md` "Mimari yeniden yapılandırma" bölümündedir.

Doğrusal katman, Softmax ve LayerNorm artık **tek üst modülde birlikte** sentezlenir, yerleştirilir, yönlendirilir ve bitstream üretilir.
**Kartta çalıştırma yapılmadı.** Aşağıdaki "Vivado çıktısı" sayıları `sentez/cikti/` raporlarından alınmıştır; "benzetim" olanlar Icarus ve Vivado xsim (davranışsal, RTL düzeyi) sonucudur; sentez sonrası (post-synthesis) benzetim yapılmadı.

## 1. Modüller ve portlar

| Dosya | İş |
|---|---|
| `rtl/bert_tiny_ust.v` | Bayt akışı arayüzlü tam sistem: `komut_cozucu` (`u_cd`) + `dogrusal_katman` (`u_kat`) + `softmax_birim` (`u_sm`) + `layernorm_birim` (`u_ln`) + iki `cikis_tamponu` (`u_smb`, `u_lnb`). Portları `hizlandirici_ust` ile aynı (rx_valid/rx_data, tx_valid/tx_data/tx_ready/tx_bos, paket_sayisi, hata_sayisi). |
| `rtl/bert_tiny_uart_ust.v` | Kart üst modülü: `uart_rx` + `uart_tx` + `bert_tiny_ust`. **Portlar** `clk, rst, uart_rx_pin, uart_tx_pin` — `hizlandirici_uart_ust` ile aynı, `sentez/basys3.xdc` **değişmeden** kullanılır (fiziksel pin eklenmedi). |
| `rtl/cikis_tamponu.v` | Softmax (64 bayt) / LayerNorm (128 bayt) çıkış akışını yakalayan bayt tamponu; `SM_OKU`/`LN_OKU` buradan okur. Birimler bu tampon ve komut çözücü üzerinden tx pinine bağlı olduğundan sentezde silinmez. |
| `rtl/komut_cozucu.v` | Yeni komutlar eklendi (aşağıda). 0x01–0x07'nin bayt biçimi ve davranışı değişmedi. |
| `rtl/hizlandirici_ust.v` | Yalnız yeni port tie-off'ları eklendi (girişler 0, çıkışlar açık). Eski üst modül ve `hizlandirici_uart_ust` hâlâ çalışır/sentezlenir. |

`softmax_birim.v`, `layernorm_birim.v`, `bolucu_seri.v`, `dogrusal_katman.v` ve alt modüllerine **dokunulmadı**.
`bolucu_seri` iki birimin içinde örneklendiği için ayrıca örneklenmez (dosya listesine eklidir).

## 2. Host protokolü (paket: `cmd(1) len(2,LE) payload crc8`, yanıt ACK/HATA/VERI — eskisiyle aynı)

| Kod | Komut | Yük | Not |
|---|---|---|---|
| 0x08 | SM_LUT | adres(2, giriş no) + 2 B/giriş (LE, 16 bit) ×512 | exp tablosu; yazma CRC'den önce uygulanır (idempotent) |
| 0x09 | SM_CFG | m0 (3 B, LE, 24 bit) | CRC doğruysa uygulanır |
| 0x0A | SM_BASLAT | boş | Birimi bir çevrim sıfırlar (abort), sonra `start` verir; `m0` start'ta örneklenir |
| 0x0B | SM_VERI | 5 B/eleman: skor (4 B LE, işaretli) + maske (1 B, bit0) | akış; **CRC'den önce** uygulanır |
| 0x0C | SM_OKU | adres(2) adet(2) (bayt) | VERI: `adet` bayt UINT8 olasılık (tampon 64 B) |
| 0x0D | LN_PAR | adres(2, kanal no) + 4 B/kanal: gamma(2, LE) beta(2, LE) ×128 | idempotent |
| 0x0E | LN_CFG | eps_q (5 B LE, 40 bit) + m0 (4 B LE, 31 bit) + nsh (1 B) | CRC doğruysa uygulanır |
| 0x0F | LN_BASLAT | boş | Softmax ile aynı |
| 0x10 | LN_VERI | 3 B/eleman: q (LE, alt 18 bit işaretli; host 24 bit işaret genişletilmiş gönderir) | akış; CRC'den önce |
| 0x11 | LN_OKU | adres(2) adet(2) (bayt) | VERI: `adet` bayt INT8 (tampon 128 B) |

**DURUM** (0x06) yanıtı yine 2 bayt. Bayt0 = `{akış_hata, ln_hazır, sm_hazır, ln_busy, sm_busy, taşma, layer_done, busy}` — bit 0–2 eskisiyle aynı, bit 3–7 eskiden 0'dı. Bayt1 değişmedi.
`sm_hazır`/`ln_hazır`: son çıkış tampona yazıldı (BASLAT'ta silinir). Host "hazır && !busy" bekleyip OKU yapar.

**HATA kodları:** 1 CRC, 2 bilinmeyen komut (0x12 ve üstü dahil), 3 uzunluk hatası (kısa yük, yarım eleman, tampon dışı OKU aralığı).

## 3. Tasarım kararları

- **Akış komutları CRC'den önce uygulanır.** 320 B'lık skor akışını CRC sonrasına kadar tutmak ek tampon ister. Bunun yerine: CRC hatası (HATA 1) alınırsa host **BASLAT'tan yeniden başlar**; BASLAT birimi sıfırladığı için yarım kalmış giriş temizlenir (testte denendi: satır 1'de akış ortasında bozuk CRC, ardından kurtarma, çıktı doğru). Birimlerin kendi RTL'i değişmedi; sıfırlama üst modülde `rst | *_abort` ile yapılır.
- **CFG komutları CRC doğruysa uygulanır** (bozuk CRC'li CFG'nin etkisiz olduğu testte doğrulandı).
- Hazır olmayan birime (BASLAT'sız ya da L/N eleman dolduktan sonra) veri gelirse eleman **atılır** ve DURUM bit 7 yükselir; BASLAT bit'i siler.
- Okuma yolu `cr_addr` çıkışını yeniden kullanır (tampon okuması 1 bayt/sözcük); dogrusal katmanın çıkış BRAM'i bu sırada okunmaz sayılır, zararsızdır.
- Dur-ve-bekle kuralı değişmedi: yanıt tamamlanmadan yeni paket gönderilmez.
- **İç zincirleme (Q·Kᵀ → Softmax → P·V) YAPILMADI**, görev tanımındaki "isteğe bağlı" adım. Koddan sorunun yanıtı: `dogrusal_katman` çıkış BRAM'i **INT8** tutar (`cikis_paketle`, 8 token/64 bit sözcük); INT32 birikeç (`out_acc`) modül içinde var ama dışarı verilmiyor. Softmax girişi INT32 skor ister; zincirleme için `out_acc`'ın ayrı bir porta/tampona çıkarılması gerekir. Veri şimdilik host üzerinden taşınır.

## 4. Doğrulama (benzetim)

| Test | Sonuç |
|---|---|
| `tb/tb_bert_tiny_ust.v` — bayt arayüzü, tüm vektörler (Icarus) | `BERT_TINY_UST TEST: PASS (175390 kontrol, 0 hata)` — 325 Softmax satırı (20 820 bayt) + 485 LayerNorm satırı (62 108 bayt) bit bit eşit |
| Aynı tb, **Vivado GUI projesi, davranışsal xsim** (kullanıcı koşusu; `debug off`, 42 029 915 ns'de `$finish`, ≈29 sn) | `PASS (175390 kontrol, 0 hata)` |
| Aynı tb, xsim komut satırı (`xvlog/xelab -debug off/xsim`, .mem dosyaları çalışma klasöründe) | `PASS (175390 kontrol, 0 hata)`, 12 sn |
| Aynı tb, gerçek UART (`parameter UART=1`, `bert_tiny_uart_ust`, 8N1 921600 baud; 2+2 satır, yavaş) | `PASS (448 kontrol, 0 hata)` |
| `tb_hizlandirici` **yeni top üzerinden** (`iverilog -DYENI_TOP`) | `YANIT KARSILASTIRMA: PASS (8337 yanit bayti beklenenle ayni, 0 fark)`, 70 paket, 2 kasıtlı hata. Eski top: aynı sonuç, aynı çevrim (65 309) |
| Bozuk CRC'li yeni komutlar (CFG, BASLAT, VERI) → HATA 1; bilinmeyen komut (0x7E, 0x12) → HATA 2; kısa yük/yarım eleman/tampon dışı OKU → HATA 3; bozuk BASLAT birimi başlatmaz | tb içinde, geçti |
| Mutant denetimi `python scripts/kos_g13_mutant.py` (5 bozulma) | Hepsi yakalandı (`G13 MUTANT TOPLAM: PASS`). *m4 (m0'ın 24. biti) ilk turda kaçtı çünkü vektör m0 değerleri < 2^23; tb'ye üst bitleri dolduran CFG denetimi eklendi* |
| `kos_g11.py` | `G11 TOPLAM: PASS` (2 açıklanmış eşdeğer mutant) |
| `kos_g4.py` | `G4 TOPLAM: PASS (11 koşu, 0 başarısız)` |
| `kos_g10.py` | `G10 TOPLAM: PASS (8 koşu, 0 başarısız)` |
| `kos_g7.py` | `G7 TOPLAM: PASS (12 katman, 0 başarısız)` |

Not (xsim): vektörler `+vdir` verilmezse sırayla `tb/vektor_g11` (cwd=03-RTL), sonra `.` aranır. GUI projesinde `.mem` dosyaları *Simulation Sources*'a eklendiği için Vivado bunları xsim klasörüne kopyalar; bu yüzden log'da `WARNING: file tb/vektor_g11/sm_meta.mem could not be opened` ve ardından `vektor klasoru=.` görülür — beklenen, vektörler okunur. Hızlı koşu: `xsim.elaborate.debug_level = off` (dalga formu yok); `launch_simulation` testi kendisi sonuna kadar koşar (`xsim.simulate.runtime` 10000s), ek `run -all` verilmez (`$finish` sonrası boşuna ilerler). Dalga formu için `debug_level typical/all` ve kısa pencere (`run 1 ms`) önerilir; sinyal yolu `/tb_bert_tiny_ust/\g_bayt.dut /...` (adın sonunda boşluk vardır). Komut satırında `-testplusarg smrows=8` değerli kullanımı Windows sarmalayıcısında çalışmadı.

## 5. Sentez, yerleştirme-yönlendirme ve bitstream (Vivado 2025.1, xc7a35tcpg236-1, 100 MHz)

**Kaynak: kullanıcının Vivado GUI proje koşusu** (`bitirme_bert_tiny.runs/synth_1`, `impl_1`; 29.10.2026 21:48–21:56; kısıt dosyası `basys3.xdc` bağlı). Sentez, yerleştirme-yönlendirme ve bitstream (`write_bitstream completed successfully`, 2,19 MB) hatasız tamamlandı.
Komut satırı alternatifi (cwd `03-RTL`): `vivado -mode batch -source sentez/sentez.tcl -tclargs bert_tiny_uart_ust` ve `sentez/impl.tcl -tclargs bert_tiny_uart_ust` (ikinci argüman 0: bitstream yok). Çıktılar `sentez/cikti/bert_tiny_uart_ust_*`; eski `impl_*` dosyalarının üzerine yazılmaz.

| Kaynak / zamanlama | Eski: `hizlandirici_uart_ust` (impl) | Yeni: sentez | Yeni: impl (yerleştirme-yönlendirme sonrası) |
|---|---|---|---|
| LUT (toplam) | 3 702 | 5 714 (logic 3 769 + bellek 1 945) | **5 540** (logic 3 603 + bellek 1 937) |
| FF | 4 219 | 5 386 | **5 390** |
| BRAM (tile) | 15 | 15,5 (14 RAMB36 + 3 RAMB18) | **15,5** |
| DSP | 68 | 77 | **77** (DSP48E1) |
| Setup WNS | +0,721 ns | — | **+0,626 ns** (0 başarısız uç nokta / 31 620) |
| Hold WHS | +0,026 ns | — | **+0,024 ns** (0 başarısız) |
| Yönlendirme hatası | 0 | — | 0 |
| Güç tahmini | 0,170 W | — | **0,189 W**, kavşak 25,9 °C, güven: orta (vektörsüz tahmin) |

"Tüm kullanıcı zamanlama kısıtları sağlandı." Bütçe: LUT %26,6, FF %13,0, BRAM %31, DSP %85,6 (77/90).
DRC: 0 hata, 89 uyarı (yalnız DSP boru hattı önerileri DPIP/DPOP). Metodoloji: **0 kritik**, 28 uyarı — SYNTH-6 ×17 (RAM çıkış yazmacı birleşmedi), SYNTH-10 ×8 (geniş çarpıcı), TIMING-18 ×3 (`rst`, `uart_rx_pin` giriş gecikmesi ve `uart_tx_pin` çıkış gecikmesi tanımsız; bilinen, kısıtlanmadı).
Sentez sonrası WNS için GUI koşusunda zamanlama raporu yok; komut satırı sentezimde (aynı sayılarla) +1,287 ns çıkmıştı (yazarın betik koşusu, yalnız bilgi).

**Önemli not:** GUI projesinde ilk koşu `constrs_1` boş olduğu için zamanlama "NA", güç 74,7 W ve metodoloji 1000 kritik uyarı verdi. Bu bir kısıt eksikliği artefaktıydı; `basys3.xdc` eklenince giderildi (`sentez/proje_guncelle.tcl`).

**Hiyerarşik kullanım (komut satırı impl koşusu, yazarın):** `u_cd` 701 LUT / 958 FF; `u_kat` 3 145 LUT / 3 534 FF / 68 DSP / 14 RAMB36 + 2 RAMB18; `u_sm` 517 LUT / 198 FF / 3 DSP; `u_ln` 1 103 LUT / 604 FF / 6 DSP; `u_rx` 52 LUT. `sentez.tcl` bunu otomatik denetler (`HIYERARSI KONTROL: TAMAM`). Küçük `cikis_tamponu` örnekleri `-flatten_hierarchy rebuilt` altında üst modüle katıldığı için hiyerarşik raporda ayrı satır değildir; hücreleri (`u_ust/u_smb/mem_reg`, `u_ust/u_lnb/mem_reg`) netlistte vardır.

**Bellek yorumu (sentez günlüğünden):** Softmax `sbuf` 64×32, `ebuf` 64×16, `mbuf`, **`lut` 512×16** ve LayerNorm `buf_q` 128×18, `gam`/`bet` 128×16 → **dağıtık RAM** (RAM64X1S/RAM64M/RAM128X1S). Birimlerde asenkron/mux'lı okuma olduğundan BRAM'e çıkmadı; birim RTL'i değiştirilmediği için bırakıldı. `u_lnb` (128×8) RAMB18, `u_smb` (64×8) dağıtık RAM.

## 6. Bilinen sınırlar / dürüstlük notları

- **Kartta denenmedi.** Pin atamaları (`basys3.xdc`) Digilent ana XDC'sinden; bitstream üretildi ama karta yüklenmedi. Gerçek UART'ta (921600 baud) tam skor akışı ve OKU yanıtları yalnız benzetimle, az satırla denendi.
- Giriş/çıkış gecikmeleri (rx, rst, tx) kısıtlanmadı (eskisi gibi); `rst` (btnC) senkronlayıcısız, doğrudan fabrik reseti.
- Hold payı dar (+0,024 ns, eskisi +0,026) ve setup payı eskisinden düştü (+0,626 ns vs +0,721 ns); sınırı aşan bir ihlal yok ama pay küçük, yer-yön çalıştırmaları arası ±birkaç yüz ps oynayabilir.
- Softmax tek sorgu başına L=64, LayerNorm N=128 sabit parametreli; farklı uzunluk ayrı derleme ister.
- Softmax/LayerNorm ile doğrusal katman arasında **donanım içi veri yolu yok**: her birim host üzerinden beslenir. Bu nedenle "tüm tasarım tek kartta ucu uca çalışır" iddiası **yoktur**; yalnız "birlikte sentezlenir ve hepsi host'tan sürülebilir".
- UART hızı mimarinin darboğazı olmaya devam eder (G9'daki ölçüme bakın).

## 7. Danışmana / FPGA hocasına sorulacaklar

1. İç zincirleme (INT32 skor → Softmax → P·V) için `dogrusal_katman`'dan `out_acc` çıkarılsın mı, yoksa host üzerinden taşıma raporda yeterli mi?
2. Softmax `lut`/LayerNorm tabloları dağıtık RAM'de (≈1 870 LUT-as-memory). BRAM'e taşımak için birim RTL'inde senkron okuma düzenine geçilsin mi (G11 yeniden doğrulaması gerekir)?
3. Kartta ilk açılışta hangi test: yalnız DURUM + Softmax LUT yükleme + tek satır mı?
