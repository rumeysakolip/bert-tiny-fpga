"""PyTorch FP32 BERT-Tiny gecikmesini farkli token sayilarinda olcer (FPGA ile ayni token sayisinda karsilastirma icin).

Mevcut olc_islemci_gecikme.py yalniz 64 ve 8 token olcuyordu. Burada 8, 16, 24, 25, 32, 40, 48, 56, 64 token olculur (24, 32, 40, 48, 56, 64 = nb 3..8 tam bloklar); her olcum isinma turundan sonra
en az 300 tekrar; iplik sayisi 1 (onceki olcumde en hizli olan) ve 10. Girdi: ilk n belirtec, dikkat maskesi hepsi 1 (n belirteclik gercek cumle gibi).
Kullanim (cwd: 04-RTL_Komutsuz):  python scripts/olc_islemci_token.py          -> notlar/islemci_token_sonuc.json
Bilgisayarda baska agir is calismazken kos (olcum gurultulenir).
"""
import argparse
import json
import os
import platform
import subprocess
import sys
import time

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJE = os.path.dirname(KOK)
ALTIN = os.path.join(PROJE, "02-RTL_Altin_Model", "01_Kod")
MODEL_DIZIN = os.path.join(PROJE, "01-INT8_Nicemleme", "02_Girdiler", "model")
TOKENLAR = (8, 16, 24, 25, 32, 40, 48, 56, 64)


def alt_surec(iplik, tekrar):
    import numpy as np
    import torch
    sys.path.insert(0, ALTIN)
    import argparse as _ap
    import ortak
    from transformers import BertForSequenceClassification
    a = ortak.ortak_argumanlar(_ap.ArgumentParser()).parse_args([])
    _, _, _, _, ids, _, _ = ortak.yukle_hepsi(a)
    torch.set_num_threads(iplik)
    m = BertForSequenceClassification.from_pretrained(MODEL_DIZIN).eval()
    sonuc = {"iplik": iplik, "olcumler": {}}
    for n in TOKENLAR:
        ti = torch.tensor(ids[0:1, :n], dtype=torch.long)
        tm = torch.ones((1, n), dtype=torch.long)
        with torch.inference_mode():
            for _ in range(50):
                m(input_ids=ti, attention_mask=tm)
            s = []
            for _ in range(tekrar):
                t = time.perf_counter()
                m(input_ids=ti, attention_mask=tm)
                s.append((time.perf_counter() - t) * 1000.0)
        x = np.asarray(s)
        sonuc["olcumler"][str(n)] = {"tekrar": int(x.size), "ortalama_ms": float(x.mean()), "ortanca_ms": float(np.median(x)),
                                     "standart_sapma_ms": float(x.std(ddof=1)), "yuzde95_ms": float(np.percentile(x, 95)), "en_kucuk_ms": float(x.min())}
    print("SONUC_JSON " + json.dumps(sonuc))


def ana(tekrar, iplikler):
    tum = {"isletim_sistemi": platform.platform(), "tarih": time.strftime("%Y-%m-%d %H:%M"), "sonuclar": []}
    for n in iplikler:
        env = dict(os.environ, OMP_NUM_THREADS=str(n), MKL_NUM_THREADS=str(n), OPENBLAS_NUM_THREADS=str(n), PYTHONIOENCODING="utf-8")
        o = subprocess.run([sys.executable, os.path.abspath(__file__), "--alt", str(n), "--tekrar", str(tekrar)],
                           env=env, capture_output=True, text=True, encoding="utf-8", errors="replace")
        satir = [s for s in o.stdout.splitlines() if s.startswith("SONUC_JSON ")]
        if not satir:
            print(o.stdout[-2000:], o.stderr[-3000:])
            raise SystemExit("alt surec sonuc vermedi")
        r = json.loads(satir[-1][len("SONUC_JSON "):])
        tum["sonuclar"].append(r)
        print(f"--- iplik {n} ---")
        for k, v in r["olcumler"].items():
            print(f"  {k:>3s} belirtec: ortalama {v['ortalama_ms']:.3f} ms  ortanca {v['ortanca_ms']:.3f}  sapma {v['standart_sapma_ms']:.3f}  (n={v['tekrar']})")
    yol = os.path.join(KOK, "notlar", "islemci_token_sonuc.json")
    with open(yol, "w", encoding="utf-8") as f:
        json.dump(tum, f, indent=2)
    print("yazildi:", yol)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--alt", type=int, default=0)
    ap.add_argument("--tekrar", type=int, default=300)
    ap.add_argument("--iplikler", default="1,10")
    a = ap.parse_args()
    alt_surec(a.alt, a.tekrar) if a.alt else ana(a.tekrar, [int(x) for x in a.iplikler.split(",")])
