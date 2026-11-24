// BERT-Tiny hizlandirici - altin modelden uretilmistir. ELLE DEGISTIRMEYIN.
// Kaynak: 03-RTL_Altin_Model/01_Kod/00_parametre_cikar.py

localparam integer GIZLI_BOYUT      = 128;
localparam integer ARA_BOYUT        = 512;
localparam integer BASLIK_SAYISI    = 2;
localparam integer BASLIK_BOYU      = 64;
localparam integer KATMAN_SAYISI    = 2;
localparam integer DIZI_UZUNLUGU    = 64;
localparam integer AKTIVASYON_BIT   = 8;
localparam integer AGIRLIK_BIT      = 8;
localparam integer BIRIKEC_BIT      = 32;
localparam integer BIAS_BIT         = 32;
localparam integer M0_BIT           = 31;
localparam integer PE_SATIR         = 8;
localparam integer PE_SUTUN         = 8;
localparam integer K_DILIM          = 64;
localparam integer GELU_LUT_BOYU    = 256;

// Katman basina kaydirma miktarlari
localparam integer KAYDIRMA_L0_Q           = 37;
localparam integer KAYDIRMA_L0_K           = 37;
localparam integer KAYDIRMA_L0_V           = 37;
localparam integer KAYDIRMA_L0_ATTN_OUT    = 38;
localparam integer KAYDIRMA_L0_FFN1        = 37;
localparam integer KAYDIRMA_L0_FFN2        = 37;
localparam integer KAYDIRMA_L1_Q           = 38;
localparam integer KAYDIRMA_L1_K           = 38;
localparam integer KAYDIRMA_L1_V           = 38;
localparam integer KAYDIRMA_L1_ATTN_OUT    = 37;
localparam integer KAYDIRMA_L1_FFN1        = 38;
localparam integer KAYDIRMA_L1_FFN2        = 36;
localparam integer KAYDIRMA_POOLER         = 38;
localparam integer KAYDIRMA_CLASSIFIER     = 42;
