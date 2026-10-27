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
    "durum": f"SENTEZ YAPILDI (post-synth). 100 MHz kısıtı kaba tahminde İHLAL: WNS {t['WNS']} ns. Kart yok.",
    "amac": "RTL'in Basys3 (XC7A35T) üzerindeki kaynak kullanımını ve kaba zamanlamasını Vivado ile ölçmek, plandaki tahminlerle karşılaştırmak ve farkları nedenleriyle kaydetmek.",
    "kararlar": [
        ["Araç", "Vivado 2025.1 synth_design, flatten rebuilt", "yosys tahmini", "Vivado kuruludur; tahmin yerine ölçüm."],
        ["Kısıt", "100 MHz (10 ns) saat, Basys3 pinleri (basys3.xdc)", "—", "Pin atamaları kartta denenmedi; okulda doğrulanmalı."],
    ],
    "literatur": [
        {"konu": "DSP kullanımının çarpma birimlerinde yoğunlaşması", "alintilar": ["SN-03"],
         "bizde": f"Plan 64 PE için ≈72 DSP bekliyordu (tahmin). Sentez yalnızca {t['DSP']:g} DSP kullandı; 64 adet 9b×8b çarpıcı LUT/carry zincirine eşlendi (PE başına ≈145 LUT, hiyerarşik rapor). Toplam {t['LUT']:g} LUT (%{100 * t['LUT'] / 20800:.1f}).",
         "fark": "Kaynaktaki gözlemin (çarpma birimi DSP'nin çoğunu tüketir) tersi bizde ölçüldü: küçük çarpıcılar için Vivado DSP yerine LUT seçti. Nedeni bu çalışmada incelenmedi; DSP'ye zorlama (use_dsp) veya çarpmayı PE içinde yazmaçlı yazmak denenebilir (açık nokta).",
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
        f"Zamanlama sentez sonrası, yerleştirme ve yönlendirme olmadan; en kötü yol {t['yol_gecikme']:.2f} ns (kritik yol dizideki PE acc toplamasına giden k_reg/kontrol yolu, 17 mantık seviyesi). Bu 100 MHz'i karşılamaz; gerçek frekans implementasyon sonrası belirlenmelidir (düşük frekansta çalıştırma seçeneği vardır).",
        "Yalnızca sentez yapıldı: implementasyon, bitstream, güç ve kartta çalıştırma yok.",
        "BRAM sayısı hedefte tahminin altındadır (15 ≤ 50); LUT %48,6 ile en kısıtlı kaynaktır.",
        "Plandaki ‘64 PE ≈ 64 DSP’ varsayımı doğrulanmadı; DSP kullanımı bu tasarımda ölçülen 4'tür.",
    ],
    "sekiller": {
        "S1": {"dosya": "sekiller/tr12_s1_kaynak.png", "baslik": "Post-sentez kaynak kullanımı.", "aciklama": "Her çubuk XC7A35T'deki mevcut kaynağın yüzdesidir; LUT en kısıtlı kaynaktır, DSP neredeyse kullanılmamıştır.", "genislik_cm": 12},
        "S2": {"dosya": "sekiller/tr12_s2_tahmin.png", "baslik": "Plan tahmini ve Vivado ölçümü.", "aciklama": "Gri çubuk plandaki (bölüm 6.3) tahmin, turuncu çubuk sentez sonucudur. DSP tahmini tutmadı, BRAM tahminin altında kaldı.", "genislik_cm": 12},
        "S3": {"dosya": "sekiller/tr12_s3_dagilim.png", "baslik": "LUT'ların modüllere dağılımı.", "aciklama": "Hiyerarşik rapordan; dizi (64 PE) LUT'ların çoğunu tüketir.", "genislik_cm": 12},
        "S4": {"dosya": "sekiller/tr12_s4_zamanlama.png", "baslik": "100 MHz hedefi ve sentez sonrası kritik yol.", "aciklama": "Kritik yol 10 ns hedefini aşıyor (WNS negatif); bu kaba bir tahmindir, yönlendirme gecikmeleri eklenmemiştir.", "genislik_cm": 11},
    },
    "mimari_sekilleri": [],
}
yol = os.path.join(AY, "tasarim_raporlari", "TR12_sentez.json")
json.dump(sp, open(yol, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("yazıldı:", yol)
