"""BERT-Tiny FPGA hızlandırıcısı — RTL altın (golden) referans modeli.

Kullanım:
    from altin import parametreler, model, veri
    p = parametreler.yukle(model_dizin, npz_yol, olcek_yol)
    m = model.AltinModel(p, model.Ayarlar(kip="A"))
    logit = m.ileri(ids, maske)
"""

from . import birimler, dogrusal_olmayan, model, nicem, parametreler, sabitler, veri  # noqa: F401

__all__ = ["sabitler", "nicem", "birimler", "dogrusal_olmayan",
           "parametreler", "model", "veri"]
