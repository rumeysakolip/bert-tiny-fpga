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
t = "// layernorm_birim_dz.v -- layernorm_birim.v'nin xsim uyumlu kopyasi (uret_ln_duzeltilmis.py ile uretilir; hesap satirlari ayni)\n" + t
open(os.path.join(KOK, "rtl", "layernorm_birim_dz.v"), "w", encoding="utf-8").write(t)
print("uretildi: rtl/layernorm_birim_dz.v")
