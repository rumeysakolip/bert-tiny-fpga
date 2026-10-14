# G4 — Gerçek aktivasyonlarla doğrulama (otomatik üretildi)

Veri: CSV: /mnt/user-data/uploads/biitirme-projem/bert-tiny-fpga/deneyler/fp32_baz/dogrulama_tahminleri.csv (872 cümle, yalnızca dolgu olmayan token'lar). Model: `/mnt/user-data/uploads/biitirme-projem/fp32_baz-20261014T100446Z-1-001/fp32_baz/model`. G3 tahminleriyle tutarlılık: yüklenen model doğruluğu %82.45; G3 CSV tahminlerinden farklı: 0/872

## Aykırı değer dağılımı

| Kayıt noktası | n | min | p0,1 | p50 | p99,9 | max | maks/std | maks/p99,9 | std/adım (8 / 12 / 16 bit) |
|---|---|---|---|---|---|---|---|---|---|
| GELU girdisi · layer.0 | 11234816 | -11.26 | -7.352 | -0.492 | 5.597 | 10.85 | 7.82 | 1.53 | 16.2 / 262 / 4.19e+03 |
| GELU girdisi · layer.1 | 11234816 | -10.8 | -5.552 | -0.4859 | 3.195 | 6.49 | 8.6 | 1.95 | 14.8 / 238 / 3.81e+03 |
| Softmax girdisi (skor) · layer.0 | 1291842 | -6.056 | -4.12 | -0.001265 | 6.238 | 9.434 | 6.15 | 1.51 | 20.7 / 333 / 5.33e+03 |
| Softmax girdisi (skor) · layer.1 | 1291842 | -11.22 | -5.656 | 1.346 | 8.415 | 10.35 | 5.26 | 1.33 | 24.1 / 389 / 6.22e+03 |
| LayerNorm girdisi · embeddings.LayerNorm | 2808704 | -1.017 | -0.3663 | -0.009496 | 0.197 | 0.3603 | 15.2 | 2.78 | 8.34 / 134 / 2.15e+03 |
| LayerNorm girdisi · encoder.layer.0.attention.output.LayerNorm | 2808704 | -12.02 | -5.953 | 0.001161 | 5.077 | 9.685 | 7.54 | 2.02 | 16.8 / 271 / 4.34e+03 |
| LayerNorm girdisi · encoder.layer.0.output.LayerNorm | 2808704 | -28.92 | -9.566 | 0.07671 | 4.365 | 10.07 | 19.3 | 3.02 | 6.6 / 106 / 1.7e+03 |
| LayerNorm girdisi · encoder.layer.1.attention.output.LayerNorm | 2808704 | -12.66 | -5.468 | -0.00134 | 5.805 | 10.16 | 7.36 | 2.18 | 17.3 / 278 / 4.45e+03 |
| LayerNorm girdisi · encoder.layer.1.output.LayerNorm | 2808704 | -5.989 | -3.891 | 0.05017 | 3.822 | 5.492 | 4.71 | 1.54 | 26.9 / 434 / 6.95e+03 |

LayerNorm girdilerinde en büyük |değer| taşıyan gizli boyutlar:

- LayerNorm girdisi · embeddings.LayerNorm: kanal 2 (1.017), kanal 32 (0.4955), kanal 124 (0.47)
- LayerNorm girdisi · encoder.layer.0.attention.output.LayerNorm: kanal 2 (12.02), kanal 47 (9.685), kanal 31 (9.362)
- LayerNorm girdisi · encoder.layer.0.output.LayerNorm: kanal 2 (28.92), kanal 73 (15.16), kanal 32 (13.03)
- LayerNorm girdisi · encoder.layer.1.attention.output.LayerNorm: kanal 73 (12.66), kanal 16 (10.75), kanal 111 (10.16)
- LayerNorm girdisi · encoder.layer.1.output.LayerNorm: kanal 125 (5.989), kanal 50 (5.771), kanal 105 (5.761)

## GELU (gerçek girdi; en kötü katman)

| Girdi bit | maks hata | RMS hata | ref RMS | rastgele maks hata (8/12/16) |
|---|---|---|---|---|
| 8 | 0.075 | 0.01951 | 0.6322 | 0.04826 |
| 12 | 0.02103 | 0.00794 | 0.6322 | 0.01999 |
| 16 | 0.01832 | 0.00789 | 0.6322 | 0.01827 |
| 22 | 0.01815 | 0.007891 | 0.6322 | — |

## Softmax (gerçek girdi; katmanlar birlikte en kötü değer)

| Girdi bit | Çıkış bit | maks hata | ort hata | satır toplamı (ort / min) | argmax uyuşma | rastgele argmax | rastgele satır toplamı |
|---|---|---|---|---|---|---|---|
| 8 | 8 | 0.07119 | 0.00384 | 0.8949 / 0.7188 | 0.9799 | 0.9754 | 0.8911 |
| 8 | 16 | 0.06633 | 0.002124 | 0.9995 / 0.9988 | 0.9805 | 0.9754 | 0.9991 |
| 12 | 8 | 0.0115 | 0.003444 | 0.8986 / 0.7344 | 0.9858 | 0.9924 | 0.9097 |
| 12 | 16 | 0.004018 | 0.0001309 | 0.9995 / 0.9989 | 0.9986 | 0.9984 | 0.9991 |
| 16 | 8 | 0.008446 | 0.003435 | 0.8989 / 0.75 | 0.9858 | 0.992 | 0.9101 |
| 16 | 16 | 0.0008748 | 4.746e-05 | 0.9995 / 0.9989 | 0.9999 | 0.9998 | 0.9991 |
| 22 | 8 | 0.008446 | 0.003435 | 0.8989 / 0.75 | 0.9858 | — | — |
| 22 | 16 | 0.0009358 | 4.96e-05 | 0.9995 / 0.9989 | 0.9999 | — | — |

## LayerNorm — özet (5 kayıt noktasındaki en kötü değer)

| Girdi bit | gerçek maks hata | gerçek RMS hata (en kötü) | rastgele maks hata | rastgele RMS hata | gereken Newton yinelemesi (gerçek, en çok) |
|---|---|---|---|---|---|
| 8 | 1.151 | 0.122 | — | — | 3 |
| 12 | 0.06343 | 0.00852 | 0.0127 | 0.00218 | 4 |
| 16 | 0.00395 | 0.0005192 | 0.0008 | 0.00014 | 4 |
| 22 | 8.379e-05 | 1.673e-05 | 0 | 2e-05 | 5 |

## LayerNorm (gerçek girdi; kayıt noktası bazında)

| Kayıt noktası | Girdi bit | maks hata | RMS hata | afin sonrası maks hata | min tamsayı varyans |
|---|---|---|---|---|---|
| bert.embeddings.LayerNorm | 8 | 0.8144 | 0.1165 | 0.9633 | 40 |
| bert.embeddings.LayerNorm | 12 | 0.04474 | 0.006831 | 0.05552 | 1.026e+04 |
| bert.embeddings.LayerNorm | 16 | 0.002882 | 0.00042 | 0.003434 | 2.629e+06 |
| bert.embeddings.LayerNorm | 22 | 7.495e-05 | 1.543e-05 | 7.222e-05 | 1.077e+10 |
| bert.encoder.layer.0.attention.output.LayerNorm | 8 | 0.5234 | 0.06001 | 0.9514 | 158 |
| bert.encoder.layer.0.attention.output.LayerNorm | 12 | 0.03141 | 0.003252 | 0.0571 | 4.113e+04 |
| bert.encoder.layer.0.attention.output.LayerNorm | 16 | 0.001994 | 0.0001958 | 0.003626 | 1.054e+07 |
| bert.encoder.layer.0.attention.output.LayerNorm | 22 | 5.818e-05 | 1.628e-05 | 0.0001058 | 4.317e+10 |
| bert.encoder.layer.0.output.LayerNorm | 8 | 1.151 | 0.122 | 1.143 | 25 |
| bert.encoder.layer.0.output.LayerNorm | 12 | 0.06343 | 0.00852 | 0.06368 | 6641 |
| bert.encoder.layer.0.output.LayerNorm | 16 | 0.00395 | 0.0005192 | 0.004164 | 1.701e+06 |
| bert.encoder.layer.0.output.LayerNorm | 22 | 8.379e-05 | 1.531e-05 | 8.666e-05 | 6.968e+09 |
| bert.encoder.layer.1.attention.output.LayerNorm | 8 | 0.3799 | 0.05057 | 0.3821 | 111 |
| bert.encoder.layer.1.attention.output.LayerNorm | 12 | 0.0217 | 0.003257 | 0.02159 | 2.897e+04 |
| bert.encoder.layer.1.attention.output.LayerNorm | 16 | 0.00139 | 0.0001956 | 0.00153 | 7.421e+06 |
| bert.encoder.layer.1.attention.output.LayerNorm | 22 | 4.691e-05 | 1.63e-05 | 5.992e-05 | 3.04e+10 |
| bert.encoder.layer.1.output.LayerNorm | 8 | 0.2048 | 0.0331 | 0.229 | 377 |
| bert.encoder.layer.1.output.LayerNorm | 12 | 0.01393 | 0.002002 | 0.01314 | 9.751e+04 |
| bert.encoder.layer.1.output.LayerNorm | 16 | 0.0008345 | 0.0001186 | 0.0007795 | 2.499e+07 |
| bert.encoder.layer.1.output.LayerNorm | 22 | 3.83e-05 | 1.673e-05 | 5.126e-05 | 1.023e+11 |

Newton karekökü sabit yineleme sayısı: monoton güncelleme (x yalnızca küçülürse) ile floor(sqrt) tam çıkana kadar; rastgele girdi taslağında 4 bulunmuştu (ibert_hata_analizi.py).