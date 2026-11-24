// tb_dikkat_pv.v -- tam dikkat bası: Q.K^T -> Softmax -> (olasiliklar CIP ICINDE uretilir) -> olasilik x deger (P.V) -> baglam, ALTIN MODELLE bit-birebir
//   Her is (katman, cumle, bas): once QK + Softmax kosulur (olasiliklar cip belleginde kalir), sonra deger matrisi (devrik panel duzeni) yuklenir
//   ve P.V kipi kosulur: A operandi dikkat cekirdeginin KENDI urettigi olasiliklardir (dosyadan degil).
//   Baglam (INT8) altin modelin attn_out girdisinin ilgili bas dilimiyle (64 kanal) karsilastirilir: 4096 deger.
//   Vivado'da parametresiz calisir. plusarg: +ns=<cumle> (varsayilan 2) +vdir=<test_vektorleri> +ddir=<vektor_dikkat>
`timescale 1ns/1ps
module tb_dikkat_pv;
    parameter NS_VARSAYILAN = 2;
    parameter VDIR_V = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/test_vektorleri";
    parameter DDIR_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_dikkat";

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg          q_yaz_etkin = 0, k_yaz_etkin = 0, basla = 0, mod = 0;
    reg  [11:0]  q_yaz_adres = 0, k_yaz_adres = 0;
    reg  [63:0]  q_yaz_veri = 0, k_yaz_veri = 0;
    reg  [30:0]  ayar_m0_qk = 0, ayar_m0_pv = 0;
    reg  [5:0]   ayar_n_qk = 0, ayar_n_pv = 0;
    reg  [23:0]  ayar_m0_sm = 0;
    reg  [6:0]   uzunluk = 0;
    wire         skor_hazir, bitti, mesgul, skor_tasma, tile_tasma;
    reg  [8:0]   c_oku_adres = 0;
    wire [63:0]  c_oku_veri;
    wire signed [15:0] skor_oku_veri;
    wire [63:0]  p_oku_veri;

    dikkat_cekirdegi dut (.clk(clk), .rst(rst), .q_yaz_etkin(q_yaz_etkin), .q_yaz_adres(q_yaz_adres), .q_yaz_veri(q_yaz_veri),
        .k_yaz_etkin(k_yaz_etkin), .k_yaz_adres(k_yaz_adres), .k_yaz_veri(k_yaz_veri),
        .ayar_k_taban(12'd0), .ayar_k_adim(12'd64), .ayar_m0_qk(ayar_m0_qk), .ayar_n_qk(ayar_n_qk), .ayar_m0_sm(ayar_m0_sm), .uzunluk(uzunluk),
        .basla(basla), .mod(mod), .ayar_m0_pv(ayar_m0_pv), .ayar_n_pv(ayar_n_pv), .skor_hazir(skor_hazir), .bitti(bitti), .mesgul(mesgul),
        .skor_oku_adres(12'd0), .skor_oku_veri(skor_oku_veri), .p_oku_adres(9'd0), .p_oku_veri(p_oku_veri), .c_oku_adres(c_oku_adres), .c_oku_veri(c_oku_veri),
        .skor_tasma(skor_tasma), .tile_tasma(tile_tasma));

    reg [63:0] memQ [0:2047];
    reg [63:0] memK [0:2047];
    reg [63:0] memV [0:2047];
    reg [7:0]  memCtx [0:32767];
    reg [31:0] memPar  [0:5];
    reg [31:0] memPv   [0:3];
    reg [7:0]  memUz   [0:3];
    reg [255*8:1] vdir, ddir, yol;
    integer ns, L, s, h, i, w, errors, nchk, hc, cyc, t0, t1, t2, isler, b, top_cevrim;
    reg bitti_goruldu;
    reg [7:0] bek_c, gel_c;

    always @(posedge clk) cyc <= cyc + 1;
    always @(posedge clk) if (bitti) bitti_goruldu <= 1'b1;

    task kos_ve_bekle;
        input integer limit;
        begin
            bitti_goruldu = 0;
            @(negedge clk); basla = 1;
            @(negedge clk); basla = 0;
            while (!bitti_goruldu && (cyc - t0) < limit) @(posedge clk);
            if (!bitti_goruldu) begin errors = errors + 1; $display("  HATA: zaman asimi"); end
        end
    endtask

    initial begin
        errors = 0; nchk = 0; cyc = 0; isler = 0; top_cevrim = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = VDIR_V;
        if (!$value$plusargs("ddir=%s", ddir)) ddir = DDIR_V;
        if (!$value$plusargs("ns=%d", ns)) ns = NS_VARSAYILAN;
        $display("==== TAM DIKKAT BASI SINAMASI: Q.K^T -> Softmax -> P.V (olasiliklar cip icinde uretilir), 2 katman x 2 bas x %0d cumle, altin modelle bit-birebir ====", ns);
        $sformat(yol, "%0s/param.mem", ddir);    $readmemh(yol, memPar);
        $sformat(yol, "%0s/param_pv.mem", ddir); $readmemh(yol, memPv);
        $sformat(yol, "%0s/uzunluk.mem", ddir);  $readmemh(yol, memUz);
        repeat (4) @(posedge clk); @(negedge clk); rst = 0; repeat (3) @(posedge clk);

        for (L = 0; L < 2; L = L + 1) begin
            $sformat(yol, "%0s/l%0d_attn_out_girdi.mem", vdir, L); $readmemh(yol, memCtx);
            for (s = 0; s < ns; s = s + 1)
                for (h = 0; h < 2; h = h + 1) begin
                    // 1) Q.K^T + Softmax (mod 0): olasiliklar cip belleginde kalir
                    $sformat(yol, "%0s/l%0d_qk_h%0d_girdi_blok.mem", vdir, L, h); $readmemh(yol, memQ);
                    $sformat(yol, "%0s/l%0d_qk_h%0d_w_panel.mem", vdir, L, h);    $readmemh(yol, memK);
                    for (w = 0; w < 512; w = w + 1) begin
                        @(negedge clk); q_yaz_etkin = 1; q_yaz_adres = w; q_yaz_veri = memQ[s*512 + w];
                        k_yaz_etkin = 1; k_yaz_adres = w; k_yaz_veri = memK[s*512 + w];
                    end
                    @(negedge clk); q_yaz_etkin = 0; k_yaz_etkin = 0;
                    ayar_m0_qk = memPar[L*3][30:0]; ayar_n_qk = memPar[L*3 + 1][5:0]; ayar_m0_sm = memPar[L*3 + 2][23:0]; uzunluk = memUz[s][6:0];
                    mod = 0; t0 = cyc; kos_ve_bekle(400000); t1 = cyc;
                    // 2) deger matrisi (devrik panel duzeni) yuklenir
                    $sformat(yol, "%0s/l%0d_av_h%0d_w_panel.mem", vdir, L, h); $readmemh(yol, memV);
                    for (w = 0; w < 512; w = w + 1) begin
                        @(negedge clk); k_yaz_etkin = 1; k_yaz_adres = w; k_yaz_veri = memV[s*512 + w];
                    end
                    @(negedge clk); k_yaz_etkin = 0;
                    // 3) P.V (mod 1)
                    ayar_m0_pv = memPv[L*2][30:0]; ayar_n_pv = memPv[L*2 + 1][5:0];
                    mod = 1; t0 = cyc; kos_ve_bekle(100000); t2 = cyc;
                    // baglam karsilastirma: sozcuk (blok*64 + kanal), bayt i = token 8*blok+i ; beklenen [n][64][128] bas dilimi
                    hc = 0;
                    for (b = 0; b < 8; b = b + 1)
                        for (w = 0; w < 64; w = w + 1) begin
                            @(negedge clk); c_oku_adres = b*64 + w;
                            @(negedge clk); @(negedge clk);
                            for (i = 0; i < 8; i = i + 1) begin
                                bek_c = memCtx[(s*64 + b*8 + i)*128 + h*64 + w];
                                gel_c = c_oku_veri[i*8 +: 8];
                                if (gel_c !== bek_c) begin
                                    hc = hc + 1;
                                    if (hc < 4) $display("  HATA baglam (token %0d, kanal %0d): devre=%0d beklenen=%0d", b*8 + i, h*64 + w, $signed(gel_c), $signed(bek_c));
                                end
                            end
                        end
                    errors = errors + hc; nchk = nchk + 4096; isler = isler + 1; top_cevrim = top_cevrim + (t2 - t0);
                    $display("[katman %0d, cumle %0d, bas %0d] uzunluk=%0d : Q.K^T+Softmax tamamlandi, P.V baglam %0s (4096 kontrol, %0d hata) | cevrim: P.V=%0d",
                             L, s, h, memUz[s], (hc == 0) ? "BASARILI" : "BASARISIZ", hc, t2 - t0);
                end
        end
        $display("----------------------------------------------");
        $display("TAM DIKKAT BASI TEST: %0s  (%0d is, %0d kontrol, %0d hata)", (errors == 0) ? "BASARILI" : "BASARISIZ", isler, nchk, errors);
        $finish;
    end
endmodule
