"""P1 — RTL parametrelerini çıkar (.mem / .vh / .json).

Üretilenler (hepsi `03_Sonuclar/parametreler/` altına):
    <kisa_ad>_w.mem    INT8 ağırlık, satır-öncelikli (çıkış kanalı x girdi)
    <kisa_ad>_b.mem    INT32 bias
    <kisa_ad>_m0.mem   kanal başına sabit noktalı çarpan M0
    gelu_lut.mem       INT8 -> INT8 GELU tablosu   (ara ölçek tablosu varsa)
    tanh_lut.mem       INT8 -> INT8 tanh tablosu   (ara ölçek tablosu varsa)
    parametreler.vh    Verilog `localparam` başlığı (bit genişlikleri, boyutlar)
    bellek_haritasi.json  her dosyanın boyutu + BRAM maliyeti

Dosya biçimi Vivado `$readmemh` ile birebir uyumludur: her satırda bir sözcük,
ikiye tümleyen (two's complement) onaltılık. Örnek:
    initial $readmemh("l0_q_w.mem", agirlik_bellegi);
"""

from __future__ import annotations

import argparse
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ortak  # noqa: E402
from altin import dogrusal_olmayan as dol  # noqa: E402
from altin import nicem, sabitler as S  # noqa: E402


def hex_yaz(yol: str, dizi: np.ndarray, bit: int, aciklama: str = ""):
    """İkiye tümleyen onaltılık, satır başına bir sözcük."""
    basamak = (bit + 3) // 4
    maske = (1 << bit) - 1
    with open(yol, "w", encoding="ascii") as f:
        if aciklama:
            f.write(f"// {aciklama}\n")
        for v in np.asarray(dizi).ravel():
            f.write(f"{int(v) & maske:0{basamak}x}\n")
    return os.path.getsize(yol)


def bram_blok(bit_sayisi: int) -> float:
    """Kaç adet BRAM36 (36 Kb) gerekir."""
    return bit_sayisi / (36 * 1024)


def main():
    ap = ortak.ortak_argumanlar(argparse.ArgumentParser(description=__doc__))
    ap.add_argument("--m0_bit", type=int, default=S.M0_BIT)
    ap.add_argument("--kanal_basina_kaydirma", action="store_true")
    ap.add_argument("--ara_olcek", default=None)
    a = ap.parse_args()

    sys.path.insert(0, ortak.HERE)
    from altin import parametreler
    y = ortak.kosu_yollari(a)
    p = parametreler.yukle(a.model_dizin, y["npz"], y["olcekler"])

    cikis = os.path.join(a.cikis, "parametreler")
    os.makedirs(cikis, exist_ok=True)

    ara_yol = a.ara_olcek or os.path.join(a.cikis, "ara_olcekler.json")
    ara = {}
    if os.path.exists(ara_yol):
        with open(ara_yol, encoding="utf-8") as f:
            ara = json.load(f)["olcekler"]

    katmanlar = []
    for k in p.katmanlar:
        katmanlar += [k.q, k.k, k.v, k.attn_cikis, k.ffn1, k.ffn2]
    katmanlar += [p.pooler, p.siniflandirici]

    harita, toplam_bit = {}, 0
    print(f"{'katman':14s} {'ağırlık':>14s} {'bias':>8s} {'M0':>6s} {'bit':>10s}")
    print("-" * 58)
    for kat in katmanlar:
        kisa = S.KISA_AD[kat.ad]
        C, K = kat.w_q.shape

        # Yeniden ölçekleme çarpanı: çıkış ölçeği biliniyorsa tam hedefe,
        # bilinmiyorsa yalnızca a_olcek*w_olcek olarak yazılır (A-kipi).
        s_out = ara.get(f"{S.IZLE_ADI[kat.ad]}.cikis")
        M = kat.cikis_olcek / s_out if s_out else kat.cikis_olcek
        M0, n = nicem.carpan_tablosu(M, a.m0_bit, not a.kanal_basina_kaydirma)

        b_w = hex_yaz(os.path.join(cikis, f"{kisa}_w.mem"), kat.w_q, S.AGIRLIK_BIT,
                      f"{kat.ad}  ({C} cikis kanali x {K} girdi), INT8 satir-oncelikli")
        b_b = hex_yaz(os.path.join(cikis, f"{kisa}_b.mem"), kat.bias_q, S.BIAS_BIT,
                      f"{kat.ad} bias, INT32, olcek = a_olcek*w_olcek")
        b_m = hex_yaz(os.path.join(cikis, f"{kisa}_m0.mem"), M0, a.m0_bit,
                      f"{kat.ad} yeniden olcekleme carpani M0 (kaydirma n={n})")

        bit = C * K * S.AGIRLIK_BIT + C * S.BIAS_BIT + C * a.m0_bit
        toplam_bit += bit
        harita[kisa] = {
            "katman": kat.ad, "cikis_kanali": C, "girdi": K,
            "agirlik_bayt": C * K, "bias_bayt": C * 4,
            "a_olcek": kat.a_olcek, "kaydirma_n": int(n) if np.ndim(n) == 0 else None,
            "cikis_olcek_kalibre": s_out,
            "dosyalar": {"w": f"{kisa}_w.mem", "b": f"{kisa}_b.mem", "m0": f"{kisa}_m0.mem"},
            "bit": bit, "bram36": round(bram_blok(bit), 3),
        }
        print(f"{kisa:14s} {f'{C}x{K}':>14s} {C:8d} {C:6d} {bit:10d}")

    # --- LUT'lar (ara ölçek tablosu varsa) ---
    if ara:
        for i in range(S.KATMAN_SAYISI):
            s_in, s_out = ara.get(f"l{i}.ffn1.cikis"), ara.get(f"l{i}.gelu")
            if s_in and s_out:
                lut = dol.gelu_lut_uret(s_in, s_out)
                hex_yaz(os.path.join(cikis, f"l{i}_gelu_lut.mem"), lut, S.AKTIVASYON_BIT,
                        f"GELU INT8->INT8, girdi olcek={s_in:.6e} cikis olcek={s_out:.6e}")
                toplam_bit += 256 * 8
        s_in, s_out = ara.get("pooler.cikis"), ara.get("pooler.tanh")
        if s_in and s_out:
            hex_yaz(os.path.join(cikis, "tanh_lut.mem"),
                    dol.tanh_lut_uret(s_in, s_out), S.AKTIVASYON_BIT,
                    f"tanh INT8->INT8, girdi olcek={s_in:.6e} cikis olcek={s_out:.6e}")
            toplam_bit += 256 * 8
        for i in range(S.KATMAN_SAYISI):
            s = ara.get(f"l{i}.skor")
            if s:
                hex_yaz(os.path.join(cikis, f"l{i}_exp_lut.mem"),
                        dol.exp_lut_uret(), 16, f"softmax exp tablosu, menzil={dol.SOFTMAX_MENZIL}, skor olcek={s:.6e}")
                toplam_bit += 256 * 16
    else:
        print("\n(ara_olcekler.json yok -> GELU/tanh/exp tabloları atlandı; "
              "önce 03_kalibre_ara_olcek.py çalıştırın)")

    # --- Verilog başlığı ---
    vh = os.path.join(cikis, "parametreler.vh")
    with open(vh, "w", encoding="ascii") as f:
        f.write("// BERT-Tiny hizlandirici - altin modelden uretilmistir. ELLE DEGISTIRMEYIN.\n")
        f.write("// Kaynak: 03-RTL_Altin_Model/01_Kod/00_parametre_cikar.py\n\n")
        for ad, deg in [
            ("GIZLI_BOYUT", S.GIZLI_BOYUT), ("ARA_BOYUT", S.ARA_BOYUT),
            ("BASLIK_SAYISI", S.BASLIK_SAYISI), ("BASLIK_BOYU", S.BASLIK_BOYU),
            ("KATMAN_SAYISI", S.KATMAN_SAYISI), ("DIZI_UZUNLUGU", S.DIZI_UZUNLUGU),
            ("AKTIVASYON_BIT", S.AKTIVASYON_BIT), ("AGIRLIK_BIT", S.AGIRLIK_BIT),
            ("BIRIKEC_BIT", S.BIRIKEC_BIT), ("BIAS_BIT", S.BIAS_BIT),
            ("M0_BIT", a.m0_bit), ("PE_SATIR", S.PE_SATIR), ("PE_SUTUN", S.PE_SUTUN),
            ("K_DILIM", S.K_DILIM), ("GELU_LUT_BOYU", S.GELU_LUT_BOYU),
        ]:
            f.write(f"localparam integer {ad:16s} = {deg};\n")
        f.write("\n// Katman basina kaydirma miktarlari\n")
        for kisa, d in harita.items():
            if d["kaydirma_n"] is not None:
                f.write(f"localparam integer KAYDIRMA_{kisa.upper():14s} = {d['kaydirma_n']};\n")

    with open(os.path.join(cikis, "bellek_haritasi.json"), "w", encoding="utf-8") as f:
        json.dump({"toplam_bit": toplam_bit,
                   "toplam_kb": round(toplam_bit / 8 / 1024, 1),
                   "bram36_gerekli": round(bram_blok(toplam_bit), 1),
                   "basys3_bram36": 50,
                   "tek_seferde_sigar_mi": bram_blok(toplam_bit) <= 50,
                   "katmanlar": harita}, f, ensure_ascii=False, indent=2)

    kb = toplam_bit / 8 / 1024
    br = bram_blok(toplam_bit)
    print(f"\nToplam: {kb:.1f} KB  ->  {br:.1f} BRAM36 blok "
          f"(Basys3'te 50 var: {'SIĞAR' if br <= 50 else 'SIĞMAZ'})")
    if br > 50:
        enb = max(harita.values(), key=lambda d: d["bram36"])
        print(f"  En büyük tek katman: {enb['katman']} -> {enb['bram36']} BRAM36")
        print("  -> Katman katman yükleme (ağırlıkları UART/flash üzerinden akıtma) gerekir.")
    print(f"Çıktılar: {cikis}")


if __name__ == "__main__":
    main()
