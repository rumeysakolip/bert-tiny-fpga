"""G4 — I-BERT tarzı tamsayı GELU / Softmax / LayerNorm yaklaşımlarının GERÇEK model aktivasyonlarıyla doğrulanması.

ibert_hata_analizi.py rastgele girdiyle çalışıyordu. Bu betik, G3'te eğitilen FP32 BERT-Tiny'yi (SST-2)
doğrulama cümleleri üzerinde çalıştırır, forward hook ile şu girdileri kaydeder ve aynı tamsayı
yaklaşımlarını (ibert_hata_analizi.py'den içe aktarılır, o dosya DEĞİŞTİRİLMEZ) bunlarla değerlendirir:

  GELU girdisi        : layer.intermediate.dense çıkışı            (her katman, [token, 512])
  Softmax girdisi     : dikkat skorları Q·Kᵀ/√d_baş (maske öncesi) (her katman, her baş)
  LayerNorm girdileri : embeddings.LayerNorm + her katmanın 2 LayerNorm'u (residual toplam sonrası)

Yalnızca dolgu (padding) olmayan token'lar değerlendirilir; Softmax yalnızca geçerli anahtarlar üzerinde
hesaplanır (donanımda maske eşdeğeri). Niceleme ölçeği her kayıt noktası için TÜM doğrulama kümesinden
statik (maks-mutlak) alınır; donanımda sabit ölçek/kalibrasyon bu davranışa karşılık gelir.

Çalıştırma (proje kökünden):
    python yazilim/ibert_gercek_aktivasyon.py --model_dir deneyler/fp32_baz/model \
        --dogrulama_csv deneyler/fp32_baz/dogrulama_tahminleri.csv --out_dir deneyler/int8_ptq
(CSV yoksa/verilmezse veri nyu-mll/glue sst2 doğrulama kümesinden yüklenir.)

Çıktılar (out_dir): g4_gercek_aktivasyon.json, g4_gercek_aktivasyon.md
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

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ibert_hata_analizi as ib  # noqa: E402  (i_gelu, i_softmax, i_sqrt yeniden kullanılır)

D = torch.float64
BITLER = (8, 12, 16, 22)
YUZDELIKLER = (0.01, 0.1, 1, 50, 99, 99.9, 99.99)
CHUNK = 2048  # token/satır parça boyu (bellek için)


# ---------------------------------------------------------------- veri / model
def dogrulama_cumleleri(csv_yolu, n):
    if csv_yolu and os.path.exists(csv_yolu):
        with open(csv_yolu, encoding="utf-8", newline="") as f:
            rows = list(csv.DictReader(f))
        cumle = [r["cumle"] for r in rows]
        etiket = [int(r["etiket"]) for r in rows]
        tahmin = [int(r["tahmin"]) for r in rows]
        kaynak = f"CSV: {csv_yolu}"
    else:
        from sst2_veri import load_sst2
        ds = load_sst2()["validation"]
        cumle, etiket, tahmin = list(ds["sentence"]), list(ds["label"]), None
        kaynak = "nyu-mll/glue sst2 validation"
    if n:
        cumle, etiket = cumle[:n], etiket[:n]
        tahmin = tahmin[:n] if tahmin else None
    return cumle, etiket, tahmin, kaynak


def model_yukle(model_dir):
    from transformers import BertForSequenceClassification, BertTokenizer
    tok = BertTokenizer.from_pretrained(model_dir, do_lower_case=True)
    try:
        model = BertForSequenceClassification.from_pretrained(model_dir, attn_implementation="eager")
    except Exception:  # noqa: BLE001
        model = BertForSequenceClassification.from_pretrained(model_dir)
    return tok, model.eval().float()


# ---------------------------------------------------------------- kayıt (hook)
class Kayit:
    """Forward hook'larla GELU/LayerNorm girdilerini, q/k çıkışlarından dikkat skorlarını toplar."""

    def __init__(self, model):
        self.cfg = model.config
        self.gelu, self.ln, self.q, self.k = {}, {}, {}, {}
        self.skor_satir, self.skor_uzun = {}, {}
        self.valid = None  # [B, L] bool (hook'lar okur)
        self.ln_param = {}
        self.hooks = []
        for ad, m in model.named_modules():
            if ad.endswith("intermediate.dense"):
                self.hooks.append(m.register_forward_hook(self._gelu(ad)))
            elif isinstance(m, torch.nn.LayerNorm):
                self.ln_param[ad] = (m.weight.detach().double().clone(), m.bias.detach().double().clone(), m.eps)
                self.hooks.append(m.register_forward_pre_hook(self._ln(ad)))
            elif ad.endswith("attention.self.query"):
                self.hooks.append(m.register_forward_hook(self._qk(ad, self.q)))
            elif ad.endswith("attention.self.key"):
                self.hooks.append(m.register_forward_hook(self._qk(ad.replace(".key", ".query"), self.k)))
        if not (self.gelu is not None and self.ln_param and any(a.endswith("attention.self.query") for a, _ in model.named_modules())):
            raise RuntimeError("Beklenen BERT modül adları bulunamadı (transformers sürümü?)")

    def _gelu(self, ad):
        def h(_m, _i, out):
            self.gelu.setdefault(ad, []).append(out[self.valid].detach().float().cpu())
        return h

    def _ln(self, ad):
        def h(_m, inp):
            self.ln.setdefault(ad, []).append(inp[0][self.valid].detach().float().cpu())
        return h

    def _qk(self, ad, hedef):
        def h(_m, _i, out):
            hedef[ad] = out.detach().float()
        return h

    def skor_topla(self, uzunluk):
        """Aynı ileri geçişte yakalanan q,k'dan skorları hesapla; geçerli sorgu satırlarını sakla."""
        H = self.cfg.num_attention_heads
        for ad, q in self.q.items():
            k = self.k[ad]
            B, L, Hd = q.shape
            dh = Hd // H
            qh = q.view(B, L, H, dh).transpose(1, 2)
            kh = k.view(B, L, H, dh).transpose(1, 2)
            s = qh @ kh.transpose(-1, -2) / math.sqrt(dh)  # [B,H,L,L]
            for b in range(B):
                n = int(uzunluk[b])
                self.skor_satir.setdefault(ad, []).append(s[b, :, :n, :].reshape(-1, L).cpu())
                self.skor_uzun.setdefault(ad, []).append(torch.full((H * n,), n, dtype=torch.int16))

    def kapat(self):
        for h in self.hooks:
            h.remove()


@torch.no_grad()
def kaydet(model, tok, cumleler, max_len, batch=64):
    kayit = Kayit(model)
    logits = []
    for i in range(0, len(cumleler), batch):
        e = tok(cumleler[i:i + batch], padding="max_length", truncation=True, max_length=max_len, return_tensors="pt")
        kayit.valid = e["attention_mask"].bool()
        logits.append(model(**e).logits.float())
        kayit.skor_topla(e["attention_mask"].sum(-1))
    kayit.kapat()
    logits = torch.cat(logits)
    cat = lambda d: {k: torch.cat(v) for k, v in d.items()}  # noqa: E731
    return {"gelu": cat(kayit.gelu), "ln": cat(kayit.ln), "skor": cat(kayit.skor_satir),
            "skor_n": cat(kayit.skor_uzun), "ln_param": kayit.ln_param, "logits": logits}


# ---------------------------------------------------------------- istatistik
def istatistik(x, kanal_ekseni=None):
    a = x.double().flatten()
    p = np.percentile(a.numpy(), YUZDELIKLER)
    s = {"n": int(a.numel()), "min": float(a.min()), "max": float(a.max()), "ort": float(a.mean()),
         "std": float(a.std()), **{f"p{q:g}": float(v) for q, v in zip(YUZDELIKLER, p)}}
    mx = max(abs(s["min"]), abs(s["max"]))
    s["maks_abs"] = mx
    s["maks_abs/std"] = mx / s["std"] if s["std"] > 0 else None
    s["maks_abs/p99.9_abs"] = mx / max(abs(s["p0.1"]), abs(s["p99.9"]), 1e-30)
    # bit genişliğine göre tipik değerin kaç nicemleme adımına yayıldığı (std / adım)
    s["std_adim_orani"] = {str(b): s["std"] / (mx / (2 ** (b - 1) - 1)) for b in BITLER}
    if kanal_ekseni is not None:  # LayerNorm: aykırı değer hangi gizli boyutta?
        kmax = x.double().abs().amax(0)
        top = torch.topk(kmax, 3)
        s["en_buyuk_kanallar"] = [{"kanal": int(i), "maks_abs": float(v)} for v, i in zip(top.values, top.indices)]
    return s


def niceleme(x, bit, S):
    qmax = 2 ** (bit - 1) - 1
    return torch.clamp(torch.round(x / S), -qmax, qmax)


# ---------------------------------------------------------------- değerlendirme
def gelu_degerlendir(x32, bit):
    amax = x32.abs().max().item()
    S = amax / (2 ** (bit - 1) - 1)
    emax, se2, n, refsq, refmax = 0.0, 0.0, 0, 0.0, 0.0
    for i in range(0, x32.shape[0], CHUNK):
        x = x32[i:i + CHUNK].double()
        ref = torch.nn.functional.gelu(x)
        qg, Sg = ib.i_gelu(niceleme(x, bit, S), S)
        e = (qg * Sg - ref).abs()
        emax, se2, n = max(emax, e.max().item()), se2 + (e ** 2).sum().item(), n + e.numel()
        refsq += (ref ** 2).sum().item()
    return {"girdi_bit": bit, "maks_mutlak_hata": emax, "rms_hata": math.sqrt(se2 / n), "ref_rms": math.sqrt(refsq / n)}


def softmax_degerlendir(skor32, uzun, bit, cikis_bit):
    L = skor32.shape[1]
    amax = skor32.abs().max().item()
    S = amax / (2 ** (bit - 1) - 1)
    emax = esum = 0.0
    n_el = n_row = uyum = 0
    topl = []
    for i in range(0, skor32.shape[0], CHUNK):
        x = skor32[i:i + CHUNK].double()
        mask = torch.arange(L)[None, :] < uzun[i:i + CHUNK, None].long()
        ref = torch.softmax(x.masked_fill(~mask, float("-inf")), -1)
        q = niceleme(x, bit, S).masked_fill(~mask, -(2.0 ** 40))  # maskeli konum: exp -> 0
        qs, Ss = ib.i_softmax(q, S, cikis_bit)
        y = qs * Ss * mask
        e = ((y - ref).abs() * mask)
        emax = max(emax, e.max().item())
        esum += e.sum().item()
        n_el += int(mask.sum())
        uyum += int((y.argmax(-1) == ref.argmax(-1)).sum())
        n_row += y.shape[0]
        topl.append(y.sum(-1))
    t = torch.cat(topl)
    return {"girdi_bit": bit, "cikis_bit": cikis_bit, "maks_mutlak_hata": emax, "ort_mutlak_hata": esum / n_el,
            "satir_toplami_ort": t.mean().item(), "satir_toplami_min": t.min().item(),
            "satir_toplami_maks": t.max().item(), "argmax_uyusma": uyum / n_row, "satir_sayisi": n_row}


def layernorm_degerlendir(x32, bit, gamma, beta, eps, fac_bit=15):
    amax = x32.abs().max().item()
    S = amax / (2 ** (bit - 1) - 1)
    H = x32.shape[1]
    emax = se2 = ea_max = ea_se2 = 0.0
    n = 0
    var_min = float("inf")
    sifir_var = 0
    for i in range(0, x32.shape[0], CHUNK):
        x = x32[i:i + CHUNK].double()
        ref0 = torch.nn.functional.layer_norm(x, (H,), None, None, eps)
        ref = ref0 * gamma + beta
        q = niceleme(x, bit, S)
        mean = torch.floor(q.sum(-1, keepdim=True) / H)
        y = q - mean
        var = torch.floor((y ** 2).sum(-1, keepdim=True) / H)
        var_min = min(var_min, var.min().item())
        sifir_var += int((var == 0).sum())
        _, std = ib.i_sqrt(var)
        fac = 2.0 ** fac_bit
        out = torch.floor(y * fac / std) / fac
        e = (out - ref0).abs()
        ea = (out * gamma + beta - ref).abs()
        emax, se2 = max(emax, e.max().item()), se2 + (e ** 2).sum().item()
        ea_max, ea_se2 = max(ea_max, ea.max().item()), ea_se2 + (ea ** 2).sum().item()
        n += e.numel()
    return {"girdi_bit": bit, "maks_mutlak_hata": emax, "rms_hata": math.sqrt(se2 / n),
            "afin_sonrasi_maks_hata": ea_max, "afin_sonrasi_rms_hata": math.sqrt(ea_se2 / n),
            "tamsayi_varyans_min": var_min, "sifir_varyansli_satir": sifir_var}


def isqrt_sabit(n, k):
    """k sabit Newton yinelemesi; x yalnızca küçülürse güncellenir (taşma/salınım yok). Başlangıç ib.i_sqrt ile aynı."""
    x = 2.0 ** torch.ceil(torch.log2(n.clamp_min(1)) / 2 + 1e-9)
    for _ in range(k):
        nx = torch.floor((x + torch.floor(n / x)) / 2)
        x = torch.where(nx < x, nx, x)
    return x


def isqrt_gerekli_yineleme(x32, bit):
    """Gerçek LayerNorm varyanslarında floor(sqrt) sonucunun tam çıkması için gereken sabit yineleme sayısı."""
    amax = x32.abs().max().item()
    S = amax / (2 ** (bit - 1) - 1)
    H = x32.shape[1]
    x = x32.double()
    q = niceleme(x, bit, S)
    y = q - torch.floor(q.sum(-1, keepdim=True) / H)
    var = torch.floor((y ** 2).sum(-1, keepdim=True) / H)
    ref = torch.floor(torch.sqrt(var.clamp_min(1)))
    for k in range(1, 16):
        if bool((isqrt_sabit(var, k) == ref).all()):
            return {"girdi_bit": bit, "gereken_sabit_yineleme": k, "maks_varyans": var.max().item()}
    return {"girdi_bit": bit, "gereken_sabit_yineleme": None, "maks_varyans": var.max().item()}


# ---------------------------------------------------------------- rapor
def f(v, p=4):
    return f"{v:.{p}g}" if isinstance(v, float) else str(v)


def rapor_md(R, rastgele):
    L = ["# G4 — Gerçek aktivasyonlarla doğrulama (otomatik üretildi)", "",
         f"Veri: {R['veri_kaynagi']} ({R['cumle_sayisi']} cümle, yalnızca dolgu olmayan token'lar). "
         f"Model: `{R['model_dir']}`. G3 tahminleriyle tutarlılık: {R['g3_tutarlilik']}", ""]
    L += ["## Aykırı değer dağılımı", "",
          "| Kayıt noktası | n | min | p0,1 | p50 | p99,9 | max | maks/std | maks/p99,9 | std/adım (8 / 12 / 16 bit) |", "|---|---|---|---|---|---|---|---|---|---|"]
    for ad, s in R["istatistik"].items():
        sa = s["std_adim_orani"]
        L.append(f"| {ad} | {s['n']} | {f(s['min'])} | {f(s['p0.1'])} | {f(s['p50'])} | {f(s['p99.9'])} | {f(s['max'])} | "
                 f"{f(s['maks_abs/std'], 3)} | {f(s['maks_abs/p99.9_abs'], 3)} | {f(sa['8'], 3)} / {f(sa['12'], 3)} / {f(sa['16'], 3)} |")
    L += ["", "LayerNorm girdilerinde en büyük |değer| taşıyan gizli boyutlar:", ""]
    for ad, s in R["istatistik"].items():
        if "en_buyuk_kanallar" in s:
            L.append(f"- {ad}: " + ", ".join(f"kanal {k['kanal']} ({f(k['maks_abs'])})" for k in s["en_buyuk_kanallar"]))
    L += ["", "## GELU (gerçek girdi; en kötü katman)", "", "| Girdi bit | maks hata | RMS hata | ref RMS | rastgele maks hata (8/12/16) |", "|---|---|---|---|---|"]
    for b in BITLER:
        rows = [r for k, v in R["gelu"].items() for r in v if r["girdi_bit"] == b]
        w = max(rows, key=lambda r: r["maks_mutlak_hata"])
        rr = next((r for r in rastgele.get("gelu", []) if r["girdi_bit"] == b), None)
        L.append(f"| {b} | {f(w['maks_mutlak_hata'])} | {f(w['rms_hata'])} | {f(w['ref_rms'])} | {f(rr['maks_mutlak_hata']) if rr else '—'} |")
    L += ["", "## Softmax (gerçek girdi; katmanlar birlikte en kötü değer)", "",
          "| Girdi bit | Çıkış bit | maks hata | ort hata | satır toplamı (ort / min) | argmax uyuşma | rastgele argmax | rastgele satır toplamı |", "|---|---|---|---|---|---|---|---|"]
    for b in BITLER:
        for ob in (8, 16):
            rows = [r for v in R["softmax"].values() for r in v if r["girdi_bit"] == b and r["cikis_bit"] == ob]
            w = min(rows, key=lambda r: r["argmax_uyusma"])
            rr = next((r for r in rastgele.get("softmax", []) if r["girdi_bit"] == b and r["cikis_bit"] == ob), None)
            L.append(f"| {b} | {ob} | {f(max(r['maks_mutlak_hata'] for r in rows))} | {f(max(r['ort_mutlak_hata'] for r in rows))} | "
                     f"{f(w['satir_toplami_ort'])} / {f(min(r['satir_toplami_min'] for r in rows))} | {f(w['argmax_uyusma'], 4)} | "
                     f"{f(rr['argmax_uyusma'], 4) if rr else '—'} | {f(rr['satir_toplami_ort'], 4) if rr else '—'} |")
    L += ["", "## LayerNorm — özet (5 kayıt noktasındaki en kötü değer)", "",
          "| Girdi bit | gerçek maks hata | gerçek RMS hata (en kötü) | rastgele maks hata | rastgele RMS hata | gereken Newton yinelemesi (gerçek, en çok) |", "|---|---|---|---|---|---|"]
    for b in BITLER:
        rows = [r for v in R["layernorm"].values() for r in v if r["girdi_bit"] == b]
        rr = next((r for r in rastgele.get("layernorm", []) if r["girdi_bit"] == b), None)
        it = [r["gereken_sabit_yineleme"] for v in R["isqrt"].values() for r in v if r["girdi_bit"] == b]
        itx = "belirsiz" if any(i is None for i in it) else str(max(it))
        L.append(f"| {b} | {f(max(r['maks_mutlak_hata'] for r in rows))} | {f(max(r['rms_hata'] for r in rows))} | "
                 f"{f(rr['maks_mutlak_hata']) if rr else '—'} | {f(rr['rms_hata']) if rr else '—'} | {itx} |")
    L += ["", "## LayerNorm (gerçek girdi; kayıt noktası bazında)", "",
          "| Kayıt noktası | Girdi bit | maks hata | RMS hata | afin sonrası maks hata | min tamsayı varyans |", "|---|---|---|---|---|---|"]
    for ad, v in R["layernorm"].items():
        for r in v:
            L.append(f"| {ad} | {r['girdi_bit']} | {f(r['maks_mutlak_hata'])} | {f(r['rms_hata'])} | {f(r['afin_sonrasi_maks_hata'])} | {f(r['tamsayi_varyans_min'])} |")
    L += ["", "Newton karekökü sabit yineleme sayısı: monoton güncelleme (x yalnızca küçülürse) ile floor(sqrt) tam çıkana kadar; rastgele girdi taslağında 4 bulunmuştu (ibert_hata_analizi.py)."]
    return "\n".join(L)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model_dir", default="deneyler/fp32_baz/model")
    ap.add_argument("--dogrulama_csv", default="deneyler/fp32_baz/dogrulama_tahminleri.csv")
    ap.add_argument("--rastgele_json", default="deneyler/int8_ptq/g4_hata_analizi.json")
    ap.add_argument("--out_dir", default="deneyler/int8_ptq")
    ap.add_argument("--max_len", type=int, default=64)
    ap.add_argument("--n", type=int, default=None, help="İlk n doğrulama cümlesi (varsayılan: hepsi)")
    a = ap.parse_args()
    torch.set_grad_enabled(False)

    cumle, etiket, csv_tahmin, kaynak = dogrulama_cumleleri(a.dogrulama_csv, a.n)
    tok, model = model_yukle(a.model_dir)
    K = kaydet(model, tok, cumle, a.max_len)

    pred = K["logits"].argmax(-1)
    acc = float((pred == torch.tensor(etiket)).float().mean())
    if csv_tahmin is not None:
        fark = int((pred != torch.tensor(csv_tahmin)).sum())
        tut = f"yüklenen model doğruluğu %{100 * acc:.2f}; G3 CSV tahminlerinden farklı: {fark}/{len(cumle)}"
        if fark > 0.01 * len(cumle):
            print("UYARI: model G3'teki model gibi görünmüyor (tahminler uyuşmuyor).")
    else:
        tut = f"yüklenen model doğruluğu %{100 * acc:.2f} (G3 CSV yok, karşılaştırılmadı)"
    print(tut)

    R = {"veri_kaynagi": kaynak, "cumle_sayisi": len(cumle), "model_dir": a.model_dir, "g3_tutarlilik": tut,
         "niceleme": "statik maks-mutlak ölçek (kayıt noktası başına, tüm küme)", "istatistik": {}, "gelu": {}, "softmax": {},
         "layernorm": {}, "isqrt": {}}
    for ad, x in K["gelu"].items():
        R["istatistik"][f"GELU girdisi · {ad.split('.encoder.')[-1].replace('.intermediate.dense', '')}"] = istatistik(x)
        R["gelu"][ad] = [gelu_degerlendir(x, b) for b in BITLER]
    for ad, x in K["skor"].items():
        valid = torch.arange(x.shape[1])[None, :] < K["skor_n"][ad][:, None].long()
        R["istatistik"][f"Softmax girdisi (skor) · {ad.split('.encoder.')[-1].replace('.attention.self.query', '')}"] = istatistik(x[valid])
        R["softmax"][ad] = [softmax_degerlendir(x, K["skor_n"][ad], b, ob) for b in BITLER for ob in (8, 16)]
    for ad, x in K["ln"].items():
        g, bt, eps = K["ln_param"][ad]
        R["istatistik"][f"LayerNorm girdisi · {ad.split('bert.')[-1]}"] = istatistik(x, kanal_ekseni=1)
        R["layernorm"][ad] = [layernorm_degerlendir(x, b, g, bt, eps) for b in BITLER]
        R["isqrt"][ad] = [isqrt_gerekli_yineleme(x, b) for b in BITLER]

    rastgele = {}
    if os.path.exists(a.rastgele_json):
        with open(a.rastgele_json, encoding="utf-8") as fh:
            rastgele = json.load(fh)
    R["rastgele_girdi_sonuclari"] = rastgele

    os.makedirs(a.out_dir, exist_ok=True)
    with open(os.path.join(a.out_dir, "g4_gercek_aktivasyon.json"), "w", encoding="utf-8") as fh:
        json.dump(R, fh, ensure_ascii=False, indent=2)
    with open(os.path.join(a.out_dir, "g4_gercek_aktivasyon.md"), "w", encoding="utf-8") as fh:
        fh.write(rapor_md(R, rastgele))
    print("Yazıldı:", os.path.join(a.out_dir, "g4_gercek_aktivasyon.{json,md}"))


if __name__ == "__main__":
    main()
