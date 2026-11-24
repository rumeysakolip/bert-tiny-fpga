#!/usr/bin/env python3
"""PC tarafı hızlandırıcı sürücüsü (BIL 401, G9). İki arka uç, aynı API:

  SimArkaUc  : paketleri Icarus testbench'ine (tb_hizlandirici.v) komut dosyası olarak verir, yanıt dosyasını okur.
               Benzetim toplu çalışır: önce tüm adımlar kaydedilir, `calistir()` ile bir kez koşar.
  SeriArkaUc : pyserial ile gerçek karta (Basys3 USB-UART). KARTTA DENENMEDİ (elde kart yok); ayni paket
               formatini kullanir, bekleme adimlari DURUM (0x06) sorgusuyla yapilir.

Protokol (rtl/komut_cozucu.v ile aynı):
  istek: cmd(1) len(2,LE) payload crc8(1)      crc8 poly 0x07, init 0, cmd+len+payload
  yanıt: ACK 06 cmd | HATA 15 cmd kod | VERI 02 cmd len(2) veri crc8
"""
import os
import subprocess
import time

CMD = dict(CFG=1, YUKLE_AKT=2, YUKLE_PANEL=3, CALISTIR=4, OKU_AKT=5, DURUM=6, PANEL_HAZIR=7)
HATA_KODU = {1: "CRC", 2: "bilinmeyen komut", 3: "uzunluk"}

VARSAYILAN_BAUD = 921600            # FPGA tarafi: CLKS_PER_BIT = f_clk / baud (100 MHz -> 109)
BAUD_GUVENLI_PCT, BAUD_SINIR_PCT = 2.0, 4.0     # |baud hatasi| esikleri (sim/sure_modeli.json: uart)


def uart_ayari(f_clk_hz, baud):
    """FPGA'nin kullanacagi CLKS_PER_BIT ve baud hatasi (yuzde). Donus: (clks_per_bit, gercek_baud, hata_pct, durum).
    durum: 'guvenli' (<=%2) | 'sinirda' (<=%4) | 'calismaz' (>%4). Kural ve esikler: 03-RTL/scripts/sure_modeli.py."""
    oran = f_clk_hz / baud
    cpb = min((int(oran), int(oran) + 1), key=lambda c: abs(f_clk_hz / c - baud))
    gercek = f_clk_hz / cpb
    hata = 100.0 * (gercek - baud) / baud
    durum = "guvenli" if abs(hata) <= BAUD_GUVENLI_PCT else ("sinirda" if abs(hata) <= BAUD_SINIR_PCT else "calismaz")
    return cpb, gercek, hata, durum


def crc8(veri, c=0):
    for b in veri:
        c ^= b
        for _ in range(8):
            c = ((c << 1) ^ 0x07) & 0xFF if c & 0x80 else (c << 1) & 0xFF
    return c


def paket(cmd, payload=b"", bozuk_crc=False):
    govde = bytes([cmd]) + len(payload).to_bytes(2, "little") + bytes(payload)
    c = crc8(govde)
    return govde + bytes([c ^ 0xFF if bozuk_crc else c])


def yanit_ayristir(b):
    """Bayt akışını yanıt listesine ayırır: [{'tur','cmd',...}]. VERI CRC'si doğrulanır."""
    out, i = [], 0
    while i < len(b):
        t = b[i]
        if t == 0x06:
            out.append({"tur": "ACK", "cmd": b[i + 1]}); i += 2
        elif t == 0x15:
            out.append({"tur": "HATA", "cmd": b[i + 1], "kod": b[i + 2], "neden": HATA_KODU.get(b[i + 2], "?")}); i += 3
        elif t == 0x02:
            cmd, n = b[i + 1], b[i + 2] | (b[i + 3] << 8)
            veri = bytes(b[i + 4:i + 4 + n]); crc = b[i + 4 + n]
            ok = crc8(bytes(b[i + 1:i + 4 + n])) == crc
            out.append({"tur": "VERI", "cmd": cmd, "veri": veri, "crc_ok": ok}); i += 5 + n
        else:
            raise ValueError(f"yanıt akışında beklenmeyen bayt 0x{t:02x} (konum {i})")
    return out


class SimArkaUc:
    """Icarus arka ucu. kok = 03-RTL klasörü."""

    def __init__(self, kok, calisma="sim/host_dongu", vvp="sim/tb_hizlandirici.vvp"):
        self.kok, self.betik, self.paketler = kok, [], []
        self.calisma = os.path.join(kok, calisma)
        self.vvp = os.path.join(kok, vvp)
        self.log = ""

    def derle(self):
        rtl = ["islem_elemani", "sistolik_dizi", "cift_kapili_bellek", "panel_tamponu", "tile_denetleyici", "yeniden_olcekle", "gelu_tablosu",
               "cikis_sozcuk_toplayici", "dogrusal_katman", "seri_bolucu", "ters_bolucu", "softmax_birim", "layernorm_birim", "sonuc_tamponu",
               "komut_cozucu", "kontrol_birimi", "veri_yolu", "bert_tiny_ust"]
        kaynak = [os.path.join(self.kok, "rtl", f + ".v") for f in rtl] + [os.path.join(self.kok, "tb", "tb_hizlandirici.v")]
        r = subprocess.run(["iverilog", "-g2001", "-o", self.vvp] + kaynak, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError("iverilog: " + r.stderr[-500:])

    def gonder(self, p):
        for b in p:
            self.betik.append((0, b))
        self.betik.append((1, 0))
        self.paketler.append(p)

    def bekle_panel_bos(self, buf):
        self.betik.append((2, buf))

    def bekle_bitti(self):
        self.betik.append((3, 0))

    def calistir(self):
        os.makedirs(os.path.dirname(self.calisma), exist_ok=True)
        scr, out = self.calisma + "_komut.hex", self.calisma + "_yanit.hex"
        with open(scr, "w") as f:
            for t, v in self.betik + [(4, 0)]:
                f.write(f"{t:x}{v:02x}\n")
        if not os.path.exists(self.vvp):
            self.derle()
        t0 = time.time()
        r = subprocess.run(["vvp", self.vvp, f"+scr={scr}", f"+out={out}"], capture_output=True, text=True)
        self.log = r.stdout
        yanit = bytes(int(s, 16) for s in open(out).read().split())
        self.sure = time.time() - t0
        return yanit_ayristir(yanit)


class SeriArkaUc:
    """pyserial arka ucu (kart gelince). Dur-ve-bekle; bekleme adımları DURUM sorgusuyla."""

    def __init__(self, port, baud=VARSAYILAN_BAUD, zaman_asimi=5.0, f_clk_hz=None):
        """baud: PC tarafi hizi; FPGA'daki CLKS_PER_BIT ile eslesmeli. f_clk_hz verilirse hata hesaplanir:
        'calismaz' ise ValueError, 'sinirda' ise uyari. 12 Mbaud'un Windows/pyserial'de gercekten verilip verilmedigi DOGRULANMADI."""
        if f_clk_hz is not None:
            cpb, gercek, hata, durum = uart_ayari(f_clk_hz, baud)
            if durum == "calismaz":
                raise ValueError(f"{f_clk_hz / 1e6:g} MHz saatte {baud} baud icin CLKS_PER_BIT={cpb} ({gercek:.0f} baud, hata %{hata:.2f}) calismaz")
            if durum == "sinirda":
                import warnings  # noqa: PLC0415
                warnings.warn(f"baud hatasi %{hata:.2f}: sinirda (CLKS_PER_BIT={cpb}); kartta denenmeli")
        import serial  # noqa: PLC0415
        self.s = serial.Serial(port, baud, timeout=zaman_asimi)

    def _oku_yanit(self):
        t = self.s.read(1)
        if not t:
            raise TimeoutError("yanıt yok")
        if t[0] == 0x06:
            return yanit_ayristir(t + self.s.read(1))[0]
        if t[0] == 0x15:
            return yanit_ayristir(t + self.s.read(2))[0]
        h = self.s.read(3)
        n = h[1] | (h[2] << 8)
        return yanit_ayristir(t + h + self.s.read(n + 1))[0]

    def gonder(self, p):
        self.s.write(p)
        return self._oku_yanit()

    def durum(self):
        y = self.gonder(paket(CMD["DURUM"]))
        return y["veri"][0], y["veri"][1]

    def bekle_panel_bos(self, buf):
        while not (self.durum()[1] >> buf) & 1:
            time.sleep(0.001)

    def bekle_bitti(self):
        while not (self.durum()[0] >> 1) & 1:
            time.sleep(0.001)


class Hizlandirici:
    """Üst düzey API: aynı kod iki arka uçta da çalışır (gönderme sırası aynıdır)."""

    def __init__(self, arka):
        self.a = arka

    def cfg(self, K, np_, n, a_isaretsiz=False, gelu_en=False, nb=0):
        """nb: islenecek token blogu sayisi (1..8; her blok 8 token). 0 = 8 (eski davranis). Bayrak baytinin bit 5:2 alanina yazilir."""
        assert 0 <= nb <= 8, "nb 0..8 olmali"
        self.a.gonder(paket(CMD["CFG"], K.to_bytes(2, "little") + bytes([np_, n, int(a_isaretsiz) | (int(gelu_en) << 1) | (nb << 2)])))

    def yukle_akt(self, adres, sozcukler):
        self.a.gonder(paket(CMD["YUKLE_AKT"], adres.to_bytes(2, "little") + b"".join(int(w).to_bytes(8, "little") for w in sozcukler)))

    def yukle_panel(self, buf, sel, adres, veri):
        self.a.gonder(paket(CMD["YUKLE_PANEL"], bytes([buf, sel]) + adres.to_bytes(2, "little") + bytes(veri)))

    def panel_hazir(self, buf):
        self.a.gonder(paket(CMD["PANEL_HAZIR"], bytes([buf])))

    def calistir(self):
        self.a.gonder(paket(CMD["CALISTIR"]))

    def oku_akt(self, adres, adet):
        self.a.gonder(paket(CMD["OKU_AKT"], adres.to_bytes(2, "little") + adet.to_bytes(2, "little")))

    def durum(self):
        self.a.gonder(paket(CMD["DURUM"]))
