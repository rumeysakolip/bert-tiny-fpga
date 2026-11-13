// -----------------------------------------------------------------------------
// birlesik_bellek.v -- aktivasyon belleği: altı adet 1024 sozcuklu (8 KB) birim = 6144 sozcuk x 64 bit = 48 KB
//   Bir sozcuk = sekiz token'in ayni kanaldaki baytlari. Katmanlarin giris ve cikis tensorleri bu bellekte, adres tabanlariyla
//   yerlestirilir; bir katmanin cikisi, kopyalanmadan sonraki katmanin girisidir.
//   Her birim ayri bir bellek (2 blok bellek); adres = {birim[12:10], sozcuk[9:0]}. Boylece 6144 derinlik 8192'ye yuvarlanmaz
//   (tek buyuk bellek 16 blok bellek tutar; altı ayri birim 12 tutar).
//   1 yazma + 1 okuma, okuma kayitli (1 cevrim): okuma verisi, birimden gelen kayitli degerlerin secimidir.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module birlesik_bellek #(
    parameter BIRIM_SAYISI = 6,
    parameter AW           = 13
) (
    input  wire          clk,
    input  wire          yaz_etkin,
    input  wire [AW-1:0] yaz_adres,
    input  wire [63:0]   yaz_veri,
    input  wire [AW-1:0] oku_adres,
    output wire [63:0]   oku_veri
);
    wire [63:0] birim_veri [0:BIRIM_SAYISI-1];
    reg  [2:0]  oku_birim;                                   // okuma verisi bir cevrim sonra gelir; birim secimi de ayni gecikmeyle
    always @(posedge clk) oku_birim <= oku_adres[12:10];

    genvar g;
    generate
        for (g = 0; g < BIRIM_SAYISI; g = g + 1) begin : birim
            cift_kapili_bellek #(.ADRES_GENISLIGI(10), .VERI_GENISLIGI(64)) u_birim (
                .clk(clk), .yaz_etkin(yaz_etkin && (yaz_adres[12:10] == g)), .yaz_adres(yaz_adres[9:0]), .yaz_veri(yaz_veri),
                .oku_adres(oku_adres[9:0]), .oku_veri(birim_veri[g]));
        end
    endgenerate

    assign oku_veri = (oku_birim == 3'd0) ? birim_veri[0] :
                      (oku_birim == 3'd1) ? birim_veri[1] :
                      (oku_birim == 3'd2) ? birim_veri[2] :
                      (oku_birim == 3'd3) ? birim_veri[3] :
                      (oku_birim == 3'd4) ? birim_veri[4] : birim_veri[5];
endmodule
