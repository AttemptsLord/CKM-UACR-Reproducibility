# Reproducibility notes

## Accepted evidence lineage

- W09 production analysis: PASS; two complete immutable-source-to-results runs produced byte-identical analytic/result objects.
- W10 independent results red-team: final corrected v1.0.3 implementation reconstructed from raw official XPTs twice before opening W09; both independent runs were reproducible, and all **1,492** mapped W09 comparison fields passed the frozen equality/tolerance standard.
- W10 post-freeze analytic identity checks: eligible SEQN set, WTSAF2YR, UACR, eGFR, G, A, transition, missing-UACR coding, and joint-analyzable identity all passed.

## Equality policy

The accepted W09 result CSVs were byte-identical across the original two accepted runs. This repository therefore uses **byte equality** for the six frozen machine-readable result tables in the formal release validator. It does not use numerical rounding or a tolerance to conceal drift.

The historical independent W10 audit used exact equality for counts/categories and a documented `<=1e-10` comparison tolerance for point estimates, CIs, and bounds. Those audit results remain available as independent validation evidence in `validation/reference/W10_ACCEPTED/`.

## Publication-facing provenance

The W12 manuscript title and manuscript-output mapping are closed. `docs/MANUSCRIPT_OUTPUT_MAP.csv` traces the manuscript's cohort counts, Table 1 values, primary estimate, UACR availability and secondary findings, age/sex subgroup statements, all five prespecified sensitivity analyses, identification bounds, and Figure 1 values to the accepted W09 machine-readable result families.

## Final exact-environment release gate

A fresh public-release reproduction was executed in GitHub Actions on **Apple Silicon macOS arm64** using:

- R 4.6.1
- `survey` 4.5
- `srvyr` 1.3.1
- `foreign` 0.8-91
- `LC_ALL=C`
- `TZ=UTC`
- `survey.lonely.psu="fail"`
- `survey.adjust.domain.lonely=FALSE`

The successful run downloaded and SHA256-verified all 12 official NHANES inputs, passed the protocol unit tests, ran the canonical W09 analysis, reproduced the frozen denominator and headline result, and produced **byte-identical copies of all six accepted W09 result CSVs**.

Successful release-gate PASS lines:

```text
CKM_UACR_ENVIRONMENT: PASS R=4.6.1 survey=4.5 srvyr=1.3.1 foreign=0.8-91 LC_ALL=C TZ=UTC lonely=fail domain_adjust=FALSE
CKM_UACR_NHANES_INPUTS: PASS files=12
CKM_UACR_PROTOCOL_UNIT_TESTS: PASS egfr=8 transition_grid=18
W09_R_ANALYSIS_RUN: PASS primary_sum=0.99999999999999967 primary_joint_n=1851
CKM_UACR_RUN_FROZEN_ANALYSIS: PASS
CKM_UACR_FROZEN_RESULT_VALIDATION: PASS denominator=1985 joint=1851 T02=10.3% CI=8.8%-12.0% bounds=9.7%-15.6% reference_tables=6
CKM_UACR_RUN_ALL: PASS
```

All six byte comparisons also passed:

```text
PRIMARY_RESULTS.csv: BYTE_IDENTICAL
SECONDARY_RESULTS.csv: BYTE_IDENTICAL
SUBGROUP_RESULTS.csv: BYTE_IDENTICAL
SENSITIVITY_RESULTS.csv: BYTE_IDENTICAL
MISSINGNESS_RESULTS.csv: BYTE_IDENTICAL
IDENTIFICATION_BOUNDS.csv: BYTE_IDENTICAL
```

See `docs/RELEASE_VALIDATION.md` for workflow/run/artifact identifiers.

## Cross-platform note

An earlier Linux x86_64 CI trial using the same R/package versions completed the canonical scientific analysis and reproduced the frozen denominator/headline result, but differed at a few final floating-point serialization digits and therefore correctly failed the byte-equality validator. No reference files or scientific code were changed to accommodate that platform difference.

The formal **exact byte-reproduction** release gate is therefore platform-locked to the accepted Apple Silicon macOS family. The successful arm64 macOS run demonstrates the intended exact reproduction contract.

## Release status

Static publication/security gates, title synchronization, manuscript-output mapping, authorized `CITATION.cff`, MIT licensing, and the exact-environment execution gate have all passed. **Repository visibility is public.** The public release is available at `https://github.com/AttemptsLord/CKM-UACR-Reproducibility`.
