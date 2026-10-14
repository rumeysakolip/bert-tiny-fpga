"""G4 (tamamlama) — GELU / Softmax / LayerNorm tamsayı yaklaşımlarının SST-2 doğruluğuna UÇTAN UCA etkisi.

ibert_gercek_aktivasyon.py yalnızca işlem düzeyindeki sayısal hatayı ölçtü. Bu betik, G3'teki statik INT8 PTQ
modelinde (Linear katmanlar INT8; nicele_ptq.py ile aynı şema) Softmax, GELU ve LayerNorm'u I-BERT tamsayı
yaklaşımlarıyla (ibert_hata_analizi.py) DEĞİŞTİRİP modelin doğrulama doğruluğunu ve FP32 ile tahmin uyuşmasını ölçer.

Her tamsayı işlem girdisini kayıt noktası başına STATİK ölçekle (kalibrasyon cümlelerinden maks-mutlak) b bite nicelerek
alır (donanımdaki sabit ölçek gibi). Kalibrasyon cümleleri EĞİTİM kümesindendir; doğrulama kümesi ölçek belirlemede
kullanılmaz. Doğrulamada kalibrasyon aralığını aşan değerler doyar (kırpılır); doyma oranı raporlanır.

Kapsam dışı (FP32 kalır): gömme tabloları, residual toplamlar, QK^T ve Softmax·V matris çarpımları.
(Bunların nicelenmesi ayrı iştir; bu sonuçlar tam tamsayı hattın doğruluğu DEĞİL, üç nonlineer işlemin etkisidir.)

Çalıştırma (proje kökünden):
    python yazilim/ibert_uctan_uca.py --model_dir deneyler/fp32_baz/model \
        --kalib_tsv <train.tsv> --out_dir deneyler/int8_ptq/g4_uctan_uca
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import os
import sys

import numpy as np
import torch
import torch.nn as nn

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ibert_hata_analizi as ib  # noqa: E402
import nicele_ptq as nq  # noqa: E402
from egit_fp32 import evaluate, load_tokenizer, set_seed  # noqa: E402
from nicemleme_olcut import degerlendir  # noqa: E402

D = torch.float64


# ---------------------------------------------------------------- küresel durum
class Durum:
    faz = "run"          # 'calib' | 'run'
    cfg: dict = {}       # {'gelu': {'bit':12}, 'softmax': {'bit':12,'cikis':16}, 'ln': {'bit':16}} (anahtar yoksa FP32)
    tokmask = None       # (B, L) bool: dolgu olmayan token'lar
    siteler: dict = {}   # ad -> {'amax': float, 'kirpilan': int, 'toplam': int}


S = Durum()


def site(ad):
    return S.siteler.setdefault(ad, {"amax": 0.0, "kirpilan": 0, "toplam": 0})


def niceleme(x, bit, ad, gecerli):
    """x'i statik ölçekle b bite nicele; ölçeği ve (geçerli konumlardaki) doyma sayısını güncelle."""
    st = site(ad)
    qmax = 2 ** (bit - 1) - 1
    scale = max(st["amax"], 1e-12) / qmax
    r = torch.round(x / scale)
    st["kirpilan"] += int(((r.abs() > qmax) & gecerli).sum())
    st["toplam"] += int(gecerli.sum())
    return torch.clamp(r, -qmax, qmax), scale


def gozle(x, ad, gecerli):
    st = site(ad)
    v = x.abs().masked_fill(~gecerli, 0.0).max().item()
    st["amax"] = max(st["amax"], v)


# ---------------------------------------------------------------- tamsayı modüller
class IntGELU(nn.Module):
    def __init__(self, orig, ad):
        super().__init__()
        self.orig, self.ad = orig, ad

    def forward(self, x):
        gec = S.tokmask[..., None] if S.tokmask is not None else torch.ones_like(x[..., :1], dtype=torch.bool)
        if S.faz == "calib":
            gozle(x, self.ad, gec.expand_as(x))
            return self.orig(x)
        c = S.cfg.get("gelu")
        if not c:
            return self.orig(x)
        q, sc = niceleme(x.double(), c["bit"], self.ad, gec.expand_as(x))
        qg, sg = ib.i_gelu(q, sc)
        return (qg * sg).to(x.dtype)


class IntLayerNorm(nn.Module):
    def __init__(self, orig: nn.LayerNorm, ad):
        super().__init__()
        self.orig, self.ad = orig, ad
        self.register_buffer("g", orig.weight.detach().double().clone())
        self.register_buffer("b", orig.bias.detach().double().clone())

    def forward(self, x):
        gec = S.tokmask[..., None] if S.tokmask is not None else torch.ones_like(x[..., :1], dtype=torch.bool)
        if S.faz == "calib":
            gozle(x, self.ad, gec.expand_as(x))
            return self.orig(x)
        c = S.cfg.get("ln")
        if not c:
            return self.orig(x)
        H = x.shape[-1]
        q, _ = niceleme(x.double(), c["bit"], self.ad, gec.expand_as(x))
        mean = torch.floor(q.sum(-1, keepdim=True) / H)
        y = q - mean
        var = torch.floor((y ** 2).sum(-1, keepdim=True) / H)
        _, std = ib.i_sqrt(var)
        fac = 2.0 ** 15
        out = torch.floor(y * fac / std) / fac
        return (out * self.g + self.b).to(x.dtype)


_ORIG_ATTN = None


def dikkat(module, query, key, value, attention_mask, scaling=None, dropout=0.0, **kw):
    """eager_attention_forward yerine: Softmax tamsayı ya da FP32 (cfg'ye göre)."""
    c = S.cfg.get("softmax")
    if S.faz != "calib" and not c:
        return _ORIG_ATTN(module, query, key, value, attention_mask, scaling=scaling, dropout=dropout, **kw)
    if scaling is None:
        scaling = query.size(-1) ** -0.5
    sk = torch.matmul(query, key.transpose(2, 3)) * scaling              # (B,H,L,L)
    if attention_mask is None:
        kg = torch.ones_like(sk, dtype=torch.bool)
    elif attention_mask.dtype == torch.bool:
        kg = attention_mask
    else:
        kg = attention_mask > -1.0      # toplamsal maske: 0 = geçerli, çok negatif = maskeli
    kg = kg.expand_as(sk)
    ad = S.softmax_adlari[id(module)]
    qg = S.tokmask[:, None, :, None].expand_as(sk) if S.tokmask is not None else torch.ones_like(kg)
    if S.faz == "calib":
        gozle(sk, ad, kg & qg)
        w = torch.softmax(sk.masked_fill(~kg, float("-inf")), -1)
    else:
        q, sc = niceleme(sk.double(), c["bit"], ad, kg & qg)
        q = q.masked_fill(~kg, -(2.0 ** 40))                              # maskeli anahtar -> exp = 0
        qs, ss = ib.i_softmax(q, sc, c["cikis"])
        w = (qs * ss * kg).to(sk.dtype)
    out = torch.matmul(w, value).transpose(1, 2).contiguous()
    return out, w


def donustur(model):
    import transformers.models.bert.modeling_bert as mb
    global _ORIG_ATTN
    if _ORIG_ATTN is None:
        _ORIG_ATTN = mb.eager_attention_forward
    mb.eager_attention_forward = dikkat
    S.softmax_adlari = {}
    for ad, m in list(model.named_modules()):
        if ad.endswith("attention.self"):
            S.softmax_adlari[id(m)] = "softmax:" + ad
        for cad, ch in list(m.named_children()):
            tam = f"{ad}.{cad}" if ad else cad
            if cad == "intermediate_act_fn":
                setattr(m, cad, IntGELU(ch, "gelu:" + tam))
            elif isinstance(ch, nn.LayerNorm):
                setattr(m, cad, IntLayerNorm(ch, "ln:" + tam))
    model.register_forward_pre_hook(_maske_al, with_kwargs=True)


def _maske_al(_m, args, kwargs):
    am = kwargs.get("attention_mask")
    S.tokmask = am.bool() if am is not None else None
    nq._MASK["m"] = S.tokmask


# ---------------------------------------------------------------- koşu yardımcıları
def kalib_cumleleri(yol, n, seed):
    with open(yol, encoding="utf-8") as f:
        satirlar = [l.rstrip("\n").split("\t") for l in f if l.strip()]
    cum = [s[0] for s in satirlar]
    etk = [int(s[1]) for s in satirlar]
    idx = np.random.RandomState(seed).permutation(len(cum))[:n]
    return [cum[i] for i in idx], [etk[i] for i in idx]


def linear_mod(qlayers, mod):
    for q in qlayers.values():
        q.mode = mod


KONFIGLER = [
    ("nl_fp32", {}),
    ("oneri", {"gelu": {"bit": 12}, "softmax": {"bit": 12, "cikis": 16}, "ln": {"bit": 16}}),
    ("genis", {"gelu": {"bit": 16}, "softmax": {"bit": 16, "cikis": 16}, "ln": {"bit": 22}}),
    ("hepsi_8bit", {"gelu": {"bit": 8}, "softmax": {"bit": 8, "cikis": 8}, "ln": {"bit": 8}}),
    ("oneri_ln12", {"gelu": {"bit": 12}, "softmax": {"bit": 12, "cikis": 16}, "ln": {"bit": 12}}),
    ("yalniz_gelu12", {"gelu": {"bit": 12}}),
    ("yalniz_gelu8", {"gelu": {"bit": 8}}),
    ("yalniz_softmax12_16", {"softmax": {"bit": 12, "cikis": 16}}),
    ("yalniz_softmax12_8", {"softmax": {"bit": 12, "cikis": 8}}),
    ("yalniz_softmax8_16", {"softmax": {"bit": 8, "cikis": 16}}),
    ("yalniz_ln16", {"ln": {"bit": 16}}),
    ("yalniz_ln12", {"ln": {"bit": 12}}),
    ("yalniz_ln8", {"ln": {"bit": 8}}),
]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model_dir", default="deneyler/fp32_baz/model")
    ap.add_argument("--fp32_csv", default="deneyler/fp32_baz/dogrulama_tahminleri.csv")
    ap.add_argument("--kalib_tsv", required=True, help="cümle<TAB>etiket (başlıksız) eğitim cümleleri")
    ap.add_argument("--out_dir", default="deneyler/int8_ptq/g4_uctan_uca")
    ap.add_argument("--n_kalib", type=int, default=512)
    ap.add_argument("--seedler", default="42,43,44")
    ap.add_argument("--max_len", type=int, default=64)
    a = ap.parse_args()
    torch.set_grad_enabled(False)
    os.makedirs(a.out_dir, exist_ok=True)

    from transformers import BertForSequenceClassification
    with open(a.fp32_csv, encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    val_s = [r["cumle"] for r in rows]
    val_l = [int(r["etiket"]) for r in rows]
    fp_tahmin = [int(r["tahmin"]) for r in rows]
    tok, _ = load_tokenizer(a.model_dir)
    val = nq.Batches(tok, val_s, val_l, a.max_len, 128)

    sonuclar, ozet_seed = {}, {}
    for seed in [int(s) for s in a.seedler.split(",")]:
        set_seed(seed)
        model = BertForSequenceClassification.from_pretrained(a.model_dir, attn_implementation="eager").eval().float()
        qlayers = nq.nicele(model, None, True, "minmax", 99.99)
        donustur(model)
        # ---- kalibrasyon: Linear + nonlineer girdi ölçekleri (FP32 modelde, eğitim cümleleri)
        cs, cl = kalib_cumleleri(a.kalib_tsv, a.n_kalib, seed)
        S.siteler = {}
        S.faz, S.cfg = "calib", {}
        linear_mod(qlayers, "observe")
        for b in nq.Batches(tok, cs, cl, a.max_len, 64):
            b.pop("labels")
            model(**b)
        for q in qlayers.values():
            q.finalize()
        S.faz = "run"

        for lin in ("fp32", "int8"):
            for ad, cfg in KONFIGLER:
                linear_mod(qlayers, "fp32" if lin == "fp32" else "quant")
                for st in S.siteler.values():
                    st["kirpilan"] = st["toplam"] = 0
                S.cfg = cfg
                acc, lg, pr, lab = evaluate(model, val, torch.device("cpu"))
                ol = degerlendir(val_l, fp_tahmin, pr.tolist())
                kirp = {}
                for k in ("gelu", "softmax", "ln"):
                    t = sum(v["toplam"] for n, v in S.siteler.items() if n.startswith(k + ":"))
                    c = sum(v["kirpilan"] for n, v in S.siteler.items() if n.startswith(k + ":"))
                    kirp[k] = (c / t) if t else None
                sonuclar.setdefault(f"{lin}|{ad}", {})[seed] = {
                    "dogru": ol["dogru_int8"], "kayip_cumle": ol["kayip_cumle"], "kayip_puan": ol["kayip_puan"],
                    "uyusma": ol["uyusma_orani"], "uyusmayan": ol["uyusmayan_cumle"],
                    "bozulan": ol["fp32_dogru_int8_yanlis"], "duzelen": ol["fp32_yanlis_int8_dogru"],
                    "mlperf": ol["mlperf_saglandi"], "hedef": ol["hedef_saglandi"],
                    "kirpilma_orani": kirp, "tahmin": pr.tolist() if seed == 42 and ad in ("oneri", "nl_fp32") and lin == "int8" else None}
                print(f"seed {seed} linear={lin:4s} {ad:22s} doğru={ol['dogru_int8']} kayıp={ol['kayip_cumle']:+d} "
                      f"uyuşma={ol['uyusma_orani']:.4f} kırpılma={ {k: (None if v is None else round(v, 5)) for k, v in kirp.items()} }")
        if seed == int(a.seedler.split(",")[0]):
            ozet_seed = {n: {"amax": v["amax"]} for n, v in S.siteler.items()}
        # FP32 referansı (nonlineer FP32, Linear FP32) birebir yeniden üretim kontrolü
        # (yukarıdaki fp32|nl_fp32 satırı 719 ve 0 farklı tahmin vermelidir)

    # ---- tahmin CSV (öneri, INT8 Linear, seed ilk)
    s0 = int(a.seedler.split(",")[0])
    onr = sonuclar["int8|oneri"][s0]["tahmin"]
    nl = sonuclar["int8|nl_fp32"][s0]["tahmin"]
    with open(os.path.join(a.out_dir, "oneri_int8_tahminleri.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["idx", "cumle", "etiket", "fp32_tahmin", "int8_linear_nl_fp32", "int8_linear_oneri_tamsayi_nl"])
        for i, s in enumerate(val_s):
            w.writerow([i, s, val_l[i], fp_tahmin[i], nl[i], onr[i]])
    for k in sonuclar:
        for sd in sonuclar[k]:
            sonuclar[k][sd]["tahmin"] = None
    out = {"kalibrasyon": f"{a.n_kalib} eğitim cümlesi, permütasyon seed'leri {a.seedler}", "konfigler": {n: c for n, c in KONFIGLER},
           "sonuclar": sonuclar, "ilk_seed_olcekleri_amax": ozet_seed}
    with open(os.path.join(a.out_dir, "sonuclar.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
    print("Yazıldı:", a.out_dir)


if __name__ == "__main__":
    main()
