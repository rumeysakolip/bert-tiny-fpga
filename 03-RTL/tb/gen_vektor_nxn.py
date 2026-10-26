#!/usr/bin/env python3
"""NxN akisli sistolik dizi icin test vektoru uretir (altin: numpy INT64 matmul).

C = A @ B ; A: (N,K) 9 bit isaretli [-256,255], B: (K,N) INT8, C: (N,N) INT32.
Cikti (tb/vektor_nxn/n<N>_k<K>/):
  A.mem    : test basina N*K eleman, 4 hane hex (16 bit iki'ye tumleyen), A[i][k] satir-oncelikli
  B.mem    : test basina K*N eleman, 2 hane hex, B[k][j] satir-oncelikli
  C.mem    : test basina N*N eleman, 8 hane hex (INT32)
  meta.mem : test sayisi (hex)
Kullanim: python tb/gen_vektor_nxn.py --N 8 --K 64 [--seed 1] [--rastgele 60]
"""
import argparse
import os

import numpy as np


def uc_durumlar(N, K):
    t = []
    f = lambda sek, v: np.full(sek, v, dtype=np.int64)
    t.append(("hepsi -128 x hepsi -128", f((N, K), -128), f((K, N), -128)))
    t.append(("hepsi 127 x hepsi 127", f((N, K), 127), f((K, N), 127)))
    t.append(("UINT8 255 x -128 (en kotu negatif)", f((N, K), 255), f((K, N), -128)))
    t.append(("UINT8 255 x 127 (en kotu pozitif)", f((N, K), 255), f((K, N), 127)))
    t.append(("A -128 x B 127", f((N, K), -128), f((K, N), 127)))
    t.append(("9 bit alt sinir -256 x -128", f((N, K), -256), f((K, N), -128)))
    t.append(("tum sifir", f((N, K), 0), f((K, N), 0)))
    t.append(("tum -1", f((N, K), -1), f((K, N), -1)))
    sira = (np.arange(N * K).reshape(N, K) % 2) * 2 - 1
    t.append(("isaret deseni", sira * 127, (np.arange(K * N).reshape(K, N) % 3 - 1) * 127))
    eye = np.zeros((N, K), dtype=np.int64)
    for i in range(min(N, K)):
        eye[i, i] = 1
    t.append(("A=I benzeri, B uc desen", eye, np.where(np.arange(K * N).reshape(K, N) % 2 == 0, -128, 127)))
    return t


def hex_yaz(yol, dizi, bit):
    basamak = (bit + 3) // 4
    m = (1 << bit) - 1
    with open(yol, "w", encoding="ascii") as f:
        for v in np.asarray(dizi).ravel():
            f.write(f"{int(v) & m:0{basamak}x}\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--N", type=int, default=8)
    ap.add_argument("--K", type=int, default=64)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--rastgele", type=int, default=60, help="tam aralikta (A 9 bit) rastgele test")
    ap.add_argument("--int8", type=int, default=60, help="A INT8 rastgele test")
    ap.add_argument("--uint8", type=int, default=60, help="A UINT8 (softmax olasiligi) rastgele test")
    ap.add_argument("--cikti", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "vektor_nxn"))
    a = ap.parse_args()
    N, K = a.N, a.K
    rng = np.random.default_rng(a.seed + 1000 * N + K)
    testler = uc_durumlar(N, K)
    for _ in range(a.rastgele):
        testler.append(("rastgele 9 bit", rng.integers(-256, 256, (N, K)), rng.integers(-128, 128, (K, N))))
    for _ in range(a.int8):
        testler.append(("rastgele INT8", rng.integers(-128, 128, (N, K)), rng.integers(-128, 128, (K, N))))
    for _ in range(a.uint8):
        testler.append(("rastgele UINT8", rng.integers(0, 256, (N, K)), rng.integers(-128, 128, (K, N))))
    A = np.stack([t[1] for t in testler]).astype(np.int64)
    B = np.stack([t[2] for t in testler]).astype(np.int64)
    C = np.einsum("tik,tkj->tij", A, B)
    assert A.min() >= -256 and A.max() <= 255 and B.min() >= -128 and B.max() <= 127
    assert np.abs(C).max() < 2**31, "INT32 tasmasi"
    d = os.path.join(a.cikti, f"n{N}_k{K}")
    os.makedirs(d, exist_ok=True)
    hex_yaz(os.path.join(d, "A.mem"), A, 16)
    hex_yaz(os.path.join(d, "B.mem"), B, 8)
    hex_yaz(os.path.join(d, "C.mem"), C, 32)
    with open(os.path.join(d, "meta.mem"), "w") as f:
        f.write(f"{len(testler):x}\n")
    print(f"N={N} K={K}: {len(testler)} test -> {d} (maks |C| = {int(np.abs(C).max())})")


if __name__ == "__main__":
    main()
