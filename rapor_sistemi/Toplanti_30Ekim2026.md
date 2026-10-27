# Toplantı notu — 30 Ekim 2026 (BIL 401, 5–6 ekran)

**1. Ne bitti (hepsi benzetim, kart yok)**
- Tam tamsayı hat 718/872 (FP32 719; kayıp 0,11 puan; hedef ≥711 sağlandı). Farklar ±1–2 cümle: gürültü.
- RTL: parametrik PE (9 bit A), 8×8 akışlı dizi, tile denetleyici, yeniden ölçekleme, GELU LUT, UART+komut çözücü.

**2. Bit-birebir kanıt**
- 12 doğrusal katman (L0+L1) 4 cümlede altın çıktıyla 0 hata; dikkat çekirdeği (Q·Kᵀ, P·V) 8 koşu 0 hata.
- PC→FPGA→PC döngüsü: 6 L0 katmanı, 602 paket, 0 fark; bozuk CRC → HATA döndü.

**3. Sentez (Vivado post-synth, yerleştirme yok)**
- 10 110 LUT (%48,6), 6 451 FF, 15 BRAM, **4 DSP** (tahmin ≈72 idi: PE çarpıcıları LUT'a eşlendi).
- 100 MHz'de WNS −0,456 ns (kaba) → frekans düşürme / DSP'ye zorlama gerekli.

**4. Dürüst performans**
- Hesap ms düzeyi; ama ağırlıklar UART'tan her çıkarımda akar: ≈420 KB → ≈4,6 sn @921 600 baud (hesap). CPU 2,49 ms. **Hız kazancı beklenmiyor.**

**5. Açık maddeler**
- G3 (512 cümle × 3 tohum) yapılmadı; G11 (Softmax/LayerNorm RTL) yapılmadı; pooler/classifier RTL'de doğrulanmadı; zincirli akış yok.
- Literatür: 9 bit A ve PC–FPGA UART için 2021 sonrası kaynak bulunamadı; alıntılar PDF'te gözle doğrulanmalı.

**6. Danışmandan istenen kararlar**
- Softmax/LayerNorm host'ta kalsın mı, G11 kapsama alınsın mı?
- LayerNorm 12 vs 16 bit (sentez verisi LN RTL olmadığından yok).
- Ağırlığı kartta kalıcı saklama (UART trafiğini kaldırmak) araştırılsın mı?

*FPGA/kart soruları (Basys3+Vivado erişimi, bitstream, USB-UART, DSP çıkarımı, 100 MHz kapanışı) danışmana değil FPGA'dan anlayan hocaya.*
