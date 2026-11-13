// tb_yeniden_olcekle_ortak.v -- ortak yeniden olcekleme birimi sinamasi (rastgele girisler, uc uc degerler dahil)
//   Kosul 1 (genis=0): 03-RTL/yeniden_olcekle ile AYNI cikis (8 bit kirpma).
//   Kosul 2 (genis=1): bagimsiz referans ile ayni cikis (32 bit kirpma): ref = clip32((acc*M0 + 2^(n-1)) >>> n).
//   Vivado'da parametresiz calisir.
`timescale 1ns/1ps
module tb_yeniden_olcekle_ortak;
    parameter N_RASTGELE = 40000;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg         giris_gecerli = 0, genis = 0;
    reg  signed [31:0] birikec = 0;
    reg  [30:0] m0 = 0;
    reg  [5:0]  kay = 0;
    wire        eski_gecerli, yeni_gecerli, eski_kirp, yeni_kirp;
    wire signed [7:0]  eski_cikis;
    wire signed [31:0] yeni_cikis;
    wire [0:0] eski_yb, yeni_yb;

    yeniden_olcekle #(.META_W(1)) eski (.clk(clk), .rst(rst), .giris_gecerli(giris_gecerli), .birikec(birikec), .olcek_m0(m0), .kaydirma(kay), .yan_bilgi_giris(1'b0),
        .cikis_gecerli(eski_gecerli), .cikis_int8(eski_cikis), .yan_bilgi_cikis(eski_yb), .kirpildi(eski_kirp));
    yeniden_olcekle_ortak #(.META_W(1)) yeni (.clk(clk), .rst(rst), .genis(genis), .giris_gecerli(giris_gecerli), .birikec(birikec), .olcek_m0(m0), .kaydirma(kay), .yan_bilgi_giris(1'b0),
        .cikis_gecerli(yeni_gecerli), .cikis_veri(yeni_cikis), .yan_bilgi_cikis(yeni_yb), .kirpildi(yeni_kirp));

    // referans (bagimsiz yazim): kuyruk, giris aninda hesaplanir, 4 cevrim sonra karsilastirilir
    reg signed [63:0] ref_q [0:3];
    reg               gen_q [0:3];
    integer i, hata1, hata2, kont1, kont2, kirp_say;
    reg signed [63:0] p, r, ust, alt;
    reg signed [63:0] ref_v;
    reg signed [63:0] ref_pipe [0:7];
    reg               gen_pipe [0:7];
    integer k;

    task referans;
        input signed [31:0] a;
        input [30:0] m;
        input [5:0] n;
        input g;
        output signed [63:0] y;
        begin
            p = a * $signed({33'd0, m});
            if (n != 0) p = p + (64'sd1 <<< (n - 1));
            r = p >>> n;
            ust = g ? 64'sd2147483647 : 64'sd127; alt = g ? -64'sd2147483648 : -64'sd128;
            if (r > ust) y = ust; else if (r < alt) y = alt; else y = r;
        end
    endtask

    always @(posedge clk) begin
        // 4 cevrimlik gecikme: ref_pipe
        for (k = 7; k > 0; k = k - 1) begin ref_pipe[k] <= ref_pipe[k-1]; gen_pipe[k] <= gen_pipe[k-1]; end
    end

    // karsilastirma: cikis gecerli oldugunda, 4 asama onceki girisin referansi ref_pipe[3]
    always @(posedge clk) if (yeni_gecerli) begin
        kont2 = kont2 + 1;
        if (yeni_cikis !== ref_pipe[4][31:0]) begin hata2 = hata2 + 1; if (hata2 < 5) $display("  HATA(genis=%0d): devre=%0d beklenen=%0d", gen_pipe[4], yeni_cikis, ref_pipe[4]); end
        if (!gen_pipe[4]) begin
            kont1 = kont1 + 1;
            if (eski_cikis !== yeni_cikis[7:0] || yeni_cikis < -128 || yeni_cikis > 127) begin hata1 = hata1 + 1; if (hata1 < 5) $display("  HATA(8 bit): eski=%0d ortak=%0d", eski_cikis, yeni_cikis); end
        end
    end

    reg signed [63:0] yy;
    initial begin
        hata1 = 0; hata2 = 0; kont1 = 0; kont2 = 0;
        for (k = 0; k < 8; k = k + 1) begin ref_pipe[k] = 0; gen_pipe[k] = 0; end
        $display("==== ORTAK YENIDEN OLCEKLEME SINAMASI: 8 bit kirpma eski birimle, 32 bit kirpma bagimsiz referansla ====");
        repeat (4) @(posedge clk); @(negedge clk); rst = 0;
        for (i = 0; i < N_RASTGELE; i = i + 1) begin
            @(negedge clk);
            giris_gecerli = 1;
            case (i % 4)
                0: birikec = $random;                                   // tam aralik
                1: birikec = $random % 1000000;                         // gercek birikec buyuklugu
                2: birikec = ($random & 1) ? 32'sh7fffffff : -32'sh7fffffff - 1;   // uc degerler
                default: birikec = $random % 5000;
            endcase
            m0 = $random & 31'h3fffffff;                                // M0 < 2^30
            kay = 30 + ($unsigned($random) % 14);                       // 30..43 (gercek kaydirma 34..42 civari)
            genis = ($unsigned($random) % 2);
            referans(birikec, m0, kay, genis, yy);
            ref_pipe[0] <= yy; gen_pipe[0] <= genis;
        end
        @(negedge clk); giris_gecerli = 0;
        repeat (12) @(posedge clk);
        $display("   genis=0 (8 bit) eski birimle karsilastirma : kontrol=%0d hata=%0d", kont1, hata1);
        $display("   tum kosullar referansla karsilastirma       : kontrol=%0d hata=%0d", kont2, hata2);
        $display("ORTAK YENIDEN OLCEKLEME TEST: %0s", (hata1 == 0 && hata2 == 0 && kont2 > 0) ? "BASARILI" : "BASARISIZ");
        $finish;
    end
endmodule
