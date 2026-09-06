# Analysis workflow

1. **Environment gate** — exact R/package versions and survey options are checked.
2. **Source gate** — the 12 official NHANES XPTs are located or downloaded and checked against frozen W04 byte sizes and SHA256 hashes.
3. **Input staging** — the public-data files, accepted authorization state, and 1,985-participant frozen pre-UACR denominator lock are staged into the directory shape expected by the accepted W09 program.
4. **Synthetic protocol tests** — the frozen 2021 race-free CKD-EPI test vectors and complete G/A-to-T transition grid are checked without loading NHANES data.
5. **Canonical analysis** — the untouched accepted `R/canonical/w09_analysis.R` reconstructs variables and the pre-UACR denominator, verifies exact denominator membership before opening `ALB_CR_L`, then creates the analytic object and prespecified primary, secondary, subgroup, sensitivity, missingness, and identification-bound outputs.
6. **Frozen-result validation** — all six result CSVs must be byte-identical to the accepted W09 references; explicit W12 headline smoke checks and reliability/context hierarchy checks must also pass.

The public wrapper deliberately does not rewrite the scientific pipeline into cosmetically cleaner modules. That choice minimizes the risk of changing a frozen estimand, survey domain, factor level, missingness rule, or reliability decision.
