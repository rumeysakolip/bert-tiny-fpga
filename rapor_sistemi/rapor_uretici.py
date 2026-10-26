"""Tasarım raporu üretici (BIL 401).

Kullanım:  python rapor_uretici.py tasarim_raporlari/TR01_pe_ve_sistolik_dizi.json
Alıntı metinleri YALNIZCA literatur_kutuphanesi.json'dan okunur; rapor spesifikasyonu
alıntıyı yalnızca kimliğiyle (ör. "DF-02") çağırır, böylece metin raporlar arasında
değiştirilemez. Kütüphanede olmayan kimlik hata verir (uydurma alıntı engellenir).
Çıktı: aynı adlı .docx dosyası.
"""
import json, os, sys
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

AY = os.path.dirname(os.path.abspath(__file__))


def hucre_golge(hucre, renk):
    tcPr = hucre._tc.get_or_add_tcPr()
    sh = OxmlElement("w:shd")
    sh.set(qn("w:val"), "clear"); sh.set(qn("w:color"), "auto"); sh.set(qn("w:fill"), renk)
    tcPr.append(sh)


def tablo(doc, satirlar, genislikler=None, baslik=True):
    t = doc.add_table(rows=len(satirlar), cols=len(satirlar[0]))
    t.style = "Table Grid"
    for i, s in enumerate(satirlar):
        for j, v in enumerate(s):
            c = t.cell(i, j); c.text = ""
            p = c.paragraphs[0]; r = p.add_run(str(v)); r.font.size = Pt(9.5)
            if baslik and i == 0:
                r.bold = True; hucre_golge(c, "D9E2F3")
            if genislikler:
                c.width = Cm(genislikler[j])
    doc.add_paragraph()
    return t


def sol_cizgi(p, renk="2F5496"):
    pPr = p._p.get_or_add_pPr()
    b = OxmlElement("w:pBdr"); l = OxmlElement("w:left")
    l.set(qn("w:val"), "single"); l.set(qn("w:sz"), "18"); l.set(qn("w:space"), "8"); l.set(qn("w:color"), renk)
    b.append(l); pPr.append(b)


MIN_SEKIL = 3   # görsel-ağırlıklı kural: her rapor en az bu kadar şekil içermeli


def uret(spec_yolu):
    kut = json.load(open(os.path.join(AY, "literatur_kutuphanesi.json"), encoding="utf-8"))
    sp = json.load(open(spec_yolu, encoding="utf-8"))
    kullanilan = []
    sekil_no = {}

    def sekil_ekle(doc, sid):
        """Şekli ekler; numara ilk kullanımda verilir. Dosya yoksa hata verir (boş şekil yok)."""
        if sid not in sp.get("sekiller", {}):
            raise SystemExit(f"HATA: {sid} spec 'sekiller' içinde tanımlı değil.")
        sk = sp["sekiller"][sid]
        yol = os.path.join(AY, sk["dosya"])
        if not os.path.exists(yol):
            raise SystemExit(f"HATA: şekil dosyası yok: {yol}")
        sekil_no.setdefault(sid, len(sekil_no) + 1)
        doc.add_picture(yol, width=Cm(sk.get("genislik_cm", 15)))
        doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
        p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(f"Şekil {sekil_no[sid]}. {sk['baslik']} "); r.bold = True; r.font.size = Pt(9.5)
        r2 = p.add_run(sk["aciklama"]); r2.font.size = Pt(9.5)

    d = Document()
    for s in d.sections:
        s.left_margin = s.right_margin = Cm(2.2); s.top_margin = s.bottom_margin = Cm(2)
    st = d.styles["Normal"]; st.font.name = "Calibri"; st.font.size = Pt(11)
    st.element.rPr.rFonts.set(qn("w:eastAsia"), "Calibri")

    p = d.add_paragraph(); r = p.add_run("BİLGİSAYAR MÜHENDİSLİĞİ BÖLÜMÜ · BIL 401 Bitirme Tasarımı"); r.font.size = Pt(9); r.font.color.rgb = RGBColor(0x59, 0x59, 0x59)
    d.add_heading(f"{sp['rapor_no']} — {sp['baslik']}", 0)
    p = d.add_paragraph(); r = p.add_run(sp["alt_baslik"]); r.italic = True
    tablo(d, [["Öğrenci", "Rümeysa Kolip · 23010903093"],
              ["Danışman", "Dr. Öğr. Üyesi Emin Güney"],
              ["Proje", "FPGA Tabanlı BERT-Tiny INT8 Hızlandırıcısı"],
              ["İlgili görev", sp["gorev"]],
              ["Tarih", sp["tarih"]],
              ["Durum", sp["durum"]]], [3.5, 12.5], baslik=False)

    d.add_heading("1. Amaç ve kapsam", 1); d.add_paragraph(sp["amac"])

    d.add_heading("2. Tasarım kararları (özet)", 1)
    tablo(d, [["Konu", "Seçilen", "Alternatif", "Gerekçe"]] + sp["kararlar"], [2.4, 4.2, 3.2, 6.2])

    for sid in sp.get("mimari_sekilleri", []):
        sekil_ekle(d, sid)

    d.add_heading("3. Literatür karşılığı ve bizdeki uygulama", 1)
    d.add_paragraph("Her alt başlıkta önce kaynak makaleden alıntı (özgün dilinde, tırnak içinde, bölüm numarasıyla), "
                    "ardından bu alıntının tasarımımızda nasıl karşılık bulduğu verilmiştir.")
    for n, k in enumerate(sp["literatur"], 1):
        d.add_heading(f"3.{n} {k['konu']}", 2)
        for qid in k["alintilar"]:
            if qid not in kut["alintilar"]:
                raise SystemExit(f"HATA: {qid} kütüphanede yok — alıntı eklenmeden rapora konamaz.")
            q = kut["alintilar"][qid]; src = kut["kaynaklar"][q["kaynak"]]
            if q["kaynak"] not in kullanilan: kullanilan.append(q["kaynak"])
            p = d.add_paragraph(); r = p.add_run(f"{src['yazarlar']} ({src['yil'].split(' ')[0]}) — {src['baslik']}"); r.bold = True; r.font.size = Pt(10)
            p = d.add_paragraph(); r = p.add_run(f"Bölüm: {q['bolum']}  ·  Alıntı kimliği: {qid}"); r.font.size = Pt(9); r.font.color.rgb = RGBColor(0x59, 0x59, 0x59)
            p = d.add_paragraph(); p.paragraph_format.left_indent = Cm(1)
            r = p.add_run("“" + q["metin"] + "”"); r.italic = True
            if not q["tam_cumle"]:
                r2 = p.add_run("  [cümlenin bir parçası]"); r2.font.size = Pt(8.5); r2.font.color.rgb = RGBColor(0x7F, 0x7F, 0x7F)
            sol_cizgi(p)
        p = d.add_paragraph(); r = p.add_run("Bizde uygulama: "); r.bold = True; p.add_run(k["bizde"])
        for sid in k.get("sekil", []):
            sekil_ekle(d, sid)
        if k.get("fark"):
            p = d.add_paragraph(); r = p.add_run("Fark / dikkat: "); r.bold = True; p.add_run(k["fark"])

    d.add_heading("4. Doğrulama kanıtı", 1)
    v = sp["dogrulama"]
    d.add_paragraph(f"Araç: {v['arac']}. Kaynak kayıtlar: " + ", ".join(v["kaynak_dosyalar"]) + ".")
    tablo(d, v["tablo"], [3, 3.6, 5.6, 3.8])
    for sid in v.get("sekil", []):
        sekil_ekle(d, sid)

    d.add_heading("5. Sınırlar ve açık noktalar", 1)
    for s in sp["sinirlar"]:
        d.add_paragraph(s, style="List Bullet")

    d.add_heading("6. Kaynakça", 1)
    for a in kullanilan:
        s = kut["kaynaklar"][a]
        d.add_paragraph(f"{s['yazarlar']} ({s['yil']}). {s['baslik']}. {s['url']}" + (f"  [{s['not']}]" if s.get("not") else ""),
                        style="List Number")

    d.add_heading("Ek. Alıntı doğrulama notu", 1)
    d.add_paragraph(kut["_not"])

    if len(sekil_no) < MIN_SEKIL and not sp.get("gorsel_istisna"):
        raise SystemExit(f"HATA: rapor {len(sekil_no)} şekil içeriyor; en az {MIN_SEKIL} gerekli "
                         f"(görsel-ağırlıklı rapor kuralı). Gerekçeli istisna için spec'e 'gorsel_istisna' yazın.")
    cikis = os.path.splitext(spec_yolu)[0] + ".docx"
    d.save(cikis); print("Yazıldı:", cikis)


if __name__ == "__main__":
    uret(sys.argv[1])
