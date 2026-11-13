// -----------------------------------------------------------------------------
// birlesik_bellek_2o.v -- aktivasyon belleği, IKI okuma portlu: altı adet 1024 sozcuklu birim = 48 KB
//   Birinci port: dizinin A operandi / LayerNorm / dis okuma.  Ikinci port: panel kopyalayici (K ve V paneli).
//   Her birim tek okuma portlu bir blok bellektir; iki port FARKLI birimlere erisirse ayni cevrimde ikisi de okunur.
//   Iki port ayni birime ayni cevrimde gercekten erismemelidir (adres yerlesimi bunu saglar); olursa birinci port kazanir ve
//   `catisma` darbesi uretilir (benzetimde yakalanir). Bos (etkin olmayan) port diger portu engellemez.
//   Okuma kayitli (1 cevrim): okuma verisi, birimden gelen kayitli degerlerin secimidir.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module birlesik_bellek_2o #(
    parameter BIRIM_SAYISI = 6,
    parameter AW           = 13
) (
    input  wire          clk,
    input  wire          yaz_etkin,
    input  wire [AW-1:0] yaz_adres,
    input  wire [63:0]   yaz_veri,
    input  wire          oku1_etkin,                              // birinci port bu cevrimde gercekten okuyor mu
    input  wire [AW-1:0] oku1_adres,
    output wire [63:0]   oku1_veri,
    input  wire          oku2_etkin,                              // ikinci port bu cevrimde gercekten okuyor mu (catisma denetimi icin)
    input  wire [AW-1:0] oku2_adres,
    output wire [63:0]   oku2_veri,
    output reg           catisma
);
    wire [63:0] birim_veri [0:BIRIM_SAYISI-1];
    reg  [2:0]  oku1_birim, oku2_birim;
    always @(posedge clk) begin
        oku1_birim <= oku1_adres[12:10];
        oku2_birim <= oku2_adres[12:10];
        catisma    <= oku1_etkin && oku2_etkin && (oku1_adres[12:10] == oku2_adres[12:10]);
    end

    genvar g;
    generate
        for (g = 0; g < BIRIM_SAYISI; g = g + 1) begin : birim
            // ikinci port yalniz gercekten okuyorsa ve birinci port bu birimi gercekten okumuyorsa ikinci porta verilir
            wire sec2 = oku2_etkin && (oku2_adres[12:10] == g) && !(oku1_etkin && (oku1_adres[12:10] == g));
            cift_kapili_bellek #(.ADRES_GENISLIGI(10), .VERI_GENISLIGI(64)) u_birim (
                .clk(clk), .yaz_etkin(yaz_etkin && (yaz_adres[12:10] == g)), .yaz_adres(yaz_adres[9:0]), .yaz_veri(yaz_veri),
                .oku_adres(sec2 ? oku2_adres[9:0] : oku1_adres[9:0]), .oku_veri(birim_veri[g]));
        end
    endgenerate

    assign oku1_veri = (oku1_birim == 3'd0) ? birim_veri[0] :
                       (oku1_birim == 3'd1) ? birim_veri[1] :
                       (oku1_birim == 3'd2) ? birim_veri[2] :
                       (oku1_birim == 3'd3) ? birim_veri[3] :
                       (oku1_birim == 3'd4) ? birim_veri[4] : birim_veri[5];
    assign oku2_veri = (oku2_birim == 3'd0) ? birim_veri[0] :
                       (oku2_birim == 3'd1) ? birim_veri[1] :
                       (oku2_birim == 3'd2) ? birim_veri[2] :
                       (oku2_birim == 3'd3) ? birim_veri[3] :
                       (oku2_birim == 3'd4) ? birim_veri[4] : birim_veri[5];
endmodule
