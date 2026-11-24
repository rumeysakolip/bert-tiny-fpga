"""Parametre yükleme: FP32 ağırlıklar + INT8 nicemleme çıktıları.

Kaynaklar (hepsi 01-INT8_Nicemleme adımının çıktısı):
  * model.safetensors        -> gömme tabloları, LayerNorm gamma/beta, FP32 ağırlıklar
  * int8_agirliklar.npz      -> w_q, bias_q, w_olcek, a_olcek (14 Linear katman)
  * olcekler.json            -> aynı ölçekler + kalibrasyon istatistikleri

Gömme tablosu FPGA'ya KONMAZ: 30522 x 128 INT8 ~= 3.9 MB, Basys3'ün 225 KB
BRAM'ine sığmaz. Donanıma giren veri, ana bilgisayarda aranmış gömme
vektörleridir (64 x 128). Bu dosya o ayrımı açık tutar: `gomme_ileri`
ana bilgisayar tarafı, geri kalan her şey FPGA tarafıdır.
"""

from __future__ import annotations

import json
import os
from dataclasses import dataclass, field

import numpy as np
from safetensors.numpy import load_file

from . import sabitler as S
from .birimler import LineerKatman


@dataclass
class KatmanParametreleri:
    """Bir encoder katmanının tüm parametreleri."""
    q: LineerKatman
    k: LineerKatman
    v: LineerKatman
    attn_cikis: LineerKatman
    ffn1: LineerKatman
    ffn2: LineerKatman
    attn_ln_gamma: np.ndarray
    attn_ln_beta: np.ndarray
    cikis_ln_gamma: np.ndarray
    cikis_ln_beta: np.ndarray


@dataclass
class Parametreler:
    kelime_gomme: np.ndarray
    konum_gomme: np.ndarray
    tip_gomme: np.ndarray
    gomme_ln_gamma: np.ndarray
    gomme_ln_beta: np.ndarray
    katmanlar: list[KatmanParametreleri]
    pooler: LineerKatman
    siniflandirici: LineerKatman
    fp32: dict = field(default_factory=dict)
    olcekler: dict = field(default_factory=dict)

    # -- ana bilgisayar tarafı: gömme araması ---------------------------------
    def gomme_ileri(self, ids: np.ndarray, tip_ids: np.ndarray | None = None) -> np.ndarray:
        """(B, S) token kimlikleri -> (B, S, 128) FP32 gömme (LayerNorm'dan önce)."""
        B, Sq = ids.shape
        if tip_ids is None:
            tip_ids = np.zeros_like(ids)
        konum = np.arange(Sq)
        return (self.kelime_gomme[ids]
                + self.konum_gomme[konum][None, :, :]
                + self.tip_gomme[tip_ids]).astype(np.float32)


def _lineer(ad: str, z, olcekler: dict) -> LineerKatman:
    return LineerKatman(
        ad=ad,
        w_q=z[f"{ad}.w_q"].astype(np.int8),
        bias_q=z[f"{ad}.bias_q"].astype(np.int64),
        a_olcek=float(z[f"{ad}.a_scale"]),
        w_olcek=z[f"{ad}.w_scale"].astype(np.float64),
        a_sifir=int(z[f"{ad}.a_zp"]),
    )


def yukle(model_dizin: str, npz_yol: str, olcek_yol: str | None = None) -> Parametreler:
    sd = load_file(os.path.join(model_dizin, "model.safetensors"))
    z = np.load(npz_yol)
    olcekler = {}
    if olcek_yol and os.path.exists(olcek_yol):
        with open(olcek_yol, encoding="utf-8") as f:
            olcekler = json.load(f)

    katmanlar = []
    for i in range(S.KATMAN_SAYISI):
        p = f"bert.encoder.layer.{i}"
        katmanlar.append(KatmanParametreleri(
            q=_lineer(f"{p}.attention.self.query", z, olcekler),
            k=_lineer(f"{p}.attention.self.key", z, olcekler),
            v=_lineer(f"{p}.attention.self.value", z, olcekler),
            attn_cikis=_lineer(f"{p}.attention.output.dense", z, olcekler),
            ffn1=_lineer(f"{p}.intermediate.dense", z, olcekler),
            ffn2=_lineer(f"{p}.output.dense", z, olcekler),
            attn_ln_gamma=sd[f"{p}.attention.output.LayerNorm.weight"],
            attn_ln_beta=sd[f"{p}.attention.output.LayerNorm.bias"],
            cikis_ln_gamma=sd[f"{p}.output.LayerNorm.weight"],
            cikis_ln_beta=sd[f"{p}.output.LayerNorm.bias"],
        ))

    return Parametreler(
        kelime_gomme=sd["bert.embeddings.word_embeddings.weight"],
        konum_gomme=sd["bert.embeddings.position_embeddings.weight"],
        tip_gomme=sd["bert.embeddings.token_type_embeddings.weight"],
        gomme_ln_gamma=sd["bert.embeddings.LayerNorm.weight"],
        gomme_ln_beta=sd["bert.embeddings.LayerNorm.bias"],
        katmanlar=katmanlar,
        pooler=_lineer("bert.pooler.dense", z, olcekler),
        siniflandirici=_lineer("classifier", z, olcekler),
        fp32={k: v for k, v in sd.items()},
        olcekler=olcekler,
    )
