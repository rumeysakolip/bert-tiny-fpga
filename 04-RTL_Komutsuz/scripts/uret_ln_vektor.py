"""Artik toplama + LayerNorm (+ sonraki katman girisine yeniden olcekleme) test vektorleri ve gomulu parametreler.
Altin modelin TAM TAMSAYI hattini (B kipi) test cumleleri (kunye.json) uzerinde calistirir ve her kodlayici LayerNorm'u icin sunlari yakalar:
   x  : katman girisi (INT8, olcek hs)            a : dikkat/ileri besleme cikisi (INT8, olcek s_a)
   q  : toplam = tam(x,hs->s_ln) + tam(a,s_a->s_ln)   (LayerNorm girisi)      y : LayerNorm cikisi (INT8, olcek s_out)
   z  : sonraki girisin yeniden olceklenmis hali = tam(y, s_out -> sonraki a_olcek)   (sonraki katmanin gercek girdisi)
Cikti (04-RTL_Komutsuz): vektor_ln/ln{1..4}_x_blok.mem, _a_blok.mem ([n][8][128] 64 bit sozcuk), ln{1..4}_cikis.mem ([n][64][128] INT8 = z),
   rtl/ln_gamma.mem, ln_beta.mem (4 x 128, 16 bit), rtl/artik_ln_blogu.v ve artik_ln_ortak.v icindeki ln_harita bolgesi (eps, olcek ve yeniden olcekleme sabitleri)
Kullanim: python scripts/uret_ln_vektor.py
"""
import argparse, json, os, sys
import numpy as np

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJE = os.path.abspath(os.path.join(KOK, ".."))
KOD = os.path.join(PROJE, "02-RTL_Altin_Model", "01_Kod")
sys.path.insert(0, KOD)
import ortak  # noqa: E402
from altin import model, nicem, sabitler as S  # noqa: E402
from altin import dogrusal_olmayan as dol  # noqa: E402

OUT = os.environ.get("DOLGU_LN") or os.path.join(KOK, "vektor_ln")           # DOLGU_LN: baska cikti dizini (dolgu atlama vektorleri)
RTL = os.path.join(KOK, "rtl")
os.makedirs(OUT, exist_ok=True)

ap = ortak.ortak_argumanlar(argparse.ArgumentParser())
a = ap.parse_args([])
if os.environ.get("DOLGU_CIKIS"): a.cikis = os.environ["DOLGU_CIKIS"]            # test_vektorleri/kunye.json ve ara_olcekler.json burada
p, _, cumleler, etiket, ids, maske, y = ortak.yukle_hepsi(a)
ara = json.load(open(os.path.join(a.cikis, "ara_olcekler.json"), encoding="utf-8"))["olcekler"]
kunye = json.load(open(os.path.join(a.cikis, "test_vektorleri", "kunye.json"), encoding="utf-8"))
sec = kunye["cumle_idx"]
for _i, _n in zip(sec, kunye.get("uzat", [])): maske[_i, :_n] = 1                # 04_test_vektoru_uret.py --uzat ile ayni maske uzatmasi
n_c = len(sec)

olaylar = []
orj_ln = dol.katman_norm_tam
m = model.AltinModel(p, model.Ayarlar.B_kipi(tasima_adim=model.TASIMA_ADIMLARI), ara)
orj_tam = m._tam_yeniden


def tam_yakala(q, s_kaynak, s_hedef, *r, **kw):
    sonuc = orj_tam(q, s_kaynak, s_hedef, *r, **kw)
    olaylar.append(("tam", np.array(q), float(s_kaynak), float(s_hedef), np.array(sonuc), kw))
    return sonuc


def ln_yakala(q, girdi_olcek, gamma, beta, cikis_olcek, *r, **kw):
    c = orj_ln(q, girdi_olcek, gamma, beta, cikis_olcek, *r, **kw)
    olaylar.append(("ln", np.array(q), float(girdi_olcek), np.array(gamma), np.array(beta), float(cikis_olcek), np.array(c)))
    return c


m._tam_yeniden = tam_yakala
dol.katman_norm_tam = ln_yakala
try:
    m.ileri(ids[sec], maske[sec])
finally:
    dol.katman_norm_tam = orj_ln

ln_idx = [i for i, o in enumerate(olaylar) if o[0] == "ln"]
assert len(ln_idx) == 5, f"5 LayerNorm bekleniyordu (gomme + 4), bulunan {len(ln_idx)}"


def sabit(oran):
    """_tam_yeniden ile ayni (M0, n); olcekler esitse kimlik (M0=2^30, n=30)."""
    if abs(oran - 1.0) < 1e-12:
        return (1 << 30), 30
    return nicem.carpani_ayristir(oran, m.ayar.m0_bit)


def bloklu(x_int8):                       # [n][64][128] INT8 -> [n][8][128] 64 bit sozcuk (bayt i = token 8*blok+i)
    x = x_int8.reshape(n_c, 8, 8, 128)
    w = np.zeros((n_c, 8, 128), dtype=np.uint64)
    for i in range(8):
        w |= (x[:, :, i, :].astype(np.int64) & 0xFF).astype(np.uint64) << np.uint64(8 * i)
    return w


def ln_sabitleri(girdi_olcek, gamma, beta, cikis_olcek, g_bit=12, eps=S.LN_EPS):
    eps_q = max(int(round(eps / (girdi_olcek ** 2))), 1)
    gamma_q = np.rint(np.asarray(gamma, dtype=np.float64) * (1 << g_bit)).astype(np.int64)
    beta_q = np.rint(np.asarray(beta, dtype=np.float64) / cikis_olcek).astype(np.int64)
    M0, n = nicem.carpani_ayristir(float(1.0 / cikis_olcek) / (1 << (2 * g_bit)))
    return eps_q, gamma_q, beta_q, M0, n


gam_tum, bet_tum, harita = [], [], []
for j, i in enumerate(ln_idx[1:], start=1):          # 0: gomme LayerNorm (bilgisayarda)
    _, q, s_in, gamma, beta, s_out, yq = olaylar[i]
    t1, t2, tz = olaylar[i - 2], olaylar[i - 1], olaylar[i + 1]
    assert t1[0] == t2[0] == tz[0] == "tam", (j, t1[0], t2[0], tz[0])
    # artik toplam: iki akis LayerNorm giris olcegine tasinip toplanir
    assert abs(t1[3] - s_in) < 1e-12 and abs(t2[3] - s_in) < 1e-12
    assert np.array_equal(t1[4].astype(np.int64) + t2[4].astype(np.int64), q), "artik toplam q ile uyusmuyor"
    # sabitler (RTL ile ayni formul) ve dogrulama
    M0x, nx = sabit(t1[2] / t1[3]); M0a, na = sabit(t2[2] / t2[3])
    yenix = np.clip((t1[1].astype(np.int64) * M0x + (1 << (nx - 1))) >> nx, -(1 << 31), (1 << 31) - 1)
    yenia = np.clip((t2[1].astype(np.int64) * M0a + (1 << (na - 1))) >> na, -(1 << 31), (1 << 31) - 1)
    assert np.array_equal(yenix, t1[4]) and np.array_equal(yenia, t2[4]), "yeniden olcekleme formulu uyusmuyor"
    # LayerNorm sabitleri ve sonraki girisin yeniden olceklenmesi
    eps_q, gamma_q, beta_q, M0l, nl = ln_sabitleri(s_in, gamma, beta, s_out)
    assert np.array_equal(orj_ln(q, s_in, gamma, beta, s_out), yq)
    yq3 = yq.reshape(n_c, 64, 128)
    ilk_token = (tz[1].shape != yq.shape)               # son LayerNorm: havuz katmani yalniz ilk tokeni (sinif ogesi) kullanir
    if ilk_token:
        assert np.array_equal(tz[1].reshape(n_c, 128), yq3[:, 0, :]), "havuz girisi ilk token ile uyusmuyor"
    else:
        assert np.array_equal(tz[1], yq), "LayerNorm cikisi ile sonraki yeniden olcekleme girisi ayni degil"
    M0o, no = sabit(tz[2] / tz[3])
    z = np.clip((yq.astype(np.int64) * M0o + (1 << (no - 1))) >> no, S.AKT_MIN, S.AKT_MAX)
    zk = z.reshape(n_c, 64, 128)
    assert np.array_equal(zk[:, 0, :] if ilk_token else z, tz[4].reshape(n_c, 128) if ilk_token else tz[4]), "sonraki girdi yeniden olcekleme uyusmuyor"
    harita.append(dict(eps=eps_q, ml=M0l, nl=nl, mx=M0x, nx=nx, ma=M0a, na=na, mo=M0o, no=no, ilk=int(ilk_token)))
    gam_tum += [int(v) & 0xFFFF for v in gamma_q]; bet_tum += [int(v) & 0xFFFF for v in beta_q]
    assert np.abs(gamma_q).max() < 2 ** 15 and np.abs(beta_q).max() < 2 ** 15
    # test vektorleri
    x8 = t1[1].astype(np.int64).reshape(n_c, 64, 128); a8 = t2[1].astype(np.int64).reshape(n_c, 64, 128)
    assert x8.min() >= -128 and x8.max() <= 127 and a8.min() >= -128 and a8.max() <= 127
    for ad, v in ((f"ln{j}_x_blok.mem", bloklu(x8)), (f"ln{j}_a_blok.mem", bloklu(a8))):
        open(os.path.join(OUT, ad), "w").write("\n".join(f"{int(w):016x}" for w in v.reshape(-1)) + "\n")
    open(os.path.join(OUT, f"ln{j}_cikis.mem"), "w").write("\n".join(f"{int(v) & 0xFF:02x}" for v in z.reshape(-1)) + "\n")
    print(f"LN {j}: s_in={s_in:.5g} q aralik [{q.min()},{q.max()}] eps={eps_q} Mx={M0x}/{nx} Ma={M0a}/{na} Ml={M0l}/{nl} Mo={M0o}/{no}  dogrulama tamam")

RTL_YAZ = os.environ.get("DOLGU_RTL_YAZMA", "1") != "0"                 # 0: rtl/ altindaki sabit dosyalari yeniden yazma
if RTL_YAZ: open(os.path.join(RTL, "ln_gamma.mem"), "w").write("\n".join(f"{v:04x}" for v in gam_tum) + "\n")
if RTL_YAZ: open(os.path.join(RTL, "ln_beta.mem"), "w").write("\n".join(f"{v:04x}" for v in bet_tum) + "\n")
satir = ["// uret_ln_vektor.py tarafindan uretildi; elle duzenlemeyin", "localparam LN_SAYISI = 4;"]
for ad, anahtar, g in (("ln_eps", "eps", 40), ("ln_m0", "ml", 31), ("ln_n", "nl", 6), ("ln_x_m0", "mx", 31), ("ln_x_n", "nx", 6),
                       ("ln_a_m0", "ma", 31), ("ln_a_n", "na", 6), ("ln_o_m0", "mo", 31), ("ln_o_n", "no", 6), ("ln_yalniz_ilk_token", "ilk", 1)):
    satir.append(f"function [{g - 1}:0] {ad}; input integer i; begin case (i)")
    for j, h in enumerate(harita):
        satir.append(f"        {j}: {ad} = {g}'d{h[anahtar]};")
    satir.append(f"        default: {ad} = {g}'d0; endcase end endfunction")
if RTL_YAZ: open(os.path.join(RTL, "ln_harita.vh"), "w").write("\n".join(satir) + "\n")
print("cumle sayisi:", n_c, "| LN sabitleri:", harita[0])
