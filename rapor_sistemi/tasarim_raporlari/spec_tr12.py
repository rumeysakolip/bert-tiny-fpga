"""TR12 — Vivado post-sentez kaynak/zamanlama raporu spesifikasyonu (sayılar sim/g12_ozet.json)."""
import json
import os

AY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
o = json.load(open(os.path.join(os.path.dirname(AY), "03-RTL", "sim", "g12_ozet.json"), encoding="utf-8"))
t, m = o["top"], o["modul"]
sp = {
    "rapor_no": "TR12", "baslik": "Sentez Sonucu: Kaynak Kullanımı ve Zamanlama",
    "alt_baslik": "Vivado 2025.1, xc7a35tcpg236-1, yalnızca synth_design (yerleştirme/yönlendirme yok), üst modül hizlandirici_uart_ust",
    "gorev": "G12 — sentez ve kart hazırlık paketi", "tarih": "27 Ekim 2026",
    "durum": f"SENTEZ YAPILDI (post-synth). 100 MHz kısıtı kaba tahminde SAĞLANDI: WNS {t['WNS']} ns (ilk sentezde −0,456 ns idi). Kart yok.",
    "amac": "RTL'in Basys3 (XC7A35T) üzerindeki kaynak kullanımını ve kaba zamanlamasını Vivado ile ölçmek, plandaki tahminlerle karşılaştırmak ve farkları nedenleriyle kaydetmek.",
    "kararlar": [
        ["Araç", "Vivado 2025.1 synth_design, flatten rebuilt", "yosys tahmini", "Vivado kuruludur; tahmin yerine ölçüm."],
        ["Kısıt", "100 MHz (10 ns) saat, Basys3 pinleri (basys3.xdc)", "—", "Pin atamaları kartta denenmedi; okulda doğrulanmalı."],
    ],
    "literatur": [
        {"konu": "DSP kullanımının çarpma birimlerinde yoğunlaşması", "alintilar": ["SN-03"],
         "bizde": f"Plan 64 PE için ≈72 DSP bekliyordu (tahmin). İlk sentezde 64 çarpıcı LUT'a eşlendi (yalnızca 4 DSP, 10 110 LUT, WNS −0,456 ns). pe.v'ye use_dsp ipucu eklenince sentez {t['DSP']:g} DSP verdi (64 PE + yeniden ölçekleme), LUT {t['LUT']:g} (%{100 * t['LUT'] / 20800:.1f}) ve FF {t['FF']:g}'e düştü.",
         "fark": "Varsayılan sentez küçük (9b×8b) çarpıcılar için LUT seçti; use_dsp ile DSP'ye zorlanınca kaynaktaki gözlem (çarpma birimi DSP'yi tüketir) bizde de görüldü. Ek yazmaçlı çarpma gerekmedi: çarp-biriktir tek DSP48E1'de, gecikme (tile = K+2N−2) değişmeden eşlendi.",
         "sekil": ["S2"]},
        {"konu": "Veri genişliği / maliyet dengesi", "alintilar": ["QK-03"],
         "bizde": "Genişlikler sabittir (A 9b, B 8b, acc 32b). Altın modelde ölçülen en geniş birikeç 25 bit civarındadır; 32 bit birikeç gereğinden geniştir ve 64 PE × 32 FF + 2 048 FF gölge kopyada kaynak yer.",
         "fark": "Kaynak dinamik bit genişliği ayarını anlatır; bizde dinamik ayar yoktur. Birikeci daraltmanın sentez etkisi denenmedi (açık nokta; LayerNorm 12 vs 16 bit kararına da henüz sentez verisi yok, LayerNorm RTL'de olmadığından).",
         "sekil": ["S3"]},
    ],
    "dogrulama": {"arac": "Vivado 2025.1 batch (03-RTL/sentez/sentez.tcl)", "kaynak_dosyalar": ["03-RTL/sentez/cikti/hizlandirici_uart_ust_kullanim.txt", "03-RTL/sentez/cikti/hizlandirici_uart_ust_zamanlama.txt"],
                  "tablo": [["Kaynak", "Kullanılan", "Mevcut", "Plan tahmini"],
                            ["Slice LUT", f"{t['LUT']:g}", "20 800", "—"], ["Slice FF", f"{t['FF']:g}", "41 600", "≈2 048 (gölge) + PE"],
                            ["BRAM36 eşdeğeri", f"{t['BRAM36']:g}", "50", "27–30"], ["DSP48E1", f"{t['DSP']:g}", "90", "≈72"],
                            ["WNS (10 ns)", f"{t['WNS']} ns", "—", "—"]],
                  "sekil": ["S1", "S4"]},
    "sinirlar": [
        f"Zamanlama sentez sonrası, yerleştirme ve yönlendirme olmadan; en kötü yol {t['yol_gecikme']:.2f} ns (kritik yol kcnt'den PE DSP girişine, 5 mantık seviyesi). Sentez sonrası 100 MHz karşılanıyor; yönlendirme gecikmesi eklenince değişebilir, gerçek frekans implementasyon sonrası belirlenmelidir.",
        "Yalnızca sentez yapıldı: implementasyon, bitstream, güç ve kartta çalıştırma yok.",
        "BRAM sayısı hedefte tahminin altındadır (15 ≤ 50); LUT %18,4 ve DSP %75,6 kullanımda; DSP en kısıtlı kaynaktır.",
        "DSP ipucu etkisi: ilk sentez 4 DSP / 10 110 LUT / WNS −0,456 ns; use_dsp ile 68 DSP / 3 816 LUT / WNS +1,648 ns. İkisi de yerleştirme öncesi sentez ölçümüdür.",
        "Sentezlenmiş 8×8 dizi ağ listesi (64 DSP) xsim ile K=64 ve K=128 vektörlerinde 198 test, 25 344 kontrol, 0 hata verdi; tam üst modül ağ listesi benzetimi yapılmadı.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr12_s1_kaynak.png", "baslik": "Post-sentez kaynak kullanımı.", "aciklama": "Her çubuk XC7A35T'deki mevcut kaynağın yüzdesidir; LUT en kısıtlı kaynaktır, DSP neredeyse kullanılmamıştır.", "genislik_cm": 12},
        "S2": {"dosya": "sekiller/tr12_s2_tahmin.png", "baslik": "Plan tahmini ve Vivado ölçümü.", "aciklama": "Gri çubuk plandaki (bölüm 6.3) tahmin, turuncu çubuk sentez sonucudur. DSP tahmini tutmadı, BRAM tahminin altında kaldı.", "genislik_cm": 12},
        "S3": {"dosya": "sekiller/tr12_s3_dagilim.png", "baslik": "LUT'ların modüllere dağılımı.", "aciklama": "Hiyerarşik rapordan; dizi (64 PE) LUT'ların çoğunu tüketir.", "genislik_cm": 12},
        "S4": {"dosya": "sekiller/tr12_s4_zamanlama.png", "baslik": "100 MHz hedefi ve sentez sonrası kritik yol.", "aciklama": "Kritik yol 10 ns hedefinin altında (WNS pozitif); bu kaba bir tahmindir, yönlendirme gecikmeleri eklenmemiştir.", "genislik_cm": 11},
    },
    "mimari_sekilleri": [],
}
yol = os.path.join(AY, "tasarim_raporlari", "TR12_sentez.json")
json.dump(sp, open(yol, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("yazıldı:", yol)
