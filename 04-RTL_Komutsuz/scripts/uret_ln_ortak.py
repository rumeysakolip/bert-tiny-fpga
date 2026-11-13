"""rtl/artik_ln_blogu.v'den rtl/artik_ln_ortak.v uretir: kendi yeniden olcekleme devresi (u_rs) sokulur, arabirimi disariya acilir
(ortak cekirdekte TEK carpma devresi paylasilir). Ek: yeniden olceklenmemis LayerNorm cikisi (y) ikinci bir bolgeye de yazilabilir
(altin modelde artik toplamin ikinci LayerNorm'u, ilk LayerNorm'un yeniden olceklenmemis cikisini kullanir). Kaynak dosyaya dokunulmaz."""
import os
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
t = open(os.path.join(KOK, "rtl", "artik_ln_blogu.v"), encoding="utf-8").read()


def degistir(eski, yeni):
    global t
    assert eski in t, "bulunamadi: " + eski[:60]
    t = t.replace(eski, yeni, 1)


degistir("module artik_ln_blogu (", "module artik_ln_ortak (")
degistir("    input  wire [12:0]  taban_cikis,\n",
         "    input  wire [12:0]  taban_cikis,\n"
         "    input  wire         y_yaz,                   // 1: yeniden olceklenmemis cikis (y) ayrica taban_cikis_y'ye yazilir\n"
         "    input  wire [12:0]  taban_cikis_y,\n")
degistir("    output reg          tasma                    // artik toplam 18 bite sigmadi (sticky; basla ile temizlenir)\n);",
         """    output reg          tasma,                   // artik toplam 18 bite sigmadi (sticky; basla ile temizlenir)
    // ortak yeniden olcekleme birimine baglanti (bu blok kendi carpma devresini tasimaz)
    output reg          rs_gir_gecerli,
    output reg          rs_genis,
    output reg signed [31:0] rs_gir_veri,
    output reg  [30:0]  rs_m0,
    output reg  [5:0]   rs_n,
    output reg  [7:0]   rs_meta_gir,
    input  wire         rs_cik_gecerli,
    input  wire signed [31:0] rs_cik_veri,
    input  wire [7:0]   rs_meta_cik
);""")
i0 = t.index("    // ---------------- ortak yeniden olcekleme birimi ----------------")
i1 = t.index("    // ---------------- denetim ----------------")
t = t[:i0] + t[i1:]
degistir("            durum <= D_BOS; tasma <= 1'b0; f1_v <= 1'b0; f2_v <= 1'b0; cik_say <= 9'd0;",
         "            durum <= D_BOS; tasma <= 1'b0; f1_v <= 1'b0; f2_v <= 1'b0; cik_say <= 9'd0; oku_adres <= 13'd0; yaz_adres <= 13'd0; yaz_veri <= 64'd0;")
# ---- ikinci cikis (y) ----
degistir("D_YAZ = 4'd5;", "D_YAZ = 4'd5, D_YAZY = 4'd6;")
degistir("    reg [7:0]  obuf [0:1023];               // 8 satir x 128 kanal\n",
         "    reg [7:0]  obuf [0:1023];               // 8 satir x 128 kanal (yeniden olceklenmis cikis, z)\n"
         "    reg [7:0]  ybuf [0:1023];               // yeniden olceklenmemis LayerNorm cikisi (y)\n"
         "    reg        y_on; reg [12:0] tcy;\n")
degistir("                rs_m0 <= ln_o_m0(ln_k); rs_n <= ln_o_n(ln_k); rs_meta_gir <= {1'b0, cik_say[6:0]};\n",
         "                rs_m0 <= ln_o_m0(ln_k); rs_n <= ln_o_n(ln_k); rs_meta_gir <= {1'b0, cik_say[6:0]};\n"
         "                ybuf[{satir[2:0], cik_say[6:0]}] <= ln_cikis_veri;\n")
degistir("ln_k <= ln_no; tx <= taban_x; ta <= taban_a; tc <= taban_cikis;",
         "ln_k <= ln_no; tx <= taban_x; ta <= taban_a; tc <= taban_cikis; y_on <= y_yaz; tcy <= taban_cikis_y;")
degistir("""                    if (yaz_say == 8'd127) begin
                        if (satir == 6'd63) begin bitti <= 1'b1; durum <= D_BOS; end
                        else begin satir <= satir + 6'd1; durum <= D_BASLAT; end
                    end else yaz_say <= yaz_say + 8'd1;
                end
""", """                    if (yaz_say == 8'd127) begin
                        if (y_on) begin yaz_say <= 8'd0; durum <= D_YAZY; end
                        else if (satir == 6'd63) begin bitti <= 1'b1; durum <= D_BOS; end
                        else begin satir <= satir + 6'd1; durum <= D_BASLAT; end
                    end else yaz_say <= yaz_say + 8'd1;
                end
                D_YAZY: begin
                    yaz_etkin <= 1'b1; yaz_adres <= tcy + {satir[5:3], 7'd0} + yaz_say[6:0];
                    yaz_veri <= {ybuf[7*128 + yaz_say[6:0]], ybuf[6*128 + yaz_say[6:0]], ybuf[5*128 + yaz_say[6:0]], ybuf[4*128 + yaz_say[6:0]],
                                 ybuf[3*128 + yaz_say[6:0]], ybuf[2*128 + yaz_say[6:0]], ybuf[1*128 + yaz_say[6:0]], ybuf[0*128 + yaz_say[6:0]]};
                    if (yaz_say == 8'd127) begin
                        if (satir == 6'd63) begin bitti <= 1'b1; durum <= D_BOS; end
                        else begin satir <= satir + 6'd1; durum <= D_BASLAT; end
                    end else yaz_say <= yaz_say + 8'd1;
                end
""")
t = "// artik_ln_ortak.v -- artik_ln_blogu.v'nin ortak yeniden olcekleme birimine baglanan hali (uret_ln_ortak.py ile uretilir)\n" + t
open(os.path.join(KOK, "rtl", "artik_ln_ortak.v"), "w", encoding="utf-8").write(t)
print("uretildi: rtl/artik_ln_ortak.v")
