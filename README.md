# CKM-UACR reproducibility repository

> **Release-candidate status:** the scientific implementation is curated from the accepted W09/W10 lineage without changing scientific code. Final public release remains blocked until the exact W12 manuscript package/title is cross-checked and this cleaned runner is executed under the locked R runtime.

## Study title

**[EXACT FROZEN W12 MANUSCRIPT TITLE REQUIRED BEFORE PUBLIC RELEASE]**

The supplied code-curation archive did not contain the accepted W12 manuscript package. This release candidate therefore does not guess or promote an earlier working title as the final study title.

## Scientific objective

This repository implements the frozen descriptive analysis of the incremental CKM/KDIGO kidney-risk information obtained after adding measured urine albumin-to-creatinine ratio (UACR) to a noncircular, pre-UACR guideline-defined testing-candidate population. It is a **guideline-implementation/information-yield analysis**, not a causal effectiveness analysis.

A single UACR or eGFR measurement in NHANES does **not** establish chronic CKD. The repository must not be used to relabel one-time measurements as confirmed chronic disease.

## Data source

National Health and Nutrition Examination Survey (**NHANES August 2021-August 2023**), public-use CDC/NCHS files. Raw XPTs are not redistributed. Exact required filenames, official NCHS URLs, byte sizes, and SHA256s are frozen in `config/SOURCE_FILE_FREEZE.csv`.

## Locked software environment

- R **4.6.1**
- `survey` **4.5**
- `srvyr` **1.3.1**
- `foreign` **0.8-91** (XPT import only)
- `LC_ALL=C`, `TZ=UTC`
- `survey.lonely.psu="fail"`
- `survey.adjust.domain.lonely=FALSE`
- Python 3 standard library for download/SHA256 verification

See `requirements/` for the accepted runtime record. Package substitutions are not allowed for a frozen-result reproduction run.

## Why the analysis is not split into many rewritten scripts

The accepted W09 scientific implementation is one production script plus five frozen helper modules. Splitting that script into new variable/cohort/primary/secondary files would create unnecessary scientific-drift risk. Therefore `R/canonical/w09_analysis.R` and its helper files are copied **byte-for-byte** from the accepted W09 return. Public-facing wrappers handle only paths, data acquisition, staging, execution, and validation.

## Reproduction

From the repository root:

```bash
Rscript scripts/00_check_environment.R
Rscript scripts/run_all.R --download
```

If the 12 verified XPT files are already in `data/raw/`, omit `--download`:

```bash
Rscript scripts/run_all.R
```

The run fails loudly if the environment, source files, frozen denominator, canonical analysis, unit tests, or output validation does not match the lock.

## Expected frozen smoke checks

- pre-UACR main denominator: **n = 1,985**
- jointly analyzable primary population: **n = 1,851**
- primary T02 estimate: **10.3%**
- primary 95% CI: **8.8%-12.0%**
- locked T02 missingness identification bounds: **9.7%-15.6%**

These rounded values are smoke checks only. Exact machine-readable values in `validation/reference/W09_ACCEPTED/` control the release validator; discrepancies are not repaired by rounding.

## Repository map

- `R/canonical/` — untouched accepted W09 scientific code.
- `scripts/` — public wrappers for environment, official-data verification/download, staging, execution, and frozen-result validation.
- `config/` — frozen denominator, authorization state, data hashes/URLs, unit-test vectors, and non-scientific path/validation configuration.
- `validation/reference/W09_ACCEPTED/` — accepted result tables used for byte-level validation.
- `validation/reference/W10_ACCEPTED/` — independent red-team evidence; the accepted W10 v1.0.3 run independently reconstructed the analysis before comparison.
- `tests/` — synthetic eGFR/transition tests and frozen-result validation entrypoint.
- `provenance/` — canonical code hashes and behavior-preserving cleaning history; the full curator forensic ledger is retained outside the GitHub tree.
- `data/raw/` — local, ignored XPT inputs.
- `outputs/current/` — generated, ignored analysis outputs.

## Output-to-manuscript relationship

`PRIMARY_RESULTS.csv`, `SECONDARY_RESULTS.csv`, `SUBGROUP_RESULTS.csv`, `SENSITIVITY_RESULTS.csv`, `MISSINGNESS_RESULTS.csv`, and `IDENTIFICATION_BOUNDS.csv` are the accepted computational result families. The exact W12 reader-facing table/figure mapping was not present in the supplied code-curation bundle, so this repository does not invent a manuscript table or figure layer.

## Citation

`CITATION.cff` is included as a release-candidate placeholder. Replace its author/title citation fields with the exact frozen W12 manuscript metadata before public publication. No DOI or GitHub account is assumed.

## License

No public software license was supplied with the source bundle. `LICENSE` therefore preserves all rights pending an explicit license choice; select a public license before publishing this repository.

## Contact

No public contact address is included in this release candidate.
