"""Konu 8 -- birlesik sonuc tablosu: sim/hizlandirma_sonrasi.json, sim/etki_tablosu.csv, g19_ozet.json'a 'onceki' alanlari

Calistirma:  python scripts/konu8_birlesik.py        (cwd: 03-RTL)   [once: kos_g7/kos_g10/kos_g11, kos_konu3_nb, Vivado kosulari]
Her sayi bir kaynak dosyadan okunur. Etiketler: benzetim (Icarus), Vivado (rapor dosyasi), hesap (formul).
Hicbir satir CPU ile kiyaslanmaz.
"""
import csv
import importlib.util
import json
import os
import re

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
spec = importlib.util.spec_from_file_location("k1", os.path.join(KOK, "scripts", "konu1_baslangic.py"))
k1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(k1)
C = "sentez/cikti"


def js(y):
    return json.load(open(y, encoding="utf-8"))


def vivado(etiket):
    """sentez/cikti/<etiket>_* raporlarindan kaynak ve zamanlama."""
    u = k1.kullanim(f"{C}/{etiket}_kullanim.txt")
    z = k1.zamanlama(f"{C}/{etiket}_zamanlama.txt")
    t = open(f"{C}/{etiket}_zamanlama.txt", encoding="utf-8", errors="replace").read()
    kapandi = "All user specified timing constraints are met" in t
    m = re.search(r"^\s*-?\d+\.\d+\s+(-?\d+\.\d+)\s+(\d+)\s+\d+", t[t.index("WNS(ns)"):], re.M)
    return {"LUT": u["LUT"], "LUT_bellek": u["LUT_bellek"], "FF": u["FF"], "DSP": u["DSP"], "BRAM_tile": u["BRAM_tile"],
            "WNS_ns": z["WNS_ns"], "WHS_ns": z.get("WHS_ns"), "TNS_ns": float(m.group(1)) if m else None,
            "basarisiz_uc_nokta": int(m.group(2)) if m else None, "kisitlar_saglandi": kapandi, "kaynak": f"{C}/{etiket}_*.txt"}


def main():
    on = js("sim/hizlandirma_oncesi.json")
    g19 = js("sim/g19_ozet.json")
    g19_on = js("sim/g19_ozet_onceki.json")
    g11 = js("sim/g11_sonuc.json")
    nb = js("sim/nb_olcum.json")
    uz = js("sim/token_uzunluk.json")
    karar = js("sim/layernorm_bit_karari.json")
    sm_satir, ln_satir = g11["birim"]["softmax"]["cevrim_maks"], g11["birim"]["layernorm"]["cevrim_maks"]
    cev = g19["rtl_cevrim"]
    toplam = g19["rtl_toplam_cevrim"]
    steps = {
        "100MHz_1grup": "konu6a_p10", "125MHz_karekok_oncesi": "konu6b_p8", "125MHz": "konu6c_p8", "125MHz_MMCM": "konu6f_mmcm125",
        "150MHz_ilk": "konu6d_p6_67", "150MHz": "konu6i_p6_67",
    }
    for e in ("konu6j_p5_71", "konu6k_mmcm150"):
        if os.path.exists(f"{C}/{e}_zamanlama.txt"):
            steps[{"konu6j_p5_71": "175MHz_5_71ns", "konu6k_mmcm150": "150MHz_MMCM"}[e]] = e
    basamaklar = {ad: vivado(e) for ad, e in steps.items()}

    sonra = {
        "etiket": "Konu 1-8 sonrasi (hizlandirma sonrasi); onceki degerler hizlandirma_oncesi.json",
        "tarih": "2026-11-02",
        "cevrim_modeli": {
            "dogrusal_12_katman": cev["Doğrusal katmanlar (12, ölçüldü)"],
            "dikkat_carpimlari": cev["Dikkat çarpımları (Q·Kᵀ, P·V, ölçüldü)"],
            "softmax_satir_cevrimi": sm_satir, "softmax_toplam": cev["Softmax birimi (hesap)"],
            "layernorm_satir_cevrimi": ln_satir, "layernorm_toplam": cev["LayerNorm birimi (hesap)"],
            "toplam": toplam, "ms_100mhz": g19["rtl_ms_100mhz"], "ms_125mhz": round(toplam / 125e3, 3), "ms_150mhz": round(toplam / 150e3, 3),
            "onceki_toplam": on["cevrim_modeli"]["toplam"], "onceki_ms_100mhz": on["cevrim_modeli"]["ms_100mhz"],
            "etiket": "dogrusal ve dikkat: olculdu (benzetim, G7, G10); Softmax ve LayerNorm: satir cevrimi olculdu, toplam hesap (satir sayisi 256 ve 320); "
                      "ms degerleri hesap (cevrim / frekans); 125 ve 150 MHz yalniz Vivado'da kapandi, kartta denenmedi",
            "kaynak": ["sim/g19_ozet.json", "sim/g11_sonuc.json", "sim/konu6h_g7_sonuc.json", "sim/g10_sonuc.json"]},
        "dogrusal_nb_olcumleri": {"katman_cevrimi_nb": nb["katman_cevrimi_nb"], "toplam_12_katman": nb["dogrusal_12_katman_toplam_cevrim"], "kaynak": "sim/nb_olcum.json"},
        "token_dagilimi": {"ortalama": uz["uzunluk"]["ortalama"], "medyan": uz["uzunluk"]["medyan"], "yuzde90": uz["uzunluk"]["yuzde90"],
                           "en_uzun": uz["uzunluk"]["en_uzun"], "blok_ortalama": uz["blok_sayisi"]["ortalama"], "kaynak": "sim/token_uzunluk.json"},
        "vivado_basamaklar": basamaklar,
        "layernorm_bit_karari": karar["oneri"],
    }
    json.dump(sonra, open("sim/hizlandirma_sonrasi.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)

    # g19_ozet.json'a onceki alanlari ekle (yan yana)
    g19["rtl_cevrim_onceki"] = g19_on["rtl_cevrim"]
    g19["rtl_toplam_cevrim_onceki"] = g19_on["rtl_toplam_cevrim"]
    g19["rtl_ms_100mhz_onceki"] = g19_on["rtl_ms_100mhz"]
    g19["onceki_not"] = "onceki: Konu 1 tabani (2 Kasim 2026, hizlandirma oncesi), sim/g19_ozet_onceki.json"
    json.dump(g19, open("sim/g19_ozet.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)

    # konu basina etki tablosu
    b100, b125, b150 = basamaklar["100MHz_1grup"], basamaklar["125MHz"], basamaklar["150MHz"]
    onc = on["vivado"]["tam_sistem_bert_tiny_uart_ust"]
    onc_k = onc["yerlestirme_yonlendirme"]
    onc_z = onc["zamanlama_yerlestirme_yonlendirme"]
    satirlar = [
        ("Konu 2", "UART baud/saat tablosu", "921 600 baud: CLKS_PER_BIT=109, 4,565 sn (420,7 KB)", "12 Mbaud @96 MHz: CLKS_PER_BIT=8 hata %0; 0,351 sn", "tb_uart_baud (benzetim), sure_modeli (hesap)", "benzetim / hesap"),
        ("Konu 3", "Doğrusal çevrim, 25 token (4 blok)", f"{on['cevrim_modeli']['dogrusal_katmanlar_12']}", f"{nb['dogrusal_12_katman_toplam_cevrim']['4']}", "tb_katman +NBE (cfg_nb), kos_konu3_nb", "benzetim"),
        ("Konu 4a", "Softmax çevrim/satır", f"{on['cevrim_modeli']['softmax_satir_cevrimi']}", f"{sm_satir}", "tb_softmax (son girişten son çıkışa)", "benzetim"),
        ("Konu 4a", "LayerNorm çevrim/satır", f"{on['cevrim_modeli']['layernorm_satir_cevrimi']}", f"{ln_satir}", "tb_layernorm", "benzetim"),
        ("Konu 4a", "Tam sistem DSP", f"{onc_k['DSP']}", f"{basamaklar['100MHz_1grup']['DSP']}", "Vivado yerleştirme+yönlendirme", "Vivado"),
        ("Konu 4b+6", "Tam sistem LUT (100 MHz)", f"{onc_k['LUT']}", f"{b100['LUT']}", "Vivado (4b: tablolar BRAM; 6: panel tamponu BRAM; ayrı ayrı notlarda)", "Vivado"),
        ("Konu 4b+6", "Tam sistem LUT-bellek", f"{onc_k['LUT_bellek']}", f"{b100['LUT_bellek']}", "Vivado", "Vivado"),
        ("Konu 4b+6", "Tam sistem BRAM (karo)", f"{onc_k['BRAM_tile']}", f"{b100['BRAM_tile']}", "Vivado", "Vivado"),
        ("Konu 6", "Tam sistem WNS/hold @100 MHz", f"{onc_z['WNS_ns']} / {onc_z['WHS_ns']} ns", f"{b100['WNS_ns']} / {b100['WHS_ns']} ns", "Vivado (1. grup düzeltmeler)", "Vivado"),
        ("Konu 6", "125 MHz (8 ns)", "kapanmıyordu (denenmedi)", f"WNS {b125['WNS_ns']} / hold {b125['WHS_ns']} ns, kısıtlar sağlandı", "Vivado", "Vivado"),
        ("Konu 6", "150 MHz (6,67 ns)", "kapanmıyordu (denenmedi)", f"WNS {b150['WNS_ns']} / hold {b150['WHS_ns']} ns, kısıtlar sağlandı", "Vivado", "Vivado"),
        ("Konu 8", "Toplam çevrim, 64 token", f"{on['cevrim_modeli']['toplam']}", f"{toplam}", "doğrusal+dikkat ölçüldü, Softmax/LN satır ölçüldü × satır sayısı", "hesap"),
        ("Konu 8", "Toplam süre @100 MHz", f"{on['cevrim_modeli']['ms_100mhz']} ms", f"{g19['rtl_ms_100mhz']:.3f} ms", "çevrim ÷ frekans", "hesap"),
        ("Konu 8", "Toplam süre @150 MHz", "-", f"{toplam / 150e3:.3f} ms", "çevrim ÷ frekans (150 MHz yalnız Vivado'da kapandı)", "hesap"),
    ]
    with open("sim/etki_tablosu.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["konu", "degisen_kalem", "once", "sonra", "olcum_yontemi", "etiket"])
        w.writerows(satirlar)
    print("yazildi: sim/hizlandirma_sonrasi.json, sim/etki_tablosu.csv, sim/g19_ozet.json (onceki alanlar)")
    for ad, v in basamaklar.items():
        print(f"  {ad:24s} LUT {v['LUT']} FF {v['FF']} DSP {v['DSP']} BRAM {v['BRAM_tile']} | WNS {v['WNS_ns']} hold {v['WHS_ns']} TNS {v['TNS_ns']} "
              f"basarisiz {v['basarisiz_uc_nokta']} kapandi {v['kisitlar_saglandi']}")


if __name__ == "__main__":
    main()
