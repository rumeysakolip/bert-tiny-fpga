"""G4 — Softmax / GELU / LayerNorm için tamsayı (I-BERT tarzı) yaklaşımların sayısal hata analizi.

Model ağırlığı GEREKTİRMEZ: gerçekçi aralıkta rastgele girdilerle, her işlemin tamsayı yaklaşımı
FP64 referansla karşılaştırılır. Doğruluk üzerindeki gerçek etki (SST-2) G3 ağırlıkları gelince
nicele_ptq.py ile ölçülecek.

Yaklaşımlar (Kim ve ark., 2021, I-BERT):
  i-GELU     : erf için 2. derece polinom  L(x)=sgn(x)[a(clip(|x|,max=-b)+b)^2+1], a=-0,2888, b=-1,769
  i-Softmax  : exp için x = -z ln2 + p ayrıştırması, exp(p) ≈ 0,3585(p+1,353)^2+0,344, sonra z kadar kaydırma
  i-LayerNorm: ortalama/varyans tamsayı, standart sapma için Newton yinelemeli tamsayı karekökü

Çalıştırma:  python yazilim/ibert_hata_analizi.py --out deneyler/int8_ptq/g4_hata_analizi.json
"""

from __future__ import annotations

import argparse
import json
import math

import numpy as np
import torch

torch.manual_seed(0)
D = torch.float64


# ---------------- I-BERT temel işlemleri (tamsayı değerler float64 içinde tutulur) ----------------
def i_poly(q, S, a, b, c):
    qb = math.floor(b / S)
    qc = math.floor(c / (a * S * S))
    return (q + qb) ** 2 + qc, a * S * S


def i_erf(q, S):
    a, b, c = -0.2888, -1.769, 1.0
    sgn = torch.sign(q)
    qa = torch.clamp(q.abs(), max=-b / S).floor()
    ql, Sl = i_poly(qa, S, a, b, c)
    return sgn * ql, Sl


def i_gelu(q, S):
    qe, Se = i_erf(q, S / math.sqrt(2))
    q1 = math.floor(1.0 / Se)
    return q * (qe + q1), S * Se / 2


def i_exp(q, S, n=30):
    q_ln2 = math.floor(-math.log(2) / S)
    z = torch.floor(q / q_ln2)
    qp = q - z * q_ln2
    qpoly, Sp = i_poly(qp, S, 0.3585, 1.353, 0.344)
    return torch.clamp(torch.floor(qpoly * 2.0 ** (n - z)), min=0), Sp / 2.0 ** n


def i_softmax(q, S, out_bits=8):
    q = q - q.max(dim=-1, keepdim=True).values
    qe, Se = i_exp(q, S)
    # I-BERT: exp çıktısı toplamadan önce 16 bite yeniden nicelenir (aksi hâlde toplam 32 bite sığmaz)
    S16 = qe.max().item() * Se / (2 ** 15 - 1)
    qe = torch.floor(qe * Se / S16)
    tot = qe.sum(dim=-1, keepdim=True)
    factor = torch.floor(2.0 ** 32 / tot)
    out = torch.floor(qe * factor / 2.0 ** (32 - out_bits + 1))
    return out, 1.0 / 2.0 ** (out_bits - 1)


def i_sqrt(n: torch.Tensor, iters=None):
    """Newton yinelemesiyle floor(sqrt(n)); (yinelenme sayısı, sonuç) döndürür."""
    x = 2.0 ** torch.ceil(torch.log2(n.clamp_min(1)) / 2 + 1e-9)  # n'den büyük bir başlangıç
    for it in range(1, 40):
        nx = torch.floor((x + torch.floor(n / x)) / 2)
        if iters is None and bool((nx >= x).all()):
            return it, x
        if iters is not None and it >= iters:
            return it, nx
        x = torch.where(nx < x, nx, x)
    return 40, x


def quantize_sym(x, bits):
    S = x.abs().max().item() / (2 ** (bits - 1) - 1)
    return torch.round(x / S), S


# ---------------- deneyler ----------------
def deney_gelu(bitler=(8, 12, 16)):
    # FFN-1 çıkışı için gerçekçi aralık: ~N(0, 1.5), |x| <= 8 civarı
    x = torch.randn(200_000, dtype=D) * 1.5
    ref = torch.nn.functional.gelu(x)
    out = []
    for b in bitler:
        q, S = quantize_sym(x, b)
        qg, Sg = i_gelu(q, S)
        y = qg * Sg
        e = (y - ref).abs()
        out.append({"girdi_bit": b, "maks_mutlak_hata": round(e.max().item(), 5),
                    "rms_hata": round(float((e ** 2).mean().sqrt()), 5),
                    "ref_rms": round(float((ref ** 2).mean().sqrt()), 4)})
    return out


def deney_softmax(bitler=(8, 12, 16), uzunluk=64, cikis_bitleri=(8, 16)):
    # dikkat skorları: 64 anahtar, skor ~N(0, 3)
    x = torch.randn(5000, uzunluk, dtype=D) * 3.0
    ref = torch.softmax(x, -1)
    out = []
    for b, ob in [(b, ob) for b in bitler for ob in cikis_bitleri]:
        q, S = quantize_sym(x, b)
        qs, Ss = i_softmax(q, S, ob)
        y = qs * Ss
        e = (y - ref).abs()
        out.append({"girdi_bit": b, "cikis_bit": ob, "maks_mutlak_hata": round(e.max().item(), 5),
                    "ort_mutlak_hata": round(e.mean().item(), 6),
                    "satir_toplami_ort": round(y.sum(-1).mean().item(), 4),
                    "argmax_uyusma": round(float((y.argmax(-1) == ref.argmax(-1)).double().mean()), 4)})
    return out


def deney_isqrt():
    # LayerNorm varyansı: sıfırdan büyük tamsayı değerler (hidden=128, girdi 16 bit)
    n = torch.randint(1, 2 ** 28, (100_000,), dtype=torch.int64).to(D)
    it, r = i_sqrt(n)
    hata = (r - torch.floor(torch.sqrt(n))).abs()
    # sabit yineleme sayısıyla donanım için gerekli minimum
    gerekli = None
    for k in range(1, 12):
        _, rk = i_sqrt(n, iters=k)
        if bool((rk == torch.floor(torch.sqrt(n))).all()):
            gerekli = k
            break
    return {"yineleme_sayisi_yakinsama": it, "maks_hata_tamsayi": hata.max().item(),
            "tam_dogru_icin_gereken_sabit_yineleme": gerekli}


def deney_layernorm(bit=16, hidden=128):
    x = torch.randn(4000, hidden, dtype=D) * 2.0 + 0.5
    gamma, beta = torch.ones(hidden, dtype=D), torch.zeros(hidden, dtype=D)
    ref = torch.nn.functional.layer_norm(x, (hidden,), gamma, beta, eps=1e-12)
    q, S = quantize_sym(x, bit)
    mean = torch.floor(q.sum(-1, keepdim=True) / hidden)
    y = q - mean
    var = torch.floor((y ** 2).sum(-1, keepdim=True) / hidden)
    _, std = i_sqrt(var)
    fac = 2.0 ** 15
    out = torch.floor(y * fac / std) / fac  # tamsayı bölme, 15 bit kesir
    e = (out - ref).abs()
    return {"girdi_bit": bit, "hidden": hidden, "maks_mutlak_hata": round(e.max().item(), 4),
            "rms_hata": round(float((e ** 2).mean().sqrt()), 5)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=None)
    a = ap.parse_args()
    sonuc = {"gelu": deney_gelu(), "softmax": deney_softmax(), "isqrt": deney_isqrt(),
             "layernorm": [deney_layernorm(b) for b in (12, 16, 22)]}
    txt = json.dumps(sonuc, ensure_ascii=False, indent=2)
    print(txt)
    if a.out:
        with open(a.out, "w", encoding="utf-8") as f:
            f.write(txt)


if __name__ == "__main__":
    main()
