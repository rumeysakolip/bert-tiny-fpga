// tb_layernorm.v -- layernorm_birim'i altin modelin katman_norm_tam vektorlerine karsi sinar (G11)
// +vdir=tb/vektor_g11   (ln_q/ln_ornek/ln_cikis/ln_gamma/ln_beta/ln_par/ln_meta .mem)
`timescale 1ns/1ps
module tb_layernorm;
    parameter N = 128;
    parameter MAXR = 600;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg         par_we = 0;
    reg  [6:0]  par_adr = 0;
    reg  signed [15:0] par_gamma = 0, par_beta = 0;
    reg  [39:0] eps_q = 0;
    reg  [30:0] m0 = 0;
    reg  [5:0]  nsh = 0;
    reg         start = 0, in_valid = 0;
    reg  signed [17:0] in_data = 0;
    wire        in_ready, out_valid, out_last, busy;
    wire signed [7:0] out_data;

    layernorm_birim #(.N(N)) dut (.clk(clk), .rst(rst), .par_we(par_we), .par_adr(par_adr), .par_gamma(par_gamma),
        .par_beta(par_beta), .eps_q(eps_q), .m0(m0), .nsh(nsh), .start(start), .in_ready(in_ready),
        .in_valid(in_valid), .in_data(in_data), .out_valid(out_valid), .out_data(out_data), .out_last(out_last), .busy(busy));

    reg [31:0] mQ    [0:MAXR*N-1];
    reg [31:0] mCik  [0:MAXR*N-1];
    reg [31:0] mOrn  [0:MAXR-1];
    reg [31:0] mGam  [0:16*N-1];
    reg [31:0] mBet  [0:16*N-1];
    reg [31:0] mPar  [0:16*3-1];
    reg [31:0] mMeta [0:2];
    reg [255*8:1] vdir, yol;
    reg [255*8:1] vcdf; reg vcd_ac = 0;
    integer nrow, nornek, r, i, hata, kontrol, bad_rows, cyc, cyc_min, cyc_max, cnt_out, h0, ornek, onceki;

    // faz sayaclari (satir 0 icin): dut.st her durumda kac cevrim kaldi
    integer stsay [0:15]; integer k_;
    initial for (k_ = 0; k_ < 16; k_ = k_ + 1) stsay[k_] = 0;
    reg say_ac = 0;
    always @(posedge clk) if (say_ac && dut.st != 0) stsay[dut.st] = stsay[dut.st] + 1;

    always @(posedge clk) if (out_valid) begin
        if ($signed(out_data) !== $signed(mCik[r*N + cnt_out][7:0])) begin
            hata = hata + 1;
            if (hata < 10) $display("  HATA satir %0d eleman %0d: rtl=%0d beklenen=%0d", r, cnt_out, out_data, $signed(mCik[r*N+cnt_out][7:0]));
        end
        kontrol = kontrol + 1; cnt_out = cnt_out + 1;
    end

    initial begin
        hata = 0; kontrol = 0; bad_rows = 0; cyc_min = 1000000; cyc_max = 0; cnt_out = 0; onceki = -1;
        if (!$value$plusargs("vdir=%s", vdir)) begin $display("HATA: +vdir yok"); $finish; end
        $sformat(yol, "%0s/ln_meta.mem", vdir);  $readmemh(yol, mMeta); nrow = mMeta[0]; nornek = mMeta[2];
        $sformat(yol, "%0s/ln_q.mem", vdir);     $readmemh(yol, mQ);
        $sformat(yol, "%0s/ln_cikis.mem", vdir); $readmemh(yol, mCik);
        $sformat(yol, "%0s/ln_ornek.mem", vdir); $readmemh(yol, mOrn);
        $sformat(yol, "%0s/ln_gamma.mem", vdir); $readmemh(yol, mGam);
        $sformat(yol, "%0s/ln_beta.mem", vdir);  $readmemh(yol, mBet);
        $sformat(yol, "%0s/ln_par.mem", vdir);   $readmemh(yol, mPar);
        if ($value$plusargs("vcd=%s", vcdf)) begin $dumpfile(vcdf); $dumpvars(0, tb_layernorm); vcd_ac = 1; end
        repeat (4) @(posedge clk); @(negedge clk); rst = 0;
        for (r = 0; r < nrow; r = r + 1) begin
            ornek = mOrn[r];
            if (ornek != onceki) begin                         // gamma/beta tablolarini yukle
                for (i = 0; i < N; i = i + 1) begin
                    @(negedge clk); par_we = 1; par_adr = i; par_gamma = mGam[ornek*N+i][15:0]; par_beta = mBet[ornek*N+i][15:0];
                end
                @(negedge clk); par_we = 0; onceki = ornek;
            end
            h0 = hata; cnt_out = 0; cyc = 0; say_ac = (r == 0);
            @(negedge clk); eps_q = mPar[ornek*3]; m0 = mPar[ornek*3+1][30:0]; nsh = mPar[ornek*3+2][5:0]; start = 1;
            @(negedge clk); start = 0;
            for (i = 0; i < N; i = i + 1) begin
                @(negedge clk); in_valid = 1; in_data = mQ[r*N+i][17:0];
            end
            @(negedge clk); in_valid = 0;
            while (cnt_out < N && cyc < 2000000) begin @(negedge clk); cyc = cyc + 1; end
            if (cnt_out != N) begin hata = hata + 1; $display("  HATA satir %0d: cikis sayisi %0d", r, cnt_out); end
            if (r == 0) begin say_ac = 0; for (k_ = 1; k_ < 16; k_ = k_ + 1) if (stsay[k_] != 0) $display("FAZ %0d %0d", k_, stsay[k_]); end
            if (hata != h0) bad_rows = bad_rows + 1;
            if (cyc < cyc_min) cyc_min = cyc; if (cyc > cyc_max) cyc_max = cyc;
            repeat (2) @(negedge clk);
            if (vcd_ac && r == 0) begin $dumpoff; end
        end
        $display("LAYERNORM TEST: %s  (%0d satir, %0d kontrol, %0d hata)  hesap_cevrimi=%0d..%0d",
                 (hata == 0) ? "PASS" : "FAIL", nrow, kontrol, hata, cyc_min, cyc_max);
        $finish;
    end
endmodule
