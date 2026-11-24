# Mimari Notu P1 — Komutsuz akış arabirimi, denetim kodu ve çizelge sıralayıcı (prototip)

Tarih: 6 Kasım 2026 · Kapsam: ara rapordan önce gerçekleştirilen ilk komutsuz prototip. Kararların kaynağı: `raporlar/ara_rapor/Tasarim_Kararlari_Arastirma_Raporu.docx` (Karar 3, 4, 5, 6).

## 1. Amaç ve ölçülen sorun
Mevcut sistemde her ağırlık paneli bir komut paketiyle gelir (komut kodu, uzunluk, yük, sağlama, onay yanıtı); komut çözücü ve kontrol birimi bu paketlere göre çalışır. Modelin işlem sırası sabit olduğundan bu bilgi devrede sabit bir tabloda durabilir. Prototip, aynı doğrusal katman hesap birimlerini (`dogrusal_katman`: sistolik dizi, yeniden ölçekleme, bellekler — değiştirilmedi) komutsuz bir akışla sürmenin mümkün olduğunu ve bit düzeyinde aynı sonucu verdiğini gösterir.

## 2. Çözüm
- **`akis_ayristirici`**: yalnız veri baytı alır. Blok, çizelgenin önceden bildirdiği uzunlukta veri baytı ve ardından 2 bayt CRC-16 (CCITT, 0x1021, başlangıç 0xFFFF, yüksek bayt önce) içerir. Baytlar küçük-uçlu 64 bit (veri) ya da 32 bit (bias, ölçek çarpanı M0) sözcüklere birleştirilip doğrudan ilgili belleğe yazılır. Blok sonunda CRC uyuşmazsa `blok_hatali` verilir.
- **`cizelge_siralayici`**: komutların yerini alan sabit tablo (3 satır: katman 0 Q, K, V; her satır K=128, 16 panel, kaydırma 37) ve durum makinesi. Sıra: aktivasyon bloğu → iki panel (iki tampon) → hesap başlat → tampon boşaldıkça sıradaki paneli iste (yükleme ile hesap örtüşür) → satır bitti → sonraki satır → cümle sonunda yeni aktivasyon bloğu. CRC hatasında `hata` kilitlenir, çizelge durur; hatalı panel tüketilmez (`panel_hazir` yükselmez).
- **`komutsuz_ust`**: üçünü ve mevcut `dogrusal_katman`'ı bağlar. Dışarıya yalnız bayt girişi (geçerli/hazır), hata ve prototipe özgü gözlem kancası (`satir_bitti`/`devam`, çıkış okuma) çıkar.

Bayt akışı kaynağı arabirimin arkasında değiştirilebilir (seri hat ya da flaş okuyucu); aynı `bayt_geçerli/bayt_hazır` el sıkışması kullanılır.

## 3. Akış biçimi (cümle başına)
| Parça | Bayt |
|---|---|
| Aktivasyon bloğu (1024 sözcük × 8) + CRC | 8 192 + 2 |
| Her satır için 16 panel: 128×8 ağırlık + 8×4 bias + 8×4 M0 + CRC | 1 088 + 2 |
| Toplam (3 satır) | 8 194 + 3×16×1 090 = 60 514 |

Başlık, komut kodu ya da uzunluk alanı yoktur; ne geleceğini çizelge ve sayaçlar bilir.

## 4. Doğrulama
- Akış, altın modelin test vektörlerinden **Python'da** üretilir ve CRC'si Python'un kendi uygulamasıyla (`binascii.crc_hqx`) hesaplanır; devredeki CRC ayrı yazılmıştır, böylece iki uygulama birbirini sınar.
- Her satır bitince çıkış belleği altın modelin `l0_q/k/v_cikis.mem` dosyasıyla bit bit karşılaştırılır.
- Hata enjeksiyonu: bir panele tek bit hatası eklenir; beklenen: `hata`=1, çizelge durur.
- Hız: bayt başına 1 çevrim (tam hız) ve 8 çevrim (kart flaşının dört hatlı 25 MHz okuması için gerçekçi hız).

## 5. Kapsam dışı (bu prototipte yok)
Softmax/LayerNorm/GELU zinciri, 14 katmanın tamamı, çip içi zincirleme, dolgu atlama, gerçek flaş okuyucu (SPI), UART, kart. Bunlar sonraki aşamalardır.
