"""Konu 3, adim 4 -- 4, 6, 25, 64 token ve gercek uzunluk dagilimi icin tam cikarim cevrimi -> sim/token_atlama_sonuc.json

Calistirma:  python scripts/konu3_cevrim_tablosu.py [--sm-satir 2049] [--ln-satir 5274] [--etiket onceki]        (cwd: 03-RTL)
Parcalar ve etiketleri:
  dogrusal 12 katman : OLCULDU (benzetim, sim/nb_olcum.json: nb=1,2,4,7,8); nb=3,5,6 icin formul 53 472*nb + 1 152 (nb=2,4,7,8'de olculenle BIREBIR) -> hesap
                       nb=1 olculen deger testbench'in panel yukleme hizi (1 sozcuk/cevrim) ile sinirlidir; hesap-sinirli deger de yazilir.
  dikkat carpimlari  : HESAP (nb ile orantili: 5 056*nb + 600; nb=8'de olculen 41 048 ile ayni; nb<8 olculmedi)
  Softmax            : satir cevrimi OLCULDU (benzetim, tb_softmax, --sm-satir); satir sayisi = 4 * gecerli token (2 katman x 2 bas) -> toplam hesap
  LayerNorm          : satir cevrimi OLCULDU (--ln-satir); satir sayisi = 5 * gecerli token -> toplam hesap
Gecerli token = host'un gonderdigi satir sayisi; dogrusal ve dikkat ceil(token/8) blok uzerinden calisir.
"""
import argparse
import json
import math
import os

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
DIKKAT_BLOK, DIKKAT_SABIT = 5056, 600       # taban (Konu 1); --son ile son RTL degerleri (5120 ve 608: tile +1 cevrim)
DOG_BLOK, DOG_SABIT = 53472, 1152            # taban; son RTL: 53760 ve 1176 (nb=2,4,7,8 olcumleriyle birebir)


def js(y):
    return json.load(open(y, encoding="utf-8"))


def main():
    on = js("sim/hizlandirma_oncesi.json")["cevrim_modeli"]
    ap = argparse.ArgumentParser()
    ap.add_argument("--sm-satir", type=int, default=on["softmax_satir_cevrimi"])
    ap.add_argument("--ln-satir", type=int, default=on["layernorm_satir_cevrimi"])
    ap.add_argument("--etiket", default="onceki")
    ap.add_argument("--cikti", default="sim/token_atlama_sonuc.json")
    ap.add_argument("--son", action="store_true", help="son RTL sabitleri (Konu 6 sonrasi olcumleri) kullan")
    a = ap.parse_args()
    global DIKKAT_BLOK, DIKKAT_SABIT, DOG_BLOK, DOG_SABIT
    if a.son:
        DIKKAT_BLOK, DIKKAT_SABIT, DOG_BLOK, DOG_SABIT = 5120, 608, 53760, 1176
    nbo = js("sim/nb_olcum.json")
    olc = {int(k): v for k, v in nbo["dogrusal_12_katman_toplam_cevrim"].items()}
    assert all(abs(olc[k] - (DOG_BLOK * k + DOG_SABIT)) == 0 for k in olc if k >= 2), "formul olcumle uyusmuyor"

    def dogrusal(nb):
        return olc[nb] if nb in olc else DOG_BLOK * nb + DOG_SABIT

    def toplam(token):
        nb = math.ceil(token / 8)
        d, k = dogrusal(nb), DIKKAT_BLOK * nb + DIKKAT_SABIT
        sm, ln = a.sm_satir * 4 * token, a.ln_satir * 5 * token
        return {"token": token, "nb": nb, "dogrusal": d, "dikkat": k, "softmax": sm, "layernorm": ln, "toplam": d + k + sm + ln,
                "dogrusal_etiket": "olculdu" if nb in olc else "hesap (formul)"}

    uz = js("sim/token_uzunluk.json")
    # gercek dagilim: uzunluk_histogrami {uzunluk: cumle sayisi}
    hist = {int(k): v for k, v in uz["uzunluk_histogrami"].items()}
    n = sum(hist.values())
    ort = sum(toplam(t)["toplam"] * c for t, c in hist.items()) / n
    tam = toplam(64)
    satirlar = [toplam(t) for t in (4, 6, 25, 64)]
    sonuc = {"etiket": f"{a.etiket}: softmax {a.sm_satir} cevrim/satir, layernorm {a.ln_satir} cevrim/satir (benzetim, olculdu); toplamlar hesap",
             "tablo": satirlar,
             "dagilim_ortalamasi": {"cumle": n, "ortalama_cevrim": round(ort), "ms_100mhz_hesap": round(ort / 1e5, 3),
                                    "oran_64_token": round(ort / tam["toplam"], 4), "kat_azalma_64e_gore": round(tam["toplam"] / ort, 3)},
             "doğrusal_olcumleri": {str(k): v for k, v in olc.items()},
             "not": "nb=1 doğrusal ölçümü testbench panel yükleme hızıyla sınırlı (formül 54 624; ölçülen 63 336). "
                    "Dikkat çarpımlarında nb ölçeklemesi ölçülmedi (hesap)."}
    json.dump(sonuc, open(a.cikti, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print(a.etiket)
    for s in satirlar:
        print(f"  token {s['token']:2d} nb={s['nb']} dogrusal={s['dogrusal']:7d}({s['dogrusal_etiket']}) dikkat={s['dikkat']:6d} softmax={s['softmax']:7d} layernorm={s['layernorm']:8d} TOPLAM={s['toplam']}")
    print("  dagilim ortalamasi:", sonuc["dagilim_ortalamasi"])


if __name__ == "__main__":
    main()
