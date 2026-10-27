"""G11 -- Softmax ve LayerNorm RTL icin test vektorleri (altin modelin dogrusal_olmayan.py cagrilarindan).

Gercek cumlelerde (tam tamsayi tasima, B-kipi) altin modelin softmax_tam / katman_norm_tam cagrilarini
yakalar; ayrica uc durum icin sentetik satirlar ekler. Beklenen cikislar altin fonksiyonlarin kendisinden gelir.

Cikti: 03-RTL/tb/vektor_g11/ (32 bit hex kelimeler, negatifler ikiye tümleyen)
Calistirma:  python scripts/g11_vektor_uret.py        (cwd: 03-RTL)
"""
import argparse
import json
import math
import os
import sys

import numpy as np

KOK = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
KOD = os.path.join(KOK, "02-RTL_Altin_Model", "01_Kod")
sys.path.insert(0, KOD)
import ortak  # noqa: E402
from altin import model, nicem, sabitler as S  # noqa: E402
from altin import dogrusal_olmayan as dol  # noqa: E402

CIKIS = os.path.join(KOK, "03-RTL", "tb", "vektor_g11")
SM_MAKS_SATIR = 160          # katman basina
LN_MAKS_SATIR = 96           # LN ornegi basina


def yaz(ad, dizi, genislik=32):
    """Tamsayi dizisini 32 bit hex kelimeler olarak yazar (genislik: maske biti)."""
    mask = (1 << genislik) - 1
    with open(os.path.join(CIKIS, ad), "w") as f:
        for v in np.asarray(dizi, dtype=np.int64).ravel():
            f.write(f"{int(v) & mask:0{genislik // 4}x}\n")


def ln_sabitleri(girdi_olcek, gamma, beta, cikis_olcek, g_bit=12, eps=S.LN_EPS):
    """katman_norm_tam icindeki sabitlerin birebir ayni hesabi (RTL'e parametre olarak verilir)."""
    eps_q = max(int(round(eps / (girdi_olcek ** 2))), 1)
    gamma_q = np.rint(np.asarray(gamma, dtype=np.float64) * (1 << g_bit)).astype(np.int64)
    beta_q = np.rint(np.asarray(beta, dtype=np.float64) / cikis_olcek).astype(np.int64)
    M0, n = nicem.carpani_ayristir(float(1.0 / cikis_olcek) / (1 << (2 * g_bit)))
    return eps_q, gamma_q, beta_q, M0, n


def main():
    ap = ortak.ortak_argumanlar(argparse.ArgumentParser(description=__doc__))
    ap.add_argument("--ara_olcek", default=None)
    a = ap.parse_args([])
    p, _, cumleler, etiket, ids, maske, y = ortak.yukle_hepsi(a)
    with open(os.path.join(a.cikis, "ara_olcekler.json"), encoding="utf-8") as f:
        ara = json.load(f)["olcekler"]

    # kisa/uzun karisik 4 cumle (maske uzunlugu degissin)
    uzun = np.argsort(maske.sum(1))
    sec = [int(uzun[0]), int(uzun[1]), int(uzun[-1]), int(uzun[-2])]
    print("cumleler:", sec, "token:", [int(maske[i].sum()) for i in sec])

    sm_cagri, ln_cagri = [], []
    orj_sm, orj_ln = dol.softmax_tam, dol.katman_norm_tam

    def sm_yakala(skor_q, girdi_olcek, maske_=None, **kw):
        c = orj_sm(skor_q, girdi_olcek, maske_, **kw)
        sm_cagri.append((np.array(skor_q), float(girdi_olcek), np.array(maske_), c, kw))
        return c

    def ln_yakala(q, girdi_olcek, gamma, beta, cikis_olcek, *r, **kw):
        c = orj_ln(q, girdi_olcek, gamma, beta, cikis_olcek, *r, **kw)
        ln_cagri.append((np.array(q), float(girdi_olcek), np.array(gamma), np.array(beta), float(cikis_olcek), c))
        return c

    dol.softmax_tam, dol.katman_norm_tam = sm_yakala, ln_yakala
    try:
        m = model.AltinModel(p, model.Ayarlar.B_kipi(tasima_adim=model.TASIMA_ADIMLARI), ara)
        m.ileri(ids[sec], maske[sec])
    finally:
        dol.softmax_tam, dol.katman_norm_tam = orj_sm, orj_ln
    print(f"yakalanan: softmax {len(sm_cagri)} cagri, layernorm {len(ln_cagri)} cagri")

    os.makedirs(CIKIS, exist_ok=True)
    rng = np.random.default_rng(11)
    L = S.DIZI_UZUNLUGU          # 64
    N = S.GIZLI_BOYUT            # 128

    # ------------------------------ softmax ------------------------------
    sk, mk, m0, ex = [], [], [], []
    for skor_q, s_skor, mask, cikti, kw in sm_cagri:
        B, H, T, Lk = skor_q.shape
        mask_b = np.broadcast_to(mask, skor_q.shape)
        M0 = int(round(s_skor * dol.SOFTMAX_LUT_BOYU / dol.SOFTMAX_MENZIL * (1 << 16)))
        idx = [(b, h, t) for b in range(B) for h in range(H) for t in range(T)]
        rng.shuffle(idx)
        for b, h, t in idx[:SM_MAKS_SATIR]:
            sk.append(skor_q[b, h, t]); mk.append(mask_b[b, h, t].astype(np.int64)); m0.append(M0); ex.append(cikti[b, h, t])
    n_gercek_sm = len(sk)
    # sentetik: hepsi maskeli, esit skorlar, cok genis aralik, tek gecerli token
    M0s = m0[0]
    sent = [
        (np.zeros(L, np.int64), np.zeros(L, np.int64)),                                  # hepsi maskeli
        (np.full(L, 123, np.int64), np.ones(L, np.int64)),                               # hepsi esit
        (rng.integers(-2**30, 2**30, L), np.ones(L, np.int64)),                          # cok genis aralik
        (rng.integers(-50, 50, L), np.eye(1, L, 5, dtype=np.int64)[0]),                  # tek gecerli
        (rng.integers(-2000, 2000, L), (rng.random(L) < 0.5).astype(np.int64)),          # rastgele maske
    ]
    for s, mk_ in sent:
        sk.append(s); mk.append(mk_); m0.append(M0s)
        ex.append(orj_sm(s, M0s / (1 << 16) * dol.SOFTMAX_MENZIL / dol.SOFTMAX_LUT_BOYU, mk_.astype(bool)))
    sk, mk, m0, ex = (np.array(x) for x in (sk, mk, m0, ex))
    yaz("sm_skor.mem", sk); yaz("sm_mask.mem", mk); yaz("sm_m0.mem", m0); yaz("sm_cikis.mem", ex)
    yaz("sm_lut.mem", dol.exp_lut_uret(), 32); yaz("sm_meta.mem", [len(sk), L])
    print(f"softmax: {len(sk)} satir ({n_gercek_sm} gercek, {len(sent)} sentetik); |skor|max={np.abs(sk).max()} M0max={m0.max()}")

    # ------------------------------ layernorm ------------------------------
    # ayni LN ornegini (gamma/beta/olcek) gorsel kimlikle grupla
    ornek, qs, kim, ex = [], [], [], []
    for q, s_in, gamma, beta, s_out, cikti in ln_cagri:
        sab = ln_sabitleri(s_in, gamma, beta, s_out)
        ornek.append((sab, s_in, s_out))
        kimlik = len(ornek) - 1
        satir = q.reshape(-1, N)
        cik = cikti.reshape(-1, N)
        sec_i = rng.permutation(len(satir))[:LN_MAKS_SATIR]
        for i in sec_i:
            qs.append(satir[i]); kim.append(kimlik); ex.append(cik[i])
    n_gercek_ln = len(qs)
    # sentetik satirlar ilk orneğin parametreleriyle: sabit satir (var=0), uc degerler, tek darbe
    s_in0, s_out0 = ornek[0][1], ornek[0][2]
    g0, b0 = ln_cagri[0][2], ln_cagri[0][3]
    sent = [np.full(N, 37, np.int64), np.full(N, 0, np.int64),
            rng.integers(-2**11, 2**11, N), np.where(np.arange(N) == 3, 2**15, 0).astype(np.int64),
            rng.integers(-2**15, 2**15, N)]
    for s in sent:
        qs.append(s); kim.append(0)
        ex.append(orj_ln(s[None, :], s_in0, g0, b0, s_out0)[0])
    qs, kim, ex = np.array(qs), np.array(kim), np.array(ex)
    ne = len(ornek)
    yaz("ln_q.mem", qs); yaz("ln_ornek.mem", kim); yaz("ln_cikis.mem", ex)
    yaz("ln_gamma.mem", np.concatenate([o[0][1] for o in ornek])); yaz("ln_beta.mem", np.concatenate([o[0][2] for o in ornek]))
    yaz("ln_par.mem", np.array([[o[0][0], o[0][3], o[0][4]] for o in ornek]))     # eps_q, M0, n
    yaz("ln_meta.mem", [len(qs), N, ne])

    # genislik istatistikleri (RTL veri yolu icin)
    gq = np.concatenate([o[0][1] for o in ornek]); bq = np.concatenate([o[0][2] for o in ornek])
    d = qs - ((qs.sum(1, keepdims=True) + 64) >> 7)
    var = ((d * d).sum(1) + 64) >> 7
    std = np.maximum(dol.tamsayi_karekok(var + np.array([ornek[k][0][0] for k in kim])), 1)
    yv = ((d << 12) + std[:, None] // 2) // std[:, None]
    st = {"q_abs_max": int(np.abs(qs).max()), "d_abs_max": int(np.abs(d).max()), "var_max": int(var.max()),
          "std_max": int(std.max()), "std_min": int(std.min()), "y_abs_max": int(np.abs(yv).max()),
          "gamma_q_abs_max": int(np.abs(gq).max()), "beta_q_abs_max": int(np.abs(bq).max()),
          "M0_max": int(max(o[0][3] for o in ornek)), "n": [int(o[0][4]) for o in ornek],
          "eps_q": [int(o[0][0]) for o in ornek],
          "carpim1_max": int(np.abs(yv.astype(object) * gq.max()).max()),
          "ln_satir": len(qs), "ln_gercek": n_gercek_ln, "sm_satir": len(sk), "sm_gercek": n_gercek_sm}
    # newton == bit-bit karekok ?
    v = np.concatenate([var, rng.integers(0, 2**31, 2000)])
    st["isqrt_newton_eq_floor"] = bool(all(int(dol.tamsayi_karekok(np.array([int(x)]))[0]) == math.isqrt(int(x)) for x in v))
    json.dump(st, open(os.path.join(CIKIS, "istatistik.json"), "w"), indent=1)
    print(json.dumps(st))


if __name__ == "__main__":
    main()
