"""G20 -- N=4,8,16 dizi benzetimi (K=64): tile suresi ve bit-birebir sonuc -> sim/g20_sonuc.json.
Calistirma: python scripts/kos_g20.py   (cwd: 03-RTL). Sentez: vivado -mode batch -source sentez/g20_dizi.tcl -tclargs <N>"""
import json
import os
import re
import subprocess
import sys

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(KOK)
os.makedirs("sim", exist_ok=True)
sonuc = {}
for n in (4, 8, 16):
    vd = f"tb/vektor_nxn/n{n}_k64"
    if not os.path.exists(os.path.join(vd, "C.mem")):
        subprocess.run([sys.executable, "tb/gen_vektor_nxn.py", "--N", str(n), "--K", "64"], check=True)
    vvp = f"sim/g20_n{n}.vvp"
    d = subprocess.run(["iverilog", "-g2001", f"-Ptb_systolic_nxn.N={n}", "-Ptb_systolic_nxn.KT=64", "-o", vvp,
                        "tb/tb_systolic_nxn.v", "rtl/pe.v", "rtl/systolic_nxn.v"], capture_output=True, text=True)
    assert d.returncode == 0, d.stderr
    o = subprocess.run(["vvp", vvp, f"+vdir={vd}"], capture_output=True, text=True).stdout
    m = re.search(r"SYSTOLIC NxN TEST \(N=\d+,K=\d+\): (PASS|FAIL)\s+\((\d+) test, (\d+) kontrol, (\d+) hata\)", o)
    t = re.search(r"olculen (\d+)\.\.(\d+)", o)
    sonuc[str(n)] = {"pass": m.group(1) == "PASS", "test": int(m.group(2)), "kontrol": int(m.group(3)), "hata": int(m.group(4)),
                     "tile_cevrim": int(t.group(1)), "tile_cevrim_maks": int(t.group(2)), "beklenen": 64 + 2 * n - 2}
    print(n, sonuc[str(n)])
json.dump(sonuc, open("sim/g20_sonuc.json", "w"), indent=1)
