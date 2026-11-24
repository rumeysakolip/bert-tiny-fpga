"""Birim testleri — RTL'e geçmeden önce ilkel işlemlerin kanıtı.

Çalıştırma (pytest gerekmez):
    python testler/test_birimler.py
"""

from __future__ import annotations

import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from altin import birimler, dogrusal_olmayan as dol, nicem, sabitler as S  # noqa: E402

GECTI, KALDI = [], []


def kontrol(ad: str, kosul: bool, ayrinti: str = ""):
    (GECTI if kosul else KALDI).append(ad)
    print(f"[{'GEÇTİ' if kosul else 'KALDI'}] {ad}" + (f"  — {ayrinti}" if ayrinti else ""))


# ---------------------------------------------------------------------------
def test_sistolik_birebir():
    """Döngüsel systolic dizi, vektörel matmul ile BİT-BİREBİR aynı olmalı."""
    rng = np.random.default_rng(1)
    for T, K, C in [(8, 64, 8), (17, 128, 33), (64, 512, 128), (1, 128, 2)]:
        X = rng.integers(S.AKT_MIN, S.AKT_MAX + 1, size=(T, K), dtype=np.int64)
        W = rng.integers(S.AGIRLIK_MIN, S.AGIRLIK_MAX + 1, size=(C, K), dtype=np.int64)
        a = birimler.SistolikDizi().carp(X, W)
        b = birimler.hizli_matmul(X, W)
        if not np.array_equal(a, b):
            kontrol(f"systolic == matmul ({T}x{K}x{C})", False)
            return
    kontrol("systolic dizi == vektörel matmul (4 farklı boyut)", True)


def test_birikec_genisligi():
    """En kötü durumda INT32 birikeç taşmamalı (teorik üst sınır)."""
    # en uzun iç çarpım: FFN-2 girdisi 512 uzunluğunda
    ust = 512 * 127 * 127
    kontrol("INT32 birikeç teorik üst sınırı", ust < 2**31 - 1,
            f"512*127*127 = {ust} < 2^31 ({100*ust/(2**31):.1f}% dolu)")


def test_carpan_ayristirma():
    """M0/kaydırma ayrıştırması gerçel çarpana yeterince yakın olmalı."""
    rng = np.random.default_rng(2)
    M = 10 ** rng.uniform(-6, -1, size=1000)
    for bit, esik in [(31, 1e-8), (24, 1e-6), (16, 1e-4)]:
        M0, n = nicem.carpan_tablosu(M, bit, paylasimli_kaydirma=False)
        yak = M0.astype(np.float64) / 2.0 ** n.astype(np.float64)
        hata = float(np.max(np.abs(yak - M) / M))
        kontrol(f"M0 ayrıştırma hatası ({bit} bit) < {esik:g}", hata < esik,
                f"en büyük bağıl hata {hata:.2e}")


def test_sabit_nokta_yuvarlama():
    """sabit_nokta_carp, round(acc*M) ile en fazla 1 fark etmeli."""
    rng = np.random.default_rng(3)
    acc = rng.integers(-(2**20), 2**20, size=5000, dtype=np.int64)
    M = 3.7e-4
    M0, n = nicem.carpani_ayristir(M)
    bizim = nicem.sabit_nokta_carp(acc, M0, n)
    gercek = np.rint(acc.astype(np.float64) * M).astype(np.int64)
    fark = int(np.abs(bizim - gercek).max())
    kontrol("sabit noktalı çarpma, float yuvarlamadan en fazla 1 sapar", fark <= 1,
            f"en büyük sapma {fark} LSB")


def test_gelu_lut():
    """INT8 GELU tablosu, tam GELU'dan en fazla 1 LSB sapmalı."""
    s_in, s_out = 0.05, 0.02
    lut = dol.gelu_lut_uret(s_in, s_out)
    q = np.arange(S.AKT_MIN, S.AKT_MAX + 1)
    gercek = np.clip(np.rint(dol.gelu_fp(q * s_in) / s_out), S.AKT_MIN, S.AKT_MAX)
    fark = int(np.abs(lut - gercek).max())
    kontrol("GELU LUT == doğrudan hesap", fark == 0, f"256 girdide sapma {fark}")


def test_tamsayi_karekok():
    """Tamsayı karekök, floor(sqrt(v)) ile birebir aynı olmalı."""
    v = np.array([0, 1, 2, 3, 4, 99, 100, 101, 12345, 2**20, 2**30 + 7], dtype=np.int64)
    bizim = dol.tamsayi_karekok(v)
    gercek = np.floor(np.sqrt(v.astype(np.float64))).astype(np.int64)
    kontrol("tamsayı karekök == floor(sqrt)", bool(np.array_equal(bizim, gercek)),
            f"{list(bizim)}")


def test_softmax_tam():
    """Tamsayı softmax hatası, SKOR bit genişliğine bağlıdır.

    Bu test bir tasarım kararını belgeler: hata exp tablosundan değil,
    softmax'a giren skorların nicemleme adımından gelir. 8 bitlik skorla
    hata tabloyu ne kadar büyütürsen büyüt 0.024'te takılır; skor 12 bite
    çıkarıldığında 0.005'in altına iner. RTL'de dikkat skoru yolu bu yüzden
    8 bit DEĞİL, 12 bit tutulmalıdır.
    """
    rng = np.random.default_rng(4)
    skor = rng.normal(0, 3, size=(4, 2, 16, 16)).astype(np.float32)
    p_fp = dol.softmax_fp(skor).astype(np.float64)

    def hata(bit):
        s = float(np.abs(skor).max()) / (2 ** (bit - 1) - 1)
        q = nicem.nicele(skor, s, alt=-(2**31), ust=2**31 - 1)
        return float(np.abs(dol.softmax_tam(q, s).astype(np.float64) / 255.0 - p_fp).max())

    h8, h12 = hata(8), hata(12)
    kontrol("tamsayı softmax: 8 bit skor sınırı belgelendi", h8 < 0.03,
            f"8 bit skorla hata {h8:.4f} (tablo büyütmek bunu düşürmez)")
    kontrol("tamsayı softmax: 12 bit skorla hata < 0.01", h12 < 0.01,
            f"12 bit skorla hata {h12:.4f}")


def test_cevrim_tahmini():
    """Systolic dizi çevrim sayısı tutarlı olmalı (başarım tahmini için)."""
    d = birimler.SistolikDizi()
    c = d.cevrim_sayisi(T=64, C=128, K=128)
    kontrol("çevrim tahmini üretiliyor", c["toplam_cevrim"] > 0,
            f"64x128x128 -> {c['toplam_cevrim']} çevrim, "
            f"PE kullanımı %{100*c['pe_kullanimi']:.0f}")


if __name__ == "__main__":
    for f in [test_sistolik_birebir, test_birikec_genisligi, test_carpan_ayristirma,
              test_sabit_nokta_yuvarlama, test_gelu_lut, test_tamsayi_karekok,
              test_softmax_tam, test_cevrim_tahmini]:
        f()
    print(f"\n{len(GECTI)} geçti, {len(KALDI)} kaldı")
    if KALDI:
        print("KALAN TESTLER:", ", ".join(KALDI))
    raise SystemExit(1 if KALDI else 0)
