"""Konu 3, adim 2 -- altin modelde dolgu satirlari atlandiginda gecerli token ciktilarinin degismedigini gosterir -> sim/dolgu_denetimi.json

Calistirma:  python scripts/konu3_dolgu_denetimi.py [--n 872]        (cwd: 03-RTL)
Yapilandirma: "tam tamsayi hat" = Ayarlar.B_kipi(m0_bit=31, tasima_adim=TASIMA_ADIMLARI) (RTL'in bit-birebir uyduruldugu hat; 718/872).
Altin modelin kodu ve ayarlari DEGISTIRILMEZ; yalniz girdi (ids/maske) kisaltilir ya da dolgu konumlarinin ids'i degistirilir.
Denetimler:
  1. kisaltma:  her cumle icin diziyi ceil(uzunluk/8)*8 tokena kisalt (maske korunur); gecerli token satirlarinin son gizli durumu ve logit ayni mi?
  2. dolgu icerigi: dolgu konumlarina (maske=0) rastgele token kimligi yaz (maske ayni); logit ve gecerli satirlar ayni mi?
  3. dogruluk: tam / kisaltilmis kosuda dogru sayisi (872 cumle)
  4. pooler: kod incelemesi (model.py), yalniz ilk token (CLS) satiri kullanilir
"""
import argparse
import json
import os
import sys
import time

import numpy as np

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJE = os.path.dirname(KOK)
ALTIN = os.path.join(PROJE, "02-RTL_Altin_Model", "01_Kod")
sys.path.insert(0, ALTIN)
import ortak  # noqa: E402
from altin import model, veri  # noqa: E402

BLOK = 8


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=None, help="yalniz ilk n cumle (hizli deneme)")
    ap.add_argument("--yigin", type=int, default=128)
    ap.add_argument("--tohum", type=int, default=7)
    a = ap.parse_args()
    os.chdir(KOK)

    args = ortak.ortak_argumanlar(argparse.ArgumentParser()).parse_args([])
    p, _, cumleler, etiket, ids, maske, _ = ortak.yukle_hepsi(args)
    if a.n:
        ids, maske, etiket = ids[:a.n], maske[:a.n], etiket[:a.n]
    n = len(ids)
    ara = json.load(open(os.path.join(args.cikis, "ara_olcekler.json"), encoding="utf-8"))["olcekler"]
    ayar = model.Ayarlar.B_kipi(m0_bit=31, tasima_adim=model.TASIMA_ADIMLARI, izle_ara_tensor=True)
    uz = maske.sum(1).astype(int)
    nb = np.ceil(uz / BLOK).astype(int)

    def kos(ids_, maske_):
        """(B,S) -> (logit (B,2), son gizli durum (B,S,128)); tek kitle (yigin) basina yeni model."""
        m = model.AltinModel(p, ayar, ara)
        lg = m.ileri(ids_, maske_)
        return lg, np.array(m.izle["fpga.cikis"])

    def toplu(ids_, maske_, idx):
        L = ids_.shape[1]
        lg = np.zeros((len(idx), 2), np.float32)
        H = np.zeros((len(idx), L, 128), np.float32)
        for b in range(0, len(idx), a.yigin):
            s = idx[b:b + a.yigin]
            lg[b:b + a.yigin], H[b:b + a.yigin] = kos(ids_[s], maske_[s])
        return lg, H

    t0 = time.time()
    tum = np.arange(n)
    lg_tam, H_tam = toplu(ids, maske, tum)
    print(f"tam (64 token) kosu: {time.time() - t0:.0f} sn, dogru {(lg_tam.argmax(1) == etiket).sum()}/{n}")

    # --- 1. kisaltma ---
    lg_k = np.zeros_like(lg_tam)
    gecerli_farkli_cumle, gizli_farkli_cumle = 0, 0
    blok_dagilim = {}
    for b in sorted(set(nb.tolist())):
        idx = np.where(nb == b)[0]
        L = b * BLOK
        lg, H = toplu(ids[:, :L], maske[:, :L], idx)
        lg_k[idx] = lg
        blok_dagilim[int(b)] = int(len(idx))
        for j, i in enumerate(idx):
            v = uz[i]
            if not np.array_equal(H[j, :v], H_tam[i, :v]):
                gizli_farkli_cumle += 1
            if not np.array_equal(lg[j], lg_tam[i]):
                gecerli_farkli_cumle += 1
    kisaltma = {
        "blok_dagilimi_cumle_sayisi": blok_dagilim,
        "logit_farkli_cumle": int(gecerli_farkli_cumle),
        "gecerli_token_gizli_durum_farkli_cumle": int(gizli_farkli_cumle),
        "dogru_tam": int((lg_tam.argmax(1) == etiket).sum()), "dogru_kisaltilmis": int((lg_k.argmax(1) == etiket).sum()),
        "tahmin_farkli_cumle": int((lg_tam.argmax(1) != lg_k.argmax(1)).sum()),
        "maks_logit_farki": float(np.abs(lg_tam - lg_k).max()),
    }

    # --- 2. dolgu icerigi ---
    rng = np.random.default_rng(a.tohum)
    ids_r = ids.copy()
    dolgu = maske == 0
    ids_r[dolgu] = rng.integers(1000, 29000, size=int(dolgu.sum()))
    lg_r, H_r = toplu(ids_r, maske, tum)
    gizli_r = sum(0 if np.array_equal(H_r[i, :uz[i]], H_tam[i, :uz[i]]) else 1 for i in range(n))
    dolgu_icerik = {"dolgu_konumu_sayisi": int(dolgu.sum()), "logit_farkli_cumle": int((lg_r != lg_tam).any(1).sum()),
                    "gecerli_token_gizli_durum_farkli_cumle": int(gizli_r), "tohum": a.tohum}

    kaynak_satir = None
    for no, s in enumerate(open(os.path.join(ALTIN, "altin", "model.py"), encoding="utf-8"), 1):
        if "p.pooler" in s and "h[:, 0, :]" in s:
            kaynak_satir = (no, s.strip())
    sonuc = {
        "etiket": "benzetim degil; altin model (NumPy) uzerinde olculdu",
        "yapilandirma": "Ayarlar.B_kipi(m0_bit=31, tasima_adim=TASIMA_ADIMLARI) = tam tamsayi hat",
        "cumle_sayisi": int(n),
        "kisaltma": kisaltma, "dolgu_icerigi": dolgu_icerik,
        "pooler_yalniz_ilk_token": {"yontem": "kod incelemesi", "satir": kaynak_satir,
                                    "sonuc": "havuzlama yalniz h[:, 0, :] (CLS) satirini kullanir; dikkat anahtar maskesi korunur"},
        "gecti": bool(kisaltma["logit_farkli_cumle"] == 0 and kisaltma["gecerli_token_gizli_durum_farkli_cumle"] == 0
                      and dolgu_icerik["logit_farkli_cumle"] == 0 and dolgu_icerik["gecerli_token_gizli_durum_farkli_cumle"] == 0),
        "sure_sn": round(time.time() - t0),
    }
    json.dump(sonuc, open("sim/dolgu_denetimi.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print(json.dumps(sonuc, indent=1, ensure_ascii=False))


if __name__ == "__main__":
    main()
