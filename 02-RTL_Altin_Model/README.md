# 03 — RTL Altın (Golden) Referans Modeli

Bu dizin, FPGA'da kurulacak devrenin **Python'daki birebir karşılığını** tutar.
RTL yazmadan önceki son yazılım adımıdır: donanımın yapacağı her tamsayı işlemi
burada önce Python'da kurulur, doğruluğu ölçülür, sonra Verilog'a taşınır.

> **Neden doğrudan RTL'e geçilmiyor?**
> Testbench'in "beklenen çıktı" diye karşılaştıracağı bir referans olmazsa, bir
> uyuşmazlığın RTL hatasından mı yoksa nicemleme yaklaşımından mı geldiği
> ayırt edilemez. Altın model o referanstır: her modülün girdi/çıkış çiftlerini
> üretir ve her tamsayı yaklaşımının doğruluk maliyetini önceden ölçer.

**Girdi:** 01-INT8_Nicemleme adımının `minmax_sim_n128` koşusu (718/872, 0.11 puan kayıp)
**Taban:** FP32 719/872 · **Hedef:** ≥711 (≤1 puan) · **Katı sınır:** ≥702 (≤2 puan)
**Hedef kart:** Basys3 (XC7A35T-1CPG236) — 20800 LUT, 41600 FF, 50 BRAM36, 90 DSP

---

## Nasıl çalıştırılır

### Gereksinimler

| | |
|---|---|
| Python | 3.10 veya üstü |
| Paketler | `numpy`, `scipy`, `tokenizers`, `safetensors` (toplam ~60 MB) |
| **PyTorch / transformers** | **GEREKMEZ** — altın model saf NumPy'dir |
| GPU | gerekmez, hepsi CPU'da koşar |
| Colab | gerekmez, kendi bilgisayarında koşar |
| Toplam süre | tüm adımlar ~3 dakika |

PyTorch'un bilerek dışarıda bırakılması altın modelin en önemli özelliğidir:
donanımda ne olacağını tarif eden kodun, modeli eğiten kütüphaneye hiçbir
bağımlılığı yoktur. Böylece "PyTorch şöyle yuvarlıyormuş" türünden gizli bir
davranış sonuca sızamaz.

### Kurulum (bir kez)

```bat
cd C:\Users\rumey\Documents\biitirme-projem\02-RTL_Altin_Model\01_Kod
pip install -r requirements.txt
```

Conda kullanıyorsan önce ortamı etkinleştir (`conda activate <ortam>`), sonra
aynı `pip install` komutu. Kurulumu doğrulamak için:

```bat
python -c "import numpy, scipy, tokenizers, safetensors; print('TAMAM')"
```

### Adım adım koşturma

Tüm komutlar `01_Kod` klasörünün içinden çalıştırılır. Betikler girdileri
varsayılan olarak `../../01-INT8_Nicemleme/` altından okur, çıktıları
`../03_Sonuclar/` altına yazar — **hiçbir yol vermen gerekmez.**

#### 1. Birim testleri — ilkel işlemlerin doğruluğu (~5 saniye)

```bat
python testler\test_birimler.py
```

Beklenen son satır: `11 geçti, 0 kaldı`

Burada systolic dizinin vektörel matmul ile bit-birebir aynı olduğu, M0
ayrıştırmasının hata payı, GELU tablosunun doğruluğu, tamsayı karekök ve
tamsayı softmax sınırları tek tek kanıtlanır. **Bir tanesi bile kalırsa
sonraki adımlara geçme** — altın model bozuk demektir.

#### 2. Doğrulama — altın modelin geçerlilik ölçütü (~35 saniye)

```bat
python 02_dogrula_ptq.py
```

Beklenen son satır: `TÜM ÖLÇÜTLER GEÇTİ`

Üç ölçüt kontrol edilir: FP32 yolu 719/872 veriyor mu, A-kipi 718/872 verip
PTQ tahminleriyle 872/872 uyuşuyor mu, tamsayı yolunda taşma var mı.
Çıktı: `03_Sonuclar/dogrulama_raporu.json`

**Bu adım geçmeden RTL yazmaya başlama.** Geçmiyorsa altın model ile PTQ
ayrışmış demektir; testbench'in "beklenen çıktı"sına güvenilemez.

#### 3. Kalibrasyon — ara tensör ölçekleri (~25 saniye)

```bat
python 03_kalibre_ara_olcek.py
```

Beklenen: `40 ara tensör ölçeği yazıldı`

PTQ yalnızca 14 Linear katmanın GİRDİ ölçeğini kalibre etmişti. Tamsayı-only
veri yolu için LayerNorm girdi/çıkışı, dikkat skorları, GELU çıkışı gibi
tensörlerin de ölçeği gerekir; bu adım onları **eğitim kümesinden** çıkarır
(doğrulama kümesi sızıntısı olmasın diye). Çıktı: `03_Sonuclar/ara_olcekler.json`

#### 4. Karşılaştırma — FP32 / INT8-PTQ / Altın-A / Altın-B (~75 saniye)

```bat
python 05_karsilastir.py
```

Dört modeli tek tabloda karşılaştırır: doğruluk ve FP32'ye göre kayıp puan,
**doğrulama kaybı (çapraz entropi)**, MLPerf eşiği ve **eşdeğerlik** (Altın-A
ile INT8-PTQ birebir aynı kararları veriyor mu). Ayrıca FP32 eğitim kaybını
`00-FP32_Egitim/03_Sonuclar/sonuclar.json` dosyasından okuyup, karıştırılmasın
diye ayrı bir büyüklük olduğunu not düşer. Çıktılar: `karsilastirma.json`,
`karsilastirma_ozet.csv`, `ayrisan_cumleler.csv`

#### 5. Birim taraması — hangi donanım yaklaşımı ne kadara mal oluyor (~2,5 dakika)

```bat
python 01_altin_kos.py --tarama
```

A-kipinden başlayıp her donanım yaklaşımını tek tek açar, en sonunda hepsini
birden. Çıktı: `03_Sonuclar/birim_taramasi.csv`

Tek bir yapılandırmayı denemek için:

```bat
python 01_altin_kos.py --kip B --m0_bit 16
python 01_altin_kos.py --kip B --skor_bit 8      :: skoru 8 bite düşürünce ne oluyor
python 01_altin_kos.py --kip fp32                :: taban doğruluk
```

#### 6. RTL parametreleri — `.mem` ve `.vh` dosyaları (~10 saniye)

```bat
python 00_parametre_cikar.py --m0_bit 16
```

Vivado'nun `$readmemh` ile okuyacağı ağırlık/bias/M0 dosyalarını, LUT'ları ve
`parametreler.vh` başlığını üretir. Çıktı: `03_Sonuclar/parametreler/`

#### 7. Testbench vektörleri (~10 saniye)

```bat
python 04_test_vektoru_uret.py --n_cumle 4
```

Her modül için girdi + **beklenen** çıktı çiftleri.
Çıktı: `03_Sonuclar/test_vektorleri/`

### Başka bir PTQ koşusunu denemek

Varsayılan `minmax_sim_n128`. Değiştirmek için her betiğe aynı bayrak verilir:

```bat
python 02_dogrula_ptq.py --kosu percentile99.99_asim_n512
```

Dikkat: asimetrik koşularda sıfır noktası (zero-point) devreye girer ve
donanımda birikeç yoluna fazladan düzeltme terimi ekler. Altın model bunu
destekler ama `02_dogrula_ptq.py` içindeki beklenen doğruluk sayıları
`minmax_sim_n128` için yazılmıştır, o yüzden başka koşuda "KALDI" görmek
normaldir — sayıları `ozet_tablo.csv`'den güncelle.

### Takılırsan

| Belirti | Sebep / çözüm |
|---|---|
| `ModuleNotFoundError: scipy` | `pip install -r requirements.txt` koşmamış |
| `FileNotFoundError: ...int8_agirliklar.npz` | `01-INT8_Nicemleme/03_Sonuclar/` boş; Drive'dan koşu sonuçlarını indir |
| `B-kipi ara tensör ölçek tablosu ister` | Önce 3. adımı (`03_kalibre_ara_olcek.py`) çalıştır |
| Doğrulama "KALDI" diyor | Farklı bir PTQ koşusu seçilmiş olabilir (`--kosu`), ya da `01` adımı yeniden koşmuş ve sayılar değişmiş |
| Türkçe karakterler bozuk görünüyor | Windows konsolunda `chcp 65001` |
| Çok yavaş | Normal: 872 cümle × 64 token, saf NumPy. Hızlı deneme için `--yigin 256` |

---

## Düzen

| Yol | İçerik |
|---|---|
| `01_Kod/altin/sabitler.py` | Bit genişlikleri, model geometrisi, PE dizisi boyutu — RTL'deki `localparam`'ların tek kaynağı |
| `01_Kod/altin/nicem.py` | Nicemleme ilkel işlemleri: yuvarlama, kırpma, M0/kaydırma ayrıştırması, taşma kaydı |
| `01_Kod/altin/birimler.py` | `pe_mac`, `SistolikDizi`, `YenidenOlcekle`, `LineerKatman` |
| `01_Kod/altin/dogrusal_olmayan.py` | LayerNorm / Softmax / GELU / Tanh — her biri FP32 ve TAMSAYI sürümüyle |
| `01_Kod/altin/model.py` | Encoder katmanı + tam ileri yol (`AltinModel.ileri`), kip anahtarları (`Ayarlar`) |
| `01_Kod/altin/parametreler.py` | safetensors + npz + olcekler.json → donanım parametreleri |
| `01_Kod/altin/veri.py` | PTQ ile birebir aynı token'laştırma (padding=64, truncation) |
| `01_Kod/00_parametre_cikar.py` | `.mem` / `.vh` / bellek haritası üretir |
| `01_Kod/01_altin_kos.py` | Tek koşu ya da birim taraması |
| `01_Kod/02_dogrula_ptq.py` | **Geçerlilik ölçütü** — PTQ ile karşılaştırma |
| `01_Kod/03_kalibre_ara_olcek.py` | Ara tensör ölçeklerini eğitim kümesinden kalibre eder |
| `01_Kod/04_test_vektoru_uret.py` | Testbench vektörleri |
| `01_Kod/05_karsilastir.py` | FP32 / INT8-PTQ / Altın-A / Altın-B dört yönlü karşılaştırma |
| `03_Sonuclar/parametreler/` | `.mem` dosyaları + `parametreler.vh` + `bellek_haritasi.json` |
| `03_Sonuclar/test_vektorleri/` | Modül başına girdi + BEKLENEN çıktı |
| `03_Sonuclar/dogrulama_raporu.json` | Doğrulama ölçütlerinin sonucu |
| `03_Sonuclar/ara_olcekler.json` | Kalibre edilmiş ara tensör ölçekleri |
| `03_Sonuclar/birim_taramasi.csv` | Birim bazında doğruluk maliyeti tablosu |

---

## Üç kip

| Kip | Ne yapar | Ne için |
|---|---|---|
| `fp32` | Hiç nicemleme yok | Taban doğruluk (719/872) |
| **`A`** | 14 Linear katman INT8 matmul + INT32 birikeç; LayerNorm/Softmax/GELU/Tanh FP32 | **PTQ ile birebir** — altın modelin doğruluğunun kanıtı |
| `B` | Yeniden ölçekleme sabit noktalı, doğrusal olmayanlar tamsayı/LUT | FPGA'da gerçekten kurulacak devre |

B-kipinde birimler arası taşıma hâlâ float'tır; her birimin girdi/çıkışı kalibre
edilmiş ölçeklerle tamsayıya indirgenir ve birim kendi tamsayı algoritmasını
çalıştırır. Böylece **her yaklaşımın maliyeti tek tek ölçülebilir**. Hepsi
geçtikten sonra taşımayı da tamsayıya çevirmek mekanik bir adımdır.

---

## Doğrulama durumu

`python 02_dogrula_ptq.py` çıktısı:

| Ölçüt | Sonuç |
|---|---|
| FP32 yolu | **719/872** (beklenen 719) — PTQ'nun FP32 tahminleriyle 872/872 uyuşma |
| A-kipi | **718/872** (beklenen 718) — PTQ INT8 tahminleriyle **872/872 uyuşma** |
| A-kipi logit farkı | ortanca 2.6e-07 · %99 5.5e-04 · en büyük 1.5e-02 |
| Systolic dizi == vektörel matmul | **bit-birebir** |
| INT32 birikeç taşması | **yok** |

Logit farkı yalnızca FP32 kalan birimlerin (LayerNorm/softmax/GELU) numpy ile
torch arasındaki yuvarlama sırası farkından gelir; **tamsayı yolu birebirdir** ve
872 cümlenin hepsinde karar aynıdır.

---

## Model karşılaştırması (FP32 / INT8 / altın model)

`python 05_karsilastir.py` çıktısı. Ölçüt adları ve eşikler 01 adımındaki
`nicemleme_olcut.py` ile aynıdır, iki adımın raporları yan yana konabilir.

### Doğruluk

| Model | Doğru | % | FP32'ye göre kayıp | FP32 ile uyuşma | Hedef (≤1 p) | MLPerf (≥%99) |
|---|---|---|---|---|---|---|
| FP32 (referans) | 719 | 82,45 | — | — | — | — |
| INT8-PTQ (yazılım) | 718 | 82,34 | 0,11 p | %99,66 | ✔ | ✔ |
| **Altın-A** (PTQ eşdeğeri) | **718** | 82,34 | 0,11 p | %99,66 | ✔ | ✔ |
| **Altın-B** (donanım) | **720** | 82,57 | −0,11 p | %99,43 | ✔ | ✔ |

### Doğrulama kaybı (çapraz entropi)

Doğruluk ayrık bir ölçüdür: 872 cümlede bir cümlelik fark 0,11 puan demektir ve
±2 cümlelik gürültü taşır. Çapraz entropi süreklidir — karar değişmese bile
modelin doğru sınıfa verdiği olasılık aşınmışsa bunu gösterir. Nicemlemenin
modeli gerçekten bozup bozmadığı asıl burada görülür.

| Model | Doğrulama kaybı | FP32'ye göre | Ortanca | Ort. güven | Doğru sınıf olasılığı |
|---|---|---|---|---|---|
| FP32 (referans) | 0,5817 | — | 0,0124 | 0,9460 | 0,8074 |
| INT8-PTQ (yazılım) | 0,5826 | +0,0009 | 0,0123 | 0,9460 | 0,8065 |
| **Altın-A** | **0,5826** | **+0,0009** | 0,0123 | 0,9460 | 0,8065 |
| Altın-B (donanım) | 0,5752 | −0,0065 | 0,0127 | 0,9460 | 0,8086 |

Üç okuma:

- **INT8 nicemleme kaybı %0,15 artırıyor** (0,5817 → 0,5826). Modelin güveni
  pratikte hiç aşınmamış; doğruluktaki 1 cümlelik farkın gerçekten sınırdaki
  bir cümleden geldiğini bu doğruluyor.
- **Altın-A, PTQ ile virgülden sonra dört hanede aynı kaybı veriyor.** Bu,
  872/872 tahmin uyuşmasından daha güçlü bir eşdeğerlik kanıtıdır: yalnızca
  aynı kararları değil, aynı olasılıkları üretiyor.
- **Ortanca kayıp 0,0124, ortalama 0,5817.** Aradaki büyük fark, ortalamanın
  birkaç çok yanlış cümle tarafından sürüklendiğini gösteriyor; model cümlelerin
  büyük çoğunluğunda çok emin. Altın-B'nin ortalamasının düşük çıkması da aynı
  nedenle gürültüdür (fark, PTQ'nun FP32'den sapmasıyla aynı mertebede).

> **"Kayıp" sözcüğünün iki anlamı karıştırılmamalı.** Yukarıdaki tablo
> **doğrulama kaybıdır** (872 doğrulama cümlesinde çapraz entropi). FP32
> **eğitim kaybı** bambaşka bir büyüklüktür — eğitim kümesinde ölçülür ve
> `00-FP32_Egitim/03_Sonuclar/sonuclar.json` → `gecmis[].train_loss` içinde
> durur (epoch 1→4: 0,4197 / 0,2404 / 0,1904 / **0,1640**). Doğruluk
> tablolarındaki **"kayıp puan"** ise üçüncü bir şeydir: FP32'ye göre doğruluk
> farkı, yüzde puan cinsinden; FP32'nin kendisine göre kaybı tanımı gereği
> sıfır olduğu için o satırda "—" yazar.

### Eşdeğerlik — altın model gerçekten aynı modeli mi hesaplıyor?

| Karşılaştırma | Aynı tahmin | Anlamı |
|---|---|---|
| **Altın-A vs INT8-PTQ** | **872/872 BİREBİR** | **Altın modelin geçerlilik kanıtı** |
| Altın-FP32 vs PTQ-FP32 | 872/872 BİREBİR | FP32 yolu da tutarlı |
| Altın-B vs Altın-A | 864/872 (8 cümle farklı) | Donanım yaklaşımlarının toplam etkisi |

Doğruluğun yakın çıkması yetmez — altın modelin **aynı cümlelerde aynı kararı**
vermesi gerekir, yoksa testbench'in "beklenen çıktı"sına güvenilemez. 872/872
uyuşma bunu kanıtlıyor. Logit farkı da ortanca 2,6e−07 ile saf kayan nokta
yuvarlama gürültüsü düzeyinde (en büyük 1,5e−02, o da kararı değiştirmiyor).

### Ayrışan cümleler

FP32 ile en az bir INT8 modelinin farklı karar verdiği **toplam 8 cümle** var
(`03_Sonuclar/ayrisan_cumleler.csv`). Hepsinin ortak özelliği: FP32'nin iki
logiti arasındaki fark 0,03 ile 0,62 arasında — yani model bu cümlelerde zaten
kararsız. Örnek:

> `what better message than 'love thyself' could young women of any size receive?`
> FP32 logit farkı 0,0476

Bu, nicemlemenin modeli bozmadığının göstergesi: kayıp, **sınırdaki cümlelerin
hangi tarafa düştüğünden** ibaret, modelin öğrendiği temsilin bozulmasından
değil. Altın-B'nin FP32'den 1 cümle *fazla* doğru bulması (720) da aynı
nedenle gerçek bir iyileşme değil, 872 cümlelik kümenin gürültüsüdür (±2 cümle).

---

## Ölçülen donanım bulguları

Bunlar RTL'e doğrudan giren kararlardır:

### 1. INT32 birikeç fazlasıyla geniş — 21 bit yetiyor

Tüm katmanlarda görülen en büyük mutlak birikeç değeri **649 311** (21 bit).
Teorik en kötü durum bile `512 × 127 × 127 = 8 258 048` (24 bit), yani INT32'nin
yalnızca %0,4'ü. **Birikeci 24 bitte tutmak güvenli**; bu, PE başına 8 bitlik
toplayıcı ve yazmaç tasarrufu demektir — 64 PE'de kayda değer bir LUT kazancı.

### 2. Dikkat skoru 8 bit YETMEZ — 12 bit gerekir

Tamsayı softmax'ın hatası exp tablosundan değil, softmax'a **giren skorların**
nicemleme adımından geliyor:

| Skor bit genişliği | En büyük mutlak olasılık hatası |
|---|---|
| 8 bit | 0,0237 (tabloyu büyütmek düşürmüyor) |
| 12 bit | **0,0045** |
| 16 bit | 0,0041 |

Karar: `skor_bit = 12`, exp tablosu 512 girdi × 15 bit, menzil `[0, 8]`
(exp(−8) ≈ 3,4e−4, 1/255'lik olasılık çözünürlüğünün altında).

### 3. LayerNorm girdisi de 8 bit YETMEZ — 12 bit

LayerNorm artık (residual) toplamdan beslenir ve dinamik aralığı geniştir:

| Girdi bit genişliği | En büyük mutlak LayerNorm hatası |
|---|---|
| 8 bit | 0,125 |
| 12 bit | **0,037** |
| 16 bit | 0,033 |

Karar: `ln_bit = 12`.

### 4. GELU ve tanh bedavaya geliyor

256 girdilik INT8→INT8 arama tablosu, doğrudan hesapla **bit-birebir** aynı
sonucu veriyor (sapma 0). İkisi birlikte 512 bayt — Basys3'te dağıtık RAM'e sığar,
tek çevrimde okunur, hiç çarpma gerektirmez.

### 5. Yeniden ölçekleme çarpanı 16 bit yetiyor — çarpıcı başına tek DSP

`python 01_altin_kos.py --kip B --m0_bit <bit>` ile ölçüldü:

| M0 bit genişliği | Doğru | Kayıp | DSP48E1 maliyeti (32×M0 çarpım) |
|---|---|---|---|
| **16 bit** | **720** | −0,11 p | **1 DSP** |
| 18 bit | 717 | 0,23 p | 2 DSP |
| 24 bit | 717 | 0,23 p | 2 DSP |
| 31 bit | 717 | 0,23 p | 2 DSP |

16 bitin 720 vermesi gerçek bir iyileşme değil, 872 cümlelik kümenin gürültüsü
(±2 cümle); doğru okuma **"16 bit ile 31 bit arasında ölçülebilir fark yok"**.
Karar: `M0_BIT = 16`, paylaşımlı kaydırma. Basys3'ün 90 DSP'si düşünülünce bu,
yeniden ölçekleme biriminin bütçesini yarıya indirir.

### 6. Ağırlıklar Basys3'e tek seferde SIĞMIYOR — katman katman yükleme şart

`03_Sonuclar/parametreler/bellek_haritasi.json`:

| | Değer |
|---|---|
| Toplam parametre (ağırlık + bias + M0 tabloları) | **420,7 KB** |
| Gereken BRAM36 | **93,5** |
| Basys3'te mevcut | 50 |
| En büyük tek katman (`l0_ffn1`) | 15,1 BRAM36 |
| Tek bir encoder katmanının tamamı | ~201 KB → ~44,7 BRAM36 |

Yani **bir encoder katmanı BRAM'e sığıyor, ikisi birden sığmıyor.** Mimarî karar:
tek katmanlık donanım kurulur, iki kez çalıştırılır, arada ağırlıklar yeniden
yüklenir. Gömme tablosu (30522×128 = 3,9 MB) zaten FPGA'ya hiç girmez — arama
ana bilgisayarda yapılır, karta 64×128'lik INT8 vektör gider (16 KB).

---

## Birim bazında doğruluk maliyeti

`python 01_altin_kos.py --tarama` çıktısı (`03_Sonuclar/birim_taramasi.csv`):

A-kipinden başlanıp her donanım yaklaşımı **tek tek** açılır; en son hepsi birden:

| Yapılandırma | Doğru | Kayıp | Hedef (≥711) |
|---|---|---|---|
| A (taban) | 718 | 0,11 p | ✔ |
| + sabit noktalı yeniden ölçekleme | 715 | 0,46 p | ✔ |
| + LUT GELU | 718 | 0,11 p | ✔ |
| + LUT tanh | 718 | 0,11 p | ✔ |
| + tamsayı softmax | 720 | −0,11 p | ✔ |
| + tamsayı LayerNorm | 717 | 0,23 p | ✔ |
| **B (hepsi birden)** | **717** | **0,23 p** | **✔** |

Okunuşu:

- **Tüm donanım yaklaşımları birlikte yalnızca 0,23 puana mal oluyor** — hedefin
  (≤1 puan) çok içinde, katı sınırın (≤2 puan) ise uzağında. Nicemleme tarafında
  RTL'e geçmeyi engelleyen bir şey kalmadı.
- **En pahalı tek birim: sabit noktalı yeniden ölçekleme (0,46 p).** Tek başına
  açıldığında kayıp B-kipinin tamamından büyük; yani birimlerin hataları
  birikmiyor, kısmen birbirini götürüyor. Hassasiyet gerekirse ilk bakılacak yer
  burasıdır (M0 bit genişliği ya da kanal başına kaydırma).
- **Tamsayı softmax doğruluğu düşürmedi (720)**; bu, gerçek bir iyileşme değil
  872 cümlelik kümenin gürültüsüdür (±2 cümle). Doğru okuma: "softmax yaklaşımı
  ölçülebilir bir kayba yol açmıyor".
- **GELU ve tanh tabloları tamamen bedava** (718, taban ile aynı).

---

## RTL modül hiyerarşisi

Altın modeldeki her sınıf, yazılacak Verilog modülüne birebir karşılık gelir:

| Altın model | RTL modülü | Not |
|---|---|---|
| `birimler.pe_mac` | `pe.v` | DSP48E1 ya da LUT çarpıcı + 24 bit toplayıcı |
| `birimler.SistolikDizi` | `sistolik_dizi.v` | 8×8 çıkış-duralı dizi, K_DILIM=64 |
| `birimler.YenidenOlcekle` | `yeniden_olcekle.v` | M0 çarpıcı + yuvarlama + kaydırma + doyum |
| `birimler.LineerKatman` | `lineer_katman.v` | yukarıdakiler + bias + bellek arayüzü |
| `dogrusal_olmayan.katman_norm_tam` | `layer_norm.v` | toplayıcı ağacı + kare toplayıcı + tamsayı karekök + bölücü |
| `dogrusal_olmayan.softmax_tam` | `softmax.v` | maksimum ağacı + exp LUT + toplayıcı + bölücü |
| `dogrusal_olmayan.gelu_tam` | `gelu_lut.v` | 256×8 bit dağıtık RAM |
| `model.AltinModel.ileri` | `encoder_katmani.v` + `ust_duzey.v` | FSM durumları `ileri()` bloklarına karşılık gelir |

`SistolikDizi.cevrim_sayisi()` başarım tahmini verir: 64×128×128'lik bir matmul
8×8 dizide **18 432 çevrim**, PE kullanımı %100.

---

## Testbench kurulumu

`03_Sonuclar/test_vektorleri/` altında, en kısa 4 doğrulama cümlesi için modül
başına girdi ve **beklenen** çıktı var:

```verilog
$readmemh("l0_q_girdi.mem",   girdi);     // INT8 aktivasyon
$readmemh("l0_q_birikec.mem", beklenen);  // INT32 beklenen birikeç (bias dahil)
```

`kunye.json` her dosyanın şeklini, cümle metinlerini, etiketleri ve beklenen
logitleri taşır. Modül doğrulandıkça bir üst seviyeye geçilir; en üstte tüm
boru hattının çıkışı `kunye.json`'daki logitlerle karşılaştırılır.

---

## Sırada ne var (İP5)

1. `pe.v` + `sistolik_dizi.v` yaz, `l0_q` vektörleriyle doğrula — birikeç birebir tutmalı.
2. `yeniden_olcekle.v` — `l0_q_m0.mem` ve `KAYDIRMA_L0_Q` ile, M0 16 bit.
   (`.mem` dosyalarını 16 bitlik çarpanla yeniden üretmek için:
   `python 00_parametre_cikar.py --m0_bit 16`)
3. `gelu_lut.v`, `softmax.v`, `layer_norm.v` — bit genişlikleri yukarıdaki bulgulara göre.
4. `encoder_katmani.v` — tek katmanlık donanım, ağırlık yeniden yükleme ile iki geçiş.
5. UART/flash üzerinden ağırlık akıtma + ana bilgisayar tarafı (gömme araması).

**Bir sonraki ölçüm adımı:** birimler arası taşımayı da tamsayıya çevirip
(B-kipinin tam hâli) doğruluğun ≥711 kaldığını doğrulamak.
