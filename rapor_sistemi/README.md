# Tasarım raporu sistemi (BIL 401)

Her RTL tasarım adımı bittiğinde bir Word raporu üretilir (TRnn). Kural:
1. Makale yalnızca 2021 sonrası (son 5 yıl) olabilir.
2. Alıntı `literatur_kutuphanesi.json`'a, makale metninden **iki bağımsız çekimle** doğrulandıktan sonra eklenir. Rapor alıntıyı yalnızca kimliğiyle çağırır; kütüphanede olmayan kimlik hata verir.
3. Rapor sırası: kaynak, bölüm, tırnak içinde alıntı → "Bizde uygulama" → "Fark/dikkat". Uyumsuzluklar ve doğrulanmamış iddialar açıkça yazılır.
4. Sayılar ilgili log/json dosyasından alınır; ölçülmemiş değer "tahmin" etiketiyle gider.
5. **Görsel ağırlıklı:** her rapor en az 3 şekil içerir (üretici bunu zorlar); şekiller `sekiller/trnn_sekiller.py` ile gerçek veriden üretilir, başlık + "nasıl okunur" açıklaması taşır, metinde atıf yapılır. `tr01_sekiller.py` şablondur.

Üretmek için: `python rapor_uretici.py tasarim_raporlari/TRnn_....json` (python-docx gerekir).

## Planlanan raporlar ve hazır literatür eşlemesi
| Rapor | Konu | Hazır alıntılar | Boşluk |
|---|---|---|---|
| TR01 | PE + çıkış-sabit 4×4 dizi (**üretildi**) | DF-01/02, SW-01, KV-03, SN-03 | Skew için 2021+ kaynak |
| TR02 | PE'nin 9 bit işaretli A girişi (UINT8 olasılık) | – | **Kaynak bulunamadı**; Python testiyle gerekçelendirilecek |
| TR03 | Parametrik 8×8 dizi + akışlı arayüz | KV-02, KV-03, SN-01 | – |
| TR04 | Tile denetleyici, host'tan panel akıtma | TL-01, TL-02, KV-01, SN-01 | Host (PC)–FPGA ağırlık akıtma için kaynak |
| TR05 | Yeniden ölçekleme (M0, kaydırma) | SW-03, IV-01, IO-01, IO-02 | – |
| TR06 | Tek doğrusal katman uçtan uca | SW-01, KV-04 | – |
| TR07 | GELU LUT | SN-02, QK-02 | GELU LUT için doğrudan kaynak |
| TR08 | Host↔FPGA arabirimi (UART, protokol) | – | **Kaynak bulunamadı** |
| TR09 | Softmax | SW-04, IV-02, IO-03, IO-04 | – |
| TR10 | LayerNorm / tamsayı karekök | SW-05, IV-03, QK-01 | – |
| TR11 | Sentez ve kaynak kullanımı | SN-03, QK-03 | – |
