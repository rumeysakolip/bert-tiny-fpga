"""TR01 şekilleri: PE blok şeması, 4x4 dizi veri akışı, skew çizelgesi, bağlantı yazmaç karşılaştırması.
Tüm sayılar kodla hesaplanır (elle çizilmiş sayı yok)."""
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle

AY = os.path.dirname(os.path.abspath(__file__))
MAVI, GRI, TURUNCU, YESIL = "#2F5496", "#7F7F7F", "#C55A11", "#548235"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9})


def kutu(ax, x, y, w, h, metin, renk="#D9E2F3", kenar=MAVI, fs=9):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02,rounding_size=0.08",
                                fc=renk, ec=kenar, lw=1.3))
    ax.text(x + w / 2, y + h / 2, metin, ha="center", va="center", fontsize=fs)


def ok(ax, x0, y0, x1, y1, renk="black", etiket=None, ofs=(0, 0.1)):
    ax.annotate("", xy=(x1, y1), xytext=(x0, y0), arrowprops=dict(arrowstyle="-|>", color=renk, lw=1.3))
    if etiket:
        ax.text((x0 + x1) / 2 + ofs[0], (y0 + y1) / 2 + ofs[1], etiket, ha="center", fontsize=8, color=renk)


# ---------------- Şekil 1: PE blok şeması ----------------
def pe_sema():
    f, ax = plt.subplots(figsize=(7.4, 4.0)); ax.set_xlim(0, 11.2); ax.set_ylim(-0.3, 5.6); ax.axis("off")
    ax.add_patch(Rectangle((1.5, 0.15), 7.9, 4.85, fc="#F7F7F7", ec=GRI, ls="--"))
    ax.text(5.4, 5.2, "pe.v  (çıkış-sabit işlem hücresi)", ha="center", fontsize=10, weight="bold")
    kutu(ax, 3.4, 3.2, 1.6, 0.9, "×\n8b × 8b → 16b", "#FCE4D6", TURUNCU)
    kutu(ax, 5.7, 3.2, 1.1, 0.9, "+\n32b", "#FCE4D6", TURUNCU)
    kutu(ax, 7.4, 3.2, 1.5, 0.9, "acc\n32b yazmaç", "#E2EFDA", YESIL)
    kutu(ax, 3.4, 1.6, 1.6, 0.8, "a_out\n8b yazmaç", "#D9E2F3")
    kutu(ax, 3.4, 0.5, 1.6, 0.8, "b_out\n8b yazmaç", "#D9E2F3")
    # girişler
    ok(ax, 0.1, 3.85, 3.4, 3.85); ax.text(0.15, 4.0, "a_in (8b, soldan)", fontsize=8)
    ok(ax, 0.1, 3.45, 3.4, 3.45); ax.text(0.15, 3.12, "b_in (8b, yukarıdan)", fontsize=8)
    # a ve b'nin yazmaçlara ayrılan kolları
    ax.plot([2.0, 2.0], [3.85, 2.0], color="black", lw=1.3); ax.plot(2.0, 3.85, "ko", ms=3); ok(ax, 2.0, 2.0, 3.4, 2.0)
    ax.plot([2.6, 2.6], [3.45, 0.9], color="black", lw=1.3); ax.plot(2.6, 3.45, "ko", ms=3); ok(ax, 2.6, 0.9, 3.4, 0.9)
    # hesap zinciri
    ok(ax, 5.0, 3.65, 5.7, 3.65); ok(ax, 6.8, 3.65, 7.4, 3.65)
    ax.plot([8.15, 8.15, 6.25], [3.2, 2.8, 2.8], color="black", lw=1.3); ok(ax, 6.25, 2.8, 6.25, 3.2)
    ok(ax, 8.9, 3.65, 11.1, 3.65); ax.text(9.0, 3.95, "acc = C[i][j]", fontsize=8)
    # çıkışlar
    ok(ax, 5.0, 2.0, 11.1, 2.0); ax.text(9.0, 2.12, "a_out → sağdaki PE", fontsize=8, ha="center")
    ok(ax, 5.0, 0.9, 11.1, 0.9); ax.text(9.0, 1.02, "b_out → alttaki PE", fontsize=8, ha="center")
    ax.text(5.4, -0.2, "rst=1: sıfırla · en=1: acc ← acc + a·b, işlenenleri bir çevrim geciktirip ilet · en=0: tut",
            ha="center", fontsize=8, color=GRI)
    f.savefig(os.path.join(AY, "tr01_s1_pe.png"), dpi=200, bbox_inches="tight"); plt.close(f)


# ---------------- Şekil 2: 4x4 dizi veri akışı ----------------
def dizi_sema(N=4):
    f, ax = plt.subplots(figsize=(6.6, 5.0)); ax.set_xlim(-2.4, N * 1.6 + 0.4); ax.set_ylim(-N * 1.4 - 0.4, 2.3); ax.axis("off")
    for i in range(N):
        for j in range(N):
            x, y = j * 1.6, -i * 1.4
            kutu(ax, x, y, 1.1, 0.9, f"PE({i},{j})\nacc=C[{i}][{j}]", "#E2EFDA" if i == j else "#EDF2FA", YESIL if i == j else MAVI, fs=7.5)
            if j < N - 1: ok(ax, x + 1.1, y + 0.45, x + 1.6, y + 0.45, TURUNCU)
            if i < N - 1: ok(ax, x + 0.55, y, x + 0.55, y - 0.5, MAVI)
    for i in range(N):
        ok(ax, -1.9, -i * 1.4 + 0.45, 0, -i * 1.4 + 0.45, TURUNCU)
        ax.text(-2.35, -i * 1.4 + 0.55, f"A satır {i}\n{i} çevrim geç", fontsize=7.5, color=TURUNCU, ha="left", va="bottom")
    for j in range(N):
        ok(ax, j * 1.6 + 0.55, 1.5, j * 1.6 + 0.55, 0.9, MAVI)
        ax.text(j * 1.6 + 0.55, 1.6, f"B sütun {j}\n{j} çevrim geç", fontsize=7.5, color=MAVI, ha="center", va="bottom")
    ax.text(N * 0.8 - 0.2, -N * 1.4 - 0.15, "Turuncu: A (8b) soldan sağa · Mavi: B (8b) yukarıdan aşağı · Kısmi toplam PE'den ÇIKMAZ",
            ha="center", fontsize=8, color=GRI)
    f.savefig(os.path.join(AY, "tr01_s2_dizi.png"), dpi=200, bbox_inches="tight"); plt.close(f)


# ---------------- Şekil 3: skew çizelgesi (hesaplanır) ----------------
def skew_cizelge(N=4):
    T = 3 * (N - 1) + 1                      # 10 çevrim (cnt = 0..9)
    pes = [(i, j) for i in range(N) for j in range(N)]
    M = np.full((len(pes), T), np.nan)
    for r, (i, j) in enumerate(pes):
        for t in range(T):
            k = t - i - j
            if 0 <= k < N:
                M[r, t] = k
    f, ax = plt.subplots(figsize=(7.0, 5.4))
    im = ax.imshow(M, cmap="YlGnBu", vmin=-0.5, vmax=N - 1 + 0.5, aspect="auto")
    for r in range(len(pes)):
        for t in range(T):
            if not np.isnan(M[r, t]):
                ax.text(t, r, f"k={int(M[r, t])}", ha="center", va="center", fontsize=7.5,
                        color="white" if M[r, t] >= 2 else "black")
    ax.set_xticks(range(T)); ax.set_xticklabels([f"{t}" for t in range(T)])
    ax.set_yticks(range(len(pes))); ax.set_yticklabels([f"PE({i},{j})" for i, j in pes], fontsize=7.5)
    ax.set_xlabel("çevrim t (start sonrası)"); ax.set_ylabel("işlem hücresi")
    ax.set_title("Her PE'nin çevrim t'de gördüğü iç çarpım indisi k = t − i − j  (boş = 0 beslenir)\nson veri PE(3,3), t=9 → toplam 10 hesap çevrimi", fontsize=9)
    ax.set_xticks(np.arange(-.5, T, 1), minor=True); ax.set_yticks(np.arange(-.5, len(pes), 1), minor=True)
    ax.grid(which="minor", color="white", lw=0.8); ax.tick_params(which="minor", length=0)
    f.savefig(os.path.join(AY, "tr01_s3_skew.png"), dpi=200, bbox_inches="tight"); plt.close(f)
    return T


# ---------------- Şekil 4: hücreler arası taşınan yazmaç biti (hesaplanır) ----------------
def baglanti_karsilastir():
    Ns = [4, 8]
    os_bit = [2 * N * (N - 1) * 8 for N in Ns]            # A(8b) yatay + B(8b) dikey bağlantılar
    ws_bit = [N * (N - 1) * 8 + N * (N - 1) * 32 for N in Ns]   # A(8b) yatay + kısmi toplam(32b) dikey
    f, ax = plt.subplots(figsize=(5.6, 3.4)); x = np.arange(len(Ns)); w = 0.35
    b1 = ax.bar(x - w / 2, os_bit, w, color=MAVI, label="Çıkış-sabit (bizim tasarım)")
    b2 = ax.bar(x + w / 2, ws_bit, w, color=TURUNCU, label="Ağırlık-sabit (varsayım: A ve kısmi toplam akar)")
    for b in list(b1) + list(b2):
        ax.text(b.get_x() + b.get_width() / 2, b.get_height() + 15, f"{int(b.get_height())}", ha="center", fontsize=8)
    ax.set_xticks(x); ax.set_xticklabels([f"{N}×{N} dizi" for N in Ns])
    ax.set_ylabel("hücreler arası bağlantı biti (çevrim başına)")
    ax.set_title("Hücreler arası taşınan veri genişliği (kendi hesabımız)", fontsize=9)
    ax.legend(fontsize=7.5, frameon=False); ax.spines[["top", "right"]].set_visible(False)
    f.savefig(os.path.join(AY, "tr01_s4_baglanti.png"), dpi=200, bbox_inches="tight"); plt.close(f)
    return os_bit, ws_bit


if __name__ == "__main__":
    pe_sema(); dizi_sema(); print("skew çevrim sayısı:", skew_cizelge()); print("OS/WS bit:", baglanti_karsilastir())
