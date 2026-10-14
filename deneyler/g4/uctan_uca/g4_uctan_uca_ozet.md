# G4 — Tamsayı nonlineerlikler, SST-2 uçtan uca doğruluk (otomatik özet)

FP32 referansı 719/872 (%82,45). Hedef: ≤1 puan (≤8 cümle), üst sınır ≤2 puan (≤17 cümle), MLPerf ≥712. Üç değer = kalibrasyon seed'leri 42/43/44.

| Koşu | Doğru (Linear INT8) | Kayıp cümle | Min uyuşma | Hedef | MLPerf | Doğru (Linear FP32) | Kayıp cümle (FP32 Linear) |
|---|---|---|---|---|---|---|---|
| Tamsayı yok (FP32 nonlineer) | 719/717/720 | +0/+2/-1 | %99.54 | evet | evet | 719/719/719 | +0/+0/+0 |
| ÖNERİ: GELU 12 · Softmax 12→16 · LN 16 | 717/718/720 | +2/+1/-1 | %99.66 | evet | evet | 719/719/719 | +0/+0/+0 |
| Geniş: GELU 16 · Softmax 16→16 · LN 22 | 715/717/719 | +4/+2/+0 | %99.54 | evet | evet | 719/719/719 | +0/+0/+0 |
| GELU 12 · Softmax 12→16 · LN 12 | 716/719/718 | +3/+0/+1 | %99.66 | evet | evet | 719/719/719 | +0/+0/+0 |
| Hepsi 8 bit (Softmax çıkış 8) | 698/699/694 | +21/+20/+25 | %96.22 | HAYIR | HAYIR | 702/700/695 | +17/+19/+24 |
| Yalnız GELU 12 | 718/718/720 | +1/+1/-1 | %99.66 | evet | evet | 719/719/719 | +0/+0/+0 |
| Yalnız GELU 8 | 715/721/720 | +4/-2/-1 | %99.54 | evet | evet | 719/719/719 | +0/+0/+0 |
| Yalnız Softmax 12→16 | 719/720/720 | +0/-1/-1 | %99.66 | evet | evet | 719/719/719 | +0/+0/+0 |
| Yalnız Softmax 8→16 | 719/718/716 | +0/+1/+3 | %99.66 | evet | evet | 720/719/721 | -1/+0/-2 |
| Yalnız Softmax 12→8 | 711/714/709 | +8/+5/+10 | %98.62 | HAYIR | HAYIR | 712/712/713 | +7/+7/+6 |
| Yalnız LN 16 | 717/720/718 | +2/-1/+1 | %99.43 | evet | evet | 719/719/719 | +0/+0/+0 |
| Yalnız LN 12 | 718/718/717 | +1/+1/+2 | %99.66 | evet | evet | 719/719/719 | +0/+0/+0 |
| Yalnız LN 8 | 706/704/704 | +13/+15/+15 | %97.36 | HAYIR | HAYIR | 702/703/705 | +17/+16/+14 |
