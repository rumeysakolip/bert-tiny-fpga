#!/usr/bin/env python3
"""Sistolik 4x4 testbench için test vektörü üretir.

C = A @ B  (INT8 x INT8 -> INT32, işaretli) numpy ile hesaplanır.
Çıktı dosyaları (tb/vektor/ altında, $readmemh biçimi, satır başına 1 eleman):
  A.mem    : test başına 16 eleman, 2 hane hex (iki'ye tümleyen), A[i][k] satır-öncelikli
  B.mem    : test başına 16 eleman, B[k][j] satır-öncelikli
  C.mem    : test başına 16 eleman, 8 hane hex (INT32), C[i][j] satır-öncelikli
  meta.mem : test sayısı (hex)
Kullanım:  python3 tb/gen_vektor.py [--seed 1] [--rastgele 200] [--cikti tb/vektor]
"""
import argparse
import os
import numpy as np

N = 4


def uc_durumlar():
    t = []
    f = lambda v: np.full((N, N), v, dtype=np.int8)
    t.append(("hepsi -128 x hepsi -128", f(-128), f(-128)))   # C = 4*16384
    t.append(("hepsi 127 x hepsi 127", f(127), f(127)))
    t.append(("hepsi -128 x hepsi 127", f(-128), f(127)))
    t.append(("hepsi 127 x hepsi -128", f(127), f(-128)))
    t.append(("tum sifir", f(0), f(0)))
    t.append(("tum -1", f(-1), f(-1)))
    t.append(("A sifir, B rastgele-uc", f(0), np.array([[-128, 127] * 2] * N, dtype=np.int8)))
    t.append(("A=-1, B=127", f(-1), f(127)))
    eye = np.eye(N, dtype=np.int8)
    t.append(("A=I, B=-128/127 desen", eye, np.array([[-128, 127, -128, 127],
                                                      [127, -128, 127, -128],
                                                      [-128, 127, -128, 127],
                                                      [127, -128, 127, -128]], dtype=np.int8)))
    return t


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--rastgele", type=int, default=200, help="tam aralıkta rastgele test sayısı")
    ap.add_argument("--uc_rastgele", type=int, default=50,
                    help="yalnızca {-128,-1,0,1,127} değerlerinden rastgele test sayısı")
    ap.add_argument("--cikti", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "vektor"))
    args = ap.parse_args()

    rng = np.random.default_rng(args.seed)
    testler = uc_durumlar()
    for i in range(args.rastgele):
        testler.append((f"rastgele {i}",
                        rng.integers(-128, 128, (N, N), dtype=np.int8),
                        rng.integers(-128, 128, (N, N), dtype=np.int8)))
    degerler = np.array([-128, -1, 0, 1, 127], dtype=np.int8)
    for i in range(args.uc_rastgele):
        testler.append((f"uc-rastgele {i}",
                        rng.choice(degerler, (N, N)), rng.choice(degerler, (N, N))))

    os.makedirs(args.cikti, exist_ok=True)
    with open(os.path.join(args.cikti, "A.mem"), "w") as fa, \
         open(os.path.join(args.cikti, "B.mem"), "w") as fb, \
         open(os.path.join(args.cikti, "C.mem"), "w") as fc, \
         open(os.path.join(args.cikti, "aciklama.txt"), "w") as fd:
        for idx, (ad, A, B) in enumerate(testler):
            C = A.astype(np.int32) @ B.astype(np.int32)       # INT32 referans
            assert C.dtype == np.int32
            for v in A.flatten():
                fa.write(f"{int(v) & 0xFF:02x}\n")
            for v in B.flatten():
                fb.write(f"{int(v) & 0xFF:02x}\n")
            for v in C.flatten():
                fc.write(f"{int(v) & 0xFFFFFFFF:08x}\n")
            fd.write(f"{idx}: {ad}\n")
    with open(os.path.join(args.cikti, "meta.mem"), "w") as fm:
        fm.write(f"{len(testler):x}\n")
    print(f"{len(testler)} test yazildi -> {args.cikti}")


if __name__ == "__main__":
    main()
