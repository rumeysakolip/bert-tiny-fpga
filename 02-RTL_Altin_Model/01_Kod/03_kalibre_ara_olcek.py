"""K1 — Ara tensör ölçeklerini kalibre et (B-kipinin girdisi).

PTQ yalnızca 14 Linear katmanın GİRDİ ölçeğini kalibre etmişti. Tamsayı-only
veri yolu için bunlara ek olarak şu tensörlerin ölçeği gerekir:

    * her Linear'ın ÇIKIŞI          (yeniden ölçekleme hedefi)
    * her LayerNorm'un girdisi/çıkışı
    * dikkat skorları (softmax girdisi)
    * GELU çıkışı, pooler tanh çıkışı

Ölçek, kalibrasyon kümesindeki mutlak en büyük değerden türetilir:
    olcek = max|x| / 127          (simetrik, PTQ ile aynı kural)

Kalibrasyon verisi EĞİTİM kümesinden alınır — doğrulama kümesi sızıntısı
olmaması için (PTQ ile aynı ilke). Dolgu token'ları istatistiğe katılmaz.

Çalıştırma:
    python 03_kalibre_ara_olcek.py --n_kalib 128
"""

from __future__ import annotations

import argparse
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ortak  # noqa: E402
from altin import model, veri  # noqa: E402

# Ölçeği çıkarılacak ara tensörler (altın modelin `izle` anahtarları)
HEDEFLER = (
    ["gomme.ln"]
    + [f"l{i}.{ad}.cikis" for i in range(2)
       for ad in ("q", "k", "v", "attn_out", "ffn1", "ffn2")]
    + [f"l{i}.{ad}" for i in range(2) for ad in ("skor", "ln1", "ln2", "gelu")]
    + ["pooler.cikis", "pooler.tanh", "logit"]
)

# LayerNorm'ların girdisi ayrıca gerekir (artık toplamdan sonraki tensör)
LN_GIRDI = {f"l{i}.ln{j}": f"l{i}.ln{j}.girdi" for i in range(2) for j in (1, 2)}


def main():
    ap = ortak.ortak_argumanlar(argparse.ArgumentParser(description=__doc__))
    ap.add_argument("--n_kalib", type=int, default=128,
                    help="eğitim kümesinden alınacak cümle sayısı (PTQ ile aynı: 128)")
    ap.add_argument("--yuzdelik", type=float, default=100.0,
                    help="100 = mutlak maksimum; 99.99 = aykırı değer kırpma")
    ap.add_argument("--seed", type=int, default=42)
    a = ap.parse_args()

    sys.path.insert(0, ortak.HERE)
    from altin import parametreler
    y = ortak.kosu_yollari(a)
    p = parametreler.yukle(a.model_dizin, y["npz"], y["olcekler"])
    tok = veri.tokenlayici(a.model_dizin)

    cumleler, _ = veri.tsv_oku(y["train"])
    rng = np.random.default_rng(a.seed)
    sec = rng.permutation(len(cumleler))[:a.n_kalib]
    ids, maske = veri.kodla(tok, [cumleler[i] for i in sec])
    print(f"Kalibrasyon: eğitim kümesinden {len(sec)} cümle "
          f"(seed={a.seed}, yüzdelik={a.yuzdelik})")

    m = model.AltinModel(p, model.Ayarlar(kip="A", izle_ara_tensor=True))
    uc: dict[str, float] = {}
    for i, k in veri.yiginla(ids, maske, 64):
        m.izle.clear()
        m.ileri(i, k)
        gecerli = np.asarray(k, dtype=bool)
        for ad, t in m.izle.items():
            if ad.endswith("_q") or ad.endswith("birikec") or ad == "fpga.girdi":
                continue
            t = np.asarray(t, dtype=np.float64)
            # (B, S, C) biçimindeki tensörlerde dolgu token'larını at
            if t.ndim == 3 and t.shape[:2] == gecerli.shape:
                t = t[gecerli]
            v = (float(np.abs(t).max()) if a.yuzdelik >= 100.0
                 else float(np.percentile(np.abs(t), a.yuzdelik)))
            uc[ad] = max(uc.get(ad, 0.0), v)

    olcekler = {ad: max(v, 1e-8) / 127.0 for ad, v in uc.items()}

    # LayerNorm çıkış ölçekleri, aynı tensörün ".cikis" takma adıyla da anılır
    for ad in ("gomme.ln", "l0.ln1", "l0.ln2", "l1.ln1", "l1.ln2"):
        olcekler[f"{ad}.cikis"] = olcekler[ad]

    eksik = [h for h in HEDEFLER if h not in olcekler]
    if eksik:
        print(f"UYARI: ölçeği çıkarılamayan tensör: {eksik}")

    os.makedirs(a.cikis, exist_ok=True)
    yol = os.path.join(a.cikis, "ara_olcekler.json")
    with open(yol, "w", encoding="utf-8") as f:
        json.dump({"ayarlar": vars(a), "olcekler": olcekler,
                   "mutlak_maks": uc}, f, ensure_ascii=False, indent=2)
    print(f"{len(olcekler)} ara tensör ölçeği yazıldı -> {yol}")
    for ad in sorted(olcekler)[:8]:
        print(f"   {ad:28s} olcek={olcekler[ad]:.3e}")
    print("   ...")


if __name__ == "__main__":
    main()
