# Test vektörü düzeni (OKUBENI)

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
