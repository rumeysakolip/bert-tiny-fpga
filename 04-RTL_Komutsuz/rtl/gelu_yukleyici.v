// -----------------------------------------------------------------------------
// gelu_yukleyici.v -- GELU / tanh tablolarini gomulu bellekten katmanin tablosuna yazar (disaridan yukleme yok)
//   tablo_sec: 1 = GELU katman 0, 2 = GELU katman 1, 3 = tanh, 4 = GELU+ffn2 girdi olcegi katman 0, 5 = ayni, katman 1. basla darbesiyle 256 giris yazilir (256 cevrim + 2).
//   Mevcut gelu_tablosu modulunun yazma portu kullanilir; modul degismez.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module gelu_yukleyici #(
    parameter GELU_L0 = "gelu_l0.mem",
    parameter GELU_L1 = "gelu_l1.mem",
    parameter TANH    = "tanh.mem",
    parameter GELU_F0 = "gelu_ffn2_l0.mem",
    parameter GELU_F1 = "gelu_ffn2_l1.mem"
) (
    input  wire       clk,
    input  wire       rst,
    input  wire       basla,
    input  wire [2:0] tablo_sec,
    output reg        gelu_yaz_etkin,
    output reg  [7:0] gelu_yaz_adres,
    output reg  [7:0] gelu_yaz_veri,
    output wire       mesgul,
    output reg        bitti
);
    (* rom_style = "distributed" *) reg [7:0] t0 [0:255];      // dagitik bellek (mantik hucresi): blok bellek harcanmaz
    (* rom_style = "distributed" *) reg [7:0] t1 [0:255];
    (* rom_style = "distributed" *) reg [7:0] t2 [0:255];
    (* rom_style = "distributed" *) reg [7:0] t3 [0:255];
    (* rom_style = "distributed" *) reg [7:0] t4 [0:255];
    initial begin
        $readmemh(GELU_L0, t0);
        $readmemh(GELU_L1, t1);
        $readmemh(TANH,    t2);
        $readmemh(GELU_F0, t3);
        $readmemh(GELU_F1, t4);
    end
    reg [8:0] sayac;
    reg       calisiyor;
    reg [2:0] sec;
    assign mesgul = calisiyor;
    always @(posedge clk) begin
        gelu_yaz_etkin <= 1'b0;
        bitti <= 1'b0;
        if (rst) begin calisiyor <= 1'b0; sayac <= 9'd0; end
        else if (!calisiyor) begin
            if (basla && tablo_sec != 3'd0) begin calisiyor <= 1'b1; sayac <= 9'd0; sec <= tablo_sec; end
        end else begin
            gelu_yaz_etkin <= 1'b1;
            gelu_yaz_adres <= sayac[7:0];
            gelu_yaz_veri  <= (sec == 3'd1) ? t0[sayac[7:0]] : (sec == 3'd2) ? t1[sayac[7:0]] : (sec == 3'd3) ? t2[sayac[7:0]] : (sec == 3'd4) ? t3[sayac[7:0]] : t4[sayac[7:0]];
            if (sayac == 9'd255) begin calisiyor <= 1'b0; bitti <= 1'b1; end
            else sayac <= sayac + 9'd1;
        end
    end
endmodule
