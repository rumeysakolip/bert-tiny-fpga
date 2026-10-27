"""TR10 (Softmax) ve TR11 (LayerNorm) rapor spesifikasyonlari. Sayilar sim/g11_*.json, birim_taramasi.csv, sentez ciktilarindan okunur."""
import csv
import json
import os

AY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJE = os.path.dirname(AY)
SIM = os.path.join(PROJE, "03-RTL", "sim")
g = json.load(open(os.path.join(SIM, "g11_sonuc.json"), encoding="utf-8"))
ist = json.load(open(os.path.join(SIM, "g11_istatistik.json"), encoding="utf-8"))
sm, ln = g["birim"]["softmax"], g["birim"]["layernorm"]
sz = ist["sentez"]
smz, lnz = sz["softmax_birim"], sz["layernorm_birim"]
tarama = {r["yapilandirma"]: r for r in csv.DictReader(open(os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar", "birim_taramasi.csv"), encoding="utf-8"))}
k_sm, k_ln, k_a = tarama["+ tamsayı softmax"], tarama["+ tamsayı LayerNorm"], tarama["A (taban)"]


def mut_tablo(birim):
    return [[m["ad"], m["tanim"], f"{m['hata']} hata" if m["yakalandi"] else "0 hata", "yakalandı" if m["yakalandi"] else "eşdeğer (aşağıda)"]
            for m in g["mutant"] if m["birim"] == birim]


# ------------------------------------------------------------------ TR10
tr10 = {
    "rapor_no": "TR10", "baslik": "Softmax Birimi (Tamsayı, LUT'lu, Ardışık Bölücülü)",
    "alt_baslik": "softmax_birim.v + bolucu_seri.v: satır maksimumu, exp LUT'u, toplam, tamsayı bölme (bağımsız modül, sistem entegrasyonu yok)",
    "gorev": "G11 — Softmax RTL", "tarih": "27 Ekim 2026",
    "durum": f"UYGULANDI (benzetim, bağımsız birim). {sm['satir']} satırda altın softmax_tam ile bit-birebir, {sm['hata']} hata. Üst modüle BAĞLANMADI: Softmax şu an host'ta kalır.",
    "amac": "Softmax'ın FPGA'ya taşınabileceğini, altın modelin tamsayı softmax_tam davranışını bit düzeyinde yeniden üreten bir RTL birimiyle göstermek; kaynak ve çevrim maliyetini ölçmek.",
    "kararlar": [
        ["Algoritma", "Satır max → LUT exp → toplam → bölme (üç geçiş)", "Shiftmax / taban-2 yaklaşıklığı", "Altın modelle bit-birebir doğrulanabilir; altın model bu algoritmayı zaten ölçmüştü."],
        ["exp", "512 girişli, 16 bit LUT (host yükler), adım 8/512", "Polinom / CORDIC", f"LUT dağıtık RAM'e oturur ({int(smz['LUT'])} LUT'un içinde); skor ölçeğinden bağımsız çözünürlük."],
        ["LUT indisi", "fark·M0 >> 16, 511'e doyurma (M0 ≤ 24 bit)", "Bölme ile indis", "Tek çarpma + kaydırma; M0 skor ölçeğinden host'ta hesaplanır."],
        ["Bölme", "255·e + toplam/2 bölü toplam, 1 bit/çevrim restoring (24 bit)", "Ters çevirip çarpma", f"Altın modelle aynı sonucu verir (yuvarlama dahil); maliyet: eleman başına 28 çevrim ({sm['faz_cevrimleri']['6']} çevrim bölme)."],
        ["Maske", "Maskeli eleman max'a girmez, e=0", "Büyük negatif skor", "Altın model −2^40 koyar; sonuç aynıdır, RTL'de karşılaştırıcı genişliği artmaz."],
        ["Boru hattı", "FARK→IDX→EXP→ACC her eleman 4 çevrim, tek çarpıcı", "Tam boru hattı", f"Kritik yolu 100 MHz altında tutar (sentezde WNS {smz['WNS']} ns); hız bu bağlamda öncelik değildir (bkz. sınırlar)."],
    ],
    "literatur": [
        {"konu": "Bölücü Softmax biriminin en pahalı parçasıdır", "alintilar": ["SW-04", "IO-04"],
         "bizde": f"Bölme tek bir restoring bölücüdür ve satır başına çevrimin büyük kısmını yer ({sm['faz_cevrimleri']['6']} / {sm['cevrim_maks']} çevrim). Kaynak kullanımı ise küçüktür: {int(smz['LUT'])} LUT, {int(smz['FF'])} FF, {int(smz['DSP'])} DSP.",
         "fark": "Kaynaklar bölücünün kaynak maliyetini vurgular; bizde bölücü kaynak değil çevrim yer. Bu, 1 bit/çevrim seçiminin doğrudan sonucudur; paralel/çok bit/çevrim bölücü denenmedi.",
         "sekil": ["S2"]},
        {"konu": "exp için arama tablosu", "alintilar": ["IO-03"],
         "bizde": "512 girişli LUT, dağıtık RAM. Altın modelin skor/olasılık sonuçları bu tabloyla alındı.",
         "fark": f"Kaynak tüm girdiler için LUT'u anlatır; bizde indis, fark·M0 ile 512 girişe kırpılır ve 8 üstü farkta doyar. Yaklaşıklık hatası ölçüldü: en çok {ist['sm_hata_maks_lsb']:.2f} LSB (1/255), ortalama {ist['sm_hata_ort_lsb']:.3f} LSB ({ist['sm_eleman']} eleman).",
         "sekil": ["S3"]},
        {"konu": "Bölme dışında aritmetiğin kaydırma ve toplamaya indirilmesi", "alintilar": ["IV-02"],
         "bizde": "Bizde çarpma (fark·M0) vardır ve DSP48E1'e eşlendi; bölme ayrıca ardışıktır.",
         "fark": "Shiftmax çarpmayı kaydırmaya çevirir; biz bunu denemedik, çünkü altın model bu ölçekle zaten doğrulanmıştı ve DSP kaynağı kısıtlayıcı değil. Mühendislik kararıdır.",
         "sekil": ["S1"]},
    ],
    "dogrulama": {
        "arac": "Icarus Verilog (tb_softmax.v) ve Vivado 2025.1 synth_design (g11_sentez.tcl)",
        "kaynak_dosyalar": ["03-RTL/sim/g11_sonuc.json", "03-RTL/tb/vektor_g11/", "03-RTL/sentez/cikti/softmax_birim_kullanim.txt"],
        "tablo": [["Ölçü", "Değer"],
                  ["Test satırı", f"{sm['satir']} (gerçek cümlelerden 320 + 5 sentetik uç durum)"],
                  ["Eleman kontrolü / hata", f"{sm['kontrol']} / {sm['hata']}"],
                  ["Hesap çevrimi (L=64)", f"{sm['cevrim_maks']} (sabit; veriye bağlı değil)"],
                  ["Yaklaşıklık hatası (FP64'e karşı)", f"en çok {ist['sm_hata_maks_lsb']:.2f} LSB, ortalama {ist['sm_hata_ort_lsb']:.3f} LSB"],
                  ["Sentez (yalnız bu birim)", f"{int(smz['LUT'])} LUT, {int(smz['FF'])} FF, {int(smz['DSP'])} DSP, 0 BRAM, WNS {smz['WNS']} ns @100 MHz"],
                  ["Altın model, tek başına tamsayı softmax", f"{k_sm['dogru']}/872 (taban A: {k_a['dogru']}/872); fark gürültü düzeyinde"]],
        "sekil": ["S4", "S5"],
    },
    "sinirlar": [
        "Birim sistem içine BAĞLANMADI. Skorların FPGA→host→FPGA gidiş-gelişi şu an host'ta yapılıyor; bu raporun sonucu 'RTL bit-birebir' demektir, 'uçtan uca hızlandı' demek değildir.",
        f"Eleman başına 28 çevrim (bölme 24) nedeniyle bir satır {sm['cevrim_maks']} çevrim; 100 MHz'de yaklaşık {sm['cevrim_maks'] * 10 / 1000:.1f} µs. Tek birim kullanıldığı için bir cümlenin 2 katman × 2 baş × 64 satırı sıralı işlenirse ≈{sm['cevrim_maks'] * 256 * 10 / 1e6:.1f} ms olur (hesap, ölçülmedi).",
        "Altın modelin yaklaşıklığı değişmedi; RTL yalnızca onu yeniden üretir. Doğruluk etkisi için tek başına tamsayı softmax açıkken altın modelde 872 cümlede " + f"{k_sm['dogru']} doğru (taban {k_a['dogru']}); bu fark gürültü düzeyindedir.",
        "Sentez sonrası zamanlama yerleştirme/yönlendirme öncesi kaba tahmindir; kartta denenmedi.",
        "Mutant denetiminde iki mutant testi geçti: sm2 (LUT'un 510. ve 511. girişleri aynı değer, 0x0B) ve ln3'ün (TR11) eşdeğer olduğu kanıtlandı. Bunlar testin zayıflığı değil, mutantın davranış değiştirmemesidir.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr10_s1_fsm.png", "baslik": "Softmax durum makinesi.", "aciklama": "Üç geçiş: giriş ve maksimum, eleman başına FARK-IDX-EXP-ACC (4 çevrim), eleman başına NUM-DIV-OUT. Kırmızı oklar eleman döngüsüdür.", "genislik_cm": 15},
        "S2": {"dosya": "sekiller/tr10_s2_faz.png", "baslik": "Bir satırın faz başına çevrim dökümü.", "aciklama": "Değerler benzetimde, ilk test satırında durum sayaçlarından ölçüldü. Bölme (DIV) satırın büyük kısmıdır.", "genislik_cm": 15},
        "S3": {"dosya": "sekiller/tr10_s3_hata.png", "baslik": "Yaklaşıklık hatası.", "aciklama": f"RTL çıkışı ile FP64 softmax farkı, 1/255 birimiyle ({ist['sm_eleman']} gerçek eleman, kayıt ölçeği M0'dan geri kurulmuştur). Kesikli çizgi 8 bit yuvarlamanın 0,5 LSB tabanıdır.", "genislik_cm": 13},
        "S4": {"dosya": "sekiller/tr10_s4_dalga.png", "baslik": "Dalga formu (Icarus VCD).", "aciklama": "Üstte tüm satır, ortada geçiş 2'nin dört durumlu elemanları, altta geçiş 3'te bölücünün 24 çevrimi.", "genislik_cm": 15},
        "S5": {"dosya": "sekiller/tr10_s5_dogrulama.png", "baslik": "Doğrulama sonucu ve mutant denetimi.", "aciklama": "Solda satır/kontrol/hata sayıları, sağda kasıtlı bozulmuş (mutant) RTL'de testin yakaladığı hata sayısı.", "genislik_cm": 15},
    },
    "mimari_sekilleri": ["S1"],
}

# ------------------------------------------------------------------ TR11
tr11 = {
    "rapor_no": "TR11", "baslik": "LayerNorm Birimi (Tamsayı Karekök ve Bölme)",
    "alt_baslik": "layernorm_birim.v + bolucu_seri.v: ortalama, varyans, bit-bit karekök, eleman başına bölme ve γ/β ölçekleme (bağımsız modül)",
    "gorev": "G11 — LayerNorm RTL", "tarih": "27 Ekim 2026",
    "durum": f"UYGULANDI (benzetim, bağımsız birim). {ln['satir']} satırda altın katman_norm_tam ile bit-birebir, {ln['hata']} hata. Üst modüle BAĞLANMADI: LayerNorm şu an host'ta kalır.",
    "amac": "Tamsayı LayerNorm'un (ortalama, varyans, karekök, bölme, γ/β) altın modelle bit düzeyinde uyuşan bir RTL birimini kurmak; kaynak, çevrim ve zamanlama maliyetini ölçmek.",
    "kararlar": [
        ["Karekök", "Bit-bit (digit-by-digit) tamsayı karekök, 20 çevrim", "Newton (plan: 4 yineleme)", "Newton için bölücü gerekir. Altın modelin Newton'u tam taban karekökü verir (2000 rastgele değerde math.isqrt ile eşit); bit-bit karekök aynı sonucu bölücüsüz verir. Plandan SAPMA: 4 Newton yinelemesi yerine 20 çevrimlik bit-bit karekök."],
        ["Bölme", "d·2^12 + std/2 bölü std, 1 bit/çevrim restoring, taban (floor) düzeltmesiyle", "Ters std ile çarpma", f"Altın model floor bölme yapar; negatif paylarda −ceil düzeltmesi gerekir (mutant ln1 bunu {g['mutant'][2]['hata']} hata ile yakalıyor)."],
        ["Ölçekleme", "y·γ_q (16 bit), ·M0 (31 bit), (+2^(n−1))>>n, +β_q, [−128,127] kırp", "Tek geniş çarpma", f"İki kayıtlı çarpma ve ayrı kaydırma durumu (SH): ilk sentezde WNS −2,88 ns idi, aşama eklenince {lnz['WNS']} ns oldu."],
        ["Veri yolu genişliği", "Girdi 18 bit işaretli; |y| ≤ √128·2^12 ≈ 46 341 (17 bit)", "32 bit", "q ± 2^17 içinde varsayılır; sentetik testte 2^15 ve gerçek verilerde bu sınırın çok altında. |y| sınırı matematikseldir (|d| ≤ √N·std)."],
        ["Karesel toplam", "3 aşamalı boru hattı (d, d², Σ), 45 bit biriktirici", "Tek çevrimde", "Tek çevrimlik sürümde WNS −2,76 ns (ölçüldü); boru hattıyla pozitif."],
        ["γ, β depoları", "Host'tan par_we ile yüklenir, dağıtık RAM", "ROM", "Her LayerNorm örneğinin (ln1, ln2, gömme) γ/β ve ölçekleri farklıdır."],
    ],
    "literatur": [
        {"konu": "Karekök yinelemeli ve çok çevrimlidir", "alintilar": ["SW-05"],
         "bizde": f"Karekök 20 çevrim; satırın toplam {ln['cevrim_maks']} çevriminin küçük bir kısmıdır (bölme daha pahalı: {ln['faz_cevrimleri']['8']} çevrim).",
         "fark": "Kaynak yinelemeli (Newton benzeri) karekökü anlatır. Biz bit-bit karekök kullandık; yineleme sayısı sabit (20) ve bölücü gerektirmez. Newton ile aynı değeri verdiği 2000 rastgele değerde ölçüldü.",
         "sekil": ["S2"]},
        {"konu": "Bölmesiz yinelemeli tamsayı LayerNorm", "alintilar": ["IV-03", "QK-01"],
         "bizde": "Bizde bölme vardır (eleman başına 32 çevrim), bölmesiz tasarım denenmedi. Kritik yol bölmeden değil çarpım sonrası kaydırma/toplamadan geliyordu ve boru hattıyla çözüldü.",
         "fark": "QUARK bölmeden kaçınır; bölme bizde en çok çevrimi yer (" + f"{ln['faz_cevrimleri']['8']} / {ln['cevrim_maks']}). Bölmesiz karekök-ters yöntemi bu çalışmada denenmedi; altın modelle bit-birebir uyum bu bölmeli sürümle sağlandı. Mühendislik kararı: önce altın modeli yeniden üret, sonra optimize et.",
         "sekil": ["S2", "S3"]},
        {"konu": "Sabit nokta yaklaşıklığı ve doğruluk", "alintilar": [],
         "bizde": f"RTL çıkışı FP64 LayerNorm'dan en çok {ist['ln_hata_maks_lsb']:.2f} LSB, ortalama {ist['ln_hata_ort_lsb']:.3f} LSB uzak ({ist['ln_eleman']} eleman). Altın modelde tek başına tamsayı LayerNorm {k_ln['dogru']}/872 (taban {k_a['dogru']}/872): gürültü düzeyi.",
         "fark": "doğrudan karşılık bulunamadı; mühendislik kararı (12 bit giriş genişliği altın modelin ölçümünden: ln_bit = 12).",
         "sekil": ["S3"]},
    ],
    "dogrulama": {
        "arac": "Icarus Verilog (tb_layernorm.v) ve Vivado 2025.1 synth_design (g11_sentez.tcl)",
        "kaynak_dosyalar": ["03-RTL/sim/g11_sonuc.json", "03-RTL/tb/vektor_g11/", "03-RTL/sentez/cikti/layernorm_birim_kullanim.txt"],
        "tablo": [["Ölçü", "Değer"],
                  ["Test satırı", f"{ln['satir']} (gerçek cümlelerden 480, 5 LayerNorm örneği; + 5 sentetik uç durum)"],
                  ["Eleman kontrolü / hata", f"{ln['kontrol']} / {ln['hata']}"],
                  ["Hesap çevrimi (N=128)", f"{ln['cevrim_maks']} (sabit)"],
                  ["Yaklaşıklık hatası (FP64'e karşı)", f"en çok {ist['ln_hata_maks_lsb']:.2f} LSB, ortalama {ist['ln_hata_ort_lsb']:.3f} LSB"],
                  ["Karekök kesme hatası", f"en çok {ist['isqrt_hata_maks']:.3f} < 1 (floor)"],
                  ["Sentez (yalnız bu birim)", f"{int(lnz['LUT'])} LUT, {int(lnz['FF'])} FF, {int(lnz['DSP'])} DSP, 0 BRAM, WNS {lnz['WNS']} ns @100 MHz"]],
        "sekil": ["S4", "S5"],
    },
    "sinirlar": [
        "Birim sistem içine BAĞLANMADI; LayerNorm host'ta kalır (bu raporun sonucu 'RTL bit-birebir'dir, uçtan uca hızlanma değildir).",
        f"Satır başına {ln['cevrim_maks']} çevrim (100 MHz'de ≈{ln['cevrim_maks'] * 10 / 1000:.0f} µs). Bir cümlede 64 token × 2 LayerNorm × 2 katman = 256 satır tek birimde ≈{ln['cevrim_maks'] * 256 * 10 / 1e6:.1f} ms (hesap, ölçülmedi). Paralel birim kullanılmadı.",
        "Veri yolu genişliği (18 bit girdi) altın modelin ölçtüğü aralığa dayanır; daha geniş girdide Q_W parametresi büyütülmelidir (sentezde etkisi ölçülmedi).",
        "12 vs 16 bit LayerNorm kararı (plan G12) için bu birimin sentez verisi hazırdır (Q_W parametresi), ancak 16 bit sürüm sentezlenmedi.",
        "Mutant ln3 (std ≥ 1 kırpması) eşdeğerdir: eps_q ≥ 1 olduğundan karekök 0 olamaz; savunma amaçlı bir koşuldur.",
        "Sentez sonrası zamanlama kaba tahmindir; kartta denenmedi. Raporda geçen ara sentez değerleri (−2,88 ve −2,76 ns) tasarım iyileştirme sırasında konsolda okundu; ara çıktı dosyaları saklanmadı, yalnızca son sürümün raporları depoda.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr11_s1_fsm.png", "baslik": "LayerNorm durum makinesi.", "aciklama": "Üst satır satır istatistiklerini (ort, varyans, std), alt satır eleman başına bölme ve ölçeklemeyi gösterir; kırmızı ok eleman döngüsüdür.", "genislik_cm": 15},
        "S2": {"dosya": "sekiller/tr11_s2_faz.png", "baslik": "Bir satırın faz başına çevrim dökümü.", "aciklama": "Benzetimde ilk test satırında durum sayaçlarından ölçüldü. Eleman başına bölme (DIV) baskındır.", "genislik_cm": 15},
        "S3": {"dosya": "sekiller/tr11_s3_hata.png", "baslik": "Yaklaşıklık hataları.", "aciklama": "Solda RTL çıkışının FP64 LayerNorm'dan farkı (INT8 LSB), sağda bit-bit karekökün gerçek karekökten kesme farkı.", "genislik_cm": 15},
        "S4": {"dosya": "sekiller/tr11_s4_dalga.png", "baslik": "Dalga formu (Icarus VCD).", "aciklama": "Üstte tüm satır, ortada karekök (ilk bitlerde op<res+one olduğundan yalnızca res ve one kayar), altta bir elemanın bölme-ölçekleme yolu.", "genislik_cm": 15},
        "S5": {"dosya": "sekiller/tr11_s5_dogrulama.png", "baslik": "Doğrulama sonucu ve mutant denetimi.", "aciklama": "Solda satır/kontrol/hata, sağda kasıtlı bozulmuş RTL'de testin yakaladığı hata sayısı.", "genislik_cm": 15},
    },
    "mimari_sekilleri": ["S1"],
}

for ad, sp in (("TR10_softmax", tr10), ("TR11_layernorm", tr11)):
    yol = os.path.join(AY, "tasarim_raporlari", ad + ".json")
    json.dump(sp, open(yol, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print("yazıldı:", yol)
