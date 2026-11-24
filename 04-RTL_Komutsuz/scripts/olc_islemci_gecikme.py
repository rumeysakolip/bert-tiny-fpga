"""Bilgisayar işlemcisinde tek cümlelik çıkarım gecikmesini ölçer (araştırma sorusu 4 için karşılaştırma tabanı).

Ölçülenler (her biri ısınma turundan sonra, en az 200 tekrarla; ortalama, standart sapma, ortanca ve %95'lik değer):
  1) PyTorch kayan noktalı (FP32) BERT-Tiny, gerçek ağırlıklarla, 64 belirteç (dolgulu) ve 8 belirteç
  2) Altın model, kayan noktalı kip (NumPy)
  3) Altın model, sekiz bitlik tamsayı donanım-sadık kip (B kipi, NumPy)
Her ölçüm iplik sayıları 1, 10 (fiziksel çekirdek) ve tüm mantıksal iplik için ayrı bir alt süreçte yapılır (iplik sayısı
bellek kütüphanelerinin ortam değişkenleriyle sınırlanır).

Not: Eski betik (arsiv/eski_calismalar/.../hesap_yuku_analizi.py) rastgele ağırlıkla ve yalnız PyTorch ile ölçüyordu; ona dokunulmadı.
Kullanım (cwd: 04-RTL_Komutsuz):  python scripts/olc_islemci_gecikme.py            -> notlar/islemci_gecikme_sonuc.json
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


def istatistik(sureler):
    import numpy as np
    a = np.asarray(sureler, dtype=np.float64)
    return {"tekrar": int(a.size), "ortalama_ms": float(a.mean()), "standart_sapma_ms": float(a.std(ddof=1)),
            "ortanca_ms": float(np.median(a)), "yuzde95_ms": float(np.percentile(a, 95)), "en_kucuk_ms": float(a.min())}


def olc(fn, tekrar, isinma):
    for _ in range(isinma):
        fn()
    s = []
    for _ in range(tekrar):
        t = time.perf_counter()
        fn()
        s.append((time.perf_counter() - t) * 1000.0)
    return istatistik(s)


def alt_surec(iplik, tekrar, golden_tekrar):
    """Tek bir iplik sayısı için tüm ölçümleri yapar ve sonucu tek satır JSON olarak yazar."""
    import numpy as np
    sonuc = {"iplik": iplik, "olcumler": {}}
    sys.path.insert(0, ALTIN)
    import argparse as _ap
    import ortak
    a = ortak.ortak_argumanlar(_ap.ArgumentParser()).parse_args([])
    p, tok, cumleler, etiketler, ids, maske, y = ortak.yukle_hepsi(a)
    ids1, maske1 = ids[0:1], maske[0:1]
    sonuc["ornek_cumle_belirtec_sayisi"] = int(maske1.sum())

    # 1) PyTorch FP32
    import torch
    from transformers import BertForSequenceClassification
    torch.set_num_threads(iplik)
    m = BertForSequenceClassification.from_pretrained(MODEL_DIZIN).eval()
    for S in (64, 8):
        ti = torch.tensor(ids1[:, :S], dtype=torch.long)
        tm = torch.tensor(maske1[:, :S] if S == 64 else np.ones((1, S), dtype=np.int64), dtype=torch.long)
        with torch.inference_mode():
            cik = m(input_ids=ti, attention_mask=tm).logits
            sonuc["olcumler"][f"pytorch_fp32_{S}_belirtec"] = olc(lambda: m(input_ids=ti, attention_mask=tm), tekrar, 30)
            sonuc["olcumler"][f"pytorch_fp32_{S}_belirtec"]["ilk_cikis_puanlari"] = [float(v) for v in cik[0]]

    # 2) ve 3) altın model (NumPy)
    from altin import model
    with open(os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar", "ara_olcekler.json"), encoding="utf-8") as f:
        ara = json.load(f)["olcekler"]
    mf = model.AltinModel(p, model.Ayarlar(kip="fp32"))
    mb = model.AltinModel(p, model.Ayarlar.B_kipi(), ara)
    cf = mf.ileri(ids1, maske1)
    cb = mb.ileri(ids1, maske1)
    r = olc(lambda: mf.ileri(ids1, maske1), golden_tekrar, 5)
    r["ilk_cikis_puanlari"] = [float(v) for v in cf[0]]
    sonuc["olcumler"]["altin_kayan_nokta_64_belirtec"] = r
    r = olc(lambda: mb.ileri(ids1, maske1), golden_tekrar, 5)
    r["ilk_cikis_puanlari"] = [float(v) for v in cb[0]]
    sonuc["olcumler"]["altin_tamsayi_b_kipi_64_belirtec"] = r
    sonuc["surumler"] = {"python": sys.version.split()[0], "numpy": np.__version__, "torch": torch.__version__,
                         "torch_iplik": torch.get_num_threads()}
    print("SONUC_JSON " + json.dumps(sonuc, ensure_ascii=False))


def ana(tekrar, golden_tekrar, iplikler):
    cpu = subprocess.run(["powershell", "-NoProfile", "-Command",
                          "Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | ConvertTo-Json"],
                         capture_output=True, text=True, encoding="utf-8").stdout
    guc = subprocess.run(["powercfg", "/getactivescheme"], capture_output=True, text=True, encoding="utf-8", errors="replace").stdout.strip()
    cpu_j = json.loads(cpu)
    tum = {"islemci": cpu_j, "guc_plani": guc, "isletim_sistemi": platform.platform(), "tarih": time.strftime("%Y-%m-%d %H:%M"), "sonuclar": []}
    for n in iplikler:
        env = dict(os.environ, OMP_NUM_THREADS=str(n), MKL_NUM_THREADS=str(n), OPENBLAS_NUM_THREADS=str(n),
                   NUMEXPR_NUM_THREADS=str(n), PYTHONIOENCODING="utf-8")
        print(f"--- iplik sayisi {n} ---", flush=True)
        t = time.time()
        o = subprocess.run([sys.executable, os.path.abspath(__file__), "--alt", str(n), "--tekrar", str(tekrar), "--golden_tekrar", str(golden_tekrar)],
                           env=env, capture_output=True, text=True, encoding="utf-8", errors="replace")
        satir = [s for s in o.stdout.splitlines() if s.startswith("SONUC_JSON ")]
        if not satir:
            print(o.stdout[-2000:], o.stderr[-3000:])
            raise SystemExit("alt surec sonuc vermedi")
        r = json.loads(satir[-1][len("SONUC_JSON "):])
        r["sure_sn"] = round(time.time() - t, 1)
        tum["sonuclar"].append(r)
        for ad, v in r["olcumler"].items():
            print(f"  {ad:42s} ortalama {v['ortalama_ms']:9.3f} ms  sapma {v['standart_sapma_ms']:7.3f}  ortanca {v['ortanca_ms']:9.3f}  (n={v['tekrar']})", flush=True)
    yol = os.path.join(KOK, "notlar", "islemci_gecikme_sonuc.json")
    with open(yol, "w", encoding="utf-8") as f:
        json.dump(tum, f, ensure_ascii=False, indent=2)
    print("yazildi:", yol)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--alt", type=int, default=0, help="(dahili) alt surec: iplik sayisi")
    ap.add_argument("--tekrar", type=int, default=300)
    ap.add_argument("--golden_tekrar", type=int, default=200)
    ap.add_argument("--iplikler", default="1,10,16")
    a = ap.parse_args()
    if a.alt:
        alt_surec(a.alt, a.tekrar, a.golden_tekrar)
    else:
        ana(a.tekrar, a.golden_tekrar, [int(x) for x in a.iplikler.split(",")])
