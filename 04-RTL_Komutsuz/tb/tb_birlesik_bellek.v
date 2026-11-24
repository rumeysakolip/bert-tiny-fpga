// tb_birlesik_bellek.v -- birlesik aktivasyon belleği (48 KB, 6 birim): katmanlar adres tabanlariyla zincirlenir, KOPYALAMA YOK
//   Senaryo A: cumle girisi birim 6'ya yazilir; Q -> birim 1, K -> birim 2, V -> birim 3 (ayni girisi okurlar); uc cikis altin modelle bit-birebir,
//              ve hepsi son katmandan sonra da yerinde (ustune yazilmamis) olmali.
//   Senaryo B: ileri besleme 1 (GELU, 128->512) girisi birim 5'ten okur, cikisini birim 1-4'e yazar; ileri besleme 2 (512->128) girisini
//              AYNI yerden (birim 1-4) okur, cikisini birim 6'ya yazar. Iki cikis da altin modelle bit-birebir.
//   Vivado'da parametresiz calisir. plusarg: +ns=<cumle> (varsayilan 1) +vdir=<test_vektorleri>
`timescale 1ns/1ps
module tb_birlesik_bellek;
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
    parameter ZDIR_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_birlesik";

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg          calistir = 0;
    reg  [10:0]  ayar_k = 0;
    reg  [6:0]   ayar_panel_sayisi = 0;
    reg  [5:0]   ayar_kaydirma = 0;
    reg          gelu_etkin = 0;
    reg  [12:0]  taban_giris = 0, taban_cikis = 0;
    reg          devrik_yaz = 0;
    wire         mesgul, katman_bitti;
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
    reg  [1:0]   tablo_sec = 0;
    wire         tablo_bitti, tablo_mesgul;
    reg  [1:0]   panel_hazir = 0;
    wire         panel_bitti, panel_bitti_tampon, tasma_hatasi;
    wire [31:0]  kirpilan_sayisi;

    dogrusal_katman_birlesik dut (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_sayisi), .ayar_blok_sayisi(4'd0),
        .ayar_kaydirma(ayar_kaydirma), .a_isaretsiz(1'b0), .gelu_etkin(gelu_etkin), .devrik_yaz(devrik_yaz), .taban_giris(taban_giris), .taban_cikis(taban_cikis),
        .mesgul(mesgul), .katman_bitti(katman_bitti),
        .dis_yaz_etkin(dis_yaz_etkin), .dis_yaz_adres(dis_yaz_adres), .dis_yaz_veri(dis_yaz_veri), .dis_oku_adres(dis_oku_adres), .dis_oku_veri(dis_oku_veri),
        .w_yaz_etkin(w_yaz_etkin), .w_yaz_tampon(w_yaz_tampon), .w_yaz_adres(w_yaz_adres), .w_yaz_veri(w_yaz_veri),
        .param_basla(param_basla), .param_taban(param_taban), .param_tampon(param_tampon), .param_bitti(param_bitti),
        .tablo_basla(tablo_basla), .tablo_sec(tablo_sec), .tablo_bitti(tablo_bitti), .tablo_mesgul(tablo_mesgul),
        .panel_hazir(panel_hazir), .panel_bitti(panel_bitti), .panel_bitti_tampon(panel_bitti_tampon),
        .tasma_hatasi(tasma_hatasi), .kirpilan_sayisi(kirpilan_sayisi));

    reg [63:0] memAct [0:16383];
    reg [63:0] memW   [0:8191];
    reg [7:0]  memExp [0:131071];
    reg [255*8:1] vdir, zdir, yol, ad, sfx;
    integer ns, s, w, li, k, pan, nextp, errors, nchk, cyc, cyc0, gecen, hk, blk, c, bi, top_cevrim, kat_say, h;
    reg bitti;
    reg [7:0] gelen, beklenen;

    always @(posedge clk) cyc <= cyc + 1;

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

    // bellege cumle girisi: sozcuk (blk*K + k) -> taban + ...
    task giris_yaz;
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

    // bir katmani calistir: giris tabanindan okur, cikis tabanina yazar
    task kos;
        input integer katman;
        input integer tin;
        input integer tout;
        begin
            li = katman; k = katman_k(li); pan = katman_c(li) / 8;
            ayar_k = k; ayar_panel_sayisi = pan; ayar_kaydirma = katman_kaydirma(li); gelu_etkin = (katman_gelu(li) != 0);
            taban_giris = tin; taban_cikis = tout;
            $sformat(yol, "%0s/%0s_w_panel.mem", vdir, katman_ad(li)); $readmemh(yol, memW, 0, pan*k - 1);
            if (katman_gelu(li) != 0) begin
                @(negedge clk); tablo_sec = katman_gelu(li); tablo_basla = 1;
                @(negedge clk); tablo_basla = 0;
                @(posedge clk); while (!tablo_bitti) @(posedge clk);
            end
            panel_hazir = 2'b00; bq_bas = 0; bq_son = 0;
            nextp = 1; yukle_panel(0, 0);
            if (pan > 1) begin nextp = 2; yukle_panel(1, 1); end
            @(negedge clk); calistir = 1; cyc0 = cyc;
            @(negedge clk); calistir = 0;
            bitti = 0;
            while (!bitti && (cyc - cyc0) < 40*pan*NB*(k+20)) begin @(posedge clk); #1; if (katman_bitti) bitti = 1; end
            gecen = cyc - cyc0; top_cevrim = top_cevrim + gecen;
            if (!bitti) begin errors = errors + 1; $display("   HATA: zaman asimi"); end
        end
    endtask

    // bellekteki bir tensoru altin model dosyasiyla karsilastir
    task karsilastir;
        input integer katman;
        input integer taban;
        input integer cumle;
        input integer birim_etiket;
        input integer zincir_dosyasi;                 // 1: beklenen cikis, onceki katmanin gercek cikisindan hesaplanmis dosya
        integer kc, kat_hata;
        begin
            kc = katman_c(katman);
            if (katman_gelu(katman) != 0) sfx = "gelu_cikis"; else sfx = "cikis";
            if (zincir_dosyasi) $sformat(yol, "%0s/ffn2_zincir_cikis.mem", zdir); else $sformat(yol, "%0s/%0s_%0s.mem", vdir, katman_ad(katman), sfx);
            $readmemh(yol, memExp, 0, 4*64*kc - 1);
            kat_hata = 0; hk = 0;
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
            $display("   %0s sonucu (bellek birimi %0d'den itibaren): %0s  (%0d kontrol, %0d hata)", katman_ad(katman), birim_etiket, (kat_hata == 0) ? "BASARILI" : "BASARISIZ", 8*kc*8, kat_hata);
        end
    endtask

    initial begin
        errors = 0; nchk = 0; cyc = 0; top_cevrim = 0; nextp = 0; pan = 0; k = 0; li = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = VDIR_V;
        if (!$value$plusargs("zdir=%s", zdir)) zdir = ZDIR_V;
        if (!$value$plusargs("ns=%d", ns)) ns = NS_VARSAYILAN;
        $display("==== BIRLESIK AKTIVASYON BELLEGI (48 KB, 6 birim) SINAMASI: katmanlar kopyalamadan zincirlenir, altin modelle bit-birebir ====");
        $display("Birimler: 1=0..1023  2=1024..2047  3=2048..3071  4=3072..4095  5=4096..5119  6=5120..6143 (sozcuk adresi)");
        repeat (4) @(posedge clk); @(negedge clk); rst = 0; repeat (3) @(posedge clk);

        for (s = 0; s < ns; s = s + 1) begin
            // ---------- Senaryo A: Q, K, V ayni girisi okur, uc ayri birime yazar ----------
            $display("[cumle %0d] Senaryo A: giris birim 6'ya yazildi; Q->birim 1, K->birim 2, V->birim 3", s);
            $sformat(yol, "%0s/l0_q_girdi_blok.mem", vdir); $readmemh(yol, memAct, 0, 4*NB*128 - 1);
            giris_yaz(5120, NB*128, s*NB*128);
            kos(0, 5120, 0);     $display("   Q katmani calisti: %0d cevrim", gecen);
            kos(1, 5120, 1024);  $display("   K katmani calisti: %0d cevrim", gecen);
            kos(2, 5120, 2048);  $display("   V katmani calisti: %0d cevrim", gecen);
            karsilastir(0, 0, s, 1, 0); karsilastir(1, 1024, s, 2, 0); karsilastir(2, 2048, s, 3, 0);
            // ---------- Senaryo B: ileri besleme 1 -> ileri besleme 2, kopyasiz ----------
            $display("[cumle %0d] Senaryo B: giris birim 5'e yazildi; ileri besleme 1 -> birim 1-4; ileri besleme 2 AYNI yerden okur -> birim 6", s);
            $sformat(yol, "%0s/l0_ffn1_girdi_blok.mem", vdir); $readmemh(yol, memAct, 0, 4*NB*128 - 1);
            giris_yaz(4096, NB*128, s*NB*128);
            kos(4, 4096, 0);     $display("   ileri besleme 1 (GELU) calisti: %0d cevrim", gecen);
            kos(5, 0, 5120);     $display("   ileri besleme 2 calisti (girisi ileri besleme 1'in cikisi, kopyalanmadi): %0d cevrim", gecen);
            karsilastir(4, 0, s, 1, 0); karsilastir(5, 5120, s, 6, 1);
        end

        // ---------- Senaryo C: deger (V) devrik panel duzeninde yazilir; her bas icin 8 panel x 64 sozcuk altin modelin V paneliyle ayni olmali ----------
        $display("Senaryo C: V katmani DEVRIK yazim kipinde birim 4'e yazilir (deger matrisi, olasilik x deger icin panel duzeni)");
        for (s = 0; s < ns; s = s + 1) begin
            $sformat(yol, "%0s/l0_q_girdi_blok.mem", vdir); $readmemh(yol, memAct, 0, 4*NB*128 - 1);
            giris_yaz(5120, NB*128, s*NB*128);
            devrik_yaz = 1; kos(2, 5120, 3072); devrik_yaz = 0;
            $display("[cumle %0d] V katmani devrik yazimla calisti: %0d cevrim", s, gecen);
            for (h = 0; h < 2; h = h + 1) begin
                $sformat(yol, "%0s/l0_av_h%0d_w_panel.mem", vdir, h); $readmemh(yol, memW, 0, 4*512 - 1);
                hk = 0;
                for (w = 0; w < 512; w = w + 1) begin
                    @(negedge clk); dis_oku_adres = 3072 + h*512 + w;
                    @(negedge clk); @(negedge clk);
                    nchk = nchk + 8;
                    if (dis_oku_veri !== memW[s*512 + w]) begin hk = hk + 1; errors = errors + 1; if (hk < 4) $display("   HATA bas %0d sozcuk %0d: devre=%h beklenen=%h", h, w, dis_oku_veri, memW[s*512 + w]); end
                end
                $display("   bas %0d deger paneli (8 panel x 64 sozcuk): %0s  (512 sozcuk, %0d hata)", h, (hk == 0) ? "BASARILI" : "BASARISIZ", hk);
            end
        end

        $display("----------------------------------------------");
        $display("BIRLESIK BELLEK TEST: %0s  (%0d cumle, %0d kontrol, %0d hata, toplam %0d hesap cevrimi)", (errors == 0) ? "BASARILI" : "BASARISIZ", ns, nchk, errors, top_cevrim);
        $finish;
    end
endmodule
