"""Konu 2 -- toplam sure modeli + UART baud/frekans tablosu -> sim/sure_modeli.json, sim/sure_modeli.csv, sim/uart_kombinasyonlari.csv

Model:  toplam sure = hesap cevrimi / frekans  +  agirlik aktarim suresi  (+ host, burada 0: olculmedi)
        aktarim suresi = bayt * 10 / baud   (8N1: bayt basina 10 bit)
Calistirma:  python scripts/sure_modeli.py [--sm-satir 2049] [--ln-satir 5274] [--cikti-oneki sim/sure_modeli] [--uart-benzetim 0|1]   (cwd: 03-RTL)
Etiketler: 'hesap' = bu betikteki formul; 'benzetim' = Icarus (tb/tb_uart_baud.v); 'olculdu' yalniz N=8 cevrim kalibrasyonunda.
Hicbir satir CPU ile kiyaslanmaz.
"""
import argparse
import csv
import itertools
import json
import math
import os
import re
import subprocess

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)

DIZILER = (4, 8, 16)
FREKANSLAR_MHZ = (100.0, 96.0, 125.0, 150.0)
BAUDLAR = (921_600, 3_000_000, 12_000_000)
AGIRLIK_BAYT = 420_700          # istem bolum 3: tum agirlik/bias/M0 tablolari (hesap, 1 KB = 1000 bayt: 921 600 baud'da 4,57 sn)
SATIR_SAYISI_SM, SATIR_SAYISI_LN = 256, 320
BIT_BAYT = 10                   # 8N1
GUVENLI_PCT, SINIR_PCT = 2.0, 4.0
DOGRUSAL = [(128, 128)] * 4 + [(128, 512), (512, 128)]       # bir kodlayici katmaninin (K, C) listesi; 2 katman
KATMAN_SAYISI = 2
DIKKAT_MATRIS = 8               # 2 katman x 2 bas x (Q.K^T + P.V); K=64, C=64
TOKEN = 64
VIVADO_TOPLAM_DSP = 90

UART_DOSYALARI = ["islem_elemani", "sistolik_dizi", "cift_kapili_bellek", "panel_tamponu", "tile_denetleyici", "yeniden_olcekle", "gelu_tablosu", "cikis_sozcuk_toplayici",
                  "dogrusal_katman", "komut_cozucu", "kontrol_birimi", "veri_yolu", "uart_alici", "uart_verici", "bert_tiny_ust", "bert_tiny_uart_ust"]


def js(yol):
    return json.load(open(yol, encoding="utf-8"))


def en_yakin_cpb(f_mhz, baud):
    """f/baud'a en yakin tam sayi (esitlikte hatasi kucuk olan); gercek baud ve yuzde hata dondurur."""
    oran = f_mhz * 1e6 / baud
    adaylar = sorted({math.floor(oran), math.ceil(oran)})
    en = min(adaylar, key=lambda c: abs(f_mhz * 1e6 / c - baud))
    gercek = f_mhz * 1e6 / en
    return en, gercek, 100.0 * (gercek - baud) / baud


def uart_durumu(hata_pct):
    h = abs(hata_pct)
    return "guvenli" if h <= GUVENLI_PCT else ("sinirda" if h <= SINIR_PCT else "calismaz")


def tb_kos(cpb, f_mhz, baud, ad="t"):
    """tb_uart_baud.v'yi verilen parametrelerle derleyip kosar; 'PASS'/'FAIL'/'DERLEME' dondurur."""
    vvp = f"sim/uart/{ad}.vvp"
    os.makedirs("sim/uart", exist_ok=True)
    kaynak = [f"rtl/{d}.v" for d in UART_DOSYALARI] + ["tb/tb_uart_baud.v"]
    r = subprocess.run(["iverilog", "-g2001", "-o", vvp, f"-Ptb_uart_baud.CPB={cpb}", f"-Ptb_uart_baud.F_MHZ={f_mhz}",
                        f"-Ptb_uart_baud.BAUD={baud}"] + kaynak, capture_output=True, text=True)
    if r.returncode:
        return "DERLEME"
    o = subprocess.run(["vvp", vvp], capture_output=True, text=True, timeout=600).stdout
    m = re.search(r"UART BAUD TEST .*?: (PASS|FAIL)", o)
    return m.group(1) if m else "BELIRSIZ"


def akis_testi(cpb, satir=3):
    """tb_bert_tiny_ust'u UART kipinde (parameter UART=1, CPB) az satirla kosar: Softmax/LayerNorm akisi gercek bit hizinda sinanir.
    Not: bu testte PC bit suresi de saat cevrimiyle uretilir; baud hatasi sinamaz, yalniz hiz/akis sinar."""
    vvp = f"sim/uart/akis{cpb}.vvp"
    dosyalar = [f"rtl/{d}.v" for d in ("islem_elemani", "sistolik_dizi", "cift_kapili_bellek", "panel_tamponu", "tile_denetleyici", "yeniden_olcekle", "gelu_tablosu",
                                       "cikis_sozcuk_toplayici", "dogrusal_katman", "komut_cozucu", "kontrol_birimi", "veri_yolu", "seri_bolucu", "softmax_birim",
                                       "layernorm_birim", "sonuc_tamponu", "bert_tiny_ust", "uart_alici", "uart_verici", "bert_tiny_uart_ust")]
    r = subprocess.run(["iverilog", "-g2001", "-o", vvp, "-Ptb_bert_tiny_ust.UART=1", f"-Ptb_bert_tiny_ust.CPB={cpb}"] + dosyalar
                       + ["tb/tb_bert_tiny_ust.v"], capture_output=True, text=True)
    if r.returncode:
        return {"clks_per_bit": cpb, "sonuc": "DERLEME"}
    o = subprocess.run(["vvp", vvp, f"+smrows={satir}", f"+lnrows={satir}"], capture_output=True, text=True, timeout=1800).stdout
    m = re.search(r"BERT_TINY_UST TEST: (PASS|FAIL) \((\d+) kontrol, (\d+) hata\)", o)
    g = re.search(r"gonderilen_bayt=(\d+)", o)
    return {"clks_per_bit": cpb, "sonuc": m.group(1) if m else "BELIRSIZ", "kontrol": int(m.group(2)) if m else None,
            "hata": int(m.group(3)) if m else None, "gonderilen_bayt": int(g.group(1)) if g else None, "satir": satir,
            "etiket": "benzetim (Icarus)"}


def tb_uart_kos(cpb):
    """Eski tb_uart.v (host bit suresi = DUT saat cevrimi): yalniz CLKS_PER_BIT mantigi, frekans/baud hatasi sinamaz."""
    vvp = "sim/uart/eski.vvp"
    kaynak = [f"rtl/{d}.v" for d in UART_DOSYALARI] + ["tb/tb_uart.v"]
    r = subprocess.run(["iverilog", "-g2001", "-o", vvp, f"-Ptb_uart.CPB={cpb}"] + kaynak, capture_output=True, text=True)
    if r.returncode:
        return "DERLEME"
    o = subprocess.run(["vvp", vvp], capture_output=True, text=True, timeout=600).stdout
    m = re.search(r"UART TEST .*?: (PASS|FAIL)", o)
    return m.group(1) if m else "BELIRSIZ"


TILE_EK = 0                      # Konu 6 sonrasi karo suresi K+2N-1+1: --tile-ek 1


def cevrim_modeli(n, sm_satir, ln_satir, kalib):
    """N x N dizi icin hesap cevrimi (hesap). Karo cevrimi = K + 2N - 1 (g20: 128+15=143, ölçülen l0_q 18392 = 18304 + 88);
    karo sayisi = ceil(64/N) * ceil(C/N). Sabit ekler N=8 olcumunden turetilir (kalib)."""
    dog = sum(math.ceil(TOKEN / n) * math.ceil(c / n) * (k + 2 * n - 1 + TILE_EK) for k, c in DOGRUSAL) * KATMAN_SAYISI + kalib["dogrusal_ek"]
    dik = DIKKAT_MATRIS * math.ceil(TOKEN / n) ** 2 * (64 + 2 * n - 1 + TILE_EK) + kalib["dikkat_ek"]
    return {"dogrusal": dog, "dikkat": dik, "softmax": sm_satir * SATIR_SAYISI_SM, "layernorm": ln_satir * SATIR_SAYISI_LN,
            "toplam": dog + dik + sm_satir * SATIR_SAYISI_SM + ln_satir * SATIR_SAYISI_LN}


def main():
    ap = argparse.ArgumentParser()
    oncesi = js("sim/hizlandirma_oncesi.json")["cevrim_modeli"]
    ap.add_argument("--sm-satir", type=int, default=oncesi["softmax_satir_cevrimi"])
    ap.add_argument("--ln-satir", type=int, default=oncesi["layernorm_satir_cevrimi"])
    ap.add_argument("--cikti-oneki", default="sim/sure_modeli")
    ap.add_argument("--uart-benzetim", type=int, default=1, help="1: UART benzetimlerini kos (yavas, ~18 dk); 0: onceki json'daki sonuclari yeniden kullan")
    ap.add_argument("--tile-ek", type=int, default=0, help="karo suresine ek cevrim (Konu 6 sonrasi 1)")
    ap.add_argument("--dog-olculen", type=int, default=None, help="olculen 12 katman doğrusal cevrim (kalibrasyon); varsayilan: hizlandirma_oncesi.json")
    ap.add_argument("--dik-olculen", type=int, default=None, help="olculen dikkat cevrimi (kalibrasyon)")
    ap.add_argument("--akis", default="", help="UART kipinde tb_bert_tiny_ust akis testi icin virgullu CLKS_PER_BIT listesi (or. 8,33)")
    a = ap.parse_args()
    onceki = js(a.cikti_oneki + ".json") if os.path.exists(a.cikti_oneki + ".json") else None

    # --- kalibrasyon: N=8 formul degeri ile olculen arasindaki fark ---
    global TILE_EK
    TILE_EK = a.tile_ek
    dog_ol = a.dog_olculen if a.dog_olculen is not None else oncesi["dogrusal_katmanlar_12"]
    dik_ol = a.dik_olculen if a.dik_olculen is not None else oncesi["dikkat_carpimlari"]
    kal0 = {"dogrusal_ek": 0, "dikkat_ek": 0}
    f8 = cevrim_modeli(8, a.sm_satir, a.ln_satir, kal0)
    kalib = {"dogrusal_ek": dog_ol - f8["dogrusal"], "dikkat_ek": dik_ol - f8["dikkat"]}
    kalib["aciklama"] = ("N=8: formul degeri ile olculen cevrim arasindaki fark (dogrusal: 12 katman, dikkat: 8 carpim) sabit ek sayilir; "
                         "N=4 ve N=16 icin OLCUM yok, yalniz formul (hesap)")
    g20 = js("sim/g20_ozet.json")
    dsp_dizi = {n: g20[str(n)]["sentez"]["DSP"] for n in DIZILER}
    tam_dsp = js("sim/hizlandirma_oncesi.json")["vivado"]["tam_sistem_bert_tiny_uart_ust"]["yerlestirme_yonlendirme"]["DSP"]
    dsp_diger = tam_dsp - dsp_dizi[8]                 # N=8 tam sistem DSP'si - dizi DSP'si (G11 birimleri + yeniden olcekleme vb.)

    # --- UART tablosu ---
    uart = []
    for f, b in itertools.product(FREKANSLAR_MHZ, BAUDLAR):
        cpb, gercek, hata = en_yakin_cpb(f, b)
        satir = {"f_mhz": f, "baud_istenen": b, "clks_per_bit": cpb, "baud_gercek": round(gercek, 1), "hata_pct": round(hata, 3),
                 "degerlendirme": uart_durumu(hata), "etiket": "hesap"}
        if a.uart_benzetim:
            satir["benzetim_tb_uart_baud"] = tb_kos(cpb, f, b)
            satir["benzetim_tb_uart_eski"] = tb_uart_kos(cpb)
            satir["benzetim_etiket"] = "benzetim (Icarus)"
        elif onceki:
            eski = next((u for u in onceki["uart"] if u["f_mhz"] == f and u["baud_istenen"] == b and u["clks_per_bit"] == cpb), None)
            if eski:
                satir.update({k: v for k, v in eski.items() if k.startswith("benzetim")})
        uart.append(satir)
    uart_durum = {(u["f_mhz"], u["baud_istenen"]): u for u in uart}

    # --- tolerans taramasi (benzetim): sapma e = (PC baud - DUT baud) / DUT baud, yuzde ---
    tolerans = []
    if a.uart_benzetim:
        for f, cpb in ((96.0, 8), (100.0, 33), (100.0, 109)):
            dut_baud = f * 1e6 / cpb
            sonuclar = {}
            for e in range(-8, 9):
                sonuclar[e] = tb_kos(cpb, f, dut_baud * (1 + e / 100.0), ad="tol")
            tolerans.append({"f_mhz": f, "clks_per_bit": cpb, "dut_baud": round(dut_baud, 1),
                             "pc_baud_sapma_pct_sonuc": sonuclar, "etiket": "benzetim (Icarus)"})
    elif onceki:
        tolerans = onceki["uart_tolerans_taramasi"]

    # --- akis testi: tb_bert_tiny_ust UART kipinde, gercek bit suresiyle (az satir) ---
    akis = onceki.get("uart_akis_testi", []) if (onceki and not a.akis) else []
    for cpb in (int(c) for c in a.akis.split(",") if c):
        akis.append(akis_testi(cpb))

    # --- sure satirlari ---
    satirlar = []
    for n, f in itertools.product(DIZILER, FREKANSLAR_MHZ):
        cm = cevrim_modeli(n, a.sm_satir, a.ln_satir, kalib)
        hesap_ms = cm["toplam"] / (f * 1e3)
        dsp = dsp_dizi[n] + dsp_diger
        sigar = dsp <= VIVADO_TOPLAM_DSP
        senaryolar = [("agirlik_cipte_varsayim", 0, None)]
        senaryolar += [(ad, by, b) for b in BAUDLAR for ad, by in (("agirlik_tablolari_420_7KB", AGIRLIK_BAYT), ("olculen_trafik_x2", None))]
        for ad, by, b in senaryolar:
            if ad == "olculen_trafik_x2":
                by = TRAFIK_X2
            akt = 0.0 if b is None else by * BIT_BAYT / b
            dur = "-" if b is None else uart_durum[(f, b)]["degerlendirme"]
            satirlar.append({"dizi": f"{n}x{n}", "f_mhz": f, "baud": b if b else "", "agirlik_senaryosu": ad, "bayt": by,
                             "hesap_cevrim": cm["toplam"], "hesap_ms": round(hesap_ms, 3), "aktarim_s": round(akt, 3),
                             "toplam_s": round(hesap_ms / 1e3 + akt, 3), "uart_degerlendirme": dur,
                             "dsp_tahmin": dsp, "kartta_sigar": "evet" if sigar else "HAYIR (DSP>90)",
                             "frekans_durumu": "olculdu (Vivado, kapandi)" if f == 100.0 and n == 8 else "senaryo (kapandigi dogrulanmadi)",
                             "etiket": "hesap"})

    cikti = {"model": "toplam sure = hesap cevrimi / frekans + agirlik aktarim suresi (host suresi 0, olculmedi); aktarim = bayt*10/baud",
             "etiket": "hesap/tahmin (tum sureler); yalniz N=8 cevrim kalibrasyonu ve 100 MHz zamanlama olculmustur",
             "parametreler": {"agirlik_bayt_420_7KB": AGIRLIK_BAYT, "olculen_trafik_x2_bayt": TRAFIK_X2,
                              "olculen_trafik_aciklama": TRAFIK_ACIKLAMA, "softmax_satir_cevrimi": a.sm_satir,
                              "layernorm_satir_cevrimi": a.ln_satir, "esikler_pct": {"guvenli": GUVENLI_PCT, "sinirda": SINIR_PCT},
                              "kalibrasyon": kalib, "dsp_dizi_sentez": dsp_dizi, "dsp_diger_N8_tam_sistem_eksi_dizi": dsp_diger},
             "bilinmeyenler": ["FT2232H/pyserial'in Windows'ta 12 Mbaud'u gercekten vermesi dogrulanmadi",
                               "paket basina USB gecikmesi (dur-ve-bekle protokolu, 602 paket/6 katman) modele katilmadi; olculmedi",
                               "host suresi (numpy, Softmax/LayerNorm/artik toplam) katilmadi",
                               "125/150 MHz'in kapanip kapanmadigi Konu 6'da belirlenir; burada yalniz senaryo"],
             "uart": uart, "uart_tolerans_taramasi": tolerans, "uart_akis_testi": akis,
             "tolerans_sapma_tanimi": "e = (PC baud - FPGA baud) / FPGA baud, yuzde; negatif: PC yavas. 'PASS' penceresi = benzetimde gecen sapmalar; "
                                      "gercek kartta FT2232H saat toleransi, kablo ve sentez/yonlendirme gecikmeleri benzetimde YOK",
             "sure": satirlar}
    json.dump(cikti, open(a.cikti_oneki + ".json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    with open(a.cikti_oneki + ".csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(satirlar[0].keys()))
        w.writeheader()
        w.writerows(satirlar)
    uart_csv = "sim/uart_kombinasyonlari.csv" if a.cikti_oneki == "sim/sure_modeli" else a.cikti_oneki + "_uart.csv"     # temel dosya yalniz temel kosuda yazilir
    with open(uart_csv, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(uart[0].keys()))
        w.writeheader()
        w.writerows(uart)
    print("yazildi:", a.cikti_oneki + ".json/.csv", uart_csv)
    for u in uart:
        print(u["f_mhz"], u["baud_istenen"], "CPB", u["clks_per_bit"], f"hata %{u['hata_pct']}", u["degerlendirme"],
              u.get("benzetim_tb_uart_baud", ""), u.get("benzetim_tb_uart_eski", ""))
    for t in tolerans:
        print("tolerans", t["f_mhz"], t["clks_per_bit"], {e: s for e, s in t["pc_baud_sapma_pct_sonuc"].items()})


# Olculen trafik: host dongusu (6 doğrusal katman, bir kodlayici katmani) gonderilen + alinan bayt, iki katmana carpilir (hesap)
_g9 = js("sim/g9_dongu_sonuc.json")
_ALINAN_L0 = 8 * sum(8 * c for c in (128, 128, 128, 128, 512, 128)) + 5 * 6        # host/g9_host_dongusu.py'deki top_alinan formulu
TRAFIK_X2 = KATMAN_SAYISI * (_g9["gonderilen_bayt"] + _ALINAN_L0)
TRAFIK_ACIKLAMA = (f"6 doğrusal katman (bir kodlayıcı katmanı): gönderilen {_g9['gonderilen_bayt']} + alınan {_ALINAN_L0} bayt "
                   "(sim/g9_dongu_sonuc.json, host döngüsü), iki katmana çarpıldı (2. katman = 1. katman varsayımı); aktivasyon ve paket başlıkları dahil, "
                   "dikkat çarpımlarının ve Softmax/LayerNorm gidiş-dönüşünün trafiği dahil değil")

if __name__ == "__main__":
    main()
