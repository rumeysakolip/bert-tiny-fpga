# 2. İlerleme Raporu için Çalışma Özeti (RTL ve deneyler)

Bu belge, 1. ilerleme sunumundan (16 Ekim 2026) bu yana yapılan **RTL / deney çalışmasını** tek yerde toplar.
Amaç: rapor yazacak veya video fikri verecek bir sohbete bağlam olmak. Yazar: Rümeysa Kolip, danışman Dr. Öğr. Üyesi Emin Güney.
Sunum: 30 Ekim 2026 (İP3, "Deneyler ve donanım geliştirme"). Belge tarihi: 29 Ekim 2026.

**Okuma kuralları (rapor ve videoda da geçerli):**
- Her sayı bir benzetim veya Vivado çıktısından geliyor; **kartta hiçbir şey çalıştırılmadı**. "Benzetim" ve "sentez/implementasyon (Vivado)" denir, "kart sonucu" denmez.
- Tahmin/hesap olan sayılar ayrıca etiketli ("hesap", "tahmin").
- 1–3 cümlelik doğruluk farkları gürültüdür (1 puan ≈ 8,72 cümle, 872 cümlede).
- Hocanın kararı: **QAT yapılmayacak, eğitim sonrası niceleme (PTQ) kullanıldı.**

---

## 1. Proje özeti (bir paragraf)

Uç cihazlar için BERT-Tiny (2 katman, H=128, 2 baş, FFN=512, dizi uzunluğu 64) modelinin **INT8** çıkarımını yapan, FPGA tabanlı
(Basys3, XC7A35T) bir hızlandırıcı. Matris çarpımları 8×8 sistolik dizide (çıkış-sabit, 64 PE), büyük matrisler 8×8 "tile"lara bölünerek
işleniyor. Ağırlıklar PC'den UART ile panel panel akıtılıyor, aktivasyonlar FPGA'daki BRAM'de duruyor. Softmax, LayerNorm ve artık toplama
şimdilik PC'de (host'ta); bunların RTL birimleri yazıldı ama sisteme bağlanmadı. Her RTL modülü, Python "altın model"in `.mem` vektörleriyle
**bit-birebir** doğrulanıyor.

## 2. İş paketi (İP3) görevleri ve durumu

İş paketleri Excel'indeki görev numaralarına göre (G15–G22). Ayrı bir iç plan (`BITIRME_NIHAI_PLAN.md`, G0–G14) de vardı; aşağıda ikisi eşleştirildi.

| İP3 görevi | Durum | Kanıt / not |
|---|---|---|
| G15 Sistolik diziyi genelleştirme | **Tamam** | `systolic_nxn.v`, `pe.v` parametrik (N, A_W, B_W, ACC_W). N=4, 8, 16 benzetimde 0 hata. |
| G16 Parçalayan kontrol birimi + bellek tamponları | **Tamam** | `tile_denetleyici.v`, `bram_sdp.v`, `panel_tamponu.v` (çift tampon, gölge birikeç). |
| G17 Bir katmanın matris çarpımı, referansla bit düzeyinde | **Tamam (hedefin ötesinde)** | 12 doğrusal katman + dikkat çarpımları bit-birebir. |
| G18 Doğruluk deneyi | **Tamam (QAT yok, PTQ)** | FP32 719/872; PTQ 716–718; tam tamsayı hat 718 (kayıp 0,11 puan). |
| G19 Hesaplama yükü tablosu | **Tamam** | MAC payı, CPU süre payı, bu RTL'in çevrim payı (3 şekil + CSV). |
| G20 Dizi boyutu deneyi (4×4, 8×8, 16×16) | **Tamam** | Benzetim + sentez + yerleştirme; 16×16 bu FPGA'ya sığmıyor. |
| G21 Rapor ana başlıkları | **Taslak var, düzeltme gerekli** | `Ilerleme_Raporu_2_BIL401_30Ekim2026.docx` üretildi; yeni sonuçlar (G18, G19, dikkat Vivado testleri, G11) henüz rapora eklenmedi; Word'de görsel kontrol edilmedi. |
| G22 2. ilerleme sunumu hazırlığı | **Kalan (kullanıcı)** | Slaytlar ve video henüz yok; bu belge ona girdi olacak. |

İç plan ile eşleşme: iç plan G1–G2 (test vektörleri, tamsayı taşıma) → G18; G4–G8 → G15–G17; G9 (host arabirimi), G10 (dikkat), G11
(Softmax/LayerNorm), G12 (sentez) → **İP3'ün ötesi, İP4/İP5 hazırlığı**; G13 (rapor) → G21; G14 (toplantı notu) → G22.

**Özet:** RTL ve deney görevlerinin hepsi tamam; İP3'te istenenin ötesinde İP4/İP5'e dönük yapılar da tasarlanıp doğrulandı (Bölüm 4).
Kalanlar: rapor düzeltmesi ve sunum/video (kullanıcı) ile kart tarafı.

## 3. Yapılan işler (kronolojik, ana hatlarıyla)

### 3.1 Altın model ve tamsayı taşıma (iç plan G1–G2)
- Test vektörleri artık donanım-sadık **B kipinde** üretiliyor (tamsayı yeniden ölçekleme, katman başına M0/n); her katman için girdi, ağırlık paneli, bias, M0, beklenen birikeç ve INT8 çıkış `.mem` dosyaları.
- Birimler arası taşıma float'tan tamsayıya çevrildi (gömme, LayerNorm çıkışı, artık toplam, Q·Kᵀ, P·V, GELU). Sonuç: **718/872** (FP32 719); tek adım "artık toplam" 3 cümleyi değiştirdi, gerisi aynı.

### 3.2 PE ve sistolik dizi (G15)
- **PE:** 9 bit işaretli A (INT8 ve Softmax'ın UINT8 çıkışı aynı PE'ye sığsın), 8 bit B, 32 bit birikeç. `tb_pe`: 5 bölüm, **10 333 kontrol, 0 hata** (uç değerler dahil: 255×(−128)×512 = −16 711 680).
- **Dizi:** akışlı arayüz, skew kaydırma yazmaçları. Tile süresi **K+2N−2** (N=8, K=64 → 78 çevrim), 198 test, 25 344 kontrol, 0 hata.
- Benzetim tuzağı: Icarus'ta paketlenmiş vektör dilimleri 200× yavaştı; ağ-dizisi (net array) bağlantısıyla 86 sn → 1,4 sn.

### 3.3 Tile denetleyici ve doğrusal katman (G16–G17)
- **Tile denetleyici:** panel dış döngü, token bloğu iç döngü (bir ağırlık paneli 8 blokta yeniden kullanılır); **gölge birikeç** (tile bitince sonuç yedeğe kopyalanır, dizi hemen sonraki tile'a geçer, yedek 64 çevrimde bias eklenerek akıtılır); çift tamponlu panel el sıkışması (`pan_hazir`, `pan_bitti`). Tile periyodu K+15.
- `l0_q` birikeç testi: 4 cümle, 512 tile/cümle için toplam **32 768 kontrol, 0 hata**; cümle başına 18 387 çevrim (teorik alt sınır 18 176).
- **Yeniden ölçekleme:** `y = kırp((acc·M0 + 2^(n−1)) >> n)`, 3 aşamalı boru hattı. **7 792 vektör, 0 hata**, 5 271 eleman kırpıldı (kırpma yolu da sınandı).
- **Uçtan uca doğrusal katman** (`dogrusal_katman.v`: BRAM → dizi → bias → ölçekleme → [GELU] → paketleme → çıkış BRAM'i): **12 katman (L0+L1: Q, K, V, attn_out, ffn1, ffn2) 4 cümlede bit-birebir**; 12 katmanın toplamı 428 928 çevrim/cümle.
- **GELU:** 256 girişli INT8→INT8 tablo (host yükler). `l0_ffn1` (128→512 kanal): **131 072 kontrol, 0 hata**, 73 352 çevrim/cümle.

### 3.4 Dikkat çarpımları (iç plan G10)
- Q·Kᵀ ve P·V, aynı dizi ve denetleyiciyle; B operandı cümleye göre değişiyor, P·V'de A işaretsiz (UINT8 olasılık).
- 2 katman × 2 baş × 2 işlem = **8 koşu, hepsi bit-birebir** (her biri 16 384 kontrol, cümle başına 5 131 çevrim, toplam 41 048).

### 3.5 Host arabirimi (iç plan G9) — İP4 hazırlığı
- Protokol: `komut / uzunluk (2 bayt) / yük / CRC8`; yanıtlar ACK, HATA, VERI. Dur-ve-bekle. `uart_rx.v`, `uart_tx.v`, `komut_cozucu.v`, `hizlandirici_ust.v`, `hizlandirici_uart_ust.v`.
- Python sürücüsü (`host/hizlandirici_surucu.py`): benzetim arka ucu (komut dosyası → Icarus/xsim) ve pyserial arka ucu (**kartta denenmedi**).
- **Host-in-the-loop:** Layer 0'ın 6 katmanı PC→FPGA→PC döngüsünde bit-birebir (602 paket); bozuk CRC `HATA` döndü; bilinmeyen komut `HATA` döndü. Vivado'da gösterilen tek katmanlık sürümü: 70 paket, 26 106 bayt gönderildi, 8 337 yanıt baytı beklenenle birebir (2 kasıtlı hata).
- UART bit düzeyi testi (`tb_uart`): DURUM, bozuk CRC'li CFG (HATA), doğru CRC'li CFG (ACK); 10 kontrol, 0 hata.

### 3.6 Softmax ve LayerNorm RTL (iç plan G11) — İP3'ün dışında, fazladan
- **`softmax_birim.v`:** satır maksimumu → fark·M0 ile 512 girişli exp tablosu → toplam → ardışık bölme → UINT8. **325 satır, 20 800 kontrol, 0 hata**, satır başına 2 049 çevrim.
- **`layernorm_birim.v`:** ortalama, varyans, **bit-bit karekök** (plandaki 4 Newton yinelemesi yerine; aynı sonucu bölücüsüz verir), eleman başına ardışık bölme, γ/β ölçekleme. **485 satır, 62 080 kontrol, 0 hata**, 5 274 çevrim/satır.
- **Mutant denetimi:** RTL'e kasıtlı 5 bozulma; 3'ü yakalandı, 2'si davranışı değiştirmediği için (kanıtlı eşdeğer) geçti. Yani test gerçekten hata yakalıyor.
- Yaklaşıklık: Softmax FP64'e göre en çok 2,40 LSB (1/255), LayerNorm 0,93 LSB.
- **Sisteme bağlı değil.** Ayrı ayrı sentezlendi: Softmax 561 LUT / 3 DSP (WNS +3,19 ns), LayerNorm 1 129 LUT / 6 DSP (WNS +1,38 ns), sentez sonrası.

### 3.7 Sentez ve implementasyon (iç plan G12; İP3 G20 ile ilgili)
- **İlk sentez:** 10 110 LUT, **4 DSP** (plan ≈72 bekliyordu: çarpıcılar LUT'a eşlenmişti), WNS **−0,456 ns** @100 MHz → zamanlama tutmadı.
- **İyileştirme:** `pe.v`'ye `(* use_dsp = "yes" *)`: 3 816 LUT, 4 216 FF, 15 BRAM, **68 DSP**, WNS +1,648 ns. Sentezlenmiş 8×8 dizi ağ listesi xsim'de de bit-birebir (K=64 ve K=128).
- **Yerleştirme + yönlendirme (Vivado 2025.1, bitstream yok):** **3 702 LUT (%17,8), 4 219 FF, 15 BRAM, 68 DSP (%75,6); setup WNS +0,721 ns, hold WHS +0,026 ns (dar), 0 hatalı uç nokta, güç tahmini 0,170 W** (güven: orta). En yüksek frekans kabaca ≈108 MHz (tahmin).
- Kısıtlanmamış: rx, rst, tx için giriş/çıkış gecikmesi.

### 3.8 Dizi boyutu deneyi (G20)
Yalnızca dizi (kontrol/bellek yok), bağlam dışı sentez, 100 MHz:

| | 4×4 | 8×8 | 16×16 |
|---|---|---|---|
| PE sayısı | 16 | 64 | 256 |
| Tile süresi (K=64, benzetim) | 70 | 78 | 94 çevrim |
| Bit-birebir (198 test) | 0 hata | 0 hata | 0 hata |
| LUT / FF / DSP (sentez) | 114 / 204 / 16 | 311 / 1042 / 64 | 695 / 4318 / **256** |
| WNS, sentez | +2,35 ns | +2,33 ns | +2,32 ns |
| WNS, yerleştirme+yönlendirme | +1,42 ns | +1,08 ns | **yapılamadı (256 DSP > 90)** |
| l0_q katmanı çevrim/cümle | 69 120 (hesap) | 18 392 (ölçüldü) | 5 088 (hesap) |

Sınır: tam sistem yalnız 8×8 için kurulu; 4×4 ve 16×16 katman çevrimi tile formülünden hesaplandı (8×8 için hesap 18 304, ölçüm 18 392).

### 3.9 Doğruluk deneyi (G18) — PTQ, QAT yok
872 SST-2 doğrulama cümlesi:

| Yapılandırma | Doğru | Kayıp (puan) | FP32 ile uyuşma |
|---|---|---|---|
| FP32 referans | 719 | 0 | %100 |
| PTQ (6 koşu; minmax/yüzdelik, simetrik/asimetrik, 128/512 cümle) | 716–718 | 0,11–0,34 | %99,43–99,89 |
| Altın model A (PTQ eşdeğeri) | 718 | 0,11 | %99,66 |
| **Tam tamsayı hat (donanım düzeni)** | **718** | **0,11** | **%99,66** |

Hedef ≥711 (≤1 puan) ve sınır ≥702 (≤2 puan) sağlandı. Tamsayı taşıma adımları (gömme → LN çıkışı → artık → Q·Kᵀ → P·V → GELU) doğruluğu bozmadı (717→718).

### 3.10 Hesaplama yükü (G19)
- **MAC payı (toplam 27,3 M, seq=64):** FFN1 %30,8, FFN2 %30,8, Q/K/V %23,1, attn çıkışı %7,7, Q·Kᵀ %3,8, P·V %3,8, pooler+sınıflandırıcı %0,1. Matris çarpımları aritmetik yükün ~%96'sı.
- **Doğrusal olmayan işlemler (eleman sayısı):** Softmax 16 384, LayerNorm 40 960, GELU 65 536.
- **CPU süre payı** (x86, 1 iş parçacığı, toplam 2,49 ms/cümle; eski çalışmadan okundu): doğrusal katmanlar %57, diğer %19,2, dikkat çekirdeği %9,9, GELU %8,2, LayerNorm %4,0, gömme %1,8.
- **Bu RTL ile çevrim payı** (≈2,68 M çevrim ≈ 26,8 ms @100 MHz): doğrusal 428 928 (%16,0, ölçüldü), dikkat 41 048 (%1,5, ölçüldü), **Softmax 524 544 (%19,6, hesap)**, **LayerNorm 1 687 680 (%62,9, hesap)**. Softmax/LayerNorm, ölçülen satır çevrimi × satır sayısı (256 ve 320 satır); bu birimler sisteme bağlı olmadığı için hesaptır. Anlamı: tek, 1 bit/çevrim bölücülü bu birimler bağlansaydı aritmetik yükün %4'ünden azı olan LayerNorm süre yükünün ~%63'ünü alırdı; paralel/çok bit/çevrim bölücü denenmedi.

## 4. "Fazladan" yapılanlar (İP3'ün istediğinden öte)

İP3'te yalnızca G15–G22 isteniyordu. Ek olarak yapılanlar (İP4/İP5 ve riskleri azaltma için):
1. **Softmax ve LayerNorm RTL birimleri** (bağımsız, bit-birebir, mutant denetimli, sentezli).
2. **UART + komut çözücü + host protokolü + Python sürücüsü**, host-in-the-loop doğrulaması, hata enjeksiyonu.
3. **Dikkat çarpımları** (Q·Kᵀ, P·V) donanımda; UINT8 olasılığı destekleyen 9 bit PE.
4. **GELU LUT** yolu ve geniş (512 kanallı) katman.
5. **DSP eşleme iyileştirmesi** (WNS −0,456 → +0,721 ns) ve **yerleştirme-yönlendirme** sonucu, güç tahmini.
6. **11 tasarım raporu (TR02–TR12)** — her RTL modülü için karar tablosu, literatür karşılığı (yalnızca `literatur_kutuphanesi.json`'dan, 2021+), doğrulama kanıtı, sınırlar, şekiller. TR01 daha önce vardı.
7. **Vivado'ya uygun testbench'ler** (varsayılan vektör yolları, VCD isteğe bağlı) ve kullanıcının Vivado'da koşturduğu **12 testbench**.
8. Basys3 kısıt dosyası (`basys3.xdc`; pinler kartta denenmedi).

## 5. Vivado'da gösterilebilen testler (sırayla; hepsi kullanıcı tarafından koşturuldu, geçti)

Her biri kendi vektör klasörünü varsayılan olarak okur; "Set as Top" yapıp **Run Behavioral Simulation → Run All** yeterli.

| # | Testbench | Neyi gösteriyor | Beklenen son satır |
|---|---|---|---|
| 1 | `tb_pe` | Tek PE: çarp-biriktir, reset/enable, uç değerler | `PE ... PASS (10333 kontrol, 0 hata)` |
| 2 | `tb_systolic_nxn` | 8×8 dizi, 198 test, tile süresi K+2N−2 | `PASS (198 test, 25344 kontrol, 0 hata)` |
| 3 | `tb_requant` | Yeniden ölçekleme boru hattı, kırpma | `PASS (7792 kontrol, 0 hata)` |
| 4 | `tb_tile` | Tile denetleyici: birikeç, panel ping-pong, gölge birikeç | `PASS (32768 kontrol, 0 hata)` |
| 5 | `tb_katman` | `l0_q` uçtan uca, INT8 çıkışa kadar | `PASS (32768 kontrol, 0 hata)` |
| 6 | `tb_katman_ffn1` | GELU'lu, 128→512 kanal | `PASS (131072 kontrol, 0 hata)` |
| 7 | `tb_dikkat_qk`, `tb_dikkat_av` | Q·Kᵀ (INT8) ve P·V (UINT8 olasılık) | her biri `PASS (16384 kontrol, 0 hata)` |
| 8 | `tb_softmax` | Tamsayı Softmax birimi | `PASS (325 satir, 20800 kontrol, 0 hata)` |
| 9 | `tb_layernorm` | Tamsayı LayerNorm birimi | `PASS (485 satir, 62080 kontrol, 0 hata)` |
| 10 | `tb_uart` | UART üst modül: DURUM, bozuk CRC→HATA, CFG→ACK | `PASS (10 kontrol, 0 hata)` |
| 11 | `tb_hizlandirici` | PC↔FPGA tam döngü, 70 paket, yanıt karşılaştırma | `YANIT KARSILASTIRMA: PASS (8337 ... 0 fark)` |

Not: dalga formundaki kırmızı alanlar tanımsız (X) değerlerdir, hata değildir. Hata göstergesi log'daki `hata` sayısıdır.
Vivado'da henüz çalıştırılmayan: `tb_regresyon_n4` (eski 4×4 prototiple tarihçe karşılaştırması, zorunlu değil), sentez/implementasyonun GUI'de kendisi.

## 6. Video / sunum için fikirler

Mesaj: "Model INT8'e indirildi, doğruluk korundu (718/719); matris çarpımı donanımı bit-birebir doğrulandı; kaynak ve zamanlama ölçüldü; dürüst sınırlar."

Önerilen akış (≈5–8 dk):
1. **Problem ve yöntem (30 sn):** FP32 → PTQ INT8; 872 cümle; `g18_s1_dogruluk.png` (hepsi hedef çizgisinin sağında, eksen 705'ten başlıyor).
2. **Hesaplama yükü (30 sn):** `g19_s1_mac.png`: yükün ~%96'sı matris çarpımı → sistolik dizi mantığı.
3. **PE → dizi (1 dk):** `tb_pe` PASS satırı; `tb_systolic_nxn` dalga formu (78 çevrim = K+2N−2). Anlat: neden 9 bit A.
4. **Büyük katman: tile + panel akıtma (1,5 dk):** `tb_tile`/`tb_katman` dalga formu (aktivasyon yükleme → panel yükleme → hesap); "ağırlık bir kez, 8 blokta yeniden kullanılır".
5. **GELU ve dikkat (1 dk):** `tb_katman_ffn1`, `tb_dikkat_qk/av`; UINT8 olasılık aynı PE'de.
6. **Host ile konuşma (45 sn):** `tb_hizlandirici` PASS satırı; "bozuk CRC → HATA" gösterimi.
7. **Dizi boyutu deneyi (45 sn):** tablo; "16×16, 256 DSP gerektirdiği için bu FPGA'ya sığmıyor".
8. **Kaynak ve zamanlama (45 sn):** 3 702 LUT, 68 DSP, WNS +0,721 ns; DSP ipucunun etkisi (−0,456 → +0,721).
9. **Dürüst sınırlar ve sıradaki adımlar (45 sn):** aşağıdaki Bölüm 7.

Gösterilecek görseller: `rapor_sistemi/sekiller/` altında `g18_s1`, `g18_s2`, `g19_s1–s3`, `g20_s1–s3`, `tr03_s3_dalga`, `tr04_s4_dalga`, `tr06_s2_dogrulama`, `tr12_s1–s4`; dalga formları için Vivado ekranları.

## 7. Dürüst sınırlar (rapor ve videoda mutlaka söylenmeli)

- **Kartta hiçbir şey çalıştırılmadı.** Bitstream üretilmedi; Basys3 pin atamaları ve pyserial arka ucu denenmedi.
- **Softmax, LayerNorm ve artık toplam FPGA'da değil**, host'ta çalışıyor; RTL birimleri hazır ama bağlı değil. Katmanlar altın girdileriyle ayrı ayrı sınandı; **zincirli FPGA→host→FPGA akışı doğrulanmadı**. pooler/classifier RTL'de doğrulanmadı.
- **Hız kazancı beklenmiyor:** ağırlıklar her çıkarımda UART'tan akıyor; aktarım hesaptan ≈1000× uzun (hesapla bulundu). 921 600 baud'da bir çıkarım ≈4,6 sn, 3 Mbaud'da ≈1,4 sn (hesap); CPU 2,49 ms. Bu bir başarısızlık değil, bu mimarinin ölçülmüş sınırı (çözüm yönleri: ağırlığın kartta kalıcı saklanması, daha hızlı arayüz — denenmedi).
- **Zamanlama:** yerleştirme-yönlendirme sonucu, ama giriş/çıkış gecikmeleri kısıtlanmadı; hold marjı dar (+0,026 ns); güç değeri aracın tahmini.
- **G20:** yalnızca dizi için sentez; tam sistem yalnız 8×8; 4×4 ve 16×16 katman çevrimi hesap.
- **G19:** Softmax/LayerNorm çevrim payı hesap; CPU süre payı eski ölçümden okundu, yeniden ölçülmedi.
- **Plandan sapmalar:** DSP eşlemesi ilk sentezde tutmadı (düzeltildi); LayerNorm karekökü Newton yerine bit-bit; 512 cümle × 3 tohum kalibrasyon (iç plan G3) yapılmadı (kalibrasyon 128/512 cümle, tek tohum).
- **Literatür:** 9 bit A girişi ve PC–FPGA UART için 2021 sonrası doğrudan kaynak bulunamadı; raporlarda "doğrudan karşılık bulunamadı; mühendislik kararı" yazıyor. Alıntıların PDF'te bölüm numarasıyla elle doğrulanması gerekiyor.
- **Raporlar (docx):** PDF'e çevrilip görsel kontrol edilmedi.

## 8. Sonraki adımlar (İP4 ve sonrası)

1. Rapor düzeltmesi: yeni sonuçlar (G18, G19, G20, dikkat Vivado testleri, G11) rapora; biçim kontrolü; literatür alıntı kontrolü.
2. Sunum slaytları ve video (G22).
3. Kart: Vivado'da bitstream, Basys3'te UART bağlantısı, tek katmanı kartta doğrulama (İP4 G23–G25).
4. İsteğe bağlı: Softmax/LayerNorm'ü sisteme bağlama ve zincirli akış; daha hızlı bölücü; ağırlığın kartta saklanması.

## 9. Dosya haritası

Proje kökü: `C:\Users\rumey\Documents\biitirme-projem` (yerel git deposu; **push yapılmadı**; son commit `afd00ae` ve sonrası).

| Yol | İçerik |
|---|---|
| `03-RTL/rtl/` | 17 Verilog dosyası (pe, systolic_nxn, bram_sdp, panel_tamponu, tile_denetleyici, yeniden_olcekle, gelu_lut, cikis_paketle, dogrusal_katman, komut_cozucu, uart_rx/tx, hizlandirici_ust, hizlandirici_uart_ust, bolucu_seri, softmax_birim, layernorm_birim) |
| `03-RTL/tb/` | Testbench'ler ve test vektörleri (`vektor_nxn/`, `vektor_rq/`, `vektor_g11/`) |
| `03-RTL/scripts/` | Koşturucular: `kos_g4.py`, `kos_g7.py`, `kos_g10.py`, `kos_g11.py`, `kos_g20.py` |
| `03-RTL/sim/` | Sonuç JSON/log dosyaları (`g7_sonuc.json`, `g10_sonuc.json`, `g11_sonuc.json`, `g18_ozet.json`, `g19_ozet.json`, `g20_ozet.json` ...) |
| `03-RTL/sentez/` | `sentez.tcl`, `impl.tcl`, `g11_sentez.tcl`, `g20_dizi.tcl`, `basys3.xdc`, `cikti/` (Vivado raporları) |
| `host/` | PC tarafı sürücü (`hizlandirici_surucu.py`, `g9_host_dongusu.py`) |
| `02-RTL_Altin_Model/` | Altın model (Python), test vektörleri, sonuçlar |
| `rapor_sistemi/` | Tasarım raporları (`tasarim_raporlari/TR02–TR12`), şekiller (`sekiller/`), `Ilerleme_Raporu_2_BIL401_30Ekim2026.docx`, `Toplanti_30Ekim2026.md`, `g18_tablo.csv`, `g19_tablo.csv` |
| `BITIRME_NIHAI_PLAN.md` | İç plan (G0–G14) ve çalışma kuralları |

Çalıştırma komutları: `03-RTL/README.md`.
