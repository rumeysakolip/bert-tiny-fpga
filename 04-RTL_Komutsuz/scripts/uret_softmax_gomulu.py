"""03-RTL/rtl/softmax_birim.v dosyasindan, ustel tablosu gomulu (baslangic degerli) varyanti uretir:
rtl/softmax_birim_gomulu.v  ve  tb/tb_softmax_gomulu.v.   Kok: 04-RTL_Komutsuz.
Mevcut birim DEGISTIRILMEZ; hesap satirlari aynen korunur, yalnizca tablo yazma portu kalkar ve tablo initial ile yuklenir.
"""
import os, re, shutil

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.abspath(os.path.join(KOK, ".."))
kaynak = open(os.path.join(PROJE, "03-RTL", "rtl", "softmax_birim.v"), encoding="utf-8").read()

# ---- RTL ----
s = kaynak.replace("module softmax_birim #(", "module softmax_birim_gomulu #(")
s = s.replace("    parameter SATIR_UZUNLUGU_LOG2 = 6\n", "    parameter SATIR_UZUNLUGU_LOG2 = 6,\n    parameter TABLO_DOSYASI = \"exp_tablosu.mem\"        // 512 x 16 bit ustel tablosu; yuklenebilir dosyaya baslangic degeri olarak gomulur\n")
s = re.sub(r"    input  wire                 tablo_yaz_etkin,\n    input  wire \[8:0\]           tablo_yaz_adres,\n    input  wire \[15:0\]          tablo_yaz_veri,\n", "", s)
s = s.replace("        if (tablo_yaz_etkin) us_tablosu[tablo_yaz_adres] <= tablo_yaz_veri;\n", "")
s = s.replace("    reg [15:0]        us_tablo_okunan;", "    initial $readmemh(TABLO_DOSYASI, us_tablosu);                                       // gomulu tablo: yazma portu yok\n    reg [15:0]        us_tablo_okunan;")
s = "// softmax_birim_gomulu.v -- softmax_birim.v'nin ustel tablosu gomulu varyanti (uret_softmax_gomulu.py ile uretilir; hesap satirlari ayni)\n" + s
# xsim, bildirimden once kullanimi reddeder (iverilog kabul eder): tablo_adresi bildirimi carpim2'den hemen sonraya tasinir
adres_satiri = "    wire [8:0]  tablo_adresi = (carpim2[57:16] > 42'd511) ? 9'd511 : carpim2[24:16];\n"
assert adres_satiri in s
s = s.replace(adres_satiri, "")
s = s.replace("    reg [57:0]        carpim1, carpim2;\n", "    reg [57:0]        carpim1, carpim2;\n" + adres_satiri)
assert "tablo_yaz" not in s.replace("tablo_adresi", ""), "tablo yazma kalintisi"
open(os.path.join(KOK, "rtl", "softmax_birim_gomulu.v"), "w", encoding="utf-8").write(s)

# tablo dosyasi (katman 0 ile 1 ayni veri mi?)
par = os.path.join(PROJE, "02-RTL_Altin_Model", "03_Sonuclar", "parametreler")
def veri(p): return [l.strip() for l in open(p, encoding="utf-8") if l.strip() and not l.startswith("//")]
l0, l1 = veri(os.path.join(par, "l0_exp_lut.mem")), veri(os.path.join(par, "l1_exp_lut.mem"))
shutil.copy(os.path.join(par, "l0_exp_lut.mem"), os.path.join(KOK, "rtl", "exp_l0.mem"))
print("exp tablolari ayni mi:", l0 == l1, len(l0), "giris")

# ---- Testbench (tb_softmax.v'nin gomulu varyanti, anlamli gunluk) ----
t = open(os.path.join(PROJE, "03-RTL", "tb", "tb_softmax.v"), encoding="utf-8").read()
t = t.replace("module tb_softmax;", "module tb_softmax_gomulu;").replace("$dumpvars(0, tb_softmax)", "$dumpvars(0, tb_softmax_gomulu)")
t = t.replace('    parameter VDIR_VARSAYILAN = "C:/Users/rumey/Documents/biitirme-projem/03-RTL/tb/vektor_g11";',
              '    parameter VDIR_VARSAYILAN = "C:/Users/rumey/Documents/biitirme-projem/03-RTL/tb/vektor_g11";\n    parameter TABLO_VARSAYILAN = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/rtl/exp_l0.mem";')
t = t.replace("    reg         tablo_yaz_etkin = 0;\n    reg  [8:0]  tablo_yaz_adres = 0;\n    reg  [15:0] tablo_yaz_veri = 0;\n", "")
t = t.replace("softmax_birim #(.SATIR_UZUNLUGU(L)) dut (.clk(clk), .rst(rst), .tablo_yaz_etkin(tablo_yaz_etkin), .tablo_yaz_adres(tablo_yaz_adres), .tablo_yaz_veri(tablo_yaz_veri),",
              "softmax_birim_gomulu #(.SATIR_UZUNLUGU(L), .TABLO_DOSYASI(TABLO_VARSAYILAN)) dut (.clk(clk), .rst(rst),")
# LUT yukleme blogunu kaldir
i = t.index("        // LUT yukle")
j = t.index("        for (r = 0; r < nrow; r = r + 1) begin")
t = t[:i] + t[j:]
t = t.replace("    reg [31:0] mLut  [0:511];\n", "")
t = t.replace('        $sformat(yol, "%0s/sm_lut.mem", vdir);  $readmemh(yol, mLut);\n', "")
# gunluk
t = t.replace("        hata = 0; kontrol = 0; bad_rows = 0;", '        $display("==== SOFTMAX (gomulu ustel tablo) SINAMASI ====");\n        $display("Ustel tablo, devre icinde baslangic degeriyle yuklu; disaridan yazma yok.");\n        hata = 0; kontrol = 0; bad_rows = 0;')
t = t.replace("            repeat (2) @(negedge clk);\n            if (vcd_ac && r == 0) begin $dumpoff; end",
              '            repeat (2) @(negedge clk);\n            if ((r + 1) % 50 == 0 || r == nrow - 1) $display("  [ilerleme] %0d / %0d satir islendi, hata=%0d", r + 1, nrow, hata);\n            if (vcd_ac && r == 0) begin $dumpoff; end')
t = t.replace('        $display("SOFTMAX TEST: %s', '        $display("SOFTMAX GOMULU TEST: %s')
t = t.replace('(hata == 0) ? "PASS" : "FAIL"', '(hata == 0) ? "BASARILI" : "BASARISIZ"')
t = t.replace('$readmemh(yol, mCik);\n', '$readmemh(yol, mCik);\n', 1)
t = t.replace("    integer h0;\nendmodule", "endmodule").replace("    integer nrow, r, i, hata, kontrol, bad_rows, cyc, cyc_min, cyc_max, got;", "    integer nrow, r, i, hata, kontrol, bad_rows, cyc, cyc_min, cyc_max, got, h0;   // xsim: kullanimdan once bildirilmeli")
assert "got, h0;" in t and "integer h0;" not in t
open(os.path.join(KOK, "tb", "tb_softmax_gomulu.v"), "w", encoding="utf-8").write(t)
print("uretildi")
