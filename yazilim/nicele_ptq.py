"""G2 — Kalibrasyonlu STATİK INT8 eğitim sonrası niceleme (PTQ), BERT-Tiny / SST-2.

Neden statik? PyTorch'un dinamik nicelemesi aktivasyon ölçeğini çalışma anında hesaplar; FPGA'da bu
mümkün değildir. Burada aktivasyon ölçekleri kalibrasyon kümesiyle BİR KEZ belirlenir ve sabit kalır.

Nicelenen işlemler (bu sürüm)
  * Tüm nn.Linear katmanları: Q, K, V, dikkat çıkışı, FFN-1, FFN-2, pooler, sınıflandırıcı
      - ağırlık   : INT8, simetrik, çıkış kanalı başına (per-channel) ölçek
      - aktivasyon: INT8, tensör başına (per-tensor) sabit ölçek (simetrik ya da asimetrik)
      - bias      : INT32, ölçek = aktivasyon_ölçeği * ağırlık_ölçeği (donanımdaki birikeçle aynı)
      - çarpım-toplam tamsayı değerlerle float64 üzerinde yapılır (INT32 birikeç ile birebir aynı sonuç)
Henüz nicelenmeyenler (FP32 kalır -> G4'te karar verilecek)
  * Softmax, GELU, LayerNorm, artık toplamlar, QK^T ve Softmax·V matris çarpımları, gömme (embedding) tabloları

Kalibrasyon verisi EĞİTİM kümesinden alınır (doğrulama kümesi sızıntısı olmasın). Dolgu (padding)
token'ları aktivasyon istatistiklerine katılmaz.

Örnek:
    python yazilim/nicele_ptq.py --model_dir deneyler/fp32_baz/model
    python yazilim/nicele_ptq.py --model_dir deneyler/fp32_baz/model --observer percentile --pct 99.99 --n_kalib 512
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import time

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from egit_fp32 import evaluate, load_tokenizer, set_seed  # noqa: E402
from nicemleme_olcut import degerlendir, oku_fp32_csv  # noqa: E402
from sst2_veri import load_sst2  # noqa: E402

_MASK = {"m": None}  # kalibrasyon sırasında (B, S) bool: gerçek (dolgu olmayan) token'lar


class QLinear(nn.Module):
    """nn.Linear'ın statik INT8 karşılığı. mod: 'fp32' | 'observe' | 'quant'."""

    def __init__(self, lin: nn.Linear, ad: str, act_sym: bool, observer: str, pct: float):
        super().__init__()
        self.ad, self.act_sym, self.observer, self.pct = ad, act_sym, observer, pct
        self.mode = "fp32"
        self.register_buffer("w_fp", lin.weight.detach().clone())
        self.register_buffer("b_fp", lin.bias.detach().clone() if lin.bias is not None else None)
        w = lin.weight.detach().double()
        w_scale = w.abs().amax(dim=1).clamp_min(1e-12) / 127.0              # (out,)
        self.register_buffer("w_scale", w_scale)
        self.register_buffer("w_q", torch.round(w / w_scale[:, None]).clamp(-127, 127).to(torch.int8))
        self.register_buffer("bias_q", torch.zeros(w.shape[0], dtype=torch.int64))
        self.a_scale, self.a_zp = 1.0, 0
        self._bufs: list[np.ndarray] = []
        self.istatistik: dict = {}

    # ---- kalibrasyon ----
    def _observe(self, x: torch.Tensor):
        m = _MASK["m"]
        v = x[m] if (m is not None and x.dim() == 3 and tuple(x.shape[:2]) == tuple(m.shape)) else x.reshape(-1, x.shape[-1])
        self._bufs.append(v.detach().float().cpu().numpy().ravel())

    def finalize(self):
        a = np.concatenate(self._bufs)
        self._bufs = []
        mutlak = np.abs(a)
        self.istatistik = {
            "min": float(a.min()), "max": float(a.max()), "mutlak_max": float(mutlak.max()),
            "p99.9": float(np.percentile(mutlak, 99.9)), "p99.99": float(np.percentile(mutlak, 99.99)),
            "aykiri_orani(max/p99.9)": float(mutlak.max() / max(np.percentile(mutlak, 99.9), 1e-12)),
            "ornek_sayisi": int(a.size),
        }
        if self.act_sym:
            c = float(mutlak.max()) if self.observer == "minmax" else float(np.percentile(mutlak, self.pct))
            self.a_scale, self.a_zp = max(c, 1e-8) / 127.0, 0
        else:
            if self.observer == "minmax":
                lo, hi = float(a.min()), float(a.max())
            else:
                lo, hi = (float(v) for v in np.percentile(a, [100.0 - self.pct, self.pct]))
            lo, hi = min(lo, 0.0), max(hi, 0.0)
            self.a_scale = max(hi - lo, 1e-8) / 255.0
            self.a_zp = int(min(127, max(-128, round(-128 - lo / self.a_scale))))
        scale_b = self.a_scale * self.w_scale.double()
        if self.b_fp is not None:
            self.bias_q = torch.round(self.b_fp.double() / scale_b).to(torch.int64)
        self.mode = "quant"

    def forward(self, x):
        if self.mode == "quant":
            xq = torch.clamp(torch.round(x.double() / self.a_scale) + self.a_zp, -128, 127)
            acc = torch.matmul(xq - self.a_zp, self.w_q.double().t()) + self.bias_q.double()  # INT32 birikeç
            return (acc * (self.a_scale * self.w_scale)).to(x.dtype)
        if self.mode == "observe":
            self._observe(x)
        return F.linear(x, self.w_fp, self.b_fp)


def nicele(model, skip_regex, act_sym, observer, pct):
    qlayers = {}
    for ad, mod in list(model.named_modules()):
        for cad, child in list(mod.named_children()):
            tam = f"{ad}.{cad}" if ad else cad
            if isinstance(child, nn.Linear) and not (skip_regex and re.search(skip_regex, tam)):
                q = QLinear(child, tam, act_sym, observer, pct)
                setattr(mod, cad, q)
                qlayers[tam] = q
    return qlayers


class Batches:
    def __init__(self, tok, sentences, labels, max_len, bs):
        self.tok, self.s, self.l, self.max_len, self.bs = tok, sentences, labels, max_len, bs

    def __iter__(self):
        for i in range(0, len(self.s), self.bs):
            enc = self.tok(list(self.s[i:i + self.bs]), padding="max_length", truncation=True,
                           max_length=self.max_len, return_tensors="pt")
            d = dict(enc)
            d["labels"] = torch.tensor(self.l[i:i + self.bs])
            yield d


def main():
    ap = argparse.ArgumentParser(description="BERT-Tiny statik INT8 PTQ")
    ap.add_argument("--model_dir", default="deneyler/fp32_baz/model")
    ap.add_argument("--fp32_csv", default="deneyler/fp32_baz/dogrulama_tahminleri.csv")
    ap.add_argument("--data_dir", default=None)
    ap.add_argument("--out_dir", default="deneyler/int8_ptq")
    ap.add_argument("--ad", default=None, help="koşu adı (varsayılan: ayarlardan türetilir)")
    ap.add_argument("--max_len", type=int, default=64)
    ap.add_argument("--n_kalib", type=int, default=512, help="eğitim kümesinden kalibrasyon cümlesi sayısı")
    ap.add_argument("--observer", choices=["minmax", "percentile"], default="minmax")
    ap.add_argument("--pct", type=float, default=99.99, help="percentile observer yüzdeliği")
    ap.add_argument("--asimetrik", action="store_true", help="aktivasyonlar için asimetrik (sıfır noktalı) INT8")
    ap.add_argument("--fp32_katmanlar", default=None, help="FP32 kalacak Linear adları için regex (örn. 'classifier|pooler')")
    ap.add_argument("--agirlik_kaydet", action="store_true", help="INT8 ağırlıkları/ölçekleri .npz olarak da yaz")
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--device", default="cpu")
    a = ap.parse_args()

    set_seed(a.seed)
    from transformers import BertForSequenceClassification
    device = torch.device(a.device)
    ad = a.ad or f"{a.observer}{'' if a.observer == 'minmax' else a.pct}_{'asim' if a.asimetrik else 'sim'}_n{a.n_kalib}"
    run = os.path.join(a.out_dir, ad)
    os.makedirs(run, exist_ok=True)

    tok, tok_ad = load_tokenizer(a.model_dir)
    model = BertForSequenceClassification.from_pretrained(a.model_dir).to(device).eval()
    ds = load_sst2(a.data_dir)
    val_s, val_l = ds["validation"]["sentence"], ds["validation"]["label"]
    val = Batches(tok, val_s, val_l, a.max_len, 128)

    # --- FP32 referansı (aynı ortamda yeniden hesaplanır; CSV ile tutarlılığı kontrol edilir) ---
    acc32, lg32, pr32, lab = evaluate(model, val, device)
    fp = oku_fp32_csv(a.fp32_csv) if os.path.exists(a.fp32_csv) else None
    csv_fark = int((pr32.numpy() != np.array(fp["tahmin"])).sum()) if fp else None
    print(f"FP32 doğruluk (yeniden hesap): %{100 * acc32:.2f}  | CSV ile farklı tahmin: {csv_fark}")

    # --- Nicele + kalibre et ---
    qlayers = nicele(model, a.fp32_katmanlar, not a.asimetrik, a.observer, a.pct)
    print(f"Nicelenen Linear katmanı: {len(qlayers)}")
    tr = ds["train"].shuffle(seed=a.seed).select(range(a.n_kalib))
    for q in qlayers.values():
        q.mode = "observe"
    t0 = time.time()
    with torch.no_grad():
        for b in Batches(tok, tr["sentence"], tr["label"], a.max_len, 64):
            b.pop("labels")
            _MASK["m"] = b["attention_mask"].bool().to(device)
            model(**{k: v.to(device) for k, v in b.items()})
    _MASK["m"] = None
    for q in qlayers.values():
        q.finalize()
    kalib_sn = time.time() - t0

    # --- INT8 değerlendirme ---
    acc8, lg8, pr8, _ = evaluate(model, val, device)
    ol = degerlendir(lab.tolist(), pr32.tolist(), pr8.tolist())
    ol["maks_logit_farki"] = round(float((lg8 - lg32).abs().max()), 4)
    ol["ort_logit_farki"] = round(float((lg8 - lg32).abs().mean()), 4)
    print(f"INT8 doğruluk: %{100 * acc8:.2f} | kayıp: {ol['kayip_puan']} puan ({ol['kayip_cumle']} cümle) | "
          f"uyuşma: %{100 * ol['uyusma_orani']:.2f} | {ol['karar']}")

    with open(os.path.join(run, "int8_tahminleri.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["idx", "cumle", "etiket", "fp32_tahmin", "int8_tahmin", "logit_olumsuz", "logit_olumlu"])
        for i, s in enumerate(val_s):
            w.writerow([i, s, int(lab[i]), int(pr32[i]), int(pr8[i]), f"{lg8[i, 0]:.6f}", f"{lg8[i, 1]:.6f}"])

    olcekler = {n: {"aktivasyon_olcek": float(q.a_scale), "aktivasyon_sifir_noktasi": q.a_zp,
                    "agirlik_olcek_kanal_basina": q.w_scale.tolist(), "istatistik": q.istatistik}
                for n, q in qlayers.items()}
    with open(os.path.join(run, "olcekler.json"), "w", encoding="utf-8") as f:
        json.dump(olcekler, f, ensure_ascii=False, indent=2)
    if a.agirlik_kaydet:
        arr = {}
        for n, q in qlayers.items():
            arr[f"{n}.w_q"] = q.w_q.cpu().numpy()
            arr[f"{n}.bias_q"] = q.bias_q.cpu().numpy().astype(np.int32)
            arr[f"{n}.w_scale"] = q.w_scale.cpu().numpy()
            arr[f"{n}.a_scale"] = np.float64(q.a_scale)
            arr[f"{n}.a_zp"] = np.int32(q.a_zp)
        np.savez(os.path.join(run, "int8_agirliklar.npz"), **arr)

    sonuc = {"deney": f"Statik INT8 PTQ ({ad})", "model_dir": a.model_dir, "tokenizer": tok_ad,
             "ayarlar": vars(a), "nicelenen_katman_sayisi": len(qlayers),
             "nicelenmeyen": ["softmax", "gelu", "layernorm", "artik_toplam", "QK^T", "softmax*V", "embedding"],
             "fp32_csv_ile_farkli_tahmin": csv_fark, "kalibrasyon_sn": round(kalib_sn, 2), "sonuc": ol,
             "ortam": {"torch": torch.__version__}}
    with open(os.path.join(run, "sonuclar.json"), "w", encoding="utf-8") as f:
        json.dump(sonuc, f, ensure_ascii=False, indent=2)
    print(f"Çıktılar: {run}")


if __name__ == "__main__":
    main()
