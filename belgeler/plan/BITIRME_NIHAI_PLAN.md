# BITIRME_NIHAI_PLAN.md — BIL 401 · FPGA Tabanlı BERT-Tiny INT8 Hızlandırıcısı

**Bu dosya Claude Code için tek başına yeterli çalışma kılavuzudur.** Önce bölüm 0–2'yi oku, sonra görevleri sırayla yürüt.
Sahibi: Rümeysa Kolip (23010903093) · Danışman: Dr. Öğr. Üyesi Emin Güney · Hedef: **30 Ekim 2026 (Cuma) toplantısı** · Hazırlanma: 27 Ekim 2026

---

## 0. Claude Code için çalışma talimatı

1. Çalışma klasörü: `C:\Users\rumey\Documents\biitirme-projem` (aşağıda `PROJE/`). Mevcut klasörlere (`00-…`, `01-…`, `02-…`, `old/`) **dokunma**, yalnızca oku; yeni işi `03-RTL/`, `host/`, `rapor_sistemi/` altında yap.
2. Her göreve başlamadan önce o görevin **Girdi** dosyalarının var olduğunu ve **Temel hat** komutlarının (bölüm 3.3) geçtiğini doğrula. Geçmiyorsa dur, sebebini rapor et.
3. Bir görev ancak **Kabul ölçütü** komutla gösterilince "bitti" sayılır; çıktının son satırını (PASS/hata sayısı) gösterilmiş kanıt olarak kaydet.
4. Görev bitince sırayla: (a) kabul ölçütünü koştur, (b) o görevin **tasarım raporunu (TRnn)** görsel ağırlıklı olarak üret (bölüm 8), (c) `git commit` (Türkçe, tek satır özet: `G5: tile denetleyici, l0_q 4 cümle bit-birebir`).
5. Belirsizlik, eksik girdi ya da kabul ölçütünün sağlanamaması durumunda **uydurma, dur ve sor**. Başarısızlığı olduğu gibi raporla (bölüm 2).
6. Bu dosyadaki "tahmin" etiketli sayılar ölçülene kadar rapora ölçülmüş sayı olarak girmez.

## 1. Proje özeti

BERT-Tiny (2 kodlayıcı katman, gizli boyut 128, 2 baş, FFN 512, 4.386.178 parametre) SST-2 duygu sınıflandırması çıkarımı INT8 tamsayı aritmetiğine indirildi. Matris çarpımları FPGA'da **8×8 çıkış-sabit sistolik dizi** ile hızlandırılacak. **PC host, FPGA hızlandırıcıdır**; ağırlıklar PC'de kalır, FPGA'ya panel panel akıtılır, aktivasyonlar FPGA BRAM'inde yerleşiktir. Hedef kart: **Basys3 (XC7A35T-1CPG236; 20 800 LUT, 41 600 FF, 50 BRAM36, 90 DSP)**. **Elde kart yok**; bu hafta çıktılar: (1) altın modelle bit-birebir doğrulanmış RTL + host↔hızlandırıcı benzetimi, (2) 2. ilerleme raporu. Kartta çalıştırma, okulda hocalardan ricayla sonra yapılacak (kapsam dışı).

## 2. Çalışma sözleşmesi (kurallar)

**Dürüstlük**
- Ölçülmeyen sayı yazma. Benzetim sonucu ≠ kart sonucu; her yerde "benzetim" de. Hesapla bulunan tahminler "tahmin" etiketli olsun.
- Yapılmayan birimi "yapıldı" diye sunma. Hedef tutmazsa bulguyu nedeniyle birlikte raporla.
- 872 cümlelik doğrulama kümesinde 1 puan ≈ 8,72 cümle; 1–2 cümlelik farklar gürültüdür, üstünlük iddiası yazma.

**Doğrulama**
- Her RTL modülü, altın modelin ürettiği `.mem` vektörleriyle **bit-birebir** doğrulanır. Uyuşmazlıkta suç RTL'dedir (altın model PTQ ile 872/872 uyuşuyor).
- RTL'e başlamadan önce `02_dogrula_ptq.py` "TÜM ÖLÇÜTLER GEÇTİ" vermelidir.
- Her testbench `PASS`/`FAIL` ve hata sayısı yazdırır; kabul için hata sayısı 0.

**Kod**
- RTL Verilog-2001 (Icarus Verilog uyumlu), parametrik (`N`, `K`, bit genişlikleri). Magic number yok; sabitler `parametreler.vh` ve `altin/sabitler.py` ile tutarlı.
- Python kimlikleri mevcut stile uyar (Türkçe). Doküman, commit ve rapor dili: **Türkçe**.
- Yeni iş mevcut altın modelin mantığını **değiştirirse** (ör. G2) önce doğrulama komutları yeniden koşturulur ve sonuçlar kaydedilir.

**Görsel ağırlıklı raporlama (ZORUNLU)** — ayrıntı bölüm 8
- Her tasarım raporu **şekil ağırlıklıdır**: en az 3 şekil, uzun paragraf yerine şekil/tablo. Üretici bu sayının altını reddeder.
- Şekiller gerçek veriden **kodla** üretilir (blok şeması, zamanlama/dalga formu, veri akışı çizelgesi, sonuç grafiği, kaynak grafiği). Elle sayı yazılmış şekil yok.

**Literatür (ZORUNLU)** — ayrıntı bölüm 8.3
- Yalnızca **2021 sonrası** (son 5 yıl) makaleler. Alıntı: bölüm no + tırnak içinde birebir metin + "bizde uygulama".
- Alıntı yalnızca `literatur_kutuphanesi.json`'dan gelir; yeni alıntı kütüphaneye ancak makale metninde iki bağımsız çekimle bulunduktan sonra eklenir. Bulunamıyorsa raporda "doğrudan karşılık bulunamadı; mühendislik kararı" yaz.

## 3. Ortam ve komutlar

### 3.1 Gerekenler
| Araç | Not |
|---|---|
| Python ≥ 3.10 | `numpy scipy tokenizers safetensors` (altın model; PyTorch **gerekmez**), rapor için `python-docx matplotlib`, host sürücüsü için `pyserial` |
| Icarus Verilog + GTKWave | `iverilog`, `vvp` (RTL benzetimi; Windows: bleyer.org/icarus) |
| Git | Uzak depo: `https://github.com/rumeysakolip/bert-tiny-fpga.git` |
| Vivado (opsiyonel) | Sentez için; yoksa `yosys synth_xilinx` yaklaşık tahmin ("tahmin" etiketiyle) |
| LibreOffice (opsiyonel) | docx → PDF ile raporun görsel kontrolü |

### 3.2 Altın model betikleri (`PROJE/02-RTL_Altin_Model/01_Kod`, hepsi bu klasörden koşar; girdileri `../../01-INT8_Nicemleme/`'dan okur, çıktıları `../03_Sonuclar/`'ya yazar)
| Betik | Süre | Beklenen son satır |
|---|---|---|
| `python testler\test_birimler.py` | ~5 sn | `11 geçti, 0 kaldı` |
| `python 02_dogrula_ptq.py` | ~35 sn | `TÜM ÖLÇÜTLER GEÇTİ` |
| `python 03_kalibre_ara_olcek.py` | ~25 sn | `40 ara tensör ölçeği yazıldı` |
| `python 05_karsilastir.py` | ~75 sn | karşılaştırma tablosu (fp32/PTQ/Altın-A/Altın-B) |
| `python 01_altin_kos.py --tarama` | ~2,5 dk | `birim_taramasi.csv` |
| `python 04_test_vektoru_uret.py --n_cumle 4` | kısa | `03_Sonuclar/test_vektorleri/` |
| `python 00_parametre_cikar.py` | kısa | `03_Sonuclar/parametreler/` (`.mem`, `.vh`, `bellek_haritasi.json`) |
(README'deki `03-RTL_Altin_Model` yolları hatalıdır; gerçek klasör `02-RTL_Altin_Model`.)

### 3.3 Temel hat (her göreve başlamadan önce)
1. `python testler\test_birimler.py` → `11 geçti, 0 kaldı`
2. `python 02_dogrula_ptq.py` → `TÜM ÖLÇÜTLER GEÇTİ`
3. (G0'dan sonra) `PE TEST: PASS` ve `SYSTOLIC 4x4 TEST: PASS` (Icarus, bölüm G0)

### 3.4 RTL benzetim şablonu
```
iverilog -g2001 -Wall -o sim\tb_X.vvp rtl\<modüller>.v tb\tb_X.v
vvp sim\tb_X.vvp          # son satır: "... TEST: PASS (N kontrol, 0 hata)"
```

## 4. Depo yapısı
```
PROJE/
  00-FP32_Egitim/  01-INT8_Nicemleme/  02-RTL_Altin_Model/   # mevcut, DOKUNMA (yalnız oku)
    02-RTL_Altin_Model/01_Kod/altin/{model,birimler,dogrusal_olmayan,nicem,parametreler,sabitler,veri}.py
    02-RTL_Altin_Model/03_Sonuclar/{parametreler,test_vektorleri}/ , *.json , *.csv
  old/bert-tiny-fpga/donanim/{rtl,tb,sim}/                    # eski pe.v, systolic_4x4.v ve testbench'ler (kopyala)
  03-RTL/{rtl,tb,sim,vektor,scripts}/                         # YENİ: yeni RTL (G0'da açılır)
  host/hizlandirici_surucu.py                                 # YENİ: PC tarafı (G9)
  rapor_sistemi/                                              # VAR: README.md, literatur_kutuphanesi.json, rapor_uretici.py,
    tasarim_raporlari/TRnn_*.json|.docx , sekiller/trnn_sekiller.py|.png
  BITIRME_NIHAI_PLAN.md                                       # bu dosya
```

## 5. Mevcut durum (kanıtlı)

| Alan | Durum | Kanıt |
|---|---|---|
| FP32 eğitim | 719/872 (%82,45); Colab T4, 96 sn, tek tohum (42) | `00-FP32_Egitim/` |
| INT8 PTQ | 6 koşu, 716–718/872 (kayıp ≤0,34 puan); statik kalibrasyonlu, 14 doğrusal katman, ağırlık kanal başına simetrik INT8, bias INT32 | `01-INT8_Nicemleme/` |
| Bit genişlikleri | GELU 12, Softmax girişi 12 / çıkışı 16, LayerNorm 16 (12 ile karşılaştırılıyor; karar sentezle), 4 Newton yinelemesi | rapor Böl. 4 |
| Altın model (NumPy) | fp32/A/B kipi; A kipi PTQ ile 872/872 aynı karar; B kipi donanım yaklaşıklıkları toplam 0,23 puan; en geniş birikeç 32 bitin 21'i | `02-RTL_Altin_Model/` |
| Parametre paketi | 49 dosya: `<ad>_w.mem`, `_b.mem`, `_m0.mem`, `l0_exp_lut.mem` …, `parametreler.vh` (`KAYDIRMA_*`), `bellek_haritasi.json` | `03_Sonuclar/parametreler/` |
| Test vektörleri | 4 cümle (en kısa: `cool ?`, `bad .`, `very bad .`, `oh come on .`; 4–6 token), her katman için `<ad>_girdi.mem` (INT8) ve `<ad>_birikec.mem` (INT32), `l*_olasilik_u8.mem`, `token_ids.mem`, `maske.mem`, `fpga_girdi_q.mem`, `kunye.json` | `03_Sonuclar/test_vektorleri/` |
| RTL prototip | `pe.v`, **sabit** `systolic_4x4.v`; PE 1012 kontrol 0 hata; dizi 264 test 0 hata; start→done 10 çevrim (Icarus 12.0) | `old/bert-tiny-fpga/donanim/` |

**Başarı ölçütleri (danışman):** hedef ≥711/872 (≤1 puan kayıp), üst sınır ≥702 (≤2 puan), MLPerf eşiği ≥712 (FP32'nin %99'u). FP32 referansı 719.

**Sayısal referanslar:** T=64 (dizi uzunluğu), GIZLI_BOYUT=128, ARA_BOYUT=512, BASLIK=2×64, AKTIVASYON/AGIRLIK=8 bit, BIRIKEC/BIAS=32 bit, M0_BIT=31, PE_SATIR=PE_SUTUN=8, K_DILIM=64, GELU/TANH LUT=256 giriş, tek çıkarımda 27 279 616 MAC, tüm ağırlıklar 420,7 KB (≈93,5 BRAM36).

**Eksikler:** (1) RTL 4×4 sabit; 8×8, K=128/512 döşeme, bellek, bias, requant, kırpma yok. (2) RTL altın modele bağlanmadı. (3) Host↔FPGA arabirimi yok. (4) Birimler arası taşıma float (gömme, artık toplam, Q·Kᵀ, Dikkat·V). (5) Nonlineer birim RTL'i yok. (6) Sentez yok. (7) Test vektöründe yeniden ölçeklenmiş INT8 çıkış (`*_cikis.mem`) yok. (8) Ara ölçekler 128 cümle + tek tohumla kalibre.

## 6. Hedef mimari

### 6.1 İş bölümü
| PC (host, Python/NumPy = altın model) | FPGA (RTL) |
|---|---|
| Tokenizer, gömme araması + gömme LayerNorm | INT8 matris çarpımları: Q, K, V, attn_out, ffn1, ffn2, pooler, classifier **ve** Q·Kᵀ, Dikkat·V |
| Tüm ağırlık/bias/M0 tabloları (420,7 KB) | Yeniden ölçekleme: `(acc+bias)·M0 >> n`, yuvarla, [−128,127] kırp |
| Softmax, LayerNorm, artık toplam (başlangıç yerleşimi; G11 yetişirse FPGA'ya) | GELU LUT, aktivasyon tamponları (BRAM yerleşik), tile denetleyici, UART |
| Panel sıralama, komut üretme, sonuç karşılaştırma | – |

Karar: **PE'nin A girişi 9 bit işaretli** (Softmax çıkışı UINT8 0..255, 9 bit işaretli aralık [−256,255] bunu tam kapsar; ölçek değişmez; Python testinde rastgele 64×64 için fark 0). G4'te kalıcı birim testi olur; bozulursa karar geri alınır.

### 6.2 Blok şeması
```
PC ──UART──► komut_cozucu ──► aktivasyon BRAM (yerleşik, çift tampon)
                 │                  │            ▲
                 │ ağırlık paneli   ▼            │
                 └──► panel BRAM ─► tile_denetleyici ─► sistolik dizi 8×8 (PE: 9b×8b→32b)
                       (8 kanal)         │ acc gölge kopyası
                                         ▼
                              yeniden_olcekle (1–2 hat, boru hattı)
                                         ▼
                              [GELU LUT] ─► çıktı tamponu ──UART──► PC
```

### 6.3 Tiling planı (host akıtmalı)
`Y[T×C] = X[T×K]·Wᵀ[K×C]`, T=64, dizi 8×8, çıktı tile'ı = 8 token × 8 çıktı kanalı, çıkış-sabit.
```
her çıktı paneli p (8 kanal):        # host sırayla gönderir
    host→FPGA: W paneli (8×K bayt), bias (8×4 B), M0 (8×4 B), n        # K=128: 1 088 B
    her token bloğu b (8 token):      # FPGA içinde, veri hareketi yok
        K boyunca akıt (A = X[b], B = panelᵀ) → 8×8 acc → requant → Y[b,p]
```
- Aktivasyonlar FPGA'da yerleşik; yalnızca ağırlık paneli akar, her panel 8 token bloğunda yeniden kullanılır.
- Q·Kᵀ ve Dikkat·V aktivasyon×aktivasyon → host trafiği yok.
- Panel çift tamponlu: FPGA panel p'yi işlerken host p+1'i gönderir.

**BRAM bütçesi (tahmin; sentezle doğrula; Basys3 50×BRAM36 = 225 KB):** girdi aktivasyonu en büyük 64×512 = 32 KB (8) · çıktı aktivasyonu 32 KB (8) · Q,K,V 24 KB (6) · skor/olasılık 8 KB (2) · panel çift tampon 8 KB (2) · bias/M0/LUT ≈2 KB (1) → toplam ≈106 KB ≈ 27–30 BRAM36.
**DSP bütçesi (tahmin):** 8×8 = 64 PE × 1 DSP; requant (31b×32b ≈3–4 DSP/hat) **1–2 hat seri**, tile hesabı (K+14 çevrim) ile örtüşür → ≈72/90 DSP. 16×16 bu kartta mümkün değil. acc 64×32 bit gölge yazmaca kopyalanır (≈2 048 FF).
**Çevrim (tahmin):** tile = K+2N−2 = K+14. Katman başına: Q,K,V,attn_out 4×(128 tile×142)=72 704 · ffn1 72 704 · ffn2 (K=512) 67 328 · dikkat (2 baş, K=64) 19 968 → 232 704/katman, iki katman ≈465 k, +pooler/sınıflandırıcı ≈ **468 k çevrim ≈ 4,7 ms @100 MHz** (yalnız hesap, tam dolu dizi).
**Host trafiği:** çıkarım başına ≈420,7 KB ağırlık; UART 921 600 baud ≈4,6 sn, 3 Mbaud ≈1,4 sn (donanımda doğrulanmalı).

### 6.4 Host↔hızlandırıcı protokolü (G9'da kesinleşir)
Paket: `[komut:1][uzunluk:2-3][yük][CRC8/toplam:1]`; hızlandırıcı her pakete `ACK`/`HATA` döner.
`CFG` (katman kimliği, T,K,C, n, bayraklar) · `YUKLE_AKT` (tampon, satır×sütun, veri) · `YUKLE_PANEL` (panel no, 8×K bayt W, 8×INT32 bias, 8×INT32 M0) · `CALISTIR` (katman) · `OKU_AKT` (tampon) · `DURUM`.
`host/hizlandirici_surucu.py` iki arka uç: (a) **benzetim** (testbench komut dosyasını okuyup yanıt dosyası yazar), (b) `pyserial` (kart gelince). Sürücü aynı kalır.

## 7. Görevler

Süre = tek kişilik saat tahmini. **K** kritik · **Ö** önemli · **S** isteğe bağlı. Her görev: **Kabul** = bitiş ölçütü; **TR** = üretilecek tasarım raporu; **Şekiller** = raporda zorunlu görseller (en az 3; bölüm 8).

### G0 — Zemin · K (≈1–1,5 sa)
- `03-RTL/{rtl,tb,sim,vektor,scripts}`, `host/` aç. `old/bert-tiny-fpga/donanim` içinden `pe.v`, `systolic_4x4.v`, `tb_pe.v`, `tb_systolic_4x4.v` (+ `tb/gen_vektor.py`, `tb/vektor/`) kopyala.
- Icarus'u doğrula; bölüm 3.4 şablonuyla eski testleri koştur.
- `03-RTL/scripts/vcd_ciz.py` yaz: bir `.vcd`'den seçilen sinyalleri matplotlib ile çizer (dalga formu şekilleri için; raporlarda kullanılacak).
- README yollarını düzelt (`03-` → `02-`). `git commit`.
- **Kabul:** `PE TEST: PASS (1012 kontrol, 0 hata)`, `SYSTOLIC 4x4 TEST: PASS (264 test, 0 hata)`, `11 geçti, 0 kaldı`, `TÜM ÖLÇÜTLER GEÇTİ`; `vcd_ciz.py` eski `tb_systolic_4x4.vcd`'den bir şekil üretir.

### G1 — Test vektörleri RTL için tamamla · K (≈1,5 sa)
- `04_test_vektoru_uret.py`'a ekle: her katman için `<ad>_cikis.mem` (requant sonrası INT8), panel-düzeni ağırlık (`8 kanal/blok`) ve token-bloğu düzeni; Q·Kᵀ (INT8×INT8) ve Dikkat·V (UINT8×INT8) için ayrı girdi/çıkış vektörleri. Düzeni (satır-öncelikli, T=64, C) bir `OKUBENI` ile belgele.
- **Kabul:** Python'da `birikec → +bias → M0/n → yuvarla → kırp` yeniden hesaplanınca `*_cikis.mem` ile birebir.
- **TR:** raporun parçası (TR05'te kullanılır). **Şekiller:** (opsiyonel) vektör düzeni şeması.

### G2 — Birimler arası taşımayı tamsayıya al ve ölç · K (≈2–3 sa)
- `model.py`'a bayrak (ör. `tasima="tam"`): gömme çıkışı, artık toplamlar, Q·Kᵀ, Dikkat·V tamsayı. Dikkat·V'de UINT8 olasılık (9 bit A) modellenir. 872 cümlede koştur.
- Adım adım kayıp tablosu (hangi adım kaç cümle/puan kaybettirdi), Şekil 7 biçiminde.
- **Kabul:** sonuç ≥711/872 **ya da** hedefin altında kalıyorsa neden ve çözüm önerisiyle raporlanır; katı sınır ≥702. `02_dogrula_ptq.py` hâlâ geçer (A kipi değişmez).
- **Şekiller (2. ilerleme raporu için):** adım adım doğruluk grafiği, ayrışan cümlelerin logit farkı, kayıp çubuğu.

### G3 — Ara ölçek kalibrasyonunu güçlendir · Ö (≈1 sa + Colab)
- `03_kalibre_ara_olcek.py`: 512 cümle, 3 tohum; tohumlara göre doğruluk aralığı; G2 bu ölçeklerle tekrar. Gerekirse Colab'da (HF erişimi), çıktıyı Drive'dan indir.
- **Kabul:** 3 tohumun doğruluğu tabloda ve grafikte.

### G4 — PE'yi parametrik yap, 8×8 akışlı dizi · K (≈2 sa) · **TR02, TR03**
- `pe.v`: `A_W` (9), `B_W` (8), `ACC_W` (32). `systolic_nxn.v`: `N` 4 ve 8, **akışlı arayüz** (her çevrimde bir A sütunu ve bir B satırı), mevcut sayaçlı skew korunur. `N=4` çıktısı eski modülle birebir (regresyon).
- Testbench: rastgele + uç değer (−128×−128, 255×−128) + K=512 en kötü durum; UINT8×INT8 birim testi (9 bit A); `tb/gen_vektor.py` ile Python referansı.
- **Kabul:** N=4 ve N=8 `PASS`; tile başına çevrim K+14 logda görülür.
- **Şekiller:** PE (9 bit A) blok şeması · 8×8 veri akışı + skew çizelgesi (N=8, kodla hesaplanmış) · dalga formu (VCD, ilk/son veri) · hata sayısı/vektör tablosu grafiği · (TR02) 9 bit A değer aralığı çizimi (UINT8 0..255 ve INT8 −128..127 → 9 bit işaretli).

### G5 — Tile denetleyici · K (≈2–3 sa) · **TR04**
- Bölüm 6.3 akışı: aktivasyon BRAM'inden token bloğu, panel BRAM'inden panel, K boyunca akıt; gölge acc; adres üreteçleri; K=128, 512 ve 64 (dikkat) parametre. Önce küçük boyutla (16×16 çarpım) doğrula.
- **Kabul:** `l0_q_girdi.mem` + panel düzeninde `l0_q_w.mem` → 64×128 çıktı `l0_q_birikec.mem` ile **bit-birebir**, 4 cümlenin hepsi.
- **Şekiller:** tile haritası (64×128 çıktı → 8×8 tile ızgarası, işlenme sırası) · zaman çizelgesi (panel yükleme ↔ hesap örtüşmesi) · BRAM yerleşim şeması · dalga formu (bir tile) · çevrim sayısı: teorik vs. benzetim grafiği.

### G6 — Yeniden ölçekleme · K (≈1,5–2 sa) · **TR05**
- `(acc+bias)·M0 >> n`, altın modeldeki `yuvarla_yukari_tamsayi` ile aynı yuvarlama, [−128,127] kırp; 1–2 hat, boru hattı, tile ile örtüşme. Kanal başına M0, katman başına n (`KAYDIRMA_*`).
- **Kabul:** `*_cikis.mem` ile bit-birebir; M0 uç değeri ve taşma sınırı testleri geçer; DSP sayısı not edilir.
- **Şekiller:** boru hattı şeması (aşama aşama bit genişlikleri) · hata dağılımı histogramı (RTL−altın = 0) · M0/n değerleri 14 katman için çubuk grafiği · dalga formu.

### G7 — Tek doğrusal katman uçtan uca · K (≈1 sa) · **TR06**
- G5+G6: `dogrusal_katman` (aktivasyon BRAM → dizi → requant → çıktı BRAM); Q, K, V, attn_out, ffn1, ffn2 aynı modülle.
- **Kabul:** L0'ın 6 doğrusal katmanı kendi `_cikis.mem` dosyasıyla bit-birebir `PASS` (4 cümle).
- **Şekiller:** katman veri yolu şeması · 6 katman için doğrulama tablosu/grafiği (vektör sayısı, hata=0, çevrim) · katman başına çevrim çubuğu · dalga formu.

### G8 — GELU LUT · Ö (≈0,5–1 sa) · **TR07**
- 256 girişli ROM (INT8→INT8), `l0_ffn1` çıkışına bağlanır.
- **Kabul:** altın modelle bit-birebir.
- **Şekiller:** LUT eğrisi (FP32 GELU vs. tamsayı LUT) · maksimum hata grafiği · birim blok şeması.

### G9 — Host↔hızlandırıcı arabirimi ve host-in-the-loop · K (≈3–4 sa) · **TR08**
- Önce UART'sız bayt-akışı arayüzü; sonra `uart_rx`/`uart_tx` (parametrik baud), `komut_cozucu`, panel/aktivasyon yükleme, ACK/durum. Testbench komut dosyasını okuyup yanıt dosyası yazar. `host/hizlandirici_surucu.py` (benzetim arka ucu).
- **Kabul:** bir cümle için L0'ın doğrusal katmanları **PC→(benzetilen) FPGA→PC döngüsünde** altın modelle bire bir. Hata enjeksiyonunda (bozuk CRC) `HATA` döner.
- **Şekiller:** sistem blok şeması (PC/FPGA ayrımı) · paket formatı şeması · zaman çizgesi (host ↔ FPGA mesaj dizisi) · UART dalga formu · veri hacmi çubuğu (panel boyutları).

### G10 — Dikkat: Q·Kᵀ ve Dikkat·V dizide · Ö (≈1,5–2 sa) · **TR09**
- K'nın transpozu adreslemeyle; UINT8 olasılık 9 bit A ile; `l0_olasilik_u8.mem` ile doğrula.
- **Şekiller:** dikkat veri akışı şeması · skor/olasılık matrisi ısı haritası (altın vs. RTL, fark=0) · çevrim çubuğu.

### G11 — Softmax ve LayerNorm RTL · S (≈3–4 sa; yetişmezse host'ta kalır) · **TR10 (Softmax), TR11 (LayerNorm)**
- Softmax: satır max, exp LUT, toplam, tamsayı bölme. LayerNorm: tamsayı karekök (Newton, 4 yineleme) + bölme. Tek vektörle altın modele karşı doğrula.
- Yetişmezse bu iki birim host'ta kalır ve raporda **öyle yazılır**.
- **Şekiller:** FSM durum diyagramı · çevrim/aşama zaman çizelgesi · yaklaşıklık hata grafiği · dalga formu.

### G12 — Sentez ve kart hazırlık paketi · Ö (≈1,5–2 sa) · **TR12**
- Vivado (`xc7a35tcpg236-1`, 100 MHz kısıtı) yalnızca sentez: LUT, FF, DSP, BRAM, WNS. Vivado yoksa `yosys synth_xilinx` tahmini ("tahmin" etiketli). Bölüm 6.3 bütçeleriyle karşılaştır; 12 vs 16 bit LayerNorm kararına veri.
- Hocaya paket: Basys3 `.xdc`, UART üst modülü, `pyserial` arka ucu, 1 sayfalık istek notu.
- **Şekiller:** kaynak kullanımı çubuk grafiği (kullanılan/mevcut, %), tahmin vs. ölçüm karşılaştırması, zamanlama (WNS) özeti, kat başına DSP/BRAM dağılımı.

### G13 — 2. İlerleme Raporu (BIL 401) · K (≈4–5 sa)
Birinci rapor yapısı korunur (`02-RTL_Altin_Model/04_Rapor/Ilerleme_Raporu_BIL401_16Ekim2026.docx` şablon): önceki rapordan bu yana yapılanlar; tam tamsayı hat doğruluğu (G2) ve tohumlar (G3); mimari (PC/FPGA bölünmesi, tiling, protokol, 9 bit A); doğrulama kanıtı (modül/vektör/hata/çevrim tablosu + dalga formları + host-in-the-loop sonucu); sentez; **performans (dürüst, bölüm 9)**; sınırlar; sonraki adımlar. Şekil ağırlıklı, her sayı bir log/json dosyasından.

### G14 — Toplantı hazırlığı · K (≈1 sa)
5–6 ekranlık güncelleme (ne bitti, bit-birebir kanıt, sentez, açık maddeler, danışmandan istenen kararlar: 12/16 bit; Softmax/LayerNorm'ün host'ta kalması kabul mü). **FPGA/kart soruları danışmana değil, FPGA'dan anlayan hocaya.**

## 8. Rapor sistemi (görsel ağırlıklı)

### 8.1 Her rapor
`rapor_sistemi/tasarim_raporlari/TRnn_*.json` (spesifikasyon) → `python rapor_sistemi/rapor_uretici.py <json>` → `.docx`. TR01 hazırdır ve şablondur (4 şekil). Bölümler: amaç · karar özeti (tablo) + mimari şekilleri · literatür karşılığı (her konuda: kaynak, bölüm no, **tırnak içinde birebir alıntı**, **Bizde uygulama**, **Fark/dikkat**, şekil) · doğrulama kanıtı (tablo + şekil) · sınırlar · kaynakça.

### 8.2 Görsel kural (üretici zorlar)
1. **En az 3 şekil** (`MIN_SEKIL`); altında üretici hata verir. Gerekçeli istisna için spec'e `gorsel_istisna` yazılır.
2. Şekiller `rapor_sistemi/sekiller/trnn_sekiller.py` ile **gerçek veriden/loglardan** üretilir (`tr01_sekiller.py` şablon). Elle sayı yazılmış şekil yok; benzetim sonucu için VCD/log/json okunur.
3. Her rapor şu türlerden en az **üçünü** içerir: (a) blok şeması/mimari, (b) zamanlama/dalga formu veya veri akışı çizelgesi, (c) sonuç grafiği (hata dağılımı, doğruluk, çevrim, kaynak), (d) tablo-grafik (doğrulama özeti).
4. Her şeklin yazılı başlığı ve "nasıl okunur" açıklaması olur; metinde ona atıf yapılır; sayfa başına ağırlık şekil/tabloda, paragraf kısa tutulur.
5. 200 dpi, genişlik ≤16 cm, Türkçe etiket, renk körü dostu palet (mavi/turuncu/yeşil/gri), eksen etiketi ve birim zorunlu.
6. Üretimden sonra docx → PDF → görsel kontrol (taşma, üst üste binen etiket, boş şekil); sorun varsa düzelt.

### 8.3 Literatür kuralı
Yalnızca 2021 sonrası. Alıntı kimlikleri `literatur_kutuphanesi.json`'da (Ek B). Kütüphanede olmayan kimlik üreticide hata verir. **Teslimden önce her alıntıyı PDF'te bölüm numarasıyla gözle doğrula** (alıntılar web okuyucusuyla iki bağımsız çekimde bulundu, otomatik dosya eşleştirmesi yapılamadı). Kaynak boşlukları: 9 bit işaretli A (UINT8 olasılık) ve PC–FPGA UART arabirimi için doğrulanmış 2021 sonrası kaynak yok; bu raporlarda "doğrudan karşılık bulunamadı; mühendislik kararı" yaz, aramaya devam et.

### 8.4 Rapor eşlemesi
| TR | Görev | Konu | Hazır alıntılar | Boşluk |
|---|---|---|---|---|
| TR01 | (hazır) | PE + çıkış-sabit 4×4 dizi | DF-01/02, SW-01, KV-03, SN-03 | skew için 2021+ kaynak |
| TR02 | G4 | PE 9 bit işaretli A girişi | – | **kaynak yok** |
| TR03 | G4 | Parametrik 8×8 dizi, akışlı arayüz | KV-02, KV-03, SN-01 | – |
| TR04 | G5 | Tile denetleyici, host'tan panel akıtma | TL-01, TL-02, KV-01, SN-01 | host'tan ağırlık akıtma |
| TR05 | G6 | Yeniden ölçekleme | SW-03, IV-01, IO-01, IO-02 | – |
| TR06 | G7 | Doğrusal katman uçtan uca | SW-01, KV-04 | – |
| TR07 | G8 | GELU LUT | SN-02, QK-02 | GELU LUT doğrudan |
| TR08 | G9 | Host↔FPGA arabirimi | – | **kaynak yok** |
| TR09 | G10 | Dikkat (Q·Kᵀ, A·V) | SN-01 | – |
| TR10 | G11 | Softmax | SW-04, IV-02, IO-03, IO-04 | – |
| TR11 | G11 | LayerNorm / karekök | SW-05, IV-03, QK-01 | – |
| TR12 | G12 | Sentez/kaynak | SN-03, QK-03 | – |

## 9. Performans gerçeği (rapora girmeden önce)
- 8×8 dizi @100 MHz, tam doluluk: ≈4,7 ms (**tahmin**). Rapordaki ölçülen tek iş parçacıklı CPU süresi 2,49 ms. Bu kartta, bu dizi boyutuyla **PC CPU'suna göre hız kazancı beklenmez**; 90 DSP sınırı diziyi büyütmeye izin vermez. UART trafiği (ağırlıklar her çıkarımda akıtılır) üstüne biner.
- Bu bir başarısızlık değil, edge-hızlandırıcının ölçülmüş sınırıdır. Uygun çerçeveler: (a) çevrim/MAC verimliliği ve doluluk, (b) dolgu token'larını atlama (test cümleleri 4–6 token, dizi 64'e doluyor; 8'lik bloklarda gerçek uzunluğa göre atlanırsa hesap birkaç kat azalır — **yalnızca ölçülürse yazılır**), (c) daha büyük FPGA'ya ölçekleme projeksiyonu (etiketli), (d) daha zayıf gömülü CPU ile karşılaştırma (ölçülürse).
- Hız iddiasını yalnızca ölçülen sayıyla yaz; hesaplananı "tahmin" diye etiketle; FPGA süresini hesap ve UART olarak ayrı raporla.

## 10. Zaman çizelgesi ve öncelik
| Gün | İş |
|---|---|
| Salı 27 Ekim | G0, G1; G2'yi başlat (arka planda); G4'e başla. Hocaya mesaj: kart + Vivado erişimi |
| Çarşamba 28 Ekim | G4–G6 (bit-birebir kanıtlar); G3 (Colab); G9'un UART/komut kısmı. Okulda hocayla görüş |
| Perşembe 29 Ekim | G7, G8, G9 (host-in-the-loop), G10; G12 sentez. Akşam rapor taslağı (G13) |
| Cuma 30 Ekim (sabah) | G13–G14 son kontrol; tüm sayıları kaynak dosyalarla karşılaştır |

**Asgari teslim (MVP):** G0, G1, G2, G4–G7, G9 (en az bir doğrusal katmanda host-in-the-loop), G12, G13 + ilgili TR raporları. Zaman daralırsa sırayla **G11 → G10 → G8 → G3** kesilir. Her TR raporu için ≈45–60 dk ayrılır; MVP raporları (TR02–TR06, TR08, TR12) kesilmez.

## 11. Riskler
- **G2 hedefi sağlamayabilir** (artık toplam/Q·Kᵀ tamsayıya alınınca ≥711 altı). Bulgudur; ölçüp nedeniyle raporla (muhtemel neden: LayerNorm girdisindeki artık bağlantı aykırı değerleri, gizli boyut 2'de −28,9). Çözüm adayları: kanal bazlı ölçek, o noktada 12/16 bit.
- **G5 en riskli RTL adımı.** Küçük boyutla başla.
- **G9 kapsamı büyüyebilir.** Önce UART'sız arayüz.
- **Vivado erişimi yoksa** sentez sayıları "tahmin" etiketiyle gider.
- **UART saat/baud uyuşması:** 100 MHz'den bölücü; benzetimde hata enjekte et.
- **Alıntı doğruluğu:** teslimden önce PDF'te gözle kontrol (bölüm 8.3).

## 12. Okulda hocaya götürülecek liste
1. Basys3 ve Vivado kurulu bilgisayar ne zaman kullanılabilir?
2. Bitstream yükleme ve USB-UART (sürücü, port, baud) için destek.
3. 100 MHz'de 8×8 INT8 dizi için zamanlama beklentisi; DSP48 ile 9×8 çarpma için tavsiye.
4. (Opsiyonel) Basys3'ün dahili QSPI flash'ı ağırlıkların kalıcı saklanması için kullanılabilir mi (boyutu doğrulanmalı)? UART trafiğini azaltabilir.

## Ek A — Veri sözlüğü
- `.mem` dosyaları `$readmemh` ile okunur; ilk iki satır `//` yorumu, sonra her satır bir eleman (hex, iki'ye tümleyen, satır-öncelikli). Biçim ve şekil başlıkta yazar.
- `<ad>` kısa adları: `l0_q, l0_k, l0_v, l0_attn_out, l0_ffn1, l0_ffn2, l1_…, pooler, classifier`.
- Parametre: `<ad>_w.mem` (INT8, [Cout×K]), `<ad>_b.mem` (INT32), `<ad>_m0.mem` (M0, 31 bit); `l0_exp_lut.mem` vb. LUT'lar; katman başına `KAYDIRMA_<AD>` (`parametreler.vh`) ve `bellek_haritasi.json` (boyutlar, a_olcek, kaydırma, BRAM tahmini).
- Test vektörü: `<ad>_girdi.mem` (INT8 [n_cumle,64,K]), `<ad>_birikec.mem` (INT32 [n_cumle,64,Cout]), `token_ids.mem` (16 bit), `maske.mem` (8 bit), `fpga_girdi_q.mem` (gömme+LayerNorm çıktısı, ilk katman Q ölçeğinde INT8), `l*_olasilik_u8.mem` (UINT8), `kunye.json` (cümle indeksleri, `*_sekil`, `birikec_maks_mutlak`, `gereken_bit`).
- Altın model API: `ortak.yukle_hepsi(args)`; `model.AltinModel(p, model.Ayarlar.B_kipi(...)).ileri(ids, maske)`; `Ayarlar(kip="A"|"B"|"fp32", izle_ara_tensor=True)` ile ara tensörler `m.izle[...]` sözlüğüne yazılır (ör. `m.izle["l0.q.girdi_q"]`).

## Ek B — Literatür kütüphanesi (otomatik; `literatur_kutuphanesi.json` ile aynı)

> Alıntılar makale metninden iki bağımsız çekimle (27 Ekim 2026) denetlendi. Çekim aracı formülleri ve uzun cümleleri kırptığı için alıntılar ≤125 karakterlik, makalede birebir geçen ifadelerdir; bazıları cümlenin bir parçasıdır (tam_cumle=false). Teslimden önce PDF'te ilgili bölüm numarasında gözle doğrulayın.

**Kaynaklar (hepsi 2021 sonrası)**

- **SwiftTron** — A. Marchisio, D. Dura, M. Capra, M. Martina, G. Masera, M. Shafique (2023 (arXiv:2304.03986, Nisan 2023)). *SwiftTron: An Efficient Hardware Accelerator for Quantized Transformers*. https://arxiv.org/abs/2304.03986
- **I-ViT** — Z. Li, Q. Gu (2023 (ICCV 2023; arXiv:2207.01405, Temmuz 2022)). *I-ViT: Integer-only Quantization for Efficient Vision Transformer Inference*. https://arxiv.org/abs/2207.01405
- **IntOnlyFPGA** — T. Ling, C. Qian, G. Schiele (2024 (arXiv:2407.11041, Temmuz 2024)). *Integer-only Quantized Transformers for Embedded FPGA-based Time-series Forecasting in AIoT*. https://arxiv.org/abs/2407.11041
- **DataflowReview** — Z. Li (2025 (arXiv:2505.08992, Mayıs 2025)). *Dataflow & Tiling Strategies in Edge-AI FPGA Accelerators: A Comprehensive Literature Review*. https://arxiv.org/abs/2505.08992
- **KV260-Tiled** — R. Li, S. Chen (2025 (arXiv:2503.16731, Mart 2025)). *Design and Implementation of an FPGA-Based Tiled Matrix Multiplication Accelerator for Transformer Self-Attention on the Xilinx KV260 SoM*. https://arxiv.org/abs/2503.16731
- **QUARK** — Z. Zhao, H. Li, F. Liu, Y. Lu, Z. Wang, T. Yang, L. Jiang, H. Guan (2025 (arXiv:2511.06767, Kasım 2025)). *QUARK: Quantization-Enabled Circuit Sharing for Transformer Acceleration by Exploiting Common Patterns in Nonlinear Operations*. https://arxiv.org/abs/2511.06767
- **SwinFPGA** — Z. Liu, Z. Ren, P. Yin (2023 (arXiv:2308.13922, Ağustos 2023)). *An Efficient FPGA-Based Accelerator for Swin Transformer*. https://arxiv.org/abs/2308.13922

**Doğrulanmış alıntılar** (kimlik · kaynak · bölüm · metin)

| Kimlik | Kaynak | Bölüm | Alıntı |
|---|---|---|---|
| DF-01 | DataflowReview | II.A Weight-Stationary (WS) | “In Weight-Stationary dataflow, each PE keeps its filter weights locally, and partial sums / activations stream through.” |
| DF-02 | DataflowReview | II.B Output-Stationary (OS) | “partial sums for a specific output element (or a small group of output channels) remain in local PE registers or buffers” *(cümlenin parçası)* |
| TL-01 | DataflowReview | IV.A Two-Level Tiling | “Fit in BRAM: The tile must not exceed available BRAM or URAM capacity.” |
| TL-02 | DataflowReview | IV.A Two-Level Tiling | “Outer tile size is chosen so that a large chunk can be loaded into on-chip buffers once and reused many times.” |
| SW-01 | SwiftTron | III-A Quantization and Scaling Factor Design | “The matrix multiplications are conducted with INT8 inputs and INT32 accumulators.” |
| SW-02 | SwiftTron | III-A Quantization and Scaling Factor Design | “The nonlinear functions operate on INT32 to avoid excessive accuracy loss.” |
| SW-03 | SwiftTron | III-C Hardware Architecture of the Requantization Unit | “the required resources are only an INT32 multiplication and a one-bit shifting” *(cümlenin parçası)* |
| SW-04 | SwiftTron | III-F Hardware Architecture of the Softmax Unit | “The most complex operator is the divider, whose implementation consumes relatively more resources.” |
| SW-05 | SwiftTron | III-I Residual Connection and Layer Normalization Units | “It is a recursive algorithm that needs multiple cycles to compute the output.” |
| IV-01 | I-ViT | 3.2 Dyadic Arithmetic for Linear Operations | “In this case, the rescaling can be efficiently accomplished by integer multiplication and bit-shifting.” |
| IV-02 | I-ViT | 3.3 Integer-only Softmax: Shiftmax | “Shiftmax performs all arithmetic with bit-shifting, except for one integer subtraction, summation, and division” *(cümlenin parçası)* |
| IV-03 | I-ViT | 3.5 Integer-only LayerNorm: I-LayerNorm | “we improve the light-weight integer iterative approach [8] via bit-shifting” *(cümlenin parçası)* |
| IV-04 | I-ViT | Abstract | “to enable ViTs to perform the entire computational graph of inference with integer arithmetic and bit-shifting” *(cümlenin parçası)* |
| IO-01 | IntOnlyFPGA | IV-A Addition Component | “which can be approximated using a precomputed positive integer M by right-shifting by n bits” *(cümlenin parçası)* |
| IO-02 | IntOnlyFPGA | IV-A Addition Component | “This process, referred to as ApproxMul, ensures that all operations remain within the integer domain.” |
| IO-03 | IntOnlyFPGA | IV-C Softmax Component | “we adopt a Softmax implementation based on lookup tables for computing exp () for all possible inputs.” *(cümlenin parçası)* |
| IO-04 | IntOnlyFPGA | IV-C Softmax Component | “However, this division operation is resource-intensive on FPGAs.” |
| KV-01 | KV260-Tiled | 4.1 HLS Implementation and Parallel Computation | “Matrix A is loaded once into persistent BRAM, while matrix B is streamed in blocks.” |
| KV-02 | KV260-Tiled | 4.1 HLS Implementation and Parallel Computation | “Local buffers (register-level tiling) store 32×32 tiles of A and B for rapid access.” |
| KV-03 | KV260-Tiled | 4 (II. Spatial Mapping) | “Fully unrolling the innermost loops creates a 32×32 array of multipliers-adders for parallel computation.” |
| KV-04 | KV260-Tiled | 7 Challenges and Optimizations | “Converting DistilBERT weights and activations to int8 required careful calibration.” |
| QK-01 | QUARK | III-A Integer-only LayerNorm without Division | “This iterative method converges within ten iterations for any INT8 input, avoiding nonlinear operations like division.” |
| QK-02 | QUARK | V-C(b) Nonlinear Operators Resource Utilization | “Traditional implementations rely on memory-intensive LUT methods or extensive division operations.” |
| QK-03 | QUARK | IV-B Group Quantization Unit | “Dynamic bit-width adjustment is applied to balance quantization precision and hardware cost.” |
| SN-01 | SwinFPGA | IV.B Matrix Multiplication Unit (MMU) | “The core idea behind our MMU design is to employ blocked matrix multiplication for computing matrix products.” |
| SN-02 | SwinFPGA | IV.D The Overall Architecture of GCU | “The structure of GCU is relatively simple, consisting of a polynomial computation unit, an EU, and a GU.” |
| SN-03 | SwinFPGA | V.D.1 Resource Utilization of Submodules | “MMU accounts for the majority of DSP utilization.” |

---
*Son.* Bu dosya güncellendikçe sürümü `git` ile izlenir; alıntı kütüphanesi yalnızca `rapor_sistemi/literatur_kutuphanesi.json` üzerinden değişir.
