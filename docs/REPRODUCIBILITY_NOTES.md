# Reproducibility notes

## Accepted evidence lineage

- W09 production analysis: PASS; two complete immutable-source-to-results runs produced byte-identical analytic/result objects.
- W10 independent results red-team: final corrected v1.0.3 implementation reconstructed from raw official XPTs twice before opening W09; both independent runs were reproducible, and all **1,492** mapped W09 comparison fields passed the frozen equality/tolerance standard.
- W10 post-freeze analytic identity checks: eligible SEQN set, WTSAF2YR, UACR, eGFR, G, A, transition, missing-UACR coding, and joint-analyzable identity all passed.

## Equality policy in this public release candidate

The accepted W09 result CSVs were byte-identical across the original two runs. The cleaned repository therefore requires **byte equality** for all six published machine-readable result tables. It does not use a numerical tolerance to conceal drift.

The historical independent W10 audit used exact equality for counts/categories and a documented `<=1e-10` comparison tolerance for point estimates, CIs, and bounds. Those audit results are retained as evidence in `validation/reference/W10_ACCEPTED/`.

## Current release-gate status

The W12 manuscript title and publication-facing manuscript-output mapping have now been cross-checked and closed. `docs/MANUSCRIPT_OUTPUT_MAP.csv` traces the manuscript's cohort counts, Table 1 values, primary estimate, UACR availability and secondary findings, subgroup statements, all five sensitivity analyses, identification bounds, and Figure 1 values to the accepted W09 machine-readable result families.

The repository remains **private** pending one final gate: a fresh end-to-end run under the exact locked runtime (R 4.6.1, `survey` 4.5, `srvyr` 1.3.1, `foreign` 0.8-91, `LC_ALL=C`, `TZ=UTC`). The static release audit passed, the MIT License has been explicitly authorized, and the public-release metadata have been prepared.
