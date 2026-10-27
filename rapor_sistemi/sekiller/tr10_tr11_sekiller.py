"""TR10 (Softmax) ve TR11 (LayerNorm) sekilleri. Tum veriler 03-RTL/tb/vektor_g11, sim/g11_sonuc.json, VCD'lerden."""
import numpy as np

from tr_ortak import *   # noqa: E402
import vcd_ciz           # noqa: E402

VD = os.path.join(RTL, "tb", "vektor_g11")
SIM = os.path.join(RTL, "sim")


def mem(ad, isaretli=True, bit=32):
    v = np.array([int(x, 16) for x in open(os.path.join(VD, ad)).read().split()], dtype=np.int64)
    if isaretli:
        v = np.where(v >= 1 << (bit - 1), v - (1 << bit), v)
    return v


def fsm(ax, satir_a, satir_b, dongu_a, dongu_b, gecis_etiket, baslik, w=1.36, adim=1.62):
    """Iki satirli FSM: satir_a ve satir_b [(ad, metin)] listeleri; dongu_*: (baslangic, bitis, etiket) geri okları;
    son durumdan ikinci satirin ilkine inen ok gecis_etiket ile etiketlenir."""
    n = max(len(satir_a), len(satir_b))
    ax.set_xlim(-0.2, n * adim + 0.2); ax.set_ylim(-0.9, 3.7); ax.axis("off"); ax.set_title(baslik)
    h = 1.0
    ya, yb = 2.1, 0.0

    def ciz(satir, y, dongu, yon):
        xs = [0.1 + i * adim for i in range(len(satir))]
        for (ad, metin), x in zip(satir, xs):
            kutu(ax, x, y, w, h, f"{ad}\n{metin}", renk=ACIK_MAVI, fs=4.9)
        for i in range(len(satir) - 1):
            ok(ax, xs[i] + w, y + h / 2, xs[i + 1], y + h / 2)
        for i0, i1, et in dongu:
            if yon == "ust":
                ax.annotate("", xy=(xs[i0] + w / 2, y + h), xytext=(xs[i1] + w / 2, y + h),
                            arrowprops=dict(arrowstyle="-|>", color=KIRMIZI, lw=1, connectionstyle="arc3,rad=-0.35"))
                ax.text((xs[i0] + xs[i1]) / 2 + w / 2, y + h + 0.42, et, ha="center", fontsize=5.8, color=KIRMIZI)
            else:
                ax.annotate("", xy=(xs[i0] + w / 2, y), xytext=(xs[i1] + w / 2, y),
                            arrowprops=dict(arrowstyle="-|>", color=KIRMIZI, lw=1, connectionstyle="arc3,rad=0.35"))
                ax.text((xs[i0] + xs[i1]) / 2 + w / 2, y - 0.62, et, ha="center", fontsize=5.8, color=KIRMIZI)
        return xs
    xa = ciz(satir_a, ya, dongu_a, "ust")
    xb = ciz(satir_b, yb, dongu_b, "alt")
    # A satiri sonu -> B satiri basi (dirsek)
    x0, y0 = xa[-1] + w / 2, ya
    x1, y1 = xb[0] + w / 2, yb + h
    ym = (y0 + y1) / 2
    ax.plot([x0, x0, x1], [y0, ym, ym], color="#333333", lw=1)
    ax.annotate("", xy=(x1, y1), xytext=(x1, ym), arrowprops=dict(arrowstyle="-|>", color="#333333", lw=1))
    ax.text((x0 + x1) / 2, ym + 0.08, gecis_etiket, ha="center", fontsize=5.8)


def faz_cubugu(ax, adlar, say, baslik, toplam_etiket):
    sol = 0
    renkler = [MAVI, TURUNCU, YESIL, ACIK_MAVI, KIRMIZI, GRI, "#CC79A7", "#F0E442", "#000000", "#999933", "#44AA99", "#882255", "#DDCC77"]
    for (ad, v), r in zip(zip(adlar, say), renkler):
        ax.barh([0], [v], left=sol, color=r, edgecolor="white", label=f"{ad}: {v}")
        sol += v
    ax.set_yticks([]); ax.set_xlabel("çevrim (bir satır)"); ax.set_title(baslik)
    ax.legend(fontsize=6, ncol=2, loc="upper center", bbox_to_anchor=(0.5, -0.35), frameon=False)
    ax.text(sol, 0.45, toplam_etiket, ha="right", fontsize=7)


def dogrulama_sekli(ax1, ax2, o, birim, baslik):
    b = o["birim"][birim]
    ax1.bar(["satır", "eleman kontrolü", "hata"], [b["satir"], b["kontrol"], b["hata"]], color=[ACIK_MAVI, MAVI, KIRMIZI])
    for i, v in enumerate([b["satir"], b["kontrol"], b["hata"]]):
        ax1.text(i, v, f"{v}", ha="center", va="bottom", fontsize=7)
    ax1.set_yscale("symlog"); ax1.set_title(baslik)
    mut = [m for m in o["mutant"] if m["birim"] == birim]
    for i, m in enumerate(mut):
        ax2.bar(i, max(m["hata"], 0.5), color=YESIL if m["yakalandi"] else GRI)
        ax2.text(i, max(m["hata"], 0.5) * 1.15, f"{m['hata']} hata\n" + ("yakalandı" if m["yakalandi"] else "eşdeğer"), ha="center", fontsize=6.5)
    ax2.set_xticks(range(len(mut))); ax2.set_xticklabels([m["ad"] for m in mut]); ax2.set_yscale("log")
    ax2.set_ylim(0.3, max(m["hata"] for m in mut) * 20 + 10); ax2.set_title("Mutant denetimi: kasıtlı bozulmayı test yakalıyor mu?")


def tr10():
    o = json_oku(os.path.join(SIM, "g11_sonuc.json"))
    # S1: FSM
    fig, ax = plt.subplots(figsize=(6.6, 2.9))
    A = [("IDLE", "start: M0 al"), ("LOAD", "L giriş; max\n(maskeli hariç)"), ("FARK", "fark = max − s"), ("IDX", "fark · M0"),
         ("EXP", "idx = min(.>>16,\n511); e_r = LUT"), ("ACC", "ebuf = e_r\ntop += e_r")]
    B = [("NUM", "e·255 + top/2"), ("DIV", "ardışık bölme\n24 çevrim"), ("OUT", "p = min(q, 255)")]
    fsm(ax, A, B, [(2, 5, "her eleman için (×L)")], [(0, 2, "her eleman için (×L)")], "son eleman",
        "Softmax FSM: (1) maks bul, (2) exp ve topla, (3) böl")
    kaydet(fig, "tr10_s1_fsm.png")

    # S2: faz cubugu
    f = o["birim"]["softmax"]["faz_cevrimleri"]
    ad = ["LOAD", "FARK", "IDX", "EXP", "ACC", "NUM", "DIV", "OUT"]
    anah = ["1", "2", "3", "4", "8", "5", "6", "7"]
    say = [f[a] for a in anah]
    fig, ax = plt.subplots(figsize=(6.4, 2.4))
    faz_cubugu(ax, ad, say, "Bir satırın (L=64) faz başına çevrim dökümü (benzetimde ölçülen)", f"toplam {sum(say)} çevrim")
    kaydet(fig, "tr10_s2_faz.png")

    # S3: hata histogrami (gercek satirlar: ilk 320)
    skor, mask, m0, cik = mem("sm_skor.mem"), mem("sm_mask.mem"), mem("sm_m0.mem"), mem("sm_cikis.mem")
    nr = 320
    err = []
    for r in range(nr):
        s = skor[r * 64:(r + 1) * 64].astype(np.float64) * (m0[r] / (65536.0 * 64.0))
        mk = mask[r * 64:(r + 1) * 64].astype(bool)
        if not mk.any():
            continue
        e = np.exp(np.where(mk, s - s[mk].max(), -np.inf)); p = e / e.sum()
        err.extend(np.abs(cik[r * 64:(r + 1) * 64] / 255.0 - p)[mk] * 255.0)       # 1/255 (LSB) cinsinden
    err = np.array(err)
    fig, ax = plt.subplots(figsize=(6.0, 2.6))
    ax.hist(err, bins=np.arange(0, max(err.max(), 1.0) + 0.1, 0.1), color=MAVI)
    ax.axvline(0.5, color=KIRMIZI, ls="--", lw=1); ax.text(0.52, ax.get_ylim()[1] * 0.85, "0,5 LSB = 8 bit\nyuvarlama tabanı", fontsize=6.5, color=KIRMIZI)
    ax.set_yscale("log"); ax.set_xlabel("|RTL olasılığı − FP64 softmax| (1/255 birimi)"); ax.set_ylabel("eleman sayısı")
    ax.set_title(f"Softmax yaklaşıklık hatası: {nr} gerçek satır, maks {err.max():.2f} LSB, ort {err.mean():.3f} LSB")
    kaydet(fig, "tr10_s3_hata.png")
    istat = {"sm_hata_maks_lsb": float(err.max()), "sm_hata_ort_lsb": float(err.mean()), "sm_eleman": int(len(err))}

    # S4: dalga formu
    vcd = os.path.join(SIM, "g11_softmax.vcd")
    fig, axs = plt.subplots(3, 1, figsize=(6.4, 6.0))
    t = "tb_softmax.dut."
    sig = [t + "st", t + "cnt", t + "in_valid", t + "out_valid"]
    vcd_ciz.dalga_ciz(vcd, sig, 5150, 25800, ax=axs[0], baslik="Tüm satır: LOAD → (FARK,IDX,EXP,ACC)×64 → (NUM,DIV,OUT)×64")
    vcd_ciz.dalga_ciz(vcd, [t + "st", t + "ix", t + "fark", t + "carp", t + "idx", t + "e_r", t + "top"], 5830, 6030,
                      ax=axs[1], baslik="Geçiş 2 yakın plan: elemanlar 4 çevrimde (FARK, IDX, EXP, ACC)")
    vcd_ciz.dalga_ciz(vcd, [t + "st", t + "dv_start", t + "dv_busy", t + "dv_done", t + "pay", t + "dv_q", t + "out_valid"], 8380, 8760,
                      ax=axs[2], baslik="Geçiş 3 yakın plan: bölücü 24 çevrim, sonra çıkış")
    fig.tight_layout()
    kaydet(fig, "tr10_s4_dalga.png")

    # S5: dogrulama
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.6))
    dogrulama_sekli(a1, a2, o, "softmax", "Softmax doğrulama (altın softmax_tam'a karşı)")
    fig.tight_layout(); kaydet(fig, "tr10_s5_dogrulama.png")
    return istat


def tr11():
    o = json_oku(os.path.join(SIM, "g11_sonuc.json"))
    fig, ax = plt.subplots(figsize=(6.4, 3.4))
    A = [("IDLE", "start"), ("LOAD", "N giriş\nsum += q"), ("MEAN", "ort=(sum+64)>>7"), ("SQ", "d, d², Σd²\n(3 aşama)"),
         ("VAR", "(Σd²+64)>>7\n+ eps_q"), ("ROOT", "bit-bit karekök\n20 çevrim"), ("STD", "std=max(kök,1)")]
    B = [("NUM", "(d<<12)+std/2"), ("DIV", "ardışık bölme\n32 çevrim"), ("Y", "işaret/taban"), ("M1", "y·γ"), ("M2", "·M0"),
         ("SH", "(+2^(n−1))>>n"), ("OUT", "+β, kırp\n[−128,127]")]
    fsm(ax, A, B, [], [(0, 6, "her eleman için (×N = 128)")], "ortalama, varyans, karekök hazır",
        "LayerNorm FSM: önce satır istatistikleri, sonra eleman başına böl-ölçekle")
    kaydet(fig, "tr11_s1_fsm.png")

    f = o["birim"]["layernorm"]["faz_cevrimleri"]
    ad = ["LOAD", "MEAN", "SQ", "VAR", "ROOT", "STD", "NUM", "DIV", "Y", "M1", "M2", "SH", "OUT"]
    say = [f[str(i)] for i in range(1, 14)]
    fig, ax = plt.subplots(figsize=(6.4, 2.6))
    faz_cubugu(ax, ad, say, "Bir satırın (N=128) faz başına çevrim dökümü (benzetimde ölçülen)", f"toplam {sum(say)} çevrim")
    kaydet(fig, "tr11_s2_faz.png")

    # S3: hata
    q, ornek, cik = mem("ln_q.mem"), mem("ln_ornek.mem"), mem("ln_cikis.mem")
    gam, bet, par = mem("ln_gamma.mem"), mem("ln_beta.mem"), mem("ln_par.mem")
    nr, N = 480, 128
    err, isqrt_err = [], []
    for r in range(nr):
        x = q[r * N:(r + 1) * N].astype(np.float64); k = ornek[r]
        eps_q = par[k * 3]
        d = x - x.mean(); var = (d * d).mean()
        carpan = par[k * 3 + 1] / 2.0 ** par[k * 3 + 2] * 2.0 ** 24          # = 1/cikis_olcek (M0/2^n * 2^(2*g_bit))
        y = d / np.sqrt(var + eps_q) * gam[k * N:(k + 1) * N] / 4096.0 * carpan + bet[k * N:(k + 1) * N]
        err.extend(cik[r * N:(r + 1) * N] - np.clip(y, -128, 127))
    err = np.array(err)
    # karekok: bit-bit (floor) ile gercek karekok farki
    rng = np.random.default_rng(3)
    vs = np.concatenate([rng.integers(1, 2**36, 4000), rng.integers(1, 5000, 4000)])
    import math
    fark = np.array([math.sqrt(int(v)) - math.isqrt(int(v)) for v in vs])
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.6))
    a1.hist(err, bins=np.arange(-1.05, 1.06, 0.1), color=MAVI); a1.set_yscale("log")
    a1.set_xlabel("RTL çıkışı − FP64 LayerNorm (INT8 LSB)"); a1.set_ylabel("eleman sayısı")
    a1.set_title(f"LayerNorm hatası ({nr} gerçek satır)\nmaks {np.abs(err).max():.2f} LSB, ort {np.abs(err).mean():.3f}")
    a2.hist(fark, bins=np.linspace(0, 1, 21), color=TURUNCU)
    a2.set_xlabel("√v − floor(√v)  (karekök kesme hatası)"); a2.set_title(f"Karekök: Newton ≡ bit-bit\nmaks hata {fark.max():.3f} < 1")
    fig.tight_layout(); kaydet(fig, "tr11_s3_hata.png")
    istat = {"ln_hata_maks_lsb": float(np.abs(err).max()), "ln_hata_ort_lsb": float(np.abs(err).mean()),
             "ln_eleman": int(len(err)), "isqrt_hata_maks": float(fark.max())}

    vcd = os.path.join(SIM, "g11_layernorm.vcd")
    t = "tb_layernorm.dut."
    fig, axs = plt.subplots(3, 1, figsize=(6.4, 6.0))
    vcd_ciz.dalga_ciz(vcd, [t + "st", t + "cnt", t + "in_valid", t + "out_valid"], 1300, 54300, ax=axs[0],
                      baslik="Tüm satır: LOAD, MEAN, SQ, VAR, ROOT, ardından 128 eleman (NUM…OUT)")
    vcd_ciz.dalga_ciz(vcd, [t + "st", t + "op", t + "res", t + "one", t + "rcnt"], 3930, 4180, ax=axs[1],
                      baslik="Karekök yakın plan: op/res/one üzerinde bit-bit yaklaştırma (20 çevrim)")
    vcd_ciz.dalga_ciz(vcd, [t + "st", t + "dv_start", t + "dv_done", t + "y", t + "p1", t + "out_data", t + "out_valid"], 4160, 4600, ax=axs[2],
                      baslik="Bir elemanın yolu: NUM → DIV(32) → Y → M1 → M2 → SH → OUT")
    fig.tight_layout(); kaydet(fig, "tr11_s4_dalga.png")

    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.6))
    dogrulama_sekli(a1, a2, o, "layernorm", "LayerNorm doğrulama (altın katman_norm_tam'a karşı)")
    fig.tight_layout(); kaydet(fig, "tr11_s5_dogrulama.png")
    return istat


def sentez_verisi():
    import re
    c = os.path.join(RTL, "sentez", "cikti")
    sonuc = {}
    for u in ("softmax_birim", "layernorm_birim"):
        k = open(os.path.join(c, f"{u}_kullanim.txt"), encoding="utf-8").read()
        g = lambda kalip: float(re.search(kalip, k).group(1))
        z = open(os.path.join(c, f"{u}_zamanlama.txt"), encoding="utf-8").read()
        sonuc[u] = {"LUT": g(r"\|\s*Slice LUTs\*\s*\|\s*(\d+)"), "FF": g(r"\|\s*Slice Registers\s*\|\s*(\d+)"),
                    "DSP": g(r"\|\s*DSPs\s*\|\s*(\d+)"),
                    "WNS": float(re.search(r"WNS\(ns\).*?\n.*?\n\s*(-?[\d.]+)", z, re.S).group(1))}
    return sonuc


if __name__ == "__main__":
    ist = {}
    ist.update(tr10()); ist.update(tr11()); ist["sentez"] = sentez_verisi()
    json.dump(ist, open(os.path.join(SIM, "g11_istatistik.json"), "w"), indent=1)
    print(ist)
