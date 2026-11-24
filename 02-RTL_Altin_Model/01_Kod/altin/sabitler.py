"""Donanım sabitleri ve model geometrisi.

Bu dosya altın modelin "parametre paketi"dir: RTL'de `localparam` olarak
yazacağın her sayı burada tek bir yerde durur. Python tarafında bir değeri
değiştirip doğruluğun nasıl etkilendiğini ölçebilir, sonra aynı değeri
Verilog'a taşıyabilirsin.

Not: buradaki bit genişlikleri BERT-Tiny + SST-2 için seçilmiştir ve
`03_Sonuclar/tasima_raporu.md` içindeki taşma (overflow) kontrolleriyle
doğrulanır. Değiştirirsen testleri yeniden koş.
"""

from __future__ import annotations

# ----------------------------------------------------------------------------
# Model geometrisi (config.json ile birebir aynı olmalı)
# ----------------------------------------------------------------------------
GIZLI_BOYUT = 128          # hidden_size
ARA_BOYUT = 512            # intermediate_size (FFN genişliği)
BASLIK_SAYISI = 2          # num_attention_heads
BASLIK_BOYU = GIZLI_BOYUT // BASLIK_SAYISI   # 64
KATMAN_SAYISI = 2          # num_hidden_layers
SOZLUK_BOYUTU = 30522      # vocab_size
TIP_SAYISI = 2             # type_vocab_size
MAKS_KONUM = 512           # max_position_embeddings
SINIF_SAYISI = 2           # SST-2: olumsuz / olumlu
LN_EPS = 1e-12             # layer_norm_eps

# Çalışma zamanı dizi uzunluğu (PTQ ile aynı: --max_len 64, sabit dolgulu)
DIZI_UZUNLUGU = 64

# ----------------------------------------------------------------------------
# Sayı biçimleri (RTL veri yolu genişlikleri)
# ----------------------------------------------------------------------------
AKTIVASYON_BIT = 8         # işaretli: [-128, 127]
AGIRLIK_BIT = 8            # işaretli, simetrik nicemleme: [-127, 127]
BIRIKEC_BIT = 32           # INT32 birikeç (systolic dizinin çıkışı)
BIAS_BIT = 32              # INT32 bias, ölçeği = a_olcek * w_olcek

AKT_MIN, AKT_MAX = -128, 127
AGIRLIK_MIN, AGIRLIK_MAX = -127, 127   # -128 kullanılmıyor (simetrik)
BIRIKEC_MIN, BIRIKEC_MAX = -(2**31), 2**31 - 1

# Yeniden ölçekleme (requantize) sabit noktalı çarpanı: M ~= M0 * 2^-n
# M0_BIT büyüdükçe doğruluk artar, çarpıcı maliyeti artar.
# Basys3'te DSP48E1 25x18 çarpıyor; 18 bit tek DSP'ye, 31 bit iki DSP'ye düşer.
M0_BIT = 31
MAKS_KAYDIRMA = 62         # n için üst sınır (int64 çarpım taşmasın)

# ----------------------------------------------------------------------------
# Systolic dizi geometrisi (İP5'te RTL'e geçecek olan)
# ----------------------------------------------------------------------------
PE_SATIR = 8               # dizinin satır sayısı  (çıkış kanalı yönü)
PE_SUTUN = 8               # dizinin sütun sayısı  (token/batch yönü)
K_DILIM = 64               # bir seferde işlenen iç çarpım uzunluğu

# ----------------------------------------------------------------------------
# Dogrusal olmayan birimlerin sabit noktalı biçimleri
# ----------------------------------------------------------------------------
SOFTMAX_CIKIS_BIT = 8      # olasılıklar işaretsiz 8 bit
SOFTMAX_CIKIS_OLCEK = 1.0 / 255.0   # 0..255 -> 0.0..1.0
GELU_LUT_BOYU = 256        # INT8 girdi -> INT8 çıkış, tam kapsama
TANH_LUT_BOYU = 256

# ----------------------------------------------------------------------------
# Nicemlenen Linear katmanlarının RTL'deki adları (sıra = veri akışı sırası)
# ----------------------------------------------------------------------------
LINEAR_KATMANLAR = [
    "bert.encoder.layer.0.attention.self.query",
    "bert.encoder.layer.0.attention.self.key",
    "bert.encoder.layer.0.attention.self.value",
    "bert.encoder.layer.0.attention.output.dense",
    "bert.encoder.layer.0.intermediate.dense",
    "bert.encoder.layer.0.output.dense",
    "bert.encoder.layer.1.attention.self.query",
    "bert.encoder.layer.1.attention.self.key",
    "bert.encoder.layer.1.attention.self.value",
    "bert.encoder.layer.1.attention.output.dense",
    "bert.encoder.layer.1.intermediate.dense",
    "bert.encoder.layer.1.output.dense",
    "bert.pooler.dense",
    "classifier",
]

# RTL'de bellek dosyası adı olarak kullanılacak kısa karşılıklar
KISA_AD = {
    "bert.encoder.layer.0.attention.self.query": "l0_q",
    "bert.encoder.layer.0.attention.self.key": "l0_k",
    "bert.encoder.layer.0.attention.self.value": "l0_v",
    "bert.encoder.layer.0.attention.output.dense": "l0_attn_out",
    "bert.encoder.layer.0.intermediate.dense": "l0_ffn1",
    "bert.encoder.layer.0.output.dense": "l0_ffn2",
    "bert.encoder.layer.1.attention.self.query": "l1_q",
    "bert.encoder.layer.1.attention.self.key": "l1_k",
    "bert.encoder.layer.1.attention.self.value": "l1_v",
    "bert.encoder.layer.1.attention.output.dense": "l1_attn_out",
    "bert.encoder.layer.1.intermediate.dense": "l1_ffn1",
    "bert.encoder.layer.1.output.dense": "l1_ffn2",
    "bert.pooler.dense": "pooler",
    "classifier": "classifier",
}

# PTQ katman adı -> altın modelin ara tensör izleme öneki (model.py `izle` anahtarı)
IZLE_ADI = {
    "bert.encoder.layer.0.attention.self.query": "l0.q",
    "bert.encoder.layer.0.attention.self.key": "l0.k",
    "bert.encoder.layer.0.attention.self.value": "l0.v",
    "bert.encoder.layer.0.attention.output.dense": "l0.attn_out",
    "bert.encoder.layer.0.intermediate.dense": "l0.ffn1",
    "bert.encoder.layer.0.output.dense": "l0.ffn2",
    "bert.encoder.layer.1.attention.self.query": "l1.q",
    "bert.encoder.layer.1.attention.self.key": "l1.k",
    "bert.encoder.layer.1.attention.self.value": "l1.v",
    "bert.encoder.layer.1.attention.output.dense": "l1.attn_out",
    "bert.encoder.layer.1.intermediate.dense": "l1.ffn1",
    "bert.encoder.layer.1.output.dense": "l1.ffn2",
    "bert.pooler.dense": "pooler",
    "classifier": "classifier",
}
