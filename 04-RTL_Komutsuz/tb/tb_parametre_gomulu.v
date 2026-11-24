// tb_parametre_gomulu.v -- gomulu sabit parametreler: 12 dogrusal katman (iki kodlayici katmani) altin modelle BIT-BIREBIR
//   Agirlik sozcukleri test duzeneginden gelir; sapma ve olcek carpani gomulu bellekten (panel_parametre_yukleyici),
//   GELU tablosu gomulu bellekten (gelu_yukleyici) yuklenir. Disaridan sapma/M0/tablo VERILMEZ.
//   Vivado'da parametresiz calisir (varsayilan yollar). plusarg: +ns=<cumle> (varsayilan 1) +vdir=<test_vektorleri>
`timescale 1ns/1ps
module tb_parametre_gomulu;
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
    parameter NS_VARSAYILAN = 1;
    parameter NB = 8;
    parameter VDIR_V = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/test_vektorleri";
    localparam NKAT = 12;                       // pooler ve classifier ayri (tek token) duzende; bu testte yok

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg          calistir = 0;
    reg  [10:0]  ayar_k = 0;
    reg  [6:0]   ayar_panel_sayisi = 0;
    reg  [5:0]   ayar_kaydirma = 0;
    reg          gelu_etkin = 0;
    wire         mesgul, katman_bitti;
    reg          akt_yaz_etkin = 0;
    reg  [11:0]  akt_yaz_adres = 0;
    reg  [63:0]  akt_yaz_veri = 0;
    reg          w_yaz_etkin = 0, w_yaz_tampon = 0;
    reg  [10:0]  w_yaz_adres = 0;
    reg  [63:0]  w_yaz_veri = 0;
    reg          param_basla = 0, param_tampon = 0;
    reg  [11:0]  param_taban = 0;
    wire         param_bitti;
    reg          tablo_basla = 0;
    reg  [1:0]   tablo_sec = 0;
    wire         tablo_bitti, tablo_mesgul;
    reg  [1:0]   panel_hazir = 0;
    wire         panel_bitti, panel_bitti_tampon;
    reg  [11:0]  cikis_oku_adres = 0;
    wire [63:0]  cikis_oku_veri;
    wire         tasma_hatasi;
    wire [31:0]  kirpilan_sayisi;

    dogrusal_katman_gomulu dut (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_sayisi), .ayar_blok_sayisi(4'd0),
        .ayar_kaydirma(ayar_kaydirma), .a_isaretsiz(1'b0), .gelu_etkin(gelu_etkin), .mesgul(mesgul), .katman_bitti(katman_bitti),
        .aktivasyon_yaz_etkin(akt_yaz_etkin), .aktivasyon_yaz_adres(akt_yaz_adres), .aktivasyon_yaz_veri(akt_yaz_veri),
        .w_yaz_etkin(w_yaz_etkin), .w_yaz_tampon(w_yaz_tampon), .w_yaz_adres(w_yaz_adres), .w_yaz_veri(w_yaz_veri),
        .param_basla(param_basla), .param_taban(param_taban), .param_tampon(param_tampon), .param_bitti(param_bitti),
        .tablo_basla(tablo_basla), .tablo_sec(tablo_sec), .tablo_bitti(tablo_bitti), .tablo_mesgul(tablo_mesgul),
        .panel_hazir(panel_hazir), .panel_bitti(panel_bitti), .panel_bitti_tampon(panel_bitti_tampon),
        .cikis_oku_adres(cikis_oku_adres), .cikis_oku_veri(cikis_oku_veri), .tasma_hatasi(tasma_hatasi), .kirpilan_sayisi(kirpilan_sayisi));

    reg [63:0] memAct [0:16383];
    reg [63:0] memW   [0:8191];
    reg [7:0]  memExp [0:131071];
    reg [255*8:1] vdir, yol, sfx;
    integer ns, li, s, p, errors, nchk, kat_hata, kat_chk, cyc, cyc0, cyc_kat, k, c, pan, nextp, w, t, blk, bi, gecen;
    integer top_cevrim;
    reg bitti;
    reg [7:0] gelen, beklenen;

    always @(posedge clk) cyc <= cyc + 1;

    // panel yukleme: agirlik sozcukleri + gomulu sapma/olcek carpani
    task yukle_panel;
        input integer pn;
        input integer b;
        integer tt;
        begin
            for (tt = 0; tt < k; tt = tt + 1) begin
                @(negedge clk); w_yaz_etkin = 1; w_yaz_tampon = b; w_yaz_adres = tt; w_yaz_veri = memW[pn*k + tt];
            end
            @(negedge clk); w_yaz_etkin = 0;
            @(negedge clk); param_basla = 1; param_taban = katman_taban(li) + pn*8; param_tampon = b;
            @(negedge clk); param_basla = 0;
            @(posedge clk); while (!param_bitti) @(posedge clk);
            @(negedge clk); panel_hazir[b] = 1'b1;
        end
    endtask

    // panel_bitti bir cevrimlik darbe: siraya al, bosalan tampona sonraki paneli yukle
    integer bq_bas = 0, bq_son = 0;
    reg     bq_buf [0:63];
    always @(posedge clk) if (panel_bitti) begin
        panel_hazir[panel_bitti_tampon] = 1'b0;
        bq_buf[bq_son % 64] = panel_bitti_tampon; bq_son = bq_son + 1;
    end
    always @(posedge clk) if (bq_bas != bq_son) begin
        if (nextp < pan) begin
            nextp = nextp + 1;
            yukle_panel(nextp - 1, bq_buf[bq_bas % 64]);
        end
        bq_bas = bq_bas + 1;
    end

    initial begin
        errors = 0; nchk = 0; cyc = 0; top_cevrim = 0; nextp = 0; pan = 0; k = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = VDIR_V;
        if (!$value$plusargs("ns=%d", ns)) ns = NS_VARSAYILAN;
        $display("==== GOMULU SABIT PARAMETRE SINAMASI: 12 dogrusal katman, altin modelle bit-birebir ====");
        $display("Sapma ve olcek carpani gomulu bellekten, GELU tablosu gomulu bellekten yuklenir; disaridan verilmez. Cumle sayisi: %0d", ns);
        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat (3) @(posedge clk);

        for (li = 0; li < NKAT; li = li + 1) begin
            k = katman_k(li); c = katman_c(li); pan = c / 8;
            ayar_k = katman_k(li); ayar_panel_sayisi = pan; ayar_kaydirma = katman_kaydirma(li); gelu_etkin = (katman_gelu(li) != 0);
            $display("[katman %0d/%0d] %0s  giris=%0d cikis=%0d panel=%0d kaydirma=%0d gelu=%0d", li + 1, NKAT, katman_ad(li), k, c, pan, katman_kaydirma(li), katman_gelu(li));
            // vektorler
            $sformat(yol, "%0s/%0s_girdi_blok.mem", vdir, katman_ad(li)); $readmemh(yol, memAct, 0, ns*NB*k - 1);
            $sformat(yol, "%0s/%0s_w_panel.mem", vdir, katman_ad(li));    $readmemh(yol, memW, 0, pan*k - 1);
            if (katman_gelu(li) != 0) sfx = "gelu_cikis"; else sfx = "cikis";
            $sformat(yol, "%0s/%0s_%0s.mem", vdir, katman_ad(li), sfx);   $readmemh(yol, memExp, 0, ns*64*c - 1);
            // GELU tablosu gomulu bellekten
            if (katman_gelu(li) != 0) begin
                @(negedge clk); tablo_sec = katman_gelu(li); tablo_basla = 1;
                @(negedge clk); tablo_basla = 0;
                @(posedge clk); while (!tablo_bitti) @(posedge clk);
                $display("   GELU tablosu gomulu bellekten yuklendi (256 giris)");
            end
            kat_hata = 0; kat_chk = 0; cyc_kat = 0;
            for (s = 0; s < ns; s = s + 1) begin
                for (w = 0; w < NB*k; w = w + 1) begin
                    @(negedge clk); akt_yaz_etkin = 1; akt_yaz_adres = w; akt_yaz_veri = memAct[s*NB*k + w];
                end
                @(negedge clk); akt_yaz_etkin = 0;
                panel_hazir = 2'b00; bq_bas = 0; bq_son = 0;
                nextp = 1; yukle_panel(0, 0);
                if (pan > 1) begin nextp = 2; yukle_panel(1, 1); end
                @(negedge clk); calistir = 1; cyc0 = cyc;
                @(negedge clk); calistir = 0;
                bitti = 0;
                while (!bitti && (cyc - cyc0) < 40*pan*NB*(k+20)) begin
                    @(posedge clk); #1;
                    if (katman_bitti) bitti = 1;
                end
                gecen = cyc - cyc0; cyc_kat = cyc_kat + gecen;
                if (!bitti) begin kat_hata = kat_hata + 1; $display("   HATA: zaman asimi (cumle %0d)", s); end
                for (blk = 0; blk < NB; blk = blk + 1)
                    for (w = 0; w < c; w = w + 1) begin
                        @(negedge clk); cikis_oku_adres = blk*c + w;
                        @(negedge clk); @(negedge clk);
                        for (bi = 0; bi < 8; bi = bi + 1) begin
                            kat_chk = kat_chk + 1;
                            beklenen = memExp[(s*64 + blk*8 + bi)*c + w];
                            gelen = cikis_oku_veri[bi*8 +: 8];
                            if (gelen !== beklenen) begin
                                kat_hata = kat_hata + 1;
                                if (kat_hata < 5) $display("   HATA cumle %0d token %0d kanal %0d: devre=%0d beklenen=%0d", s, blk*8+bi, w, $signed(gelen), $signed(beklenen));
                            end
                        end
                    end
                if (tasma_hatasi) begin kat_hata = kat_hata + 1; $display("   HATA: golge ustune yazildi"); end
            end
            errors = errors + kat_hata; nchk = nchk + kat_chk; top_cevrim = top_cevrim + cyc_kat;
            $display("   sonuc: %0s  kontrol=%0d hata=%0d hesap_cevrimi=%0d", (kat_hata == 0) ? "BASARILI" : "BASARISIZ", kat_chk, kat_hata, cyc_kat);
        end

        $display("----------------------------------------------");
        $display("GOMULU PARAMETRE TEST: %0s  (%0d katman, %0d kontrol, %0d hata, toplam %0d cevrim)", (errors == 0) ? "BASARILI" : "BASARISIZ", NKAT, nchk, errors, top_cevrim);
        $finish;
    end
endmodule
