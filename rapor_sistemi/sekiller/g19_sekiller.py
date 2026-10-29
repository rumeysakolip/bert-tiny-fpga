"""G19 -- hesaplama yuku analizi sonuc tablosu ve sekilleri.

Uc bakis:
  1) Aritmetik yuk (analitik): MAC sayisi ve eleman sayisi, tek cumle, seq=64 (old/.../hesap_yuku_analizi.py ile ayni formuller).
  2) CPU suresi payi: old/bert-tiny-fpga/deneyler/hesap_yuku/sonuclar_x86_1thread.json (OKUNUR, degistirilmez; bu betik yeniden olcum yapmaz).
  3) Bu calismadaki RTL cevrim payi: 03-RTL/sim/g7_sonuc.json, g10_sonuc.json (olculen) ve g11_sonuc.json satir cevrimleri x satir sayisi (hesap).
Cikti: 03-RTL/sim/g19_ozet.json, rapor_sistemi/g19_tablo.csv, sekiller/g19_s*.png
"""
import csv

from tr_ortak import *   # noqa: E402

CPU_JSON = os.path.join(PROJE, "old", "bert-tiny-fpga", "deneyler", "hesap_yuku", "sonuclar_x86_1thread.json")
L, H, A, F, S = 2, 128, 2, 512, 64
DH = H // A


def main():
    cpu = json_oku(CPU_JSON)
    macs = {
        "Q/K/V izdüşümleri": L * 3 * S * H * H, "Q·Kᵀ": L * A * S * S * DH, "Dikkat·V": L * A * S * S * DH,
        "Dikkat çıkış izdüşümü": L * S * H * H, "FFN1 (H→4H)": L * S * H * F, "FFN2 (4H→H)": L * S * F * H,
        "Pooler + sınıflandırıcı": H * H + H * 2,
    }
    assert macs == cpu["mac"], "MAC formulleri eski analizle uyusmuyor"
    elem = {"Softmax (eleman)": L * A * S * S, "LayerNorm (eleman)": (1 + 2 * L) * S * H, "GELU (eleman)": L * S * F}
    tot_mac = sum(macs.values())

    g7 = json_oku(os.path.join(RTL, "sim", "g7_sonuc.json"))["sonuclar"]
    g10 = json_oku(os.path.join(RTL, "sim", "g10_sonuc.json"))["sonuclar"]
    g11 = json_oku(os.path.join(RTL, "sim", "g11_sonuc.json"))["birim"]
    sm_satir = L * A * S                     # 256 satir (her baş, her token)
    ln_satir = (1 + 2 * L) * S               # 320 satir (gomme + 2 LN/katman)
    cev = {
        "Doğrusal katmanlar (12, ölçüldü)": sum(s["cevrim_olculen"] for s in g7),
        "Dikkat çarpımları (Q·Kᵀ, P·V, ölçüldü)": sum(s["cevrim"] for s in g10),
        "Softmax birimi (hesap)": sm_satir * g11["softmax"]["cevrim_maks"],
        "LayerNorm birimi (hesap)": ln_satir * g11["layernorm"]["cevrim_maks"],
    }
    tot_cev = sum(cev.values())

    ozet = {"seq_len": S, "mac": macs, "toplam_mac": tot_mac, "eleman": elem,
            "cpu_sure_yuzde": cpu["cpu_sure_yuzde"], "cpu_gecikme_ms": cpu["cpu_gecikme_ms"],
            "rtl_cevrim": cev, "rtl_toplam_cevrim": tot_cev, "rtl_ms_100mhz": tot_cev / 100e6 * 1e3,
            "satir_sayilari": {"softmax": sm_satir, "layernorm": ln_satir},
            "not": "rtl_cevrim: dogrusal ve dikkat OLCULDU (benzetim), Softmax/LayerNorm = olculen satir cevrimi x satir sayisi (HESAP, bu birimler sisteme bagli degil). pooler/classifier ve GELU ek cevrimi dahil degil."}
    json.dump(ozet, open(os.path.join(RTL, "sim", "g19_ozet.json"), "w", encoding="utf-8"), indent=1, ensure_ascii=False)

    with open(os.path.join(AY, "g19_tablo.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(["islem", "MAC_veya_eleman", "MAC_yuzde", "CPU_sure_yuzde(x86,1 is parcacigi)", "RTL_cevrim", "RTL_cevrim_yuzde"])
        for k, v in macs.items():
            w.writerow([k, v, f"{100 * v / tot_mac:.1f}", "", "", ""])
        for k, v in elem.items():
            w.writerow([k, v, "", "", "", ""])
        for k, v in cpu["cpu_sure_yuzde"].items():
            w.writerow([f"CPU: {k}", "", "", v, "", ""])
        for k, v in cev.items():
            w.writerow([k, "", "", "", v, f"{100 * v / tot_cev:.1f}"])

    # S1: MAC payi + eleman sayilari
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.8), gridspec_kw={"width_ratios": [1.6, 1]})
    ad = list(macs); v = [100 * macs[k] / tot_mac for k in ad]
    a1.barh(ad[::-1], v[::-1], color=MAVI)
    for i, y in enumerate(v[::-1]):
        a1.text(y + 0.5, i, f"{y:.1f}%", va="center", fontsize=7)
    a1.set_xlabel("toplam MAC içindeki pay (%)"); a1.set_title(f"Çarpma-toplama (MAC) payı; toplam {tot_mac / 1e6:.1f} M", fontsize=8.5)
    a1.set_xlim(0, 40)
    a2.bar(["Softmax", "LayerNorm", "GELU"], list(elem.values()), color=[TURUNCU, YESIL, ACIK_MAVI])
    for i, y in enumerate(elem.values()):
        a2.text(i, y, f"{y:,}".replace(",", "."), ha="center", va="bottom", fontsize=7)
    a2.set_ylim(0, max(elem.values()) * 1.2); a2.set_title("Doğrusal olmayan işlemler\n(eleman sayısı, MAC değil)", fontsize=8.5)
    fig.tight_layout(); kaydet(fig, "g19_s1_mac.png")

    # S2: CPU sure payi
    fig, ax = plt.subplots(figsize=(6.4, 2.6))
    ks = list(cpu["cpu_sure_yuzde"]); vs = [cpu["cpu_sure_yuzde"][k] for k in ks]
    ax.barh(ks[::-1], vs[::-1], color=TURUNCU)
    for i, y in enumerate(vs[::-1]):
        ax.text(y + 0.5, i, f"{y:.1f}%", va="center", fontsize=7)
    ax.set_xlim(0, 70); ax.set_xlabel("CPU süresi payı (%)")
    ax.set_title(f"CPU'da (x86, 1 iş parçacığı) süre payı; toplam {cpu['cpu_gecikme_ms']} ms/cümle", fontsize=8.5)
    kaydet(fig, "g19_s2_cpu.png")

    # S3: RTL cevrim payi (bu calismadaki birimlerle)
    fig, ax = plt.subplots(figsize=(6.6, 2.6))
    ks = list(cev); vs = [cev[k] for k in ks]
    renk = [MAVI, ACIK_MAVI, TURUNCU, YESIL]
    sol = 0
    for k, y, r in zip(ks, vs, renk):
        ax.barh([0], [y], left=sol, color=r, edgecolor="white", label=f"{k}: {y:,}".replace(",", ".") + f" ({100 * y / tot_cev:.1f}%)")
        sol += y
    ax.set_yticks([]); ax.set_xlabel("çevrim / cümle")
    ax.set_title(f"Bu RTL ile çevrim payı: toplam {tot_cev:,} çevrim (≈{tot_cev / 1e5:.1f} ms @100 MHz)".replace(",", "."), fontsize=8.5)
    ax.legend(fontsize=6.5, loc="upper center", bbox_to_anchor=(0.5, -0.3), ncol=1, frameon=False)
    kaydet(fig, "g19_s3_rtl_cevrim.png")
    print(json.dumps({k: v for k, v in ozet.items() if k.startswith("rtl")}, ensure_ascii=False))
    print({k: f"{100 * v / tot_cev:.1f}%" for k, v in cev.items()})


if __name__ == "__main__":
    main()
