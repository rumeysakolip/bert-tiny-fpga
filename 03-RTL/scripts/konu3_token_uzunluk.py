"""Konu 3, adim 1 -- 872 cumlelik dogrulama kumesinde token uzunlugu dagilimi -> sim/token_uzunluk.json (+ sim/token_uzunluk.png)

Calistirma:  python scripts/konu3_token_uzunluk.py        (cwd: 03-RTL)
Uzunluk = dikkat maskesi toplami ([CLS] ve [SEP] dahil, 64'e kirpilmis). Altin modelin veri.py ve tokenizer'i yalniz OKUNUR.
Blok sayisi = ceil(uzunluk / 8) (token dizisi 8'lik bloklar halinde islenir; PE_SATIR=8).
Kazanc tahmini (HESAP): N=8 cevrim formulu (scripts/sure_modeli.py ile ayni) token blogu sayisina gore olceklenir; olcum degil.
"""
import json
import math
import os
import sys

import numpy as np

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJE = os.path.dirname(KOK)
sys.path.insert(0, os.path.join(PROJE, "02-RTL_Altin_Model", "01_Kod"))
from altin import veri  # noqa: E402

MODEL = os.path.join(PROJE, "01-INT8_Nicemleme", "02_Girdiler", "model")
DEV = os.path.join(PROJE, "01-INT8_Nicemleme", "02_Girdiler", "veri", "dev.tsv")
BLOK = 8
TAM_BLOK = 8                  # 64 token / 8
DOGRUSAL = [(128, 128)] * 4 + [(128, 512), (512, 128)]
KATMAN = 2


def cevrim_nb(nb, sm_satir, ln_satir, kalib, dikkat_azalir):
    """N=8, nb token blogu icin hesap cevrimi. kalib: oncesi.json'daki sabit ekler. Tam (nb=8) icin formul = scripts/sure_modeli.py N=8."""
    dog = sum(nb * math.ceil(c / 8) * (k + 15) for k, c in DOGRUSAL) * KATMAN + kalib["dogrusal_ek"]
    if dikkat_azalir:
        qk = nb * nb * (64 + 15)                         # Q.K^T: nb x nb karo, K=64 (bas boyutu)
        av = nb * 8 * (8 * nb + 15)                      # P.V: nb x 8 karo (bas boyutu 64 = 8 blok), K = gecerli anahtar sayisi
        dik = 4 * (qk + av) + kalib["dikkat_ek"]         # 2 katman x 2 bas
    else:
        dik = 8 * 64 * 79 + kalib["dikkat_ek"]
    satir = nb * BLOK
    sm = sm_satir * 4 * satir                            # 2 katman x 2 bas x gecerli satir
    ln = ln_satir * (4 * satir + satir)                  # katman basina 2 LayerNorm (4) + gomme LayerNorm (1) -> 5 x satir
    return {"dogrusal": dog, "dikkat": dik, "softmax": sm, "layernorm": ln, "toplam": dog + dik + sm + ln}


def main():
    os.chdir(KOK)
    tok = veri.tokenlayici(MODEL)
    cumle, etiket = veri.tsv_oku(DEV)
    ids, maske = veri.kodla(tok, cumle)
    uz = maske.sum(1).astype(int)
    # beklenen: maske ardisik 1'lerden ve sonra 0'lardan olusur (dolgu sonda); denetle
    ardisik = bool(all((maske[i, :uz[i]] == 1).all() and (maske[i, uz[i]:] == 0).all() for i in range(len(uz))))
    nb = np.ceil(uz / BLOK).astype(int)
    hist = {int(k): int(v) for k, v in zip(*np.unique(uz, return_counts=True))}
    nb_hist = {int(k): int(v) for k, v in zip(*np.unique(nb, return_counts=True))}
    sonuc = {
        "etiket": "olculdu (tokenizer + dev.tsv, hicbir model kosusu gerekmedi)",
        "kaynak": ["02-RTL_Altin_Model/01_Kod/altin/veri.py", "01-INT8_Nicemleme/02_Girdiler/veri/dev.tsv", "01-INT8_Nicemleme/02_Girdiler/model/tokenizer.json"],
        "cumle_sayisi": int(len(uz)),
        "uzunluk": {"ortalama": round(float(uz.mean()), 2), "medyan": float(np.median(uz)), "yuzde90": float(np.percentile(uz, 90)),
                    "yuzde99": float(np.percentile(uz, 99)), "en_kisa": int(uz.min()), "en_uzun": int(uz.max()),
                    "64e_kirpilan_cumle": int((uz >= 64).sum())},
        "dolgu_sonda_ardisik": ardisik,
        "uzunluk_histogrami": hist,
        "blok_histogrami_ceil_uzunluk_8": nb_hist,
        "blok_sayisi": {"ortalama": round(float(nb.mean()), 3), "medyan": float(np.median(nb)), "yuzde90": float(np.percentile(nb, 90)),
                        "en_uzun": int(nb.max())},
        "dolgu_orani_T64": round(float(1 - uz.sum() / (64 * len(uz))), 4),
        "blok_dolgu_orani": round(float(1 - nb.mean() / TAM_BLOK), 4),
    }
    # hesap: cumle basina cevrim, blok dagilimiyla agirlikli (sm/ln satir cevrimi hizlandirma_oncesi.json'dan)
    on = json.load(open("sim/hizlandirma_oncesi.json", encoding="utf-8"))["cevrim_modeli"]
    from importlib import util
    spec = util.spec_from_file_location("sm", os.path.join(KOK, "scripts", "sure_modeli.py"))
    kal = {"dogrusal_ek": on["dogrusal_katmanlar_12"] - sum(8 * math.ceil(c / 8) * (k + 15) for k, c in DOGRUSAL) * KATMAN,
           "dikkat_ek": on["dikkat_carpimlari"] - 8 * 64 * 79}
    tam = cevrim_nb(8, on["softmax_satir_cevrimi"], on["layernorm_satir_cevrimi"], kal, True)
    sonuc["tam_dizi_hesap_cevrim_nb8"] = tam
    sonuc["tam_dizi_hesap_not"] = ("nb=8 icin formul toplami; hizlandirma_oncesi.json'daki 2 682 200 ile ayni olmali (softmax 256 satir, layernorm 320 satir)")
    sonuc["tam_dizi_toplam_oncesi_json_ile_ayni"] = tam["toplam"] == on["toplam"]
    for ad, azalir in (("dikkat_sabit", False), ("dikkat_azalir", True)):
        dag = {}
        top = 0.0
        for b, adet in nb_hist.items():
            c = cevrim_nb(b, on["softmax_satir_cevrimi"], on["layernorm_satir_cevrimi"], kal, azalir)
            dag[int(b)] = c["toplam"]
            top += c["toplam"] * adet
        ort = top / len(uz)
        sonuc[f"hesap_{ad}"] = {"blok_basina_toplam_cevrim": dag, "cumle_basi_ortalama_cevrim": round(ort),
                                "oran_tam_dizi_toplamina": round(ort / tam["toplam"], 4),
                                "hizlanma_kat": round(tam["toplam"] / ort, 3),
                                "etiket": "hesap (olcum degil); kesin degerler adim 4'te benzetimle olculecek"}
    json.dump(sonuc, open("sim/token_uzunluk.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)

    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        fig, ax = plt.subplots(figsize=(7, 3.6))
        ax.bar(list(hist.keys()), list(hist.values()), color="#4472c4")
        for b in range(8, 65, 8):
            ax.axvline(b + 0.5, color="#c00000", lw=0.6, ls="--")
        ax.set_xlabel("token uzunluğu ([CLS] ve [SEP] dahil)")
        ax.set_ylabel("cümle sayısı")
        ax.set_title(f"SST-2 doğrulama: {len(uz)} cümle, ortalama {uz.mean():.1f}, medyan {np.median(uz):.0f}, en uzun {uz.max()}")
        fig.tight_layout()
        fig.savefig("sim/token_uzunluk.png", dpi=130)
        print("histogram: sim/token_uzunluk.png")
    except ImportError:
        print("matplotlib yok: histogram yalniz json icinde (uzunluk_histogrami)")
    print(json.dumps({k: sonuc[k] for k in ("cumle_sayisi", "uzunluk", "blok_sayisi", "dolgu_orani_T64", "blok_dolgu_orani", "dolgu_sonda_ardisik",
                                            "tam_dizi_toplam_oncesi_json_ile_ayni", "hesap_dikkat_sabit", "hesap_dikkat_azalir")}, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
