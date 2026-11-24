"""GELU tablosu + ileri besleme 2 girdisine yeniden olcekleme TEK tabloda (256 giris, ek gecis yok).
Altin modelin tam tamsayi hatti: g_q = gelu_tablosu[ffn1_cikis_q];  ffn2_girdisi = kirp((g_q*M0 + 2^(n-1)) >> n)  (olcek s_gelu -> ffn2.a_olcek).
Iki adim yalnizca 8 bitlik g_q'ya bagli oldugundan birlesik tablo  T'[x] = yeniden_olcekle(gelu_tablosu[x])  bit-birebir aynidir.
Cikti: rtl/gelu_ffn2_l0.mem, rtl/gelu_ffn2_l1.mem; dogrulama: vektorlerdeki l<i>_ffn2_girdi.mem ile (tum cumleler).
Kullanim: python scripts/uret_gelu_birlesik.py
"""
import argparse, json, os, sys
import numpy as np

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.abspath(os.path.join(KOK, ".."))
sys.path.insert(0, os.path.join(PROJE, "02-RTL_Altin_Model", "01_Kod"))
import ortak  # noqa: E402
from altin import model, nicem, sabitler as S  # noqa: E402

ap = ortak.ortak_argumanlar(argparse.ArgumentParser())
a = ap.parse_args([])
p, _, cumleler, etiket, ids, maske, y = ortak.yukle_hepsi(a)
ara = json.load(open(os.path.join(a.cikis, "ara_olcekler.json"), encoding="utf-8"))["olcekler"]
m = model.AltinModel(p, model.Ayarlar.B_kipi(tasima_adim=model.TASIMA_ADIMLARI), ara)
VEK = os.path.join(a.cikis, "test_vektorleri")


def oku8(yol):
    return np.array([int(l, 16) for l in (x.strip() for x in open(yol)) if l and not l.startswith("//")], dtype=np.int64)


def i8(v):
    return v - 256 if v > 127 else v


for L in range(2):
    kat = p.katmanlar[L] if hasattr(p, "katmanlar") else p.kodlayici[L]
    s_gelu = float(ara[f"l{L}.gelu"]); a_ol = float(kat.ffn2.a_olcek)
    tablo = np.array([i8(v) for v in oku8(os.path.join(KOK, "rtl", f"gelu_l{L}.mem"))[:256]], dtype=np.int64)
    oran = s_gelu / a_ol
    if abs(oran - 1.0) < 1e-12:
        yeni = nicem.kirp(tablo, S.AKT_MIN, S.AKT_MAX)
        sabit = "kimlik"
    else:
        M0, n = nicem.carpani_ayristir(oran, m.ayar.m0_bit)
        yeni = nicem.kirp(nicem.sabit_nokta_carp(tablo, M0, n), S.AKT_MIN, S.AKT_MAX).astype(np.int64)
        sabit = f"M0={M0} n={n}"
    # dogrulama: ffn1 cikisi -> birlesik tablo -> ffn2 girdisi
    x1 = oku8(os.path.join(VEK, f"l{L}_ffn1_cikis.mem"))
    g2 = oku8(os.path.join(VEK, f"l{L}_ffn2_girdi.mem"))
    xs = np.array([i8(v) for v in x1], dtype=np.int64)
    beklenen = np.array([i8(v) for v in g2], dtype=np.int64)
    # tablo adresi = isaretli girdi + 128 (0..255)
    uretilen = np.array([yeni[(v + 128) & 0xFF] for v in xs])
    esit = int((uretilen == beklenen).sum()); toplam = len(beklenen)
    print(f"katman {L}: s_gelu={s_gelu:.6e} ffn2.a_olcek={a_ol:.6e} oran={oran:.9f} {sabit}; birlesik tablo vs ffn2 girdisi: {esit}/{toplam} esit")
    assert esit == toplam, "birlesik tablo altin modelle uyusmuyor"
    with open(os.path.join(KOK, "rtl", f"gelu_ffn2_l{L}.mem"), "w") as f:
        f.write(f"// GELU + ffn2 girdi yeniden olcekleme (katman {L}); {sabit}\n")
        for v in yeni:
            f.write(f"{int(v) & 0xFF:02x}\n")
print("TAMAM")
