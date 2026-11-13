"""Sabit parametrelerin (sapma, olcek carpani M0, kaydirma, GELU/tanh tablolari) gomulu bellek dosyalarini ve haritasini uretir.
Kaynak: 02-RTL_Altin_Model/03_Sonuclar/parametreler.   Cikti (04-RTL_Komutsuz/rtl): param_bias.mem, param_m0.mem, gelu_l0.mem, gelu_l1.mem, tanh.mem ve cizelge_ortak.v icindeki parametre_harita bolgesi
Kullanim (kok 04-RTL_Komutsuz): python scripts/uret_parametre_rom.py
"""
import json, os, shutil

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.abspath(os.path.join(KOK, ".."))
PAR = os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar", "parametreler")
RTL = os.path.join(KOK, "rtl")
bm = json.load(open(os.path.join(PAR, "bellek_haritasi.json"), encoding="utf-8"))["katmanlar"]

sira = [f"l{k}_{a}" for k in range(2) for a in ("q", "k", "v", "attn_out", "ffn1", "ffn2")] + ["pooler", "classifier"]
gelu_tablo = {"l0_ffn1": 1, "l1_ffn1": 2, "pooler": 3}      # 1: GELU katman 0, 2: GELU katman 1, 3: tanh


def oku(yol):
    return [l.strip() for l in open(yol, encoding="utf-8") if l.strip() and not l.startswith("//")]


bias_tum, m0_tum, taban, c = [], [], {}, {}
for ad in sira:
    b, m = oku(os.path.join(PAR, f"{ad}_b.mem")), oku(os.path.join(PAR, f"{ad}_m0.mem"))
    kanal = bm[ad]["cikis_kanali"]
    assert len(b) == kanal and len(m) == kanal, (ad, len(b), len(m), kanal)
    pad = (-kanal) % 8
    taban[ad] = len(bias_tum); c[ad] = kanal
    bias_tum += b + ["00000000"] * pad
    m0_tum += m + ["00000000"] * pad
# tek birlesik bellek: 48 bit = {sapma (16 bit isaretli), olcek carpani M0 (32 bit)}  -> bellek tasarrufu
birlesik = []
for b, m in zip(bias_tum, m0_tum):
    bv = int(b, 16)
    bs = bv - (1 << 32) if bv >= (1 << 31) else bv
    assert -(1 << 15) <= bs < (1 << 15), f"sapma 16 bite sigmiyor: {bs}"
    mv = int(m, 16)
    assert mv < (1 << 30), f"olcek carpani 30 bite sigmiyor: {mv}"
    birlesik.append(f"{(((bs & 0xFFFF) << 30) | mv):012x}")           # 46 bit: {sapma 16 bit isaretli, M0 30 bit}
open(os.path.join(RTL, "param_birlesik.mem"), "w").write("\n".join(birlesik) + "\n")
for eski in ("param_bias.mem", "param_m0.mem"):
    if os.path.exists(os.path.join(RTL, eski)):
        os.remove(os.path.join(RTL, eski))
for kaynak, hedef in (("l0_gelu_lut.mem", "gelu_l0.mem"), ("l1_gelu_lut.mem", "gelu_l1.mem"), ("tanh_lut.mem", "tanh.mem")):
    assert len(oku(os.path.join(PAR, kaynak))) == 256
    shutil.copy(os.path.join(PAR, kaynak), os.path.join(RTL, hedef))

K_ = {ad: bm[ad]["girdi"] for ad in sira}
satir = ["// uret_parametre_rom.py tarafindan uretildi; elle duzenlemeyin",
         f"localparam PARAMETRE_SAYISI = {len(bias_tum)};", f"localparam KATMAN_SAYISI = {len(sira)};"]


def fonk(ad, genislik, deger):
    s = [f"function [{genislik - 1}:0] {ad}; input integer i; begin case (i)"]
    for i, a in enumerate(sira):
        s.append(f"        {i}: {ad} = {genislik}'d{deger(a)};")
    s.append(f"        default: {ad} = {genislik}'d0; endcase end endfunction")
    return s


satir += fonk("katman_taban", 12, lambda a: taban[a])
satir += fonk("katman_k", 11, lambda a: K_[a])
satir += fonk("katman_c", 10, lambda a: c[a])
satir += fonk("katman_kaydirma", 6, lambda a: bm[a]["kaydirma_n"])
satir += fonk("katman_gelu", 2, lambda a: gelu_tablo.get(a, 0))
# katman adi (dosya yollari icin)
satir.append("function [8*16-1:0] katman_ad; input integer i; begin case (i)")
for i, a in enumerate(sira):
    satir.append(f'        {i}: katman_ad = "{a}";')
satir.append('        default: katman_ad = "yok"; endcase end endfunction')
open(os.path.join(RTL, "parametre_harita.vh"), "w").write("\n".join(satir) + "\n")
print("parametre sayisi", len(bias_tum), "| katman:", len(sira), "| taban:", taban)
