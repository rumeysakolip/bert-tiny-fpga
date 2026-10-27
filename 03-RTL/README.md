# 03-RTL — BERT-Tiny INT8 hızlandırıcısı RTL (benzetim)

Hedef kart: Basys3 (XC7A35T-1CPG236). **Kart yok; tüm sonuçlar Icarus Verilog benzetimidir.** Altın model: `../02-RTL_Altin_Model`.

## Modüller (`rtl/`)
| Dosya | İş |
|---|---|
| `pe.v` | parametrik MAC (A 9b işaretli × B 8b → 32b) |
| `systolic_nxn.v` | N×N çıkış-sabit dizi, akışlı arayüz, tile = K+2N−2 çevrim |
| `bram_sdp.v`, `panel_tamponu.v` | aktivasyon/çıkış BRAM'i; çift tamponlu ağırlık paneli + bias/M0 |
| `tile_denetleyici.v` | tile sırası, adres, gölge acc, çıkış katı (K+15/tile) |
| `yeniden_olcekle.v` | (acc·M0 + 2^(n−1)) >>> n, kırp [−128,127] |
| `gelu_lut.v`, `cikis_paketle.v` | GELU/tanh tablosu; 8 token → 64 bit sözcük |
| `dogrusal_katman.v` | uçtan uca doğrusal katman |
| `komut_cozucu.v`, `uart_rx.v`, `uart_tx.v`, `hizlandirici_ust.v`, `hizlandirici_uart_ust.v` | host protokolü ve UART |

`legacy/`: TR01'deki 4×4 prototip (modül adları `_eski`), regresyon için.

## Koşturma (kök: bu klasör)
```
python scripts/kos_g4.py              # PE + dizi + N=4 regresyon (≈5 dk)
python scripts/g1_dogrula.py          # test vektörlerinin bağımsız denetimi
python scripts/kos_g7.py              # 12 doğrusal katman, paralel (uzun: ≥30 dk)
python scripts/g10_hazirla.py && python scripts/kos_g10.py   # dikkat çekirdeği
python ../host/g9_host_dongusu.py     # host-in-the-loop (benzetim arka ucu)
vvp sim/tb_uart.vvp                   # UART bit düzeyi (önce iverilog ile derle)
vivado -mode batch -source sentez/sentez.tcl -tclargs hizlandirici_uart_ust   # sentez
```
Test vektörleri: `../02-RTL_Altin_Model/03_Sonuclar/test_vektorleri` (düzen: `OKUBENI.md`).

## Bilinen sınırlar
Softmax/LayerNorm/artık toplam RTL'de yok (host). pooler/classifier RTL'de doğrulanmadı. Basys3 pin atamaları (`sentez/basys3.xdc`) kartta denenmedi.
