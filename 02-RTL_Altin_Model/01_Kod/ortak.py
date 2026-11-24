"""Betiklerin paylaştığı yol/argüman yardımcıları."""

from __future__ import annotations

import argparse
import os

HERE = os.path.dirname(os.path.abspath(__file__))
KOK = os.path.dirname(HERE)                      # 03-RTL_Altin_Model
PROJE = os.path.dirname(KOK)                     # biitirme-projem
NICEM = os.path.join(PROJE, "01-INT8_Nicemleme")

VARSAYILAN = {
    "model_dizin": os.path.join(NICEM, "02_Girdiler", "model"),
    "kosu": "minmax_sim_n128",
    "veri_dizin": os.path.join(NICEM, "02_Girdiler", "veri"),
    "ptq_dizin": os.path.join(NICEM, "03_Sonuclar", "int8_ptq"),
    "cikis": os.path.join(KOK, "03_Sonuclar"),
}


def ortak_argumanlar(ap: argparse.ArgumentParser) -> argparse.ArgumentParser:
    ap.add_argument("--model_dizin", default=VARSAYILAN["model_dizin"],
                    help="model.safetensors + tokenizer.json dizini")
    ap.add_argument("--kosu", default=VARSAYILAN["kosu"],
                    help="kullanılacak PTQ koşusu (03_Sonuclar/int8_ptq altındaki klasör)")
    ap.add_argument("--ptq_dizin", default=VARSAYILAN["ptq_dizin"])
    ap.add_argument("--veri_dizin", default=VARSAYILAN["veri_dizin"])
    ap.add_argument("--cikis", default=VARSAYILAN["cikis"])
    return ap


def kosu_yollari(a) -> dict:
    r = os.path.join(a.ptq_dizin, a.kosu)
    return {
        "npz": os.path.join(r, "int8_agirliklar.npz"),
        "olcekler": os.path.join(r, "olcekler.json"),
        "ptq_csv": os.path.join(r, "int8_tahminleri.csv"),
        "dev": os.path.join(a.veri_dizin, "dev.tsv"),
        "train": os.path.join(a.veri_dizin, "train.tsv"),
    }


def yukle_hepsi(a):
    """Parametreler + token'lanmış doğrulama kümesi."""
    import sys
    sys.path.insert(0, HERE)
    from altin import parametreler, veri

    y = kosu_yollari(a)
    p = parametreler.yukle(a.model_dizin, y["npz"], y["olcekler"])
    tok = veri.tokenlayici(a.model_dizin)
    cumleler, etiketler = veri.tsv_oku(y["dev"])
    ids, maske = veri.kodla(tok, cumleler)
    return p, tok, cumleler, etiketler, ids, maske, y
