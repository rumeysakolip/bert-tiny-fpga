"""Konu 1 -- hizlandirma calismasinin taban olcumu -> sim/hizlandirma_oncesi.json.

Calistirma:  python scripts/konu1_baslangic.py [--tb-log sim/tb_bert_tiny_ust_konu1_log.txt] [--host-log <dosya>]   (cwd: 03-RTL)
Her sayi bir kaynak dosyadan okunur; dosya adi ve etiket (benzetim / Vivado / hesap) kayda yazilir. Hicbir sayi elle girilmez.
Vivado raporlari bu betikle yeniden uretilmez: dosyalarin zaman damgasi, kaynak .v dosyalarinin son duzenlemesinden sonradir (ciktida yazilir).
"""
import argparse
import datetime
import glob
import json
import os
import re

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
CIKTI = "sentez/cikti"


def oku(yol):
    return open(yol, encoding="utf-8", errors="replace").read()


def tablo_degeri(metin, ad, sutun=0):
    """Vivado kullanim raporunda '| ad | deger | ...' satirinin sutun'uncu sayisi."""
    m = re.search(r"^\|\s*" + re.escape(ad) + r"\s*\|([^\n]*)$", metin, re.M)
    if not m:
        raise KeyError(ad)
    return float(m.group(1).split("|")[sutun].strip().replace("*", ""))


def kullanim(yol):
    t = oku(yol)
    return {"LUT": int(tablo_degeri(t, "Slice LUTs*" if "| Slice LUTs*" in t else "Slice LUTs")),
            "LUT_mantik": int(tablo_degeri(t, "LUT as Logic")),
            "LUT_bellek": int(tablo_degeri(t, "LUT as Memory")),
            "FF": int(tablo_degeri(t, "Slice Registers")),
            "BRAM_tile": tablo_degeri(t, "Block RAM Tile"),
            "DSP": int(tablo_degeri(t, "DSPs")),
            "CARRY4": int(tablo_degeri(t, "CARRY4")) if "| CARRY4" in t else None,
            "kaynak": yol}


def zamanlama(yol):
    t = oku(yol)
    # 'WNS(ns) ... ' basligini izleyen ikinci satirdaki sayilar (ozet satiri)
    bas = re.search(r"^\s*WNS\(ns\)\s+TNS\(ns\).*$", t, re.M)
    sayilar = re.findall(r"-?\d+\.\d+|\d+", t[bas.end():].splitlines()[2])
    basliklar = re.findall(r"[A-Z]+\(ns\)|TNS Failing Endpoints|TNS Total Endpoints|THS Failing Endpoints|THS Total Endpoints",
                           bas.group(0))
    d = {"WNS_ns": float(sayilar[0])}
    if "WHS(ns)" in bas.group(0):
        d["WHS_ns"] = float(sayilar[4])
    yollar = []
    blok = (r"Slack \((?:MET|VIOLATED)\) :\s+(-?[\d.]+)ns.*?\n\s*Source:\s+(\S+).*?\n\s*Destination:\s+(\S+)"
            r".*?Data Path Delay:\s+([\d.]+)ns.*?\n\s*Logic Levels:\s+(\d+)")
    for m in re.finditer(blok, t, re.S):
        yollar.append({"payi_ns": float(m.group(1)), "kaynak": m.group(2), "hedef": m.group(3),
                       "yol_gecikmesi_ns": float(m.group(4)), "mantik_seviyesi": int(m.group(5))})
    d["en_kotu_yollar"] = yollar
    d["kaynak"] = yol
    return d


def zaman_damgasi(yol):
    return datetime.datetime.fromtimestamp(os.path.getmtime(yol)).isoformat(timespec="minutes")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tb-log", default="sim/tb_bert_tiny_ust_konu1_log.txt")
    ap.add_argument("--host-log", default="")
    a = ap.parse_args()

    g11 = json.load(open("sim/g11_sonuc.json", encoding="utf-8"))
    g19 = json.load(open("sim/g19_ozet.json", encoding="utf-8"))
    sm, ln = g11["birim"]["softmax"], g11["birim"]["layernorm"]
    sm_bol, ln_bol = sm["faz_cevrimleri"]["6"], ln["faz_cevrimleri"]["8"]

    rtl_son = max(os.path.getmtime(f) for f in glob.glob("rtl/*.v"))
    impl = f"{CIKTI}/bert_tiny_uart_ust_impl_zamanlama.txt"
    cikti = {
        "etiket": "Konu 1 taban olcumu (hizlandirma oncesi)",
        "tarih": datetime.date.today().isoformat(),
        "cevrim_modeli": {
            "dogrusal_katmanlar_12": g19["rtl_cevrim"]["Doğrusal katmanlar (12, ölçüldü)"],
            "dikkat_carpimlari": g19["rtl_cevrim"]["Dikkat çarpımları (Q·Kᵀ, P·V, ölçüldü)"],
            "softmax_satir_cevrimi": sm["cevrim_maks"], "softmax_satir_sayisi": g19["satir_sayilari"]["softmax"],
            "softmax_toplam": sm["cevrim_maks"] * g19["satir_sayilari"]["softmax"],
            "layernorm_satir_cevrimi": ln["cevrim_maks"], "layernorm_satir_sayisi": g19["satir_sayilari"]["layernorm"],
            "layernorm_toplam": ln["cevrim_maks"] * g19["satir_sayilari"]["layernorm"],
            "toplam": g19["rtl_toplam_cevrim"], "ms_100mhz": g19["rtl_ms_100mhz"],
            "softmax_bolme_asamasi": sm_bol, "layernorm_bolme_asamasi": ln_bol,
            "softmax_bolme_orani": round(sm_bol / sm["cevrim_maks"], 4), "layernorm_bolme_orani": round(ln_bol / ln["cevrim_maks"], 4),
            "etiket": "Softmax ve LayerNorm satir cevrimi: benzetim (bu kosuda yeniden olculdu); toplamlar: hesap; "
                      "dogrusal ve dikkat cevrimleri g19_ozet.json'dan alindi (bu kosuda yeniden olculmedi, onceki benzetim)",
            "kaynak": ["sim/g11_sonuc.json", "sim/g19_ozet.json"],
        },
        "test_sonuclari": {
            "softmax": {k: sm[k] for k in ("sonuc", "satir", "kontrol", "hata")},
            "layernorm": {k: ln[k] for k in ("sonuc", "satir", "kontrol", "hata")},
            "mutantlar": [{k: m[k] for k in ("ad", "tanim", "sonuc", "yakalandi")} for m in g11["mutant"]],
            "etiket": "benzetim (Icarus)",
        },
        "vivado": {
            "etiket": "Vivado 2025.1, xc7a35tcpg236-1, 100 MHz kisiti",
            "tam_sistem_bert_tiny_uart_ust": {
                "yerlestirme_yonlendirme": kullanim(f"{CIKTI}/bert_tiny_uart_ust_impl_kullanim.txt"),
                "zamanlama_yerlestirme_yonlendirme": zamanlama(impl),
                "yalniz_sentez": kullanim(f"{CIKTI}/bert_tiny_uart_ust_kullanim.txt"),
                "zamanlama_yalniz_sentez": zamanlama(f"{CIKTI}/bert_tiny_uart_ust_zamanlama.txt"),
                "rapor_zaman_damgasi": zaman_damgasi(impl),
                "rtl_son_duzenleme": datetime.datetime.fromtimestamp(rtl_son).isoformat(timespec="minutes"),
            },
            "dogrusal_katman_sistemi_hizlandirici_uart_ust": {
                "yerlestirme_yonlendirme": kullanim(f"{CIKTI}/impl_kullanim.txt"),
                "zamanlama": zamanlama(f"{CIKTI}/impl_zamanlama.txt"),
                "rapor_zaman_damgasi": zaman_damgasi(f"{CIKTI}/impl_kullanim.txt"),
                "not": "komut_cozucu.v'nin Softmax/LayerNorm komutlarindan ONCEKI surumu; tam sistemle ayni RTL degil",
            },
            "softmax_birim_baglamsiz_sentez": {
                "kullanim": kullanim(f"{CIKTI}/softmax_birim_kullanim.txt"),
                "zamanlama_yalniz_sentez": zamanlama(f"{CIKTI}/softmax_birim_zamanlama.txt"),
                "not": "yalniz sentez (yerlestirme yok); WNS sentez tahmini, yonlendirmeli degil; hold raporu yok",
            },
            "layernorm_birim_baglamsiz_sentez": {
                "kullanim": kullanim(f"{CIKTI}/layernorm_birim_kullanim.txt"),
                "zamanlama_yalniz_sentez": zamanlama(f"{CIKTI}/layernorm_birim_zamanlama.txt"),
                "not": "yalniz sentez (yerlestirme yok); WNS sentez tahmini, yonlendirmeli degil; hold raporu yok",
            },
        },
    }
    if os.path.exists(a.tb_log):
        o = oku(a.tb_log)
        m = re.search(r"BERT_TINY_UST TEST: (PASS|FAIL) \((\d+) kontrol, (\d+) hata\)", o)
        cikti["test_sonuclari"]["tb_bert_tiny_ust"] = ({"sonuc": m.group(1), "kontrol": int(m.group(2)), "hata": int(m.group(3)),
                                                         "kaynak": a.tb_log, "etiket": "benzetim (Icarus)"} if m else
                                                        {"sonuc": "BELIRSIZ", "kaynak": a.tb_log})
    if a.host_log and os.path.exists(a.host_log):
        o = oku(a.host_log)
        m = re.search(r"G9 HOST-IN-THE-LOOP: (PASS|FAIL) \((\d+) katman.*?(\d+) hata\)", o)
        cikti["test_sonuclari"]["host_dongusu"] = {"sonuc": m.group(1), "katman": int(m.group(2)), "hata": int(m.group(3)),
                                                    "kaynak": a.host_log, "etiket": "benzetim (Icarus)"} if m else {"sonuc": "BELIRSIZ"}
    json.dump(cikti, open("sim/hizlandirma_oncesi.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    v = cikti["vivado"]["tam_sistem_bert_tiny_uart_ust"]
    print("yazildi: sim/hizlandirma_oncesi.json")
    print("tam sistem:", v["yerlestirme_yonlendirme"]["LUT"], "LUT,", v["yerlestirme_yonlendirme"]["FF"], "FF,",
          v["yerlestirme_yonlendirme"]["DSP"], "DSP,", v["yerlestirme_yonlendirme"]["BRAM_tile"], "BRAM | WNS",
          v["zamanlama_yerlestirme_yonlendirme"]["WNS_ns"], "WHS", v["zamanlama_yerlestirme_yonlendirme"]["WHS_ns"])
    print("rapor", v["rapor_zaman_damgasi"], "| rtl son duzenleme", v["rtl_son_duzenleme"])


if __name__ == "__main__":
    main()
