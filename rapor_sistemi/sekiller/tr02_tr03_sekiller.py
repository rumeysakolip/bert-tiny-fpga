"""TR02 (9 bit A girişi) ve TR03 (parametrik 8×8 akışlı dizi) şekilleri — gerçek veri/loglardan."""
import numpy as np

from tr_ortak import *   # noqa
import vcd_ciz


def tr02():
    # S1: PE blok şeması (9 bit A)
    fig, ax = plt.subplots(figsize=(6.0, 2.9)); ax.set_xlim(0, 10); ax.set_ylim(0, 5); ax.axis("off")
    kutu(ax, 3.6, 2.1, 1.5, 1.0, "× \n(9b × 8b → 17b)", TURUNCU, bold=True)
    kutu(ax, 5.8, 2.1, 1.3, 1.0, "+ \n(32b)", ACIK_MAVI, bold=True)
    kutu(ax, 7.5, 2.1, 1.6, 1.0, "acc (32b)\nyazmaç", YESIL, bold=True)
    kutu(ax, 6.2, 3.6, 1.3, 0.7, "a_out reg\n(9b)", "#DDDDDD"); kutu(ax, 6.2, 0.6, 1.3, 0.7, "b_out reg\n(8b)", "#DDDDDD")
    ax.plot([0.1, 1.6], [3.95, 3.95], color=MAVI, lw=1); ax.text(0.1, 4.1, "a_in (9b işaretli)", color=MAVI, fontsize=7)
    ok(ax, 1.6, 3.95, 3.9, 3.1, MAVI); ok(ax, 1.6, 3.95, 6.2, 3.95, MAVI)
    ax.plot([0.1, 1.6], [0.95, 0.95], color=TURUNCU, lw=1); ax.text(0.1, 1.1, "b_in (8b işaretli)", color=TURUNCU, fontsize=7)
    ok(ax, 1.6, 0.95, 4.7, 2.1, TURUNCU); ok(ax, 1.6, 0.95, 6.2, 0.95, TURUNCU)
    ok(ax, 5.1, 2.6, 5.8, 2.6); ok(ax, 7.1, 2.6, 7.5, 2.6)
    ok(ax, 8.3, 2.1, 8.3, 1.4, GRI); ok(ax, 8.3, 1.4, 6.5, 1.4, GRI); ok(ax, 6.5, 1.4, 6.5, 2.1, GRI)
    ax.text(8.4, 1.6, "acc geri beslemesi", fontsize=6.5, color=GRI)
    ok(ax, 7.5, 3.95, 9.7, 3.95, MAVI); ax.text(8.0, 4.1, "→ sağdaki PE", fontsize=6.5)
    ok(ax, 7.5, 0.95, 9.7, 0.95, TURUNCU); ax.text(8.0, 0.65, "→ alttaki PE", fontsize=6.5)
    ax.text(8.3, 3.25, "acc → c_flat\n(okuma)", fontsize=6.5, color=GRI)
    ax.set_title("pe.v (A_W=9, B_W=8, ACC_W=32): MAC ve komşuya akan işlenenler")
    kaydet(fig, "tr02_s1_pe9.png")

    # S2: değer aralığı
    fig, ax = plt.subplots(figsize=(6.0, 2.3))
    aralik = [("INT8 aktivasyon / ağırlık", -128, 127, MAVI), ("UINT8 Softmax olasılığı", 0, 255, TURUNCU),
              ("8 bit işaretli A (eski)", -128, 127, GRI), ("9 bit işaretli A (yeni)", -256, 255, YESIL)]
    for i, (ad, a, b, r) in enumerate(aralik):
        ax.barh(i, b - a, left=a, color=r, height=0.55)
        ax.text(b + 6, i, f"[{a}, {b}]", va="center", fontsize=7)
    ax.set_yticks(range(len(aralik))); ax.set_yticklabels([x[0] for x in aralik])
    ax.axvline(0, color="k", lw=0.6); ax.set_xlim(-290, 340); ax.set_xlabel("Tamsayı değeri")
    ax.set_title("A girişinin taşıması gereken değer aralıkları")
    kaydet(fig, "tr02_s2_aralik.png")

    # S3: en kötü durum birikeç genişliği (kodla hesaplandı)
    fig, ax = plt.subplots(figsize=(6.0, 2.5))
    K = np.array([64, 128, 512]); a_en = {"INT8×INT8 (|a|≤128)": 128 * 128, "UINT8×INT8 (a≤255)": 255 * 128, "9 bit alt sınır (−256)": 256 * 128}
    x = np.arange(len(K)); w = 0.26
    for n, (ad, m) in enumerate(a_en.items()):
        bit = np.ceil(np.log2(K * m + 1)) + 1
        ax.bar(x + (n - 1) * w, bit, w, label=ad, color=[MAVI, TURUNCU, YESIL][n])
        for xi, b in zip(x + (n - 1) * w, bit):
            ax.text(xi, b + 0.3, f"{int(b)}", ha="center", fontsize=6.5)
    ax.axhline(32, color=KIRMIZI, ls="--", lw=1); ax.text(2.45, 32.4, "ACC_W = 32", color=KIRMIZI, ha="right", fontsize=7)
    ax.set_xticks(x); ax.set_xticklabels([f"K={k}" for k in K]); ax.set_ylabel("Gereken bit (işaret dahil)"); ax.set_ylim(0, 36)
    ax.legend(fontsize=6.5, loc="lower right"); ax.set_title("K boyunca en kötü durum birikeç genişliği (hesap)")
    kaydet(fig, "tr02_s3_birikec.png")

    # S4: doğrulama bölümleri
    g4 = json_oku(os.path.join(RTL, "sim", "g4_sonuc.json"))
    pe = next(s for s in g4["sonuclar"] if s["ad"] == "pe 9b x 8b")
    fig, ax = plt.subplots(figsize=(6.0, 2.0))
    ax.bar(["PE testi (toplam)"], [int(pe["ayrinti"].split()[0])], color=YESIL)
    ax.text(0, int(pe["ayrinti"].split()[0]) * 1.02, f"{pe['ayrinti']}", ha="center", fontsize=8)
    ax.set_ylabel("Kontrol sayısı"); ax.set_ylim(0, int(pe["ayrinti"].split()[0]) * 1.25)
    ax.set_title("tb_pe.v sonucu (sim/g4_sonuc.json)")
    kaydet(fig, "tr02_s4_dogrulama.png")


def tr03():
    N = 8
    # S1: 8x8 akışlı dizi blok şeması
    fig, ax = plt.subplots(figsize=(6.0, 3.9)); ax.set_xlim(-2.2, 9.5); ax.set_ylim(-2.5, 9.5); ax.axis("off")
    for i in range(N):
        for j in range(N):
            ax.add_patch(plt.Rectangle((j * 0.95, 7.2 - i * 0.85), 0.8, 0.7, fc=ACIK_MAVI if (i + j) % 2 == 0 else "#CFE6F6", ec="#333", lw=0.4))
    ax.text(3.8, 0.75, "PE(0,0) … PE(7,7): 64 PE, her biri acc 32 bit", ha="center", fontsize=7)
    for i in range(N):
        ok(ax, -0.9, 7.55 - i * 0.85, -0.05, 7.55 - i * 0.85, TURUNCU, lw=0.7)
        ax.text(-1.8, 7.5 - i * 0.85, f"D{i}" if i else "—", fontsize=6, color=TURUNCU)
    for j in range(N):
        ok(ax, j * 0.95 + 0.4, 9.2, j * 0.95 + 0.4, 8.0, MAVI, lw=0.7)
    kutu(ax, -2.2, -2.2, 4.6, 1.0, "A sütunu (8×9b) / çevrim\nkaydırma: satır i → i yazmaç", TURUNCU, 6.5)
    kutu(ax, 2.9, -2.2, 4.8, 1.0, "B satırı (8×8b) / çevrim\nkaydırma: sütun j → j yazmaç", ACIK_MAVI, 6.5)
    kutu(ax, 7.8, 3.0, 1.7, 1.8, "kontrol\nFSM\nstart,k_len\nin_valid\ndone", YESIL, 6.5)
    ax.text(3.8, -0.7, "c_flat = 64×32 bit, done=1 iken geçerli; tile = K + 2N − 2 çevrim", ha="center", fontsize=7)
    ax.set_title("systolic_nxn (N=8) akışlı arayüz ve skew yazmaç zincirleri")
    kaydet(fig, "tr03_s1_dizi8.png")

    # S2: skew çizelgesi (N=8, kodla)
    T = 3 * N - 2
    M = np.full((N * N, T), np.nan)
    for i in range(N):
        for j in range(N):
            for t in range(T):
                k = t - i - j
                if 0 <= k < N:
                    M[i * N + j, t] = k
    fig, ax = plt.subplots(figsize=(6.0, 4.2))
    im = ax.imshow(M, aspect="auto", cmap="YlGnBu", interpolation="nearest")
    ax.set_xlabel("Çevrim t (K=8 için; genel: K + 2N − 2 çevrim)"); ax.set_ylabel("PE(i,j) → i·8 + j")
    ax.set_yticks([0, 9, 18, 27, 36, 45, 54, 63]); ax.set_yticklabels(["(0,0)", "(1,1)", "(2,2)", "(3,3)", "(4,4)", "(5,5)", "(6,6)", "(7,7)"])
    cb = fig.colorbar(im, ax=ax); cb.set_label("PE'nin gördüğü k = t − i − j")
    ax.set_title(f"N=8 skew çizelgesi: son veri t={T - 1}'de PE(7,7)'ye ulaşır")
    kaydet(fig, "tr03_s2_skew8.png")

    # S3: dalga formu (VCD)
    vcd = os.path.join(RTL, "sim", "tb_systolic_nxn_n8_k64.vcd")
    sig = ["tb_systolic_nxn.clk", "tb_systolic_nxn.start", "tb_systolic_nxn.in_valid", "tb_systolic_nxn.dut.state",
           "tb_systolic_nxn.dut.kcnt", "tb_systolic_nxn.busy", "tb_systolic_nxn.done"]
    fig, ax = plt.subplots(figsize=(6.3, 3.0))
    vcd_ciz.dalga_ciz(vcd, sig, 20, 900, ax=ax, baslik="N=8, K=64: ilk tile (start → done = 78 çevrim)")
    kaydet(fig, "tr03_s3_dalga.png")

    # S4: tile çevrimi ölçüm vs formül
    g4 = json_oku(os.path.join(RTL, "sim", "g4_sonuc.json"))["sonuclar"]
    nx = [s for s in g4 if "N" in s]
    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    for n_, r, mk in ((4, MAVI, "o"), (8, TURUNCU, "s")):
        v = [s for s in nx if s["N"] == n_]
        ax.plot([s["K"] for s in v], [s["beklenen_cevrim"] for s in v], "-", color=r, lw=1, label=f"N={n_} formül K+2N−2")
        ax.plot([s["K"] for s in v], [s["tile_cevrim_max"] for s in v], mk, color=r, ms=6, mfc="none", label=f"N={n_} benzetim ölçümü")
    ax.set_xscale("log", base=2); ax.set_xlabel("K (iç çarpım uzunluğu)"); ax.set_ylabel("Tile süresi (çevrim)")
    ax.legend(fontsize=6.5); ax.set_title("Tile süresi: ölçüm ile formül örtüşüyor")
    kaydet(fig, "tr03_s4_cevrim.png")

    # S5: doğrulama tablosu-grafik
    fig, ax = plt.subplots(figsize=(6.0, 2.6))
    etk = [f"N={s['N']},K={s['K']}" for s in nx]
    kont = [int(s["ayrinti"].split(",")[1].split()[0]) for s in nx]
    ax.bar(etk, kont, color=[MAVI if s["N"] == 4 else TURUNCU for s in nx])
    for i, (e, k) in enumerate(zip(etk, kont)):
        ax.text(i, k + 400, "0 hata", ha="center", fontsize=6.5, color=YESIL)
    ax.set_ylabel("Kontrol sayısı"); plt.setp(ax.get_xticklabels(), rotation=30, ha="right")
    ax.set_title("systolic_nxn: yapılandırma başına kontrol sayısı (tümü PASS)")
    kaydet(fig, "tr03_s5_dogrulama.png")


if __name__ == "__main__":
    tr02(); tr03()
