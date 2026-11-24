# Görev listesi — kalan işler (kararlara göre parçalanmış)

Güncelleme: 6 Kasım 2026. Karar kaynağı: `raporlar/ara_rapor/Tasarim_Kararlari_Arastirma_Raporu.docx`. Her görevden önce kısa mimari notu (`notlar/`), her görevin sonunda bit-birebir test + Vivado + README satırı.
Durum: [x] tamam · [ ] bekliyor · (K) = kesilebilir.

## Tamamlananlar
- [x] P1 Akış ayrıştırıcı + 16 bit CRC + çizelge sıralayıcı; katman 0 Q, K, V komutsuz, altın modelle bit-birebir (4 cümle, 98 304 kontrol), hata enjeksiyonu
- [x] P2 Vivado sentez + yerleştirme (100 MHz): +1,72 ns
- [x] P3 Flaş okuyucu (dört hatlı) + flaş modeli; 25 ve 50 MHz SCK; bit-birebir; Vivado +2,28 ns

## Sıradaki: P4 — Q·Kᵀ → Softmax çip içi zincir (Karar 7; ara rapordan önce hedef)
- [ ] P4.1 Mimari notu: skorun yolu (dizi çıkışı 32 bit → yeniden ölçekleme → 12 bit skor → Softmax girişi), ikinci operandın (Kᵀ) ağırlık kaynağı seçiciyle aktivasyon belleğinden okunması, maske, satır düzeni; DSP bütçesi hesabı (şu an 68 + Softmax 3 + LayerNorm 6)
- [ ] P4.2 `softmax_birim.v` arabirimini ve veri biçimini çıkar (giriş genişliği, satır uzunluğu 64, tablo yazma yolu); mevcut `tb_softmax` / `tb_dikkat_qk` nasıl besliyor
- [ ] P4.3 Softmax üstel tablosunu bitstream'e gömülü blok belleğe al (başlangıç değerli ROM; yazma yolu kalkar) — Karar 3 ve Karar 7'nin ortak parçası; altın modelle yeniden doğrula
- [ ] P4.4 Q·Kᵀ'yi çizelgeye ekle: Q ve K katman çıkışlarının aktivasyon belleğinde tutulması (çıkış belleğinden aktivasyon belleğine çip içi kopya) ve K devriği okuma sırası
- [ ] P4.5 Köprü: Q·Kᵀ birikeçi → yeniden ölçekleme (12 bit) → Softmax satır girişi; satır sonu işareti
- [ ] P4.6 Test: `l0_qk` skorları ve `l0_softmax` çıkışı altın model dosyalarıyla bit-birebir
- [ ] P4.7 Vivado: DSP ≤ 90, zamanlama payı pozitif
- [ ] P4.8 (K) Bölücü paylaşımı (Softmax 171 çevrim/satır): altın modelle eşitlik korunarak
- [ ] P4.9 (K) P·V zinciri ve Softmax çıkışının P·V'ye çip içi verilmesi (Karar 7'ye göre koşullu; sınıra takılırsa arayüz Softmax çıkışında bilgisayara devredilir)

## Karar 3 — küçük parametrelerin bitstream'e gömülmesi
- [ ] K3.1 Mimari notu: bias, M0, kaydırma ve LayerNorm katsayıları için başlangıç değerli bellek; çizelge adım numarasıyla adreslenir
- [ ] K3.2 Akıştan bias/M0'ı çıkar: panel bloğu 1 088 → 1 024 bayt + CRC; ayrıştırıcı ve `akis_uret.py` güncellemesi
- [ ] K3.3 GELU ve tanh tablolarının gömülü yüklenmesi (`gelu_yaz_*` yolu kalkar)
- [ ] K3.4 Test + Vivado (blok bellek artışı ≈ 5–6 tahmin)

## Karar 5 — tam çizelge (14 doğrusal katman)
- [ ] C1 Çıkış belleğinden aktivasyon belleğine çip içi aktarım (katmanlar arası, ping-pong) — P4.4 ile ortak
- [ ] C2 Çizelge tablosunu 14 satıra çıkar (K, panel sayısı, kaydırma, GELU/tanh bayrağı, kaynak/hedef bellek adresleri)
- [ ] C3 Artık toplama ve LayerNorm'un çizelgeye alınması (şu an bilgisayarda)
- [ ] C4 Pooler ve classifier (yalnız ilk token, 7 satır sıfır dolgu, 2 çıkış kanalı 8'e tamamlanır)
- [ ] C5 Test: 14 katman bit-birebir (kod: R2'nin yeni mimaride karşılığı), ≥16 cümle (R3)

## Karar 6 — dolgu atlama (kararlı olduktan sonra)
- [ ] D1 Cümlenin gerçek blok sayısını veri olarak almak; çizelge ve tile denetleyicide blok sayısı (`ayar_blok_sayisi` zaten var)
- [ ] D2 Akış ve hesap kısalması ölçümü (ortalama 3,6 / 8 blok)

## Karar 1–2 — kart ve giriş yolu
- [ ] F1 Cümle girişi için seri hat alıcı (3 Mbaud, ACK'siz) ve `bayt_hazir` bağlama
- [ ] F2 Kart sarmalayıcısı: flaş saat ucu için STARTUPE2, çift yönlü pin tamponları, `basys3.xdc` (flaş + seri pinleri)
- [ ] F3 Ağırlıkları bitstream'den sonra flaşa yazma yöntemi (Vivado bellek dosyası, ek veri adresi)
- [ ] F4 Kart bring-up (kart gelince): seri hat → flaş okuma → tam tasarım

## Raporlar
- [ ] R-A Model raporu (Rapor A): işlem çizelgesi, bellek, işlem yükü, veri özellikleri (mevcut `BERT_Tiny_Model_Diyagrami_Raporu.docx` temel)
- [ ] R-B Hızlandırıcı mimari planı (Rapor B): veri sözleşmesi, bellek planı, çizelge, birimler; prototip sonuçlarıyla
- [x] R-C Ara rapor: `raporlar/ara_rapor/Ara_Rapor_BIL401.docx` + `.pdf` (37 sayfa, 12 kaynak; üretici `uret_rapor.py`, şekiller `uret_sekiller.py`, alan güncelleme `guncelle_word.ps1`)

## Önerilen sıra
1. P4.1 → P4.2 → P4.3 (tablo BRAM; küçük, bağımsız, kazanç net) → P4.4 → P4.5 → P4.6 → P4.7  (6–8 Kasım)
2. K3.1–K3.4 (zaman kalırsa, 8 Kasım)
3. R-A, R-B, R-C (9–11 Kasım; vize haftasında RTL'e dokunulmaz)
4. C ve D, F ara rapordan sonra

## Güncelleme 11 Kasım 2026 — sıra (kullanıcı kararı)
Sıra: (1) RTL kararlarını raporla → (2) RTL'de gerçekle, Vivado'da gözlemlenebilir (parametresiz test, anlamlı günlük) → (3) model tasarımı bitince ara raporu kurallara göre yaz.
- [x] RTL kararları raporu: `raporlar/rtl_kararlari/RTL_Tasarim_Kararlari.docx`
- [x] Adım 1a: Softmax üstel tablosu gömülü (`rtl/softmax_birim_gomulu.v`, `tb/tb_softmax_gomulu.v`, `vivado/sim_softmax_gomulu.bat`): Vivado xsim 325 satır, 20 800 kontrol, 0 hata. Tablolar iki katmanda aynı (tek ROM).
- [x] Adım 1b: sapma/M0/GELU tablosu gömülü: 12 doğrusal katman 147 456 kontrol 0 hata, 431 256 çevrim, Vivado xsim BAŞARILI; Vivado 24,5 blok bellek, WNS +1,93 ns (tanh/pooler tek-token düzeninde ayrı, Adım 5'te)
- [x] Adım 2: dikkat zinciri çalışıyor (16 iş, 131 072 kontrol, 0 hata; Vivado xsim BAŞARILI; 75 DSP, WNS +2,05 ns). Softmax baş başına 16 000 çevrim (satır başına ~250; iyileştirme: satır girişi ile hesabı örtüştür) — sonra
- [x] Adım 3: akışa cümle uzunluğu baytı eklendi (giriş bloğu 1+8192+2 = 8 195 bayt, cümle akışı 60 515 bayt); ayrıştırıcı uzunluğu CRC doğrulanınca `cumle_uzunluk` çıkışına verir. Regresyon (4 cümle 98 304 kontrol), flaş (25/50 MHz) ve hatalı akış testleri yeniden PASS; `vivado/sim_komutsuz_akis.bat` xsim PASS. Sıradaki: dikkat çekirdeğinin `uzunluk` girişini bu çıkışa bağlamak Adım 4–5'te (tam çizelge).
- [x] Adım 4: 48 KB altı birimli aktivasyon belleği + adres tabanları: Q/K/V ve ileri besleme 1→2 kopyasız zincir, 65 536 kontrol 0 hata, Vivado xsim BAŞARILI; 20 blok bellek, WNS +1,13 ns (not: altın model tek-katman vektörlerinde ffn2 girdisi ≠ ffn1 GELU çıkışı ölçeği; zincir beklenen çıkışı Python'da hesaplandı). Dikkat çekirdeği henüz birleşik belleğe bağlanmadı (Adım 5).
- [x] Adım 5a: V devrik (panel düzeni) yazım — birleşik bellek Senaryo C PASS
- [x] Adım 5b: P·V (dikkat çekirdeği mod 1): olasılıklar çip içinde üretilip kullanıldı, bağlam altın modelle birebir (32 768 kontrol), Vivado xsim PASS, 75 DSP
- [x] Adım 5c: artık toplama + LayerNorm + sonraki girdi yeniden ölçeklemesi: 4 LayerNorm × 4 cümle 98 816 kontrol 0 hata (altın model tam tamsayı hattı), Vivado xsim PASS; blok 16 DSP, WNS +2,82
- [x] Adım 5d: ortak çekirdek + sabit çizelge (katman başına 14 satır, pooler ve sınıflandırıcı dahil) + akıştan uçtan uca: 2 katman, 4 cümle, 328 716 kontrol 0 hata, dört cümle sınıfı altın modelle aynı; Vivado xsim PASS; sentez 87 DSP, 25 blok bellek, WNS +0,279 ns. Hatalı akış (tek bit) ilk bozuk blokta yakalanır. Dolgu atlama/Softmax hızlandırma gereksiz (darboğaz ağırlık akışı); notlar/MIMARI_NOTU_5d_ortak_cekirdek_cizelge.md
- [ ] Rapor B güncellemesi: cümle uzunluğu baytı (giriş 8 193 + 2), tek exp tablosu

## 12 Kasım 2026 — Adım 2 için düzeltme (altın model kontrolü)
- Softmax'a girişin ham 32 bit birikeç olduğu varsayımı YANLIŞTI (RTL kararları raporu düzeltildi). Altın model: skor_q = (birikeç·M0 + 2^(n−1)) >> n; M0 = 779 983 511 (katman 0), 977 102 689 (katman 1), n = 34; skor_q aralığı [−974, 1 443] (12 bit); Softmax M0: 16 601 / 22 777. Bu hesap Python'da yeniden üretildi, `olasilik_u8` ile birebir (maske dahil).
- Adım 2 yapılacaklar: (a) yeniden ölçekleme birimine genişletilmiş kırpma (aynı çarpan, ek çarpma bloğu yok; 03-RTL'e dokunmadan 04'te kopya), (b) panel kopyalayıcı, (c) skor tamponu, (d) Softmax besleyici + maske, (e) olasılık toplayıcı, (f) test: skor_q ve olasılık altın model dosyalarıyla; vektörleri `scripts/uret_dikkat_vektor.py` üretecek.
- Bütçe notu: Softmax 7 + LayerNorm 12 çarpma bloğu eklenince toplam 68+19 = 87 ≤ 90; ikinci bir 4 DSP'lik yeniden ölçekleme 91 yapardı — bu yüzden birim paylaşılacak.
- Bellek tasarrufu (Adım 1b sonrası): tek 46 bit ROM + GELU dağıtık bellek: 24,5 → 23 blok bellek. Asıl kazanç Adım 4'te (64 KB'lık iki bellek yerine 48 KB'lık tek bellek).
