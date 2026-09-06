# Generated outputs

`outputs/current/` is created by `Rscript scripts/run_all.R` and is ignored by Git.

The canonical W09 analysis produces:

- `PRIMARY_RESULTS.csv` — primary E01 transition distribution (T01-T07); T02 is the frozen headline transition.
- `SECONDARY_RESULTS.csv` — prespecified S1-S5 results with reliability/context flags.
- `SUBGROUP_RESULTS.csv` — prespecified H1 age and H2 sex subgroup analyses.
- `SENSITIVITY_RESULTS.csv` — prespecified V1-V5 sensitivities.
- `MISSINGNESS_RESULTS.csv` — frozen-eligible missingness diagnostics.
- `IDENTIFICATION_BOUNDS.csv` — M1 missing-data identification bounds (not sampling confidence intervals).
- `objects/ANALYTIC_DATA.rds` — analytic object created after pre-UACR denominator verification and post-freeze UACR opening.
- `provenance/sessionInfo.txt` and `runtime_fields.tsv` — execution environment evidence.

The supplied code bundle did not include the exact W12 manuscript/table/figure mapping files. No manuscript-facing table or figure generator has therefore been invented in this release candidate.
