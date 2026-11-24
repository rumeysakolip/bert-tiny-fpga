"""notlar/DENEY_RAPORU.md ve notlar/YAPILANDIRMALAR.md dosyalarini olculmus sonuclardan (CSV, JSON, sentez raporlari) uretir.
Kullanim (cwd: 04-RTL_Komutsuz):  python scripts/uret_deney_belgeleri.py
Girdi: notlar/sonuclar/sure_tarama.csv, bilesen_dokumu.csv, islemci_token_sonuc_kosu*.json, sentez raporlari (sentez/raporlar_son/)."""
import csv
import glob
import json
import os
import re

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
N = os.path.join(KOK, "notlar")


def tr(x, n=2):
    return f"{x:,.{n}f}".replace(",", "_").replace(".", ",").replace("_", " ")


sat = {}
for r in csv.DictReader(open(os.path.join(N, "sonuclar", "sure_tarama.csv"), encoding="utf-8")):
    sat[(r["yapilandirma"], int(r["NA"]), int(r["token"]))] = int(r["cevrim"])
ILK = {1: {8: 1.053, 16: 1.142, 25: 1.216, 32: 1.330, 56: 1.673, 64: 1.794}, 10: {8: 1.130, 16: 1.158, 25: 1.182, 32: 1.215, 56: 1.365, 64: 1.398}}
cpu = {}
for f in glob.glob(os.path.join(N, "islemci_token_sonuc_kosu*.json")):
    for r in json.load(open(f, encoding="utf-8"))["sonuclar"]:
        for n, v in r["olcumler"].items():
            cpu.setdefault(int(n), []).append(v["ortalama_ms"])
for it in ILK.values():
    for n, v in it.items():
        cpu.setdefault(n, []).append(v)
cpu_iyi = {n: min(v) for n, v in cpu.items()}
cpu_kotu = {n: max(v) for n, v in cpu.items()}
TOK = [8, 16, 24, 32, 40, 48, 56, 64]


def ms(a, na, t):
    return sat[(a, na, t)] / 1e5


def kul(yol):
    t = open(yol, encoding="utf-8", errors="replace").read()
    d = {}
    for ad, k in (("Slice LUTs", "LUT"), ("Slice Registers", "FF"), ("Block RAM Tile", "BRAM"), ("DSPs", "DSP")):
        m = re.search(r"^\|\s*" + re.escape(ad) + r"\*?\s*\|\s*([\d.]+)\s*\|[^|]*\|[^|]*\|\s*([\d.]+)\s*\|\s*([\d.]+)\s*\|", t, re.M)
        d[k] = (float(m.group(1)), float(m.group(3))) if m else None
    return d


def zam(yol):
    t = open(yol, encoding="utf-8", errors="replace").read()
    i = t.index("Design Timing Summary")
    sat_ = [l for l in t[i:i + 2500].splitlines() if re.match(r"\s+-?\d+\.\d+\s+-?\d+\.\d+", l)]
    p = sat_[0].split()
    return float(p[0]), float(p[4])


R = os.path.join(KOK, "sentez", "raporlar_son")
SENTEZLER = [
    ("Basys 3 son tasarım (`ortak_ust_basys3`)", "XC7A35T", "100", "ust_impl"),
    ("Kart üst modülü (`kart_ust`)", "XC7A35T", "100", "kart_impl"),
    ("Üst model (`ortak_ust_ustmodel`)", "XC7A200T", "100", "ustmodel100_impl"),
    ("Üst model", "XC7A200T", "125", "ustmodel125_impl"),
    ("Üst model", "XC7A200T", "150", "ustmodel150_impl"),
    ("8 hat + LayerNorm + Softmax (dikkat seri)", "XC7A200T", "100", "tam8_impl"),
    ("2 hat (LayerNorm ve Softmax seri)", "XC7A100T", "100", "a100_na2_impl"),
]
srp = []
for ad, parca, mhz, on in SENTEZLER:
    k = os.path.join(R, on + "_kullanim.txt")
    z = os.path.join(R, on + "_zamanlama.txt")
    if not os.path.exists(k):
        continue
    d = kul(k)
    try:
        w, h = zam(z)
        zs = f"{tr(w, 3)} / {tr(h, 3)}"
    except Exception:
        zs = "—"
    f = lambda a: (f"{tr(d[a][0], 0 if a != 'BRAM' else 1)} (%{tr(d[a][1], 1)})" if d.get(a) else "—")
    srp.append(f"| {ad} | {parca} | {mhz} | {f('DSP')} | {f('LUT')} | {f('BRAM')} | {zs} |")
SENTEZ_TABLO = "| Tasarım | Parça | Saat (MHz) | DSP | LUT | Blok bellek (karo) | WNS / WHS (ns) |\n|---|---|---:|---:|---:|---:|---:|\n" + "\n".join(srp)

YAP = [("basys3", 1, "Basys 3 (1 dizi)"), ("temel", 2, "2 hat"), ("temel", 8, "8 hat, yalnız doğrusal paralel"), ("tam", 8, "8 hat + LayerNorm + Softmax paralel"),
       ("tamatt", 8, "**Üst model**: 8 hat + LayerNorm + Softmax + dikkat paralel")]
t1 = ["| Yapılandırma | " + " | ".join(str(t) for t in TOK) + " |", "|---|" + "---:|" * len(TOK)]
t1.append("| İşlemci, en iyi ölçüm | " + " | ".join(tr(cpu_iyi[t]) for t in TOK) + " |")
t1.append("| İşlemci, en kötü ölçüm | " + " | ".join(tr(cpu_kotu[t]) for t in TOK) + " |")
for a, na, ad in YAP:
    t1.append(f"| {ad} | " + " | ".join(tr(ms(a, na, t)) for t in TOK) + " |")
SURE_TABLO = "\n".join(t1)
t2 = ["| Belirteç | " + " | ".join(str(t) for t in TOK) + " |", "|---|" + "---:|" * len(TOK)]
t2.append("| İşlemci ÷ üst model | " + " | ".join(tr(cpu_iyi[t] / ms("tamatt", 8, t)) for t in TOK) + " |")
t2.append("| İşlemci ÷ Basys 3 | " + " | ".join(tr(cpu_iyi[t] / ms("basys3", 1, t)) for t in TOK) + " |")
ORAN_TABLO = "\n".join(t2)

bd = list(csv.DictReader(open(os.path.join(N, "sonuclar", "bilesen_dokumu.csv"), encoding="utf-8")))
t3 = ["| Yapılandırma | Belirteç | Doğrusal | İleri besleme | Dikkat | LayerNorm | Son | Toplam (çevrim) |", "|---|---:|---:|---:|---:|---:|---:|---:|"]
for r in bd:
    t3.append(f"| {r['yapilandirma']} | {r['token']} | {int(r['dogrusal']):,} | {int(r['ffn']):,} | {int(r['dikkat']):,} | {int(r['ln']):,} | {int(r['son']):,} | {int(r['toplam']):,} |".replace(",", " "))
DOKUM_TABLO = "\n".join(t3)

AREA = ["| Yapılandırma | DSP | Süre, 64 belirteç (ms) | DSP × ms | İşlemciden hızlı olduğu uzunluklar |", "|---|---:|---:|---:|---|",
        f"| Basys 3 (1 dizi) | 88 (ölçüldü) | {tr(ms('basys3', 1, 64))} | {tr(88 * ms('basys3', 1, 64), 0)} | ≈ 10 belirteçe kadar |",
        f"| 2 hat (LayerNorm ve Softmax seri) | 156 (ölçüldü, XC7A100T'ye sığmadı) | {tr(ms('temel', 2, 64))} | {tr(156 * ms('temel', 2, 64), 0)} | ≈ 15 belirteçe kadar |",
        f"| 8 hat + LayerNorm + Softmax paralel | 720 (ölçüldü) | {tr(ms('tam', 8, 64))} | {tr(720 * ms('tam', 8, 64), 0)} | 8–64 (64'te başa baş: 1,33 ms, işlemci 1,40 ms) |",
        f"| **Üst model** (dikkat de paralel) | 720 (ölçüldü) | {tr(ms('tamatt', 8, 64))} | {tr(720 * ms('tamatt', 8, 64), 0)} | 8–64'ün hepsi |"]
AREA_TABLO = "\n".join(AREA)

GORSELLER = "notlar/gorseller"
deney = f"""# Deney raporu — BERT-Tiny hızlandırıcısında hesap süresi çalışması (16–24 Kasım 2026)

Bu belge, `notlar/DENEY_KAYDI.md` içindeki ham deney kayıtlarının (D01–D20) rapor biçiminde özetidir. Sayıların hepsi bu depodaki betiklerle yeniden üretilebilir
(`scripts/`), her sayının kaynağı aşağıda belirtilmiştir. **Önemli sınırlama: bütün FPGA süreleri Vivado xsim benzetiminden ve sentez raporlarından gelir; kartta (donanımda)
ölçüm yapılmamıştır.** Kart elde bulunmadığı ve maliyeti yüksek olduğu için benzetim sonuçlarıyla ilerlenmiştir. İşlemci süreleri gerçek ölçümdür.

## 1. Amaç ve ölçüt
Bilgisayar–FPGA iletişim süresi ve ağırlık akışı hariç, yalnızca FPGA'nın hesap süresi; işlemciyle aynı cümle uzunluğunda karşılaştırılır. Önce Basys 3 (XC7A35T) ile
işlemciyi geçmek denenmiş; geçilemeyince daha büyük bir FPGA (XC7A200T), daha büyük/paralel dizi ve yonga içi ağırlık belleği ile "üst model" benzetimde gösterilmiştir.
İşlemci, modeli önceden yüklenmiş (ısınmış) bir PyTorch FP32 çıkarımıdır; üst modelde de ağırlıklar yonga içi bellekte hazır varsayılır (açılışta flaştan yüklenir, çıkarım süresine girmez).

## 2. Yöntem
- **Süre ölçümü:** `tb/tb_ortak_ust.v` süre kipi; "saf hesap" = aktivasyon bloğunun denetim kodunun doğrulandığı çevrimden sonuç darbesine kadar. 100 MHz varsayımıyla ms'ye çevrilmiştir. Her ölçüm tek cümle (ilk cümle).
- **Doğruluk:** her yapılandırma, nb = 1…8 blok sayısını kapsayan dokuz uzunluk (8, 9, 16, 24, 25, 32, 40, 48, 49, 56, 57, 64 belirteç) üzerinde altın modelle bit bit karşılaştırılmıştır (0 hata, sınıflar doğru). 8–49 belirteçlik cümleler gerçek SST-2 cümleleridir; 56, 57 ve 64 belirteçlik girdiler 54–55 belirteçlik cümlelerin dikkat maskesi uzatılarak üretilmiştir (`scripts/uret_dolgu_vektorleri.py`).
- **Sentez:** Vivado 2025.1, bağlamsız, yerleştirme ve yönlendirme sonrası rapor (`sentez/raporlar_son/`).
- **İşlemci:** i7-12650H, PyTorch FP32, 1 ve 10 iplik, `scripts/olc_islemci_token.py`; üç/dört koşu; ölçüm iki seviyeli dalgalandığından (1–1,6 ms ve 3–6 ms) en iyi ortalama alınmıştır.

## 3. Yapılan tasarım değişiklikleri
1. **Ölçüm kipi** (`HIZLI_OLCUM`) ve **dolgu atlama** (`DOLGU_ATLA`): cümlenin gerçek blok sayısı kadar hesap; 64 belirteçte 7,16 ms → LayerNorm iyileştirmesiyle 6,84 ms (Basys 3).
2. **LayerNorm**: varyans, yükleme sırasında biriken kareler toplamıyla (satır başına −126 çevrim; çarpım zamanlama için iki yarıma bölündü).
3. **Paralel doğrusal hatlar** (`NA`): her hat bir paneli hesaplar; kendi ağırlık bankası, panel tamponu, dizisi, yeniden ölçekleme devresi.
4. **Paralel LayerNorm** (`LN_PAR`): bir bloğun 8 satırı 8 hatta; **paralel Softmax** (`SMP`); **dikkat 8 hatta** (`ATTP`).

## 4. Sonuçlar
### 4.1 Saf hesap süresi (ms, 100 MHz; FPGA: benzetim, işlemci: ölçüm)
{SURE_TABLO}

İşlemci süresi FPGA süresine oranı (1'den büyük: FPGA daha hızlı):

{ORAN_TABLO}

![Süre ve cümle uzunluğu]({GORSELLER}/g14_sure_uzunluk.png)

![İşlemci ÷ FPGA süresi]({GORSELLER}/g15_hizlanma.png)

**Kesişim noktaları** (`notlar/sonuclar/kesisim.txt`): Basys 3 ≈ 10 belirteçe kadar işlemciden hızlı; 2 hat ≈ 15; 8 hat yalnız doğrusal paralel ≈ 27; 8 hat + paralel LayerNorm ve Softmax ve üst model 8–64'ün hepsinde (ilkinde 64 belirteçte yalnızca başa baş: 1,33 ms, işlemci 1,40 ms).

### 4.2 Hat sayısıyla ölçekleme
![Hat sayısı ve süre]({GORSELLER}/g16_hat_olcekleme.png)

### 4.3 Süre dökümü (çevrim)
{DOKUM_TABLO}

![Süre dökümü]({GORSELLER}/g17_sure_dokumu.png)

### 4.4 Sentez ve yerleştirme
{SENTEZ_TABLO}

XC7A100T denemesi sığmadı (blok bellek %107,8): ağırlıklar tek başına ≈ 410 KB (≈ 91 karo). XC7A200T'de 125 MHz (WNS −0,517 ns) ve 150 MHz (WNS −1,484 ns) tutmadı; yönlendirmede tutan en yüksek saat ≈ 117 MHz olarak kestirildi (iki başarısız koşudan; 100–117 MHz arası kısıtla yerleştirme yapılmadı).

![Kaynak kullanımı]({GORSELLER}/g18_kaynak_kullanimi.png)

![Saat etkisi]({GORSELLER}/g20_saat_etkisi.png)

### 4.5 Ağırlık akışı
Ağırlıklar flaştan her cümlede akıtılırsa süre flaş hızıyla sınırlanır (dört hatlı flaş: 12,5 MHz'de ≈ 66 ms, 100 MHz'de ≈ 8 ms; hesap); bu yüzden üst modelde ağırlıklar yonga içindedir.

![Ağırlık akışı]({GORSELLER}/g19_agirlik_akisi.png)

## 5. Sınırlar ve dürüst notlar
- Kartta ölçüm yok; süreler benzetim çevrimlerinin 100 MHz ile çevrilmesidir. Saat sınırı (≈ 117 MHz) kestirimdir.
- XC7A200T sentezi, LayerNorm çarpımının son boru hattı bölünmesinden önceki RTL ile yapıldı (yalnız boru hattı ekleyen bir değişiklik; yeniden sentezlenmedi).
- Süre ölçümleri ilk cümle ile; 56–64 belirteçlik üç girdi maske uzatmasıyla üretilmiştir.
- İşlemci ölçümü dalgalıdır (en iyi ortalama alındı); üst modelin 64 belirteçteki 1,4 kat avantajı bu seçime duyarlıdır.
- Güç ve enerji ölçülmemiştir.
- Ağırlıkların yonga içinde olduğu varsayımı XC7A100T ve Basys 3'e sığmaz.
"""
open(os.path.join(N, "DENEY_RAPORU.md"), "w", encoding="utf-8").write(deney)

yap = f"""# Yapılandırmalar ve nihai tasarım

Tek kod tabanı, parametrelerle farklı yapılandırmalar üretir (`rtl/ortak_ust.v`). Sabit parametreli sarmalayıcılar:
- `rtl/ortak_ust_basys3.v`: **nihai Basys 3 tasarımı** (XC7A35T): tek 8×8 dizi, ağırlıklar flaş bayt akışından (`kart_ust` bu yapılandırmayı kullanır). `NA=1, AGIRLIK_ROM=0, LN_PAR=0, SMP=0, ATTP=0, DOLGU_ATLA=1`.
- `rtl/ortak_ust_ustmodel.v`: **nihai üst model** (XC7A200T): `NA=8, AGIRLIK_ROM=1, ROM_D=6528, LN_PAR=1, SMP=1, ATTP=1, DOLGU_ATLA=1`. Ağırlık bankaları `python scripts/uret_agirlik_rom.py 8` ile üretilir (`vektor_rom/na8/agirlik_rom_b0..7.mem`).

| Parametre | Anlamı |
|---|---|
| `DOLGU_ATLA` | cümlenin gerçek blok sayısı nb = ⌈token/8⌉ kadar hesap (0: her zaman 8 blok) |
| `NA` | paralel doğrusal hat sayısı (1, 2, 4, 8) |
| `AGIRLIK_ROM` | 1: ağırlıklar yonga içi bankalardan; 0: bayt akışından |
| `LN_PAR` | 1: LayerNorm bir bloğun 8 satırı için 8 hatta |
| `SMP` | 1: Softmax bir bloğun 8 satırı için 8 birimde |
| `ATTP` | 1: Q·Kᵀ ve P·V 8 hatta (NA=8 ve SMP=1 gerekir) |
| `HIZLI_OLCUM` | 1: yalnız süre ölçümü (panel akışı beklenmez; sonuçlar anlamsız) |

## Nihai tasarım seçimi (yer ve zaman)
Ölçüt: işlemciyi 8–64 belirteçin hepsinde geçen en küçük yapılandırma. Ölçülen DSP ve 64 belirteçteki süreyle:

{AREA_TABLO}

- Çarpma bloğu (DSP) sayısı doğrusal hat sayısıyla belirlenir; paralel LayerNorm ve Softmax ek ≈ 184 DSP, dikkat hatları (`ATTP`) **ek DSP istemez** (+28 blok bellek, +1 000 LUT) ve süreyi 64 belirteçte 1,33 ms'den 1,02 ms'ye indirir. Bu yüzden aynı DSP sayısında (720) en hızlı ve işlemciyi her uzunlukta açık farkla geçen yapılandırma **üst model**dir; DSP × süre çarpımı da 8 hat + LayerNorm + Softmax'tan düşüktür.
- Daha küçük yapılandırmalar işlemciyi yalnız kısa cümlelerde geçer (tabloda son sütun); Basys 3, DSP × süre bakımından en küçük çözümdür fakat 10 belirteçten uzun cümlelerde işlemciden yavaştır.
- **Basys 3 için nihai tasarım** `ortak_ust_basys3`tür (donanıma sığan tek yapılandırma; ağırlıklar yonga içine sığmaz).

## Sentez ve yerleştirme sonuçları
{SENTEZ_TABLO}

## Yeniden üretme
```
python scripts/uret_dolgu_vektorleri.py                      # doğruluk vektörleri (vektor_dolgu/, yerel; depoya konmaz)
python scripts/uret_agirlik_rom.py 8                          # üst model ağırlık bankaları (vektor_rom/na8/)
python scripts/kos_xsim.py --na 8 --ln-par 1 --smp 1 --attp 1 --kume kume_4_64_64 --mod dogruluk   # bit-birebir sınama (Vivado xsim)
python scripts/kos_xsim.py --na 8 --ln-par 1 --smp 1 --attp 1 --kume kume_4_64_64 --mod sure       # saf hesap süresi
python scripts/tarama_sure.py 1,2,4,8                         # süre taraması (CSV: notlar/sonuclar/sure_tarama.csv)
python scripts/ciz_karsilastirma.py ; python scripts/bilesen_dokumu.py --sadece-ciz ; python scripts/ciz_kaynak_flas.py    # görseller
vivado -mode batch -source sentez/sentez_ust.tcl                                  # Basys 3 sentezi
vivado -mode batch -source sentez/kart_uret.tcl                                   # kart bit dosyası ve flaş görüntüleri
vivado -mode batch -source sentez/sentez_buyuk.tcl -tclargs 8 10.0 na8_att xc7a200tfbg676-2 1 1 1    # üst model sentezi
```
Basys 3 benzetim regresyonu: `python scripts/kos_xsim.py --na 1 --rom 0 --dolgu 0 --mod dogruluk` (4 cümle, 328 716 kontrol, 0 hata).
"""
open(os.path.join(N, "YAPILANDIRMALAR.md"), "w", encoding="utf-8").write(yap)
print("yazildi")
