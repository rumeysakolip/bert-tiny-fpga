"""G3 — BERT-Tiny modelinin SST-2 üzerinde ince ayarı ve FP32 baz doğruluğunun ölçülmesi.

Model : prajjwal1/bert-tiny  (Google'ın resmi BERT-Tiny TF ağırlıklarının PyTorch'a çevrilmiş hâli;
        2 katman, gizli boyut 128, 2 dikkat başı, ~4,4 M parametre)
Veri  : GLUE SST-2 (nyu-mll/glue, sst2)

Örnek kullanım (Colab):
    python yazilim/egit_fp32.py --out_dir deneyler/fp32_baz

Çıktılar (out_dir içinde):
    model/                   en iyi epoch'un ağırlıkları + tokenizer (save_pretrained)
    sonuclar.json            doğruluk, ayarlar, süre, sürüm bilgileri, epoch geçmişi
    dogrulama_tahminleri.csv 872 doğrulama cümlesi için etiket, tahmin ve logit değerleri
                             (ileride INT8 modeli ve FPGA çıktısıyla birebir karşılaştırmak için)
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import platform
import random
import sys
import time

import numpy as np
import torch
from torch.utils.data import DataLoader

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sst2_veri import load_sst2  # noqa: E402


def parse_args():
    p = argparse.ArgumentParser(description="BERT-Tiny SST-2 FP32 ince ayar")
    p.add_argument("--model_name", default="prajjwal1/bert-tiny")
    p.add_argument("--data_dir", default=None, help="Yerel GLUE SST-2 klasörü (train.tsv, dev.tsv)")
    p.add_argument("--out_dir", default="deneyler/fp32_baz")
    p.add_argument("--max_len", type=int, default=64,
                   help="Sabit dizi uzunluğu. Donanımda da aynı uzunluk kullanılacağı için sabit tutulur.")
    p.add_argument("--epochs", type=int, default=4)
    p.add_argument("--batch_size", type=int, default=32)
    p.add_argument("--lr", type=float, default=1e-4)
    p.add_argument("--weight_decay", type=float, default=0.01)
    p.add_argument("--warmup_ratio", type=float, default=0.1)
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--max_train_samples", type=int, default=None, help="Hızlı deneme için eğitim kümesini kısalt")
    return p.parse_args()


def set_seed(seed: int):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)


@torch.no_grad()
def evaluate(model, loader, device):
    model.eval()
    all_logits, all_labels = [], []
    for batch in loader:
        labels = batch.pop("labels")
        batch = {k: v.to(device) for k, v in batch.items()}
        all_logits.append(model(**batch).logits.float().cpu())
        all_labels.append(labels)
    logits = torch.cat(all_logits)
    labels = torch.cat(all_labels)
    preds = logits.argmax(-1)
    acc = (preds == labels).float().mean().item()
    return acc, logits, preds, labels


def main():
    args = parse_args()
    set_seed(args.seed)
    os.makedirs(args.out_dir, exist_ok=True)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Cihaz: {device}")

    from transformers import (AutoModelForSequenceClassification, AutoTokenizer,
                              get_linear_schedule_with_warmup)

    # ---------- Veri ----------
    ds = load_sst2(args.data_dir)
    if args.max_train_samples:
        ds["train"] = ds["train"].shuffle(seed=args.seed).select(range(args.max_train_samples))
    print(f"Eğitim: {len(ds['train'])} cümle | Doğrulama: {len(ds['validation'])} cümle")

    tok = AutoTokenizer.from_pretrained(args.model_name)

    def tokenize(b):
        return tok(b["sentence"], padding="max_length", truncation=True, max_length=args.max_len)

    # Kaç cümlenin max_len'e sığmadığını raporla (donanım dizi uzunluğu kararı için önemli)
    val_lens = [len(tok(s)["input_ids"]) for s in ds["validation"]["sentence"]]
    truncated_pct = 100.0 * sum(l > args.max_len for l in val_lens) / len(val_lens)
    print(f"Doğrulama token uzunluğu: ort={np.mean(val_lens):.1f}, maks={max(val_lens)}, "
          f"max_len={args.max_len} ile kesilen: %{truncated_pct:.2f}")

    cols = ["input_ids", "token_type_ids", "attention_mask", "label"]
    enc = {}
    for split in ("train", "validation"):
        e = ds[split].map(tokenize, batched=True, remove_columns=[c for c in ds[split].column_names if c != "label"])
        e = e.rename_column("label", "labels")
        e.set_format("torch", columns=[c if c != "label" else "labels" for c in cols])
        enc[split] = e

    train_loader = DataLoader(enc["train"], batch_size=args.batch_size, shuffle=True)
    val_loader = DataLoader(enc["validation"], batch_size=128, shuffle=False)

    # ---------- Model ----------
    model = AutoModelForSequenceClassification.from_pretrained(args.model_name, num_labels=2).to(device)
    n_params = sum(p.numel() for p in model.parameters())
    print(f"Parametre sayısı: {n_params:,}")

    no_decay = ("bias", "LayerNorm.weight")
    groups = [
        {"params": [p for n, p in model.named_parameters() if not any(nd in n for nd in no_decay)],
         "weight_decay": args.weight_decay},
        {"params": [p for n, p in model.named_parameters() if any(nd in n for nd in no_decay)],
         "weight_decay": 0.0},
    ]
    optim = torch.optim.AdamW(groups, lr=args.lr)
    total_steps = len(train_loader) * args.epochs
    sched = get_linear_schedule_with_warmup(optim, int(args.warmup_ratio * total_steps), total_steps)

    # ---------- Eğitim ----------
    history, best_acc, best_epoch = [], -1.0, -1
    t0 = time.time()
    for epoch in range(1, args.epochs + 1):
        model.train()
        running = 0.0
        for step, batch in enumerate(train_loader, 1):
            batch = {k: v.to(device) for k, v in batch.items()}
            loss = model(**batch).loss
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            optim.step()
            sched.step()
            optim.zero_grad()
            running += loss.item()
            if step % 500 == 0:
                print(f"  epoch {epoch} adım {step}/{len(train_loader)} kayıp={running / step:.4f}")
        acc, *_ = evaluate(model, val_loader, device)
        history.append({"epoch": epoch, "train_loss": running / len(train_loader), "val_acc": acc})
        print(f"Epoch {epoch}: eğitim kaybı={running / len(train_loader):.4f}  doğrulama doğruluğu=%{100 * acc:.2f}")
        if acc > best_acc:
            best_acc, best_epoch = acc, epoch
            model.save_pretrained(os.path.join(args.out_dir, "model"))
            tok.save_pretrained(os.path.join(args.out_dir, "model"))
    train_time = time.time() - t0

    # ---------- En iyi modelle son değerlendirme ----------
    model = AutoModelForSequenceClassification.from_pretrained(os.path.join(args.out_dir, "model")).to(device)
    acc, logits, preds, labels = evaluate(model, val_loader, device)

    with open(os.path.join(args.out_dir, "dogrulama_tahminleri.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["idx", "cumle", "etiket", "tahmin", "logit_olumsuz", "logit_olumlu"])
        for i, s in enumerate(ds["validation"]["sentence"]):
            w.writerow([i, s, int(labels[i]), int(preds[i]), f"{logits[i, 0]:.6f}", f"{logits[i, 1]:.6f}"])

    import transformers
    results = {
        "deney": "FP32 baz doğruluk (G3)",
        "model": args.model_name,
        "veri": "GLUE SST-2 (doğrulama kümesi, 872 cümle)",
        "dogruluk": round(acc, 4),
        "en_iyi_epoch": best_epoch,
        "parametre_sayisi": n_params,
        "fp32_boyut_MB": round(n_params * 4 / 2**20, 2),
        "max_len_ile_kesilen_yuzde": round(truncated_pct, 2),
        "egitim_suresi_sn": round(train_time, 1),
        "ayarlar": vars(args),
        "gecmis": history,
        "ortam": {"cihaz": str(device),
                  "gpu": torch.cuda.get_device_name(0) if torch.cuda.is_available() else None,
                  "python": platform.python_version(), "torch": torch.__version__,
                  "transformers": transformers.__version__},
        "referans": "Turc ve ark. (2019), BERT-Tiny SST-2 test doğruluğu: %83,2",
    }
    with open(os.path.join(args.out_dir, "sonuclar.json"), "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f"\nFP32 doğrulama doğruluğu: %{100 * acc:.2f} (en iyi epoch: {best_epoch})")
    print(f"Sonuçlar: {args.out_dir}/sonuclar.json")


if __name__ == "__main__":
    main()
