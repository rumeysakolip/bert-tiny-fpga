#!/usr/bin/env python3
"""yeniden_olcekle testbench vektorleri: y = kirp((acc*M0 + 2^(n-1)) >> n) -- SAF python tamsayilari (altin).
Dosyalar tb/vektor_rq/{ACC,M0,N,Y}.mem (hex, ikiye tumleyen) ve meta.mem. Yarim-yukari yuvarlama,
aritmetik kaydirma (python >> negatif sayilarda aritmetiktir)."""
import os
import random

DIZIN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "vektor_rq")


def rq(acc, m0, n):
    r = (1 << (n - 1)) if n > 0 else 0
    y = (acc * m0 + r) >> n
    return max(-128, min(127, y))


def main():
    rnd = random.Random(7)
    T = []
    I32MIN, I32MAX, M0MAX = -(2 ** 31), 2 ** 31 - 1, 2 ** 30 - 1
    # uc degerler
    for acc in (I32MIN, I32MAX, 0, 1, -1, 2 ** 22, -2 ** 22):
        for m0 in (0, 1, M0MAX, 2 ** 29):
            for n in (0, 1, 30, 31, 36, 42, 62):
                T.append((acc, m0, n))
    # yarim-yukari yuvarlama (tie) durumlari
    for n in range(1, 9):
        for acc in range(-40, 41):
            T.append((acc, 1, n))
            T.append((acc, 3, n))
    # gercekci araliklar: KAYDIRMA 36..42, M0 buyuk, acc ~ +-2^21 (gereken_bit <= 21)
    for _ in range(3000):
        n = rnd.choice([36, 37, 38, 42])
        T.append((rnd.randint(-2 ** 21, 2 ** 21), rnd.randint(2 ** 28, M0MAX), n))
    # tam aralik rastgele
    for _ in range(3000):
        T.append((rnd.randint(I32MIN, I32MAX), rnd.randint(0, M0MAX), rnd.randint(0, 62)))
    # y'nin sinira yakin oldugu: acc*m0 / 2^n ~ 127.5 , -128.5
    for _ in range(300):
        n = rnd.randint(20, 40)
        m0 = rnd.randint(2 ** 20, M0MAX)
        hedef = rnd.choice([127, 128, -128, -129])
        acc = int(((hedef << n) // m0)) + rnd.randint(-2, 2)
        if I32MIN <= acc <= I32MAX:
            T.append((acc, m0, n))
    os.makedirs(DIZIN, exist_ok=True)
    with open(os.path.join(DIZIN, "ACC.mem"), "w") as fa, open(os.path.join(DIZIN, "M0.mem"), "w") as fm, \
            open(os.path.join(DIZIN, "N.mem"), "w") as fn, open(os.path.join(DIZIN, "Y.mem"), "w") as fy:
        for acc, m0, n in T:
            fa.write(f"{acc & 0xFFFFFFFF:08x}\n")
            fm.write(f"{m0:08x}\n")
            fn.write(f"{n:02x}\n")
            fy.write(f"{rq(acc, m0, n) & 0xFF:02x}\n")
    with open(os.path.join(DIZIN, "meta.mem"), "w") as f:
        f.write(f"{len(T):x}\n")
    doy = sum(1 for a, m, n in T if abs((a * m + ((1 << (n - 1)) if n else 0)) >> n) > 127)
    print(f"{len(T)} test -> {DIZIN} (kirpilan: {doy})")


if __name__ == "__main__":
    main()
