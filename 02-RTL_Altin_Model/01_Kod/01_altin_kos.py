"""K2 — Altın modeli bir yapılandırmayla koştur ve doğruluğu raporla.

Tek koşu:
    python 01_altin_kos.py --kip A
    python 01_altin_kos.py --kip B --m0_bit 16

Birim bazında tarama (B-kipindeki her yaklaşımın maliyetini TEK TEK ölçer):
    python 01_altin_kos.py --tarama

Tarama çıktısı `03_Sonuclar/birim_taramasi.csv` — bu tablo doğrudan rapora
girer ve hangi birimin doğruluğu düşürdüğünü gösterir. RTL'de hangi birime
daha fazla bit ayıracağına bu tabloya bakarak karar verilir.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ortak  # noqa: E402
from altin import model, veri  # noqa: E402

TABAN_FP32 = 719
N_TOPLAM = 872


def kos(m, ids, maske, yigin=128):
    return np.concatenate([m.ileri(i, k) for i, k in veri.yiginla(ids, maske, yigin)])


def olc(p, ayar, ids, maske, etiket, ara_olcekler, yigin=128) -> dict:
    t = time.time()
    m = model.AltinModel(p, ayar, ara_olcekler)
    pr = kos(m, ids, maske, yigin).argmax(1)
    dogru = int((pr == etiket).sum())
    return {
        "dogru": dogru,
        "dogruluk": round(dogru / N_TOPLAM, 4),
        "kayip_puan": round(100 * (TABAN_FP32 - dogru) / N_TOPLAM, 2),
        "hedef_gecti": dogru >= 711,       # <= 1 puan
        "sinir_gecti": dogru >= 702,       # <= 2 puan (katı sınır)
        "sure_sn": round(time.time() - t, 1),
    }


def taramayi_kur() -> list[tuple[str, dict]]:
    """A-kipinden başlayıp her donanım yaklaşımını tek tek açan yapılandırmalar."""
    return [
        ("A (taban)",                     {}),
        ("+ sabit noktalı ölçekleme",     {"yeniden_olcekle": "sabit"}),
        ("+ LUT GELU",                    {"gelu": "lut"}),
        ("+ LUT tanh",                    {"tanh": "lut"}),
        ("+ tamsayı softmax",             {"softmax": "tam"}),
        ("+ tamsayı LayerNorm",           {"layer_norm": "tam"}),
        ("B (hepsi birden)",              {"yeniden_olcekle": "sabit", "gelu": "lut",
                                           "tanh": "lut", "softmax": "tam",
                                           "layer_norm": "tam"}),
    ]


def main():
    ap = ortak.ortak_argumanlar(argparse.ArgumentParser(description=__doc__))
    ap.add_argument("--kip", default="A", choices=["fp32", "A", "B"])
    ap.add_argument("--yeniden_olcekle", default=None, choices=["float", "sabit"])
    ap.add_argument("--layer_norm", default=None, choices=["float", "tam"])
    ap.add_argument("--softmax", default=None, choices=["float", "tam"])
    ap.add_argument("--gelu", default=None, choices=["float", "lut"])
    ap.add_argument("--tanh", default=None, choices=["float", "lut"])
    ap.add_argument("--m0_bit", type=int, default=31)
    ap.add_argument("--skor_bit", type=int, default=12,
                    help="dikkat skoru veri yolu genişliği (tamsayı softmax için)")
    ap.add_argument("--ln_bit", type=int, default=12,
                    help="LayerNorm girdi veri yolu genişliği (tamsayı LayerNorm için)")
    ap.add_argument("--kanal_basina_kaydirma", action="store_true",
                    help="kanal başına kaydırma (daha hassas, donanımda daha pahalı)")
    ap.add_argument("--tarama", action="store_true", help="birim bazında tarama yap")
    ap.add_argument("--ara_olcek", default=None, help="ara_olcekler.json yolu")
    ap.add_argument("--yigin", type=int, default=128)
    a = ap.parse_args()

    p, _, _, etiket, ids, maske, _ = ortak.yukle_hepsi(a)

    ara_yol = a.ara_olcek or os.path.join(a.cikis, "ara_olcekler.json")
    ara = {}
    if os.path.exists(ara_yol):
        with open(ara_yol, encoding="utf-8") as f:
            ara = json.load(f)["olcekler"]

    os.makedirs(a.cikis, exist_ok=True)

    if a.tarama:
        if not ara:
            raise SystemExit("Tarama için ara_olcekler.json gerekli: "
                             "önce `python 03_kalibre_ara_olcek.py` çalıştırın.")
        birimler_ad = ["yeniden_olcekle", "layer_norm", "softmax", "gelu", "tanh"]
        satirlar = []
        print(f"{'yapılandırma':34s} {'doğru':>6s} {'kayıp':>7s} {'hedef':>6s} {'süre':>7s}")
        print("-" * 66)
        for ad, kw in taramayi_kur():
            ayar = model.Ayarlar(
                kip="A" if not kw else "B", m0_bit=a.m0_bit, skor_bit=a.skor_bit,
                ln_bit=a.ln_bit, paylasimli_kaydirma=not a.kanal_basina_kaydirma, **kw)
            s = olc(p, ayar, ids, maske, etiket, ara, a.yigin)
            satirlar.append({"yapilandirma": ad, **s,
                             **{k: getattr(ayar, k) for k in birimler_ad},
                             "m0_bit": a.m0_bit, "skor_bit": a.skor_bit,
                             "ln_bit": a.ln_bit})
            print(f"{ad:34s} {s['dogru']:6d} {s['kayip_puan']:6.2f}p "
                  f"{'EVET' if s['hedef_gecti'] else 'HAYIR':>6s} {s['sure_sn']:6.1f}s")
        yol = os.path.join(a.cikis, "birim_taramasi.csv")
        alanlar = (["yapilandirma", "dogru", "dogruluk", "kayip_puan", "hedef_gecti",
                    "sinir_gecti", "sure_sn"] + birimler_ad
                   + ["m0_bit", "skor_bit", "ln_bit"])
        with open(yol, "w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=alanlar)
            w.writeheader()
            for s in satirlar:
                w.writerow(s)
        print(f"\nTablo yazıldı -> {yol}")
        print(f"(taban FP32 = {TABAN_FP32}/{N_TOPLAM}; hedef >= 711, katı sınır >= 702)")
        return

    kw = {k: v for k, v in (("yeniden_olcekle", a.yeniden_olcekle),
                            ("layer_norm", a.layer_norm), ("softmax", a.softmax),
                            ("gelu", a.gelu), ("tanh", a.tanh)) if v}
    ortak_kw = dict(m0_bit=a.m0_bit, skor_bit=a.skor_bit, ln_bit=a.ln_bit,
                    paylasimli_kaydirma=not a.kanal_basina_kaydirma)
    ayar = (model.Ayarlar.B_kipi(**ortak_kw, **kw) if a.kip == "B"
            else model.Ayarlar(kip=a.kip, **ortak_kw, **kw))
    s = olc(p, ayar, ids, maske, etiket, ara, a.yigin)
    print(f"kip={a.kip} {kw}")
    print(f"doğru {s['dogru']}/{N_TOPLAM}  (%{100*s['dogruluk']:.2f})  "
          f"kayıp {s['kayip_puan']} puan  hedef: "
          f"{'GEÇTİ' if s['hedef_gecti'] else 'KALDI'}  [{s['sure_sn']}s]")


if __name__ == "__main__":
    main()
