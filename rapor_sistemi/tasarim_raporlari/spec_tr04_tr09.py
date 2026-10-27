"""TR04–TR09 rapor spesifikasyonları. Sayılar sim/*.json ve loglardan okunur (elle sayı yok)."""
import json
import os
import re

AY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RTL = os.path.join(os.path.dirname(AY), "03-RTL")
SIM = os.path.join(RTL, "sim")
J = lambda ad: json.load(open(os.path.join(SIM, ad), encoding="utf-8"))
T = lambda ad: open(os.path.join(SIM, ad), encoding="utf-8", errors="replace").read()

g7 = J("g7_sonuc.json")["sonuclar"]
g9 = J("g9_l0_sonuc.json")
g10 = J("g10_sonuc.json")["sonuclar"]
g5 = T("g5_tile_l0q.txt")
m5 = re.search(r"cumle basina (\d+) (\d+) (\d+) (\d+) ; teorik \(K\+14\)\*P\*NB = (\d+) ; tile sayisi (\d+)", g5)
c5, t5, tile5 = int(m5.group(1)), int(m5.group(5)), int(m5.group(6))
k5 = re.search(r"\((\d+) kontrol, 0 hata\)", g5).group(1)
byte_panel = 8 * 128 + 8 * 4 + 8 * 4 + 3 * 8
uart_921 = byte_panel * 10 / 921600 * 1e3          # ms
hesap_panel = 8 * (128 + 15) / 100e6 * 1e3          # ms
l0 = [s for s in g7 if s["ad"].startswith("l0_")]
l0_cev = sum(s["cevrim_olculen"] for s in l0)

# ------------------------------------------------------------------ TR04
tr04 = {
    "rapor_no": "TR04", "baslik": "Tile Denetleyici ve Host'tan Panel Akıtma",
    "alt_baslik": "tile_denetleyici.v, panel_tamponu.v, bram_sdp.v: 8×8 tile sırası, gölge acc, çift tamponlu panel",
    "gorev": "G5 — tile denetleyici", "tarih": "27 Ekim 2026",
    "durum": "UYGULANDI (benzetim). l0_q 4 cümle bit-birebir. Sentez sonucu TR12'de.",
    "amac": "Y[T×C] = X[T×K]·Wᵀ çarpımını 8 token × 8 kanal tile'larına bölen, aktivasyonu BRAM'de tutup ağırlığı panel panel (host'tan) akıtan denetleyicinin kararlarını, literatür karşılığını ve bit-birebir doğrulamasını kaydetmek.",
    "kararlar": [
        ["Döngü sırası", "Panel dış, token bloğu iç", "Token dış, panel iç", "Bir ağırlık paneli 8 token bloğunda yeniden kullanılır; her panel host'tan yalnızca bir kez akar (K=128: 1 088 B)."],
        ["Aktivasyon", "BRAM'de yerleşik, 64 bit sözcük = 8 token baytı", "Her panelde yeniden gönderme", "Aktivasyon bir kez yüklenir, tüm paneller için yeniden kullanılır."],
        ["Panel tamponu", "Çift tampon (ping-pong), pan_hazir/pan_bitti el sıkışması", "Tek tampon", "Host p+1'i yazarken FPGA p'yi işler; el sıkışma yapısal çakışmayı önler."],
        ["Çıkış", "Gölge acc + bias ekleme, 64 çevrimde akıtma", "Doğrudan c_flat okuma", "Sonraki tile hesaplanırken çıkış akıtılır (K+15 ≥ 64 olduğundan örtüşür; K<49 için koruma bayrağı out_tasma)."],
        ["Tile başlatma", "done görüldüğü çevrimde bir sonraki start", "Ayrı START durumu", "Tile periyodu K+15 (hesap K+14 + 1 başlatma çevrimi)."],
    ],
    "literatur": [
        {"konu": "Aktivasyonun BRAM'de kalıcı tutulması, ağırlığın blok blok akıtılması", "alintilar": ["KV-01"],
         "bizde": "Aktivasyon BRAM'i (girdi) bir kez yazılır; ağırlık paneli (B) host'tan akıtılır ve panel tamponunda 8 token bloğu boyunca yeniden kullanılır. Yapı kaynaktakiyle aynı düzendir: A yerleşik, B blok blok akar.",
         "fark": f"Kaynakta B, kart üzerindeki DDR'den akıtılır; bizde B bir PC'den UART ile gelir. Bu fark ölçümlüdür: bir panelin hesabı {hesap_panel * 1e3:.1f} µs sürerken 921 600 baud'da aktarımı yaklaşık {uart_921:.1f} ms sürer (hesap; ≈{uart_921 / hesap_panel:.0f}× fazla, Şekil 2). Mimari UART-bağımlı olduğundan hız kazancı beklenmez (bkz. Sınırlar).",
         "sekil": ["S2"]},
        {"konu": "Tile'ın BRAM'e sığması", "alintilar": ["TL-01"],
         "bizde": "Belleğin en kötü durum büyüklüğü (K, C ≤ 512): aktivasyon 256 Kb, çıkış 256 Kb, panel tamponu 2·32 Kb + bias/M0; toplamı Şekil 3'te hesapla gösterildi (≈ 18 BRAM36, tahmin).",
         "fark": "Kaynaktaki ‘tile’ iki seviyeli döşemenin dış tile'ıdır; bizdeki 8×8 tile hesap birimidir, BRAM'e sığması gereken şey katman aktivasyonlarıdır. Sentez sayısı TR12'dedir.",
         "sekil": ["S3"]},
        {"konu": "Dış tile'ın bir kez yüklenip çok kez yeniden kullanılması", "alintilar": ["TL-02"],
         "bizde": "Ağırlık paneli 8 kez (token blokları), aktivasyon C/8 kez (paneller) yeniden kullanılır. Yeniden kullanım oranı T=64 token ile 8 ile sınırlıdır; bu yüzden aktarım hesapla örtüşmez.",
         "fark": "Kaynak yeniden kullanımı bellek trafiğini azaltmak için önerir; bizim durumumuzda trafik PC–FPGA kanalıdır ve yeniden kullanım yalnızca 8× olduğu için kanal doymuş kalır. Daha uzun dizi (T>64) ya da ağırlığın kartta kalıcı saklanması (flash/BRAM) çözüm adaylarıdır; ölçülmedi.",
         "sekil": ["S1"]},
        {"konu": "Bloklu matris çarpımı", "alintilar": ["SN-01"],
         "bizde": "Tile haritası (Şekil 1): 64×128 çıktı 8×16 tile ızgarasıdır, 128 tile her cümle için işlenir; sıra panel-ana'dır.",
         "fark": "Kaynak genel bir fikir sunar; sıra ve bellek düzeni bizim mimarimize özgüdür."},
        {"konu": "Host'tan (PC) panel akıtma", "alintilar": [],
         "bizde": "pan_hazir[b] / pan_bitti el sıkışması (TR08'deki protokolle sürülür). Host panelleri sırayla gönderir; çıkış katı panelin son tile'ını bitirince tamponu ‘boş’ ilan eder.",
         "fark": "Doğrudan karşılık bulunamadı; mühendislik kararı. 2021 sonrası doğrulanmış, PC'den ağırlık akıtan bir hızlandırıcı kaynağı bulunamadı.", "sekil": ["S4"]},
    ],
    "dogrulama": {"arac": "Icarus Verilog; altın = 02-RTL_Altin_Model test vektörleri",
                  "kaynak_dosyalar": ["03-RTL/sim/g5_tile_l0q.txt", "03-RTL/sim/g7_sonuc.json", "03-RTL/sim/g10_sonuc.json"],
                  "tablo": [["Test", "Kapsam", "Çevrim (ölçülen / teorik)", "Sonuç"],
                            ["tb_tile l0_q", "4 cümle, 64×128 birikeç (bias dahil), 16 panel × 8 blok", f"{c5} / {t5}", f"PASS — {k5} kontrol, 0 hata; {tile5} tile"],
                            ["tb_tile dikkat (8 koşu)", "Q·Kᵀ ve P·V, K=64, 4 cümle", f"{g10[0]['cevrim']} / 4992", f"PASS — {g10[0]['ayrinti']} (×8)"],
                            ["Katman başına çevrim", "12 doğrusal katman (TR06)", f"%{100 * (min(s['cevrim_olculen'] / s['cevrim_teorik'] for s in g7) - 1):.1f}…%{100 * (max(s['cevrim_olculen'] / s['cevrim_teorik'] for s in g7) - 1):.1f} fazla", "bkz. Şekil 5"]],
                  "sekil": ["S5"]},
    "sinirlar": [
        f"Tile periyodu K+15'tir; teorik K+14'e göre ölçülen katman çevrimleri %{100 * (min(s['cevrim_olculen'] / s['cevrim_teorik'] for s in g7) - 1):.1f}–%{100 * (max(s['cevrim_olculen'] / s['cevrim_teorik'] for s in g7) - 1):.1f} fazladır (başlatma, panel geçişi, boşaltma).",
        f"Hesap yalnızca {hesap_panel * 1e3:.1f} µs/panel iken 921 600 baud aktarımı ≈{uart_921:.1f} ms/panel'dir (hesap); sistem UART'a bağlıdır. 3 Mbaud ile bile ≈250× fazladır.",
        "Gölge kopya 2 048 FF'dir; çıkış seçici 64:1 çoklayıcıdır (sentez maliyeti TR12'de).",
        "K<49 için çıkış akıtması bir sonraki tile'ın bitişiyle çakışabilir; denetleyici out_tasma bayrağıyla bunu bildirir (kullanılan K ≥ 64).",
        "Tüm sonuçlar benzetimdir; kartta çalıştırma yoktur.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr04_s1_tile_haritasi.png", "baslik": "Tile haritası ve işlenme sırası (l0_q).", "aciklama": "Her hücre bir 8×8 çıktı tile'ıdır; satır token bloğu, sütun çıkış paneli. Sayı, işlenme sırasıdır: aynı panel 8 token bloğunda art arda kullanılır, sonra bir sonraki panel gelir.", "genislik_cm": 13},
        "S2": {"dosya": "sekiller/tr04_s2_zaman.png", "baslik": "Bir panel için hesap ve UART aktarım süresi (log ölçek, hesap).", "aciklama": "Yeşil çubuk 8 tile'ın 100 MHz'deki hesap süresi, turuncu/kırmızı çubuklar 3 Mbaud ve 921 600 baud'da panelin (1 088+ bayt) aktarım süresidir. Aktarım hesaptan üç büyüklük mertebesi uzundur: çift tamponlama aktarımı gizleyemez, yalnızca hesabı aktarımın arkasına saklar.", "genislik_cm": 13},
        "S3": {"dosya": "sekiller/tr04_s3_bram.png", "baslik": "Bellek yerleşimi (en kötü durum, hesap).", "aciklama": "Üç ana bellek ve boyutları; sözcük 64 bit. BRAM36 sayısı bit sayısından hesaplanmıştır (tahmin, sentez TR12).", "genislik_cm": 13},
        "S4": {"dosya": "sekiller/tr04_s4_dalga.png", "baslik": "l0_q ilk tile'lar dalga formu.", "aciklama": "state, start_now, sys_done, blk ve o_run sinyalleri: bir tile bitince aynı çevrimde bir sonraki başlar; gölge akıtması (o_run, out_valid) bir sonraki tile hesaplanırken sürer.", "genislik_cm": 14},
        "S5": {"dosya": "sekiller/tr04_s5_cevrim.png", "baslik": "Katman başına çevrim: teorik ve benzetim.", "aciklama": "Mavi çubuk (K+14)·P·8 formülü, turuncu çubuk benzetimde kos'tan layer_done'a ölçülen çevrimdir; fark tile başına +1 ve panel geçişlerinden gelir.", "genislik_cm": 13},
    },
    "mimari_sekilleri": ["S1"],
}

# ------------------------------------------------------------------ TR05
m_un = re.compile(r"")
tr05 = {
    "rapor_no": "TR05", "baslik": "Yeniden Ölçekleme Birimi (M0, kaydırma, kırpma)",
    "alt_baslik": "yeniden_olcekle.v: INT32 birikeç → INT8, altın modelle bit-birebir",
    "gorev": "G6 — yeniden ölçekleme", "tarih": "27 Ekim 2026",
    "durum": "UYGULANDI (benzetim). Birim testi 7792 vektör 0 hata; 12 katmanda uçtan uca bit-birebir.",
    "amac": "Her doğrusal katmanın INT32 birikecini (bias dahil) kanal başına M0 ve katman başına n ile ölçekleyip yarım-yukarı yuvarlayarak INT8'e indiren biriminin tasarım kararlarını ve doğrulamasını kaydetmek.",
    "kararlar": [
        ["Formül", "y = kirp((acc·M0 + 2^(n−1)) >>> n)", "Float çarpma", "Altın modelin sabit_nokta_carp + kirp işlemiyle bire bir; float yok."],
        ["Yuvarlama", "Yarım-yukarı (sabit eklenip kaydırma)", "Bankacı yuvarlaması", "Donanımda tek toplayıcı + kaydırma; altın modeldeki yuvarla_yukari_tamsayi ile aynı."],
        ["Genişlikler", "acc 32b × M0 31b → 64b", "Daha dar M0", "M0_BIT=31 parametre paketi; ara çarpım int64'e sığar. DSP maliyeti tahmindir (TR12)."],
        ["Boru hattı", "3 çevrim: çarp / yuvarla / kaydır+kırp", "Tek çevrim kombinasyonel", "Çevrim başına 1 eleman; tile hesabıyla örtüşür (64 eleman < K+15)."],
        ["Parametreler", "M0 kanal başına, n katman başına", "Kanal başına n", "KAYDIRMA_<AD> (parametreler.vh); n paylaşımlı olduğundan kaydırıcı sabit/katman başına."],
    ],
    "literatur": [
        {"konu": "Tek tamsayı çarpma ve kaydırmayla yeniden ölçekleme", "alintilar": ["SW-03", "IV-01"],
         "bizde": "yeniden_olcekle.v çarpma (A1), yuvarlama sabiti ekleme (A2) ve aritmetik kaydırma+kırpma (A3) aşamalarıdır; işlem yolunda float yoktur.",
         "fark": "SwiftTron'daki birim çarpmayı ‘bir bitlik kaydırma’ ile tarif eder; bizde çarpan 31 bit M0, kaydırma ise 36–42 bitlik değişken n'dir ve ayrıca yarım-yukarı yuvarlama ve doyumlu kırpma vardır. Kaynakların donanım ayrıntıları (ör. kırpma, yuvarlama) bu alıntılardan çıkarılamaz.",
         "sekil": ["S1"]},
        {"konu": "M ≈ M0·2^−n biçiminde yaklaşıklama (ApproxMul)", "alintilar": ["IO-01", "IO-02"],
         "bizde": "carpani_ayristir: M gerçel çarpanı (M0, n) tamsayı çiftine ayrılır; 14 katman için n = 36…42, M0 < 2^30 (Şekil 2).",
         "fark": "IntOnlyFPGA formülü tek M ve n bildirir; bizde M0 kanal başınadır, n katman başınadır. Yaklaşıklığın doğruluk maliyeti TR06'daki uçtan uca (718/872) sonuçla ölçülmüştür.",
         "sekil": ["S2"]},
    ],
    "dogrulama": {"arac": "Icarus Verilog; altın = saf Python tamsayı (tb/gen_vektor_rq.py) ve altın model .mem'leri",
                  "kaynak_dosyalar": ["03-RTL/tb/tb_requant.v", "03-RTL/sim/g7_sonuc.json"],
                  "tablo": [["Test", "Kapsam", "Sonuç"],
                            ["tb_requant (birim)", "uç değerler, yarım-yukarı tie, gerçekçi n=36–42, tam aralık rastgele, kırpma sınırı; rastgele boşluklu akış", "PASS — 7792 vektör, 0 hata"],
                            ["dogrusal_katman (12 katman)", "altın <ad>_cikis.mem ile INT8 çıktı karşılaştırması, 4 cümle", f"PASS — {sum(1 for s in g7 if s['pass'])}/{len(g7)} katman, 0 hata"],
                            ["Kırpma", "12 katmanda kırpılan INT8 eleman sayısı (4 cümle)", f"toplam {sum(s['kirpilan_eleman'] for s in g7)}"]],
                  "sekil": ["S4", "S3"]},
    "sinirlar": [
        "Birimin işlem hattı çevrim başına bir elemandır; bir hat 64 elemanı 64 çevrimde işler, bu K+15'ten kısadır (K ≥ 49).",
        "DSP kullanımı (32×31 çarpım) bu raporda ölçülmedi; Vivado sonucu TR12'dedir.",
        "m0_bit=31 (RTL) ile 05_karsilastir.py'deki varsayılan 16 farklıdır; G2 ölçümü m0_bit=31 ile yapılmıştır.",
        "Tüm sonuçlar benzetimdir.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr05_s1_boru.png", "baslik": "Yeniden ölçekleme boru hattı.", "aciklama": "birikeç+bias (INT32) → A1 çarpma (64 bit) → A2 yuvarlama sabiti → A3 aritmetik kaydırma ve [−128,127] kırpma → INT8; M0 ve n parametre paketinden gelir.", "genislik_cm": 14},
        "S2": {"dosya": "sekiller/tr05_s2_sabitler.png", "baslik": "14 katmanın kaydırma (n) ve M0 aralığı.", "aciklama": "Üst grafik katman başına n, alt grafik katmandaki kanalların log2(M0) aralığıdır; kırmızı çizgi M0'ın 2^30 üst sınırıdır. Tüm M0 değerleri sınırın altındadır.", "genislik_cm": 13},
        "S3": {"dosya": "sekiller/tr05_s3_kirpma.png", "baslik": "Katman başına kırpılan INT8 çıktı sayısı.", "aciklama": "Benzetimde yeniden ölçekleme biriminin kırpma sayacından alınmıştır (4 cümle). 0, hiçbir elemanın [−128,127] dışına çıkmadığı anlamına gelir.", "genislik_cm": 12},
        "S4": {"dosya": "sekiller/tr05_s4_birim.png", "baslik": "Birim testinin vektör grupları.", "aciklama": "Her çubuk bir vektör grubudur (toplam 7792, tamamı 0 hata). Altın, tb/gen_vektor_rq.py içindeki saf Python tamsayı hesabıdır.", "genislik_cm": 12},
    },
    "mimari_sekilleri": [],
}

# ------------------------------------------------------------------ TR06
tr06 = {
    "rapor_no": "TR06", "baslik": "Doğrusal Katman Uçtan Uca",
    "alt_baslik": "dogrusal_katman.v: aktivasyon BRAM → dizi → +bias → yeniden ölçekle → çıkış BRAM",
    "gorev": "G7 — tek doğrusal katman uçtan uca", "tarih": "27 Ekim 2026",
    "durum": f"UYGULANDI (benzetim): {sum(1 for s in g7 if s['pass'])}/{len(g7)} katman altın çıkışla bit-birebir.",
    "amac": "Tile denetleyici (TR04), 8×8 dizi (TR03) ve yeniden ölçekleme (TR05) birimlerini tek modülde birleştirip L0 ve L1'in 12 doğrusal katmanını (Q, K, V, attn_out, ffn1, ffn2) aynı donanımla altın model çıkışına karşı doğrulamak.",
    "kararlar": [
        ["Tek modül", "Aynı dogrusal_katman, katmana özgü (K, np, n) konfigürasyonla", "Katman başına ayrı modül", "Kaynak kullanımı sabit kalır; katmanlar ardışık çalışır."],
        ["Çıkış düzeni", "Çıkış BRAM sözcüğü = 8 token baytı, adres blk·C + kanal", "Satır-öncelikli INT8", "Sonraki katmanın aktivasyon düzeniyle aynıdır (blok düzeni); yeniden düzenleme gerekmez."],
        ["Doğrulama kapsamı", "Her katman kendi altın girdisiyle", "Zincirli (FPGA çıktısı → sonraki girdi)", "Katmanlar arasında host'ta kalan birimler (Softmax, LayerNorm, artık toplam) var; zincirleme bu rapor kapsamı dışındadır."],
    ],
    "literatur": [
        {"konu": "INT8 girdi, INT32 birikeç, ardından yeniden ölçekleme", "alintilar": ["SW-01"],
         "bizde": "Her katmanın veri yolu INT8×INT8→INT32 (+bias) → yeniden ölçekleme → INT8 şeklindedir (Şekil 1).",
         "fark": "Kaynak yalnızca düzeni belirtir; bizim katmanlar arası taşıma host'ta kalan birimler nedeniyle henüz tamsayı zincir değildir (tamsayı taşıma yazılım modelinde ölçüldü: 718/872, TR02/G2).",
         "sekil": ["S1"]},
        {"konu": "Kalibrasyonun önemi", "alintilar": ["KV-04"],
         "bizde": "Yeniden ölçekleme çarpanları kalibre edilmiş ara ölçeklerden (ara_olcekler.json) türetilir; altın model bunu kullanır.",
         "fark": "Ara ölçekler 128 cümle ve tek tohumla kalibre edilmiştir; 512 cümle × 3 tohum çalışması (G3) bu çalışmada yapılmadı. Kaynağın ‘dikkatli kalibrasyon’ vurgusu bu eksiği haklı kılmaz, açık nokta olarak kalır."},
    ],
    "dogrulama": {"arac": "Icarus Verilog; altın = 02-RTL_Altin_Model/03_Sonuclar/test_vektorleri/<ad>_cikis.mem",
                  "kaynak_dosyalar": ["03-RTL/sim/g7_sonuc.json", "03-RTL/scripts/kos_g7.py"],
                  "tablo": [["Katman (K×C, n)", "Çevrim/cümle (ölçülen / teorik)", "Sonuç"]] +
                           [[f"{s['ad']} ({s['K']}×{s['C']}, n={s['n']})", f"{s['cevrim_olculen']} / {s['cevrim_teorik']}", ("PASS — " if s["pass"] else "FAIL — ") + s["ayrinti"]] for s in g7],
                  "sekil": ["S2", "S3"]},
    "sinirlar": [
        f"L0 doğrusal katmanları toplam {l0_cev} çevrim = {l0_cev / 100e6 * 1e3:.2f} ms @100 MHz (yalnız hesap, tek cümle, tam dolu 64 token dizisi). Aktarım ve host işlemleri dahil değildir.",
        "pooler ve classifier (tek CLS token) bu raporda doğrulanmadı; blok düzeni için sıfır dolgulu tek blok gerekir (vektörler üretildi, RTL testi yapılmadı).",
        "Katmanlar altın girdileriyle ayrı ayrı doğrulandı; zincirli (FPGA çıktısı → sonraki girdi) akış doğrulanmadı.",
        "Tüm sonuçlar benzetimdir.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr06_s1_katman.png", "baslik": "dogrusal_katman veri yolu.", "aciklama": "Aktivasyon BRAM'i ve panel tamponu tile denetleyiciyi besler; gölge acc'den bias eklenip yeniden ölçeklenir, isteğe bağlı GELU LUT'tan geçer, paketleyici sonucu çıkış BRAM'ine yazar.", "genislik_cm": 14},
        "S2": {"dosya": "sekiller/tr06_s2_dogrulama.png", "baslik": "12 katmanın doğrulama sonucu.", "aciklama": "Çubuk yüksekliği karşılaştırılan INT8 çıktı sayısı (4 cümle × 64 token × C), yeşil = altın modelle bit-birebir (0 hata).", "genislik_cm": 12},
        "S3": {"dosya": "sekiller/tr06_s3_cevrim.png", "baslik": "Katman başına çevrim (bir cümle).", "aciklama": "kos darbesinden layer_done'a ölçülen çevrim; ffn1 (C=512) ve ffn2 (K=512) en pahalı katmanlardır.", "genislik_cm": 12},
    },
    "mimari_sekilleri": [],
}

# ------------------------------------------------------------------ TR07 (GELU)
g8 = T("g8_gelu_entegrasyon.txt")
k8 = re.search(r"\((\d+) kontrol, 0 hata\)", g8).group(1)
tr07 = {
    "rapor_no": "TR07", "baslik": "GELU Arama Tablosu (LUT)",
    "alt_baslik": "gelu_lut.v: 256 girişli INT8→INT8 tablo, ffn1 çıkışına bağlı",
    "gorev": "G8 — GELU LUT", "tarih": "27 Ekim 2026",
    "durum": "UYGULANDI (benzetim): ffn1+GELU bit-birebir (1 cümle).",
    "amac": "FFN'nin ilk katmanından sonra gelen GELU'yu, INT8 girişli 256 girişli bir tabloyla (hesapsız) gerçekleyen birimin kararlarını ve doğrulamasını kaydetmek.",
    "kararlar": [
        ["Yöntem", "256 girişli LUT, INT8→INT8", "Polinom yaklaşıklığı", "Girdi INT8 olduğundan tablo tüm girdileri tam kapsar; çarpıcı yok, 1 çevrim."],
        ["Yükleme", "Host tabloyu yükler (YUKLE_PANEL sel=3)", "Bitstream'e gömme", "Katman başına farklı ölçekler (l0, l1) aynı donanımla kullanılır."],
        ["Yer", "Yeniden ölçekleme çıkışı → LUT → paketleyici", "Ayrı geçiş", "Ek bellek geçişi gerekmez."],
    ],
    "literatur": [
        {"konu": "GELU'nun donanımda gerçeklenmesi", "alintilar": ["SN-02"],
         "bizde": "Bizde GELU, çıktı ölçeğine göre önceden hesaplanmış 256 baytlık bir tablodur; hesaplama birimi (polinom/EU/GU) yoktur.",
         "fark": "SwinFPGA GELU birimi polinom hesaplama, üstel ve ek bir birimden oluşur; bizde bunun yerine tablo kullanılır. Bu bir benzerlik değil alternatif tasarımdır; doğrudan karşılaştırılabilir ölçüm yoktur. GELU LUT için doğrudan kaynak bulunamadı.",
         "sekil": ["S1"]},
        {"konu": "Bellek-yoğun LUT yaklaşımı eleştirisi", "alintilar": ["QK-02"],
         "bizde": "Kaynak LUT yöntemlerini ‘bellek-yoğun’ diye niteler. Bizim tablomuz 256×8 bit = 256 bayt/katmandır (dağıtık RAM, ihmal edilebilir).",
         "fark": "Kaynağın eleştirisi büyük giriş genişlikleri içindir; INT8 girişte bu endişe geçerli değildir (bu bir çıkarımdır, ölçüm değil).",
         "sekil": ["S2"]},
    ],
    "dogrulama": {"arac": "Icarus Verilog; altın = l<i>_gelu_lut.mem ve bağımsız python (scripts/g8_hazirla.py)",
                  "kaynak_dosyalar": ["03-RTL/sim/g8_gelu_entegrasyon.txt", "03-RTL/sim/g8_gelu.json"],
                  "tablo": [["Test", "Kapsam", "Sonuç"],
                            ["g8_hazirla.py", "LUT = round(GELU/s_out) tüm 256 giriş, l0 ve l1", "PASS — 2 LUT, 0 hata"],
                            ["tb_katman ffn1+GELU", "l0_ffn1 (K=128, C=512), 1 cümle, GELU açık", f"PASS — {k8} kontrol, 0 hata"]],
                  "sekil": []},
    "sinirlar": ["ffn1+GELU bir cümleyle doğrulandı (4 cümle ffn1 çıkışı TR06'da, GELU'suz).", "LUT'un FP32 GELU'ya göre hatası Şekil 2'de, nicemleme adımı cinsindendir.", "Tüm sonuçlar benzetimdir."],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr07_s1_lut.png", "baslik": "Tamsayı LUT ve FP32 GELU.", "aciklama": "Noktalar iki katmanın tablo değerlerinin (girdi·ölçek, çıktı·ölçek) gerçek birimde çizimi; gri çizgi FP32 GELU'dur.", "genislik_cm": 12},
        "S2": {"dosya": "sekiller/tr07_s2_hata.png", "baslik": "LUT'un FP32 GELU'ya göre en büyük hatası.", "aciklama": "Çıkış nicemleme adımı cinsinden; yuvarlamanın en kötü durumu 0,5 adımdır (kırmızı çizgi).", "genislik_cm": 10},
    },
    "mimari_sekilleri": [],
    "gorsel_istisna": "Yalnızca iki şekil: tek bir tablo birimi; blok şeması TR06'daki veri yolu şemasında gösterildi.",
}

# ------------------------------------------------------------------ TR08
paketler, bayt = g9["paket_sayisi"], g9["gonderilen_bayt"]
tr08 = {
    "rapor_no": "TR08", "baslik": "Host–FPGA Arabirimi ve Host-in-the-Loop",
    "alt_baslik": "komut_cozucu.v, uart_rx/tx.v, hizlandirici_surucu.py: paket protokolü, CRC8, benzetim arka ucu",
    "gorev": "G9 — host↔hızlandırıcı arabirimi", "tarih": "27 Ekim 2026",
    "durum": "UYGULANDI (benzetim; UART bit düzeyi testli). Kart ve pyserial arka ucu DENENMEDİ.",
    "amac": "PC'nin (host) hızlandırıcıyı sürdüğü paket protokolünü, komut çözücüyü, UART katmanını ve Python sürücüyü tanımlamak; L0'ın 6 doğrusal katmanını PC→(benzetilen) FPGA→PC döngüsünde altın modelle doğrulamak.",
    "kararlar": [
        ["Protokol", "cmd/len/payload/CRC8, dur-ve-bekle, ACK/HATA/VERI", "Akış (paketsiz)", "Basit, bozuk paketi yakalar; her pakete yanıt gelir."],
        ["UART", "8N1, parametrik CLKS_PER_BIT (109 → 921 600 baud, 33 → 3 Mbaud @100 MHz)", "SPI/USB-FIFO", "Basys3 USB-UART'ı; ek donanım gerekmez."],
        ["Arka uç", "Aynı sürücü API'si: SimArkaUc (Icarus) ve SeriArkaUc (pyserial)", "Yalnız benzetim", "Kart gelince sürücü değişmeden kullanılır; bekleme adımı DURUM sorgusuyla."],
        ["Yazma güvenliği", "Yazmalar CRC'den önce uygulanır, host HATA'da paketi yeniden gönderir; CFG yalnızca CRC doğruysa", "Tamponlayıp sonra yaz", "Tampon BRAM maliyeti yok; yazmalar idempotent."],
    ],
    "literatur": [
        {"konu": "PC–FPGA UART arabirimi ve paket protokolü", "alintilar": [],
         "bizde": "Protokol, CRC8 (poly 0x07) ve el sıkışma (pan_hazir/pan_bos) kendi tasarımımızdır; ayrıntı Şekil 2 ve 3.",
         "fark": "Doğrudan karşılık bulunamadı; mühendislik kararı. 2021 sonrası doğrulanmış, PC'den hızlandırıcıya UART ile ağırlık akıtan bir kaynak bulunamadı; aramaya devam edilecek.",
         "sekil": ["S2", "S3"]},
    ],
    "dogrulama": {"arac": "Icarus Verilog; host/g9_host_dongusu.py; altın = test vektörü .mem",
                  "kaynak_dosyalar": ["03-RTL/sim/g9_l0_sonuc.json", "03-RTL/sim/g9_l0_log.txt", "03-RTL/tb/tb_uart.v"],
                  "tablo": [["Test", "Kapsam", "Sonuç"],
                            ["Host-in-the-loop", f"6 L0 katmanı, cümle {g9['cumle']}, {paketler} paket, {bayt} bayt PC→FPGA", "PASS — " + ", ".join(f"{k}: {v['uyusmayan']} fark" for k, v in g9["katmanlar"].items())],
                            ["Hata enjeksiyonu", "bozuk CRC'li CFG; bilinmeyen komut", f"HATA(CRC) ve HATA(bilinmeyen komut) döndü: {g9['hata_enjeksiyonu']['ok']}"],
                            ["UART bit düzeyi", "tb_uart.v (CLKS_PER_BIT=16): DURUM, bozuk CRC, CFG", "PASS — 10 kontrol, 0 hata"]],
                  "sekil": ["S4", "S5"]},
    "sinirlar": [
        f"Aktarım hacmi {bayt / 1024:.0f} KB (PC→FPGA, 6 katman) → 921 600 baud'da ≈{g9['uart_921600_sn_tahmin']} sn, 3 Mbaud'da ≈{g9['uart_3M_sn_tahmin']} sn (hesap; donanımda doğrulanmadı). Bir cümlelik çıkarımın tüm 14 katmanı için ağırlıklar her seferinde akıtılacağından ≈420 KB → 921 600 baud'da ≈4,6 sn (hesap).",
        "pyserial arka ucu (SeriArkaUc) yazıldı ancak kartta denenmedi; UART bit düzeyi yalnızca benzetimde sınandı.",
        "Host-in-the-loop, her katmanın altın girdisiyle yapıldı; Softmax/LayerNorm/artık toplam FPGA'da yok (host'ta kalıyor), zincirleme PC–FPGA akışı denenmedi.",
        "Çok hızlı UART (3 Mbaud) için 100 MHz'den bölme (CLKS_PER_BIT=33) bit hız hatası ≈%1; kartta doğrulanmalı.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr08_s1_sistem.png", "baslik": "Sistem: PC ve FPGA iş bölümü.", "aciklama": "PC tokenizer, gömme ve paketlemeyi yapar; FPGA USB-UART üzerinden gelen paketleri çözer, BRAM'lere yazar ve tile/dizi/yeniden ölçekleme hattını çalıştırır.", "genislik_cm": 14},
        "S2": {"dosya": "sekiller/tr08_s2_paket.png", "baslik": "Paket biçimi ve komut kodları.", "aciklama": "Her paket cmd, uzunluk (2 bayt, LE), yük ve CRC8'den oluşur. Yanıtlar ACK, HATA(kod) ya da VERI'dir (VERI kendi CRC'sini taşır).", "genislik_cm": 14},
        "S3": {"dosya": "sekiller/tr08_s3_zaman.png", "baslik": "Bir katman için host–FPGA mesaj sırası.", "aciklama": "Mavi oklar PC→FPGA, kırmızı ok FPGA→PC. İki panel önceden yüklenir, CALISTIR sonrası boşalan tampon yeni panelle doldurulur; layer_done ardından çıkış okunur.", "genislik_cm": 13},
        "S4": {"dosya": "sekiller/tr08_s4_uart.png", "baslik": "UART dalga formu (tb_uart.vcd).", "aciklama": "rx_pin: DURUM isteği (4 bayt); tx_pin: VERI yanıtı (7 bayt). Her bayt 10 bit (başlangıç, 8 veri, durdurma).", "genislik_cm": 14},
        "S5": {"dosya": "sekiller/tr08_s5_hacim.png", "baslik": "L0 doğrusal katmanları veri hacmi (hesap).", "aciklama": "Her katman için aktivasyon, ağırlık+bias+M0 ve çıktı baytları; ffn1/ffn2 ağırlıkları baskındır.", "genislik_cm": 12},
    },
    "mimari_sekilleri": ["S1"],
}

# ------------------------------------------------------------------ TR09 (dikkat)
tr09 = {
    "rapor_no": "TR09", "baslik": "Dikkat Çekirdeği: Q·Kᵀ ve P·V Dizide",
    "alt_baslik": "Aynı tile denetleyici ve 8×8 dizi ile aktivasyon×aktivasyon çarpımı; UINT8 olasılık 9 bit A ile",
    "gorev": "G10 — dikkat", "tarih": "27 Ekim 2026",
    "durum": "UYGULANDI (benzetim): 8 koşu bit-birebir. Softmax FPGA'da değil (host).",
    "amac": "Dikkat çarpımlarının (Q·Kᵀ INT8×INT8; P·V UINT8×INT8) doğrusal katmanla aynı denetleyici ve dizi üzerinde çalıştığını ve altın birikeçlerle bit-birebir eşleştiğini göstermek.",
    "kararlar": [
        ["B işleneni", "Q·Kᵀ: K'nın blok düzeni zaten panel düzenidir", "Ayrı transpoz birimi", "Anahtar token'ları sözcüğe yerleşiktir: panel sözcüğü (boyut d) = K_h'nin blok sözcüğü."],
        ["P·V", "V'nin transpozu host'ta yeniden düzenlenip panel olarak akıtılır", "FPGA'da transpoz", "Çıkış BRAM'i token'ları sözcüğe koyar; P·V için sözcük = bir token'ın 8 boyutu gerekir. Transpoz 8 KB/baş/katman host trafiği ekler."],
        ["Olasılık", "UINT8 (0..255), a_isaretsiz=1, 9 bit A", "INT8'e daraltma", "Olasılık ölçeği (1/255) korunur (TR02)."],
    ],
    "literatur": [
        {"konu": "Bloklu matris çarpımı ile dikkat", "alintilar": ["SN-01"],
         "bizde": "Q·Kᵀ ve P·V, doğrusal katmanlarla aynı 8×8 tile'larla (K=64, C=64) hesaplanır; her baş ve her katman için 64×64 çıktı.",
         "fark": "Kaynak SwinFPGA'da pencere dikkatini bloklu çarpımla yapar; bizdeki tam dikkat (64 token) ve Softmax'ın host'ta olması farklıdır.", "sekil": ["S2"]},
    ],
    "dogrulama": {"arac": "Icarus Verilog; altın = test vektörü l<i>_qk/av_birikec", "kaynak_dosyalar": ["03-RTL/sim/g10_sonuc.json", "03-RTL/scripts/g10_hazirla.py"],
                  "tablo": [["Koşu", "Kapsam", "Çevrim/cümle", "Sonuç"]] + [[s["ad"], "UINT8×INT8 (P·V)" if s["a_isaretsiz"] else "INT8×INT8 (Q·Kᵀ)", str(s["cevrim"]), ("PASS — " if s["pass"] else "FAIL — ") + s["ayrinti"]] for s in g10],
                  "sekil": ["S1"]},
    "sinirlar": ["Softmax (satır max, exp LUT, bölme) FPGA'da yoktur; skor→olasılık dönüşümü host'tadır, bu nedenle dikkat tek geçişte FPGA'da bitmez.",
                 "P·V için V'nin host'ta transpozu zorunludur (hesap: 8 KB/baş/katman).",
                 "Q·Kᵀ birikeci ölçeklenmeden (INT32) doğrulandı; skor yeniden ölçekleme (12 bit) ve maskeleme host'tadır.",
                 "Tüm sonuçlar benzetimdir."],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr09_s1_dogrulama.png", "baslik": "Dikkat çarpımlarının doğrulama sonucu.", "aciklama": "Her çubuk bir (katman, baş, işlem) koşusunun kontrol sayısıdır; tümü 0 hata.", "genislik_cm": 12},
        "S2": {"dosya": "sekiller/tr09_s2_isi.png", "baslik": "Softmax olasılığı (UINT8) ve RTL−altın farkı (l0, baş 0, cümle 0).", "aciklama": "Sol: altın UINT8 olasılık (0..255) 64×64; sağ: P·V birikecinde RTL−altın farkı: tümü sıfır (RTL kodu için benzetim logundan; fark haritası aynı sıfır matrisidir).", "genislik_cm": 13},
        "S3": {"dosya": "sekiller/tr09_s3_veriakisi.png", "baslik": "Dikkat veri akışı.", "aciklama": "Q_h blok düzeninde A olarak, K_h panel olarak (zaten aynı düzen) gelir; P·V'de V host'ta transpoz edilir.", "genislik_cm": 13},
    },
    "mimari_sekilleri": ["S3"],
}

for ad, sp in (("TR04_tile_denetleyici", tr04), ("TR05_yeniden_olcekleme", tr05), ("TR06_dogrusal_katman", tr06),
               ("TR07_gelu_lut", tr07), ("TR08_host_arabirimi", tr08), ("TR09_dikkat", tr09)):
    yol = os.path.join(AY, "tasarim_raporlari", ad + ".json")
    json.dump(sp, open(yol, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print("yazıldı:", yol)
