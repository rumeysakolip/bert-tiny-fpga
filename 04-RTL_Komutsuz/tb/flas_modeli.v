// flas_modeli.v -- yalniz benzetim: S25FL032 sinifi seri flasin 0x6B (Quad Output Read) davranisi
//   komut(8) + adres(24) tek hat (io0_i) -> 8 bosluk darbesi -> her SCK'da 4 bit (yuksek yarim once), adres otomatik artar.
//   Yukselen kenarda ornekler (komut/adres), alcalan kenarda veri verir. Veri sayfasinin zamanlamasini (tCLQV vb.) taklit etmez.
`timescale 1ns/1ps
module flas_modeli #(
    parameter BOYUT = 262144,
    parameter DOSYA = "akis.hex",
    parameter [23:0] TABAN = 24'd0,      // dosyanin flas icindeki baslangic adresi
    parameter TV = 0                      // alcalan SCK kenarindan veri cikisina gecikme (ns)
) (
    input  wire       sck,
    input  wire       cs_n,
    input  wire       io0_i,
    output reg  [3:0] io_o,
    output wire       surer           // 1: flas veri hatlarini suruyor (veri asamasi)
);
    reg [7:0] bellek [0:BOYUT-1];
    reg [255*8:1] dosya_adi;
    initial begin
        if (!$value$plusargs("flas=%s", dosya_adi)) dosya_adi = DOSYA;
        $readmemh(dosya_adi, bellek);
    end

    reg [31:0] kayd;
    integer    sayac;
    reg [1:0]  faz;              // 0 komut+adres, 1 bosluk, 2 veri, 3 gecersiz komut
    reg [23:0] adr;
    reg        nib;
    integer    okunan;
    reg veri_basladi;
    assign surer = (faz == 2) && !cs_n && veri_basladi;

    always @(negedge cs_n) begin veri_basladi = 0; faz = 0; sayac = 0; kayd = 0; nib = 0; io_o = 4'hF; okunan = 0; end

    always @(posedge sck) if (!cs_n) begin
        case (faz)
            0: begin
                kayd = {kayd[30:0], io0_i}; sayac = sayac + 1;
                if (sayac == 32) begin
                    if (kayd[31:24] == 8'h6B) begin faz = 1; adr = kayd[23:0]; end else faz = 3;
                    sayac = 0;
                end
            end
            1: begin sayac = sayac + 1; if (sayac == 8) begin faz = 2; sayac = 0; nib = 0; end end
            default: ;
        endcase
    end

    always @(negedge sck) if (!cs_n && faz == 2) begin
        veri_basladi = 1;
        if (!nib) io_o <= #(TV) bellek[(adr - TABAN) % BOYUT][7:4];
        else begin io_o <= #(TV) bellek[(adr - TABAN) % BOYUT][3:0]; adr = adr + 1; okunan = okunan + 1; end
        nib = ~nib;
    end
endmodule
