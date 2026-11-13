"""Konu 5 -- LayerNorm 12 mi 16 bit mi: karar tablosu -> sim/layernorm_bit_karari.json

Calistirma:  python scripts/konu5_karar.py        (cwd: 03-RTL)
Girdiler (hicbir sayi elle girilmez):
  dogruluk : sim/layernorm_bit_dogruluk.json   (scripts/konu5_ln_bit.py; altin model, 872 cumle)
  alan     : sentez/cikti/konu5_g12_*, konu5_g16_*   (sentez/konu5_sentez.tcl; Vivado, bagimsiz sentez, 100 MHz, YALNIZ sentez)
Karar Rumeysa'ya aittir; bu dosya tablo ve gerekceli oneridir, RTL varsayilani (G=12) DEGISTIRILMEZ.
"""
import importlib.util
import json
import os

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
spec = importlib.util.spec_from_file_location("k1", os.path.join(KOK, "scripts", "konu1_baslangic.py"))
k1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(k1)


def main():
    dogr = json.load(open("sim/layernorm_bit_dogruluk.json", encoding="utf-8"))
    kosu = dogr["kosular"]
    alan = {}
    for g in (12, 16):
        u = k1.kullanim(f"sentez/cikti/konu5_g{g}_layernorm_birim_kullanim.txt")
        z = k1.zamanlama(f"sentez/cikti/konu5_g{g}_layernorm_birim_zamanlama.txt")
        alan[g] = {"LUT": u["LUT"], "LUT_bellek": u["LUT_bellek"], "FF": u["FF"], "DSP": u["DSP"], "BRAM_tile": u["BRAM_tile"],
                   "CARRY4": u["CARRY4"], "WNS_ns": z["WNS_ns"], "kaynak": u["kaynak"]}
    d12, d16 = kosu["g12_ln12 (varsayilan)"], kosu["g16_ln12"]
    fark = {k: alan[16][k] - alan[12][k] for k in ("LUT", "LUT_bellek", "FF", "DSP", "BRAM_tile", "CARRY4")}
    fark["WNS_ns"] = round(alan[16]["WNS_ns"] - alan[12]["WNS_ns"], 3)
    cikti = {
        "etiket": "dogruluk: altin model (NumPy); alan ve WNS: Vivado bagimsiz SENTEZ (yerlestirme yok), 100 MHz. G=16 RTL surumu benzetimde dogrulanmadi.",
        "karar_sahibi": "Rumeysa Kolip",
        "tablo": [
            {"secenek": "g_bit=12 (RTL varsayilani, G=12)", "dogru_872": d12["dogru"], "varsayilandan_ayrisan_cumle": 0, **{"alan": alan[12]}},
            {"secenek": "g_bit=16 (G=16)", "dogru_872": d16["dogru"], "varsayilandan_ayrisan_cumle": d16["varsayilandan_ayrisan_cumle"],
             "dogruyken_yanlis_yanlisken_dogru": d16["varsayilanla_dogru_yanlis_degisen"], "alan": alan[16]},
        ],
        "g16_eksi_g12_alan": fark,
        "ek_ln_bit_dogruluk": {ad: {"dogru": k["dogru"], "ayrisan_cumle": k["varsayilandan_ayrisan_cumle"]}
                               for ad, k in kosu.items() if "ln16" in ad},
        "gecersiz_koşu_uyarisi": dogr.get("not"),
        "gurultu_kurali": dogr["gurultu_kurali"],
        "oneri": ("g_bit=12'de kal. Doğruluk 718/872 ile 718/872 (iki cümle fark, bir cümle doğrudan yanlışa, biri yanlıştan doğruya: gürültü), "
                  "yani 16 bitin doğruluk kazancı yok. 16 bit, gamma 20 bit ve çarpma zinciri 74 bit olduğundan sentezde LUT, FF ve DSP artar, zamanlama payı düşer; "
                  "ayrıca altın modelin int64 ara çarpımı g_bit=16'da taşar (35 çağrıda), yani 16 bit seçilirse altın modelin de geniş tamsayıya geçmesi gerekir. "
                  "Karar Rümeysa'nındır."),
    }
    json.dump(cikti, open("sim/layernorm_bit_karari.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print(json.dumps({"tablo": [(t["secenek"], t["dogru_872"], t["alan"]["LUT"], t["alan"]["FF"], t["alan"]["DSP"], t["alan"]["WNS_ns"]) for t in cikti["tablo"]],
                      "fark": fark, "ln16": cikti["ek_ln_bit_dogruluk"]}, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
