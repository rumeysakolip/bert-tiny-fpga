// tb_hizlandirici.v -- host-in-the-loop (benzetim arka ucu): komut dosyasini bayt bayt surer, yanitlari dosyaya yazar.
// Komut dosyasi (+scr=komut.hex): her satir 3 hane hex = {tip[11:8], deger[7:0]}
//   tip 0: bayt gonder (rx)      tip 1: paket sonu -> yanit tamamlanana kadar bekle (dur-ve-bekle)
//   tip 2: pan_bos[deger]=1 olana kadar bekle    tip 3: layer_done (kilitli) olana kadar bekle
//   tip 4: betik sonu
// Yanit (+out=yanit.hex): tx baytlari, satir basina 2 hane hex.  Gercek kartta tip 2/3, DURUM sorgusu (0x06) ile yapilir.
`timescale 1ns/1ps
module tb_hizlandirici;
    parameter SCR_N = 1048576;
    // +scr/+out/+gold verilmezse (Vivado GUI) varsayilan: l0_q katmani, 70 paket (2 kasitli hatali). Yollari bu bilgisayara gore yazildi.
    parameter SCR_V  = "C:/Users/rumey/Documents/biitirme-projem/03-RTL/sim/g9_q_komut.hex";
    parameter OUT_V  = "C:/Users/rumey/Documents/biitirme-projem/03-RTL/sim/vivado_g9_q_yanit.hex";
    parameter GOLD_V = "C:/Users/rumey/Documents/biitirme-projem/03-RTL/sim/g9_q_yanit.hex";   // Icarus kosusunun yaniti; Python bunu altin modelle 0 fark dogruladi
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg        rx_valid = 0;
    reg  [7:0] rx_data = 0;
    wire       tx_valid, tx_bos;
    wire [7:0] tx_data;
    wire [15:0] paket_sayisi, hata_sayisi;

    hizlandirici_ust dut (.clk(clk), .rst(rst), .rx_valid(rx_valid), .rx_data(rx_data),
        .tx_valid(tx_valid), .tx_data(tx_data), .tx_ready(1'b1), .tx_bos(tx_bos),
        .paket_sayisi(paket_sayisi), .hata_sayisi(hata_sayisi));

    reg [11:0] scr [0:SCR_N-1];
    reg [255*8:1] yol_scr, yol_out, yol_gold;
    reg [7:0] gold [0:65535];
    integer gold_hata, gold_var;
    integer fo, i, n, cyc, bayt_say, yanit_say, tip, val, bekle_say;

    always @(posedge clk) cyc <= cyc + 1;
    always @(posedge clk) if (tx_valid) begin
        $fdisplay(fo, "%02x", tx_data);
        if (gold_var && tx_data !== gold[yanit_say]) begin gold_hata = gold_hata + 1; if (gold_hata < 6) $display("  FARK yanit bayti %0d: rtl=%02x beklenen=%02x", yanit_say, tx_data, gold[yanit_say]); end
        yanit_say = yanit_say + 1;
    end

    initial begin
        cyc = 0; bayt_say = 0; yanit_say = 0;
        if (!$value$plusargs("scr=%s", yol_scr))  yol_scr  = SCR_V;
        if (!$value$plusargs("out=%s", yol_out))  yol_out  = OUT_V;
        gold_var = 0; gold_hata = 0;
        if (!$value$plusargs("gold=%s", yol_gold)) yol_gold = GOLD_V;
        if (yol_gold != "none") begin $readmemh(yol_gold, gold); gold_var = 1; end
        $display("BILGI: komut dosyasi=%0s", yol_scr);
        for (i = 0; i < SCR_N; i = i + 1) scr[i] = 12'h400;
        $readmemh(yol_scr, scr);
        fo = $fopen(yol_out, "w");
        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat (3) @(posedge clk);
        i = 0; tip = 0;
        while (tip != 4) begin
            tip = scr[i][11:8]; val = scr[i][7:0];
            case (tip)
                0: begin @(negedge clk); rx_valid = 1; rx_data = val; @(negedge clk); rx_valid = 0; bayt_say = bayt_say + 1; end
                1: begin bekle_say = 0; repeat (3) @(posedge clk);
                         while (!tx_bos && bekle_say < 200000) begin @(posedge clk); bekle_say = bekle_say + 1; end
                         repeat (2) @(posedge clk);
                         if (bekle_say >= 200000) begin $display("ZAMAN ASIMI: yanit gelmedi (satir %0d)", i); tip = 4; end
                   end
                2: begin bekle_say = 0; while (!dut.u_cd.pan_bos[val] && bekle_say < 5000000) begin @(posedge clk); bekle_say = bekle_say + 1; end
                         if (bekle_say >= 5000000) begin $display("ZAMAN ASIMI: pan_bos[%0d]", val); tip = 4; end
                   end
                3: begin bekle_say = 0; while (!dut.u_cd.layer_done_lat && bekle_say < 20000000) begin @(posedge clk); bekle_say = bekle_say + 1; end
                         if (bekle_say >= 20000000) begin $display("ZAMAN ASIMI: layer_done"); tip = 4; end
                   end
                default: ;
            endcase
            i = i + 1;
        end
        repeat (10) @(posedge clk);
        $fclose(fo);
        $display("HIZLANDIRICI TB BITTI: cevrim=%0d gonderilen_bayt=%0d yanit_bayt=%0d paket=%0d hata=%0d",
                 cyc, bayt_say, yanit_say, paket_sayisi, hata_sayisi);
        if (gold_var) begin
            if (gold_hata == 0 && yanit_say == 8337) $display("HIZLANDIRICI YANIT KARSILASTIRMA: PASS  (%0d yanit bayti beklenenle ayni, 0 fark)", yanit_say);
            else $display("HIZLANDIRICI YANIT KARSILASTIRMA: FAIL  (%0d fark, yanit_bayt=%0d)", gold_hata, yanit_say);
        end
        $finish;
    end
endmodule
