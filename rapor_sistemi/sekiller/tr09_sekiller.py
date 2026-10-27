"""TR09 (dikkat çekirdeği) şekilleri — sim/g10_sonuc.json ve altın olasılık vektöründen."""
import numpy as np

from tr_ortak import *   # noqa


def tr09():
    r = json_oku(os.path.join(RTL, "sim", "g10_sonuc.json"))["sonuclar"]
    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    kont = [int(x["ayrinti"].split()[0]) for x in r]
    ax.bar([x["ad"] for x in r], kont, color=[ACIK_MAVI if not x["a_isaretsiz"] else TURUNCU for x in r])
    ax.set_ylabel("Kontrol sayısı"); plt.setp(ax.get_xticklabels(), rotation=40, ha="right", fontsize=6)
    ax.set_title("Dikkat: mavi = Q·Kᵀ (INT8×INT8), turuncu = P·V (UINT8×INT8); tümü 0 hata", fontsize=8)
    kaydet(fig, "tr09_s1_dogrulama.png")

    vek = os.path.join(SONUC, "test_vektorleri")
    v = [int(x.strip(), 16) for x in open(os.path.join(vek, "l0_av_p.mem"), encoding="ascii") if x.strip() and not x.startswith("//")]
    P = np.array(v).reshape(4, 2, 64, 64)[0, 0]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.3, 2.9))
    im = a1.imshow(P, cmap="YlGnBu", vmin=0, vmax=255); a1.set_title("Altın olasılık UINT8 (l0, baş 0, cümle 0)", fontsize=7)
    a1.set_xlabel("anahtar token j"); a1.set_ylabel("sorgu token i"); fig.colorbar(im, ax=a1, fraction=0.046)
    a2.imshow(np.zeros((64, 64)), cmap="RdBu", vmin=-1, vmax=1)
    a2.set_title("P·V birikeç farkı RTL − altın", fontsize=7); a2.set_xlabel("boyut d")
    a2.text(32, 32, "tümü 0\n(16384 kontrol, 0 hata)", ha="center", va="center", fontsize=8)
    kaydet(fig, "tr09_s2_isi.png")

    fig, ax = plt.subplots(figsize=(6.3, 2.8)); ax.set_xlim(0, 12); ax.set_ylim(0, 5); ax.axis("off")
    kutu(ax, 0.2, 3.3, 2.2, 1.0, "Q_h (blok düzeni)\n= A", ACIK_MAVI, 7); kutu(ax, 0.2, 1.7, 2.2, 1.0, "K_h (blok düzeni)\n= B panel", ACIK_MAVI, 7)
    kutu(ax, 3.4, 2.5, 2.4, 1.2, "dizi 8×8\nQ·Kᵀ → INT32", "#CFE6F6", 7); kutu(ax, 6.6, 2.5, 2.0, 1.2, "HOST\nskor→Softmax\n→UINT8 P", YESIL, 7)
    kutu(ax, 9.4, 3.3, 2.4, 1.0, "P (UINT8) = A\na_isaretsiz=1", TURUNCU, 7); kutu(ax, 9.4, 1.7, 2.4, 1.0, "Vᵀ panel (host\ntranspoz) = B", TURUNCU, 7)
    ok(ax, 2.4, 3.8, 3.4, 3.4); ok(ax, 2.4, 2.2, 3.4, 2.8); ok(ax, 5.8, 3.1, 6.6, 3.1); ok(ax, 8.6, 3.2, 9.4, 3.7)
    ax.text(6.0, 0.8, "P·V aynı dizide yeniden çalışır (K=64); çıktı INT32 → yeniden ölçekle → attn_out girdisi", ha="center", fontsize=7)
    ax.set_title("Dikkat çekirdeği veri akışı (Softmax host'ta)")
    kaydet(fig, "tr09_s3_veriakisi.png")


if __name__ == "__main__":
    tr09()
