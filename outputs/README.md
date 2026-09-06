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

The exact W12 publication-facing mapping is documented in `docs/MANUSCRIPT_OUTPUT_MAP.csv`. That file links the manuscript's cohort counts, seven-category Table 1, principal T02 estimate, UACR availability and secondary findings, age/sex subgroup statements, five prespecified sensitivity analyses, identification bounds, and Figure 1 values to the accepted W09 machine-readable output rows.

No separate manuscript-facing scientific computation layer has been invented: publication displays remain traceable to the frozen canonical result families above.
