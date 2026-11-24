// tb_artik_ln.v -- artik toplama + LayerNorm + sonraki girisin yeniden olceklenmesi, ALTIN MODELIN TAM TAMSAYI HATTIYLA bit-birebir
//   Dort LayerNorm (iki kodlayici katmaninin her birinde 2): her biri icin katman girisi (x) ve dikkat/ileri besleme cikisi (a) bellege yazilir,
//   blok calistirilir, sonuc (= sonraki katmanin girdisi) altin modelin zincirinden alinan beklenenle karsilastirilir.
//   Son LayerNorm'da havuz katmani yalniz ilk tokeni kullandigindan yalniz ilk token karsilastirilir.
//   Vivado'da parametresiz calisir. plusarg: +ns=<cumle> (varsayilan 1, en cok 4) +ldir=<vektor_ln>
`timescale 1ns/1ps
module tb_artik_ln;
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
    parameter LDIR_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_ln";

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg         basla = 0; reg [1:0] ln_no = 0; reg [12:0] taban_x = 0, taban_a = 0, taban_cikis = 0;
    wire        mesgul, bitti, tasma, blok_yaz_etkin; wire [12:0] blok_oku_adres, blok_yaz_adres; wire [63:0] blok_yaz_veri, bellek_oku_veri;
    reg         tb_yaz_etkin = 0; reg [12:0] tb_yaz_adres = 0, tb_oku_adres = 0; reg [63:0] tb_yaz_veri = 0;
    reg         tb_oku_sec = 0;

    wire        b_yaz_etkin = blok_yaz_etkin | tb_yaz_etkin;
    wire [12:0] b_yaz_adres = blok_yaz_etkin ? blok_yaz_adres : tb_yaz_adres;
    wire [63:0] b_yaz_veri  = blok_yaz_etkin ? blok_yaz_veri : tb_yaz_veri;
    wire [12:0] b_oku_adres = tb_oku_sec ? tb_oku_adres : blok_oku_adres;
    birlesik_bellek #(.BIRIM_SAYISI(6), .AW(13)) bellek (.clk(clk), .yaz_etkin(b_yaz_etkin), .yaz_adres(b_yaz_adres), .yaz_veri(b_yaz_veri),
        .oku_adres(b_oku_adres), .oku_veri(bellek_oku_veri));

    artik_ln_blogu dut (.clk(clk), .rst(rst), .basla(basla), .ln_no(ln_no), .taban_x(taban_x), .taban_a(taban_a), .taban_cikis(taban_cikis),
        .mesgul(mesgul), .bitti(bitti), .oku_adres(blok_oku_adres), .oku_veri(bellek_oku_veri),
        .yaz_etkin(blok_yaz_etkin), .yaz_adres(blok_yaz_adres), .yaz_veri(blok_yaz_veri), .tasma(tasma));

    reg [63:0] memX [0:4095];
    reg [63:0] memA [0:4095];
    reg [7:0]  memExp [0:32767];
    reg [255*8:1] ldir, yol;
    integer ns, j, s, w, blk, c, i, errors, nchk, hk, cyc, t0, top_cevrim, ilk, ntok;
    reg bitti_goruldu;
    reg [7:0] gel, bek;
    always @(posedge clk) cyc <= cyc + 1;
    always @(posedge clk) if (bitti) bitti_goruldu <= 1'b1;

    initial begin
        errors = 0; nchk = 0; cyc = 0; top_cevrim = 0;
        if (!$value$plusargs("ldir=%s", ldir)) ldir = LDIR_V;
        if (!$value$plusargs("ns=%d", ns)) ns = NS_VARSAYILAN;
        $display("==== ARTIK TOPLAMA + LAYERNORM SINAMASI: 4 LayerNorm x %0d cumle, altin modelin tam tamsayi hattiyla bit-birebir ====", ns);
        $display("Akis: x ve a, LayerNorm giris olcegine tasinip toplanir -> LayerNorm -> sonraki katmanin girdi olcegine tasinir (tek carpma devresi).");
        repeat (4) @(posedge clk); @(negedge clk); rst = 0; repeat (3) @(posedge clk);

        for (j = 0; j < LN_SAYISI; j = j + 1) begin
            $sformat(yol, "%0s/ln%0d_x_blok.mem", ldir, j + 1); $readmemh(yol, memX, 0, 4*1024 - 1);
            $sformat(yol, "%0s/ln%0d_a_blok.mem", ldir, j + 1); $readmemh(yol, memA, 0, 4*1024 - 1);
            $sformat(yol, "%0s/ln%0d_cikis.mem", ldir, j + 1);  $readmemh(yol, memExp, 0, 4*64*128 - 1);
            ilk = ln_yalniz_ilk_token(j); ntok = ilk ? 1 : 8;
            for (s = 0; s < ns; s = s + 1) begin
                // x -> birim 1 (taban 0), a -> birim 2 (taban 1024); cikis -> birim 3 (taban 2048)
                for (w = 0; w < 1024; w = w + 1) begin
                    @(negedge clk); tb_yaz_etkin = 1; tb_yaz_adres = w; tb_yaz_veri = memX[s*1024 + w];
                    @(negedge clk); tb_yaz_adres = 1024 + w; tb_yaz_veri = memA[s*1024 + w];
                end
                @(negedge clk); tb_yaz_etkin = 0;
                ln_no = j; taban_x = 0; taban_a = 1024; taban_cikis = 2048;
                bitti_goruldu = 0;
                @(negedge clk); basla = 1; t0 = cyc;
                @(negedge clk); basla = 0;
                while (!bitti_goruldu && (cyc - t0) < 400000) @(posedge clk);
                if (!bitti_goruldu) begin errors = errors + 1; $display("   HATA: zaman asimi"); end
                top_cevrim = top_cevrim + (cyc - t0);
                // sonuc: sozcuk (blk*128 + c) -> bayt i = token 8*blk+i (son LayerNorm'da yalniz ilk token)
                hk = 0;
                tb_oku_sec = 1;
                for (blk = 0; blk < (ilk ? 1 : 8); blk = blk + 1)
                    for (c = 0; c < 128; c = c + 1) begin
                        @(negedge clk); tb_oku_adres = 2048 + blk*128 + c;
                        @(negedge clk); @(negedge clk);
                        for (i = 0; i < ntok; i = i + 1) begin
                            bek = memExp[(s*64 + blk*8 + i)*128 + c]; gel = bellek_oku_veri[i*8 +: 8]; nchk = nchk + 1;
                            if (gel !== bek) begin hk = hk + 1; errors = errors + 1; if (hk < 4) $display("   HATA LN %0d token %0d kanal %0d: devre=%0d beklenen=%0d", j + 1, blk*8 + i, c, $signed(gel), $signed(bek)); end
                        end
                    end
                tb_oku_sec = 0;
                if (tasma) begin errors = errors + 1; $display("   HATA: artik toplam 18 bite sigmadi"); end
                $display("[LayerNorm %0d/%0d, cumle %0d] %0s (%0d kontrol%0s, %0d hata) | cevrim: %0d", j + 1, LN_SAYISI, s, (hk == 0) ? "BASARILI" : "BASARISIZ",
                         (ilk ? 128 : 8192), ilk ? ", yalniz ilk token" : "", hk, cyc - t0);
            end
        end
        $display("----------------------------------------------");
        $display("ARTIK TOPLAMA + LAYERNORM TEST: %0s  (%0d LayerNorm, %0d cumle, %0d kontrol, %0d hata)", (errors == 0) ? "BASARILI" : "BASARISIZ", LN_SAYISI, ns, nchk, errors);
        $finish;
    end
endmodule
