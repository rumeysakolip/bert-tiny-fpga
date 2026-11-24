"""G6 — Niceleme farkındalıklı eğitim (QAT), BERT-Tiny / SST-2. nicele_ptq.py ile AYNI statik INT8 şeması.

Şema (nicele_ptq.QLinear ile birebir):
  * Tüm nn.Linear katmanları (Q, K, V, dikkat çıkışı, FFN-1, FFN-2, pooler, sınıflandırıcı)
      - ağırlık   : INT8, simetrik, çıkış kanalı başına ölçek = max|w| / 127, aralık [-127, 127]
      - aktivasyon: INT8, tensör başına SABİT ölçek (kalibrasyonla PTQ ile aynı gözlemciden gelir)
      - bias      : INT32, ölçek = aktivasyon_ölçeği * ağırlık_ölçeği
  * Softmax, GELU, LayerNorm, artık toplamlar, QK^T, Softmax·V, gömme tabloları FP32 kalır (PTQ ile aynı).

Nasıl çalışır
  1. FP32 modelden (egit_fp32.py çıktısı) başlanır; aktivasyon ölçekleri PTQ ile aynı kalibrasyonla (eğitim
     kümesinden n_kalib cümle, aynı gözlemci/seed) belirlenir. Bu hâlî model PTQ referansı olarak da değerlendirilir.
  2. Eğitimde her Linear "sahte niceleme" (fake-quant) ile çalışır: yuvarlama için doğrudan geçiş tahmincisi (STE).
     Ağırlıklar FP32 olarak güncellenir, ağırlık ölçeği her adımda max|w|/127'den yeniden hesaplanır
     (PTQ'nun ağırlık ölçeği tanımıyla aynı). Aktivasyon ölçekleri varsayılan olarak SABİTTİR.
  3. Eğitim sonunda nihai sayılar sahte niceleme ile DEĞİL, nicele_ptq.QLinear'ın tamsayı yoluyla
     (float64 üzerinde tamsayı birikeç, INT32 bias) ölçülür; yani donanımdaki hesapla aynı yoldur.
     Sahte niceleme ile tamsayı yolunun tutarlılığı da raporlanır.

Seçim kuralı: en iyi epoch seçilmez; SON epoch raporlanır (872 cümlelik doğrulama kümesinde epoch/hiperparametre
seçmek sonucu iyimser yapar; epoch başına doğrulama doğruluğu yalnızca bilgi için kaydedilir).

Örnek:
    python yazilim/nicele_qat.py --model_dir deneyler/fp32_baz/model --out_dir deneyler/int8_qat --agirlik_kaydet
"""

from __future__ import annotations

import argparse
import copy
import csv
import json
import math
import os
import sys
import time

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from egit_fp32 import evaluate, load_tokenizer, set_seed  # noqa: E402
from nicele_ptq import _MASK, Batches, QLinear, nicele  # noqa: E402
from nicemleme_olcut import degerlendir, oku_fp32_csv  # noqa: E402
from sst2_veri import load_sst2  # noqa: E402


def _ste_round(x: torch.Tensor) -> torch.Tensor:
    return x + (torch.round(x) - x).detach()


class QATLinear(nn.Module):
    """nn.Linear'ın sahte nicelemeli (fake-quant) eğitim karşılığı; ileri geçişi QLinear'ın 'quant' modunun
    gerçek değerli (dequantize edilmiş) eşdeğeridir."""

    def __init__(self, lin: nn.Linear, a_scale: float, a_zp: int, ogren_olcek: bool = False):
        super().__init__()
        self.in_features, self.out_features = lin.in_features, lin.out_features
        self.weight = nn.Parameter(lin.weight.detach().clone())
        self.bias = nn.Parameter(lin.bias.detach().clone()) if lin.bias is not None else None
        self.a_zp = int(a_zp)
        self.ogren_olcek = ogren_olcek
        a32 = float(np.float32(a_scale))  # eğitimdeki (float32) ve dışa aktarılan ölçek aynı değer olsun
        if ogren_olcek:
            self.log_a = nn.Parameter(torch.tensor(math.log(a32), dtype=torch.float32))
        else:
            self.register_buffer("a_scale_t", torch.tensor(a32, dtype=torch.float32))

    def aktivasyon_olcegi(self) -> torch.Tensor:
        return torch.exp(self.log_a) if self.ogren_olcek else self.a_scale_t

    def olcek_float(self) -> float:
        return float(self.aktivasyon_olcegi().detach().float().cpu())

    def forward(self, x):
        s = self.aktivasyon_olcegi().to(x.dtype)
        xq = torch.clamp(_ste_round(x / s) + self.a_zp, -128, 127)
        x_dq = (xq - self.a_zp) * s
        w = self.weight
        w_s = (w.detach().abs().amax(dim=1).clamp_min(1e-12) / 127.0)[:, None]
        w_dq = torch.clamp(_ste_round(w / w_s), -127, 127) * w_s
        b_dq = None
        if self.bias is not None:  # INT32 bias: ölçek = aktivasyon ölçeği * ağırlık ölçeği (ölçek üzerinden gradyan yok)
            sb = (s.detach() * w_s[:, 0])
            b_dq = _ste_round(self.bias / sb) * sb
        return F.linear(x_dq, w_dq, b_dq)


def _degistir(model: nn.Module, fn):
    """Her (ebeveyn, çocuk adı, tam ad) için fn(child, tam_ad) yeni modül döndürürse değiştirir. Adlandırma nicele() ile aynı."""
    for ad, mod in list(model.named_modules()):
        for cad, child in list(mod.named_children()):
            tam = f"{ad}.{cad}" if ad else cad
            yeni = fn(child, tam)
            if yeni is not None:
                setattr(mod, cad, yeni)


def kalibre_et(fp_model, tok, ds, a, device):
    """PTQ ile aynı kalibrasyon. Döner: (PTQ modeli [tamsayı yolu], {ad: QLinear})."""
    m = copy.deepcopy(fp_model).to(device).eval()
    ql = nicele(m, a.fp32_katmanlar, not a.asimetrik, a.observer, a.pct)
    tr = ds["train"].shuffle(seed=a.kalib_seed).select(range(a.n_kalib))
    for q in ql.values():
        q.mode = "observe"
    with torch.no_grad():
        for b in Batches(tok, tr["sentence"], tr["label"], a.max_len, 64):
            b.pop("labels")
            _MASK["m"] = b["attention_mask"].bool().to(device)
            m(**{k: v.to(device) for k, v in b.items()})
    _MASK["m"] = None
    for q in ql.values():
        q.finalize()
    return m, ql


def qat_modeli_kur(fp_model, ql, ogren_olcek, device):
    m = copy.deepcopy(fp_model).to(device)
    _degistir(m, lambda c, ad: QATLinear(c, ql[ad].a_scale, ql[ad].a_zp, ogren_olcek) if ad in ql else None)
    return m


def tamsayi_modeline_cevir(qat_model, act_sym, observer, pct):
    """Eğitilmiş QAT modelinden nicele_ptq.QLinear (gerçek tamsayı yolu) tabanlı model üretir; ölçekler QAT'tan alınır."""
    m = copy.deepcopy(qat_model)
    ql = {}

    def f(c, ad):
        if not isinstance(c, QATLinear):
            return None
        lin = nn.Linear(c.in_features, c.out_features, bias=c.bias is not None).to(c.weight.device)
        lin.weight.data.copy_(c.weight.detach())
        if c.bias is not None:
            lin.bias.data.copy_(c.bias.detach())
        q = QLinear(lin, ad, act_sym, observer, pct)
        q.a_scale, q.a_zp = c.olcek_float(), c.a_zp
        if q.b_fp is not None:
            q.bias_q = torch.round(q.b_fp.double() / (q.a_scale * q.w_scale.double())).to(torch.int64)
        q.mode = "quant"
        ql[ad] = q
        return q

    _degistir(m, f)
    return m, ql


def float_modele_cevir(qat_model):
    """QATLinear -> nn.Linear (eğitilmiş FP32 ağırlıklar); save_pretrained için."""
    m = copy.deepcopy(qat_model)

    def f(c, ad):
        if not isinstance(c, QATLinear):
            return None
        lin = nn.Linear(c.in_features, c.out_features, bias=c.bias is not None).to(c.weight.device)
        lin.weight.data.copy_(c.weight.detach())
        if c.bias is not None:
            lin.bias.data.copy_(c.bias.detach())
        return lin

    _degistir(m, f)
    return m


class TB:
    """Önceden tokenleştirilmiş tensörlerden toplu veri; her yinelemede yeni sözlük üretir (evaluate() 'labels'ı çıkarır)."""

    def __init__(self, enc, labels, bs, shuffle=False, gen=None):
        self.enc, self.labels, self.bs, self.shuffle, self.gen = enc, labels, bs, shuffle, gen

    def __len__(self):
        return math.ceil(len(self.labels) / self.bs)

    def __iter__(self):
        n = len(self.labels)
        idx = torch.randperm(n, generator=self.gen) if self.shuffle else torch.arange(n)
        for i in range(0, n, self.bs):
            j = idx[i:i + self.bs]
            d = {k: v[j] for k, v in self.enc.items()}
            d["labels"] = self.labels[j]
            yield d


def tokenle(tok, sentences, labels, max_len):
    parcalar = []
    for i in range(0, len(sentences), 8192):
        e = tok(list(sentences[i:i + 8192]), padding="max_length", truncation=True, max_length=max_len, return_tensors="pt")
        parcalar.append({k: e[k] for k in ("input_ids", "token_type_ids", "attention_mask")})
    enc = {k: torch.cat([p[k] for p in parcalar]) for k in parcalar[0]}
    return enc, torch.tensor(list(labels), dtype=torch.long)


def adim_suresi(model, loader, device, n_isinma=5, n_olc=20):
    """Eğitim adımı başına saniye (kopya model üzerinde, lr=0)."""
    m = copy.deepcopy(model).train()
    opt = torch.optim.AdamW(m.parameters(), lr=0.0)
    sayac, t0 = 0, time.time()
    for i, b in enumerate(loader):
        if i == n_isinma:
            if device.type == "cuda":
                torch.cuda.synchronize()
            t0 = time.time()
        if i >= n_isinma + n_olc:
            break
        b = {k: v.to(device) for k, v in b.items()}
        m(**b).loss.backward()
        opt.step()
        opt.zero_grad()
        sayac = i + 1
    if device.type == "cuda":
        torch.cuda.synchronize()
    return (time.time() - t0) / max(1, sayac - n_isinma)


def tablo_md(fp, ptq, qat, tut, ad):
    def s(o, k):
        return o[k]
    satirlar = [
        ("Doğru cümle (872 içinde)", f"{fp['dogru_fp32']}", f"{ptq['dogru_int8']}", f"{qat['dogru_int8']}"),
        ("Doğruluk", f"%{100 * fp['dogruluk_fp32']:.2f}", f"%{100 * ptq['dogruluk_int8']:.2f}", f"%{100 * qat['dogruluk_int8']:.2f}"),
        ("FP32'ye göre kayıp (puan)", "—", f"{ptq['kayip_puan']}", f"{qat['kayip_puan']}"),
        ("FP32'ye göre kayıp (cümle)", "—", f"{ptq['kayip_cumle']}", f"{qat['kayip_cumle']}"),
        ("FP32–INT8 tahmin uyuşma oranı", "—", f"%{100 * ptq['uyusma_orani']:.2f} ({ptq['uyusmayan_cumle']} cümle farklı)",
         f"%{100 * qat['uyusma_orani']:.2f} ({qat['uyusmayan_cumle']} cümle farklı)"),
        ("FP32 doğru → INT8 yanlış", "—", f"{ptq['fp32_dogru_int8_yanlis']}", f"{qat['fp32_dogru_int8_yanlis']}"),
        ("FP32 yanlış → INT8 doğru", "—", f"{ptq['fp32_yanlis_int8_dogru']}", f"{qat['fp32_yanlis_int8_dogru']}"),
        ("Maks / ort. mutlak logit farkı (FP32'ye göre)", "—", f"{ptq['maks_logit_farki']} / {ptq['ort_logit_farki']}", f"{qat['maks_logit_farki']} / {qat['ort_logit_farki']}"),
        (f"Hedef (≤1 puan, ≥{qat['esikler']['min_dogru_hedef']} doğru)", "—", "✔" if ptq["hedef_saglandi"] else "✘", "✔" if qat["hedef_saglandi"] else "✘"),
        (f"Üst sınır (≤2 puan, ≥{qat['esikler']['min_dogru_sinir']} doğru)", "—", "✔" if ptq["sinir_saglandi"] else "✘", "✔" if qat["sinir_saglandi"] else "✘"),
        ("MLPerf (≥%99 FP32)", "—", "✔" if ptq["mlperf_saglandi"] else "✘", "✔" if qat["mlperf_saglandi"] else "✘"),
    ]
    md = [f"# Statik INT8: PTQ ve QAT yan yana — {ad}", "",
          "| Ölçüt | FP32 | PTQ | QAT |", "|---|---|---|---|"]
    md += [f"| {a} | {b} | {c} | {d} |" for a, b, c, d in satirlar]
    md += ["", f"QAT için karar: {qat['karar']}", "",
           f"Tutarlılık (QAT sahte niceleme ↔ tamsayı yolu, doğrulama kümesi): tahmin uyuşması %{100 * tut['tahmin_uyusma']:.2f}, "
           f"maks mutlak logit farkı {tut['maks_logit_farki']}, ort. {tut['ort_logit_farki']}.",
           "", "Not: 872 cümlelik kümede 1–2 cümlelik farklar gürültüdür (1 puan ≈ 8,72 cümle)."]
    return "\n".join(md)


def main():
    ap = argparse.ArgumentParser(description="BERT-Tiny statik INT8 QAT (PTQ ile aynı şema)")
    ap.add_argument("--model_dir", default="deneyler/fp32_baz/model")
    ap.add_argument("--fp32_csv", default="deneyler/fp32_baz/dogrulama_tahminleri.csv")
    ap.add_argument("--data_dir", default=None)
    ap.add_argument("--out_dir", default="deneyler/int8_qat")
    ap.add_argument("--ad", default=None)
    ap.add_argument("--max_len", type=int, default=64)
    # PTQ ile aynı kalibrasyon/şema ayarları (PTQ koşunuzda ne kullandıysanız aynısını verin)
    ap.add_argument("--n_kalib", type=int, default=512)
    ap.add_argument("--observer", choices=["minmax", "percentile"], default="minmax")
    ap.add_argument("--pct", type=float, default=99.99)
    ap.add_argument("--asimetrik", action="store_true")
    ap.add_argument("--fp32_katmanlar", default=None)
    ap.add_argument("--kalib_seed", type=int, default=42, help="kalibrasyon cümlelerinin seed'i (PTQ koşusundaki --seed)")
    # QAT eğitimi
    ap.add_argument("--epochs", type=int, default=3)
    ap.add_argument("--batch_size", type=int, default=32)
    ap.add_argument("--lr", type=float, default=5e-5)
    ap.add_argument("--weight_decay", type=float, default=0.01)
    ap.add_argument("--warmup_ratio", type=float, default=0.05)
    ap.add_argument("--ogren_olcek", action="store_true", help="aktivasyon ölçeklerini de öğren (varsayılan: sabit)")
    ap.add_argument("--olcek_lr", type=float, default=2e-4)
    ap.add_argument("--sure_butcesi_dk", type=float, default=12.0,
                    help="yalnızca eğitim için süre bütçesi; aşılacaksa epoch sayısı otomatik azaltılır (0 = kapalı)")
    ap.add_argument("--max_train_samples", type=int, default=None)
    ap.add_argument("--agirlik_kaydet", action="store_true")
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--device", default=None)
    a = ap.parse_args()

    set_seed(a.seed)
    from transformers import BertForSequenceClassification, get_linear_schedule_with_warmup
    device = torch.device(a.device or ("cuda" if torch.cuda.is_available() else "cpu"))
    ad = a.ad or (f"qat_{a.observer}{'' if a.observer == 'minmax' else a.pct}_{'asim' if a.asimetrik else 'sim'}"
                  f"_n{a.n_kalib}_lr{a.lr:g}_e{a.epochs}{'_olcek' if a.ogren_olcek else ''}_s{a.seed}")
    run = os.path.join(a.out_dir, ad)
    os.makedirs(run, exist_ok=True)
    print(f"Cihaz: {device} | koşu: {ad}")

    tok, tok_ad = load_tokenizer(a.model_dir)
    fp_model = BertForSequenceClassification.from_pretrained(a.model_dir).to(device).eval()
    ds = load_sst2(a.data_dir)
    val_s, val_l = ds["validation"]["sentence"], ds["validation"]["label"]
    val_enc, val_y = tokenle(tok, val_s, val_l, a.max_len)
    val = TB(val_enc, val_y, 128)

    # ---- FP32 referansı ----
    acc32, lg32, pr32, lab = evaluate(fp_model, val, device)
    fp = oku_fp32_csv(a.fp32_csv) if os.path.exists(a.fp32_csv) else None
    csv_fark = int((pr32.numpy() != np.array(fp["tahmin"])).sum()) if fp else None
    print(f"FP32 doğruluk (yeniden hesap): %{100 * acc32:.2f} ({int((pr32 == lab).sum())}/{len(lab)}) | CSV ile farklı tahmin: {csv_fark}")

    # ---- PTQ referansı (aynı kalibrasyon, tamsayı yolu) ----
    ptq_model, ql = kalibre_et(fp_model, tok, ds, a, device)
    acc_p, lg_p, pr_p, _ = evaluate(ptq_model, val, device)
    ol_ptq = degerlendir(lab.tolist(), pr32.tolist(), pr_p.tolist())
    ol_ptq["maks_logit_farki"] = round(float((lg_p - lg32).abs().max()), 4)
    ol_ptq["ort_logit_farki"] = round(float((lg_p - lg32).abs().mean()), 4)
    print(f"PTQ (QAT öncesi) doğruluk: %{100 * acc_p:.2f} | kayıp: {ol_ptq['kayip_puan']} puan ({ol_ptq['kayip_cumle']} cümle) | "
          f"uyuşma: %{100 * ol_ptq['uyusma_orani']:.2f}")
    del ptq_model

    # ---- QAT modeli ----
    model = qat_modeli_kur(fp_model, ql, a.ogren_olcek, device)
    print(f"Sahte nicelemeli Linear katmanı: {len(ql)}")
    acc_f0, *_ = evaluate(model, val, device)
    print(f"QAT başlangıcı (sahte niceleme, eğitimsiz) doğrulama: %{100 * acc_f0:.2f}")

    tr_s, tr_l = ds["train"]["sentence"], ds["train"]["label"]
    if a.max_train_samples:
        tr_s, tr_l = tr_s[:a.max_train_samples], tr_l[:a.max_train_samples]
    t0 = time.time()
    tr_enc, tr_y = tokenle(tok, tr_s, tr_l, a.max_len)
    print(f"Eğitim kümesi tokenleştirildi: {len(tr_y)} cümle ({time.time() - t0:.0f} sn)")
    gen = torch.Generator().manual_seed(a.seed)
    loader = TB(tr_enc, tr_y, a.batch_size, shuffle=True, gen=gen)

    epochs = a.epochs
    if a.sure_butcesi_dk > 0:
        sps = adim_suresi(model, loader, device)
        epoch_sn = len(loader) * sps * 1.05 + 3
        izin = max(1, int(a.sure_butcesi_dk * 60 // epoch_sn))
        print(f"Adım süresi ~{sps * 1000:.1f} ms | epoch ~{epoch_sn:.0f} sn | bütçe {a.sure_butcesi_dk} dk -> en çok {izin} epoch")
        if izin < epochs:
            print(f"UYARI: süre bütçesi nedeniyle epoch {epochs} -> {izin}")
            epochs = izin
        set_seed(a.seed)
        gen.manual_seed(a.seed)

    no_decay = ("bias", "LayerNorm.weight")
    olcek_p = [p for n, p in model.named_parameters() if n.endswith("log_a")]
    diger = [(n, p) for n, p in model.named_parameters() if not n.endswith("log_a")]
    groups = [
        {"params": [p for n, p in diger if not any(nd in n for nd in no_decay)], "weight_decay": a.weight_decay, "lr": a.lr},
        {"params": [p for n, p in diger if any(nd in n for nd in no_decay)], "weight_decay": 0.0, "lr": a.lr},
    ]
    if olcek_p:
        groups.append({"params": olcek_p, "weight_decay": 0.0, "lr": a.olcek_lr})
    optim = torch.optim.AdamW(groups, lr=a.lr)
    toplam = len(loader) * epochs
    sched = get_linear_schedule_with_warmup(optim, int(a.warmup_ratio * toplam), toplam)

    gecmis, t_egitim = [], time.time()
    for ep in range(1, epochs + 1):
        model.train()
        run_loss, te = 0.0, time.time()
        for step, b in enumerate(loader, 1):
            b = {k: v.to(device) for k, v in b.items()}
            loss = model(**b).loss
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            optim.step()
            sched.step()
            optim.zero_grad()
            run_loss += loss.item()
            if step % 500 == 0:
                print(f"  epoch {ep} adım {step}/{len(loader)} kayıp={run_loss / step:.4f}")
        acc_e, *_ = evaluate(model, val, device)
        gecmis.append({"epoch": ep, "train_loss": run_loss / len(loader), "val_acc_sahte_niceleme": acc_e,
                       "sure_sn": round(time.time() - te, 1)})
        print(f"Epoch {ep}: eğitim kaybı={run_loss / len(loader):.4f} | doğrulama (sahte niceleme) %{100 * acc_e:.2f} "
              f"| {time.time() - te:.0f} sn")
    egitim_sn = time.time() - t_egitim

    # ---- Nihai değerlendirme: gerçek tamsayı yolu ----
    model.eval()
    acc_f, lg_f, pr_f, _ = evaluate(model, val, device)
    int_model, iql = tamsayi_modeline_cevir(model, not a.asimetrik, a.observer, a.pct)
    acc_q, lg_q, pr_q, _ = evaluate(int_model, val, device)
    ol_qat = degerlendir(lab.tolist(), pr32.tolist(), pr_q.tolist())
    ol_qat["maks_logit_farki"] = round(float((lg_q - lg32).abs().max()), 4)
    ol_qat["ort_logit_farki"] = round(float((lg_q - lg32).abs().mean()), 4)
    tut = {"tahmin_uyusma": float((pr_f == pr_q).float().mean()), "uyusmayan_cumle": int((pr_f != pr_q).sum()),
           "maks_logit_farki": round(float((lg_f - lg_q).abs().max()), 5), "ort_logit_farki": round(float((lg_f - lg_q).abs().mean()), 6),
           "sahte_niceleme_dogruluk": round(acc_f, 4), "tamsayi_dogruluk": round(acc_q, 4)}
    print(f"QAT INT8 (tamsayı yolu) doğruluk: %{100 * acc_q:.2f} ({ol_qat['dogru_int8']}/{ol_qat['n']}) | kayıp: {ol_qat['kayip_puan']} puan "
          f"({ol_qat['kayip_cumle']} cümle) | uyuşma: %{100 * ol_qat['uyusma_orani']:.2f} | {ol_qat['karar']}")
    print(f"Tutarlılık sahte niceleme ↔ tamsayı: tahmin uyuşması %{100 * tut['tahmin_uyusma']:.2f}, maks logit farkı {tut['maks_logit_farki']}")

    # ---- Çıktılar ----
    with open(os.path.join(run, "int8_tahminleri.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["idx", "cumle", "etiket", "fp32_tahmin", "int8_tahmin", "logit_olumsuz", "logit_olumlu"])
        for i, s in enumerate(val_s):
            w.writerow([i, s, int(lab[i]), int(pr32[i]), int(pr_q[i]), f"{lg_q[i, 0]:.6f}", f"{lg_q[i, 1]:.6f}"])
    olcekler = {n: {"aktivasyon_olcek": float(q.a_scale), "aktivasyon_sifir_noktasi": q.a_zp,
                    "agirlik_olcek_kanal_basina": q.w_scale.tolist(), "ptq_aktivasyon_olcek": float(ql[n].a_scale)}
                for n, q in iql.items()}
    with open(os.path.join(run, "olcekler.json"), "w", encoding="utf-8") as f:
        json.dump(olcekler, f, ensure_ascii=False, indent=2)
    if a.agirlik_kaydet:
        arr = {}
        for n, q in iql.items():
            arr[f"{n}.w_q"] = q.w_q.cpu().numpy()
            arr[f"{n}.bias_q"] = q.bias_q.cpu().numpy().astype(np.int32)
            arr[f"{n}.w_scale"] = q.w_scale.cpu().numpy()
            arr[f"{n}.a_scale"] = np.float64(q.a_scale)
            arr[f"{n}.a_zp"] = np.int32(q.a_zp)
        np.savez(os.path.join(run, "int8_agirliklar.npz"), **arr)
    fm = float_modele_cevir(model)
    fm.save_pretrained(os.path.join(run, "model"))
    tok.save_pretrained(os.path.join(run, "model"))

    fp_ozet = {"dogru_fp32": ol_qat["dogru_fp32"], "dogruluk_fp32": ol_qat["dogruluk_fp32"]}
    md = tablo_md(fp_ozet, ol_ptq, ol_qat, tut, ad)
    with open(os.path.join(run, "karsilastirma.md"), "w", encoding="utf-8") as f:
        f.write(md)
    sonuc = {"deney": f"QAT statik INT8 ({ad})", "model_dir": a.model_dir, "tokenizer": tok_ad, "ayarlar": vars(a),
             "kullanilan_epoch": epochs, "nicelenen_katman_sayisi": len(ql), "fp32_csv_ile_farkli_tahmin": csv_fark,
             "ptq": ol_ptq, "qat": ol_qat, "tutarlilik": tut, "qat_baslangic_sahte_niceleme_dogruluk": round(acc_f0, 4),
             "gecmis": gecmis, "egitim_sn": round(egitim_sn, 1),
             "secim": "son epoch (doğrulama kümesiyle epoch/hiperparametre seçimi yapılmadı)",
             "ortam": {"torch": torch.__version__, "cihaz": str(device),
                       "gpu": torch.cuda.get_device_name(0) if device.type == "cuda" else None}}
    with open(os.path.join(run, "sonuclar.json"), "w", encoding="utf-8") as f:
        json.dump(sonuc, f, ensure_ascii=False, indent=2)
    print("\n" + md)
    print(f"\nÇıktılar: {run}")


if __name__ == "__main__":
    main()
