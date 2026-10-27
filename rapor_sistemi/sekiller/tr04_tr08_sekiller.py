"""TR04 (tile denetleyici), TR05 (yeniden ölçekleme), TR06 (doğrusal katman), TR07 (GELU), TR08 (host arayüzü) şekilleri.
Hepsi sim/*.json ve VCD dosyalarından üretilir; elle sayı yok (hesap olan şekiller başlıkta 'hesap' yazar)."""
import glob
import re

import numpy as np

from tr_ortak import *   # noqa
import vcd_ciz

HARITA = json_oku(os.path.join(SONUC, "parametreler", "bellek_haritasi.json"))["katmanlar"]
KAY = {}
for s in open(os.path.join(SONUC, "parametreler", "parametreler.vh"), encoding="ascii"):
    m = re.match(r"localparam integer KAYDIRMA_(\w+)\s*=\s*(\d+);", s)
    if m:
        KAY[m.group(1).lower()] = int(m.group(2))


def g7():
    return json_oku(os.path.join(RTL, "sim", "g7_sonuc.json"))["sonuclar"]


# ---------------------------------------------------------------- TR04
def tr04():
    K, C = 128, 128
    # S1: tile haritası ve işlenme sırası (panel dış, token bloğu iç)
    fig, ax = plt.subplots(figsize=(6.0, 3.6))
    P, NB = C // 8, 64 // 8
    sira = np.zeros((NB, P), dtype=int)
    for p in range(P):
        for b in range(NB):
            sira[b, p] = p * NB + b + 1
    im = ax.imshow(sira, cmap="YlGnBu", aspect="auto")
    for p in range(0, P, 3):
        for b in range(NB):
            ax.text(p, b, str(sira[b, p]), ha="center", va="center", fontsize=5.5, color="black" if sira[b, p] < 70 else "white")
    ax.set_xlabel("Çıkış paneli p (8 kanal) → host her panel için 1 088 B akıtır"); ax.set_ylabel("Token bloğu b (8 token)")
    ax.set_title("l0_q: 64×128 çıktı = 8×16 tile ızgarası, sayılar işlenme sırası")
    fig.colorbar(im, ax=ax, label="tile sırası")
    kaydet(fig, "tr04_s1_tile_haritasi.png")

    # S2: panel yükleme ↔ hesap (log ölçek, hesap): UART süresi hesap süresinden çok uzun
    byte_panel = 8 * K + 8 * 4 + 8 * 4 + 3 * 8         # W + bias + M0 + 3 paketin başlık/CRC'si
    hesap_cevrim = 8 * (K + 15)
    f = 100e6
    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    etiket = ["Hesap\n(8 tile, 100 MHz)", "UART 3 Mbaud\n(tahmin)", "UART 921600\n(tahmin)"]
    deger = [hesap_cevrim / f * 1e6, byte_panel * 10 / 3e6 * 1e6, byte_panel * 10 / 921600 * 1e6]
    ax.bar(etiket, deger, color=[YESIL, TURUNCU, KIRMIZI]); ax.set_yscale("log"); ax.set_ylabel("Bir panel için süre (µs, log)")
    for i, v in enumerate(deger):
        ax.text(i, v * 1.15, f"{v:,.1f} µs".replace(",", " "), ha="center", fontsize=7)
    ax.set_title(f"Panel başına süre: hesap {hesap_cevrim} çevrim, aktarım {byte_panel} bayt (hesap)")
    ax.text(0.5, 0.97, f"UART/hesap ≈ {deger[2] / deger[0]:.0f}×", transform=ax.transAxes, ha="center", va="top", fontsize=8, color=KIRMIZI)
    kaydet(fig, "tr04_s2_zaman.png")

    # S3: BRAM yerleşimi (RTL parametrelerinden hesap)
    fig, ax = plt.subplots(figsize=(6.0, 2.8)); ax.axis("off"); ax.set_xlim(0, 10); ax.set_ylim(0, 4)
    bram = lambda bit: bit / (36 * 1024)
    kutular = [("aktivasyon BRAM\n(girdi)", 8 * 512 * 64, ACIK_MAVI), ("panel tamponu\n2×(W 512 + bias/m0)", 2 * 512 * 64 + 2 * 8 * 63, TURUNCU),
               ("çıkış BRAM", 8 * 512 * 64, YESIL)]
    for i, (ad, bit, r) in enumerate(kutular):
        kutu(ax, 0.3 + i * 3.3, 1.6, 3.0, 1.5, f"{ad}\n{bit // 8 // 1024} KB (en kötü: K/C=512)\n≈{bram(bit):.1f} BRAM36", r, 7)
    ax.text(5, 0.8, f"Toplam ≈ {sum(bram(b) for _, b, _ in kutular):.1f} BRAM36 (hesap, tahmin; Basys3: 50)", ha="center", fontsize=8)
    ax.text(5, 0.3, "Sözcük: 64 bit; aktivasyon/çıkış adresi = blok·K + k (8 token/sözcük), panel adresi = k (8 kanal/sözcük)", ha="center", fontsize=6.5)
    ax.set_title("Bellek yerleşimi")
    kaydet(fig, "tr04_s3_bram.png")

    # S4: tile dalga formu
    vcd = os.path.join(RTL, "sim", "tb_tile_k128.vcd")
    if os.path.exists(vcd):
        sig = ["tb_tile.dut.state", "tb_tile.dut.start_now", "tb_tile.dut.sys_done", "tb_tile.dut.blk", "tb_tile.dut.o_run", "tb_tile.out_valid"]
        fig, ax = plt.subplots(figsize=(6.3, 3.0))
        vcd_ciz.dalga_ciz(vcd, sig, 0, 3300, ax=ax, baslik="l0_q ilk iki tile: ardışık başlatma, golge acc akıtması hesapla örtüşür")
        kaydet(fig, "tr04_s4_dalga.png")

    # S5: teorik vs benzetim çevrim (12 katman)
    r = g7()
    fig, ax = plt.subplots(figsize=(6.0, 3.0))
    x = np.arange(len(r)); w = 0.38
    ax.bar(x - w / 2, [s["cevrim_teorik"] for s in r], w, label="teorik (K+14)·P·8", color=ACIK_MAVI)
    ax.bar(x + w / 2, [s["cevrim_olculen"] for s in r], w, label="benzetim (kos→layer_done)", color=TURUNCU)
    ax.set_xticks(x); ax.set_xticklabels([s["ad"] for s in r], rotation=40, ha="right", fontsize=6)
    ax.set_ylabel("Çevrim"); ax.legend(fontsize=7)
    fark = [100 * (s["cevrim_olculen"] / s["cevrim_teorik"] - 1) for s in r]
    ax.set_title(f"Katman başına çevrim: ölçüm teorikten %{min(fark):.1f}–%{max(fark):.1f} fazla (tile başı +1, panel geçişi, boşaltma)")
    kaydet(fig, "tr04_s5_cevrim.png")


# ---------------------------------------------------------------- TR05
def tr05():
    # S1: boru hattı
    fig, ax = plt.subplots(figsize=(6.3, 2.6)); ax.set_xlim(0, 12); ax.set_ylim(0, 4); ax.axis("off")
    adimlar = [("birikeç+bias\nINT32", "#DDDDDD"), ("A1: × M0\n32b × 31b → 64b", TURUNCU), ("A2: + 2^(n−1)\n64b", ACIK_MAVI), ("A3: >>> n\nkırp [−128,127]", YESIL), ("INT8", "#DDDDDD")]
    for i, (t, r) in enumerate(adimlar):
        kutu(ax, 0.2 + i * 2.4, 1.2, 2.0, 1.4, t, r, 7)
        if i:
            ok(ax, 0.2 + i * 2.4 - 0.4, 1.9, 0.2 + i * 2.4, 1.9)
    ax.text(6, 0.4, "M0 (31 bit, kanal başına) ve n (6 bit, katman başına) parametre paketinden; 3 çevrim gecikme, çevrim başına 1 eleman", ha="center", fontsize=6.5)
    ax.set_title("yeniden_olcekle.v boru hattı")
    kaydet(fig, "tr05_s1_boru.png")

    # S2: KAYDIRMA_n ve M0 aralığı (14 katman)
    ad = list(HARITA.keys())
    n = [KAY[a] for a in ad]
    m0 = {}
    for a in ad:
        v = [int(s.strip(), 16) for s in open(os.path.join(SONUC, "parametreler", f"{a}_m0.mem"), encoding="ascii") if s.strip() and not s.startswith("//")]
        m0[a] = (min(v), max(v))
    fig, (a1, a2) = plt.subplots(2, 1, figsize=(6.3, 4.2), sharex=True)
    a1.bar(range(len(ad)), n, color=MAVI); a1.set_ylabel("n (kaydırma)"); a1.set_ylim(30, 44)
    for i, v in enumerate(n):
        a1.text(i, v + 0.3, str(v), ha="center", fontsize=6)
    a2.vlines(range(len(ad)), [np.log2(max(m0[a][0], 1)) for a in ad], [np.log2(m0[a][1]) for a in ad], color=TURUNCU, lw=5)
    a2.axhline(30, color=KIRMIZI, ls="--", lw=1); a2.text(len(ad) - 0.5, 30.1, "M0 üst sınırı 2^30", ha="right", fontsize=6.5, color=KIRMIZI)
    a2.set_ylabel("log2(M0) aralığı"); a2.set_xticks(range(len(ad))); a2.set_xticklabels(ad, rotation=45, ha="right", fontsize=6)
    a1.set_title("Katman başına yeniden ölçekleme sabitleri (parametre paketi)")
    kaydet(fig, "tr05_s2_sabitler.png")

    # S3: kırpılan eleman sayısı (G7) ve S4: birim testi
    r = g7()
    fig, ax = plt.subplots(figsize=(6.0, 2.6))
    ax.bar([s["ad"] for s in r], [s["kirpilan_eleman"] for s in r], color=MAVI)
    ax.set_ylabel("Kırpılan eleman (4 cümle)"); plt.setp(ax.get_xticklabels(), rotation=40, ha="right", fontsize=6)
    ax.set_title("Doyumlu kırpma: katman başına kırpılan INT8 çıktı sayısı (benzetim sayacı)")
    kaydet(fig, "tr05_s3_kirpma.png")

    fig, ax = plt.subplots(figsize=(6.0, 2.3))
    gruplar = ["uç değerler", "yarım-yukarı\nyuvarlama", "gerçekçi\n(n=36–42)", "tam aralık\nrastgele", "kırpma\nsınırı"]
    adet = [196, 1296, 3000, 3000, 300]
    ax.bar(gruplar, adet, color=YESIL)
    for i, v in enumerate(adet):
        ax.text(i, v + 60, f"{v}\n0 hata", ha="center", fontsize=6.5)
    ax.set_ylabel("Test vektörü"); ax.set_ylim(0, 3800)
    ax.set_title("yeniden_olcekle birim testi: 7792 vektör, saf Python tamsayı altınıyla 0 hata")
    kaydet(fig, "tr05_s4_birim.png")


# ---------------------------------------------------------------- TR06
def tr06():
    fig, ax = plt.subplots(figsize=(6.3, 3.0)); ax.set_xlim(0, 12); ax.set_ylim(0, 5); ax.axis("off")
    kutu(ax, 0.2, 3.0, 2.0, 1.2, "aktivasyon BRAM\n(girdi)", ACIK_MAVI, 7); kutu(ax, 0.2, 0.6, 2.0, 1.2, "panel tamponu\n(çift)", TURUNCU, 7)
    kutu(ax, 3.2, 1.7, 2.4, 1.6, "tile denetleyici\n+ 8×8 dizi\n+ gölge acc", "#CFE6F6", 7)
    kutu(ax, 6.4, 1.9, 1.7, 1.2, "+bias\nyeniden\nölçekle", YESIL, 7); kutu(ax, 8.6, 2.0, 1.2, 1.0, "GELU\nLUT", "#EEDD99", 7)
    kutu(ax, 10.2, 1.7, 1.6, 1.6, "paketle\n→ çıkış\nBRAM", ACIK_MAVI, 7)
    ok(ax, 2.2, 3.4, 3.2, 2.9); ok(ax, 2.2, 1.4, 3.2, 2.1); ok(ax, 5.6, 2.5, 6.4, 2.5); ok(ax, 8.1, 2.5, 8.6, 2.5); ok(ax, 9.8, 2.5, 10.2, 2.5)
    ax.text(6, 0.4, "Aynı modül Q, K, V, attn_out, ffn1, ffn2 için; (K, np, n, GELU) kos öncesi konfigüre edilir", ha="center", fontsize=7)
    ax.set_title("dogrusal_katman.v veri yolu")
    kaydet(fig, "tr06_s1_katman.png")

    r = g7()
    fig, ax = plt.subplots(figsize=(6.0, 3.0))
    kont = [64 * s["C"] * 4 for s in r]            # 4 cümle × 64 token × C kanal
    ax.bar([s["ad"] for s in r], kont, color=[YESIL if s["pass"] else KIRMIZI for s in r])
    for i, (s, k) in enumerate(zip(r, kont)):
        ax.text(i, k + 800, "PASS" if s["pass"] else "FAIL", ha="center", fontsize=6)
    ax.set_ylabel("Karşılaştırılan INT8 çıktı"); plt.setp(ax.get_xticklabels(), rotation=40, ha="right", fontsize=6)
    ax.set_title("Altın <ad>_cikis.mem ile bit-birebir doğrulama (4 cümle, hata=0 ise yeşil)")
    kaydet(fig, "tr06_s2_dogrulama.png")

    fig, ax = plt.subplots(figsize=(6.0, 3.0))
    ax.bar([s["ad"] for s in r], [s["cevrim_olculen"] / 1e3 for s in r], color=MAVI)
    ax.set_ylabel("Çevrim (bin) / cümle"); plt.setp(ax.get_xticklabels(), rotation=40, ha="right", fontsize=6)
    top = sum(s["cevrim_olculen"] for s in r if s["ad"].startswith("l0"))
    ax.set_title(f"Katman başına çevrim; L0 doğrusal katmanlar toplamı {top / 1e3:.0f} bin çevrim = {top / 100e6 * 1e3:.2f} ms @100 MHz (yalnız hesap)")
    kaydet(fig, "tr06_s3_cevrim.png")


# ---------------------------------------------------------------- TR07 (GELU)
def tr07():
    g = json_oku(os.path.join(RTL, "sim", "g8_gelu.json"))
    fig, ax = plt.subplots(figsize=(6.0, 3.0))
    for i, r in zip(("l0", "l1"), (MAVI, TURUNCU)):
        d = g[i]; x = np.arange(-128, 128) * d["s_in"]
        ax.plot(x, np.array(d["lut"]) * d["s_out"], ".", ms=2.5, color=r, label=f"{i} tamsayı LUT")
    xx = np.linspace(-12, 12, 400)
    from math import erf, sqrt
    ax.plot(xx, [0.5 * v * (1 + erf(v / sqrt(2))) for v in xx], "-", color=GRI, lw=0.8, label="FP32 GELU")
    ax.set_xlim(-12, 12); ax.set_ylim(-1, 12); ax.set_xlabel("GELU girdisi"); ax.set_ylabel("GELU çıktısı"); ax.legend(fontsize=7)
    ax.set_title("GELU: tamsayı LUT ve FP32")
    kaydet(fig, "tr07_s1_lut.png")
    fig, ax = plt.subplots(figsize=(6.0, 2.4))
    ax.bar(["l0", "l1"], [g["l0"]["maks_hata_adim"], g["l1"]["maks_hata_adim"]], color=[MAVI, TURUNCU])
    for i, k in enumerate(("l0", "l1")):
        ax.text(i, g[k]["maks_hata_adim"] + 0.01, f"{g[k]['maks_hata_adim']:.2f}", ha="center", fontsize=8)
    ax.axhline(0.5, color=KIRMIZI, ls="--", lw=1); ax.text(1.4, 0.51, "yuvarlama sınırı 0,5", color=KIRMIZI, fontsize=7, ha="right")
    ax.set_ylabel("Maks |LUT − gerçek GELU| (çıkış adımı)")
    ax.set_title("LUT'un FP32 GELU'ya göre en büyük hatası")
    kaydet(fig, "tr07_s2_hata.png")


# ---------------------------------------------------------------- TR08
def tr08():
    fig, ax = plt.subplots(figsize=(6.3, 3.2)); ax.set_xlim(0, 12); ax.set_ylim(0, 6); ax.axis("off")
    kutu(ax, 0.2, 0.4, 4.4, 5.0, "", "#F3F3F3"); ax.text(2.4, 5.1, "PC (host, Python)", ha="center", fontsize=8, fontweight="bold")
    kutu(ax, 7.4, 0.4, 4.4, 5.0, "", "#F3F3F3"); ax.text(9.6, 5.1, "FPGA (Basys3, RTL)", ha="center", fontsize=8, fontweight="bold")
    for i, t in enumerate(["tokenizer, gömme, LN (şimdilik)", "ağırlık/bias/M0 paketleme", "panel sıralama, CRC", "hizlandirici_surucu.py"]):
        kutu(ax, 0.5, 3.9 - i * 0.9, 3.8, 0.7, t, ACIK_MAVI, 6.5)
    for i, t in enumerate(["komut_cozucu + UART", "aktivasyon / panel BRAM", "tile denetleyici + 8×8 dizi", "yeniden ölçekle → çıkış BRAM"]):
        kutu(ax, 7.7, 3.9 - i * 0.9, 3.8, 0.7, t, TURUNCU, 6.5)
    ok(ax, 4.6, 3.0, 7.4, 3.0, MAVI, "paket (CFG/YUKLE/CALISTIR)"); ok(ax, 7.4, 2.0, 4.6, 2.0, KIRMIZI, "ACK / HATA / VERI")
    ax.text(6, 0.1, "USB-UART 8N1 (921600 / 3 Mbaud)", ha="center", fontsize=7)
    ax.set_title("Sistem: PC ve FPGA iş bölümü")
    kaydet(fig, "tr08_s1_sistem.png")

    fig, ax = plt.subplots(figsize=(6.3, 2.4)); ax.set_xlim(0, 12); ax.set_ylim(0, 3); ax.axis("off")
    alan = [("cmd\n1 B", 1.0), ("len\n2 B (LE)", 1.6), ("payload\nlen B", 4.0), ("crc8\n1 B", 1.0)]
    x = 0.4
    for i, (t, w) in enumerate(alan):
        kutu(ax, x, 1.5, w * 1.3, 1.0, t, [ACIK_MAVI, ACIK_MAVI, TURUNCU, YESIL][i], 7); x += w * 1.3 + 0.1
    ax.text(6, 0.9, "crc8: poly 0x07, init 0, cmd+len+payload üzerinden. Yanıt: ACK=06 cmd | HATA=15 cmd kod | VERI=02 cmd len veri crc8", ha="center", fontsize=6.5)
    ax.text(6, 0.35, "CFG 01 · YUKLE_AKT 02 · YUKLE_PANEL 03 · CALISTIR 04 · OKU_AKT 05 · DURUM 06 · PANEL_HAZIR 07", ha="center", fontsize=6.5)
    ax.set_title("Paket biçimi")
    kaydet(fig, "tr08_s2_paket.png")

    # S3: panel akışı zaman çizgesi (host <-> FPGA)
    fig, ax = plt.subplots(figsize=(6.3, 3.2)); ax.set_xlim(0, 12); ax.set_ylim(0, 8); ax.axis("off")
    ax.text(2, 7.6, "PC", ha="center", fontweight="bold"); ax.text(10, 7.6, "FPGA", ha="center", fontweight="bold")
    ax.plot([2, 2], [0.3, 7.3], color=GRI); ax.plot([10, 10], [0.3, 7.3], color=GRI)
    mesaj = [("CFG", 1), ("YUKLE_AKT (8·K sözcük)", 1), ("YUKLE_PANEL 0 → buf0 + PANEL_HAZIR", 1), ("YUKLE_PANEL 1 → buf1 + PANEL_HAZIR", 1),
             ("CALISTIR", 1), ("… panel 0 hesaplanır, buf0 boşalır (pan_bos[0]=1) …", 0), ("YUKLE_PANEL 2 → buf0 + PANEL_HAZIR", 1),
             ("… son panel …  DURUM: layer_done=1", 0), ("OKU_AKT → VERI (çıkış BRAM)", 2)]
    for i, (t, yon) in enumerate(mesaj):
        y = 6.8 - i * 0.72
        if yon == 1: ok(ax, 2, y, 10, y, MAVI)
        elif yon == 2: ok(ax, 10, y, 2, y, KIRMIZI)
        ax.text(6, y + 0.1, t, ha="center", fontsize=6.3, color="#222222" if yon else GRI)
    ax.set_title("Bir katman için host–FPGA mesaj sırası (her paket ACK ile onaylanır)")
    kaydet(fig, "tr08_s3_zaman.png")

    # S4: UART dalga formu
    vcd = os.path.join(RTL, "sim", "tb_uart.vcd")
    if os.path.exists(vcd):
        fig, ax = plt.subplots(figsize=(6.3, 2.4))
        vcd_ciz.dalga_ciz(vcd, ["tb_uart.rx_pin", "tb_uart.tx_pin"], 0, 4000, ax=ax, baslik="UART: DURUM isteği (rx) ve VERI yanıtı (tx) — CLKS_PER_BIT=16")
        kaydet(fig, "tr08_s4_uart.png")

    # S5: veri hacmi (bayt) / katman
    oz = {}
    for a, v in HARITA.items():
        if a.startswith("l0_"):
            K, C = v["girdi"], v["cikis_kanali"]
            oz[a] = (8 * K * 8, C * K + C * 8, 8 * C * 8)
    fig, ax = plt.subplots(figsize=(6.0, 3.0))
    ad = list(oz); w = 0.27; x = np.arange(len(ad))
    for j, (t, r) in enumerate((("aktivasyon (PC→FPGA)", ACIK_MAVI), ("ağırlık+bias+M0 (PC→FPGA)", TURUNCU), ("çıktı (FPGA→PC)", YESIL))):
        ax.bar(x + (j - 1) * w, [oz[a][j] / 1024 for a in ad], w, label=t, color=r)
    ax.set_xticks(x); ax.set_xticklabels(ad, rotation=30, ha="right", fontsize=7); ax.set_ylabel("KB"); ax.legend(fontsize=6.5)
    top = sum(sum(v) for v in oz.values())
    ax.set_title(f"L0 doğrusal katmanları: veri hacmi (hesap); toplam {top / 1024:.0f} KB → 921600 baud'da ≈{top * 10 / 921600:.1f} sn")
    kaydet(fig, "tr08_s5_hacim.png")


if __name__ == "__main__":
    import sys
    for f in (sys.argv[1:] or ["tr04", "tr05", "tr06", "tr07", "tr08"]):
        globals()[f]()
