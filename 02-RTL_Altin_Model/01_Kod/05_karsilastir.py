"""K3 — FP32 / INT8-PTQ / Altın-A / Altın-B dört yönlü karşılaştırma.

Bu betik "altın model gerçekten modelin kendisi mi?" sorusunun cevabını tek
tabloda verir. Ölçüt adları ve eşikler 01-INT8_Nicemleme adımındaki
`nicemleme_olcut.py` ile BİREBİR aynıdır, böylece iki adımın raporları yan yana
konabilir.

Karşılaştırılan dört model
--------------------------
  FP32        : nicemlenmemiş referans (altın modelin `kip="fp32"` yolu)
  INT8-PTQ    : 01 adımının yazılım INT8 modeli (int8_tahminleri.csv'den okunur)
  Altın-A     : altın modelin PTQ eşdeğeri kipi  -> INT8-PTQ ile aynı olmalı
  Altın-B     : altın modelin donanım kipi       -> FPGA'da kurulacak devre

Üç ayrı soru ölçülür:
  1. DOĞRULUK   : her modelin SST-2 doğrulama kümesindeki başarısı ve FP32'ye
                  göre kaybı (hedef <=1 puan, sınır <=2 puan, MLPerf >=%99).
  2. KAYIP      : doğrulama çapraz entropisi (validation cross-entropy).
                  Doğruluk 872 cümlede +-2 cümlelik gürültü taşır; çapraz
                  entropi SÜREKLİ bir ölçüdür ve karar değişmese bile modelin
                  güveninin ne kadar bozulduğunu gösterir. Nicemlemenin modeli
                  gerçekten bozup bozmadığı asıl burada görülür.
  3. EŞDEĞERLİK : Altın-A ile INT8-PTQ'nun tahminleri birebir aynı mı?
                  Bu, altın modelin geçerlilik kanıtıdır — doğruluğun yakın
                  olması yetmez, AYNI cümlelerde aynı kararı vermesi gerekir.

NOT — "kayıp" sözcüğünün iki ayrı anlamı karıştırılmamalıdır:
  * EĞİTİM kaybı : FP32 eğitiminin çapraz entropisi, eğitim kümesinde ölçülür.
                   00-FP32_Egitim/03_Sonuclar/sonuclar.json -> gecmis[].train_loss
                   (4. epoch: 0,1640). Bu betik onu HESAPLAMAZ, yalnızca okur.
  * KAYIP PUAN   : FP32'ye göre DOĞRULUK farkı, yüzde puan cinsinden.
                   FP32'nin kendisine göre kaybı tanımı gereği sıfırdır.
Bu betiğin eklediği üçüncü büyüklük DOĞRULAMA kaybıdır: aynı 872 cümlede, her
model için ayrı ayrı hesaplanan çapraz entropi.

Çalıştırma:
    python 05_karsilastir.py
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ortak  # noqa: E402
from altin import model, veri  # noqa: E402

HEDEF_PUAN, SINIR_PUAN, MLPERF_ORAN = 1.0, 2.0, 0.99


def degerlendir(etiket, fp32, aday) -> dict:
    """nicemleme_olcut.degerlendir ile aynı ölçütler (aynı adlarla)."""
    etiket, fp32, aday = map(np.asarray, (etiket, fp32, aday))
    n = len(etiket)
    d_fp32 = int((fp32 == etiket).sum())
    d_aday = int((aday == etiket).sum())
    uyusan = int((fp32 == aday).sum())
    bozulan = int(((fp32 == etiket) & (aday != etiket)).sum())
    duzelen = int(((fp32 != etiket) & (aday == etiket)).sum())
    kayip = 100.0 * (d_fp32 - d_aday) / n
    min_mlperf = int(np.ceil(MLPERF_ORAN * d_fp32 - 1e-9))
    return {
        "n": n, "dogru": d_aday, "dogruluk": round(d_aday / n, 4),
        "kayip_puan": round(kayip, 2), "kayip_cumle": d_fp32 - d_aday,
        "uyusma_orani": round(uyusan / n, 4), "uyusmayan_cumle": n - uyusan,
        "fp32_dogru_aday_yanlis": bozulan, "fp32_yanlis_aday_dogru": duzelen,
        "mlperf_orani": round(d_aday / d_fp32, 4) if d_fp32 else None,
        "hedef_saglandi": kayip <= HEDEF_PUAN + 1e-9,
        "sinir_saglandi": kayip <= SINIR_PUAN + 1e-9,
        "mlperf_saglandi": d_aday >= min_mlperf,
        "karar": ("HEDEF sağlandı (<=1 puan)" if kayip <= HEDEF_PUAN + 1e-9 else
                  "SINIR içinde, hedef aşıldı (1-2 puan)" if kayip <= SINIR_PUAN + 1e-9 else
                  "SINIR aşıldı (>2 puan)"),
    }


def capraz_entropi(logit, etiket) -> dict:
    """Doğrulama kaybı: ortalama çapraz entropi + ortalama güven.

    Doğruluk ayrık bir ölçüdür (bir cümle ya doğru ya yanlış); çapraz entropi
    süreklidir ve modelin DOĞRU sınıfa verdiği olasılığı ölçer. Nicemleme
    kararı değiştirmese bile güveni aşındırıyorsa bu sayı yükselir.
    """
    logit = np.asarray(logit, dtype=np.float64)
    etiket = np.asarray(etiket)
    kaydir = logit - logit.max(axis=1, keepdims=True)
    log_toplam = np.log(np.exp(kaydir).sum(axis=1))
    log_olasilik = kaydir - log_toplam[:, None]
    kayip = -log_olasilik[np.arange(len(etiket)), etiket]
    olasilik = np.exp(log_olasilik)
    return {
        "kayip": round(float(kayip.mean()), 4),
        "kayip_ortanca": round(float(np.median(kayip)), 4),
        "ortalama_guven": round(float(olasilik.max(axis=1).mean()), 4),
        "dogru_sinif_olasiligi": round(float(olasilik[np.arange(len(etiket)), etiket].mean()), 4),
    }


def kos(p, ayar, ids, maske, ara, yigin=128):
    t = time.time()
    m = model.AltinModel(p, ayar, ara)
    lg = np.concatenate([m.ileri(i, k) for i, k in veri.yiginla(ids, maske, yigin)])
    return lg, round(time.time() - t, 1)


def main():
    ap = ortak.ortak_argumanlar(argparse.ArgumentParser(description=__doc__))
    ap.add_argument("--m0_bit", type=int, default=16,
                    help="B-kipi yeniden ölçekleme çarpanı bit genişliği")
    ap.add_argument("--ara_olcek", default=None)
    ap.add_argument("--yigin", type=int, default=128)
    a = ap.parse_args()

    p, _, cumleler, etiket, ids, maske, y = ortak.yukle_hepsi(a)

    ara_yol = a.ara_olcek or os.path.join(a.cikis, "ara_olcekler.json")
    if not os.path.exists(ara_yol):
        raise SystemExit("ara_olcekler.json yok. Önce: python 03_kalibre_ara_olcek.py")
    with open(ara_yol, encoding="utf-8") as f:
        ara = json.load(f)["olcekler"]

    # --- 01 adımının yazılım INT8 sonuçları ---
    satirlar = list(csv.DictReader(open(y["ptq_csv"], encoding="utf-8")))
    ptq_int8 = np.array([int(s["int8_tahmin"]) for s in satirlar])
    ptq_fp32 = np.array([int(s["fp32_tahmin"]) for s in satirlar])

    print(f"Veri: {len(cumleler)} cümle  |  PTQ koşusu: {a.kosu}\n")

    # --- altın modelin üç kipi ---
    lg32, t32 = kos(p, model.Ayarlar(kip="fp32"), ids, maske, ara, a.yigin)
    pr32 = lg32.argmax(1)
    lgA, tA = kos(p, model.Ayarlar(kip="A"), ids, maske, ara, a.yigin)
    prA = lgA.argmax(1)
    lgB, tB = kos(p, model.Ayarlar.B_kipi(m0_bit=a.m0_bit), ids, maske, ara, a.yigin)
    prB = lgB.argmax(1)

    # FP32 referansı olarak altın modelin kendi FP32 yolu kullanılır; PTQ'nun
    # kaydettiği FP32 tahminleriyle aynı olduğu ayrıca doğrulanır.
    fp32_tutarli = int((pr32 == ptq_fp32).sum())

    ptq_logit = np.array([[float(s["logit_olumsuz"]), float(s["logit_olumlu"])]
                          for s in satirlar])

    modeller = {
        "INT8-PTQ (yazılım)": (ptq_int8, ptq_logit, None),
        "Altın-A (PTQ eşdeğeri)": (prA, lgA, tA),
        "Altın-B (donanım)": (prB, lgB, tB),
    }
    sonuc = {
        "kosu": a.kosu, "m0_bit": a.m0_bit,
        "fp32": {"dogru": int((pr32 == etiket).sum()),
                 "dogruluk": round(float((pr32 == etiket).mean()), 4),
                 "sure_sn": t32,
                 "ptq_fp32_tahminleriyle_uyusma": fp32_tutarli},
        "modeller": {},
        "esdegerlik": {},
    }

    # ---- 1) DOĞRULUK TABLOSU ----
    print("1) DOĞRULUK — FP32 referansına göre")
    print(f"{'model':26s}{'doğru':>7s}{'%':>8s}{'kayıp':>8s}{'uyuşma':>9s}"
          f"{'hedef':>7s}{'MLPerf':>8s}")
    print("-" * 73)
    d32 = sonuc["fp32"]["dogru"]
    print(f"{'FP32 (referans)':26s}{d32:7d}{100*d32/len(etiket):8.2f}"
          f"{'—':>8s}{'—':>9s}{'—':>7s}{'—':>8s}")
    for ad, (pr, lg, sure) in modeller.items():
        o = degerlendir(etiket, pr32, pr)
        sonuc["modeller"][ad] = {**o, "sure_sn": sure, **capraz_entropi(lg, etiket)}
        print(f"{ad:26s}{o['dogru']:7d}{100*o['dogruluk']:8.2f}"
              f"{o['kayip_puan']:7.2f}p{100*o['uyusma_orani']:8.2f}%"
              f"{'EVET' if o['hedef_saglandi'] else 'HAYIR':>7s}"
              f"{'EVET' if o['mlperf_saglandi'] else 'HAYIR':>8s}")

    # ---- 2) DOĞRULAMA KAYBI (çapraz entropi) ----
    ce32 = capraz_entropi(lg32, etiket)
    sonuc["fp32"].update(ce32)

    # FP32 EĞİTİM kaybı ayrı bir büyüklüktür; 00 adımından okunur, hesaplanmaz.
    egitim_yol = os.path.join(ortak.PROJE, "00-FP32_Egitim", "03_Sonuclar", "sonuclar.json")
    egitim = None
    if os.path.exists(egitim_yol):
        with open(egitim_yol, encoding="utf-8") as f:
            g = json.load(f).get("gecmis", [])
        if g:
            egitim = {"son_epoch": g[-1]["epoch"],
                      "egitim_kaybi": round(float(g[-1]["train_loss"]), 4),
                      "kaynak": "00-FP32_Egitim/03_Sonuclar/sonuclar.json"}
            sonuc["fp32"]["egitim"] = egitim

    print("\n2) DOĞRULAMA KAYBI — çapraz entropi (doğruluktan daha hassas)")
    print(f"{'model':26s}{'kayıp':>9s}{'ortanca':>9s}{'ort. güven':>12s}"
          f"{'doğru sınıf ol.':>17s}")
    print("-" * 73)
    print(f"{'FP32 (referans)':26s}{ce32['kayip']:9.4f}{ce32['kayip_ortanca']:9.4f}"
          f"{ce32['ortalama_guven']:12.4f}{ce32['dogru_sinif_olasiligi']:17.4f}")
    for ad in modeller:
        o = sonuc["modeller"][ad]
        fark = o["kayip"] - ce32["kayip"]
        print(f"{ad:26s}{o['kayip']:9.4f}{o['kayip_ortanca']:9.4f}"
              f"{o['ortalama_guven']:12.4f}{o['dogru_sinif_olasiligi']:17.4f}"
              f"   ({fark:+.4f})")
    print("   Parantez içindeki sayı FP32'ye göre kayıp artışıdır (küçük = iyi).")
    if egitim:
        print(f"   NOT: FP32 EĞİTİM kaybı {egitim['egitim_kaybi']} "
              f"({egitim['son_epoch']}. epoch, eğitim kümesinde) — farklı bir "
              f"büyüklüktür, bu tabloyla karşılaştırılmaz.")
        print(f"        Kaynak: {egitim['kaynak']}")

    # ---- 3) EŞDEĞERLİK ----
    print("\n3) EŞDEĞERLİK — altın model gerçekten aynı modeli mi hesaplıyor?")
    ciftler = [
        ("Altın-A  vs  INT8-PTQ", prA, ptq_int8, "altın modelin GEÇERLİLİK KANITI"),
        ("Altın-B  vs  Altın-A", prB, prA, "donanım yaklaşımlarının etkisi"),
        ("Altın-FP32 vs PTQ-FP32", pr32, ptq_fp32, "FP32 yolunun tutarlılığı"),
    ]
    for ad, x, z, not_ in ciftler:
        ayni = int((x == z).sum())
        sonuc["esdegerlik"][ad] = {"ayni_tahmin": ayni, "toplam": len(etiket),
                                   "oran": round(ayni / len(etiket), 4), "not": not_}
        isaret = "BİREBİR" if ayni == len(etiket) else f"{len(etiket)-ayni} cümle farklı"
        print(f"   {ad:26s} {ayni:4d}/{len(etiket)}  {isaret:22s} ({not_})")

    # logit farkları (karar değişmese de sayısal yakınlığı gösterir)
    fark = np.abs(lgA - ptq_logit)
    sonuc["esdegerlik"]["Altın-A  vs  INT8-PTQ"]["logit_farki"] = {
        "ortanca": float(np.median(fark)), "p99": float(np.percentile(fark, 99)),
        "maks": float(fark.max())}
    print(f"   Altın-A logit farkı: ortanca {np.median(fark):.2e}  "
          f"%99 {np.percentile(fark,99):.2e}  maks {fark.max():.2e}")

    # ---- 4) AYRIŞAN CÜMLELER ----
    ayrisan = np.where((pr32 != prB) | (pr32 != ptq_int8) | (prA != ptq_int8))[0]
    os.makedirs(a.cikis, exist_ok=True)
    yol_csv = os.path.join(a.cikis, "ayrisan_cumleler.csv")
    with open(yol_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["idx", "cumle", "etiket", "fp32", "int8_ptq", "altin_A", "altin_B",
                    "fp32_logit_farki", "B_logit_farki"])
        for i in ayrisan:
            w.writerow([int(i), cumleler[i], int(etiket[i]), int(pr32[i]),
                        int(ptq_int8[i]), int(prA[i]), int(prB[i]),
                        f"{abs(lg32[i,1]-lg32[i,0]):.4f}",
                        f"{abs(lgB[i,1]-lgB[i,0]):.4f}"])
    print(f"\n4) AYRIŞAN CÜMLELER: {len(ayrisan)} cümle -> {yol_csv}")
    print("   (FP32 ile en az bir INT8 modelinin farklı karar verdiği cümleler;"
          " logit farkı küçük olanlar sınırdaki cümlelerdir)")

    # ---- çıktılar ----
    with open(os.path.join(a.cikis, "karsilastirma.json"), "w", encoding="utf-8") as f:
        json.dump(sonuc, f, ensure_ascii=False, indent=2)
    yol_ozet = os.path.join(a.cikis, "karsilastirma_ozet.csv")
    with open(yol_ozet, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["model", "dogru", "dogruluk", "kayip_puan", "kayip_cumle",
                    "uyusma_orani", "fp32_dogru_aday_yanlis", "fp32_yanlis_aday_dogru",
                    "mlperf_orani", "hedef_saglandi", "sinir_saglandi", "mlperf_saglandi",
                    "dogrulama_kaybi", "kayip_artisi", "ortalama_guven",
                    "dogru_sinif_olasiligi"])
        w.writerow(["FP32 (referans)", d32, round(d32/len(etiket), 4), 0.0, 0,
                    1.0, 0, 0, 1.0, True, True, True,
                    ce32["kayip"], 0.0, ce32["ortalama_guven"],
                    ce32["dogru_sinif_olasiligi"]])
        for ad, o in sonuc["modeller"].items():
            w.writerow([ad, o["dogru"], o["dogruluk"], o["kayip_puan"], o["kayip_cumle"],
                        o["uyusma_orani"], o["fp32_dogru_aday_yanlis"],
                        o["fp32_yanlis_aday_dogru"], o["mlperf_orani"],
                        o["hedef_saglandi"], o["sinir_saglandi"], o["mlperf_saglandi"],
                        o["kayip"], round(o["kayip"] - ce32["kayip"], 4),
                        o["ortalama_guven"], o["dogru_sinif_olasiligi"]])
    print(f"\nÖzet tablo -> {yol_ozet}")
    print(f"Tam rapor  -> {os.path.join(a.cikis, 'karsilastirma.json')}")


if __name__ == "__main__":
    main()
