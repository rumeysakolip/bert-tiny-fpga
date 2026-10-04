"""G9 (ön çalışma) — BERT-Tiny hesaplama yükü analizi.

1) Parametrelerin bileşenlere dağılımı
2) Tek çıkarımdaki çarpma-toplama (MAC) sayısının işlem türüne göre dağılımı
3) İşlemci üzerindeki sürenin işlem türlerine dağılımı (torch.profiler)

Süre ve MAC sayısı ağırlık değerlerinden bağımsız olduğu için model rastgele başlatılır;
bu sayede internet erişimi gerekmez. Mimari: L=2, H=128, A=2, FFN=512 (BERT-Tiny).

Kullanım:  python yazilim/hesap_yuku_analizi.py --seq_len 64 --threads 1
"""

import argparse
import collections
import json
import time

import torch
from torch.profiler import ProfilerActivity, profile
from transformers import BertConfig, BertForSequenceClassification


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seq_len", type=int, default=64)
    ap.add_argument("--threads", type=int, default=1)
    ap.add_argument("--out", default=None, help="Sonuçların yazılacağı JSON dosyası")
    a = ap.parse_args()
    torch.manual_seed(0)
    torch.set_num_threads(a.threads)
    S = a.seq_len

    cfg = BertConfig(vocab_size=30522, hidden_size=128, num_hidden_layers=2, num_attention_heads=2,
                     intermediate_size=512, num_labels=2)
    m = BertForSequenceClassification(cfg).eval()
    L, H, A, F = cfg.num_hidden_layers, cfg.hidden_size, cfg.num_attention_heads, cfg.intermediate_size
    dh = H // A

    # 1) Parametreler
    par = collections.Counter()
    for n, p in m.named_parameters():
        par["gömme (embedding)" if "embeddings" in n else "kodlayıcı (encoder)" if "encoder" in n
            else "pooler + sınıflandırıcı"] += p.numel()
    enc_mat = sum(p.numel() for n, p in m.named_parameters() if "encoder" in n and p.dim() == 2)

    # 2) MAC sayısı (analitik, tek cümle)
    macs = {
        "Q/K/V izdüşümleri": L * 3 * S * H * H,
        "Q·Kᵀ": L * A * S * S * dh,
        "Dikkat·V": L * A * S * S * dh,
        "Dikkat çıkış izdüşümü": L * S * H * H,
        "FFN1 (H→4H)": L * S * H * F,
        "FFN2 (4H→H)": L * S * F * H,
        "Pooler + sınıflandırıcı": H * H + H * 2,
    }
    elem = {"softmax": L * A * S * S, "LayerNorm": (1 + 2 * L) * S * H, "GELU": L * S * F}

    # 3) İşlemci süresi
    ids = torch.randint(1000, 2000, (1, S))
    am = torch.ones(1, S, dtype=torch.long)
    with torch.no_grad():
        for _ in range(20):
            m(input_ids=ids, attention_mask=am)
        t = time.perf_counter()
        for _ in range(200):
            m(input_ids=ids, attention_mask=am)
        lat_ms = (time.perf_counter() - t) / 200 * 1000
        with profile(activities=[ProfilerActivity.CPU]) as prof:
            for _ in range(100):
                m(input_ids=ids, attention_mask=am)
    cat = collections.Counter()
    for e in prof.key_averages():
        k = e.key
        if k in ("aten::addmm", "aten::mm", "aten::linear", "aten::matmul", "aten::bmm"):
            c = "Doğrusal katmanlar (GEMM)"
        elif "scaled_dot_product" in k:
            c = "Dikkat çekirdeği (Q·Kᵀ + softmax + Dikkat·V)"
        elif "gelu" in k:
            c = "GELU"
        elif "layer_norm" in k:
            c = "LayerNorm"
        elif "embedding" in k or "index_select" in k:
            c = "Gömme tablosu"
        else:
            c = "Diğer (yeniden şekillendirme, kopyalama, toplama)"
        cat[c] += e.self_cpu_time_total
    tt = sum(cat.values())

    tot_mac = sum(macs.values())
    res = {
        "seq_len": S,
        "parametreler": dict(par), "toplam_parametre": sum(par.values()), "kodlayici_matris_agirlik": enc_mat,
        "mac": macs, "toplam_mac": tot_mac,
        "mac_yuzde": {k: round(100 * v / tot_mac, 1) for k, v in macs.items()},
        "eleman_sayilari": elem,
        "cpu_gecikme_ms": round(lat_ms, 2),
        "cpu_sure_yuzde": {k: round(100 * v / tt, 1) for k, v in cat.most_common()},
        "ortam": {"torch": torch.__version__, "threads": a.threads},
    }
    print(json.dumps(res, ensure_ascii=False, indent=2))
    if a.out:
        with open(a.out, "w", encoding="utf-8") as f:
            json.dump(res, f, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
