# NHANES input data

Raw XPT files are **not committed**. The frozen source cycle is **NHANES August 2021-August 2023**.

## Required official public-use files

| Component | Expected filename | Frozen official NCHS URL | Bytes | SHA256 |
|---|---|---|---:|---|
| `DEMO_L` | `DEMO_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/DEMO_L.xpt | 2582160 | `ca4374a158b493b8b0163e1388da21d57a18d1b9cecff2aa4e2fa2bec494fe23` |
| `BMX_L` | `BMX_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/BMX_L.xpt | 1563200 | `44440c416d9ad709e8b1708a5975378ab4d5b18edc39eb5015c2ae7186500170` |
| `GHB_L` | `GHB_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/GHB_L.xpt | 174000 | `67aee0353160e2392dc0a33bece99b90764a630c76d82415ac4639105ad9dd03` |
| `GLU_L` | `GLU_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/GLU_L.xpt | 129200 | `70f773ab37e3d8485341f32137e280e05b9279e5fe9b6f0362e4052d8fe9a201` |
| `TRIGLY_L` | `TRIGLY_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/TRIGLY_L.xpt | 321840 | `77679864c33b98d9b6db528f3a0ac0a15ea34bde9731c04d23bc9801277975f4` |
| `HDL_L` | `HDL_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/HDL_L.xpt | 259520 | `c1bb43df5ca366f470b411c043f4aee7ae6552a7f4bca1178bc87b24fb9a7300` |
| `BPXO_L` | `BPXO_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/BPXO_L.xpt | 696720 | `189aa9bed689d2c69cf8d780b01de85073276fea5694dd52cdf696229f9054a6` |
| `BPQ_L` | `BPQ_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/BPQ_L.xpt | 409680 | `0acde3af0526c375942fe0735e3bf69a0422bcbc606f98a478209d2f47baa4b5` |
| `BIOPRO_L` | `BIOPRO_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/BIOPRO_L.xpt | 2425520 | `912b345aad6b71d53a3bc299a7f3bb0d5530e9fa5b6e76d2d00103979861a476` |
| `MCQ_L` | `MCQ_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/MCQ_L.xpt | 3294000 | `0889bb3eaa5adedf1a11c4af2d4776fc4c4c3cfdeea24fcedb77c4636b478f61` |
| `DIQ_L` | `DIQ_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/DIQ_L.xpt | 847600 | `9535a023673ae869afae19d842d8679e06f6a464606ac15900686b41ef05090f` |
| `ALB_CR_L` | `ALB_CR_L.xpt` | https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/ALB_CR_L.xpt | 545440 | `fc011a80d14419884559372a3196f0a268b494f4f2fa972d00be1f3a23ba3c41` |

The table above is reproduced directly from the accepted W04 source freeze. The machine-readable controlling copy is [`config/SOURCE_FILE_FREEZE.csv`](../config/SOURCE_FILE_FREEZE.csv).

## Obtain and verify

Place all 12 files in `data/raw/`, then verify:

```bash
python3 scripts/01_download_or_locate_nhanes.py
```

Or download missing files from the frozen official URLs and verify them immediately:

```bash
python3 scripts/01_download_or_locate_nhanes.py --download
```

The verifier exits nonzero if a file is missing (without `--download`) or if byte size/SHA256 differs from the accepted W04 freeze. Do not substitute mirrors or differently versioned files for a frozen-result reproduction run.
