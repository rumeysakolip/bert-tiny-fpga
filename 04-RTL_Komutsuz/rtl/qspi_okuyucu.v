// -----------------------------------------------------------------------------
// qspi_okuyucu.v -- seri flastan (S25FL032 sinifi) dort hatli sirali okuma; bayt akisi uretir
//   Komut 0x6B (Quad Output Read): 8 bit komut + 24 bit adres tek hat uzerinden, 8 bosluk (dummy) darbesi,
//   sonra her SCK darbesinde 4 bit (yuksek yarim bayt once); flas adresi kendisi artirir -> tek okuma isleminde butun akis.
//   SCK mod 0 (bosta alcak): flas yükselen kenarda ornekler / alcalan kenarda cikis verir.
//   Alici hazir degilse saat durdurulur. SCK yarim periyodu = BOL sistem saati (BOL=2: SCK = clk/4).
// Kart pinlerinde cift yonlu tampon ve SCK icin STARTUPE2 gerekir (bu modulun disinda, kart asamasi).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module qspi_okuyucu #(
    parameter BOL = 2
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        basla,                 // 1 cevrim darbe (bosta iken)
    input  wire [23:0] adres,
    input  wire [31:0] bayt_sayisi,
    // flas pinleri
    output reg         sck,
    output reg         cs_n,
    output reg         io0_o,
    output wire        io_oe,                 // 1: io0 (komut/adres/bosluk asamasinda) ve io2/io3 (yuksek) denetleyici tarafindan surulur; veri asamasinda hepsi flas'tan gelir
    input  wire [3:0]  io_i,
    // bayt akisi
    output reg         bayt_gecerli,
    output reg  [7:0]  bayt_veri,
    input  wire        bayt_hazir,
    output wire        mesgul,
    output reg         bitti
);
    localparam S_BOS = 3'd0, S_BASLAT = 3'd1, S_KOMUT = 3'd2, S_DUMMY = 3'd3, S_VERI = 3'd4, S_SON = 3'd5;
    reg [2:0]  durum;
    reg [31:0] kayd;
    reg [5:0]  sayac;
    reg        nib;
    reg [3:0]  hi;
    reg [31:0] kalan;
    reg [7:0]  bol;

    assign mesgul = (durum != S_BOS);
    assign io_oe  = (durum == S_BASLAT) || (durum == S_KOMUT) || (durum == S_DUMMY);
    wire tik = (bol == BOL-1);

    always @(posedge clk) begin
        bitti <= 1'b0;
        if (bayt_gecerli && bayt_hazir) bayt_gecerli <= 1'b0;
        if (rst) begin
            durum <= S_BOS; sck <= 1'b0; cs_n <= 1'b1; io0_o <= 1'b0; bayt_gecerli <= 1'b0; bol <= 8'd0; nib <= 1'b0;
        end else begin
            if (durum == S_BOS) bol <= 8'd0;
            else if (tik) bol <= 8'd0; else bol <= bol + 8'd1;

            case (durum)
                S_BOS: if (basla) begin
                    cs_n <= 1'b0; kayd <= {8'h6B, adres}; io0_o <= 1'b0;       // 0x6B'nin en yuksek biti 0
                    kalan <= bayt_sayisi; sayac <= 6'd0; nib <= 1'b0; durum <= S_BASLAT;
                end
                S_BASLAT: if (tik) durum <= S_KOMUT;
                S_KOMUT: if (tik) begin
                    if (!sck) sck <= 1'b1;
                    else begin
                        sck <= 1'b0;
                        if (sayac == 6'd31) begin durum <= S_DUMMY; sayac <= 6'd0; end
                        else begin sayac <= sayac + 6'd1; kayd <= {kayd[30:0], 1'b0}; io0_o <= kayd[30]; end
                    end
                end
                S_DUMMY: if (tik) begin
                    if (!sck) sck <= 1'b1;
                    else begin
                        sck <= 1'b0;
                        if (sayac == 6'd7) begin durum <= S_VERI; sayac <= 6'd0; end
                        else sayac <= sayac + 6'd1;
                    end
                end
                S_VERI: if (tik) begin
                    if (!sck) begin
                        // yukselen kenar: ikinci yarim bayt bayt yazmacina yazilacaksa yazmac bos olmali
                        if (!bayt_gecerli || !nib) begin
                            sck <= 1'b1;
                            if (!nib) begin hi <= io_i; nib <= 1'b1; end
                            else begin bayt_veri <= {hi, io_i}; bayt_gecerli <= 1'b1; nib <= 1'b0; kalan <= kalan - 32'd1; end
                        end
                    end else begin
                        sck <= 1'b0;
                        if (kalan == 32'd0 && !nib) durum <= S_SON;
                    end
                end
                S_SON: if (!bayt_gecerli) begin cs_n <= 1'b1; bitti <= 1'b1; durum <= S_BOS; end
                default: durum <= S_BOS;
            endcase
        end
    end
endmodule
