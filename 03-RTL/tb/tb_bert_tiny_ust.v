// tb_bert_tiny_ust.v -- bert_tiny_ust (Softmax + LayerNorm komutlari) bayt/UART arayuzunden surulur, cikti vektorlerle bit bit karsilastirilir (G13)
// Vektorler: tb/vektor_g11 (G11 ile ayni: sm_*.mem, ln_*.mem). Komutlar komut_cozucu.v basligindaki 0x08-0x11 paketleridir.
// Akis (her satir): [SM] SM_CFG, SM_BASLAT, SM_VERI, DURUM sorgula (hazir & !busy), SM_OKU -> karsilastir
//                   [LN] (ornek degisince) LN_PAR, LN_CFG, LN_BASLAT, LN_VERI, DURUM sorgula, LN_OKU -> karsilastir
// Ek denetimler: bozuk CRC -> HATA 1 (ve uygulanmaz), bilinmeyen komut -> HATA 2, uzunluk hatasi -> HATA 3,
//                akis ortasinda CRC hatasi sonrasi BASLAT ile kurtarma, hazir olmayan birime veri -> DURUM bit7, ofsetli OKU.
// Calistirma (Icarus, cwd = 03-RTL):  iverilog -g2001 -o sim/tb_bert_tiny_ust.vvp <rtl/*.v> tb/tb_bert_tiny_ust.v ; vvp sim/tb_bert_tiny_ust.vvp
//   +vdir=<klasor>  vektor klasoru (varsayilan tb/vektor_g11; bulunamazsa "." -- Vivado'da .mem dosyalari Simulation Sources'a eklenirse xsim klasorune kopyalanir)
//   +smrows=N +lnrows=N  satir sayisini sinirla (varsayilan hepsi)    parameter UART=1: gercek UART bit akisi (yavas; az satirla kullanin)
`timescale 1ns/1ps
module tb_bert_tiny_ust;
    parameter UART = 0;                                   // 0: bert_tiny_ust bayt portlari, 1: bert_tiny_uart_ust pinleri
    parameter CPB  = 109;                                 // UART modunda bit basina saat
    parameter L = 64, N = 128;
    parameter VDIR_VARSAYILAN = "tb/vektor_g11";
    parameter MAXSM = 512, MAXLN = 600;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg        rx_valid = 0;
    reg  [7:0] rx_data = 0;
    reg        uart_rx_pin = 1;
    wire       rsp_valid;
    wire [7:0] rsp_data;
    // beyaz kutu gozlemi (yalniz bayt modu): komut_cozucu'nun sabit tuttugu yapilandirma yazmaclari; UART modunda x
    wire [23:0] gorunen_softmax_olcek_m0;
    wire [39:0] gorunen_layernorm_epsilon;
    wire [30:0] gorunen_layernorm_olcek_m0;
    wire [5:0]  gorunen_layernorm_kaydirma;

    generate
        if (UART == 0) begin : g_bayt
            wire tx_bos; wire [15:0] ps, hs;
            bert_tiny_ust dut (.clk(clk), .rst(rst), .rx_valid(rx_valid), .rx_data(rx_data),
                .tx_valid(rsp_valid), .tx_data(rsp_data), .tx_ready(1'b1), .tx_bos(tx_bos), .paket_sayisi(ps), .hata_sayisi(hs));
            assign gorunen_softmax_olcek_m0 = dut.u_veri_yolu.softmax_olcek_m0; assign gorunen_layernorm_epsilon = dut.u_veri_yolu.layernorm_epsilon; assign gorunen_layernorm_olcek_m0 = dut.u_veri_yolu.layernorm_olcek_m0; assign gorunen_layernorm_kaydirma = dut.u_veri_yolu.layernorm_olcek_kaydirma;
        end else begin : g_uart
            wire uart_tx_pin;
            assign gorunen_softmax_olcek_m0 = 24'bx; assign gorunen_layernorm_epsilon = 40'bx; assign gorunen_layernorm_olcek_m0 = 31'bx; assign gorunen_layernorm_kaydirma = 6'bx;
            bert_tiny_uart_ust #(.CLKS_PER_BIT(CPB)) dut (.clk(clk), .rst(rst), .uart_rx_pin(uart_rx_pin), .uart_tx_pin(uart_tx_pin));
            uart_alici #(.CLKS_PER_BIT(CPB)) mon (.clk(clk), .rst(rst), .rx(uart_tx_pin), .gecerli(rsp_valid), .veri(rsp_data));
        end
    endgenerate

    // ---- vektorler ----
    reg [31:0] mSkor [0:MAXSM*L-1];
    reg [31:0] mMask [0:MAXSM*L-1];
    reg [31:0] mCikS [0:MAXSM*L-1];
    reg [31:0] mM0   [0:MAXSM-1];
    reg [31:0] mLut  [0:511];
    reg [31:0] mMetaS [0:1];
    reg [31:0] mQ    [0:MAXLN*N-1];
    reg [31:0] mCikL [0:MAXLN*N-1];
    reg [31:0] mOrn  [0:MAXLN-1];
    reg [31:0] mGam  [0:16*N-1];
    reg [31:0] mBet  [0:16*N-1];
    reg [31:0] mPar  [0:16*3-1];
    reg [31:0] mMetaL [0:2];
    reg [255*8:1] vdir, yol;
    integer fd, nsm, nln, nornek, smrows, lnrows;

    // ---- sayaclar ----
    integer hata, kontrol, sm_kontrol, ln_kontrol, cyc, gonderilen, alinan;
    always @(posedge clk) cyc <= cyc + 1;

    // ---- paket / yanit ----
    reg [7:0] pk [0:2047];
    reg [7:0] rsp [0:2047];
    integer rsp_n;
    reg [7:0] dur0, dur1;
    always @(posedge clk) if (rsp_valid) begin
        if (rsp_n < 2048) rsp[rsp_n] = rsp_data;
        rsp_n = rsp_n + 1; alinan = alinan + 1;
    end

    function [7:0] crc8;
        input [7:0] c;
        input [7:0] d;
        reg [7:0] x;
        integer b;
        begin
            x = c ^ d;
            for (b = 0; b < 8; b = b + 1) x = x[7] ? ((x << 1) ^ 8'h07) : (x << 1);
            crc8 = x;
        end
    endfunction

    task bayt_yolla;
        input [7:0] b;
        integer k;
        begin
            gonderilen = gonderilen + 1;
            if (UART == 0) begin
                @(negedge clk); rx_valid = 1; rx_data = b;
                @(negedge clk); rx_valid = 0;
            end else begin
                uart_rx_pin = 0; repeat (CPB) @(posedge clk);
                for (k = 0; k < 8; k = k + 1) begin uart_rx_pin = b[k]; repeat (CPB) @(posedge clk); end
                uart_rx_pin = 1; repeat (CPB) @(posedge clk);
            end
        end
    endtask

    // pk[0..n-1] yukunu cmd ile paketleyip yollar (bozuk=1: CRC bozulur)
    task paket_yolla;
        input [7:0] cmd;
        input integer n;
        input bozuk;
        integer k;
        reg [7:0] c;
        begin
            rsp_n = 0;
            bayt_yolla(cmd);        c = crc8(8'd0, cmd);
            bayt_yolla(n[7:0]);     c = crc8(c, n[7:0]);
            bayt_yolla(n[15:8]);    c = crc8(c, n[15:8]);
            for (k = 0; k < n; k = k + 1) begin bayt_yolla(pk[k]); c = crc8(c, pk[k]); end
            bayt_yolla(bozuk ? (c ^ 8'h5A) : c);
        end
    endtask

    // yanitin n bayta ulasmasini bekle, sonra fazladan bayt gelmedigini denetle
    task bekle;
        input integer n;
        integer t;
        begin
            t = 0;
            while (rsp_n < n && t < 3000000) begin @(posedge clk); t = t + 1; end
            repeat (UART ? 3000 : 20) @(posedge clk);
            if (rsp_n != n) begin
                hata = hata + 1;
                $display("  HATA: yanit uzunlugu %0d, beklenen %0d", rsp_n, n);
            end
        end
    endtask

    task say;                               // bir kontrol sayar; kosul sifirsa hata
        input kosul;
        input [8*50:1] ad;
        begin
            kontrol = kontrol + 1;
            if (!kosul) begin hata = hata + 1; if (hata < 12) $display("  HATA: %0s", ad); end
        end
    endtask

    task ack_dene;                          // paket gonder, ACK bekle
        input [7:0] cmd;
        input integer n;
        begin
            paket_yolla(cmd, n, 1'b0);
            bekle(2);
            say(rsp[0] === 8'h06 && rsp[1] === cmd, "ACK bekleniyordu");
        end
    endtask

    task hata_dene;                         // paket gonder, HATA(kod) bekle
        input [7:0] cmd;
        input integer n;
        input bozuk;
        input [7:0] kod;
        begin
            paket_yolla(cmd, n, bozuk);
            bekle(3);
            say(rsp[0] === 8'h15 && rsp[1] === cmd && rsp[2] === kod, "HATA kodu beklenenden farkli");
        end
    endtask

    task oku_dene;                          // *_OKU: adres/adet; yanit rsp[4..4+adet-1]
        input [7:0] cmd;
        input integer adr;
        input integer adet;
        reg [7:0] c;
        integer k;
        begin
            pk[0] = adr[7:0]; pk[1] = adr[15:8]; pk[2] = adet[7:0]; pk[3] = adet[15:8];
            paket_yolla(cmd, 4, 1'b0);
            bekle(adet + 5);
            c = crc8(8'd0, rsp[1]);
            for (k = 2; k < adet + 4; k = k + 1) c = crc8(c, rsp[k]);
            say(rsp[0] === 8'h02 && rsp[1] === cmd && rsp[2] === adet[7:0] && rsp[3] === adet[15:8], "VERI basligi");
            say(rsp[adet + 4] === c, "VERI crc");
        end
    endtask

    task durum_oku;                         // DURUM: dur0/dur1
        reg [7:0] c;
        begin
            paket_yolla(8'h06, 0, 1'b0);
            bekle(7);
            c = crc8(8'd0, rsp[1]); c = crc8(c, rsp[2]); c = crc8(c, rsp[3]); c = crc8(c, rsp[4]); c = crc8(c, rsp[5]);
            say(rsp[0] === 8'h02 && rsp[1] === 8'h06 && rsp[2] === 8'h02 && rsp[3] === 8'h00 && rsp[6] === c, "DURUM yaniti");
            dur0 = rsp[4]; dur1 = rsp[5];
        end
    endtask

    task hazir_bekle;                       // birim: 0 Softmax (busy b3, hazir b5), 1 LayerNorm (busy b4, hazir b6)
        input birim;
        integer t;
        reg bitti;
        begin
            t = 0; bitti = 0;
            while (!bitti && t < 5000) begin
                durum_oku;
                bitti = birim ? (dur0[6] && !dur0[4]) : (dur0[5] && !dur0[3]);
                t = t + 1;
            end
            say(bitti, "birim hazir olmadi");
        end
    endtask

    // ---- Softmax satiri ----
    integer i, r, j, e;
    task sm_cfg_yolla;
        input [23:0] m0v;
        begin pk[0] = m0v[7:0]; pk[1] = m0v[15:8]; pk[2] = m0v[23:16]; ack_dene(8'h09, 3); end
    endtask
    task sm_veri_yolla;                     // satir r, elemanlar [bas, bit) -> SM_VERI paketi
        input integer r_;
        input integer bas;
        input integer son;
        input bozuk;
        integer k, p;
        begin
            p = 0;
            for (k = bas; k < son; k = k + 1) begin
                pk[p] = mSkor[r_*L+k][7:0]; pk[p+1] = mSkor[r_*L+k][15:8]; pk[p+2] = mSkor[r_*L+k][23:16]; pk[p+3] = mSkor[r_*L+k][31:24];
                pk[p+4] = {7'd0, mMask[r_*L+k][0]}; p = p + 5;
            end
            if (bozuk) hata_dene(8'h0B, p, 1'b1, 8'd1); else ack_dene(8'h0B, p);
        end
    endtask
    task sm_satir;
        input integer r_;
        integer h0, k;
        begin
            h0 = hata;
            sm_cfg_yolla(mM0[r_][23:0]);
            if (r_ == 0) begin                                        // bozuk CRC'li CFG uygulanmamali (olcek_m0 degismemeli)
                pk[0] = 8'h56; pk[1] = 8'h34; pk[2] = 8'h12; hata_dene(8'h09, 3, 1'b1, 8'd1);
            end
            if (r_ == 1) begin                                        // akis ortasinda CRC hatasi -> BASLAT ile kurtarma
                ack_dene(8'h0A, 0);
                sm_veri_yolla(r_, 0, 20, 1'b0);
                sm_veri_yolla(r_, 20, 40, 1'b1);
            end
            ack_dene(8'h0A, 0);
            sm_veri_yolla(r_, 0, L, 1'b0);
            hazir_bekle(0);
            if (r_ == 2) begin                                        // ofsetli okuma
                oku_dene(8'h0C, 10, 20);
                for (k = 0; k < 20; k = k + 1) begin
                    kontrol = kontrol + 1; sm_kontrol = sm_kontrol + 1;
                    if (rsp[4+k] !== mCikS[r_*L + 10 + k][7:0]) begin hata = hata + 1; if (hata < 12) $display("  HATA SM satir %0d ofsetli eleman %0d: rtl=%0d beklenen=%0d", r_, 10+k, rsp[4+k], mCikS[r_*L+10+k][7:0]); end
                end
            end
            oku_dene(8'h0C, 0, L);
            for (k = 0; k < L; k = k + 1) begin
                kontrol = kontrol + 1; sm_kontrol = sm_kontrol + 1;
                if (rsp[4+k] !== mCikS[r_*L + k][7:0]) begin
                    hata = hata + 1;
                    if (hata < 12) $display("  HATA SM satir %0d eleman %0d: rtl=%0d beklenen=%0d", r_, k, rsp[4+k], mCikS[r_*L+k][7:0]);
                end
            end
        end
    endtask

    // ---- LayerNorm satiri ----
    task ln_par_yolla;
        input integer orn;
        integer k, p;
        begin
            pk[0] = 8'd0; pk[1] = 8'd0; p = 2;
            for (k = 0; k < N; k = k + 1) begin
                pk[p] = mGam[orn*N+k][7:0]; pk[p+1] = mGam[orn*N+k][15:8]; pk[p+2] = mBet[orn*N+k][7:0]; pk[p+3] = mBet[orn*N+k][15:8]; p = p + 4;
            end
            ack_dene(8'h0D, p);
        end
    endtask
    task ln_cfg_yolla;
        input integer orn;
        reg [39:0] eps; reg [30:0] m0v; reg [5:0] olcek_kaydirma;
        begin
            eps = mPar[orn*3]; m0v = mPar[orn*3+1][30:0]; olcek_kaydirma = mPar[orn*3+2][5:0];
            pk[0] = eps[7:0]; pk[1] = eps[15:8]; pk[2] = eps[23:16]; pk[3] = eps[31:24]; pk[4] = eps[39:32];
            pk[5] = m0v[7:0]; pk[6] = m0v[15:8]; pk[7] = m0v[23:16]; pk[8] = {1'b0, m0v[30:24]}; pk[9] = {2'b00, olcek_kaydirma};
            ack_dene(8'h0E, 10);
        end
    endtask
    task ln_veri_yolla;
        input integer r_;
        integer k, p;
        begin
            p = 0;
            for (k = 0; k < N; k = k + 1) begin
                pk[p] = mQ[r_*N+k][7:0]; pk[p+1] = mQ[r_*N+k][15:8]; pk[p+2] = mQ[r_*N+k][23:16]; p = p + 3;
            end
            ack_dene(8'h10, p);
        end
    endtask
    integer onceki;
    task ln_satir;
        input integer r_;
        integer orn, k;
        begin
            orn = mOrn[r_];
            if (orn != onceki) begin ln_par_yolla(orn); onceki = orn; end
            ln_cfg_yolla(orn);
            if (r_ == 0) begin                                        // bozuk CRC'li CFG uygulanmamali
                for (k = 0; k < 10; k = k + 1) pk[k] = 8'h77;
                hata_dene(8'h0E, 10, 1'b1, 8'd1);
            end
            ack_dene(8'h0F, 0);
            ln_veri_yolla(r_);
            hazir_bekle(1);
            if (r_ == 2) begin                                        // ofsetli okuma
                oku_dene(8'h11, 100, 28);
                for (k = 0; k < 28; k = k + 1) begin
                    kontrol = kontrol + 1; ln_kontrol = ln_kontrol + 1;
                    if (rsp[4+k] !== mCikL[r_*N + 100 + k][7:0]) begin hata = hata + 1; if (hata < 12) $display("  HATA LN satir %0d ofsetli eleman %0d: rtl=%0d beklenen=%0d", r_, 100+k, $signed(rsp[4+k]), $signed(mCikL[r_*N+100+k][7:0])); end
                end
            end
            oku_dene(8'h11, 0, N);
            for (k = 0; k < N; k = k + 1) begin
                kontrol = kontrol + 1; ln_kontrol = ln_kontrol + 1;
                if (rsp[4+k] !== mCikL[r_*N + k][7:0]) begin
                    hata = hata + 1;
                    if (hata < 12) $display("  HATA LN satir %0d eleman %0d: rtl=%0d beklenen=%0d", r_, k, $signed(rsp[4+k]), $signed(mCikL[r_*N+k][7:0]));
                end
            end
        end
    endtask

    // ---- ana akis ----
    initial begin
        hata = 0; kontrol = 0; sm_kontrol = 0; ln_kontrol = 0; cyc = 0; gonderilen = 0; alinan = 0; rsp_n = 0; onceki = -1;
        dur0 = 0; dur1 = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = VDIR_VARSAYILAN;
        $sformat(yol, "%0s/sm_meta.mem", vdir); fd = $fopen(yol, "r");
        if (fd == 0) begin vdir = "."; $display("BILGI: vektor klasoru bulunamadi, '.' deneniyor"); end
        else $fclose(fd);
        $display("BILGI: vektor klasoru=%0s  mod=%0s", vdir, UART ? "UART" : "BAYT");
        $sformat(yol, "%0s/sm_meta.mem", vdir);  $readmemh(yol, mMetaS); nsm = mMetaS[0];
        $sformat(yol, "%0s/sm_skor.mem", vdir);  $readmemh(yol, mSkor);
        $sformat(yol, "%0s/sm_mask.mem", vdir);  $readmemh(yol, mMask);
        $sformat(yol, "%0s/sm_cikis.mem", vdir); $readmemh(yol, mCikS);
        $sformat(yol, "%0s/sm_m0.mem", vdir);    $readmemh(yol, mM0);
        $sformat(yol, "%0s/sm_lut.mem", vdir);   $readmemh(yol, mLut);
        $sformat(yol, "%0s/ln_meta.mem", vdir);  $readmemh(yol, mMetaL); nln = mMetaL[0]; nornek = mMetaL[2];
        $sformat(yol, "%0s/ln_q.mem", vdir);     $readmemh(yol, mQ);
        $sformat(yol, "%0s/ln_cikis.mem", vdir); $readmemh(yol, mCikL);
        $sformat(yol, "%0s/ln_ornek.mem", vdir); $readmemh(yol, mOrn);
        $sformat(yol, "%0s/ln_gamma.mem", vdir); $readmemh(yol, mGam);
        $sformat(yol, "%0s/ln_beta.mem", vdir);  $readmemh(yol, mBet);
        $sformat(yol, "%0s/ln_par.mem", vdir);   $readmemh(yol, mPar);
        smrows = nsm; lnrows = nln;
        if ($value$plusargs("smrows=%d", i)) smrows = i;
        if ($value$plusargs("lnrows=%d", i)) lnrows = i;
        if (smrows > nsm) smrows = nsm;
        if (lnrows > nln) lnrows = nln;

        repeat (4) @(posedge clk); @(negedge clk); rst = 0;
        repeat (10) @(posedge clk);

        // --- protokol hata denetimleri ---
        pk[0] = 8'd0; hata_dene(8'h7E, 0, 1'b0, 8'd2);                   // bilinmeyen komut
        hata_dene(8'h12, 0, 1'b0, 8'd2);                                  // ilk atanmamis komut
        hata_dene(8'h0A, 0, 1'b1, 8'd1);                                  // bozuk CRC'li BASLAT: baslamamali
        durum_oku; say(dur0[3] === 1'b0 && dur0[4] === 1'b0 && dur0[7] === 1'b0, "bozuk BASLAT birimi baslatmamali");
        hata_dene(8'h0F, 0, 1'b1, 8'd1);
        durum_oku; say(dur0[3] === 1'b0 && dur0[4] === 1'b0 && dur0[7] === 1'b0, "bozuk LN BASLAT birimi baslatmamali");
        pk[0] = 8'd1; hata_dene(8'h09, 1, 1'b0, 8'd3);                    // SM_CFG: yuk kisa (3 bayt gerekir)
        pk[0] = 8'd0; pk[1] = 8'd0; pk[2] = 8'd0; pk[3] = 8'd0; pk[4] = 8'd0;
        hata_dene(8'h0B, 4, 1'b0, 8'd3);                                  // SM_VERI: yarim eleman
        hata_dene(8'h10, 2, 1'b0, 8'd3);                                  // LN_VERI: yarim eleman
        pk[0] = 8'd0; pk[1] = 8'd0; pk[2] = 8'd65; pk[3] = 8'd0; hata_dene(8'h0C, 4, 1'b0, 8'd3);   // SM_OKU: 65 bayt > 64
        pk[0] = 8'd100; pk[1] = 8'd0; pk[2] = 8'd29; pk[3] = 8'd0; hata_dene(8'h11, 4, 1'b0, 8'd3); // LN_OKU: 100+29 > 128
        durum_oku; say(dur0[2:0] === 3'b000 && dur1[3:0] === 4'b0011, "eski DURUM bitleri bozulmamali");

        // --- yapilandirma alanlarinin tum bitleri (vektorlerdeki degerler kucuk oldugundan ust bitleri ayrica sinanir) ---
        sm_cfg_yolla(24'hA5C3E1);
        if (UART == 0) say(gorunen_softmax_olcek_m0 === 24'hA5C3E1, "SM_CFG olcek_m0 24 bit");
        pk[0] = 8'h96; pk[1] = 8'h1E; pk[2] = 8'h4B; pk[3] = 8'h2D; pk[4] = 8'hC3;
        pk[5] = 8'h5A; pk[6] = 8'h5A; pk[7] = 8'h5A; pk[8] = 8'h5A; pk[9] = 8'h2B;
        ack_dene(8'h0E, 10);
        if (UART == 0) say(gorunen_layernorm_epsilon === 40'hC32D4B1E96 && gorunen_layernorm_olcek_m0 === 31'h5A5A5A5A && gorunen_layernorm_kaydirma === 6'h2B, "LN_CFG eps/olcek_m0/nsh alanlari");

        // --- Softmax ---
        pk[0] = 8'd0; pk[1] = 8'd0;
        for (i = 0; i < 512; i = i + 1) begin pk[2+2*i] = mLut[i][7:0]; pk[3+2*i] = mLut[i][15:8]; end
        ack_dene(8'h08, 1026);
        for (r = 0; r < smrows; r = r + 1) sm_satir(r);
        // hazir olmayan birime veri: eleman atilir, DURUM bit7; BASLAT bayragi siler
        pk[0] = 8'd1; pk[1] = 8'd0; pk[2] = 8'd0; pk[3] = 8'd0; pk[4] = 8'd1;
        ack_dene(8'h0B, 5);
        durum_oku; say(dur0[7] === 1'b1, "hazir olmayan birime veri: bit7 yukselmeli");
        ack_dene(8'h0A, 0);
        durum_oku; say(dur0[7] === 1'b0 && dur0[3] === 1'b1, "BASLAT: bit7 silinmeli, birim yuk bekler");

        // --- LayerNorm ---
        for (r = 0; r < lnrows; r = r + 1) ln_satir(r);
        pk[0] = 8'd1; pk[1] = 8'd0; pk[2] = 8'd0;
        ack_dene(8'h10, 3);
        durum_oku; say(dur0[7] === 1'b1, "LN: hazir olmayan birime veri: bit7 yukselmeli");
        ack_dene(8'h0F, 0);
        durum_oku; say(dur0[7] === 1'b0 && dur0[4] === 1'b1, "LN BASLAT: bit7 silinmeli, birim yuk bekler");

        $display("SOFTMAX: %0d satir, %0d cikis bayt karsilastirildi", smrows, sm_kontrol);
        $display("LAYERNORM: %0d satir, %0d cikis bayt karsilastirildi", lnrows, ln_kontrol);
        $display("BILGI: cevrim=%0d gonderilen_bayt=%0d alinan_bayt=%0d", cyc, gonderilen, alinan);
        $display("BERT_TINY_UST TEST: %s (%0d kontrol, %0d hata)", (hata == 0) ? "PASS" : "FAIL", kontrol, hata);
        $finish;
    end

    // guvenlik: kilitlenmeye karsi
    initial begin
        #2000000000;
        $display("ZAMAN ASIMI: testbench kilitlendi");
        $display("BERT_TINY_UST TEST: FAIL (%0d kontrol, %0d hata)", kontrol, hata + 1);
        $finish;
    end
endmodule
