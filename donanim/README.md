# Donanım (RTL)

Verilog-2001 kaynakları (`rtl/`), testbench dosyaları (`tb/`), benzetim çıktıları (`sim/`) ve ileride Vivado projeleri.
Bu aşamanın hedefi (G12, G13): INT8 işlem hücresi (PE) ve 4×4 çıkış-sabit sistolik dizi — **yalnızca benzetim**
(kartta çalıştırma, genelleştirme ve bellek tamponları kapsam dışıdır).

## Dosyalar

| Dosya | Açıklama |
|---|---|
| `rtl/pe.v` | İşlem hücresi: INT8×INT8 işaretli çarpma + INT32 biriktirici, senkron reset, enable. Çıkış-sabit (gerekçe dosyanın başındaki yorumda). |
| `rtl/systolic_4x4.v` | 16 PE'li 4×4 dizi + skew'li besleme + küçük kontrol FSM'i. Tek 4×4 matris çarpımı: `C = A·B`. |
| `tb/tb_pe.v` | PE testbench'i (reset, enable, uç değerler, 1000 rastgele MAC, K=512 en kötü durum). |
| `tb/gen_vektor.py` | numpy ile INT8 `A`,`B` üretir, `C = A·B` (INT32) hesaplayıp `tb/vektor/*.mem` yazar. |
| `tb/tb_systolic_4x4.v` | Dizi testbench'i: vektörleri okur, bire bir karşılaştırır, PASS/FAIL yazar. |
| `tb/vektor/` | Üretilen vektörler (`A.mem`, `B.mem`, `C.mem`, `meta.mem`, `aciklama.txt`). Yeniden üretilebilir. |
| `sim/` | Derleme çıktıları ve VCD dalga formları. |

## Gereksinimler

- Icarus Verilog (`iverilog`, `vvp`) ve GTKWave. Windows: <https://bleyer.org/icarus/> kurulumu ikisini birlikte getirir
  (ya da `choco install iverilog`).
- Python 3 + numpy (yalnızca vektör üretmek için; üretilmiş vektörler depoda olduğundan benzetim için şart değil).

## Çalıştırma (hepsi `donanim/` dizininden)

```bash
# 0) Test vektörlerini (yeniden) üret — isteğe bağlı, farklı tohum için --seed
python tb/gen_vektor.py                    # 9 uç durum + 200 rastgele + 50 uç-değerli rastgele = 259 test

# 1) PE'yi tek başına test et
iverilog -g2001 -Wall -o sim/tb_pe.vvp rtl/pe.v tb/tb_pe.v
vvp sim/tb_pe.vvp                          # beklenen son satır: PE TEST: PASS

# 2) 4x4 diziyi test et
iverilog -g2001 -Wall -o sim/tb_systolic_4x4.vvp rtl/pe.v rtl/systolic_4x4.v tb/tb_systolic_4x4.v
vvp sim/tb_systolic_4x4.vvp                # beklenen: SYSTOLIC 4x4 TEST: PASS

# 3) Dalga formu
gtkwave sim/tb_systolic_4x4.vcd
```

Not: `$readmemh` yolları `donanim/` dizinine göre yazılmıştır; testbench'i başka dizinden çalıştırmayın.

### Vivado xsim ile (alternatif)

```bash
xvlog rtl/pe.v rtl/systolic_4x4.v tb/tb_systolic_4x4.v
xelab -debug typical tb_systolic_4x4 -s tb_sys_sim
xsim tb_sys_sim -runall
```

Bu komutlar yazıldığı ortamda **denenmedi** (orada yalnızca Icarus Verilog vardı); xsim'de çalıştırıp sonucu doğrulayın.

## Dalga formunda nelere bakmalı

VCD yalnızca ilk 12 testi içerir (uç durumlar + birkaç rastgele; dosyayı küçük tutmak için). GTKWave'de önerilen sinyaller:

- `clk`, `start`, `busy`, `done`, `dut.cnt`
- `dut.a_feed`, `dut.b_feed` — skew'li besleme (her satır/sütun bir çevrim geç başlar)
- `dut.g_row[0].g_col[0].u_pe.acc` ve `dut.g_row[3].g_col[3].u_pe.acc` — ilk ve son PE'nin birikimi
- `c_flat` — `done=1` olduğunda geçerli sonuç

## Veri akışı ve zamanlama

- A satırları soldan, B sütunları yukarıdan akar. Satır *i* `i` çevrim, sütun *j* `j` çevrim geç başlar (skew).
  PE(i,j) girişinde çevrim *t*'de `k = t−i−j` olur: ikisi de `A[i][k]` ve `B[k][j]` değerlerini aynı anda görür.
- Her PE kendi `C[i][j]` değerini yerinde biriktirir (çıkış-sabit); komşuya yalnızca 8 bitlik işlenenler geçer.
- `start` kenarından `done`'a: **10 hesap çevrimi** (3·N−2, N=4) + start'ı örnekleyen 1 çevrim = **11 çevrim**.
  Son PE(3,3), son veriyi 10. hesap çevriminde (`cnt=9`) alır.
- `A`,`B` start kenarında yakalanır; sonrasında girişlerin değişmesi sonucu etkilemez. Hesap sürerken gelen `start` yok sayılır.

## Arayüz (`systolic_4x4`)

| Port | Yön | Anlam |
|---|---|---|
| `clk`, `rst` | giriş | saat, senkron reset (aktif-yüksek) |
| `start` | giriş | 1 çevrimlik başlatma darbesi |
| `a_flat[127:0]` | giriş | `A[i][k] = a_flat[(i*4+k)*8 +: 8]` (INT8, işaretli) |
| `b_flat[127:0]` | giriş | `B[k][j] = b_flat[(k*4+j)*8 +: 8]` |
| `c_flat[511:0]` | çıkış | `C[i][j] = c_flat[(i*4+j)*32 +: 32]` (INT32, işaretli), `done=1` iken geçerli |
| `busy`, `done` | çıkış | hesap sürüyor / bitti (yeni `start` veya `rst`'ye kadar 1 kalır) |
