# 03-RTL — BERT-Tiny INT8 hızlandırıcısı RTL (benzetim)

Hedef kart: Basys3 (XC7A35T-1CPG236). **Kart yok; tüm sonuçlar Icarus Verilog benzetimidir.** Altın model: `../02-RTL_Altin_Model`.

## Mimari
Tam sistem `bert_tiny_ust.v` üç parçadan oluşur:
- **`veri_yolu`**: gelen bayt yazmacı, komut/uzunluk/başlık/CRC yazmaçları, sözcük toplayıcı, yanıt yazmaçları ve verici yazmacı; bellekler (aktivasyon, ağırlık paneli, GELU tablosu, Softmax tablosu, LayerNorm parametreleri, sonuç tamponları) ve **işlem birimleri** (`dogrusal_katman`, `softmax_birim`, `layernorm_birim`) burada.
- **`komut_cozucu`**: komut yazmacını ve başlık alanlarını çözer. Kontrol sinyallerini (`komut_*`, geçerlilik) `kontrol_birimi`'ne, veri alanlarını (`alan_*`: ayar değerleri, okuma adresi/adedi) `veri_yolu` yazmaçlarına verir. Durum makinesi içermez.
- **`kontrol_birimi`**: istek evresi (komut, uzunluk, yük, CRC) ve yanıt evresi durum makineleri; veri yoluna yazma/yükleme sinyalleri ve birim darbeleri (`calistir_darbesi`, `softmax_baslat`, …) üretir. Veri tutmaz.

Host protokolü (komut kodları, bayt biçimi, CRC8) değişmedi.

## Modüller (`rtl/`)
| Dosya | İş |
|---|---|
| `islem_elemani.v` | parametrik MAC (A 9b işaretli × B 8b → 32b) |
| `sistolik_dizi.v` | N×N çıkış-sabit dizi, akışlı arayüz, tile = K+2N−1 çevrim |
| `cift_kapili_bellek.v`, `panel_tamponu.v` | aktivasyon/çıkış belleği; çift tamponlu ağırlık paneli + bias/M0 |
| `tile_denetleyici.v` | tile sırası, adres, gölge birikeç, çıkış katı |
| `yeniden_olcekle.v` | (birikeç·M0 + 2^(n−1)) >>> n, kırp [−128,127] |
| `gelu_tablosu.v`, `cikis_sozcuk_toplayici.v` | GELU/tanh tablosu; 8 token → 64 bit sözcük |
| `dogrusal_katman.v` | uçtan uca doğrusal katman |
| `softmax_birim.v`, `layernorm_birim.v`, `ters_bolucu.v`, `seri_bolucu.v`, `sonuc_tamponu.v` | Softmax, LayerNorm, ters değerli bölücü, seri bölücü, çıkış okuma tamponu |
| `veri_yolu.v`, `komut_cozucu.v`, `kontrol_birimi.v` | yukarıdaki mimari |
| `bert_tiny_ust.v`, `bert_tiny_uart_ust.v`, `bert_tiny_mmcm_ust.v` | bayt arayüzlü tam sistem; kart sarmalayıcısı (UART); saat üreteçli kart sarmalayıcısı |
| `uart_alici.v`, `uart_verici.v` | UART (8N1) |

Eski doğrusal-katman-yalnız üst modülü (`hizlandirici_ust`) kaldırıldı; aynı komutlar `bert_tiny_ust` ile çalışır.

`legacy/`: TR01'deki 4×4 prototip (modül adları `_eski`), regresyon için.

## Koşturma (kök: bu klasör)
```
python scripts/kos_g4.py              # PE + dizi + N=4 regresyon (≈5 dk)
python scripts/g1_dogrula.py          # test vektörlerinin bağımsız denetimi
python scripts/kos_g7.py              # 12 doğrusal katman, paralel (uzun: ≥30 dk)
python scripts/g10_hazirla.py && python scripts/kos_g10.py   # dikkat çekirdeği
python ../host/g9_host_dongusu.py     # host-in-the-loop (benzetim arka ucu)
vvp sim/tb_uart.vvp                   # UART bit düzeyi (önce iverilog ile derle)
vivado -mode batch -source sentez/sentez.tcl -tclargs bert_tiny_uart_ust      # sentez (tam sistem)
vivado -mode batch -source sentez/impl.tcl -tclargs bert_tiny_uart_ust        # yerleştirme-yönlendirme + bitstream
```
Test vektörleri: `../02-RTL_Altin_Model/03_Sonuclar/test_vektorleri` (düzen: `OKUBENI.md`).

## Bilinen sınırlar
Softmax/LayerNorm birimleri (`softmax_birim.v`, `layernorm_birim.v`, `seri_bolucu.v`) bağımsız olarak yazıldı ve bit-birebir doğrulandı (`python scripts/g11_vektor_uret.py && python scripts/kos_g11.py`), eskiden `hizlandirici_uart_ust`'a bağlı değildi; G13'ten beri `bert_tiny_ust`/`bert_tiny_uart_ust` içinde host komutlarıyla sürülür (ayrıntı `TOP_NOTLARI.md`); iç zincirleme (Q·Kᵀ→Softmax→P·V) yoktur, veri host üzerinden taşınır. pooler/classifier RTL'de doğrulanmadı. Basys3 pin atamaları (`sentez/basys3.xdc`) kartta denenmedi.

## Sentez iyileştirmesi (use_dsp)
`islem_elemani.v` modülüne `(* use_dsp = "yes" *)` eklendi; RTL davranışı değişmedi. Post-sentez (yerleştirme yok): 3 816 LUT, 4 216 FF, 15 BRAM, 68 DSP, WNS +1,648 ns (önceki: 10 110 LUT, 4 DSP, WNS −0,456 ns; `sentez/cikti/onceki_*.txt`). Sentezlenmiş dizi ağ listesi: `sentez/ps_sentez.tcl` + `sim/postsynth/` (xsim; testbench'e GSR için 200 ns gecikme eklendi).

## Implementasyon (yerleştirme + yönlendirme, bitstream yok)
`vivado -mode batch -source sentez/impl.tcl` (cwd: 03-RTL). Sonuç (`sentez/cikti/impl_*.txt`): 3 702 LUT, 4 219 FF, 15 BRAM, 68 DSP; 100 MHz setup WNS +0,721 ns, hold WHS +0,026 ns, 0 hatalı uç nokta, 0 yönlendirme hatası; güç tahmini 0,170 W (güven: orta). Giriş/çıkış gecikmeleri (rx, rst, tx) kısıtlanmadı.
