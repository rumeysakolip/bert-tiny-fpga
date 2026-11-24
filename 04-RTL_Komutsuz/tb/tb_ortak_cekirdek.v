// tb_ortak_cekirdek.v -- TEK 8x8 dizi + TEK yeniden olcekleme devresiyle dort is turu, altin modelle bit-birebir
//   Evre 1 (dogrusal): Q, K, V (V devrik), ileri besleme 1 (GELU) -> ileri besleme 2 kopyasiz zincir
//   Evre 2 (dikkat)  : Q.K^T -> Softmax (olasiliklar bellekte) -> P.V (baglam bellekte), 2 katman x 2 bas
//   Evre 3 (artik+LN): 4 LayerNorm, altin modelin tam tamsayi hattiyla
//   Hepsi AYNI cekirdek ornegi uzerinde kosar; her evre oncekinin biraktigi belleğe dokunmadan yeni is baslatir.
//   Vivado'da parametresiz calisir. plusarg: +ns=<cumle> (varsayilan 1) +vdir=<test_vektorleri> +ddir=<vektor_dikkat> +ldir=<vektor_ln> +zdir=<vektor_birlesik>
`timescale 1ns/1ps
module tb_ortak_cekirdek;
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
    parameter NS_VARSAYILAN = 1;
    parameter NB = 8;
    parameter VDIR_V = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/test_vektorleri";
    parameter ZDIR_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_birlesik";
    parameter DDIR_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_dikkat";
    parameter LDIR_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_ln";

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg          basla = 0;
    reg  [2:0]   is_tipi = 0;
    reg  [12:0]  taban_giris = 0, taban_ikinci = 0, taban_cikis = 0;
    reg  [10:0]  ayar_k = 0;
    reg  [6:0]   ayar_panel_sayisi = 0;
    reg  [5:0]   ayar_kaydirma = 0;
    reg          gelu_etkin = 0, devrik_yaz = 0;
    reg  [30:0]  ayar_m0 = 0;
    reg  [23:0]  ayar_m0_sm = 0;
    reg  [6:0]   uzunluk = 0, cikis_panel_ofset = 0;
    reg  [9:0]   cikis_kanal = 0;
    reg  [1:0]   ln_no = 0;
    wire         mesgul, bitti;
    reg          dis_yaz_etkin = 0;
    reg  [12:0]  dis_yaz_adres = 0, dis_oku_adres = 0;
    reg  [63:0]  dis_yaz_veri = 0;
    wire [63:0]  dis_oku_veri;
    reg          w_yaz_etkin = 0, w_yaz_tampon = 0;
    reg  [10:0]  w_yaz_adres = 0;
    reg  [63:0]  w_yaz_veri = 0;
    reg          param_basla = 0, param_tampon = 0;
    reg  [11:0]  param_taban = 0;
    wire         param_bitti;
    reg          tablo_basla = 0;
    reg  [2:0]   tablo_sec = 0;
    wire         tablo_bitti, tablo_mesgul;
    reg  [1:0]   panel_hazir = 0;
    wire         panel_bitti, panel_bitti_tampon, tasma_hatasi, skor_tasma, ln_tasma, bellek_catisma;
    wire [31:0]  kirpilan_sayisi;

    ortak_cekirdek dut (
        .clk(clk), .rst(rst), .basla(basla), .is_tipi(is_tipi), .taban_giris(taban_giris), .taban_ikinci(taban_ikinci), .taban_cikis(taban_cikis),
        .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_sayisi), .ayar_blok_sayisi(4'd0), .ayar_kaydirma(ayar_kaydirma), .gelu_etkin(gelu_etkin), .devrik_yaz(devrik_yaz),
        .ayar_m0(ayar_m0), .ayar_m0_sm(ayar_m0_sm), .uzunluk(uzunluk), .cikis_panel_ofset(cikis_panel_ofset), .baglam_kanal(cikis_kanal), .ln_no(ln_no), .ln_y_yaz(1'b0), .ln_taban_y(13'd0),
        .mesgul(mesgul), .bitti(bitti),
        .dis_yaz_etkin(dis_yaz_etkin), .dis_yaz_adres(dis_yaz_adres), .dis_yaz_veri(dis_yaz_veri), .dis_oku_adres(dis_oku_adres), .dis_oku_veri(dis_oku_veri),
        .w_yaz_etkin(w_yaz_etkin), .w_yaz_tampon(w_yaz_tampon), .w_yaz_adres(w_yaz_adres), .w_yaz_veri(w_yaz_veri),
        .param_basla(param_basla), .param_taban(param_taban), .param_tampon(param_tampon), .param_bitti(param_bitti),
        .tablo_basla(tablo_basla), .tablo_sec(tablo_sec), .tablo_bitti(tablo_bitti), .tablo_mesgul(tablo_mesgul),
        .panel_hazir(panel_hazir), .panel_bitti(panel_bitti), .panel_bitti_tampon(panel_bitti_tampon),
        .tasma_hatasi(tasma_hatasi), .kirpilan_sayisi(kirpilan_sayisi), .skor_tasma(skor_tasma), .ln_tasma(ln_tasma), .bellek_catisma(bellek_catisma));

    reg [63:0] memAct [0:16383];
    reg [63:0] memW   [0:8191];
    reg [7:0]  memExp [0:131071];
    reg [63:0] memQ   [0:2047];
    reg [63:0] memK   [0:2047];
    reg [63:0] memV   [0:2047];
    reg [7:0]  memCtx [0:32767];
    reg [31:0] memPar [0:5];
    reg [31:0] memPv  [0:3];
    reg [7:0]  memUz  [0:3];
    reg [63:0] memX   [0:4095];
    reg [63:0] memA   [0:4095];
    reg [255*8:1] vdir, zdir, ddir, ldir, yol, sfx;
    integer ns, s, w, li, k, pan, nextp, errors, nchk, cyc, cyc0, gecen, hk, blk, c, bi, top_cevrim, h, L, j, b, i, ilk, ntok, t0, t1;
    integer errors_evre, nchk_evre, catisma_say;
    reg lin_aktif;
    reg bitti_g;
    reg [7:0] gelen, beklenen;

    always @(posedge clk) cyc <= cyc + 1;
    always @(posedge clk) if (bitti) bitti_g <= 1'b1;
    always @(posedge clk) if (bellek_catisma) catisma_say <= catisma_say + 1;

    // ---------------- ortak: bir is baslat ve bitmesini bekle ----------------
    task is_kos;
        input integer tip;
        input integer limit;
        begin
            bitti_g = 0;
            @(negedge clk); is_tipi = tip; basla = 1; cyc0 = cyc;
            @(negedge clk); basla = 0;
            while (!bitti_g && (cyc - cyc0) < limit) @(posedge clk);
            gecen = cyc - cyc0; top_cevrim = top_cevrim + gecen;
            if (!bitti_g) begin errors = errors + 1; $display("   HATA: zaman asimi (is turu %0d)", tip); end
            repeat (3) @(posedge clk);
        end
    endtask

    task bellege_yaz;                      // veri dizisinden bellege (sozcuk sayisi, kaynak ofset)
        input integer taban;
        input integer sozcuk_sayisi;
        input integer ofset;
        integer ww;
        begin
            for (ww = 0; ww < sozcuk_sayisi; ww = ww + 1) begin
                @(negedge clk); dis_yaz_etkin = 1; dis_yaz_adres = taban + ww; dis_yaz_veri = memAct[ofset + ww];
            end
            @(negedge clk); dis_yaz_etkin = 0;
        end
    endtask

    // ---------------- Evre 1: dogrusal katman (tb_birlesik_bellek ile ayni akis) ----------------
    task yukle_panel;
        input integer pn;
        input integer bf;
        integer tt;
        begin
            for (tt = 0; tt < k; tt = tt + 1) begin
                @(negedge clk); w_yaz_etkin = 1; w_yaz_tampon = bf; w_yaz_adres = tt; w_yaz_veri = memW[pn*k + tt];
            end
            @(negedge clk); w_yaz_etkin = 0;
            @(negedge clk); param_basla = 1; param_taban = katman_taban(li) + pn*8; param_tampon = bf;
            @(negedge clk); param_basla = 0;
            @(posedge clk); while (!param_bitti) @(posedge clk);
            @(negedge clk); panel_hazir[bf] = 1'b1;
        end
    endtask

    integer bq_bas = 0, bq_son = 0;
    reg     bq_buf [0:63];
    always @(posedge clk) if (lin_aktif && panel_bitti) begin
        panel_hazir[panel_bitti_tampon] = 1'b0;
        bq_buf[bq_son % 64] = panel_bitti_tampon; bq_son = bq_son + 1;
    end
    always @(posedge clk) if (lin_aktif && bq_bas != bq_son) begin
        if (nextp < pan) begin
            nextp = nextp + 1;
            yukle_panel(nextp - 1, bq_buf[bq_bas % 64]);
        end
        bq_bas = bq_bas + 1;
    end

    task kos_lin;
        input integer katman;
        input integer tin;
        input integer tout;
        begin
            li = katman; k = katman_k(li); pan = katman_c(li) / 8;
            ayar_k = k; ayar_panel_sayisi = pan; ayar_kaydirma = katman_kaydirma(li); gelu_etkin = (katman_gelu(li) != 0);
            taban_giris = tin; taban_cikis = tout; taban_ikinci = 0;
            $sformat(yol, "%0s/%0s_w_panel.mem", vdir, katman_ad(li)); $readmemh(yol, memW, 0, pan*k - 1);
            if (katman_gelu(li) != 0) begin
                @(negedge clk); tablo_sec = katman_gelu(li); tablo_basla = 1;
                @(negedge clk); tablo_basla = 0;
                @(posedge clk); while (!tablo_bitti) @(posedge clk);
            end
            panel_hazir = 2'b00; bq_bas = 0; bq_son = 0;
            lin_aktif = 1;
            nextp = 1; yukle_panel(0, 0);
            if (pan > 1) begin nextp = 2; yukle_panel(1, 1); end
            is_kos(0, 40*pan*NB*(k+20));
            lin_aktif = 0;
        end
    endtask

    task karsilastir_lin;
        input integer katman;
        input integer taban;
        input integer cumle;
        input integer zincir_dosyasi;
        integer kc, kat_hata;
        begin
            kc = katman_c(katman);
            if (katman_gelu(katman) != 0) sfx = "gelu_cikis"; else sfx = "cikis";
            if (zincir_dosyasi) $sformat(yol, "%0s/ffn2_zincir_cikis.mem", zdir); else $sformat(yol, "%0s/%0s_%0s.mem", vdir, katman_ad(katman), sfx);
            $readmemh(yol, memExp, 0, 4*64*kc - 1);
            kat_hata = 0;
            for (blk = 0; blk < NB; blk = blk + 1)
                for (c = 0; c < kc; c = c + 1) begin
                    @(negedge clk); dis_oku_adres = taban + blk*kc + c;
                    @(negedge clk); @(negedge clk);
                    for (bi = 0; bi < 8; bi = bi + 1) begin
                        nchk = nchk + 1;
                        beklenen = memExp[(cumle*64 + blk*8 + bi)*kc + c];
                        gelen = dis_oku_veri[bi*8 +: 8];
                        if (gelen !== beklenen) begin
                            kat_hata = kat_hata + 1; errors = errors + 1;
                            if (kat_hata < 4) $display("   HATA %0s: token %0d kanal %0d: devre=%0d beklenen=%0d", katman_ad(katman), blk*8+bi, c, $signed(gelen), $signed(beklenen));
                        end
                    end
                end
            $display("   %0s sonucu: %0s  (%0d kontrol, %0d hata) | %0d cevrim", katman_ad(katman), (kat_hata == 0) ? "BASARILI" : "BASARISIZ", 8*kc*8, kat_hata, gecen);
        end
    endtask

    initial begin
        errors = 0; nchk = 0; cyc = 0; top_cevrim = 0; nextp = 0; pan = 0; k = 0; li = 0; lin_aktif = 0; catisma_say = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = VDIR_V;
        if (!$value$plusargs("zdir=%s", zdir)) zdir = ZDIR_V;
        if (!$value$plusargs("ddir=%s", ddir)) ddir = DDIR_V;
        if (!$value$plusargs("ldir=%s", ldir)) ldir = LDIR_V;
        if (!$value$plusargs("ns=%d", ns)) ns = NS_VARSAYILAN;
        $display("==== ORTAK CEKIRDEK SINAMASI: tek dizi + tek yeniden olcekleme devresi; dogrusal, dikkat, artik+LayerNorm; %0d cumle; altin modelle bit-birebir ====", ns);
        $display("Bellek birimleri (sozcuk adresi): 1=0..1023  2=1024..2047  3=2048..3071  4=3072..4095  5=4096..5119  6=5120..6143");
        repeat (4) @(posedge clk); @(negedge clk); rst = 0; repeat (3) @(posedge clk);

        // ================= Evre 1: dogrusal =================
        $display("---- EVRE 1: dogrusal katmanlar (ayni cekirdek, is turu 0) ----");
        for (s = 0; s < ns; s = s + 1) begin
            $display("[cumle %0d] Q -> birim 1, K -> birim 2, V (devrik) -> birim 3; giris birim 6", s);
            $sformat(yol, "%0s/l0_q_girdi_blok.mem", vdir); $readmemh(yol, memAct, 0, 4*NB*128 - 1);
            bellege_yaz(5120, NB*128, s*NB*128);
            devrik_yaz = 0;
            kos_lin(0, 5120, 0);     karsilastir_lin(0, 0, s, 0);
            kos_lin(1, 5120, 1024);  karsilastir_lin(1, 1024, s, 0);
            devrik_yaz = 1; kos_lin(2, 5120, 2048); devrik_yaz = 0;
            hk = 0;
            for (h = 0; h < 2; h = h + 1) begin
                $sformat(yol, "%0s/l0_av_h%0d_w_panel.mem", vdir, h); $readmemh(yol, memW, 0, 4*512 - 1);
                for (w = 0; w < 512; w = w + 1) begin
                    @(negedge clk); dis_oku_adres = 2048 + h*512 + w;
                    @(negedge clk); @(negedge clk);
                    nchk = nchk + 8;
                    if (dis_oku_veri !== memW[s*512 + w]) begin hk = hk + 1; errors = errors + 1; if (hk < 4) $display("   HATA V paneli bas %0d sozcuk %0d", h, w); end
                end
            end
            $display("   V (devrik panel duzeni, 2 bas x 512 sozcuk): %0s  (%0d hata) | %0d cevrim", (hk == 0) ? "BASARILI" : "BASARISIZ", hk, gecen);
            $display("[cumle %0d] ileri besleme 1 (GELU) giris birim 5 -> birim 1-4; ileri besleme 2 ayni yerden okur -> birim 6", s);
            $sformat(yol, "%0s/l0_ffn1_girdi_blok.mem", vdir); $readmemh(yol, memAct, 0, 4*NB*128 - 1);
            bellege_yaz(4096, NB*128, s*NB*128);
            kos_lin(4, 4096, 0);     karsilastir_lin(4, 0, s, 0);
            kos_lin(5, 0, 5120);     karsilastir_lin(5, 5120, s, 1);
        end

        // ================= Evre 2: dikkat =================
        $display("---- EVRE 2: dikkat (is turu 1: Q.K^T + Softmax, is turu 2: P.V) ----");
        $sformat(yol, "%0s/param.mem", ddir);    $readmemh(yol, memPar);
        $sformat(yol, "%0s/param_pv.mem", ddir); $readmemh(yol, memPv);
        $sformat(yol, "%0s/uzunluk.mem", ddir);  $readmemh(yol, memUz);
        for (L = 0; L < 2; L = L + 1) begin
            $sformat(yol, "%0s/l%0d_attn_out_girdi.mem", vdir, L); $readmemh(yol, memCtx);
            for (s = 0; s < ns; s = s + 1)
                for (h = 0; h < 2; h = h + 1) begin
                    $sformat(yol, "%0s/l%0d_qk_h%0d_girdi_blok.mem", vdir, L, h); $readmemh(yol, memQ);
                    $sformat(yol, "%0s/l%0d_qk_h%0d_w_panel.mem", vdir, L, h);    $readmemh(yol, memK);
                    $sformat(yol, "%0s/l%0d_av_h%0d_w_panel.mem", vdir, L, h);    $readmemh(yol, memV);
                    // Q -> birim 1 (0..), K -> birim 2 (1024..), V (devrik) -> birim 3 (2048..)
                    for (w = 0; w < 512; w = w + 1) begin
                        @(negedge clk); dis_yaz_etkin = 1; dis_yaz_adres = w;        dis_yaz_veri = memQ[s*512 + w];
                        @(negedge clk); dis_yaz_adres = 1024 + w; dis_yaz_veri = memK[s*512 + w];
                        @(negedge clk); dis_yaz_adres = 2048 + w; dis_yaz_veri = memV[s*512 + w];
                    end
                    @(negedge clk); dis_yaz_etkin = 0;
                    // Q.K^T + Softmax: olasiliklar birim 5'te (4096..)
                    taban_giris = 0; taban_ikinci = 1024; taban_cikis = 4096;
                    ayar_m0 = memPar[L*3][30:0]; ayar_kaydirma = memPar[L*3 + 1][5:0]; ayar_m0_sm = memPar[L*3 + 2][23:0]; uzunluk = memUz[s][6:0];
                    is_kos(1, 400000); t1 = gecen;
                    // P.V: A = olasiliklar (birim 5), B = deger (birim 3), baglam birim 4'e (3072..) 128 kanalli duzende, bas kaydirmasiyla
                    taban_giris = 4096; taban_ikinci = 2048; taban_cikis = 3072;
                    ayar_m0 = memPv[L*2][30:0]; ayar_kaydirma = memPv[L*2 + 1][5:0]; cikis_kanal = 128; cikis_panel_ofset = h*8;
                    is_kos(2, 100000);
                    hk = 0;
                    for (b = 0; b < 8; b = b + 1)
                        for (w = 0; w < 64; w = w + 1) begin
                            @(negedge clk); dis_oku_adres = 3072 + b*128 + h*64 + w;
                            @(negedge clk); @(negedge clk);
                            for (i = 0; i < 8; i = i + 1) begin
                                beklenen = memCtx[(s*64 + b*8 + i)*128 + h*64 + w]; gelen = dis_oku_veri[i*8 +: 8];
                                nchk = nchk + 1;
                                if (gelen !== beklenen) begin
                                    hk = hk + 1; errors = errors + 1;
                                    if (hk < 4) $display("   HATA baglam (token %0d, kanal %0d): devre=%0d beklenen=%0d", b*8 + i, h*64 + w, $signed(gelen), $signed(beklenen));
                                end
                            end
                        end
                    $display("[katman %0d, cumle %0d, bas %0d] uzunluk=%0d : Q.K^T+Softmax %0d cevrim, P.V baglam %0s (4096 kontrol, %0d hata) | P.V %0d cevrim",
                             L, s, h, memUz[s], t1, (hk == 0) ? "BASARILI" : "BASARISIZ", hk, gecen);
                    if (skor_tasma) begin errors = errors + 1; $display("   HATA: skor 16 bite sigmadi"); end
                end
        end

        // ================= Evre 3: artik toplama + LayerNorm =================
        $display("---- EVRE 3: artik toplama + LayerNorm (is turu 3; ayni carpma devresi sirayla uc is gorur) ----");
        for (j = 0; j < LN_SAYISI; j = j + 1) begin
            $sformat(yol, "%0s/ln%0d_x_blok.mem", ldir, j + 1); $readmemh(yol, memX, 0, 4*1024 - 1);
            $sformat(yol, "%0s/ln%0d_a_blok.mem", ldir, j + 1); $readmemh(yol, memA, 0, 4*1024 - 1);
            $sformat(yol, "%0s/ln%0d_cikis.mem", ldir, j + 1);  $readmemh(yol, memExp, 0, 4*64*128 - 1);
            ilk = ln_yalniz_ilk_token(j); ntok = ilk ? 1 : 8;
            for (s = 0; s < ns; s = s + 1) begin
                for (w = 0; w < 1024; w = w + 1) begin
                    @(negedge clk); dis_yaz_etkin = 1; dis_yaz_adres = w;        dis_yaz_veri = memX[s*1024 + w];
                    @(negedge clk); dis_yaz_adres = 1024 + w; dis_yaz_veri = memA[s*1024 + w];
                end
                @(negedge clk); dis_yaz_etkin = 0;
                ln_no = j; taban_giris = 0; taban_ikinci = 1024; taban_cikis = 2048;
                is_kos(3, 400000);
                hk = 0;
                for (blk = 0; blk < (ilk ? 1 : 8); blk = blk + 1)
                    for (c = 0; c < 128; c = c + 1) begin
                        @(negedge clk); dis_oku_adres = 2048 + blk*128 + c;
                        @(negedge clk); @(negedge clk);
                        for (i = 0; i < ntok; i = i + 1) begin
                            beklenen = memExp[(s*64 + blk*8 + i)*128 + c]; gelen = dis_oku_veri[i*8 +: 8]; nchk = nchk + 1;
                            if (gelen !== beklenen) begin hk = hk + 1; errors = errors + 1; if (hk < 4) $display("   HATA LN %0d token %0d kanal %0d: devre=%0d beklenen=%0d", j + 1, blk*8 + i, c, $signed(gelen), $signed(beklenen)); end
                        end
                    end
                if (ln_tasma) begin errors = errors + 1; $display("   HATA: artik toplam 18 bite sigmadi"); end
                $display("[LayerNorm %0d/%0d, cumle %0d] %0s (%0d kontrol%0s, %0d hata) | %0d cevrim", j + 1, LN_SAYISI, s, (hk == 0) ? "BASARILI" : "BASARISIZ",
                         (ilk ? 128 : 8192), ilk ? ", yalniz ilk token" : "", hk, gecen);
            end
        end

        if (catisma_say != 0) begin errors = errors + 1; $display("HATA: bellek okuma portlari %0d kez ayni birimde carpisti", catisma_say); end
        $display("----------------------------------------------");
        $display("ORTAK CEKIRDEK TEST: %0s  (%0d cumle, %0d kontrol, %0d hata, toplam %0d is cevrimi, bellek okuma carpismasi %0d)", (errors == 0) ? "BASARILI" : "BASARISIZ", ns, nchk, errors, top_cevrim, catisma_say);
        $finish;
    end
endmodule
