# 04-RTL_Komutsuz — komutsuz hızlandırıcı prototipi (benzetim + Vivado)

Komutsuz akış: dışarıdan yalnız veri baytı gelir; ne geleceğini sabit çizelge bilir; her blok sonunda 16 bit CRC (CCITT) denetlenir.
Hesap birimleri `../03-RTL/rtl/` içinden okunur (değiştirilmedi). Mimari notu: `notlar/MIMARI_NOTU_P1_komutsuz_akis.md`.

| Dosya | İş |
|---|---|
| `rtl/akis_ayristirici.v` | bayt akışı → bloklar, CRC-16 denetimi, bellek yazma |
| `rtl/cizelge_siralayici.v` | sabit çizelge (katman 0 Q, K, V) + durum makinesi |
| `rtl/komutsuz_ust.v` | üst modül (+ mevcut `dogrusal_katman`) |
| `tb/tb_komutsuz_ust.v` | testbench (altın model karşılaştırması, hata enjeksiyonu) |
| `scripts/akis_uret.py` | bayt akışı üretici (Python CRC, bağımsız) |
| `scripts/kos_komutsuz.py` | regresyon: `python scripts/kos_komutsuz.py [--hizli]` |
| `sentez/sentez_komutsuz.tcl` | Vivado: `vivado -mode batch -source sentez/sentez_komutsuz.tcl` (cwd bu klasör) |

Sonuçlar (6 Kasım 2026, benzetim ve Vivado): bayt/çevrim 1: 79 655 çevrim/cümle, 24 576 kontrol 0 hata; bayt/8 çevrim: 500 659 çevrim; CRC hata enjeksiyonu yakalandı.
Vivado 100 MHz (yerleştirme sonrası, bağlamsız): 1 242 LUT, 3 832 FF, 17 BRAM, 68 DSP, WNS +1,722 ns, WHS +0,070 ns. Kart yok.

## Flaş kaynağı (P3, 6 Kasım 2026)
`rtl/qspi_okuyucu.v` (komut 0x6B, dört hatlı çıkış okuması, tek işlemde tüm akış), `rtl/komutsuz_flas_ust.v` (okuyucu + `komutsuz_ust`), `tb/flas_modeli.v` (yalnız benzetim), `tb/tb_flas_ust.v`, `scripts/kos_flas.py`, `notlar/MIMARI_NOTU_P3_flas_okuyucu.md`.
Benzetim: SCK 25 MHz → 500 786 çevrim/cümle (8,28 çevrim/bayt); SCK 50 MHz → 258 690 (4,27); ikisi de 24 576 kontrol 0 hata; hatalı içerikte CRC yakalandı. 4 cümlelik tam regresyon (`kos_komutsuz.py`): 98 304 kontrol 0 hata.
Vivado 100 MHz (flaş dahil): 1 323 LUT, 3 911 FF, 17 BRAM, 68 DSP, WNS +2,280 ns, WHS +0,072 ns.
Görev listesi: `notlar/GOREV_LISTESI.md`.

## Adım 1a/1b (11–12 Kasım 2026): gömülü sabit veriler
- `rtl/softmax_birim_gomulu.v`, `tb/tb_softmax_gomulu.v`, `vivado/sim_softmax_gomulu.bat`: Softmax üstel tablosu gömülü. Vivado xsim: 325 satır, 20 800 kontrol, 0 hata.
- `rtl/parametre_rom.v`, `panel_parametre_yukleyici.v`, `gelu_yukleyici.v`, `dogrusal_katman_gomulu.v`; üretici `scripts/uret_parametre_rom.py` (param_bias.mem, param_m0.mem, gelu_l0/l1.mem, tanh.mem, parametre_harita.vh); test `tb/tb_parametre_gomulu.v`, `vivado/sim_parametre_gomulu.bat`.
  12 doğrusal katman, sapma/M0/GELU tablosu gömülü bellekten: 147 456 kontrol, 0 hata, 431 256 çevrim (gömülü olmayan sürümle aynı).
  Vivado 100 MHz (bağlamsız, `sentez/sentez_param_gomulu.tcl`): ilk sürüm 1 631 LUT, 24,5 blok bellek. Bellek tasarrufundan sonra (tek birleşik 46 bit ROM + GELU tabloları dağıtık bellekte): 1 683 LUT, 3 832 FF, **23 blok bellek**, 68 DSP, WNS +2,06 ns, WHS +0,07 ns; test yine 147 456 kontrol 0 hata.

## Adım 2 (12 Kasım 2026): dikkat zinciri Q·Kᵀ → ölçekleme → Softmax → olasılık belleği
Dosyalar: `rtl/dikkat_cekirdegi.v` (üst), `panel_kopyalayici.v`, `yeniden_olcekle_ortak.v` (tek çarpma devresi, 8 bit/32 bit kırpma), `softmax_birim_gomulu.v`; testler `tb/tb_dikkat_zinciri.v`, `tb/tb_yeniden_olcekle_ortak.v`; üretici `scripts/uret_dikkat_vektor.py` (vektor_dikkat/); `vivado/sim_dikkat_zinciri.bat`; `sentez/sentez_dikkat.tcl`.
Sonuç: 2 katman × 2 baş × 4 cümle = 16 iş, 131 072 kontrol (skor ve olasılık), 0 hata (Icarus); Vivado xsim 2 cümle 65 536 kontrol 0 hata. Ortak yeniden ölçekleme: 40 000 rastgele giriş, 0 hata. Çevrim (baş başına): Q·Kᵀ 5 384, Softmax 16 000.
Vivado 100 MHz (bağlamsız): 1 893 LUT, 3 935 FF, 23 blok bellek (şimdilik ayrı Q ve K 32 KB'lık bellekler; Adım 4'te birleşik 48 KB), **75 DSP** (dizi 64 + ölçekleme 4 + Softmax 7; LayerNorm 12 eklenince 87 ≤ 90), WNS +2,05 ns, WHS +0,04 ns.

## Adım 3 (12 Kasım 2026): akışta cümle uzunluğu
Aktivasyon bloğu artık `1 bayt uzunluk + 8192 bayt + 2 bayt CRC`; CRC uzunluk baytını da kapsar. `akis_ayristirici` doğrulanmış uzunluğu `cumle_uzunluk` çıkışına verir (komutsuz_ust, komutsuz_flas_ust üzerinden). Cümle akışı 60 515 bayt. `kos_komutsuz.py` ve `kos_flas.py` yeniden PASS (flaş 25 MHz: 500 794 çevrim, 50 MHz: 258 694). Vivado xsim: `vivado/sim_komutsuz_akis.bat`.

## Adım 4 (12 Kasım 2026): birleşik aktivasyon belleği (48 KB, 6 birim) ve katman zinciri
`rtl/birlesik_bellek.v` (6 ayrı 1024 sözcüklük birim), `rtl/dogrusal_katman_birlesik.v` (giriş/çıkış adres tabanları, gömülü parametreler, ortak yeniden ölçekleme), `tb/tb_birlesik_bellek.v`, `scripts/uret_zincir_vektor.py`, `vivado/sim_birlesik_bellek.bat`, `sentez/sentez_birlesik.tcl`.
Senaryo A: giriş birim 6; Q→birim 1, K→birim 2, V→birim 3. Senaryo B: ileri besleme 1 (GELU) girişi birim 5, çıkışı birim 1–4; ileri besleme 2 girişini AYNI yerden okur (kopyasız), çıkışı birim 6. 65 536 kontrol, 0 hata; çevrimler önceki ayrı bellekli sürümle aynı (18 522 / 73 866 / 67 674).
Not: altın modelin tek-katman vektörlerinde ileri besleme 2 girdisi, ileri besleme 1 GELU çıkışından farklı ölçektedir (42 771 eleman farklı); zincirin beklenen çıkışı bu yüzden aynı tamsayı formülle (önce ileri besleme 2'nin kendi vektörüyle doğrulanarak) hesaplanır.
Vivado 100 MHz (bağlamsız): 1 932 LUT, **20 blok bellek** (önceki ayrı 64 KB'lık bellekli gömülü sürüm 23), 68 DSP, WNS +1,13 ns, WHS +0,05 ns. (Tek 6144 derinlikli bellek 16 blok bellek tuttu; altı ayrı birim 12 tutuyor.)

## Adım 5a/5b (12 Kasım 2026): değer matrisinin devrik yazımı ve P·V
5a: `rtl/cikis_sozcuk_toplayici_devrik.v` + `dogrusal_katman_birlesik.v` (`devrik_yaz`): V katmanı çıkışı panel düzeninde (sözcük = 8 kanal) yazılır; `tb_birlesik_bellek.v` Senaryo C: 2 baş × 512 sözcük altın modelin `l*_av_h*_w_panel` dosyasıyla birebir. Hata bulundu ve düzeltildi: son tile'ın 8 sözcüğü katman_bitti'den sonra yazılıyordu; devrik kipte bitiş 10 çevrim ertelenir.
5b: `dikkat_cekirdegi.v` artık iki kipli (`mod` 0: Q·Kᵀ+Softmax, 1: P·V). P·V'de A operandı çekirdeğin KENDİ ürettiği olasılıklar (işaretsiz, belleğinden), B operandı değer paneli (kopyalayıcıyla), yeniden ölçekleme ortak devreyle 8 bit kırpmalı (M0 853 716 708 / 798 658 972, n=37), bağlam belleğine yazılır. Test `tb/tb_dikkat_pv.v`: 2 katman × 2 baş × 2 cümle, 32 768 bağlam değeri altın modelin attn_out girdisiyle birebir; `vivado/sim_dikkat_pv.bat`.
Vivado 100 MHz (dikkat çekirdeği, bağlamsız): 1 972 LUT, 24 blok bellek, 75 DSP (LayerNorm 12 ekleyince 87), WNS +1,37 ns, WHS +0,07 ns.

## Adım 5c (12 Kasım 2026): artık toplama + LayerNorm (+ sonraki girdinin yeniden ölçeklenmesi)
`rtl/artik_ln_blogu.v` (tek yeniden ölçekleme devresi üç iş için sıraya girer: x akışı, a akışı, LayerNorm çıkışı), `rtl/layernorm_birim_dz.v` (orijinal LayerNorm'un xsim uyumlu kopyası; `scripts/uret_ln_duzeltilmis.py`), gömülü gamma/beta (`ln_gamma.mem`, `ln_beta.mem`) ve sabitler (`ln_harita.vh`; üretici `scripts/uret_ln_vektor.py`), test `tb/tb_artik_ln.v`, `vivado/sim_artik_ln.bat`, `sentez/sentez_artik_ln.tcl`.
Referans: altın modelin TAM TAMSAYI hattı (B kipi) 4 test cümlesinde çalıştırılıp her LayerNorm için x, a, q, y ve sonraki girdi z yakalandı; formül Python'da önce doğrulandı. Sonuç: 4 LayerNorm × 4 cümle, 98 816 kontrol, 0 hata (Icarus); xsim 1 cümle 24 704 kontrol 0 hata. Son LayerNorm'da havuz yalnız ilk tokeni kullandığından yalnız ilk token karşılaştırılır. Çevrim: LayerNorm başına yaklaşık 45 764 (satır başına ≈715).
Vivado 100 MHz (blok): 1 472 LUT, 1 407 FF, 6 blok bellek, 16 DSP (LayerNorm 12 + ölçekleme 4), WNS +2,82 ns, WHS +0,05 ns.
Not (5d için): dogrusal_katman_birlesik, dikkat_cekirdegi ve artik_ln_blogu şimdilik her biri kendi dizi/ölçekleme devresine sahip; birleşik tasarımda tek 8×8 dizi (64 DSP) ve tek ölçekleme devresi (4 DSP) paylaşılacak: 64+4+7+12 = 87 ≤ 90.

## Adım 5d-i/ii (12 Kasım 2026): ortak çekirdek (tek dizi + tek ölçekleme)
`rtl/ortak_cekirdek.v` (4 iş türü: doğrusal, Q·Kᵀ+Softmax, P·V, artık+LayerNorm), `rtl/birlesik_bellek_2o.v` (iki okuma portlu 48 KB; çarpışma uyarısı), `rtl/artik_ln_ortak.v` (`scripts/uret_ln_ortak.py` ile üretilir; kendi ölçekleme devresi yok), test `tb/tb_ortak_cekirdek.v`, `vivado/sim_ortak_cekirdek.bat`, `sentez/sentez_ortak.tcl`.
Yerleşim kuralı: Q·Kᵀ ve P·V'de taban_giris ile taban_ikinci farklı 1024'lük birimde. Q ve K baş başına 8 panelle (64 kanal) koşulur; V tek işte devrik; P·V çıktısı `cikis_panel_ofset` (baş×8) ve `baglam_kanal`=128 ile 128 kanallı bağlam düzenine yazılır.
Sonuç (Icarus, 1 cümle): doğrusal Q/K/V/ffn1/ffn2, 2 katman×2 baş dikkat, 4 LayerNorm: 106 624 kontrol, 0 hata, bellek okuma çarpışması 0. xsim derleme+elaborasyon temiz.
Vivado 100 MHz (bağlamsız): 4 347 LUT, 5 936 FF, 29 blok bellek, **87 DSP** (bütçe 90), WNS **−0,016 ns** (2 uç nokta; küçük zamanlama açığı, sonra kapatılacak), WHS +0,064 ns.

## Adım 5d-iii/iv (12 Kasım 2026)
Sabit çizelge (`rtl/cizelge_ortak.v`, katman başına 14 satır) + üst modül (`rtl/ortak_ust.v`): bayt akışı → CRC-16 ayrıştırıcı (bias/M0 gömülü, panel = K×8 bayt + CRC) → çizelge → ortak çekirdek.
Eklenenler: GELU tablosu ile ileri besleme 2 girdi ölçeklemesi tek tabloda (`gelu_ffn2_l0/l1.mem`, 131 072/131 072 eşit); LayerNorm ham çıkışı (y) ikinci bölgeye yazılır (artık toplamın ikinci LayerNorm'u için).
Test `tb/tb_ortak_ust.v` (Vivado: `vivado/sim_ortak_ust.bat`): 2 katman, 1 cümle, 82 048 kontrol, 0 hata, 797 912 çevrim. Q/K/V/bağlam/dikkat çıkışı/LayerNorm 1 (iki çıkış)/LayerNorm 2 birebir; ileri besleme 1-2 ara dosyaları zincirleme girdiyle üretilmediğinden LayerNorm 2 ile dolaylı denetlenir.

## Adım 5d-v ve kapanış (12 Kasım 2026)
Çizelgeye pooler (tanh, yalnız ilk token) ve sınıflandırıcı satırları ile karar eklendi (`sinif`, `logit0`, `logit1`, `sonuc_gecerli`). Test `tb/tb_ortak_ust.v` (Vivado: `vivado/sim_ortak_ust_temiz.bat`, günlük `sim/xs_ust/gunluk.txt`): 2 katman, 4 cümle, 328 716 kontrol, 0 hata, her cümle ≈ 817 000 çevrim, dört cümlenin sınıfı doğru. Hatalı akış (tek bit) ilk bozuk blokta yakalanır, çizelge durur.
Vivado (üst modül, 100 MHz): 87 DSP, 25 blok bellek, 4 960 LUT, 6 399 kayıtçık, WNS +0,279 ns. Ayrıntı: `notlar/MIMARI_NOTU_5d_ortak_cekirdek_cizelge.md`.
