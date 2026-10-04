"""SST-2 veri setini yükleyen yardımcı fonksiyonlar.

İki kaynak desteklenir:
  1) Hugging Face Hub: nyu-mll/glue, "sst2" alt kümesi (varsayılan, Colab'da çalışır)
  2) Yerel GLUE klasörü: SST-2.zip açıldığında çıkan train.tsv / dev.tsv dosyaları
     (internet kısıtlı ortamlar için; --data_dir ile verilir)

Bölümler:
  train      : 67.349 cümle (etiketli)
  validation :    872 cümle (etiketli)  -> doğruluk bu kümede ölçülür
  test       :  1.821 cümle (etiketsiz, label = -1) -> kullanılmaz
Etiketler: 0 = olumsuz (negative), 1 = olumlu (positive)
"""

from __future__ import annotations

import csv
import os
from typing import Dict, List, Optional


def _read_glue_tsv(path: str) -> Dict[str, List]:
    sentences, labels = [], []
    with open(path, encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter="\t", quoting=csv.QUOTE_NONE)
        for row in reader:
            sentences.append(row["sentence"])
            labels.append(int(row["label"]))
    return {"sentence": sentences, "label": labels}


def load_sst2(data_dir: Optional[str] = None):
    """{'train': ..., 'validation': ...} biçiminde bir DatasetDict döndürür."""
    from datasets import Dataset, DatasetDict, load_dataset

    if data_dir:
        return DatasetDict(
            train=Dataset.from_dict(_read_glue_tsv(os.path.join(data_dir, "train.tsv"))),
            validation=Dataset.from_dict(_read_glue_tsv(os.path.join(data_dir, "dev.tsv"))),
        )

    ds = load_dataset("nyu-mll/glue", "sst2")
    return DatasetDict(train=ds["train"], validation=ds["validation"])
