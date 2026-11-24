#!/usr/bin/env python3
"""G8: GELU LUT icin beklenen vektorler + bagimsiz dogrulama (yalniz .mem dosyalari, altin model kodu yok).

  1) l<i>_ffn1_gelu_cikis.mem = lut[ffn1_cikis + 128]  (tb_katman +sfx=gelu_cikis ile kullanilir)
  2) Altin modelin float izi ile capraz denetim: l<i>.gelu / olcek == lut cikisi  (varsa; yoksa atlanir)
  3) LUT dosyasi: 256 girdi, INT8; maksimum |LUT - gercek GELU| hatasi (cikis adimi cinsinden) -> json
Cikti: sim/g8_gelu.json (grafik icin: lut egrisi, hata), son satir "G8 HAZIRLIK: PASS".
"""
import json
import math
import os
import re
import sys

import numpy as np

KOK = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SON = os.path.join(KOK, "02-RTL_Altin_Model", "03_Sonuclar")
VEK, PAR = os.path.join(SON, "test_vektorleri"), os.path.join(SON, "parametreler")


def mem(yol, bit=8, imzali=True):
    v = [int(s.strip(), 16) for s in open(yol, encoding="ascii") if s.strip() and not s.startswith("//")]
    a = np.array(v, dtype=np.int64)
    return np.where(a >= (1 << (bit - 1)), a - (1 << bit), a) if imzali else a


def hex_yaz(yol, a, bit, ac):
    with open(yol, "w", encoding="ascii") as f:
        f.write(f"// {ac}\n")
        for v in np.asarray(a).ravel():
            f.write(f"{int(v) & ((1 << bit) - 1):0{(bit + 3) // 4}x}\n")


def gelu(x):
    return 0.5 * x * (1.0 + np.vectorize(math.erf)(x / math.sqrt(2.0)))


def main():
    ara = json.load(open(os.path.join(SON, "ara_olcekler.json"), encoding="utf-8"))["olcekler"]
    hata, kontrol, rapor = 0, 0, {}
    for i in range(2):
        lut = mem(os.path.join(PAR, f"l{i}_gelu_lut.mem"))
        assert lut.shape == (256,) and lut.min() >= -128 and lut.max() <= 127
        cik = mem(os.path.join(VEK, f"l{i}_ffn1_cikis.mem"))
        g = lut[cik + 128]
        hex_yaz(os.path.join(VEK, f"l{i}_ffn1_gelu_cikis.mem"), g, 8,
                f"l{i} ffn1 cikisi -> GELU LUT -> INT8 (lut[x+128]), sekil [n][T][512]")
        s_in, s_out = ara[f"l{i}.ffn1.cikis"], ara[f"l{i}.gelu"]
        x = np.arange(-128, 128) * s_in
        ideal = np.clip(np.rint(gelu(x) / s_out), -128, 127)
        fark = np.abs(lut - ideal)
        kontrol += 1
        if fark.max() != 0:                           # LUT tam olarak round(gelu/s_out) olmali
            hata += 1
            print(f"  FAIL l{i} LUT ideal degerden farkli: maks {int(fark.max())}")
        # float gercek GELU'ya gore kuantizasyon hatasi (cikis adimi cinsinden)
        gercek = gelu(x) / s_out
        rapor[f"l{i}"] = {"s_in": s_in, "s_out": s_out, "lut": lut.tolist(),
                          "maks_hata_adim": float(np.abs(np.clip(gercek, -128, 127) - lut).max()),
                          "kullanilan_giris_araligi": [int(cik.min()), int(cik.max())]}
    os.makedirs(os.path.join(KOK, "03-RTL", "sim"), exist_ok=True)
    json.dump(rapor, open(os.path.join(KOK, "03-RTL", "sim", "g8_gelu.json"), "w", encoding="utf-8"), indent=1)
    print(f"G8 HAZIRLIK: {'PASS' if hata == 0 else 'FAIL'} ({kontrol} LUT kontrolu, {hata} hata)")
    return 0 if hata == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
