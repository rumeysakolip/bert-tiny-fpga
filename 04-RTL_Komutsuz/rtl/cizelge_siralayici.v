// -----------------------------------------------------------------------------
// cizelge_siralayici.v -- komutlarin yerini alan sabit cizelge + durum makinesi
//
// Model her cumle icin ayni islemleri ayni sirayla yaptigindan, "hangi adimda ne gelir" bilgisi devrede
// sabit bir tabloda (cizelge_satiri) durur; disaridan komut gelmez. Bu prototipte cizelge uc satirdir:
//   satir 0: katman 0 sorgu (Q), satir 1: anahtar (K), satir 2: deger (V); hepsi 128 -> 128, 16 panel, kaydirma 37.
// Her cumle: [aktivasyon blogu] + her satir icin [16 agirlik paneli blogu].
//
// Akis: aktivasyon blogunu iste -> ilk iki paneli iki tampona yukle -> calistir -> bir tampon bosaldikca
// siradaki paneli o tampona iste (agirlik yukleme ile hesap ust uste biner) -> katman_bitti -> satir_bitti.
// Prototipe ozgu gozlem kancasi: satir_bitti seviyesi yukselince disaridan cikis belleği okunur, sonra "devam" verilir.
// CRC hatali blokta "hata" kilitlenir ve cizelge durur (hata, rst ile temizlenir).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module cizelge_siralayici #(
    parameter SATIR_SAYISI    = 3,
    parameter K_GENISLIGI     = 11,
    parameter PANEL_GENISLIGI = 7
) (
    input  wire                       clk,
    input  wire                       rst,
    // akis ayristirici
    output reg                        blok_basla,
    output reg                        blok_tur,
    output reg                        blok_tampon,
    output wire [K_GENISLIGI-1:0]     blok_k,
    input  wire                       blok_tamam,
    input  wire                       blok_hatali,
    // dogrusal katman
    output reg                        calistir,
    output wire [K_GENISLIGI-1:0]     ayar_k,
    output wire [PANEL_GENISLIGI-1:0] ayar_panel_sayisi,
    output wire [5:0]                 ayar_kaydirma,
    output wire                       gelu_etkin,
    output reg  [1:0]                 panel_hazir,
    input  wire                       panel_bitti,
    input  wire                       panel_bitti_tampon,
    input  wire                       katman_bitti,
    // gozlem kancasi
    output wire                       satir_bitti,
    input  wire                       devam,
    output reg                        hata,
    output reg  [3:0]                 satir_no,
    output reg  [15:0]                cumle_no
);
    // ---- cizelge tablosu (sabit) ----
    function [K_GENISLIGI-1:0] satir_k;      input [3:0] i; begin satir_k = 128; end endfunction
    function [PANEL_GENISLIGI-1:0] satir_p;  input [3:0] i; begin satir_p = 16;  end endfunction
    function [5:0] satir_sh;
        input [3:0] i;
        begin case (i) 4'd0: satir_sh = 6'd37; 4'd1: satir_sh = 6'd37; default: satir_sh = 6'd37; endcase end
    endfunction
    function satir_gelu; input [3:0] i; begin satir_gelu = 1'b0; end endfunction

    assign ayar_k            = satir_k(satir_no);
    assign ayar_panel_sayisi = satir_p(satir_no);
    assign ayar_kaydirma     = satir_sh(satir_no);
    assign gelu_etkin        = satir_gelu(satir_no);
    assign blok_k            = satir_k(satir_no);

    localparam S_AKT = 4'd0, S_AKT_BEKLE = 4'd1, S_Y0 = 4'd2, S_Y0_BEKLE = 4'd3, S_Y1 = 4'd4, S_Y1_BEKLE = 4'd5,
               S_CALISTIR = 4'd6, S_KOS = 4'd7, S_SATIR_BEKLE = 4'd8, S_HATA = 4'd9;
    reg [3:0]                   durum;
    reg [PANEL_GENISLIGI-1:0]   yuklenen;          // yuklenmesi baslatilan panel sayisi
    reg [1:0]                   bos;               // bosalan (yeniden doldurulabilir) tamponlar
    reg                         yukleme_mesgul;
    reg                         yukleme_tampon;

    assign satir_bitti = (durum == S_SATIR_BEKLE);

    reg [1:0] ph_sonraki;

    always @(posedge clk) begin
        blok_basla <= 1'b0;
        calistir   <= 1'b0;
        if (rst) begin
            durum <= S_AKT; panel_hazir <= 2'b00; bos <= 2'b00; yuklenen <= 0; yukleme_mesgul <= 1'b0; yukleme_tampon <= 1'b0;
            hata <= 1'b0; satir_no <= 4'd0; cumle_no <= 16'd0; blok_tur <= 1'b0; blok_tampon <= 1'b0;
        end else begin
            // panel_hazir ve bos bayraklari
            ph_sonraki = panel_hazir;
            if (panel_bitti) begin
                ph_sonraki[panel_bitti_tampon] = 1'b0;
                bos[panel_bitti_tampon] <= 1'b1;
            end
            if (blok_tamam && yukleme_mesgul) begin
                ph_sonraki[yukleme_tampon] = 1'b1;
                yukleme_mesgul <= 1'b0;
            end
            panel_hazir <= ph_sonraki;

            if (blok_hatali) begin hata <= 1'b1; durum <= S_HATA; end
            else case (durum)
                S_AKT:       begin blok_basla <= 1'b1; blok_tur <= 1'b0; durum <= S_AKT_BEKLE; end
                S_AKT_BEKLE: if (blok_tamam) begin durum <= S_Y0; yuklenen <= 0; bos <= 2'b00; end
                S_Y0:        begin blok_basla <= 1'b1; blok_tur <= 1'b1; blok_tampon <= 1'b0; yukleme_mesgul <= 1'b1; yukleme_tampon <= 1'b0;
                                   yuklenen <= 1; durum <= S_Y0_BEKLE; end
                S_Y0_BEKLE:  if (blok_tamam) durum <= S_Y1;
                S_Y1:        begin blok_basla <= 1'b1; blok_tur <= 1'b1; blok_tampon <= 1'b1; yukleme_mesgul <= 1'b1; yukleme_tampon <= 1'b1;
                                   yuklenen <= 2; durum <= S_Y1_BEKLE; end
                S_Y1_BEKLE:  if (blok_tamam) durum <= S_CALISTIR;
                S_CALISTIR:  begin calistir <= 1'b1; durum <= S_KOS; end
                S_KOS: begin
                    // siradaki panel, serbest kalan tampona (sira: panel i -> tampon i mod 2) yuklenir
                    if (!yukleme_mesgul && yuklenen < satir_p(satir_no) && bos[yuklenen[0]]) begin
                        blok_basla <= 1'b1; blok_tur <= 1'b1; blok_tampon <= yuklenen[0];
                        yukleme_mesgul <= 1'b1; yukleme_tampon <= yuklenen[0];
                        bos[yuklenen[0]] <= 1'b0;                       // panel_bitti ile ayni cevrimde cakisma olmaz (ayni tampon icin ard arda gelmez)
                        yuklenen <= yuklenen + 1;
                    end
                    if (katman_bitti) durum <= S_SATIR_BEKLE;
                end
                S_SATIR_BEKLE: if (devam) begin
                    if (satir_no == SATIR_SAYISI-1) begin satir_no <= 4'd0; cumle_no <= cumle_no + 16'd1; durum <= S_AKT; end
                    else begin satir_no <= satir_no + 4'd1; durum <= S_Y0; yuklenen <= 0; bos <= 2'b00; end
                end
                S_HATA: ;
                default: durum <= S_HATA;
            endcase
        end
    end
endmodule
