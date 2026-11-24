// tb_flas_ust.v -- bayt kaynagi seri flas (benzetim modeli): flas -> qspi_okuyucu -> komutsuz_ust -> dogrusal katman (Q, K, V)
// -P: BOL (SCK yarim periyodu, sistem saati), NS (cumle sayisi)   plusarg: +flas=<hex> +vdir=<test_vektorleri> [+hatali=1]
// Kabul: her cizelge satirinda cikis BRAM'i altin <ad>_cikis.mem ile bit-birebir; ayrica olculen cevrim/bayt.
`timescale 1ns/1ps
module tb_flas_ust;
    parameter BOL = 2;
    parameter NS = 1;
    parameter K = 128, C = 128, NB = 8;
    parameter BAYT_CUMLE = 60515;
    parameter NS_V = 4;

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    wire sck, cs_n, io0_o; wire [3:0] io_i;
    wire satir_bitti, hata, tasma_hatasi, okuma_bitti;
    reg  devam = 0;
    reg  [11:0] cikis_oku_adres = 0;
    wire [63:0] cikis_oku_veri;
    wire [3:0]  satir_no; wire [15:0] cumle_no; wire [31:0] hata_sayisi, kabul_edilen_bayt;

    komutsuz_flas_ust #(.BOL(BOL), .TOPLAM_BAYT(NS*BAYT_CUMLE)) dut (
        .clk(clk), .rst(rst), .sck(sck), .cs_n(cs_n), .io0_o(io0_o), .io_i(io_i),
        .satir_bitti(satir_bitti), .devam(devam), .cikis_oku_adres(cikis_oku_adres), .cikis_oku_veri(cikis_oku_veri),
        .hata(hata), .satir_no(satir_no), .cumle_no(cumle_no), .hata_sayisi(hata_sayisi), .kabul_edilen_bayt(kabul_edilen_bayt),
        .tasma_hatasi(tasma_hatasi), .okuma_bitti(okuma_bitti));
    flas_modeli #(.BOYUT(NS_V*BAYT_CUMLE)) flas (.sck(sck), .cs_n(cs_n), .io0_i(io0_o), .io_o(io_i));

    integer errors, nchk, cyc, cyc0, cyc_basla, hatali_mod, cum, sat, c, blk, bi, cyc_okuma_bitti;
    reg [255*8:1] vdir, yol;
    reg [7:0] exq [0:NS_V*64*C-1];
    reg [7:0] exk [0:NS_V*64*C-1];
    reg [7:0] exv [0:NS_V*64*C-1];
    reg [7:0] gelen, bekle_b;
    always @(posedge clk) cyc <= cyc + 1;
    always @(posedge clk) if (okuma_bitti) cyc_okuma_bitti = cyc;

    task kontrol_et;
        input integer cumle;
        input integer satir;
        begin
            for (blk = 0; blk < NB; blk = blk + 1)
                for (c = 0; c < C; c = c + 1) begin
                    @(negedge clk); cikis_oku_adres = blk*C + c;
                    @(negedge clk); @(negedge clk);
                    for (bi = 0; bi < 8; bi = bi + 1) begin
                        nchk = nchk + 1;
                        case (satir)
                            0: bekle_b = exq[(cumle*64 + blk*8 + bi)*C + c];
                            1: bekle_b = exk[(cumle*64 + blk*8 + bi)*C + c];
                            default: bekle_b = exv[(cumle*64 + blk*8 + bi)*C + c];
                        endcase
                        gelen = cikis_oku_veri[bi*8 +: 8];
                        if (gelen !== bekle_b) begin
                            errors = errors + 1;
                            if (errors < 6) $display("  FAIL cumle %0d satir %0d token %0d kanal %0d: dut=%0d beklenen=%0d", cumle, satir, blk*8+bi, c, $signed(gelen), $signed(bekle_b));
                        end
                    end
                end
        end
    endtask

    initial begin
        errors = 0; nchk = 0; cyc = 0; cyc_okuma_bitti = 0;
        if (!$value$plusargs("vdir=%s", vdir)) begin $display("HATA: +vdir="); $finish; end
        if (!$value$plusargs("hatali=%d", hatali_mod)) hatali_mod = 0;
        $sformat(yol, "%0s/l0_q_cikis.mem", vdir); $readmemh(yol, exq);
        $sformat(yol, "%0s/l0_k_cikis.mem", vdir); $readmemh(yol, exk);
        $sformat(yol, "%0s/l0_v_cikis.mem", vdir); $readmemh(yol, exv);
        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        cyc_basla = cyc;

        if (hatali_mod == 0) begin
            for (cum = 0; cum < NS; cum = cum + 1) begin
                cyc0 = cyc;
                for (sat = 0; sat < 3; sat = sat + 1) begin
                    while (!satir_bitti && !hata && cyc - cyc0 < 40000000) begin @(posedge clk); #1; end
                    if (!satir_bitti) begin errors = errors + 1; $display("  FAIL cumle %0d satir %0d: zaman asimi/hata", cum, sat); sat = 99; end
                    else begin
                        kontrol_et(cum, sat);
                        @(negedge clk); devam = 1; @(negedge clk); devam = 0;
                    end
                end
                $display("BILGI cumle %0d: %0d cevrim (BOL=%0d, akis %0d bayt -> %0.2f cevrim/bayt), hata=%0d", cum, cyc - cyc0, BOL, BAYT_CUMLE, (cyc - cyc0) * 1.0 / BAYT_CUMLE, hata);
            end
            if (hata || hata_sayisi != 0) begin errors = errors + 1; $display("  FAIL: beklenmeyen CRC hatasi (%0d)", hata_sayisi); end
            if (kabul_edilen_bayt != NS*BAYT_CUMLE) begin errors = errors + 1; $display("  FAIL: kabul edilen bayt %0d != %0d", kabul_edilen_bayt, NS*BAYT_CUMLE); end
            $display("----------------------------------------------");
            $display("TOPLAM %0d cevrim, %0d bayt flastan okundu, SCK=%0d MHz (100 MHz sistem saatinde), %0d kontrol", cyc - cyc_basla, kabul_edilen_bayt, 50 / BOL, nchk);
            if (errors == 0) $display("FLAS KAYNAKLI KOMUTSUZ TEST (BOL=%0d ns=%0d): PASS  (%0d kontrol, 0 hata)", BOL, NS, nchk);
            else             $display("FLAS KAYNAKLI KOMUTSUZ TEST (BOL=%0d ns=%0d): FAIL  (%0d hata)", BOL, NS, errors);
        end else begin
            cyc0 = cyc;
            while (!hata && cyc - cyc0 < 1500000) begin
                @(posedge clk); #1;
                if (satir_bitti) begin @(negedge clk); devam = 1; @(negedge clk); devam = 0; end
            end
            repeat (3000) @(posedge clk);
            $display("HATALI FLAS ICERIGI: hata=%0d hata_sayisi=%0d kabul_edilen_bayt=%0d satir_no=%0d", hata, hata_sayisi, kabul_edilen_bayt, satir_no);
            if (hata && hata_sayisi == 1 && !satir_bitti) $display("FLAS CRC HATA ENJEKSIYONU TEST: PASS  (hata yakalandi, cizelge durdu)");
            else $display("FLAS CRC HATA ENJEKSIYONU TEST: FAIL");
        end
        $finish;
    end
endmodule
