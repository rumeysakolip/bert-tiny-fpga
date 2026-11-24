# Yapılandırmalar ve nihai tasarım

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

| Yapılandırma | DSP | Süre, 64 belirteç (ms) | DSP × ms | İşlemciden hızlı olduğu uzunluklar |
|---|---:|---:|---:|---|
| Basys 3 (1 dizi) | 88 (ölçüldü) | 6,84 | 602 | ≈ 10 belirteçe kadar |
| 2 hat (LayerNorm ve Softmax seri) | 156 (ölçüldü, XC7A100T'ye sığmadı) | 4,75 | 740 | ≈ 15 belirteçe kadar |
| 8 hat + LayerNorm + Softmax paralel | 720 (ölçüldü) | 1,33 | 961 | 8–64 (64'te başa baş: 1,33 ms, işlemci 1,40 ms) |
| **Üst model** (dikkat de paralel) | 720 (ölçüldü) | 1,02 | 732 | 8–64'ün hepsi |

- Çarpma bloğu (DSP) sayısı doğrusal hat sayısıyla belirlenir; paralel LayerNorm ve Softmax ek ≈ 184 DSP, dikkat hatları (`ATTP`) **ek DSP istemez** (+28 blok bellek, +1 000 LUT) ve süreyi 64 belirteçte 1,33 ms'den 1,02 ms'ye indirir. Bu yüzden aynı DSP sayısında (720) en hızlı ve işlemciyi her uzunlukta açık farkla geçen yapılandırma **üst model**dir; DSP × süre çarpımı da 8 hat + LayerNorm + Softmax'tan düşüktür.
- Daha küçük yapılandırmalar işlemciyi yalnız kısa cümlelerde geçer (tabloda son sütun); Basys 3, DSP × süre bakımından en küçük çözümdür fakat 10 belirteçten uzun cümlelerde işlemciden yavaştır.
- **Basys 3 için nihai tasarım** `ortak_ust_basys3`tür (donanıma sığan tek yapılandırma; ağırlıklar yonga içine sığmaz).

## Sentez ve yerleştirme sonuçları
| Tasarım | Parça | Saat (MHz) | DSP | LUT | Blok bellek (karo) | WNS / WHS (ns) |
|---|---|---:|---:|---:|---:|---:|
| Basys 3 son tasarım (`ortak_ust_basys3`) | XC7A35T | 100 | 88 (%97,8) | 5 662 (%27,2) | 25,0 (%50,0) | 0,418 / 0,039 |
| Kart üst modülü (`kart_ust`) | XC7A35T | 100 | 88 (%97,8) | 5 928 (%28,5) | 25,0 (%50,0) | 0,357 / 0,019 |
| Üst model (`ortak_ust_ustmodel`) | XC7A200T | 100 | 720 (%97,3) | 34 217 (%25,6) | 251,5 (%68,9) | 0,221 / 0,046 |
| Üst model | XC7A200T | 125 | 720 (%97,3) | 34 633 (%25,9) | 251,5 (%68,9) | -0,517 / 0,060 |
| Üst model | XC7A200T | 150 | 720 (%97,3) | 35 160 (%26,3) | 251,5 (%68,9) | -1,484 / 0,055 |
| 8 hat + LayerNorm + Softmax (dikkat seri) | XC7A200T | 100 | 720 (%97,3) | 33 213 (%24,8) | 223,5 (%61,2) | 0,370 / 0,065 |
| 2 hat (LayerNorm ve Softmax seri) | XC7A100T | 100 | 156 (%65,0) | 20 456 (%32,3) | 145,5 (%107,8) | — |

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
