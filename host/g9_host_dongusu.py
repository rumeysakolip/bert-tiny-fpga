#!/usr/bin/env python3
"""G9 kabul: PC -> (benzetilen) FPGA -> PC döngüsünde L0 doğrusal katmanları altın modelle birebir.

Her katman için PC: CFG, aktivasyon (altın <ad>_girdi_blok), panel panel ağırlık/bias/M0 akıtır, CALISTIR, bekler,
OKU_AKT ile çıkış BRAM'ini okur ve altın <ad>_cikis.mem ile karşılaştırır. Ayrıca bozuk CRC'li paket gönderir
(HATA beklenir). Kullanım:  python host/g9_host_dongusu.py [--katman l0_q l0_k ...] [--cumle 0]
Son satır: "G9 HOST-IN-THE-LOOP: PASS (...)".
"""
import argparse
import json
import os
import re
import sys

import numpy as np

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(KOK, "host"))
from hizlandirici_surucu import Hizlandirici, SimArkaUc, paket, CMD  # noqa: E402

RTL = os.path.join(KOK, "03-RTL")
SON = os.path.join(KOK, "02-RTL_Altin_Model", "03_Sonuclar")
VEK, PAR = os.path.join(SON, "test_vektorleri"), os.path.join(SON, "parametreler")


def mem(yol, bit, imzali=True):
    v = [int(s.strip(), 16) for s in open(yol, encoding="ascii") if s.strip() and not s.startswith("//")]
    a = np.array(v, dtype=object if bit == 64 else np.int64)
    if bit < 64 and imzali:
        a = np.where(a >= (1 << (bit - 1)), a - (1 << bit), a)
    return a


def kaydirma():
    d = {}
    for s in open(os.path.join(PAR, "parametreler.vh"), encoding="ascii"):
        m = re.match(r"localparam integer KAYDIRMA_(\w+)\s*=\s*(\d+);", s)
        if m:
            d[m.group(1).lower()] = int(m.group(2))
    return d


def katman_ekle(h, sim, ad, K, C, n, s):
    """Bir katmanın tüm adımlarını betiğe ekler; (okuma_paket_no, beklenen INT8 [64][C]) döndürür."""
    P, NB = C // 8, 8
    akt = mem(os.path.join(VEK, f"{ad}_girdi_blok.mem"), 64)[s * NB * K:(s + 1) * NB * K]
    W = mem(os.path.join(VEK, f"{ad}_w_panel.mem"), 64)
    b = mem(os.path.join(PAR, f"{ad}_b.mem"), 32)
    m0 = mem(os.path.join(PAR, f"{ad}_m0.mem"), 32, imzali=False)
    beklenen = mem(os.path.join(VEK, f"{ad}_cikis.mem"), 8)[s * 64 * C:(s + 1) * 64 * C].reshape(64, C)

    def panel_yukle(p):
        buf = p % 2
        h.yukle_panel(buf, 0, 0, b"".join(int(w).to_bytes(8, "little") for w in W[p * K:(p + 1) * K]))
        h.yukle_panel(buf, 1, 0, b"".join((int(v) & 0xFFFFFFFF).to_bytes(4, "little") for v in b[p * 8:(p + 1) * 8]))
        h.yukle_panel(buf, 2, 0, b"".join(int(v).to_bytes(4, "little") for v in m0[p * 8:(p + 1) * 8]))
        h.panel_hazir(buf)

    h.cfg(K, P, n)
    # aktivasyon tek paket (K=512: 32 KB < 64 KB)
    h.yukle_akt(0, akt)
    panel_yukle(0)
    if P > 1:
        panel_yukle(1)
    h.calistir()
    for p in range(2, P):
        sim.bekle_panel_bos(p % 2)
        panel_yukle(p)
    sim.bekle_bitti()
    h.oku_akt(0, NB * C)
    return len(sim.paketler) - 1, beklenen


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--katman", nargs="*", default=["l0_q", "l0_k", "l0_v", "l0_attn_out", "l0_ffn1", "l0_ffn2"])
    ap.add_argument("--cumle", type=int, default=0)
    ap.add_argument("--ad", default="g9_" + "dongu")
    a = ap.parse_args()

    kay = kaydirma()
    harita = json.load(open(os.path.join(PAR, "bellek_haritasi.json"), encoding="utf-8"))["katmanlar"]
    sim = SimArkaUc(RTL, calisma=f"sim/{a.ad}", vvp=f"sim/tb_hizlandirici_{a.ad}.vvp")
    sim.derle()
    h = Hizlandirici(sim)

    # 1) hata enjeksiyonu: bozuk CRC'li CFG ve bilinmeyen komut
    sim.gonder(paket(CMD["CFG"], (999).to_bytes(2, "little") + bytes([7, 7, 0]) + b"", bozuk_crc=True))
    sim.gonder(paket(0x55, b"\x01\x02"))
    hata_idx = [0, 1]

    okuma, bekle = {}, {}
    for ad in a.katman:
        K, C = harita[ad]["girdi"], harita[ad]["cikis_kanali"]
        okuma[ad], bekle[ad] = katman_ekle(h, sim, ad, K, C, kay[ad], a.cumle)

    yanit = sim.calistir()
    print(sim.log.strip().splitlines()[-1])
    assert len(yanit) == len(sim.paketler), f"yanıt sayısı {len(yanit)} != paket sayısı {len(sim.paketler)}"

    hata = 0
    rapor = {"cumle": a.cumle, "katmanlar": {}}
    # hata enjeksiyonu sonucu
    e1, e2 = yanit[0], yanit[1]
    enj_ok = e1["tur"] == "HATA" and e1["kod"] == 1 and e2["tur"] == "HATA" and e2["kod"] == 2
    print(f"  hata enjeksiyonu: bozuk CRC -> {e1['tur']}({e1.get('neden')}), bilinmeyen komut -> {e2['tur']}({e2.get('neden')}) : {'OK' if enj_ok else 'BEKLENMEYEN'}")
    hata += (not enj_ok)
    rapor["hata_enjeksiyonu"] = {"bozuk_crc": e1, "bilinmeyen_komut": e2, "ok": bool(enj_ok)}

    # tüm paketler ACK/VERI olmalı (enjekte edilenler hariç)
    kotu = [(i, y) for i, y in enumerate(yanit) if i not in hata_idx and y["tur"] == "HATA"]
    if kotu:
        print("  BEKLENMEYEN HATA yanıtları:", kotu[:3]); hata += 1

    for ad in a.katman:
        y = yanit[okuma[ad]]
        K, C = harita[ad]["girdi"], harita[ad]["cikis_kanali"]
        ok = y["tur"] == "VERI" and y["crc_ok"] and len(y["veri"]) == 8 * 8 * C
        fark = -1
        if ok:
            w = np.frombuffer(y["veri"], dtype=np.int8).reshape(8, C, 8)           # [blk][c][bayt i]
            cikis = w.transpose(0, 2, 1).reshape(64, C)                             # [token][c]
            fark = int(np.count_nonzero(cikis != bekle[ad]))
        sonuc = ok and fark == 0
        hata += (not sonuc)
        top_bayt = sum(len(p) for p in sim.paketler)
        rapor["katmanlar"][ad] = {"K": K, "C": C, "eleman": 64 * C, "uyusmayan": fark, "pass": bool(sonuc)}
        print(f"  {'PASS' if sonuc else 'FAIL'} {ad:12s} K={K} C={C}: {64 * C} eleman, uyuşmayan={fark}")

    top_gonderilen = sum(len(p) for p in sim.paketler)
    top_alinan = 8 * sum(8 * harita[k]["cikis_kanali"] for k in a.katman) + 5 * len(a.katman)
    rapor.update({"gonderilen_bayt": top_gonderilen, "paket_sayisi": len(sim.paketler),
                  "uart_921600_sn_tahmin": round((top_gonderilen + top_alinan) * 10 / 921600, 2),
                  "uart_3M_sn_tahmin": round((top_gonderilen + top_alinan) * 10 / 3_000_000, 2)})
    os.makedirs(os.path.join(RTL, "sim"), exist_ok=True)
    json.dump(rapor, open(os.path.join(RTL, "sim", f"{a.ad}_sonuc.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"G9 HOST-IN-THE-LOOP: {'PASS' if hata == 0 else 'FAIL'} ({len(a.katman)} katman, cümle {a.cumle}, {len(sim.paketler)} paket, "
          f"{top_gonderilen} bayt gönderildi, {hata} hata)")
    return 0 if hata == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
