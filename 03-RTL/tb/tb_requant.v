// tb_requant.v -- yeniden_olcekle vs python altini (tb/vektor_rq): uc degerler, yarim-yukari yuvarlama,
// kirpma siniri, tam aralik rastgele; veri akisinda rastgele bosluk (vin=0) ve meta sirasi denetlenir.
`timescale 1ns/1ps
module tb_requant;
    localparam MAXT = 16384;
    // +vdir verilmezse (Vivado GUI) bu klasor kullanilir. Baska bilgisayarda yolu degistirin.
    parameter VDIR_VARSAYILAN = "C:/Users/rumey/Documents/biitirme-projem/03-RTL/tb/vektor_rq";
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg                 vin = 0;
    reg  signed [31:0]  acc = 0;
    reg  [30:0]         m0 = 0;
    reg  [5:0]          n = 0;
    reg  [17:0]         meta_in = 0;
    wire                vout, sat;
    wire signed [7:0]   y;
    wire [17:0]         meta_out;

    yeniden_olcekle #(.META_W(18)) dut (.clk(clk), .rst(rst), .vin(vin), .acc(acc), .m0(m0), .n(n),
        .meta_in(meta_in), .vout(vout), .y(y), .meta_out(meta_out), .sat(sat));

    reg [31:0] memA [0:MAXT-1];
    reg [31:0] memM [0:MAXT-1];
    reg [7:0]  memN [0:MAXT-1];
    reg [7:0]  memY [0:MAXT-1];
    reg [31:0] memMeta [0:0];
    integer ntest, gonder, alinan, errors, sirasiz, kirp_say, lat, lat_min;
    reg [255*8:1] vdir, yol;

    // alici: cikista sirayla denetle
    always @(posedge clk) if (vout) begin
        if (meta_out !== alinan[17:0]) begin sirasiz = sirasiz + 1; errors = errors + 1; end
        if (y !== memY[alinan]) begin
            errors = errors + 1;
            if (errors < 6) $display("  FAIL #%0d: acc=%0d m0=%0d n=%0d -> dut=%0d beklenen=%0d",
                alinan, $signed(memA[alinan]), memM[alinan], memN[alinan], y, $signed(memY[alinan]));
        end
        if (sat) kirp_say = kirp_say + 1;
        alinan = alinan + 1;
    end

    initial begin
        errors = 0; sirasiz = 0; alinan = 0; kirp_say = 0; lat = 0; lat_min = 1000;
        if (!$value$plusargs("vdir=%s", vdir)) begin vdir = VDIR_VARSAYILAN; $display("BILGI: +vdir verilmedi, varsayilan klasor: %0s", vdir); end
        $sformat(yol, "%0s/meta.mem", vdir); $readmemh(yol, memMeta); ntest = memMeta[0];
        $sformat(yol, "%0s/ACC.mem", vdir); $readmemh(yol, memA, 0, ntest-1);
        $sformat(yol, "%0s/M0.mem", vdir);  $readmemh(yol, memM, 0, ntest-1);
        $sformat(yol, "%0s/N.mem", vdir);   $readmemh(yol, memN, 0, ntest-1);
        $sformat(yol, "%0s/Y.mem", vdir);   $readmemh(yol, memY, 0, ntest-1);
        repeat (3) @(posedge clk);
        @(negedge clk); rst = 0;
        // gecikme olcumu: tek eleman
        @(negedge clk); vin = 1; acc = memA[0]; m0 = memM[0][30:0]; n = memN[0][5:0]; meta_in = 18'd0;
        @(negedge clk); vin = 0;
        // (ilk eleman akisin parcasi: alici sirayla sayar; bu yuzden asagida 1'den baslatilir)
        for (gonder = 1; gonder < ntest; gonder = gonder + 1) begin
            @(negedge clk);
            if (({$random} % 5) == 0) begin vin = 0; @(negedge clk); end    // rastgele bosluk
            vin = 1; acc = memA[gonder]; m0 = memM[gonder][30:0]; n = memN[gonder][5:0]; meta_in = gonder;
        end
        @(negedge clk); vin = 0;
        repeat (10) @(posedge clk);
        $display("----------------------------------------------");
        $display("boru hatti gecikmesi: 3 cevrim (A1 carp, A2 yuvarla, A3 kaydir+kirp); kirpilan eleman: %0d; sira hatasi: %0d",
                 kirp_say, sirasiz);
        if (errors == 0 && alinan == ntest)
            $display("YENIDEN OLCEKLE TEST: PASS  (%0d kontrol, 0 hata)", ntest);
        else
            $display("YENIDEN OLCEKLE TEST: FAIL  (alinan %0d/%0d, %0d hata)", alinan, ntest, errors);
        $finish;
    end
endmodule
