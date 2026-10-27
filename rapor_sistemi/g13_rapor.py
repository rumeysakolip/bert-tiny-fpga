"""G13 — 2. İlerleme Raporu (BIL 401) üretici. Tüm sayılar 02-RTL_Altin_Model/03_Sonuclar ve 03-RTL/sim|sentez dosyalarından okunur.
Kullanım: python rapor_sistemi/g13_rapor.py  -> rapor_sistemi/Ilerleme_Raporu_2_BIL401_30Ekim2026.docx"""
import json
import os
import re
import sys

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor

AY = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AY)
from rapor_uretici import tablo  # noqa: E402

PROJE = os.path.dirname(AY)
RTL = os.path.join(PROJE, "03-RTL")
SON = os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar")
J = lambda yol: json.load(open(yol, encoding="utf-8"))


def oku(yol, varsayilan=""):
    return open(yol, encoding="utf-8", errors="replace").read() if os.path.exists(yol) else varsayilan


g2 = J(os.path.join(SON, "tasima_kayip.json"))
g4 = J(os.path.join(RTL, "sim", "g4_sonuc.json"))
g7 = J(os.path.join(RTL, "sim", "g7_sonuc.json"))["sonuclar"]
g9 = J(os.path.join(RTL, "sim", "g9_l0_sonuc.json"))
g10 = J(os.path.join(RTL, "sim", "g10_sonuc.json"))["sonuclar"]
g1 = J(os.path.join(RTL, "sim", "g1_dogrulama.json"))
tam = g2["tam_hat"]


def sentez_ozeti():
    """Vivado post-sentez kullanım ve zamanlama özetini (varsa) okur."""
    k = oku(os.path.join(RTL, "sentez", "cikti", "hizlandirici_uart_ust_kullanim.txt"))
    z = oku(os.path.join(RTL, "sentez", "cikti", "hizlandirici_uart_ust_zamanlama.txt"))
    if not k:
        return None
    def al(ad, kalip):
        m = re.search(kalip, k)
        return m.group(1).strip() if m else "?"
    o = {"LUT": al("lut", r"\|\s*Slice LUTs\*?\s*\|\s*(\d+)"), "FF": al("ff", r"\|\s*Slice Registers\s*\|\s*(\d+)"),
         "BRAM36": al("bram", r"\|\s*Block RAM Tile\s*\|\s*([\d.]+)"), "DSP": al("dsp", r"\|\s*DSPs\s*\|\s*(\d+)")}
    m = re.search(r"WNS\(ns\).*?\n.*?\n\s*([-\d.]+)", z, re.S)
    o["WNS"] = m.group(1) if m else "?"
    return o


def main():
    d = Document()
    for s in d.sections:
        s.left_margin = s.right_margin = Cm(2.2); s.top_margin = s.bottom_margin = Cm(2)
    st = d.styles["Normal"]; st.font.name = "Calibri"; st.font.size = Pt(11)
    st.element.rPr.rFonts.set(qn("w:eastAsia"), "Calibri")

    def sekil(yol, genislik, baslik, aciklama):
        d.add_picture(os.path.join(AY, "sekiller", yol), width=Cm(genislik))
        d.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
        p = d.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(f"{baslik} "); r.bold = True; r.font.size = Pt(9.5)
        p.add_run(aciklama).font.size = Pt(9.5)

    p = d.add_paragraph(); r = p.add_run("BİLGİSAYAR MÜHENDİSLİĞİ BÖLÜMÜ · BIL 401 Bitirme Tasarımı"); r.font.size = Pt(9); r.font.color.rgb = RGBColor(0x59, 0x59, 0x59)
    d.add_heading("FPGA Tabanlı BERT-Tiny INT8 Hızlandırıcısı — 2. İlerleme Raporu", 0)
    tablo(d, [["Öğrenci", "Rümeysa Kolip · 23010903093"], ["Danışman", "Dr. Öğr. Üyesi Emin Güney"], ["Tarih", "30 Ekim 2026"],
              ["Kapsam", "Altın modelle bit-birebir doğrulanmış RTL + host↔hızlandırıcı benzetimi. Tüm sonuçlar BENZETİMDİR; kartta çalıştırma yapılmamıştır."]], [3.5, 12.5], baslik=False)

    d.add_heading("1. Özet", 1)
    gorevler = [["Görev", "Durum", "Kanıt"],
                ["G0 zemin / G1 test vektörleri", "Tamam", f"G1 bağımsız doğrulayıcı: {g1['kontrol']} kontrol, {g1['hata']} hata"],
                ["G2 tamsayı taşıma", "Tamam", f"{tam['dogru']}/{g2['n_cumle']} (FP32 {g2['fp32_dogru']}); kayıp {tam['kayip_puan_fp32e_gore']} puan"],
                ["G3 ara ölçek kalibrasyonu (512 cümle, 3 tohum)", "YAPILMADI", "Colab/HF erişimi gerektirir; açık madde"],
                ["G4 parametrik PE + 8×8 akışlı dizi", "Tamam", f"{sum(1 for s in g4['sonuclar'] if s['pass'])}/{len(g4['sonuclar'])} koşu PASS"],
                ["G5 tile denetleyici", "Tamam", "l0_q 4 cümle birikeç bit-birebir"],
                ["G6 yeniden ölçekleme", "Tamam", "7792 vektör 0 hata; 12 katmanda bit-birebir"],
                ["G7 doğrusal katman uçtan uca", "Tamam", f"{sum(1 for s in g7 if s['pass'])}/{len(g7)} katman bit-birebir (4 cümle)"],
                ["G8 GELU LUT", "Tamam", "ffn1+GELU bit-birebir (1 cümle)"],
                ["G9 host↔FPGA arabirimi", "Tamam (benzetim)", f"6 L0 katmanı PC→FPGA→PC bit-birebir; hata enjeksiyonu HATA döndü"],
                ["G10 dikkat çekirdeği", "Tamam", f"{sum(1 for s in g10 if s['pass'])}/{len(g10)} koşu bit-birebir"],
                ["G11 Softmax/LayerNorm RTL", "Tamam (bağımsız birimler, benzetim)", "Softmax 325 satır, LayerNorm 485 satır altın modelle bit-birebir, 0 hata; sistem içine BAĞLANMADI (host'ta kalıyor)"],
                ["G12 sentez", "Vivado sentez + yerleştirme-yönlendirme (bitstream yok)", "bkz. Bölüm 6"]]
    tablo(d, gorevler, [5.0, 3.5, 7.5])

    d.add_heading("2. Tam tamsayı hat doğruluğu (G2)", 1)
    d.add_paragraph(f"Birimler arası float taşıma (gömme çıkışı, artık toplamlar, Q·Kᵀ, P·V, GELU/tanh çıkışı) adım adım tamsayı yeniden ölçeklemeyle değiştirildi (altın model, M0 31 bit). "
                    f"872 cümlede tam tamsayı taşımalı hat {tam['dogru']} doğru verdi (FP32: {g2['fp32_dogru']}; kayıp {tam['kayip_puan_fp32e_gore']} puan); "
                    f"hedef ≥711, sınır ≥702, MLPerf ≥712 ({'sağlandı' if tam['mlperf_712'] else 'sağlanamadı'}). "
                    f"Taşıma float iken 717; fark {tam['dogru'] - g2['kosular']['B_float_tasima']['dogru']} cümledir. Bu fark 872 cümlelik kümede gürültüdür; üstünlük iddiası yoktur.")
    sekil("g2_s1_kumulatif.png", 14, "Şekil 1.", "Taşıma adımları kümülatif olarak tamsayıya alınırken doğru cümle sayısı.")
    sekil("g2_s3_ayrisan.png", 12, "Şekil 2.", "B(float) ile tam tamsayı hat arasında kararı değişen cümleler; karar marjini sıfıra çok yakındır.")
    d.add_paragraph("Not: yalnızca ‘artık toplam’ adımı bir cümlelik karar değişimi (3 cümle) yarattı; diğer adımlar bu ölçüde bile fark yaratmadı (31 bit M0 gerçel çarpanı fiilen birebir temsil ediyor; "
                    "yolların etkin olduğu, M0 8 bite düşürülerek ara tensörlerde fark oluştuğu görülerek doğrulandı). Kalibrasyon tek tohum/128 cümle ile yapılmıştır (G3 yapılmadı).")

    d.add_heading("3. Mimari", 1)
    sekil("tr08_s1_sistem.png", 14, "Şekil 3.", "PC (tokenizer, gömme, LN, Softmax, ağırlık paketleme) ve FPGA (INT8 matris çarpımları, yeniden ölçekleme, GELU LUT, BRAM) iş bölümü.")
    sekil("tr04_s1_tile_haritasi.png", 12, "Şekil 4.", "64×128 çıktı 8×16 tile ızgarası; panel dış, token bloğu iç döngü. Ağırlık paneli (K=128: 1 088 B) host'tan akar, aktivasyon BRAM'de yerleşiktir.")
    sekil("tr02_s2_aralik.png", 12, "Şekil 5.", "PE A girişi 9 bit işaretli: INT8 ve UINT8 (Softmax) tek PE'de; bu karar için 2021 sonrası doğrudan kaynak bulunamadı, mühendislik kararıdır.")
    sekil("tr08_s2_paket.png", 13, "Şekil 6.", "Host–FPGA paket protokolü (cmd/len/payload/CRC8; ACK/HATA/VERI).")

    d.add_heading("4. Doğrulama kanıtı", 1)
    satir = [["Modül / test", "Kapsam", "Sonuç"]]
    for s in g4["sonuclar"]:
        satir.append([s["ad"], "benzetim, altın numpy/eski modül", ("PASS — " if s["pass"] else "FAIL — ") + s["ayrinti"]])
    satir.append(["tile_denetleyici (l0_q)", "4 cümle, 64×128 birikeç", "PASS — 32768 kontrol, 0 hata"])
    satir.append(["yeniden_olcekle", "uç değer, tie, kırpma", "PASS — 7792 vektör, 0 hata"])
    for s in g7:
        satir.append([f"dogrusal_katman {s['ad']}", f"K={s['K']} C={s['C']} n={s['n']}, 4 cümle", ("PASS — " if s["pass"] else "FAIL — ") + s["ayrinti"]])
    for s in g10[:2]:
        satir.append([f"dikkat {s['ad']} ...", "Q·Kᵀ, P·V (8 koşu)", f"PASS — {s['ayrinti']} (her koşu)"])
    satir.append(["host-in-the-loop (6 L0 katmanı)", f"{g9['paket_sayisi']} paket, {g9['gonderilen_bayt']} bayt", "PASS — her katman 0 fark; bozuk CRC → HATA(CRC)"])
    tablo(d, satir, [4.6, 5.2, 6.2])
    sekil("tr03_s3_dalga.png", 14, "Şekil 7.", "N=8, K=64 ilk tile dalga formu (VCD): 78 çevrim = K + 2N − 2.")
    sekil("tr06_s2_dogrulama.png", 12, "Şekil 8.", "12 doğrusal katmanın altın çıktıyla bit-birebir doğrulaması.")

    d.add_heading("5. Çevrim sayıları (benzetim)", 1)
    l_cev = sum(s["cevrim_olculen"] for s in g7)
    a_cev = sum(s["cevrim"] for s in g10) * 1   # 4 cümlelik koşuda cümle başına; 8 koşu
    d.add_paragraph(f"12 doğrusal katman (L0+L1) toplamı {l_cev} çevrim/cümle; dikkat çekirdeği 8 koşu × ≈{g10[0]['cevrim']} = {a_cev} çevrim/cümle (Q·Kᵀ ve P·V, 2 katman × 2 baş). "
                    f"pooler ve classifier ölçülmedi. Toplam ölçülen ≈ {l_cev + a_cev} çevrim = {(l_cev + a_cev) / 100e6 * 1e3:.2f} ms @100 MHz varsayımıyla (yalnız hesap; gerçek frekans Bölüm 6'ya bağlı).")
    sekil("tr04_s5_cevrim.png", 13, "Şekil 9.", "Katman başına çevrim: teorik (K+14)·P·8 ve benzetim ölçümü.")

    d.add_heading("6. Sentez (Vivado 2025.1, xc7a35tcpg236-1, yalnızca synth_design)", 1)
    o = sentez_ozeti()
    if o:
        tablo(d, [["Kaynak", "Kullanılan", "Mevcut (XC7A35T)"], ["Slice LUT", o["LUT"], "20 800"], ["Slice FF", o["FF"], "41 600"],
                  ["BRAM36", o["BRAM36"], "50"], ["DSP48E1", o["DSP"], "90"]], [5, 4, 5])
        d.add_paragraph(f"Sentez sonrası zamanlama (100 MHz kısıtı): WNS = {o['WNS']} ns. Yerleştirme-yönlendirme sonrası (impl.tcl): 3 702 LUT, 4 219 FF, 15 BRAM, 68 DSP; setup WNS +0,721 ns, hold WHS +0,026 ns, 0 hatalı uç nokta, güç tahmini 0,170 W. Bitstream üretilmedi, kartta denenmedi; giriş/çıkış gecikmeleri kısıtlanmadı. "
                        "Plan tahmini 64 PE için ≈72 DSP idi. İlk sentezde PE çarpıcıları LUT'a eşlendi (4 DSP, 10 110 LUT, WNS −0,456 ns); PE modülüne use_dsp ipucu eklenince 64 PE çarpıcısı DSP48E1'e eşlendi (68 DSP, 3 816 LUT, WNS pozitif). RTL mantığı değişmedi; benzetim regresyonu ve sentezlenmiş dizi ağ listesi (xsim, 64 DSP) 0 hata ile geçti. Implementasyon sonrası 100 MHz karşılandı (WNS +0,721 ns).")
    else:
        d.add_paragraph("Sentez çıktıları bulunamadı (03-RTL/sentez/cikti).")

    d.add_heading("7. Performans — dürüst değerlendirme", 1)
    byte = g9["gonderilen_bayt"]
    d.add_paragraph("Hesap tarafı (benzetim çevrimi, 100 MHz varsayımıyla) milisaniye düzeyindedir; ancak ağırlıklar her çıkarımda PC'den akıtıldığından toplam süre UART'a bağlıdır: "
                    f"≈420,7 KB ağırlık/çıkarım → 921 600 baud'da ≈4,6 sn, 3 Mbaud'da ≈1,4 sn (hesap; donanımda doğrulanmadı). Önceki raporda ölçülen tek iş parçacıklı CPU çıkarımı 2,49 ms'dir; "
                    "bu mimaride PC CPU'suna göre hız kazancı BEKLENMEZ (aktarım hesaptan üç büyüklük mertebesi uzun, Şekil 10). Bu bir başarısızlık değil, edge-hızlandırıcının ölçülmüş sınırıdır; "
                    "uygun çerçeveler: çevrim/MAC verimliliği, ağırlığın kartta kalıcı saklanması (flash) ile aktarımın kalkması (ölçülmedi), daha büyük FPGA'ya ölçekleme projeksiyonu (etiketli).")
    sekil("tr04_s2_zaman.png", 13, "Şekil 10.", "Bir panel için hesap ve UART aktarım süresi (log ölçek, hesap).")

    d.add_heading("8. Sınırlar ve açık noktalar", 1)
    for s in ["Mantıksal sonuçlar benzetimdir; zamanlama Vivado implementasyonuyla (place+route) ölçüldü, kartta çalıştırma ve ölçülmüş güç yoktur.",
              "G3 (512 cümle × 3 tohum kalibrasyon) yapılmadı; ara ölçekler 128 cümle/tek tohumlu.",
              "Softmax, LayerNorm ve artık toplam FPGA'da değil, host'ta çalışır; Softmax ve LayerNorm RTL birimleri yazıldı ve altın modelle bit-birebir doğrulandı (TR10, TR11) ancak üst modüle bağlanmadı. Katmanlar altın girdileriyle ayrı doğrulandı; zincirli FPGA→host→FPGA akışı doğrulanmadı.",
              "pooler/classifier RTL'de doğrulanmadı (tek CLS token düzeni).",
              "pyserial arka ucu yazıldı, kartta denenmedi; UART yalnızca bit düzeyi benzetimde sınandı.",
              "Literatür: PE 9 bit A girişi ve PC–FPGA UART arabirimi için 2021 sonrası doğrulanmış kaynak bulunamadı; alıntıların PDF'te bölüm numarasıyla gözle doğrulanması gerekir."]:
        d.add_paragraph(s, style="List Bullet")

    d.add_heading("9. Sonraki adımlar ve danışmandan istenen kararlar", 1)
    for s in ["Okulda Basys3 ve Vivado erişimi; bitstream yükleme, USB-UART doğrulaması (FPGA'dan anlayan hocayla).",
              "Karar: Softmax/LayerNorm RTL birimleri hazır ama bağlı değil; sisteme bağlanması kapsama alınsın mı, yoksa host'ta mı kalsın?",
              "Karar: LayerNorm girdi genişliği 12 vs 16 bit (12 bit sürümün sentez verisi hazır; 16 bit sürüm sentezlenmedi).",
              "Ağırlıkları kartta kalıcı saklama (flash/BRAM) ile UART trafiğini kaldırma seçeneğinin değerlendirilmesi.",
              "G3 kalibrasyonu (Colab) ve zincirli uçtan uca benzetim."]:
        d.add_paragraph(s, style="List Bullet")

    cikis = os.path.join(AY, "Ilerleme_Raporu_2_BIL401_30Ekim2026.docx")
    d.save(cikis)
    print("Yazıldı:", cikis)


if __name__ == "__main__":
    main()
