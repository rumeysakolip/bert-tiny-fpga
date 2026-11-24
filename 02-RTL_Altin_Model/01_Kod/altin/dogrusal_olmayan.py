"""Doğrusal olmayan birimler: LayerNorm, Softmax, GELU, Tanh.

Her biri iki sürümde yazıldı:

  *_fp  : FP32 referans. PTQ'da bu işlemler nicemlenmemişti, dolayısıyla
          A-kipinde bunlar kullanılır ve sonuç PTQ ile birebir eşleşir.
  *_tam : Tamsayı-only sürüm (B-kipi). FPGA'da gerçekten kurulacak olan
          devrenin davranışı. Her birinin doğruluk maliyeti ayrı ölçülür.

BERT'te doğruluğu matmul değil BU birimler düşürür; bu yüzden her birinin
yaklaşımı ayrı ayrı açılıp kapatılabilir (bkz. `Ayarlar` sınıfı).
"""

from __future__ import annotations

import numpy as np

from . import nicem, sabitler as S

try:                                    # hızlı yol
    from scipy.special import erf as _erf
except ImportError:                     # yedek (yavaş ama doğru)
    import math
    _erf = np.vectorize(math.erf)


# ===========================================================================
# LayerNorm
# ===========================================================================
def katman_norm_fp(x: np.ndarray, gamma: np.ndarray, beta: np.ndarray,
                   eps: float = S.LN_EPS) -> np.ndarray:
    """FP32 LayerNorm (PyTorch nn.LayerNorm ile aynı: yanlı varyans)."""
    x = np.asarray(x, dtype=np.float32)
    ort = x.mean(axis=-1, keepdims=True, dtype=np.float32)
    d = x - ort
    var = (d * d).mean(axis=-1, keepdims=True, dtype=np.float32)
    return (d / np.sqrt(var + np.float32(eps)) * gamma + beta).astype(np.float32)


def tamsayi_karekok(v: np.ndarray) -> np.ndarray:
    """Tamsayı karekök (floor). RTL'de ardışık yaklaştırma ile ~16 çevrim.

    Newton-Raphson; tüm ara değerler tamsayıdır.
    """
    v = np.asarray(v, dtype=np.int64)
    v = np.maximum(v, 0)
    x = np.where(v > 0, np.int64(1) << ((np.log2(np.maximum(v, 1)) // 2).astype(np.int64) + 1), 0)
    for _ in range(24):
        yeni = np.where(x > 0, (x + v // np.maximum(x, 1)) // 2, 0)
        x = np.minimum(x, yeni)
    return x


def katman_norm_tam(q: np.ndarray, girdi_olcek: float,
                    gamma: np.ndarray, beta: np.ndarray,
                    cikis_olcek: float, g_bit: int = 12,
                    eps: float = S.LN_EPS) -> np.ndarray:
    """Tamsayı LayerNorm.  INT32 girdi -> INT8 çıkış.

    Adımlar (hepsi RTL'de doğrudan karşılığı olan işlemler):
      1. ort   = sum(q) / N                       (toplayıcı ağacı + sabit bölen)
      2. d     = q - ort
      3. var   = sum(d^2) / N                     (kare toplayıcı)
      4. std   = isqrt(var)                       (tamsayı karekök)
      5. y     = (d << g_bit) / std               (tek bölücü, kanal başına)
      6. cikis = kirp(round(y * gamma_q / 2^g_bit * girdi_olcek/cikis_olcek) + beta_q)

    N = 128 olduğu için 1/N bir kaydırmadır (>> 7): bölücü gerekmez.
    """
    q = np.asarray(q, dtype=np.int64)
    N = q.shape[-1]
    assert (N & (N - 1)) == 0, "N ikinin kuvveti değilse bölücü gerekir"
    kaydir = int(np.log2(N))

    ort = (q.sum(axis=-1, keepdims=True) + (1 << (kaydir - 1))) >> kaydir
    d = q - ort
    var = ((d * d).sum(axis=-1, keepdims=True) + (1 << (kaydir - 1))) >> kaydir

    # eps girdi ölçeğinin karesi cinsinden tamsayıya çevrilir
    eps_q = max(int(round(eps / (girdi_olcek ** 2))), 1)
    std = np.maximum(tamsayi_karekok(var + eps_q), 1)

    y = ((d << g_bit) + std // 2) // std          # ~ d/std * 2^g_bit (yuvarlamalı)

    # gamma ve beta'yı sabit noktaya al
    gamma_q = np.rint(np.asarray(gamma, dtype=np.float64) * (1 << g_bit)).astype(np.int64)
    beta_q = np.rint(np.asarray(beta, dtype=np.float64) / cikis_olcek).astype(np.int64)

    # ÖNEMLİ: normalleştirilmiş değer d/std'dir ve girdi ölçeğinden BAĞIMSIZDIR
    # ((x-ort)/std_x = d*s/(std_q*s) = d/std_q). Bu yüzden düzeltme çarpanında
    # girdi_olcek YER ALMAZ; yalnızca 1/cikis_olcek ve 2^(2*g_bit) vardır.
    M0, n = nicem.carpani_ayristir(float(1.0 / cikis_olcek) / (1 << (2 * g_bit)))
    cikis = nicem.sabit_nokta_carp(y * gamma_q, M0, n) + beta_q
    return nicem.kirp(cikis, S.AKT_MIN, S.AKT_MAX).astype(np.int32)


# ===========================================================================
# Softmax
# ===========================================================================
def softmax_fp(x: np.ndarray, eksen: int = -1) -> np.ndarray:
    x = np.asarray(x, dtype=np.float32)
    x = x - x.max(axis=eksen, keepdims=True)
    e = np.exp(x)
    return (e / e.sum(axis=eksen, keepdims=True)).astype(np.float32)


# exp(-8) ~ 3.4e-4; 8 bitlik olasılıkta (1/255) bunun altı zaten sıfıra yuvarlanır.
# 512 girdi -> adım 0.0156; ölçüm: skor 12 bit iken en büyük olasılık hatası 0.0045.
SOFTMAX_MENZIL = 8.0
SOFTMAX_LUT_BOYU = 512


def exp_lut_uret(boyut: int = SOFTMAX_LUT_BOYU, menzil: float = SOFTMAX_MENZIL,
                 cikis_bit: int = 15) -> np.ndarray:
    """exp(-x) arama tablosu.  x, [0, menzil] aralığında `boyut` adımda örneklenir.

    Tablo adımı skor ölçeğinden BAĞIMSIZDIR: indeks, farkın sabit noktalı
    çarpanla ölçeklenmesiyle bulunur (bkz. softmax_tam). Böylece softmax'ın
    çözünürlüğü skor nicemleme adımına değil, tablonun kendisine bağlı kalır.

    RTL'de 256 x 15 bitlik dağıtık RAM — Basys3'te yok denecek maliyet.
    """
    x = np.arange(boyut, dtype=np.float64) * (menzil / boyut)
    return np.rint(np.exp(-x) * (1 << cikis_bit)).astype(np.int64)


def softmax_tam(skor_q: np.ndarray, girdi_olcek: float, maske: np.ndarray | None = None,
                lut_boyut: int = SOFTMAX_LUT_BOYU, exp_bit: int = 15,
                menzil: float = SOFTMAX_MENZIL, indeks_bit: int = 16) -> np.ndarray:
    """Tamsayı softmax.  INT32 skor -> UINT8 olasılık (ölçek 1/255).

      1. satır maksimumunu bul, çıkar               (karşılaştırıcı ağacı)
      2. farkı sabit noktalı çarpanla LUT indisine çevir, doyur
                                                    (tek çarpma + kaydırma)
      3. exp'i LUT'tan oku, topla                   (RAM + toplayıcı ağacı)
      4. 255 * exp / toplam                         (satır başına tek bölücü)
    """
    skor_q = np.asarray(skor_q, dtype=np.int64)
    if maske is not None:
        skor_q = np.where(maske, skor_q, np.int64(-(1 << 40)))

    enb = skor_q.max(axis=-1, keepdims=True)
    fark = np.maximum(enb - skor_q, 0)                       # tamsayı, >= 0

    # indeks = fark * girdi_olcek / (menzil/lut_boyut), sabit noktalı
    carpan = girdi_olcek * lut_boyut / menzil
    M0 = int(round(carpan * (1 << indeks_bit)))
    indeks = np.clip((fark * M0) >> indeks_bit, 0, lut_boyut - 1)

    lut = exp_lut_uret(lut_boyut, menzil, exp_bit)
    e = lut[indeks]
    if maske is not None:
        e = np.where(maske, e, 0)
    toplam = np.maximum(e.sum(axis=-1, keepdims=True), 1)
    p = (e * 255 + toplam // 2) // toplam
    return np.clip(p, 0, 255).astype(np.int32)


# ===========================================================================
# GELU
# ===========================================================================
def gelu_fp(x: np.ndarray) -> np.ndarray:
    """Tam (erf tabanlı) GELU — transformers'ın `hidden_act: gelu` karşılığı."""
    x = np.asarray(x, dtype=np.float32)
    return (0.5 * x * (1.0 + _erf(x / np.sqrt(np.float32(2.0))))).astype(np.float32)


def gelu_lut_uret(girdi_olcek: float, cikis_olcek: float) -> np.ndarray:
    """INT8 -> INT8 GELU tablosu (256 girdi). RTL'de 256x8 bit dağıtık RAM."""
    q = np.arange(S.AKT_MIN, S.AKT_MAX + 1, dtype=np.float64)
    y = gelu_fp(q * girdi_olcek)
    return nicem.kirp(nicem.yuvarla_cifte(y / cikis_olcek),
                      S.AKT_MIN, S.AKT_MAX).astype(np.int32)


def gelu_tam(q: np.ndarray, lut: np.ndarray) -> np.ndarray:
    """Tablodan okuma: tek çevrim, hiç çarpma yok."""
    return lut[np.asarray(q, dtype=np.int32) - S.AKT_MIN]


# ===========================================================================
# Tanh (pooler)
# ===========================================================================
def tanh_fp(x: np.ndarray) -> np.ndarray:
    return np.tanh(np.asarray(x, dtype=np.float32)).astype(np.float32)


def tanh_lut_uret(girdi_olcek: float, cikis_olcek: float) -> np.ndarray:
    q = np.arange(S.AKT_MIN, S.AKT_MAX + 1, dtype=np.float64)
    y = np.tanh(q * girdi_olcek)
    return nicem.kirp(nicem.yuvarla_cifte(y / cikis_olcek),
                      S.AKT_MIN, S.AKT_MAX).astype(np.int32)


def tanh_tam(q: np.ndarray, lut: np.ndarray) -> np.ndarray:
    return lut[np.asarray(q, dtype=np.int32) - S.AKT_MIN]
