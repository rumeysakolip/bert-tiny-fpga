"""Konu 6 -- Vivado zamanlama raporundan en kotu yollari ayiklar ve modul bazinda gruplar -> JSON

Calistirma:  python scripts/zamanlama_yollari.py <rapor.txt> <cikti.json> [--etiket metin]        (cwd: 03-RTL)
Rapor: report_timing (sentez/zamanlama_yollari.tcl) ya da report_timing_summary ciktisi. Her yol icin: setup payi, kaynak/hedef hucre,
yol gecikmesi, mantik seviyesi, CARRY4 sayisi, yonlendirme orani. Modul = kaynak hucrenin ilk iki hiyerarsi bileseni (or. u_ust/u_ln).
"""
import argparse
import json
import re
from collections import defaultdict


def ayikla(metin):
    yollar = []
    parcalar = re.split(r"\n(?=Slack \((?:MET|VIOLATED)\))", metin)
    for p in parcalar:
        m = re.match(r"Slack \((MET|VIOLATED)\)\s*:\s+(-?[\d.]+)ns", p)
        if not m:
            continue
        kay = re.search(r"Source:\s+(\S+)", p)
        hed = re.search(r"Destination:\s+(\S+)", p)
        gec = re.search(r"Data Path Delay:\s+([\d.]+)ns\s+\(logic ([\d.]+)ns \(([\d.]+)%\)\s+route ([\d.]+)ns \(([\d.]+)%\)\)", p)
        sev = re.search(r"Logic Levels:\s+(\d+)(?:\s+\(([^)]*)\))?", p)
        if not (kay and hed and gec and sev):
            continue
        carry = re.search(r"CARRY4=(\d+)", sev.group(2) or "")
        yollar.append({"tur": "hold" if re.search(r"Path Type:\s+Hold", p) else "setup", "durum": m.group(1), "pay_ns": float(m.group(2)), "kaynak": kay.group(1), "hedef": hed.group(1),
                       "yol_gecikmesi_ns": float(gec.group(1)), "mantik_ns": float(gec.group(2)), "yonlendirme_ns": float(gec.group(4)),
                       "yonlendirme_yuzde": float(gec.group(5)), "mantik_seviyesi": int(sev.group(1)),
                       "carry4": int(carry.group(1)) if carry else 0, "hucre_dagilimi": sev.group(2) or ""})
    return yollar


def modul(hucre):
    b = hucre.split("/")
    return "/".join(b[:2]) if len(b) > 2 else (b[0] if b else hucre)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rapor")
    ap.add_argument("cikti")
    ap.add_argument("--etiket", default="")
    a = ap.parse_args()
    yollar = ayikla(open(a.rapor, encoding="utf-8", errors="replace").read())
    gruplar = defaultdict(list)
    for y in yollar:
        y["modul"] = modul(y["kaynak"])
        gruplar[y["modul"]].append(y["pay_ns"])
    ozet = {m: {"yol_sayisi": len(v), "en_kotu_pay_ns": min(v)} for m, v in gruplar.items()}
    json.dump({"etiket": a.etiket or "Vivado (report_timing)", "kaynak": a.rapor, "yol_sayisi": len(yollar), "modul_ozeti": ozet, "yollar": yollar},
              open(a.cikti, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print(f"{len(yollar)} yol; modul ozeti:", json.dumps(ozet, ensure_ascii=False))


if __name__ == "__main__":
    main()
