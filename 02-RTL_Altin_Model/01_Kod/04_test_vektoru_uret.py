"""T1 — Testbench vektörleri üret.

Her RTL modülünün doğrulanabilmesi için girdi/BEKLENEN-ÇIKTI çiftleri üretir.
Testbench akışı şöyle olacak:

    $readmemh("l0_q_girdi.mem", girdi);      // INT8 aktivasyon
    $readmemh("l0_q_birikec.mem", beklenen); // INT32 birikeç
    ... modülü koştur, çıkışı `beklenen` ile karşılaştır ...

Tek bir cümlenin tamamı için vektör üretilir (varsayılan: en kısa birkaç cümle,
çünkü testbench süresi dizi uzunluğuyla doğru orantılı).

Kip: varsayılan "B" (donanım-sadık: sabit noktalı yeniden ölçekleme, ara ölçek
tablosu `03_Sonuclar/ara_olcekler.json` gerekir). B-kipinde her Linear'ın girdi_q,
birikeç ve cikis_q değerleri AYNI koşudan gelir, bu yüzden RTL zinciri tutarlıdır.
"A" kipi yalnızca birikeç/girdi üretir, `*_cikis.mem` yazılmaz.

Düzen ayrıntıları `OKUBENI.md` dosyasına yazılır (satır-öncelikli, panel ve token-bloğu).

Çalıştırma:
    python 04_test_vektoru_uret.py --n_cumle 4
"""

from __future__ import annotations

import argparse
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ortak  # noqa: E402
from altin import model, sabitler as S, veri  # noqa: E402

importlib_hex = None


def hex_yaz(yol: str, dizi: np.ndarray, bit: int, aciklama: str):
    basamak = (bit + 3) // 4
    maske = (1 << bit) - 1
    with open(yol, "w", encoding="ascii") as f:
        f.write(f"// {aciklama}\n")
        f.write(f"// bicim: {bit} bit ikiye tumleyen, sekil={tuple(np.shape(dizi))}, "
                f"satir-oncelikli\n")
        for v in np.asarray(dizi).ravel():
            f.write(f"{int(v) & maske:0{basamak}x}\n")


def _katman_bul(p, tam_ad: str):
    """PTQ katman adından LineerKatman nesnesini bulur."""
    tum = []
    for k in p.katmanlar:
        tum += [k.q, k.k, k.v, k.attn_cikis, k.ffn1, k.ffn2]
    tum += [p.pooler, p.siniflandirici]
    return next(k for k in tum if k.ad == tam_ad)


def kelime_yaz(yol: str, kelimeler, bit: int, aciklama: str, sekil: str):
    """Her satır bir geniş sözcük (bit genişliği 8'in katı). Bayt 0 = en düşük bayt."""
    basamak = (bit + 3) // 4
    with open(yol, "w", encoding="ascii") as f:
        f.write(f"// {aciklama}\n")
        f.write(f"// bicim: {bit} bit sozcuk (bayt0 = en dusuk bayt), {sekil}\n")
        for w in kelimeler:
            f.write(f"{w:0{basamak}x}\n")


def _paketle(satirlar: np.ndarray) -> list[int]:
    """(N, 8) INT8 -> N adet 64 bit sözcük; sütun j, bayt j'ye gider."""
    u = (np.asarray(satirlar, dtype=np.int64) & 0xFF).astype(np.uint64)
    kay = np.arange(u.shape[1], dtype=np.uint64) * np.uint64(8)
    return [int(v) for v in (u << kay).sum(axis=1, dtype=np.uint64)]


def panel_duzeni(W: np.ndarray, genislik: int = S.PE_SATIR) -> list[int]:
    """W (C, K) -> panel p (8 kanal) x k : sözcük = W[p*8+j, k], j=0..7.
    C, genişliğin katı değilse sıfırla doldurulur (classifier: 2 -> 8)."""
    C, K = W.shape
    Cp = -(-C // genislik) * genislik
    Wp = np.zeros((Cp, K), dtype=np.int64)
    Wp[:C] = W
    return _paketle(Wp.reshape(Cp // genislik, genislik, K).transpose(0, 2, 1).reshape(-1, genislik))


def blok_duzeni(X: np.ndarray, genislik: int = S.PE_SUTUN) -> list[int]:
    """X (n, T, K) -> cümle s, token bloğu b, k : sözcük = X[s, b*8+i, k], i=0..7."""
    n, T, K = X.shape
    assert T % genislik == 0
    return _paketle(X.reshape(n, T // genislik, genislik, K).transpose(0, 1, 3, 2).reshape(-1, genislik))


OKUBENI = """# Test vektörü düzeni (OKUBENI)

Hepsi `$readmemh` ile okunur. `//` ile başlayan satırlar yorumdur. Sayılar ikiye tümleyendir
(`*_p.mem` ve `*_olasilik_u8.mem` işaretsiz). n = cümle sayısı (kunye.json), T = 64, K = girdi, C = çıkış kanalı.

## Doğrusal katmanlar (<ad> = l0_q, l0_k, ... classifier)
| Dosya | Sözcük | Sıra / indeks |
|---|---|---|
| `<ad>_girdi.mem` | 8 bit | [n][T][K] satır-öncelikli: ((s*T + t)*K + k); pooler/classifier: [n][K] (yalnız CLS token) |
| `<ad>_birikec.mem` | 32 bit | [n][T][C]: ((s*T + t)*C + c); bias DAHİL (acc + bias); pooler/classifier: [n][C] |
| `<ad>_cikis.mem` | 8 bit | [n][T][C]: INT8 = kirp((birikeç*M0 + 2^(n-1)) >> n) |
| `<ad>_girdi_blok.mem` | 64 bit | [n][B][K], B = T/8 (pooler/classifier: tek token → B=1, 7 satır sıfır dolgu): sözcük ((s*B + b)*K + k); bayt i = X[s, b*8+i, k] |
| `<ad>_w_panel.mem` | 64 bit | [C/8][K]: sözcük (p*K + k); bayt j = W[p*8+j, k] (C 8'in katı değilse sıfırla doldurulur: classifier 2->8) |

Yeniden ölçekleme sabitleri `parametreler/<ad>_m0.mem` (kanal başına M0, 31 bit) ve
`parametreler.vh` içindeki `KAYDIRMA_<AD>` (katman başına n). Bias `<ad>_b.mem`.
`<ad>_cikis.mem`, `<ad>_birikec.mem`'den `03-RTL/scripts/g1_dogrula.py` ile bağımsız olarak yeniden hesaplanır.

## Dikkat (l0, l1; baş h = 0,1; hepsi satır-öncelikli)
| Dosya | Sözcük | Şekil | Anlam |
|---|---|---|---|
| `l<i>_qk_q.mem` | 8 bit | [n][2][T][64] | Q başı (INT8, `l<i>_q_cikis` bölünmüş) |
| `l<i>_qk_k.mem` | 8 bit | [n][2][T][64] | K başı (INT8); Q·Kᵀ'de B işleneni K'nın transpozudur |
| `l<i>_qk_birikec.mem` | 32 bit | [n][2][T][T] | skor[i][j] = sum_d Q[i][d]*K[j][d] (INT32, ölçeklenmemiş) |
| `l<i>_av_p.mem` | 8 bit işaretsiz | [n][2][T][T] | softmax çıkışı UINT8 (0..255, ölçek 1/255); altın modelin `olasilik_q` değeri |
| `l<i>_av_v.mem` | 8 bit | [n][2][T][64] | V başı (INT8) |
| `l<i>_av_birikec.mem` | 32 bit | [n][2][T][64] | baglam[i][d] = sum_j P[i][j]*V[j][d] (INT32) |

`l<i>_olasilik_u8.mem` = `l<i>_av_p.mem` ile aynı içerik (geriye uyumluluk).
Dikkat vektörleri yalnızca tamsayı ÇARPIM çekirdeğini belgeler; altın modelde Q·Kᵀ ve P·V henüz float'tır
(tamsayıya alma: G2). Dolgu (maske=0) token'ları da dahildir; dizi T=64 sabit.

## Diğer
`token_ids.mem` 16 bit [n][T]; `maske.mem` 8 bit [n][T]; `fpga_girdi_q.mem` 8 bit [n][T][128] (ilk katman Q girdisi).
`kunye.json`: cümleler, etiket, logit, tahmin, kip, katman başına şekil/maksimum birikeç.
"""


def main():
    ap = ortak.ortak_argumanlar(argparse.ArgumentParser(description=__doc__))
    ap.add_argument("--n_cumle", type=int, default=4)
    ap.add_argument("--kip", choices=["A", "B"], default="B",
                    help="B: donanım-sadık (cikis_q üretilir, ara_olcekler.json gerekir)")
    ap.add_argument("--ara_olcek", default=None)
    ap.add_argument("--idx", type=int, nargs="*", default=None,
                    help="belirli cümle indeksleri (varsayılan: en kısa n_cumle tanesi)")
    a = ap.parse_args()

    p, _, cumleler, etiket, ids, maske, _ = ortak.yukle_hepsi(a)

    sec = (a.idx if a.idx
           else list(np.argsort(maske.sum(1))[:a.n_cumle]))
    sec = [int(i) for i in sec]
    print(f"Seçilen cümleler: {sec} (token sayıları: {[int(maske[i].sum()) for i in sec]})")

    cikis = os.path.join(a.cikis, "test_vektorleri")
    os.makedirs(cikis, exist_ok=True)

    if a.kip == "B":
        ara_yol = a.ara_olcek or os.path.join(a.cikis, "ara_olcekler.json")
        if not os.path.exists(ara_yol):
            raise SystemExit("ara_olcekler.json yok. Önce: python 03_kalibre_ara_olcek.py")
        with open(ara_yol, encoding="utf-8") as f:
            ara = json.load(f)["olcekler"]
        m = model.AltinModel(p, model.Ayarlar.B_kipi(izle_ara_tensor=True), ara)
    else:
        m = model.AltinModel(p, model.Ayarlar(kip="A", izle_ara_tensor=True))
    logit = m.ileri(ids[sec], maske[sec])

    kunye = {"kip": a.kip, "cumle_idx": sec,
             "cumleler": [cumleler[i] for i in sec],
             "etiket": [int(etiket[i]) for i in sec],
             "gercek_token_sayisi": [int(maske[i].sum()) for i in sec],
             "dizi_uzunlugu": S.DIZI_UZUNLUGU,
             "logit": logit.tolist(),
             "tahmin": logit.argmax(1).tolist(),
             "dosyalar": {}}

    # token kimlikleri ve maske (ana bilgisayar -> FPGA arayüzü)
    hex_yaz(os.path.join(cikis, "token_ids.mem"), ids[sec], 16, "token kimlikleri (UINT16)")
    hex_yaz(os.path.join(cikis, "maske.mem"), maske[sec], 8, "dikkat maskesi (1=gercek token)")

    # FPGA'ya giren gömme vektörleri, ilk katmanın Q ölçeğinde INT8
    girdi_q = m.izle["l0.q.girdi_q"]
    hex_yaz(os.path.join(cikis, "fpga_girdi_q.mem"), girdi_q, S.AKTIVASYON_BIT,
            f"FPGA girdisi: gomme+LayerNorm ciktisi, olcek={p.katmanlar[0].q.a_olcek:.9e}")
    kunye["fpga_girdi_olcek"] = p.katmanlar[0].q.a_olcek

    # her Linear için: INT8 girdi + INT32 beklenen birikeç
    for tam_ad, kisa in S.KISA_AD.items():
        on = S.IZLE_ADI[tam_ad]
        gq, acc = m.izle.get(f"{on}.girdi_q"), m.izle.get(f"{on}.birikec")
        if gq is None:
            continue
        hex_yaz(os.path.join(cikis, f"{kisa}_girdi.mem"), gq, S.AKTIVASYON_BIT,
                f"{tam_ad} girdisi (INT8)")
        hex_yaz(os.path.join(cikis, f"{kisa}_birikec.mem"), acc, S.BIRIKEC_BIT,
                f"{tam_ad} BEKLENEN birikec (INT32, bias dahil)")
        gq3 = np.asarray(gq)
        if gq3.ndim == 2:                # pooler/classifier: cümle başına tek token (CLS)
            gq3 = gq3[:, None, :]
        tok = -(-gq3.shape[1] // 8) * 8  # 8'in katına sıfırla doldur
        gq3 = np.concatenate([gq3, np.zeros((gq3.shape[0], tok - gq3.shape[1], gq3.shape[2]), gq3.dtype)], axis=1)
        kat = _katman_bul(p, tam_ad)
        kelime_yaz(os.path.join(cikis, f"{kisa}_girdi_blok.mem"), blok_duzeni(gq3), 64,
                   f"{tam_ad} girdisi, token-blogu duzeni",
                   f"sekil=[n={len(sec)}][T/8={tok // 8}][K={gq3.shape[2]}]")
        kelime_yaz(os.path.join(cikis, f"{kisa}_w_panel.mem"), panel_duzeni(kat.w_q), 64,
                   f"{tam_ad} agirligi, 8 kanalli panel duzeni",
                   f"sekil=[P={-(-kat.w_q.shape[0] // 8)}][K={kat.w_q.shape[1]}]")
        cikis_q = m.izle.get(f"{on}.cikis_q")
        if cikis_q is not None:
            hex_yaz(os.path.join(cikis, f"{kisa}_cikis.mem"), cikis_q, S.AKTIVASYON_BIT,
                    f"{tam_ad} yeniden olceklenmis cikis (INT8)")
        kunye["dosyalar"][kisa] = {
            "girdi": f"{kisa}_girdi.mem", "girdi_sekil": list(np.shape(gq)),
            "beklenen": f"{kisa}_birikec.mem", "beklenen_sekil": list(np.shape(acc)),
            "cikis": f"{kisa}_cikis.mem" if cikis_q is not None else None,
            "birikec_maks_mutlak": int(np.abs(acc).max()),
            "gereken_bit": int(np.abs(acc).max()).bit_length() + 1,
        }

    # dikkat ara tensörleri (softmax modülü + Q.K^T ve P.V çekirdeği için)
    n, T, H, D = len(sec), S.DIZI_UZUNLUGU, S.BASLIK_SAYISI, S.BASLIK_BOYU

    def baslara(x):                      # (n, T, 128) -> (n, H, T, D)
        return np.asarray(x).reshape(n, T, H, D).transpose(0, 2, 1, 3)

    for i in range(S.KATMAN_SAYISI):
        skor = m.izle[f"l{i}.skor"]
        olasilik = m.izle[f"l{i}.olasilik"]
        np.save(os.path.join(cikis, f"l{i}_skor_fp32.npy"), skor)
        np.save(os.path.join(cikis, f"l{i}_olasilik_fp32.npy"), olasilik)
        p_q = m.izle.get(f"l{i}.olasilik_q")
        if p_q is None:                  # A kipi: float olasılıktan türet
            p_q = np.clip(np.rint(olasilik * 255), 0, 255)
        p_q = np.asarray(p_q, dtype=np.int64)
        hex_yaz(os.path.join(cikis, f"l{i}_olasilik_u8.mem"), p_q, 8,
                f"katman {i} softmax ciktisi, UINT8 (olcek 1/255), sekil [n][2][T][T]")
        qk, kk, vk = (m.izle.get(f"l{i}.{x}.cikis_q") for x in ("q", "k", "v"))
        if qk is None:
            continue
        qh, kh, vh = (baslara(x).astype(np.int64) for x in (qk, kk, vk))
        qk_acc = qh @ kh.transpose(0, 1, 3, 2)           # (n,H,T,T)
        av_acc = p_q @ vh                                 # (n,H,T,D)
        hex_yaz(os.path.join(cikis, f"l{i}_qk_q.mem"), qh, 8, f"katman {i} Q basi INT8 [n][2][T][64]")
        hex_yaz(os.path.join(cikis, f"l{i}_qk_k.mem"), kh, 8, f"katman {i} K basi INT8 [n][2][T][64]")
        hex_yaz(os.path.join(cikis, f"l{i}_qk_birikec.mem"), qk_acc, S.BIRIKEC_BIT,
                f"katman {i} Q.K^T birikeci INT32 [n][2][T][T]")
        hex_yaz(os.path.join(cikis, f"l{i}_av_p.mem"), p_q, 8, f"katman {i} olasilik UINT8 [n][2][T][T]")
        hex_yaz(os.path.join(cikis, f"l{i}_av_v.mem"), vh, 8, f"katman {i} V basi INT8 [n][2][T][64]")
        hex_yaz(os.path.join(cikis, f"l{i}_av_birikec.mem"), av_acc, S.BIRIKEC_BIT,
                f"katman {i} P.V birikeci INT32 [n][2][T][64]")
        kunye.setdefault("dikkat", {})[f"l{i}"] = {
            "qk_birikec_maks_mutlak": int(np.abs(qk_acc).max()),
            "av_birikec_maks_mutlak": int(np.abs(av_acc).max()),
            "av_gereken_bit": int(np.abs(av_acc).max()).bit_length() + 1}

    with open(os.path.join(cikis, "OKUBENI.md"), "w", encoding="utf-8") as f:
        f.write(OKUBENI)

    with open(os.path.join(cikis, "kunye.json"), "w", encoding="utf-8") as f:
        json.dump(kunye, f, ensure_ascii=False, indent=2)

    enb = max(kunye["dosyalar"].items(), key=lambda kv: kv[1]["gereken_bit"])
    print(f"{len(kunye['dosyalar'])} katman için vektör yazıldı -> {cikis}")
    print(f"En geniş birikeç: {enb[0]} -> {enb[1]['gereken_bit']} bit "
          f"(maks |acc| = {enb[1]['birikec_maks_mutlak']})")
    print(f"Tahminler: {kunye['tahmin']}  etiketler: {kunye['etiket']}")


if __name__ == "__main__":
    main()
