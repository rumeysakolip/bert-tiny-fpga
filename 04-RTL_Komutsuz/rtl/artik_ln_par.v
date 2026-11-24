// -----------------------------------------------------------------------------
// artik_ln_par.v -- artik toplama + LayerNorm, bir token blogunun 8 satiri AYNI ANDA (8 paralel LayerNorm hatti)
//   artik_ln_ortak.v'nin satir satir isledigi isi bir blok icin 8 hatta boler: hat i, blogun i. token'inin satiri. Bir aktivasyon sozcugu (8 token'in ayni
//   kanali) tum hatlara birlikte okunur: hat i, sozcugun i. baytini alir. Her hat kendi yeniden olcekleme devresine (4 DSP) ve LayerNorm birimine sahiptir;
//   hatlar ayni girdiyle ayni FSM'yi surdugu icin adim adim esgudumludur. Cikis sozcugu (8 hattin ayni kanali) dogrudan bellege yazilir.
//   Sonuc bit-birebir artik_ln_ortak ile aynidir (ayni hesap, ayni sabitler).
//   Sabitler (ln_harita) artik_ln_ortak.v'deki blogun kopyasidir (uret_ln_vektor.py ile uretilmis degerler).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

// ---- tek hat: yeniden olcekleme + LayerNorm birimi ----
module ln_hat (
    input  wire         clk,
    input  wire         rst,
    input  wire         p_yaz_etkin,
    input  wire [6:0]   p_yaz_adres,
    input  wire signed [15:0] p_gamma,
    input  wire signed [15:0] p_beta,
    input  wire [39:0]  eps_r,
    input  wire [30:0]  lm0_r,
    input  wire [5:0]   ln_n_r,
    input  wire         ln_baslat,
    input  wire         temizle,                   // is basinda tasma bayragini temizle
    input  wire         f2_v,
    input  wire         f2_src,
    input  wire [6:0]   f2_c,
    input  wire [7:0]   f_bayt,
    input  wire [30:0]  x_m0, a_m0, o_m0,
    input  wire [5:0]   x_n, a_n, o_n,
    input  wire         yukle_durumu,
    input  wire [6:0]   cik_say_meta,
    output reg          ln_giris_gecerli,
    output wire         ln_cikis_gecerli,
    output wire signed [7:0] ln_cikis_veri,
    output wire         rs_cik_gecerli,
    output wire [7:0]   rs_cik_veri8,
    output wire [7:0]   rs_meta_cik,
    output reg          tasma
);
    reg signed [17:0] ln_giris_veri;
    wire ln_giris_hazir, ln_cikis_son, ln_mesgul;
    layernorm_birim_dz #(.KANAL_SAYISI(128)) u_ln (.clk(clk), .rst(rst), .parametre_yaz_etkin(p_yaz_etkin), .parametre_yaz_adres(p_yaz_adres), .parametre_gamma(p_gamma),
        .parametre_beta(p_beta), .epsilon_q(eps_r), .olcek_m0(lm0_r), .olcek_kaydirma(ln_n_r), .baslat(ln_baslat), .giris_hazir(ln_giris_hazir),
        .giris_gecerli(ln_giris_gecerli), .giris_veri(ln_giris_veri), .cikis_gecerli(ln_cikis_gecerli), .cikis_veri(ln_cikis_veri), .cikis_son(ln_cikis_son), .mesgul(ln_mesgul));
    reg         rs_gir_gecerli, rs_genis;
    reg  signed [31:0] rs_gir_veri;
    reg  [30:0] rs_m0;
    reg  [5:0]  rs_n;
    reg  [7:0]  rs_meta_gir;
    wire signed [31:0] rs_cik_veri;
    assign rs_cik_veri8 = rs_cik_veri[7:0];
    yeniden_olcekle_ortak #(.META_W(8)) u_rs (.clk(clk), .rst(rst), .genis(rs_genis), .giris_gecerli(rs_gir_gecerli), .birikec(rs_gir_veri),
        .olcek_m0(rs_m0), .kaydirma(rs_n), .yan_bilgi_giris(rs_meta_gir), .cikis_gecerli(rs_cik_gecerli), .cikis_veri(rs_cik_veri), .yan_bilgi_cikis(rs_meta_cik), .kirpildi());
    reg signed [31:0] x_tmp;
    always @(posedge clk) begin
        rs_gir_gecerli <= 1'b0; ln_giris_gecerli <= 1'b0;
        if (rst) begin tasma <= 1'b0; end
        else begin
            if (temizle) tasma <= 1'b0;
            if (f2_v) begin
                rs_gir_gecerli <= 1'b1; rs_genis <= 1'b1; rs_gir_veri <= {{24{f_bayt[7]}}, f_bayt};
                rs_m0 <= f2_src ? a_m0 : x_m0; rs_n <= f2_src ? a_n : x_n; rs_meta_gir <= {f2_src, f2_c};
            end else if (ln_cikis_gecerli) begin
                rs_gir_gecerli <= 1'b1; rs_genis <= 1'b0; rs_gir_veri <= {{24{ln_cikis_veri[7]}}, ln_cikis_veri};
                rs_m0 <= o_m0; rs_n <= o_n; rs_meta_gir <= {1'b0, cik_say_meta};
            end
            if (rs_cik_gecerli && yukle_durumu) begin
                if (!rs_meta_cik[7]) x_tmp <= rs_cik_veri;
                else begin
                    ln_giris_gecerli <= 1'b1; ln_giris_veri <= (x_tmp + rs_cik_veri);
                    if ((x_tmp + rs_cik_veri) > 32'sd131071 || (x_tmp + rs_cik_veri) < -32'sd131072) tasma <= 1'b1;
                end
            end
        end
    end
endmodule

// ---- 8 hatli blok isleyici ----
module artik_ln_par (
    input  wire         clk,
    input  wire         rst,
    input  wire         basla,
    input  wire [1:0]   ln_no,
    input  wire [12:0]  taban_x,
    input  wire [12:0]  taban_a,
    input  wire [12:0]  taban_cikis,
    input  wire         y_yaz,
    input  wire [12:0]  taban_cikis_y,
    input  wire [3:0]   ayar_blok_sayisi,
    output wire         mesgul,
    output reg          bitti,
    output reg  [12:0]  oku_adres,
    input  wire [63:0]  oku_veri,
    output reg          yaz_etkin,
    output reg  [12:0]  yaz_adres,
    output reg  [63:0]  yaz_veri,
    output wire         tasma
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

    // ---------------- denetim ----------------
    localparam D_BOS = 3'd0, D_PAR = 3'd1, D_BASLAT = 3'd2, D_YUKLE = 3'd3, D_CIKIS = 3'd4, D_YAZY = 3'd5, D_SON = 3'd6;
    reg [2:0]  durum;
    reg [1:0]  ln_k;
    reg [12:0] tx, ta, tc, tcy;
    reg        y_on;
    reg [3:0]  nb_k, blk;
    reg [8:0]  pj;
    reg [8:0]  s;
    reg [7:0]  gir_say;
    reg [6:0]  cik_say;                    // LayerNorm cikis sayaci (y tamponu indeksi ve yeniden olcekleme yan bilgisi)
    reg [7:0]  yaz_say;
    reg        f1_v, f2_v, f1_src, f2_src; reg [6:0] f1_c, f2_c;
    reg        p_yaz_etkin; reg [6:0] p_yaz_adres; reg signed [15:0] p_gamma, p_beta;
    reg  [39:0] eps_r; reg [30:0] lm0_r; reg [5:0] ln_n_r;
    reg        ln_baslat, temizle, blok_bitti;
    reg [63:0] ybuf [0:127];
    assign mesgul = (durum != D_BOS);

    wire state_yukle = (durum == D_YUKLE) || (durum == D_BASLAT);
    wire state_cikis = (durum == D_CIKIS);
    wire [30:0] x_m0 = ln_x_m0(ln_k), a_m0 = ln_a_m0(ln_k), o_m0 = ln_o_m0(ln_k);
    wire [5:0]  x_n  = ln_x_n(ln_k),  a_n  = ln_a_n(ln_k),  o_n  = ln_o_n(ln_k);

    wire [7:0] ln_giris_g;                 // hat bazinda
    wire [7:0] ln_cikis_g;
    wire [63:0] y_kelime, z_kelime;
    wire [7:0] rs_cik_g;
    wire [7:0] rs_meta0;
    wire [7:0] tasma_v;
    wire [8*8-1:0] meta_v;
    genvar i;
    generate for (i = 0; i < 8; i = i + 1) begin : g_hat
        wire signed [7:0] cv; wire [7:0] r8; wire [7:0] mc;
        ln_hat u_hat (.clk(clk), .rst(rst), .p_yaz_etkin(p_yaz_etkin), .p_yaz_adres(p_yaz_adres), .p_gamma(p_gamma), .p_beta(p_beta),
            .eps_r(eps_r), .lm0_r(lm0_r), .ln_n_r(ln_n_r), .ln_baslat(ln_baslat), .temizle(temizle),
            .f2_v(f2_v), .f2_src(f2_src), .f2_c(f2_c), .f_bayt(oku_veri[8*i +: 8]),
            .x_m0(x_m0), .a_m0(a_m0), .o_m0(o_m0), .x_n(x_n), .a_n(a_n), .o_n(o_n),
            .yukle_durumu(state_yukle), .cik_say_meta(cik_say),
            .ln_giris_gecerli(ln_giris_g[i]), .ln_cikis_gecerli(ln_cikis_g[i]), .ln_cikis_veri(cv),
            .rs_cik_gecerli(rs_cik_g[i]), .rs_cik_veri8(r8), .rs_meta_cik(mc), .tasma(tasma_v[i]));
        assign y_kelime[8*i +: 8] = cv;
        assign z_kelime[8*i +: 8] = r8;
        assign meta_v[8*i +: 8] = mc;
    end endgenerate
    assign tasma = |tasma_v;
    wire [7:0] meta0 = meta_v[7:0];

    always @(posedge clk) begin
        p_yaz_etkin <= 1'b0; ln_baslat <= 1'b0; temizle <= 1'b0; yaz_etkin <= 1'b0; bitti <= 1'b0;
        if (rst) begin
            durum <= D_BOS; f1_v <= 1'b0; f2_v <= 1'b0; cik_say <= 7'd0; oku_adres <= 13'd0; yaz_adres <= 13'd0; yaz_veri <= 64'd0; blok_bitti <= 1'b0;
        end else begin
            // ---- yukleme boru hatti ----
            f2_v <= f1_v; f2_src <= f1_src; f2_c <= f1_c;
            // ---- LayerNorm cikislari: sayac ve y tamponu (hat 0'in gecerlisi tum hatlar icin ortak) ----
            if (ln_cikis_g[0]) begin ybuf[cik_say] <= y_kelime; cik_say <= cik_say + 7'd1; end
            // ---- yeniden olceklenmis cikis: 8 hattin ayni kanali tek sozcuk ----
            if (rs_cik_g[0] && state_cikis) begin
                yaz_etkin <= 1'b1; yaz_adres <= tc + {blk[2:0], 7'd0} + meta0[6:0]; yaz_veri <= z_kelime;
                if (meta0[6:0] == 7'd127) blok_bitti <= 1'b1;
            end
            case (durum)
                D_BOS: if (basla) begin
                    ln_k <= ln_no; tx <= taban_x; ta <= taban_a; tc <= taban_cikis; y_on <= y_yaz; tcy <= taban_cikis_y; temizle <= 1'b1; pj <= 9'd0; blk <= 4'd0;
                    nb_k <= (ayar_blok_sayisi == 4'd0 || ayar_blok_sayisi > 4'd8) ? 4'd8 : ayar_blok_sayisi;
                    eps_r <= ln_eps(ln_no); lm0_r <= ln_m0(ln_no); ln_n_r <= ln_n(ln_no); durum <= D_PAR;
                end
                D_PAR: begin
                    rom_adres <= {ln_k, 7'd0} + pj[6:0];
                    if (pj >= 9'd2) begin p_yaz_etkin <= 1'b1; p_yaz_adres <= pj[6:0] - 7'd2; p_gamma <= rom_gamma; p_beta <= rom_beta; end
                    if (pj == 9'd129) durum <= D_BASLAT;
                    pj <= pj + 9'd1;
                end
                D_BASLAT: begin ln_baslat <= 1'b1; s <= 9'd0; gir_say <= 8'd0; blok_bitti <= 1'b0; durum <= D_YUKLE; end
                D_YUKLE: begin
                    if (s < 9'd256) begin
                        oku_adres <= (s[0] ? ta : tx) + {blk[2:0], 7'd0} + s[7:1];
                        f1_v <= 1'b1; f1_src <= s[0]; f1_c <= s[7:1];
                        s <= s + 9'd1;
                    end else f1_v <= 1'b0;
                    if (ln_giris_g[0]) gir_say <= gir_say + 8'd1;
                    if (gir_say == 8'd128) begin cik_say <= 7'd0; durum <= D_CIKIS; end
                end
                D_CIKIS: begin
                    if (ln_giris_g[0]) gir_say <= gir_say + 8'd1;           // (son yukleme darbesi gec gelirse)
                    if (blok_bitti) begin
                        blok_bitti <= 1'b0;
                        if (y_on) begin yaz_say <= 8'd0; durum <= D_YAZY; end
                        else if (blk == nb_k - 4'd1) begin bitti <= 1'b1; durum <= D_BOS; end
                        else begin blk <= blk + 4'd1; durum <= D_BASLAT; end
                    end
                end
                D_YAZY: begin
                    yaz_etkin <= 1'b1; yaz_adres <= tcy + {blk[2:0], 7'd0} + yaz_say[6:0]; yaz_veri <= ybuf[yaz_say[6:0]];
                    if (yaz_say == 8'd127) begin
                        if (blk == nb_k - 4'd1) begin bitti <= 1'b1; durum <= D_BOS; end
                        else begin blk <= blk + 4'd1; durum <= D_BASLAT; end
                    end else yaz_say <= yaz_say + 8'd1;
                end
                default: durum <= D_BOS;
            endcase
        end
    end
endmodule
