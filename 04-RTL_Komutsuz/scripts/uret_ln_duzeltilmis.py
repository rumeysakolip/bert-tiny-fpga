"""03-RTL/rtl/layernorm_birim.v dosyasindan xsim uyumlu kopya uretir (rtl/layernorm_birim_dz.v).
Neden: orijinalde GAMMA_GENISLIGI, port listesinde kullanildigi halde govdede localparam olarak bildirilmis; Icarus kabul eder, xsim reddeder.
Cozum: GAMMA_GENISLIGI parametre listesine tasinir. Hesap satirlari ayni; orijinal dosyaya dokunulmaz.
"""
import os
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.abspath(os.path.join(KOK, ".."))
t = open(os.path.join(PROJE, "03-RTL", "rtl", "layernorm_birim.v"), encoding="utf-8").read()
a = "    parameter KESIR_BITI    = 12\n) ("
assert a in t
t = t.replace(a, "    parameter KESIR_BITI    = 12,\n    parameter GAMMA_GENISLIGI = KESIR_BITI + 4              // xsim: port listesinde kullanildigi icin parametre listesine tasindi\n) (")
b = "    localparam GAMMA_GENISLIGI = KESIR_BITI + 4;                // gamma_q = gamma * 2^G genisligi (isaretli)\n"
assert b in t
t = t.replace(b, "")
t = t.replace("module layernorm_birim #(", "module layernorm_birim_dz #(")
# ---- hizlandirma (Kasim 2026): varyans, kareler toplami yukleme sirasinda biriktirilerek hesaplanir ----
# sum((q-m)^2) = sum(q^2) - 2*m*sum(q) + N*m^2  (m tamsayi oldugundan TAM esitlik; sonuc bit-birebir ayni); ayri N cevrimlik fark-kare gecisi kalkar
def yama(eski, yeni):
    global t
    assert t.count(eski) == 1, ("bulunamadi: " + eski[:70], t.count(eski))
    t = t.replace(eski, yeni)


yama("    reg [KARELER_TOPLAMI_GENISLIGI-1:0]         kareler_toplami;\n",
     "    reg [KARELER_TOPLAMI_GENISLIGI-1:0]         kareler_toplami;\n"
     "    reg [2*GIRIS_GENISLIGI+KANAL_SAYISI_LOG2-1:0] kare_yuk;       // yukleme sirasinda biriken sum(q^2)\n"
     "    reg [2:0]                                   ort_adim;         // ORTALAMA durumu alt adimi\n"
     "    reg signed [TOPLAM_GENISLIGI+2:0]           ort_t1;           // 2*sum(q) - N*m\n"
     "    (* use_dsp = \"no\" *) reg signed [FARK_GENISLIGI+TOPLAM_GENISLIGI+2:0] ort_carpim;    // m * t1 (satir basina bir kez; LUT'ta, iki yarim carpim + toplama)\n"
     "    (* use_dsp = \"no\" *) reg signed [FARK_GENISLIGI+15:0] ort_p_alt;                       // m * t1[13:0]\n"
     "    (* use_dsp = \"no\" *) reg signed [FARK_GENISLIGI+TOPLAM_GENISLIGI-11:0] ort_p_ust;     // m * t1[ust:14]\n"
     "    wire [2*GIRIS_GENISLIGI-1:0] kare_giris = giris_veri * giris_veri;\n")
yama("toplam <= 0; ortalama <= 0; kareler_toplami <= 0;",
     "toplam <= 0; ortalama <= 0; kareler_toplami <= 0; kare_yuk <= 0; ort_adim <= 3'd0; ort_t1 <= 0; ort_carpim <= 0; ort_p_alt <= 0; ort_p_ust <= 0;")
yama("sayac <= 0; toplam <= 0; kareler_toplami <= 0; durum <= DURUM_YUKLE;",
     "sayac <= 0; toplam <= 0; kareler_toplami <= 0; kare_yuk <= 0; ort_adim <= 3'd0; durum <= DURUM_YUKLE;")
yama("                    toplam <= toplam + giris_veri;\n",
     "                    toplam <= toplam + giris_veri;\n                    kare_yuk <= kare_yuk + kare_giris;\n")
yama("""                DURUM_ORTALAMA: begin
                    ortalama <= (toplam + (1 <<< (KANAL_SAYISI_LOG2-1))) >>> KANAL_SAYISI_LOG2;
                    sayac <= 0; kareler_toplami <= 0; kare_asama1_gecerli <= 1'b0; kare_asama2_gecerli <= 1'b0; durum <= DURUM_KARE_TOPLA;
                end
""", """                DURUM_ORTALAMA: begin                                       // 4 adim: ortalama | t1 | m*t1 | kareler toplami (eski N+2 cevrimlik gecis yerine)
                    case (ort_adim)
                        3'd0: begin ortalama <= (toplam + (1 <<< (KANAL_SAYISI_LOG2-1))) >>> KANAL_SAYISI_LOG2; ort_adim <= 3'd1; end
                        3'd1: begin ort_t1 <= (toplam <<< 1) - (ortalama <<< KANAL_SAYISI_LOG2); ort_adim <= 3'd2; end
                        3'd2: begin ort_p_alt <= ortalama * $signed({1'b0, ort_t1[13:0]}); ort_p_ust <= ortalama * $signed(ort_t1[TOPLAM_GENISLIGI+2:14]); ort_adim <= 3'd3; end
                        3'd3: begin ort_carpim <= ort_p_alt + (ort_p_ust <<< 14); ort_adim <= 3'd4; end
                        default: begin
                            kareler_toplami <= kare_yuk - ort_carpim; ort_adim <= 3'd0;
                            sayac <= 0; kare_asama1_gecerli <= 1'b0; kare_asama2_gecerli <= 1'b0; durum <= DURUM_VARYANS;
                        end
                    endcase
                end
""")
t = "// layernorm_birim_dz.v -- layernorm_birim.v'nin xsim uyumlu kopyasi (uret_ln_duzeltilmis.py ile uretilir; hesap satirlari ayni)\n" + t
open(os.path.join(KOK, "rtl", "layernorm_birim_dz.v"), "w", encoding="utf-8").write(t)
print("uretildi: rtl/layernorm_birim_dz.v")
