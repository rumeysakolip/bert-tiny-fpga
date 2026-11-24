"""Veri ve token'laştırma — PTQ koşusuyla birebir aynı ön işleme.

PTQ'da kullanılan ayarlar (nicele_ptq.py / Batches):
    padding="max_length", truncation=True, max_length=64
Burada `tokenizers` kitaplığı doğrudan tokenizer.json'dan okur; PyTorch ya da
transformers gerekmez (altın modelin donanım tarafıyla hiçbir bağı olmasın diye).
"""

from __future__ import annotations

import csv
import os

import numpy as np
from tokenizers import Tokenizer

from . import sabitler as S


def tokenlayici(model_dizin: str, maks_uzunluk: int = S.DIZI_UZUNLUGU) -> Tokenizer:
    tok = Tokenizer.from_file(os.path.join(model_dizin, "tokenizer.json"))
    tok.enable_truncation(max_length=maks_uzunluk)
    tok.enable_padding(length=maks_uzunluk, pad_id=0, pad_token="[PAD]")
    return tok


def tsv_oku(yol: str) -> tuple[list[str], np.ndarray]:
    cumleler, etiketler = [], []
    with open(yol, encoding="utf-8") as f:
        for satir in csv.DictReader(f, delimiter="\t"):
            cumleler.append(satir["sentence"])
            etiketler.append(int(satir["label"]))
    return cumleler, np.array(etiketler, dtype=np.int64)


def kodla(tok: Tokenizer, cumleler: list[str]) -> tuple[np.ndarray, np.ndarray]:
    enc = tok.encode_batch(cumleler)
    ids = np.array([e.ids for e in enc], dtype=np.int64)
    maske = np.array([e.attention_mask for e in enc], dtype=np.int64)
    return ids, maske


def yiginla(ids: np.ndarray, maske: np.ndarray, boyut: int = 64):
    for i in range(0, len(ids), boyut):
        yield ids[i:i + boyut], maske[i:i + boyut]
