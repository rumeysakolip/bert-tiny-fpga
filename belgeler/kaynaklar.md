# Kaynaklar: kod, model ve veri

## Model kodu (GitHub)

| Kaynak | Ne işe yarar |
|---|---|
| [google-research/bert](https://github.com/google-research/bert) | BERT-Tiny'nin resmi kaynağı (TensorFlow). README'deki tabloda BERT-Tiny = `uncased_L-2_H-128_A-2`; GLUE skorları ve ince ayar ayarları burada. |
| [huggingface/transformers — modeling_bert.py](https://github.com/huggingface/transformers/blob/main/src/transformers/models/bert/modeling_bert.py) | Projede kullanılan PyTorch BERT kodu. Katmanların (Q/K/V, dikkat, FFN, LayerNorm) nasıl hesaplandığını görmek ve Python referans modelini yazmak için okunmalı. |
| [prajjwal1/generalize_lm_nli](https://github.com/prajjwal1/generalize_lm_nli) | Google TF ağırlıklarını PyTorch'a çeviren ve `prajjwal1/bert-tiny` modelini yayımlayan çalışmanın deposu. |
| [huggingface/transformers — text-classification örneği](https://github.com/huggingface/transformers/tree/main/examples/pytorch/text-classification) | `run_glue.py`: GLUE görevlerinde standart ince ayar betiği (karşılaştırma için). |

## Hazır ağırlıklar

- [prajjwal1/bert-tiny](https://huggingface.co/prajjwal1/bert-tiny): PyTorch, MIT lisansı (projede bu kullanılıyor)
- [google/bert_uncased_L-2_H-128_A-2](https://huggingface.co/google/bert_uncased_L-2_H-128_A-2): Google'ın HF üzerindeki resmi kopyası (aynı mimari)

## Veri seti

- [nyu-mll/glue — sst2](https://huggingface.co/datasets/nyu-mll/glue): `load_dataset("nyu-mll/glue", "sst2")`
  - train 67.349 / validation 872 / test 1.821 (test etiketsiz, label = -1)
  - Sütunlar: `sentence`, `label` (0 olumsuz, 1 olumlu), `idx`
- Alternatif ham dosya: GLUE SST-2.zip (`train.tsv`, `dev.tsv`) → `--data_dir` ile verilebilir
- Orijinal kaynak: Socher ve ark. (2013), Stanford Sentiment Treebank

## Literatür (G6–G7)

- Turc ve ark., 2019 — *Well-Read Students Learn Better* — arXiv:1908.08962
- Jacob ve ark., 2018 — *Quantization and Training of Neural Networks for Efficient Integer-Arithmetic-Only Inference* — arXiv:1712.05877
- Zafrir ve ark., 2019 — *Q8BERT* — arXiv:1910.06188
- Kim ve ark., 2021 — *I-BERT: Integer-only BERT Quantization* — arXiv:2101.01321
- Kung, 1982 — *Why Systolic Architectures?* — IEEE Computer
- Jouppi ve ark., 2017 — *In-Datacenter Performance Analysis of a Tensor Processing Unit* — arXiv:1704.04760
- Li ve ark., 2020 — *FTRANS: Energy-Efficient Acceleration of Transformers using FPGA* — arXiv:2007.08563
