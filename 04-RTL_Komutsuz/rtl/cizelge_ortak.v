// -----------------------------------------------------------------------------
// cizelge_ortak.v -- komutsuz cizelge: ortak cekirdegi katman katman, satir satir surer (disaridan komut yok)
//
// Her katman 14 satirdir; satirin ne yapacagi (is turu, bellek tabanlari, panel sayisi, olcek sabitleri) devrede sabit tabloda durur:
//    0 Q baş 0     1 Q baş 1     2 K baş 0     3 K baş 1     4 V (devrik)
//    5 Q.K^T+Softmax baş 0   6 P.V baş 0   7 Q.K^T+Softmax baş 1   8 P.V baş 1
//    9 dikkat cikis dogrusali   10 artik+LayerNorm 1 (ham cikis ayrica saklanir)
//   11 ileri besleme 1 (GELU ve ileri besleme 2 olcegi tek tabloda)   12 ileri besleme 2   13 artik+LayerNorm 2
// Bellek yerlesimi (1024 sozcuklu birimler; adres = birim*1024): 0 katman girdisi/cikisi, 1 Q (iki baş) ve dikkat cikisi, 2 K, 3 V (devrik),
//   4 olasiliklar (tek baş), 5 baglam ve LayerNorm 1 ham cikisi; ileri besleme 1 cikisi birimler 1-4'e yazilir.
// Veri akisi: cumle basinda aktivasyon blogu, sonra satirlara gore sirayla agirlik panelleri (blok = panel + 16 bit denetim kodu). Akis
// ayristirici blogu dogruladikca satir paneli param yukleyiciden gecirip (bias, olcek carpani gomulu bellekten) iki tampondan birine alir.
// Gozlem: `gozlem` 1 ise her satir sonunda `devam` beklenir (bellek disaridan okunabilir); 0 ise cizelge kesintisiz akar.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module cizelge_ortak #(
    parameter KATMAN_ISLEM = 1,
    parameter SINIFLANDIR  = 1,                   // 1: son katmandan sonra pooler (tanh) ve siniflandirici satirlari + karar
    parameter DOLGU_ATLA   = 1,                   // 1: token blogu sayisi nb = ceil(cumle_uzunluk/8) (dolgu bloklari hesaplanmaz); 0: her zaman 8 blok (eski davranis)
    parameter NA           = 1                    // paralel dogrusal dizi (lane) sayisi: 1, 2, 4 ya da 8; dogrusal satirda NA panel ayni anda hesaplanir
) (
    input  wire         clk,
    input  wire         rst,
    // akis ayristirici
    output reg          blok_basla,
    output reg          blok_tur,
    output reg          blok_tampon,
    output wire [10:0]  blok_k,
    input  wire         blok_tamam,
    input  wire         blok_hatali,
    input  wire [6:0]   cumle_uzunluk,
    // ortak cekirdek
    output reg          basla,
    output reg  [2:0]   is_tipi,
    output reg  [12:0]  taban_giris,
    output reg  [12:0]  taban_ikinci,
    output reg  [12:0]  taban_cikis,
    output reg  [10:0]  ayar_k,
    output reg  [6:0]   ayar_panel_sayisi,
    output reg  [15:0]  agirlik_adres,           // agirlik ROM'u (yonga ici): bu panel grubunun banka ici sozcuk adresi (blok_basla ile birlikte gecerli)
    output reg  [5:0]   ayar_kaydirma,
    output reg          gelu_etkin,
    output reg  [3:0]   ayar_blok_sayisi,
    output reg          devrik_yaz,
    output reg  [30:0]  ayar_m0,
    output reg  [23:0]  ayar_m0_sm,
    output wire [6:0]   uzunluk,
    output reg  [6:0]   cikis_panel_ofset,
    output reg  [9:0]   baglam_kanal,
    output reg  [1:0]   ln_no,
    output reg          ln_y_yaz,
    output reg  [12:0]  ln_taban_y,
    input  wire         bitti,
    output reg          param_basla,
    output reg  [11:0]  param_taban,
    output reg          param_tampon,
    input  wire         param_bitti,
    output reg          tablo_basla,
    output reg  [2:0]   tablo_sec,
    input  wire         tablo_bitti,
    output reg  [1:0]   panel_hazir,
    input  wire         panel_bitti,
    input  wire         panel_bitti_tampon,
    // gozlem ve durum
    input  wire         gozlem,
    output wire         satir_bitti,
    input  wire         devam,
    output reg          hata,
    output reg  [3:0]   satir_no,
    output reg  [3:0]   katman_no,
    output reg  [15:0]  cumle_no,
    output reg          cumle_bitti,
    // siniflandirma sonucu (dahili bellek okuma kapisi ile)
    output reg          ic_oku,
    output reg  [12:0]  ic_oku_adres,
    input  wire [63:0]  oku_veri_ic,
    output reg          sinif,
    output reg          sonuc_gecerli,
    output reg signed [7:0] logit0,
    output reg signed [7:0] logit1
);
    // >>> parametre_harita basla
// parametre_harita.vh -- uret_parametre_rom.py tarafindan uretildi; elle duzenlemeyin
localparam PARAMETRE_SAYISI = 2440;
localparam KATMAN_SAYISI = 14;
function [11:0] katman_taban; input integer i; begin case (i)
        0: katman_taban = 12'd0;
        1: katman_taban = 12'd128;
        2: katman_taban = 12'd256;
        3: katman_taban = 12'd384;
        4: katman_taban = 12'd512;
        5: katman_taban = 12'd1024;
        6: katman_taban = 12'd1152;
        7: katman_taban = 12'd1280;
        8: katman_taban = 12'd1408;
        9: katman_taban = 12'd1536;
        10: katman_taban = 12'd1664;
        11: katman_taban = 12'd2176;
        12: katman_taban = 12'd2304;
        13: katman_taban = 12'd2432;
        default: katman_taban = 12'd0; endcase end endfunction
function [10:0] katman_k; input integer i; begin case (i)
        0: katman_k = 11'd128;
        1: katman_k = 11'd128;
        2: katman_k = 11'd128;
        3: katman_k = 11'd128;
        4: katman_k = 11'd128;
        5: katman_k = 11'd512;
        6: katman_k = 11'd128;
        7: katman_k = 11'd128;
        8: katman_k = 11'd128;
        9: katman_k = 11'd128;
        10: katman_k = 11'd128;
        11: katman_k = 11'd512;
        12: katman_k = 11'd128;
        13: katman_k = 11'd128;
        default: katman_k = 11'd0; endcase end endfunction
function [9:0] katman_c; input integer i; begin case (i)
        0: katman_c = 10'd128;
        1: katman_c = 10'd128;
        2: katman_c = 10'd128;
        3: katman_c = 10'd128;
        4: katman_c = 10'd512;
        5: katman_c = 10'd128;
        6: katman_c = 10'd128;
        7: katman_c = 10'd128;
        8: katman_c = 10'd128;
        9: katman_c = 10'd128;
        10: katman_c = 10'd512;
        11: katman_c = 10'd128;
        12: katman_c = 10'd128;
        13: katman_c = 10'd2;
        default: katman_c = 10'd0; endcase end endfunction
function [5:0] katman_kaydirma; input integer i; begin case (i)
        0: katman_kaydirma = 6'd37;
        1: katman_kaydirma = 6'd37;
        2: katman_kaydirma = 6'd37;
        3: katman_kaydirma = 6'd38;
        4: katman_kaydirma = 6'd37;
        5: katman_kaydirma = 6'd37;
        6: katman_kaydirma = 6'd38;
        7: katman_kaydirma = 6'd38;
        8: katman_kaydirma = 6'd38;
        9: katman_kaydirma = 6'd37;
        10: katman_kaydirma = 6'd38;
        11: katman_kaydirma = 6'd36;
        12: katman_kaydirma = 6'd38;
        13: katman_kaydirma = 6'd42;
        default: katman_kaydirma = 6'd0; endcase end endfunction
function [1:0] katman_gelu; input integer i; begin case (i)
        0: katman_gelu = 2'd0;
        1: katman_gelu = 2'd0;
        2: katman_gelu = 2'd0;
        3: katman_gelu = 2'd0;
        4: katman_gelu = 2'd1;
        5: katman_gelu = 2'd0;
        6: katman_gelu = 2'd0;
        7: katman_gelu = 2'd0;
        8: katman_gelu = 2'd0;
        9: katman_gelu = 2'd0;
        10: katman_gelu = 2'd2;
        11: katman_gelu = 2'd0;
        12: katman_gelu = 2'd3;
        13: katman_gelu = 2'd0;
        default: katman_gelu = 2'd0; endcase end endfunction
function [8*16-1:0] katman_ad; input integer i; begin case (i)
        0: katman_ad = "l0_q";
        1: katman_ad = "l0_k";
        2: katman_ad = "l0_v";
        3: katman_ad = "l0_attn_out";
        4: katman_ad = "l0_ffn1";
        5: katman_ad = "l0_ffn2";
        6: katman_ad = "l1_q";
        7: katman_ad = "l1_k";
        8: katman_ad = "l1_v";
        9: katman_ad = "l1_attn_out";
        10: katman_ad = "l1_ffn1";
        11: katman_ad = "l1_ffn2";
        12: katman_ad = "pooler";
        13: katman_ad = "classifier";
        default: katman_ad = "yok"; endcase end endfunction
    // <<< parametre_harita bitti

    localparam SATIR_SAYISI = 14;
    localparam LOG2NA = (NA == 1) ? 0 : (NA == 2) ? 1 : (NA == 4) ? 2 : 3;
    // agirlik ROM'unda (NA banka) satirlarin banka ici taban adresi: satir r, NA'ya yuvarlanmis ceil(C/8/NA) grup x K sozcuk
    function [15:0] rom_taban; input integer i; integer r; integer s; begin
        s = 0;
        for (r = 0; r < 14; r = r + 1) if (r < i) s = s + ((((katman_c(r) + 7) >> 3) + NA - 1) >> LOG2NA) * katman_k(r);
        rom_taban = s;
    end endfunction

    // ---------------- sabit tablo ----------------
    // satir turu: 0 dogrusal, 1 Q.K^T, 2 P.V, 3 LayerNorm
    function [1:0] s_tur; input [3:0] i; begin
        case (i)
            4'd5, 4'd7:  s_tur = 2'd1;
            4'd6, 4'd8:  s_tur = 2'd2;
            4'd10, 4'd13: s_tur = 2'd3;
            default:     s_tur = 2'd0;
        endcase end endfunction
    // dogrusal satirin katman_tablosundaki sirasi (0 q, 1 k, 2 v, 3 cikis, 4 ileri besleme 1, 5 ileri besleme 2)
    function [2:0] s_kat; input [3:0] i; begin
        case (i) 4'd0, 4'd1: s_kat = 3'd0; 4'd2, 4'd3: s_kat = 3'd1; 4'd4: s_kat = 3'd2; 4'd9: s_kat = 3'd3; 4'd11: s_kat = 3'd4; default: s_kat = 3'd5; endcase end endfunction
    function [6:0] s_panel; input [3:0] i; begin
        case (i) 4'd0, 4'd1, 4'd2, 4'd3: s_panel = 7'd8; 4'd11: s_panel = 7'd64; 4'd15: s_panel = 7'd1; default: s_panel = 7'd16; endcase end endfunction
    function [6:0] s_pofs; input [3:0] i; begin      // paneller katmanin ayni agirlik matrisinin ikinci yarisindan basliyorsa kayma
        s_pofs = (i == 4'd1 || i == 4'd3) ? 7'd8 : 7'd0; end endfunction
    function [12:0] s_tg; input [3:0] i; begin
        case (i)
            4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd11, 4'd14: s_tg = 13'd0;
            4'd15: s_tg = 13'd1024;
            4'd5: s_tg = 13'd1024;  4'd7: s_tg = 13'd1536;
            4'd6, 4'd8: s_tg = 13'd4096;
            4'd9: s_tg = 13'd5120;
            4'd10: s_tg = 13'd0;
            4'd12: s_tg = 13'd1024;
            default: s_tg = 13'd5120;                      // 13: LayerNorm 2 x = ham cikis
        endcase end endfunction
    function [12:0] s_ti; input [3:0] i; begin
        case (i)
            4'd5: s_ti = 13'd2048;  4'd7: s_ti = 13'd2560;
            4'd6: s_ti = 13'd3072;  4'd8: s_ti = 13'd3584;
            4'd10: s_ti = 13'd1024;
            4'd13: s_ti = 13'd0;
            default: s_ti = 13'd0;
        endcase end endfunction
    function [12:0] s_tc; input [3:0] i; begin
        case (i)
            4'd0: s_tc = 13'd1024; 4'd1: s_tc = 13'd1536;
            4'd2: s_tc = 13'd2048; 4'd3: s_tc = 13'd2560;
            4'd4: s_tc = 13'd3072;
            4'd5, 4'd7: s_tc = 13'd4096;
            4'd6, 4'd8: s_tc = 13'd5120;
            4'd9: s_tc = 13'd1024;
            4'd10: s_tc = 13'd0;
            4'd11: s_tc = 13'd1024;
            4'd14: s_tc = 13'd1024;
            4'd15: s_tc = 13'd2048;
            default: s_tc = 13'd0;                         // 12, 13
        endcase end endfunction

    // dikkat sabitleri (altin model; katman basina): Q.K^T carpani/kaydirmasi, Softmax carpani, P.V carpani/kaydirmasi
    function [30:0] qk_m0; input integer l; begin qk_m0 = (l == 0) ? 31'h2e7d9a97 : 31'h3a3d6761; end endfunction
    function [5:0]  qk_n;  input integer l; begin qk_n  = 6'd34; end endfunction
    function [23:0] sm_m0; input integer l; begin sm_m0 = (l == 0) ? 24'h0040d9 : 24'h0058f9; end endfunction
    function [30:0] pv_m0; input integer l; begin pv_m0 = (l == 0) ? 31'h32e2aee4 : 31'h2f9a919c; end endfunction
    function [5:0]  pv_n;  input integer l; begin pv_n  = 6'd37; end endfunction

    wire [3:0]  sn   = satir_no;
    // dolgu atlama: cumlenin gercek uzunlugundan (akis ayristirici, aktivasyon blogu dogrulaninca) blok sayisi; gecersiz uzunluk (0 ya da > 64) = 8 blok
    wire [7:0]  uz_toplam = {1'b0, cumle_uzunluk} + 8'd7;
    wire [3:0]  nb_w = (DOLGU_ATLA == 0 || cumle_uzunluk == 7'd0 || cumle_uzunluk > 7'd64) ? 4'd8 : uz_toplam[6:3];
    wire [1:0]  tur  = s_tur(sn);
    wire [2:0]  kat  = s_kat(sn);
    wire [6:0]  npan = s_panel(sn);
    wire [6:0]  npg  = (npan + NA - 1) >> LOG2NA;                 // panel GRUBU sayisi (NA panel birlikte); NA=1 iken npan
    integer     kidx;                                      // katman_tablosundaki genel sira
    always @* kidx = (sn >= 4'd14) ? (sn - 2) : (katman_no * 6 + kat);     // 14, 15: pooler ve siniflandirici (genel sira 12, 13)
    assign blok_k = katman_k(kidx);
    assign uzunluk = cumle_uzunluk;

    // ---------------- durum makinesi ----------------
    localparam S_AKT = 4'd0, S_AKT_BEKLE = 4'd1, S_SATIR = 4'd2, S_TABLO = 4'd3, S_TABLO_BEKLE = 4'd4, S_DOGRUSAL = 4'd5, S_IS = 4'd6,
               S_BEKLE = 4'd7, S_SON = 4'd8, S_GOZLEM = 4'd9, S_HATA = 4'd10, S_GECIKME = 4'd11, S_SIN0 = 4'd12, S_SIN1 = 4'd13, S_SIN2 = 4'd14, S_SIN3 = 4'd15;
    localparam F_BOS = 2'd0, F_BLOK = 2'd1, F_PARAM = 2'd2;
    reg [3:0]  durum;
    reg [1:0]  fdurum;
    reg [6:0]  yuklenen;                   // yuklenmesi baslatilan panel sayisi
    reg [6:0]  alinan;                     // tamponlara yerlesen panel sayisi
    reg [1:0]  bos;
    reg        fetch_tampon;
    reg [6:0]  fetch_idx;
    reg        basladi;
    reg [3:0]  gecikme;
    reg [1:0]  ph_sonraki;

    assign satir_bitti = (durum == S_GOZLEM);

    wire [1:0] ln_numarasi = {katman_no[0], sn == 4'd13};      // katman*2 + (0: LayerNorm 1, 1: LayerNorm 2)

    always @(posedge clk) begin
        blok_basla <= 1'b0; basla <= 1'b0; param_basla <= 1'b0; tablo_basla <= 1'b0; cumle_bitti <= 1'b0; sonuc_gecerli <= 1'b0;
        if (rst) begin
            durum <= S_AKT; fdurum <= F_BOS; panel_hazir <= 2'b00; bos <= 2'b11; yuklenen <= 0; alinan <= 0; basladi <= 1'b0;
            hata <= 1'b0; ic_oku <= 1'b0; ic_oku_adres <= 13'd0; sinif <= 1'b0; logit0 <= 8'sd0; logit1 <= 8'sd0; ayar_blok_sayisi <= 4'd0; satir_no <= 4'd0; katman_no <= 4'd0; cumle_no <= 16'd0; blok_tur <= 1'b0; blok_tampon <= 1'b0; gecikme <= 4'd0;
        end else begin
            // panel_hazir / bos bayraklari (dogrusal satirda)
            ph_sonraki = panel_hazir;
            if (panel_bitti) begin ph_sonraki[panel_bitti_tampon] = 1'b0; bos[panel_bitti_tampon] <= 1'b1; end
            if (fdurum == F_PARAM && param_bitti) begin ph_sonraki[fetch_tampon] = 1'b1; alinan <= alinan + 7'd1; end
            panel_hazir <= ph_sonraki;

            if (blok_hatali) begin hata <= 1'b1; durum <= S_HATA; end
            else case (durum)
                S_AKT:       begin blok_basla <= 1'b1; blok_tur <= 1'b0; durum <= S_AKT_BEKLE; end
                S_AKT_BEKLE: if (blok_tamam) begin durum <= S_SATIR; end
                S_SATIR: begin
                    // satira ozgu ayarlar
                    taban_giris <= s_tg(sn); taban_ikinci <= s_ti(sn); taban_cikis <= s_tc(sn);
                    ayar_blok_sayisi <= nb_w;                       // her satir turu icin nb (pooler / siniflandirici asagida 1'e cekilir)
                    case (tur)
                        2'd0: begin
                            is_tipi <= 3'd0; ayar_k <= katman_k(kidx); ayar_panel_sayisi <= npan; ayar_kaydirma <= katman_kaydirma(kidx);
                            gelu_etkin <= (sn == 4'd11 || sn == 4'd14); devrik_yaz <= (sn == 4'd4); ayar_blok_sayisi <= (sn >= 4'd14) ? 4'd1 : nb_w;
                            bos <= 2'b11; panel_hazir <= 2'b00; yuklenen <= 0; alinan <= 0; basladi <= 1'b0; fdurum <= F_BOS;
                            if (sn == 4'd11 || sn == 4'd14) durum <= S_TABLO; else durum <= S_DOGRUSAL;
                        end
                        2'd1: begin is_tipi <= 3'd1; ayar_m0 <= qk_m0(katman_no); ayar_kaydirma <= qk_n(katman_no); ayar_m0_sm <= sm_m0(katman_no); durum <= S_IS; end
                        2'd2: begin is_tipi <= 3'd2; ayar_m0 <= pv_m0(katman_no); ayar_kaydirma <= pv_n(katman_no);
                                    cikis_panel_ofset <= (sn == 4'd8) ? 7'd8 : 7'd0; baglam_kanal <= 10'd128; durum <= S_IS; end
                        default: begin is_tipi <= 3'd3; ln_no <= ln_numarasi; ln_y_yaz <= (sn == 4'd10); ln_taban_y <= 13'd5120; durum <= S_IS; end
                    endcase
                end
                S_TABLO:       begin tablo_basla <= 1'b1; tablo_sec <= (sn == 4'd14) ? 3'd3 : (3'd4 + {2'b00, katman_no[0]}); durum <= S_TABLO_BEKLE; end
                S_TABLO_BEKLE: if (tablo_bitti) durum <= S_DOGRUSAL;
                S_IS:          begin basla <= 1'b1; durum <= S_BEKLE; end
                S_DOGRUSAL: begin
                    // siradaki paneli serbest tampona al: blok -> param yukleme -> panel_hazir
                    case (fdurum)
                        F_BOS: if (yuklenen < npg && bos[yuklenen[0]]) begin
                            blok_basla <= 1'b1; blok_tur <= 1'b1; blok_tampon <= yuklenen[0];
                            fetch_tampon <= yuklenen[0]; fetch_idx <= yuklenen; bos[yuklenen[0]] <= 1'b0; yuklenen <= yuklenen + 7'd1; fdurum <= F_BLOK;
                            agirlik_adres <= rom_taban(kidx) + ((katman_k(kidx) == 11'd512) ? (({9'd0, (s_pofs(sn) >> LOG2NA)} + {9'd0, yuklenen}) << 9) : (({9'd0, (s_pofs(sn) >> LOG2NA)} + {9'd0, yuklenen}) << 7));
                        end
                        F_BLOK: if (blok_tamam) begin
                            param_basla <= 1'b1; param_tampon <= fetch_tampon;
                            param_taban <= katman_taban(kidx) + {s_pofs(sn) + (fetch_idx << LOG2NA), 3'b000}; fdurum <= F_PARAM;
                        end
                        default: if (param_bitti) fdurum <= F_BOS;
                    endcase
                    // iki panel hazirsa cekirdegi baslat
                    if (!basladi && (ph_sonraki == 2'b11 || (npg == 7'd1 && ph_sonraki[0]))) begin basla <= 1'b1; basladi <= 1'b1; durum <= S_BEKLE; end
                end
                S_BEKLE: begin
                    // dogrusal satirda paneller akmaya devam eder
                    if (tur == 2'd0) begin
                        case (fdurum)
                            F_BOS: if (yuklenen < npg && bos[yuklenen[0]]) begin
                                blok_basla <= 1'b1; blok_tur <= 1'b1; blok_tampon <= yuklenen[0];
                                fetch_tampon <= yuklenen[0]; fetch_idx <= yuklenen; bos[yuklenen[0]] <= 1'b0; yuklenen <= yuklenen + 7'd1; fdurum <= F_BLOK;
                            agirlik_adres <= rom_taban(kidx) + ((katman_k(kidx) == 11'd512) ? (({9'd0, (s_pofs(sn) >> LOG2NA)} + {9'd0, yuklenen}) << 9) : (({9'd0, (s_pofs(sn) >> LOG2NA)} + {9'd0, yuklenen}) << 7));
                            end
                            F_BLOK: if (blok_tamam) begin
                                param_basla <= 1'b1; param_tampon <= fetch_tampon;
                                param_taban <= katman_taban(kidx) + {s_pofs(sn) + (fetch_idx << LOG2NA), 3'b000}; fdurum <= F_PARAM;
                            end
                            default: if (param_bitti) fdurum <= F_BOS;
                        endcase
                    end
                    if (bitti) begin gecikme <= 4'd0; durum <= S_GECIKME; end
                end
                S_GECIKME: begin                                   // cekirdegin bosa dusmesi icin kisa bekleme
                    gecikme <= gecikme + 4'd1;
                    if (gecikme == 4'd4) durum <= gozlem ? S_GOZLEM : S_SON;
                end
                S_GOZLEM: if (devam) durum <= S_SON;
                S_SON: begin
                    if (satir_no == 4'd15) durum <= S_SIN0;                          // siniflandirici satiri bitti: karar
                    else if (satir_no == SATIR_SAYISI-1) begin
                        if (katman_no == KATMAN_ISLEM-1) begin
                            if (SINIFLANDIR != 0) begin satir_no <= 4'd14; durum <= S_SATIR; end    // pooler
                            else begin satir_no <= 4'd0; katman_no <= 4'd0; cumle_no <= cumle_no + 16'd1; cumle_bitti <= 1'b1; durum <= S_AKT; end
                        end else begin satir_no <= 4'd0; katman_no <= katman_no + 4'd1; durum <= S_SATIR; end
                    end else begin satir_no <= satir_no + 4'd1; durum <= S_SATIR; end
                end
                S_SIN0: begin ic_oku <= 1'b1; ic_oku_adres <= 13'd2048; gecikme <= 4'd0; durum <= S_SIN1; end
                S_SIN1: begin gecikme <= gecikme + 4'd1; if (gecikme == 4'd5) begin logit0 <= oku_veri_ic[7:0]; ic_oku_adres <= 13'd2049; gecikme <= 4'd0; durum <= S_SIN2; end end
                S_SIN2: begin gecikme <= gecikme + 4'd1; if (gecikme == 4'd5) begin logit1 <= oku_veri_ic[7:0]; durum <= S_SIN3; end end
                S_SIN3: begin
                    sinif <= ($signed(logit1) > $signed(logit0)); sonuc_gecerli <= 1'b1; ic_oku <= 1'b0;
                    satir_no <= 4'd0; katman_no <= 4'd0; cumle_no <= cumle_no + 16'd1; cumle_bitti <= 1'b1; durum <= S_AKT;
                end
                S_HATA: ;
                default: durum <= S_HATA;
            endcase
        end
    end
endmodule
