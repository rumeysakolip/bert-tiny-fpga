"""TR02 ve TR03 rapor spesifikasyonlarını JSON olarak yazar (sayılar sim/g4_sonuc.json'dan)."""
import json
import os

AY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
g4 = json.load(open(os.path.join(os.path.dirname(AY), "03-RTL", "sim", "g4_sonuc.json"), encoding="utf-8"))["sonuclar"]
bul = {s["ad"]: s for s in g4}
pe = bul["pe 9b x 8b"]["ayrinti"]
nx = [s for s in g4 if "N" in s]

tr02 = {
    "rapor_no": "TR02", "baslik": "PE'nin 9 Bit İşaretli A Girişi",
    "alt_baslik": "pe.v (A_W=9, B_W=8, ACC_W=32): INT8 aktivasyon ve UINT8 Softmax olasılığı tek PE ile",
    "gorev": "G4 — PE'yi parametrik yap", "tarih": "27 Ekim 2026",
    "durum": "UYGULANDI (benzetim, Icarus Verilog). Sentez ve kart yok.",
    "amac": "Dikkat·V çarpımında A işleneni Softmax çıkışıdır (UINT8, 0..255); diğer tüm doğrusal katmanlarda INT8 (−128..127). Tek bir PE tasarımıyla ikisini de taşıyabilmek için A girişinin 9 bit işaretli yapılması kararını, değer aralığı ve birikeç genişliği gerekçesiyle ve doğrulama kanıtıyla kayda geçirmek.",
    "kararlar": [
        ["A girişi", "9 bit işaretli, aralık [−256, 255]", "8 bit + ayrı işaretsiz PE", "INT8 [−128,127] ve UINT8 [0,255] bu aralığa tam sığar; olasılık ölçeği (1/255) değişmez, ikinci PE tasarımı gerekmez."],
        ["B girişi", "8 bit işaretli (ağırlık, V)", "—", "Ağırlıklar ve V değerleri INT8; değişiklik gerekmedi."],
        ["Çarpım", "9b × 8b → 17 bit işaretli", "8b × 8b → 16 bit", "17 bit çarpım DSP48E1 girişlerine (25×18) sığar; DSP sayısı beklentisi değişmez (tahmin, sentez G12)."],
        ["Birikeç", "32 bit işaretli (değişmedi)", "Daraltma", "Hesaplanan en kötü durum K=512'de |acc| ≤ 255·128·512 = 16 711 680 (< 2^24); altın modelde ölçülen en geniş INT8×INT8 birikeci 21 bit."],
    ],
    "literatur": [
        {"konu": "INT8 işlenen, INT32 birikeç (genişlik tasarımı)", "alintilar": ["SW-01"],
         "bizde": "pe.v: acc 32 bit işaretli, a_in 9, b_in 8 bit. En kötü durum birikeci Şekil 3'te hesapla gösterilmiştir: INT8×INT8 için K=512'de 25 bit, UINT8×INT8 için 25 bit, 9 bit alt sınır (−256·−128) için 26 bit gerekir; hepsi 32 bitin altındadır.",
         "fark": "Kaynak yalnızca INT8 girdi/INT32 birikeç düzenini söyler; 9 bit A girişini ele almaz. 32 bit birikeç gereğinden geniştir (en kötü durum 26 bit); sentezde daraltma kaynak kazancı sağlayabilir (açık nokta).",
         "sekil": ["S3"]},
        {"konu": "9 bit işaretli A girişi (UINT8 olasılığın INT8 PE'de taşınması)", "alintilar": [],
         "bizde": "Softmax çıkışı UINT8'dir (0..255). 8 bit işaretli bir A girişi 128..255'i temsil edemez; 9 bit işaretli giriş [−256,255] aralığıyla hem INT8'i hem UINT8'i tam kapsar. Karar, testbench'te üç ayrı vektör sınıfıyla (INT8, UINT8, tam 9 bit) altın tamsayı çarpımıyla doğrulanmıştır (Şekil 2, 4).",
         "fark": "Doğrudan karşılık bulunamadı; mühendislik kararı. 2021 sonrası doğrulanmış bir kaynakta bu özel düzenleme (UINT8 olasılığı 9 bit işaretli PE girişine koymak) bulunamadı; aramaya devam edilecek. Kararın güvencesi, benzetimdeki bit-birebir doğrulamadır; bu doğrulama kartta ya da sentezden sonra yeniden yapılmalıdır.",
         "sekil": ["S2"]},
    ],
    "dogrulama": {"arac": "Icarus Verilog (iverilog -g2001) + numpy altın hesap",
                  "kaynak_dosyalar": ["03-RTL/sim/g4_sonuc.json", "03-RTL/tb/tb_pe.v", "03-RTL/tb/gen_vektor_nxn.py"],
                  "tablo": [["Modül", "Testbench", "Kapsam", "Sonuç"],
                            ["pe.v (9b×8b→32b)", "tb_pe.v", "reset/en/duraklatma; uç değerler (K=512 en kötü); UINT8×INT8; INT8×INT8 (4000); rastgele 9 bit + rastgele en/rst (6000)", "PASS — " + pe],
                            ["Dizi içinde 9 bit A", "tb_systolic_nxn.v", "UINT8, INT8 ve tam 9 bit vektörleri (bkz. TR03)", "PASS — 7 yapılandırmada 0 hata"]],
                  "sekil": ["S4"]},
    "sinirlar": [
        "Tüm sonuçlar benzetimdir; sentez, zamanlama ve kart üzerinde doğrulama yapılmamıştır.",
        "Kararı destekleyen 2021 sonrası bir literatür kaynağı bulunamamıştır; gerekçe mühendislik hesabına ve benzetime dayanır.",
        "UINT8 A girişinin altın modelde karşılığı Dikkat·V çarpımıdır; altın modelde bu çarpım hâlâ float'tır, tamsayı taşıma G2'de ölçülmüştür (718/872).",
        "32 bit birikeç gereğinden geniştir; daraltmanın kaynak etkisi ölçülmemiştir.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr02_s1_pe9.png", "baslik": "Parametrik PE blok şeması.", "aciklama": "a_in (9 bit) ve b_in (8 bit) çarpılır, 32 bitlik acc yazmacında biriktirilir (gri geri besleme); işlenenler yazmaç üzerinden komşu PE'ye akar, kısmi toplam PE içinde kalır.", "genislik_cm": 13},
        "S2": {"dosya": "sekiller/tr02_s2_aralik.png", "baslik": "A girişinin taşıması gereken değer aralıkları.", "aciklama": "Her çubuk bir sayı biçiminin aralığıdır. Yeşil çubuk (9 bit işaretli) hem mavi (INT8) hem turuncu (UINT8) aralığı içerir; gri (8 bit işaretli) UINT8'i taşıyamaz.", "genislik_cm": 13},
        "S3": {"dosya": "sekiller/tr02_s3_birikec.png", "baslik": "K boyunca en kötü durum birikeç genişliği (hesap).", "aciklama": "Her çubuk, verilen K için işlenenlerin en büyük çarpımı K kez toplanırsa gereken bit sayısıdır (işaret dahil). Kırmızı kesikli çizgi 32 bitlik birikeçtir; tüm durumlar çizginin çok altında.", "genislik_cm": 13},
        "S4": {"dosya": "sekiller/tr02_s4_dogrulama.png", "baslik": "tb_pe.v doğrulama sonucu.", "aciklama": "Çubuk, PE testbench'inde yapılan toplam kontrol sayısıdır; tüm kontroller sıfır hatayla geçmiştir (sim/g4_sonuc.json).", "genislik_cm": 10},
    },
    "mimari_sekilleri": ["S1"],
}

onl = {k: v for k, v in zip([(s["N"], s["K"]) for s in nx], nx)}
tr03 = {
    "rapor_no": "TR03", "baslik": "Parametrik 8×8 Çıkış-Sabit Dizi ve Akışlı Arayüz",
    "alt_baslik": "systolic_nxn.v: N parametresi, her çevrimde bir A sütunu / B satırı, K boyunca akıtma",
    "gorev": "G4 — 8×8 akışlı dizi", "tarih": "27 Ekim 2026",
    "durum": "UYGULANDI (N=4 ve N=8, benzetim). Sentez ve kart yok.",
    "amac": "TR01'deki sabit 4×4, tek seferde 128 bitlik düz yazmaçla beslenen diziyi; K=128/512 gibi uzun iç çarpımları destekleyen, N parametreli ve akışlı arayüzlü bir diziye genelleştirme kararlarını ve kanıtını kaydetmek. N=4 çıktısı eski modülle birebir olmalıdır (regresyon).",
    "kararlar": [
        ["Arayüz", "Akışlı: start + k_len; her çevrimde 1 A sütunu + 1 B satırı (in_valid)", "Düz yazmaç (a_flat/b_flat)", "K=512 için düz yazmaç ölçeklenmez; veri BRAM'den her çevrimde bir sözcük olarak gelir."],
        ["Skew", "Kaydırma yazmacı zinciri (A satırı i: i, B sütunu j: j yazmaç)", "Sayaçla pencere seçimi (TR01)", "Akışlı veride tüm girdiyi saklamadan skew yalnızca gecikme yazmaçlarıyla yapılabilir. Maliyet: N=8'de 28·9 + 28·8 = 476 FF (hesap, tahmin; sentezde doğrulanacak)."],
        ["Boşluk toleransı", "Gecersiz çevrimde A ve B'ye birlikte 0 girer", "Dizi dondurma", "Her iki akışa aynı anda sıfır girdiği için PE'lerin gördüğü k hizası bozulmaz; BRAM/host beklemeleri güvenle emilir (testte doğrulandı)."],
        ["Tile süresi", "K + 2N − 2 çevrim", "—", "K besleme + 2N−2 boşaltma; N=4,K=4 eski dizideki 10 çevrimle aynı."],
        ["Bağlantı gösterimi", "Net dizisi (PE arası), paketlenmiş vektör değil", "Paketlenmiş genis vektör", "Icarus'ta paketlenmiş vektör dilimleri N=8'de benzetimi yaklaşık 60 kat yavaşlattı (86 sn → 1,4 sn); davranış aynı, yalnızca benzetim hızı."],
    ],
    "literatur": [
        {"konu": "Çarpıcı-toplayıcı dizisinin uzamsal eşlenmesi", "alintilar": ["KV-03"],
         "bizde": "systolic_nxn.v N×N PE izgarasını generate ile kurar (N=8 → 64 PE, N=4 → 16 PE). Her PE bir çarpıcı-toplayıcıdır ve izgara, iç çarpım K boyunca zaman içinde akıtılarak doldurulur.",
         "fark": "Kaynak 32×32 diziyi HLS ve büyük bir cihazda (KV260) kurar; biz elle yazılmış Verilog ile 8×8'i küçük cihaz (XC7A35T, 90 DSP) hedefiyle kuruyoruz. Dizi boyutu ve frekans doğrudan karşılaştırılamaz. Bizim 16×16 seçeneğimiz kartta DSP sınırı nedeniyle yoktur (64 PE yaklaşık %71, tahmin).",
         "sekil": ["S1"]},
        {"konu": "Yerel tamponlarla döşeme", "alintilar": ["KV-02"],
         "bizde": "Bizim tile 8×8 çıktıdır ve K boyunca akıtılır; A ve B için tile boyutunda yerel tampon tutulmaz: işlenenler her çevrimde BRAM'den bir sözcük olarak gelir ve skew yazmaçlarından geçer (yalnızca 476 FF).",
         "fark": "Kaynaktaki yerel tamponlar 32×32 tile'lar içindir; bizde tampon, G5'te kurulan aktivasyon BRAM'i ve panel tamponudur. Bu rapordaki dizi tampon içermez; bu bir benzerlik değil tasarım farkıdır."},
        {"konu": "Bloklu matris çarpımı", "alintilar": ["SN-01"],
         "bizde": "Y[T×C] = X[T×K]·Wᵀ çarpımı 8 token × 8 kanallık çıktı bloklarına bölünür; her blok bu dizide bir tile'dır (TR04'te sıralama). Dizi, tek bir bloğun K boyunca hesabını yapar.",
         "fark": "Kaynak SwinFPGA'da bloklu çarpımı genel fikir olarak anlatır; blok boyutu ve bellek düzeni bizim kartımıza özgüdür.",
         "sekil": ["S2"]},
        {"konu": "Skew'li besleme", "alintilar": [],
         "bizde": "Skew artık sayaçla seçim değil, kaydırma yazmaçlarıyla yapılır; PE(i,j) girişinde t anında k = t−i−j görülür (Şekil 2). N=8'de son veri t=K+13'te PE(7,7)'ye ulaşır.",
         "fark": "Bu alt başlık için 2021 sonrası doğrulanmış alıntı yok; klasik sistolik dizi tekniğidir (TR01'deki not geçerli).", "sekil": ["S3"]},
    ],
    "dogrulama": {"arac": "Icarus Verilog + numpy altın (INT64 matmul)",
                  "kaynak_dosyalar": ["03-RTL/sim/g4_sonuc.json", "03-RTL/tb/tb_systolic_nxn.v", "03-RTL/tb/tb_regresyon_n4.v"],
                  "tablo": [["Yapılandırma", "Kapsam", "Tile çevrimi (ölçülen / K+2N−2)", "Sonuç"]] +
                           [[f"N={s['N']}, K={s['K']}", "10 uç + 180 rastgele (9 bit/INT8/UINT8) + boşluk/reset/sahte-start senaryoları", f"{s['tile_cevrim_max']} / {s['beklenen_cevrim']}", "PASS — " + s["ayrinti"]] for s in nx] +
                           [["N=4 regresyon", "eski systolic_4x4 ile yeni N=4, 259 eski vektör", "10 / 10", "PASS — " + bul["N=4 regresyon (yeni==eski)"]["ayrinti"]]],
                  "sekil": ["S4", "S5"]},
    "sinirlar": [
        "Tüm sonuçlar benzetimdir; sentez, zamanlama ve kartta çalıştırma yapılmamıştır. FF/DSP sayıları hesaptır (tahmin).",
        "Tile süresi K+2N−2'dir; denetleyicinin ardışık tile'lar arasındaki ek çevrimi TR04'te ölçülmüştür.",
        "c_flat çıkışı 2048 bit düz vektördür; kart üzerinde gölge kayıt ve okuma yolu TR04'te ele alınmıştır.",
        "Benzetim hızı (≈1000 çevrim/sn, N=8) uzun senaryoların kapsamını sınırladı; K=512 için 190 vektör koşuldu.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr03_s1_dizi8.png", "baslik": "systolic_nxn (N=8) blok şeması.", "aciklama": "64 PE; A sütunu soldan her satıra, B satırı yukarıdan her sütuna girer; satır i / sütun j için i / j yazmaçlık skew zinciri (D1…D7) gecikme ekler. Yeşil kutu kontrol FSM'idir.", "genislik_cm": 13},
        "S2": {"dosya": "sekiller/tr03_s2_skew8.png", "baslik": "N=8 skew çizelgesi (kodla hesaplandı).", "aciklama": "Her satır bir PE, her sütun bir çevrimdir; renk, PE'nin o çevrimde gördüğü k = t−i−j değeridir (boş = veri yok). Çapraz dalga, A[i][k] ile B[k][j]'nin aynı çevrimde buluştuğunu gösterir.", "genislik_cm": 13},
        "S3": {"dosya": "sekiller/tr03_s3_dalga.png", "baslik": "N=8, K=64 ilk tile dalga formu (VCD).", "aciklama": "start darbesinden sonra in_valid 64 çevrim yüksektir ve kcnt 0'dan 64'e sayar; busy 78 çevrim sürer (K+2N−2); done yükseldiğinde c_flat geçerlidir.", "genislik_cm": 14},
        "S4": {"dosya": "sekiller/tr03_s4_cevrim.png", "baslik": "Tile süresi: benzetim ölçümü ve formül.", "aciklama": "Çizgi K+2N−2 formülüdür, boş işaretler testbench'in ölçtüğü en büyük tile süresidir; tüm noktalar çizgi üzerindedir.", "genislik_cm": 12},
        "S5": {"dosya": "sekiller/tr03_s5_dogrulama.png", "baslik": "Yapılandırma başına kontrol sayısı.", "aciklama": "Her çubuk bir (N,K) yapılandırmasının testbench kontrol sayısıdır; hepsi 0 hatayla geçti.", "genislik_cm": 12},
    },
    "mimari_sekilleri": ["S1"],
}

for ad, sp in (("TR02_pe_9bit_a_girisi", tr02), ("TR03_parametrik_dizi_8x8", tr03)):
    yol = os.path.join(AY, "tasarim_raporlari", ad + ".json")
    json.dump(sp, open(yol, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print("yazıldı:", yol)
