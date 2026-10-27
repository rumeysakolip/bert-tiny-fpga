// -----------------------------------------------------------------------------
// komut_cozucu.v -- host<->hizlandirici paket protokolu (bayt akisi) (G9)
//
// Istek paketi : cmd(1) len(2, LE) payload(len) crc8(1)      crc8: poly 0x07, init 0, cmd+len+payload uzerinden
// Yanit        : ACK  = 0x06 cmd
//                HATA = 0x15 cmd kod      (kod 1 = CRC, 2 = bilinmeyen komut, 3 = uzunluk hatali)
//                VERI = 0x02 cmd lenLo lenHi veri... crc8   (crc cmd+len+veri uzerinden)
// Komutlar (payload):
//   0x01 CFG          K(2) np(1) n(1) bayrak(1: bit0 a_isaretsiz, bit1 gelu_en)    [CRC dogruysa uygulanir]
//   0x02 YUKLE_AKT    adres(2, sozcuk) + 8 bayt/sozcuk (bayt0 = en dusuk)           [yazma CRC'den ONCE uygulanir]
//   0x03 YUKLE_PANEL  buf(1) sel(1: 0 W, 1 bias, 2 m0, 3 LUT) adres(2) + veri: sel0 8 B/sozcuk, sel1/2 4 B, sel3 1 B
//   0x04 CALISTIR     (bos)                                                        [CRC dogruysa kos darbesi]
//   0x05 OKU_AKT      adres(2) adet(2) -> VERI: adet*8 bayt (cikis BRAM sozcukleri)
//   0x06 DURUM        (bos) -> VERI 2 bayt: [0]={..,tasma,layer_done,busy} [1]={..,hazir1,hazir0,bos1,bos0}
//   0x07 PANEL_HAZIR  buf(1)  -> tampon dolu isaretlenir, bos bayragi silinir
// Dur-ve-bekle: host bir yanit tamamlanmadan yeni paket gondermez. Yazma komutlari idempotenttir; HATA
// alinirsa host ayni paketi yeniden gonderir (CRC'siz kismi yazmalar ustune yazilir).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module komut_cozucu (
    input  wire         clk,
    input  wire         rst,
    input  wire         rx_valid,
    input  wire [7:0]   rx_data,
    output reg          tx_valid,
    output reg  [7:0]   tx_data,
    input  wire         tx_ready,
    output wire         tx_bos,
    // hizlandirici denetimi
    output reg          kos,
    output reg  [10:0]  cfg_k,
    output reg  [6:0]   cfg_np,
    output reg  [5:0]   cfg_n,
    output reg          a_isaretsiz,
    output reg          gelu_en,
    input  wire         busy,
    input  wire         layer_done,
    input  wire         tasma_hata,
    input  wire         pan_bitti,
    input  wire         pan_bitti_buf,
    output reg          aw_en,
    output reg  [11:0]  aw_addr,
    output reg  [63:0]  aw_data,
    output reg          pw_en,
    output reg          pw_buf,
    output reg  [1:0]   pw_sel,
    output reg  [10:0]  pw_addr,
    output reg  [63:0]  pw_data,
    output reg  [1:0]   pan_hazir,
    output reg          lw_en,
    output reg  [7:0]   lw_addr,
    output reg  [7:0]   lw_data,
    output reg  [11:0]  cr_addr,
    input  wire [63:0]  cr_data,
    output reg  [1:0]   pan_bos,
    // tanilama
    output reg  [15:0]  paket_sayisi,
    output reg  [15:0]  hata_sayisi
);
    localparam C_CFG = 8'h01, C_AKT = 8'h02, C_PAN = 8'h03, C_RUN = 8'h04, C_OKU = 8'h05, C_DUR = 8'h06, C_HAZ = 8'h07;
    localparam P_CMD = 3'd0, P_L0 = 3'd1, P_L1 = 3'd2, P_DATA = 3'd3, P_CRC = 3'd4;

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

    // ---- istek ayristirma ----
    reg [2:0]   ps;
    reg [7:0]   cmd, crc;
    reg [15:0]  plen, pcnt;
    reg [7:0]   h0, h1, h2, h3, h4;
    reg [63:0]  wacc;
    reg [3:0]   wbyte;
    reg [15:0]  waddr;
    reg         layer_done_lat, tasma_lat;

    function [3:0] hdr_n;
        input [7:0] c;
        case (c)
            C_CFG: hdr_n = 4'd5; C_AKT: hdr_n = 4'd2; C_PAN: hdr_n = 4'd4;
            C_OKU: hdr_n = 4'd4; C_HAZ: hdr_n = 4'd1; default: hdr_n = 4'd0;
        endcase
    endfunction
    wire [3:0] hn = hdr_n(cmd);
    wire [3:0] wgen = (cmd == C_AKT) ? 4'd8 :
                      (cmd == C_PAN) ? ((h1 == 8'd0) ? 4'd8 : (h1 == 8'd3) ? 4'd1 : 4'd4) : 4'd8;

    // yanit istegi
    reg         rq;                  // yanit baslat
    reg [1:0]   rq_tur;              // 0 ACK, 1 HATA, 2 VERI
    reg [7:0]   rq_cmd, rq_kod;
    reg [15:0]  rq_len;
    reg [11:0]  rq_adr;
    reg [15:0]  rq_adet;
    reg [7:0]   rq_b0, rq_b1;
    reg         resp_aktif;
    assign tx_bos = !resp_aktif && !rq && !tx_valid;

    function cmd_gecerli;
        input [7:0] c;
        cmd_gecerli = (c == C_CFG) || (c == C_AKT) || (c == C_PAN) || (c == C_RUN) || (c == C_OKU) || (c == C_DUR) || (c == C_HAZ);
    endfunction

    wire [7:0] wb = rx_data;
    wire [63:0] wnext = wacc | ({56'd0, wb} << (8 * wbyte));

    always @(posedge clk) begin
        if (rst) begin
            ps <= P_CMD; cmd <= 8'd0; crc <= 8'd0; plen <= 16'd0; pcnt <= 16'd0;
            kos <= 1'b0; aw_en <= 1'b0; pw_en <= 1'b0; lw_en <= 1'b0; pan_hazir <= 2'b00; pan_bos <= 2'b11;
            cfg_k <= 11'd0; cfg_np <= 7'd0; cfg_n <= 6'd0; a_isaretsiz <= 1'b0; gelu_en <= 1'b0;
            rq <= 1'b0; layer_done_lat <= 1'b0; tasma_lat <= 1'b0; paket_sayisi <= 16'd0; hata_sayisi <= 16'd0;
            wacc <= 64'd0; wbyte <= 4'd0; waddr <= 16'd0;
            h0 <= 8'd0; h1 <= 8'd0; h2 <= 8'd0; h3 <= 8'd0; h4 <= 8'd0;
        end else begin
            kos <= 1'b0; aw_en <= 1'b0; pw_en <= 1'b0; lw_en <= 1'b0;
            if (resp_aktif) rq <= 1'b0;
            if (layer_done) layer_done_lat <= 1'b1;
            if (tasma_hata) tasma_lat <= 1'b1;
            if (pan_bitti) begin
                pan_hazir[pan_bitti_buf] <= 1'b0; pan_bos[pan_bitti_buf] <= 1'b1;
            end
            if (rx_valid) begin
                case (ps)
                    P_CMD: begin cmd <= rx_data; crc <= crc8(8'd0, rx_data); ps <= P_L0; end
                    P_L0:  begin plen[7:0] <= rx_data; crc <= crc8(crc, rx_data); ps <= P_L1; end
                    P_L1:  begin
                        plen[15:8] <= rx_data; crc <= crc8(crc, rx_data); pcnt <= 16'd0;
                        wacc <= 64'd0; wbyte <= 4'd0;
                        ps <= (plen[7:0] == 8'd0 && rx_data == 8'd0) ? P_CRC : P_DATA;
                    end
                    P_DATA: begin
                        crc <= crc8(crc, rx_data);
                        pcnt <= pcnt + 16'd1;
                        if (pcnt < hn) begin
                            case (pcnt[2:0])
                                3'd0: h0 <= rx_data; 3'd1: h1 <= rx_data; 3'd2: h2 <= rx_data;
                                3'd3: h3 <= rx_data; default: h4 <= rx_data;
                            endcase
                            if (pcnt + 16'd1 == hn) begin               // basligin sonu: adresi yakala
                                if (cmd == C_AKT) waddr <= {rx_data, h0};
                                else if (cmd == C_PAN) waddr <= {rx_data, h2};
                            end
                        end else if (cmd == C_AKT || cmd == C_PAN) begin
                            if (wbyte + 4'd1 == wgen) begin             // sozcuk tamam
                                if (cmd == C_AKT) begin
                                    aw_en <= 1'b1; aw_addr <= waddr[11:0]; aw_data <= wnext;
                                end else begin
                                    pw_en <= 1'b1; pw_buf <= h0[0]; pw_sel <= h1[1:0]; pw_addr <= waddr[10:0]; pw_data <= wnext;
                                    if (h1 == 8'd3) begin lw_en <= 1'b1; lw_addr <= waddr[7:0]; lw_data <= wnext[7:0]; pw_en <= 1'b0; end
                                end
                                waddr <= waddr + 16'd1; wacc <= 64'd0; wbyte <= 4'd0;
                            end else begin
                                wacc <= wnext; wbyte <= wbyte + 4'd1;
                            end
                        end
                        if (pcnt + 16'd1 == plen) ps <= P_CRC;
                    end
                    P_CRC: begin
                        ps <= P_CMD;
                        paket_sayisi <= paket_sayisi + 16'd1;
                        if (!cmd_gecerli(cmd)) begin
                            rq <= 1'b1; rq_tur <= 2'd1; rq_cmd <= cmd; rq_kod <= 8'd2; hata_sayisi <= hata_sayisi + 16'd1;
                        end else if (rx_data != crc) begin
                            rq <= 1'b1; rq_tur <= 2'd1; rq_cmd <= cmd; rq_kod <= 8'd1; hata_sayisi <= hata_sayisi + 16'd1;
                        end else if (plen < hn) begin
                            rq <= 1'b1; rq_tur <= 2'd1; rq_cmd <= cmd; rq_kod <= 8'd3; hata_sayisi <= hata_sayisi + 16'd1;
                        end else begin
                            rq <= 1'b1; rq_tur <= 2'd0; rq_cmd <= cmd;
                            case (cmd)
                                C_CFG: begin cfg_k <= {h1[2:0], h0}; cfg_np <= h2[6:0]; cfg_n <= h3[5:0];
                                             a_isaretsiz <= h4[0]; gelu_en <= h4[1]; end
                                C_RUN: begin kos <= 1'b1; layer_done_lat <= 1'b0; tasma_lat <= 1'b0; end
                                C_HAZ: begin pan_hazir[h0[0]] <= 1'b1; pan_bos[h0[0]] <= 1'b0; end
                                C_OKU: begin rq_tur <= 2'd2; rq_adr <= {h1[3:0], h0}; rq_adet <= {h3, h2};
                                             rq_len <= {h3, h2} * 16'd8; end
                                C_DUR: begin rq_tur <= 2'd2; rq_len <= 16'd2; rq_adet <= 16'd0;
                                             rq_b0 <= {5'd0, tasma_lat, layer_done_lat, busy};
                                             rq_b1 <= {4'd0, pan_hazir, pan_bos}; end
                                default: ;
                            endcase
                        end
                    end
                    default: ps <= P_CMD;
                endcase
            end
        end
    end

    // ---- yanit uretici ----
    localparam R_IDLE = 4'd0, R_B0 = 4'd1, R_B1 = 4'd2, R_B2 = 4'd3, R_B3 = 4'd4, R_DATA = 4'd5,
               R_CRC = 4'd6, R_RD = 4'd7, R_RD2 = 4'd8, R_WORD = 4'd9;
    reg [3:0]  rs;
    reg [1:0]  rtur;
    reg [7:0]  rcmd, rkod, rcrc, rb0, rb1;
    reg [15:0] rlen, ridx, radet, rwi;
    reg [11:0] radr;
    reg [63:0] rword;
    reg [3:0]  rby;

    wire tx_al = tx_valid && tx_ready;
    task yaz;                       // bir bayt sun
        input [7:0] b;
        begin tx_data <= b; tx_valid <= 1'b1; end
    endtask

    always @(posedge clk) begin
        if (rst) begin
            rs <= R_IDLE; tx_valid <= 1'b0; resp_aktif <= 1'b0; tx_data <= 8'd0;
            rtur <= 2'd0; rcmd <= 8'd0; rkod <= 8'd0; rcrc <= 8'd0; rb0 <= 8'd0; rb1 <= 8'd0;
            rlen <= 16'd0; ridx <= 16'd0; radet <= 16'd0; rwi <= 16'd0; radr <= 12'd0; rword <= 64'd0; rby <= 4'd0; cr_addr <= 12'd0;
        end else begin
            if (tx_al) tx_valid <= 1'b0;
            case (rs)
                R_IDLE: if (rq && !resp_aktif) begin
                    resp_aktif <= 1'b1; rtur <= rq_tur; rcmd <= rq_cmd; rkod <= rq_kod; rlen <= rq_len;
                    radr <= rq_adr; radet <= rq_adet; rb0 <= rq_b0; rb1 <= rq_b1; rwi <= 16'd0; ridx <= 16'd0;
                    rs <= R_B0;
                end
                R_B0: if (!tx_valid || tx_al) begin
                    yaz(rtur == 2'd0 ? 8'h06 : rtur == 2'd1 ? 8'h15 : 8'h02); rs <= R_B1;
                end
                R_B1: if (!tx_valid || tx_al) begin
                    yaz(rcmd); rcrc <= crc8(8'd0, rcmd);
                    rs <= (rtur == 2'd0) ? R_IDLE : (rtur == 2'd1) ? R_B2 : R_B2;
                    if (rtur == 2'd0) resp_aktif <= 1'b0;
                end
                R_B2: if (!tx_valid || tx_al) begin
                    if (rtur == 2'd1) begin yaz(rkod); rs <= R_IDLE; resp_aktif <= 1'b0; end
                    else begin yaz(rlen[7:0]); rcrc <= crc8(rcrc, rlen[7:0]); rs <= R_B3; end
                end
                R_B3: if (!tx_valid || tx_al) begin
                    yaz(rlen[15:8]); rcrc <= crc8(rcrc, rlen[15:8]);
                    if (rlen == 16'd0) rs <= R_CRC;
                    else if (radet == 16'd0) rs <= R_DATA;           // DURUM
                    else begin cr_addr <= radr; rs <= R_RD; end        // OKU: ilk sozcuk
                end
                R_DATA: if (!tx_valid || tx_al) begin                  // DURUM: 2 bayt
                    yaz(ridx == 16'd0 ? rb0 : rb1); rcrc <= crc8(rcrc, ridx == 16'd0 ? rb0 : rb1);
                    ridx <= ridx + 16'd1;
                    if (ridx + 16'd1 == rlen) rs <= R_CRC;
                end
                R_RD:  rs <= R_RD2;                                    // BRAM okuma gecikmesi
                R_RD2: begin rword <= cr_data; rby <= 4'd0; rs <= R_WORD; end
                R_WORD: if (!tx_valid || tx_al) begin
                    yaz(rword[7:0]); rcrc <= crc8(rcrc, rword[7:0]); rword <= {8'd0, rword[63:8]};
                    rby <= rby + 4'd1;
                    if (rby == 4'd7) begin
                        rwi <= rwi + 16'd1;
                        if (rwi + 16'd1 == radet) rs <= R_CRC;
                        else begin cr_addr <= radr + rwi[11:0] + 12'd1; rs <= R_RD; end
                    end
                end
                R_CRC: if (!tx_valid || tx_al) begin
                    yaz(rcrc); rs <= R_IDLE; resp_aktif <= 1'b0;
                end
                default: rs <= R_IDLE;
            endcase
        end
    end
endmodule
