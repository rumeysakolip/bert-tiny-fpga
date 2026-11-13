"""G13 -- bert_tiny_ust testbench'inin mutant denetimi: komut_cozucu, kontrol_birimi ve veri_yolu'nda kasitli bozulma, tb_bert_tiny_ust'un FAIL vermesi beklenir.

Calistirma:  python scripts/kos_g13_mutant.py      (cwd: 03-RTL)   -> sim/g13_mutant.json
Her mutant 'sim/mutant/g13_*.v' olarak yazilir; asil rtl/ dosyalarina dokunulmaz. Satir sayisi sinirlidir (+smrows/+lnrows).
"""
import json
import os
import re
import subprocess
import sys

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
RTL = ["islem_elemani", "sistolik_dizi", "cift_kapili_bellek", "panel_tamponu", "tile_denetleyici", "yeniden_olcekle", "gelu_tablosu", "cikis_sozcuk_toplayici",
       "dogrusal_katman", "komut_cozucu", "kontrol_birimi", "veri_yolu", "seri_bolucu", "ters_bolucu", "softmax_birim", "layernorm_birim",
       "sonuc_tamponu", "bert_tiny_ust"]
# (ad, bozulan dosya, eski metin, yeni metin, tanim)
MUTANT = [
    ("m1", "veri_yolu", "softmax_giris_maske <= sozcuk_sonraki[32];", "softmax_giris_maske <= 1'b1;", "Softmax maske bayti yok sayildi"),
    ("m2", "kontrol_birimi", "softmax_iptal    <= tamam & komut_softmax_baslat;", "softmax_iptal    <= 1'b0;", "SOFTMAX_BASLAT iptal vermiyor (kurtarma testi yakalamali)"),
    ("m3", "komut_cozucu", "alan_layernorm_kaydirma  = baslik_yazmaci[77:72];", "alan_layernorm_kaydirma  = baslik_yazmaci[76:72];", "LAYERNORM_AYAR kaydirma alani bir bit eksik"),
    ("m4", "komut_cozucu", "alan_softmax_m0          = baslik_yazmaci[23:0];", "alan_softmax_m0          = baslik_yazmaci[22:0];", "SOFTMAX_AYAR m0 alani bir bit eksik"),
    ("m5", "veri_yolu", "yanit_kaydi_turu <= 2'd2; yanit_kaydi_kaynak <= 2'd2;", "yanit_kaydi_turu <= 2'd2; yanit_kaydi_kaynak <= 2'd1;", "LAYERNORM_OKU yanlis tampondan okuyor"),
    ("m6", "kontrol_birimi", "else if (!crc_dogru) begin yanit_hata_yukle = 1'b1; yanit_hata_kodu = 8'd1;", "else if (!crc_dogru) begin yanit_hata_yukle = 1'b1; yanit_hata_kodu = 8'd9;", "CRC hata kodu yanlis"),
    ("m7", "veri_yolu", "sozcuk_bayt_sirasi <= sozcuk_bayt_sirasi + 4'd1; end\n            if (sozcuk_yaz)", "sozcuk_bayt_sirasi <= sozcuk_bayt_sirasi + 4'd2; end\n            if (sozcuk_yaz)", "sozcuk bayt sirasi 2 artiyor"),
]


def kos(ad, degisen):
    """degisen: {modul_adi: dosya_yolu}; belirtilmeyen moduller rtl/'den alinir."""
    kaynak = [degisen.get(f, f"rtl/{f}.v") for f in RTL] + ["tb/tb_bert_tiny_ust.v"]
    vvp = f"sim/mutant/g13_{ad}.vvp"
    r = subprocess.run(["iverilog", "-g2001", "-o", vvp] + kaynak, capture_output=True, text=True)
    if r.returncode:
        return "DERLEME", r.stderr[-300:]
    o = subprocess.run(["vvp", vvp, "+smrows=6", "+lnrows=6"], capture_output=True, text=True, timeout=1800).stdout
    m = re.search(r"BERT_TINY_UST TEST: (PASS|FAIL) \((\d+) kontrol, (\d+) hata\)", o)
    return (m.group(1), int(m.group(3))) if m else ("BELIRSIZ", o[-300:])


def main():
    os.makedirs("sim/mutant", exist_ok=True)
    sonuc = []
    s0, h0 = kos("temel", {})
    print(f"temel (mutantsiz): {s0} ({h0} hata)")
    for ad, dosya, eski, yeni, tanim in MUTANT:
        kaynak = open(f"rtl/{dosya}.v", encoding="utf-8").read()
        assert kaynak.count(eski) == 1, ad
        yol = f"sim/mutant/g13_{ad}.v"
        open(yol, "w", encoding="utf-8").write(kaynak.replace(eski, yeni))
        s, h = kos(ad, {dosya: yol})
        sonuc.append({"ad": ad, "dosya": dosya, "tanim": tanim, "sonuc": s, "hata": h, "yakalandi": s == "FAIL"})
        print(f"mutant {ad}: {s} ({h} hata)  -- {dosya}: {tanim}")
    json.dump({"temel": s0, "mutant": sonuc}, open("sim/g13_mutant.json", "w"), indent=1)
    kacan = [m["ad"] for m in sonuc if not m["yakalandi"]]
    ok = s0 == "PASS" and not kacan
    print("G13 MUTANT TOPLAM:", "PASS" if ok else "FAIL", "| kacan mutant:", kacan)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
