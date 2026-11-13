// artik_ln_ortak.v -- artik_ln_blogu.v'nin ortak yeniden olcekleme birimine baglanan hali (uret_ln_ortak.py ile uretilir)
// -----------------------------------------------------------------------------
// artik_ln_blogu.v -- artik (residual) toplama + LayerNorm + sonraki girisin yeniden olceklenmesi, TEK carpma devresiyle
//   Altin model (B kipi):   q = tam(x, hs -> s_ln) + tam(a, s_a -> s_ln)             (iki akis LayerNorm giris olcegine tasinir, toplanir)
//                           y = katman_norm_tam(q, ...)                                (mevcut layernorm_birim, degismedi)
//                           z = tam(y, s_out -> sonraki a_olcek)                       (sonraki katmanin gercek girdisi)
//   Her satir (token) icin 128 kanal: x ve a bellekten okunur (aktivasyon duzeni: sozcuk = 8 token'in ayni kanali), ayni yeniden olcekleme
//   birimi uc is icin siraya girer (x akisi, a akisi, LayerNorm cikisi): ek carpma blogu harcanmaz. 8 satir (bir token blogu) bitince 128 sozcuk yazilir.
//   Gomulu sabitler: gamma/beta (ln_gamma.mem, ln_beta.mem; 4 LayerNorm x 128), epsilon/olcek/yeniden olcekleme (ln_harita.vh).
//   Kullanim: basla darbesi (ln_no 0..3, taban_x, taban_a, taban_cikis); bitti 1 cevrim darbe.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module artik_ln_ortak (
    input  wire         clk,
    input  wire         rst,
    input  wire         basla,
    input  wire [1:0]   ln_no,
    input  wire [12:0]  taban_x,
    input  wire [12:0]  taban_a,
    input  wire [12:0]  taban_cikis,
    input  wire         y_yaz,                   // 1: yeniden olceklenmemis cikis (y) ayrica taban_cikis_y'ye yazilir
    input  wire [12:0]  taban_cikis_y,
    output wire         mesgul,
    output reg          bitti,
    // bellek (kayitli okuma, 1 cevrim)
    output reg  [12:0]  oku_adres,
    input  wire [63:0]  oku_veri,
    output reg          yaz_etkin,
    output reg  [12:0]  yaz_adres,
    output reg  [63:0]  yaz_veri,
    output reg          tasma,                   // artik toplam 18 bite sigmadi (sticky; basla ile temizlenir)
    // ortak yeniden olcekleme birimine baglanti (bu blok kendi carpma devresini tasimaz)
    output reg          rs_gir_gecerli,
    output reg          rs_genis,
    output reg signed [31:0] rs_gir_veri,
    output reg  [30:0]  rs_m0,
    output reg  [5:0]   rs_n,
    output reg  [7:0]   rs_meta_gir,
    input  wire         rs_cik_gecerli,
    input  wire signed [31:0] rs_cik_veri,
    input  wire [7:0]   rs_meta_cik
);
    // >>> ln_harita basla
// ln_harita.vh -- uret_ln_vektor.py tarafindan uretildi; elle duzenlemeyin
localparam LN_SAYISI = 4;
function [39:0] ln_eps; input integer i; begin case (i)
        0: ln_eps = 40'd1;
        1: ln_eps = 40'd1;
        2: ln_eps = 40'd1;
        3: ln_eps = 40'd1;
        default: ln_eps = 40'd0; endcase end endfunction
function [30:0] ln_m0; input integer i; begin case (i)
        0: ln_m0 = 31'd655931401;
        1: ln_m0 = 31'd638004798;
        2: ln_m0 = 31'd871216554;
        3: ln_m0 = 31'd683654168;
        default: ln_m0 = 31'd0; endcase end endfunction
function [5:0] ln_n; input integer i; begin case (i)
        0: ln_n = 6'd50;
        1: ln_n = 6'd49;
        2: ln_n = 6'd49;
        3: ln_n = 6'd49;
        default: ln_n = 6'd0; endcase end endfunction
function [30:0] ln_x_m0; input integer i; begin case (i)
        0: ln_x_m0 = 31'd863060790;
        1: ln_x_m0 = 31'd1023211101;
        2: ln_x_m0 = 31'd648228509;
        3: ln_x_m0 = 31'd914724452;
        default: ln_x_m0 = 31'd0; endcase end endfunction
function [5:0] ln_x_n; input integer i; begin case (i)
        0: ln_x_n = 6'd26;
        1: ln_x_n = 6'd27;
        2: ln_x_n = 6'd26;
        3: ln_x_n = 6'd26;
        default: ln_x_n = 6'd0; endcase end endfunction
function [30:0] ln_a_m0; input integer i; begin case (i)
        0: ln_a_m0 = 31'd701167798;
        1: ln_a_m0 = 31'd606554150;
        2: ln_a_m0 = 31'd938729158;
        3: ln_a_m0 = 31'd677810651;
        default: ln_a_m0 = 31'd0; endcase end endfunction
function [5:0] ln_a_n; input integer i; begin case (i)
        0: ln_a_n = 6'd26;
        1: ln_a_n = 6'd26;
        2: ln_a_n = 6'd26;
        3: ln_a_n = 6'd26;
        default: ln_a_n = 6'd0; endcase end endfunction
function [30:0] ln_o_m0; input integer i; begin case (i)
        0: ln_o_m0 = 31'd1050081950;
        1: ln_o_m0 = 31'd1070038561;
        2: ln_o_m0 = 31'd546040382;
        3: ln_o_m0 = 31'd738176766;
        default: ln_o_m0 = 31'd0; endcase end endfunction
function [5:0] ln_o_n; input integer i; begin case (i)
        0: ln_o_n = 6'd30;
        1: ln_o_n = 6'd30;
        2: ln_o_n = 6'd29;
        3: ln_o_n = 6'd29;
        default: ln_o_n = 6'd0; endcase end endfunction
function [0:0] ln_yalniz_ilk_token; input integer i; begin case (i)
        0: ln_yalniz_ilk_token = 1'd0;
        1: ln_yalniz_ilk_token = 1'd0;
        2: ln_yalniz_ilk_token = 1'd0;
        3: ln_yalniz_ilk_token = 1'd1;
        default: ln_yalniz_ilk_token = 1'd0; endcase end endfunction
    // <<< ln_harita bitti

    // ---------------- gomulu gamma / beta ----------------
    reg [15:0] gamma_rom [0:511];
    reg [15:0] beta_rom  [0:511];
    initial begin $readmemh("ln_gamma.mem", gamma_rom); $readmemh("ln_beta.mem", beta_rom); end
    reg  [8:0]  rom_adres;
    reg  [15:0] rom_gamma, rom_beta;
    always @(posedge clk) begin rom_gamma <= gamma_rom[rom_adres]; rom_beta <= beta_rom[rom_adres]; end

    // ---------------- LayerNorm birimi ----------------
    reg         p_yaz_etkin; reg [6:0] p_yaz_adres; reg signed [15:0] p_gamma, p_beta;
    reg  [39:0] eps_r; reg [30:0] lm0_r; reg [5:0] ln_n_r;
    reg         ln_baslat, ln_giris_gecerli; reg signed [17:0] ln_giris_veri;
    wire        ln_giris_hazir, ln_cikis_gecerli, ln_cikis_son, ln_mesgul; wire signed [7:0] ln_cikis_veri;
    layernorm_birim_dz #(.KANAL_SAYISI(128)) u_ln (.clk(clk), .rst(rst), .parametre_yaz_etkin(p_yaz_etkin), .parametre_yaz_adres(p_yaz_adres), .parametre_gamma(p_gamma),
        .parametre_beta(p_beta), .epsilon_q(eps_r), .olcek_m0(lm0_r), .olcek_kaydirma(ln_n_r), .baslat(ln_baslat), .giris_hazir(ln_giris_hazir),
        .giris_gecerli(ln_giris_gecerli), .giris_veri(ln_giris_veri), .cikis_gecerli(ln_cikis_gecerli), .cikis_veri(ln_cikis_veri), .cikis_son(ln_cikis_son), .mesgul(ln_mesgul));

    // ---------------- denetim ----------------
    localparam D_BOS = 4'd0, D_PAR = 4'd1, D_BASLAT = 4'd2, D_YUKLE = 4'd3, D_CIKIS = 4'd4, D_YAZ = 4'd5, D_YAZY = 4'd6;
    reg [3:0]  durum;
    reg [1:0]  ln_k;
    reg [12:0] tx, ta, tc;
    reg [8:0]  pj;                          // parametre yukleme sayaci (0..129)
    reg [5:0]  satir;                       // 0..63
    reg [8:0]  s;                           // yukleme adimi 0..255 (+ bosaltma)
    reg [7:0]  gir_say;                     // LayerNorm'a verilen eleman sayisi
    reg [8:0]  cik_say;                     // alinan LayerNorm cikis sayisi (yeniden olceklenmis)
    reg [7:0]  yaz_say;
    reg        f1_v, f2_v, f1_src, f2_src; reg [6:0] f1_c, f2_c;
    reg signed [31:0] x_tmp;
    reg [7:0]  obuf [0:1023];               // 8 satir x 128 kanal (yeniden olceklenmis cikis, z)
    reg [7:0]  ybuf [0:1023];               // yeniden olceklenmemis LayerNorm cikisi (y)
    reg        y_on; reg [12:0] tcy;
    reg        satir_tamam;
    assign mesgul = (durum != D_BOS);

    wire [7:0] f_bayt = oku_veri[{satir[2:0], 3'b000} +: 8];
    wire state_yukle_cikis = (durum == D_YUKLE) || (durum == D_BASLAT);      // x ve a akislarinin sonuclari bu durumlarda gelir
    wire state_cikis_cikis = (durum == D_CIKIS);                              // LayerNorm cikislarinin sonuclari bu durumda gelir

    always @(posedge clk) begin
        p_yaz_etkin <= 1'b0; ln_baslat <= 1'b0; ln_giris_gecerli <= 1'b0; rs_gir_gecerli <= 1'b0; yaz_etkin <= 1'b0; bitti <= 1'b0; satir_tamam <= 1'b0;
        if (rst) begin
            durum <= D_BOS; tasma <= 1'b0; f1_v <= 1'b0; f2_v <= 1'b0; cik_say <= 9'd0; oku_adres <= 13'd0; yaz_adres <= 13'd0; yaz_veri <= 64'd0;
        end else begin
            // ---- yukleme boru hatti: bellek okuma (2 cevrim) -> yeniden olcekleme girisi ----
            f2_v <= f1_v; f2_src <= f1_src; f2_c <= f1_c;
            if (f2_v) begin
                rs_gir_gecerli <= 1'b1; rs_genis <= 1'b1; rs_gir_veri <= {{24{f_bayt[7]}}, f_bayt};
                rs_m0 <= f2_src ? ln_a_m0(ln_k) : ln_x_m0(ln_k); rs_n <= f2_src ? ln_a_n(ln_k) : ln_x_n(ln_k); rs_meta_gir <= {f2_src, f2_c};
            end else if (ln_cikis_gecerli) begin                        // LayerNorm cikisi: sonraki girisin olcegine
                rs_gir_gecerli <= 1'b1; rs_genis <= 1'b0; rs_gir_veri <= {{24{ln_cikis_veri[7]}}, ln_cikis_veri};
                rs_m0 <= ln_o_m0(ln_k); rs_n <= ln_o_n(ln_k); rs_meta_gir <= {1'b0, cik_say[6:0]};
                ybuf[{satir[2:0], cik_say[6:0]}] <= ln_cikis_veri;
                cik_say <= cik_say + 9'd1;
            end
            // ---- yeniden olcekleme cikislari ----
            // x akisi: sakla; a akisi: topla ve LayerNorm'a ver
            if (rs_cik_gecerli && state_yukle_cikis) begin
                if (!rs_meta_cik[7]) x_tmp <= rs_cik_veri;
                else begin
                    ln_giris_gecerli <= 1'b1; ln_giris_veri <= (x_tmp + rs_cik_veri);
                    if ((x_tmp + rs_cik_veri) > 32'sd131071 || (x_tmp + rs_cik_veri) < -32'sd131072) tasma <= 1'b1;
                    gir_say <= gir_say + 8'd1;
                end
            end
            // LayerNorm cikisi (yeniden olceklenmis) satir tamponuna
            if (rs_cik_gecerli && state_cikis_cikis) begin
                obuf[{satir[2:0], rs_meta_cik[6:0]}] <= rs_cik_veri[7:0];
                if (rs_meta_cik[6:0] == 7'd127) satir_tamam <= 1'b1;
            end

            case (durum)
                D_BOS: if (basla) begin
                    ln_k <= ln_no; tx <= taban_x; ta <= taban_a; tc <= taban_cikis; y_on <= y_yaz; tcy <= taban_cikis_y; tasma <= 1'b0; pj <= 9'd0; satir <= 6'd0;
                    eps_r <= ln_eps(ln_no); lm0_r <= ln_m0(ln_no); ln_n_r <= ln_n(ln_no); durum <= D_PAR;
                end
                D_PAR: begin                                                   // gamma/beta'yi LayerNorm birimine yaz (gomulu bellekten)
                    rom_adres <= {ln_k, 7'd0} + pj[6:0];
                    if (pj >= 9'd2) begin
                        p_yaz_etkin <= 1'b1; p_yaz_adres <= pj[6:0] - 7'd2; p_gamma <= rom_gamma; p_beta <= rom_beta;
                    end
                    if (pj == 9'd129) begin durum <= D_BASLAT; end
                    pj <= pj + 9'd1;
                end
                D_BASLAT: begin ln_baslat <= 1'b1; s <= 9'd0; gir_say <= 8'd0; durum <= D_YUKLE; end
                D_YUKLE: begin
                    // adim s: kanal c = s/2, s cift -> x, s tek -> a
                    if (s < 9'd256) begin
                        oku_adres <= (s[0] ? ta : tx) + {satir[5:3], 7'd0} + s[7:1];
                        f1_v <= 1'b1; f1_src <= s[0]; f1_c <= s[7:1];
                        s <= s + 9'd1;
                    end else f1_v <= 1'b0;
                    if (gir_say == 8'd128) begin cik_say <= 9'd0; durum <= D_CIKIS; end
                end
                D_CIKIS: if (satir_tamam) begin
                    if (satir[2:0] == 3'd7) begin yaz_say <= 8'd0; durum <= D_YAZ; end
                    else begin satir <= satir + 6'd1; durum <= D_BASLAT; end
                end
                D_YAZ: begin
                    yaz_etkin <= 1'b1; yaz_adres <= tc + {satir[5:3], 7'd0} + yaz_say[6:0];
                    yaz_veri <= {obuf[7*128 + yaz_say[6:0]], obuf[6*128 + yaz_say[6:0]], obuf[5*128 + yaz_say[6:0]], obuf[4*128 + yaz_say[6:0]],
                                 obuf[3*128 + yaz_say[6:0]], obuf[2*128 + yaz_say[6:0]], obuf[1*128 + yaz_say[6:0]], obuf[0*128 + yaz_say[6:0]]};
                    if (yaz_say == 8'd127) begin
                        if (y_on) begin yaz_say <= 8'd0; durum <= D_YAZY; end
                        else if (satir == 6'd63) begin bitti <= 1'b1; durum <= D_BOS; end
                        else begin satir <= satir + 6'd1; durum <= D_BASLAT; end
                    end else yaz_say <= yaz_say + 8'd1;
                end
                D_YAZY: begin
                    yaz_etkin <= 1'b1; yaz_adres <= tcy + {satir[5:3], 7'd0} + yaz_say[6:0];
                    yaz_veri <= {ybuf[7*128 + yaz_say[6:0]], ybuf[6*128 + yaz_say[6:0]], ybuf[5*128 + yaz_say[6:0]], ybuf[4*128 + yaz_say[6:0]],
                                 ybuf[3*128 + yaz_say[6:0]], ybuf[2*128 + yaz_say[6:0]], ybuf[1*128 + yaz_say[6:0]], ybuf[0*128 + yaz_say[6:0]]};
                    if (yaz_say == 8'd127) begin
                        if (satir == 6'd63) begin bitti <= 1'b1; durum <= D_BOS; end
                        else begin satir <= satir + 6'd1; durum <= D_BASLAT; end
                    end else yaz_say <= yaz_say + 8'd1;
                end
                default: durum <= D_BOS;
            endcase
        end
    end
endmodule
