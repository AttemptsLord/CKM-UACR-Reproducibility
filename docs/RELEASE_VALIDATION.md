# Public-release reproducibility validation

## Successful exact-environment run

- Repository: `AttemptsLord/CKM-UACR-Reproducibility`
- Workflow: `CKM-UACR frozen reproducibility gate`
- Workflow file: `.github/workflows/reproducibility-gate.yml`
- GitHub Actions run ID: `34047759657`
- Run number: `2`
- Head commit tested: `ce5ca4192905e1c1f03eae36de70572f75a88fc4`
- Result: **SUCCESS**
- Runner family: GitHub-hosted `macos-15`, Apple Silicon arm64
- macOS during run: 15.7.9 (Build 24G830)
- R platform: `aarch64-apple-darwin23`
- R: 4.6.1
- `survey`: 4.5
- `srvyr`: 1.3.1
- `foreign`: 0.8-91
- `LC_ALL=C`
- `TZ=UTC`

## Data-input verification

All 12 frozen official NHANES source files were downloaded from the URLs in `config/SOURCE_FILE_FREEZE.csv` and passed the frozen byte-size/SHA256 checks.

```text
CKM_UACR_NHANES_INPUTS: PASS files=12
```

Raw XPT inputs and generated outputs remain ignored and are not committed.

## Protocol and scientific execution

```text
CKM_UACR_PROTOCOL_UNIT_TESTS: PASS egfr=8 transition_grid=18
W09_R_ANALYSIS_RUN: PASS primary_sum=0.99999999999999967 primary_joint_n=1851
CKM_UACR_RUN_FROZEN_ANALYSIS: PASS
CKM_UACR_FROZEN_RESULT_VALIDATION: PASS denominator=1985 joint=1851 T02=10.3% CI=8.8%-12.0% bounds=9.7%-15.6% reference_tables=6
CKM_UACR_RUN_ALL: PASS
```

## Byte-equality result

Each generated publication result family was compared directly with its accepted W09 reference file:

```text
PRIMARY_RESULTS.csv: BYTE_IDENTICAL
SECONDARY_RESULTS.csv: BYTE_IDENTICAL
SUBGROUP_RESULTS.csv: BYTE_IDENTICAL
SENSITIVITY_RESULTS.csv: BYTE_IDENTICAL
MISSINGNESS_RESULTS.csv: BYTE_IDENTICAL
IDENTIFICATION_BOUNDS.csv: BYTE_IDENTICAL
```

No scientific code or accepted reference file was modified to achieve the pass.

## Evidence artifact

GitHub Actions artifact:

- Artifact ID: `9993629996`
- Name: `ckm-uacr-release-gate-evidence-macos-arm64`
- SHA256 digest: `b30d5d2b0cca016cadf94f4c1cbf709767a766d9f1e988436b230ab1f7b6ea14`
- Created: 2026-09-06T17:11:30Z
- Scheduled expiration: 2026-12-05T17:10:20Z

The artifact contains the six generated result CSVs plus exact environment, workflow, byte-comparison, and run logs. It is evidence rather than a permanent scientific authority; the repository's accepted reference files and provenance remain controlling.

## Platform note

A preceding Ubuntu x86_64 trial successfully downloaded/verified all 12 sources, passed the protocol tests, and completed the canonical analysis, but failed the intentionally strict byte-equality validator because a few floating-point values serialized in the last decimal digit differently from the accepted Apple Silicon macOS reference files. The accepted references were not modified. The exact public-release reproduction contract is consequently documented as Apple Silicon macOS arm64.

## Release state

At this stage:

- frozen science: unchanged;
- canonical W09 scientific code: unchanged;
- W09 accepted references: unchanged;
- manuscript-output provenance map: present;
- static privacy/security audit: passed;
- private credentialing/reference information exposed: none detected;
- `CITATION.cff`: populated with authorized public metadata;
- software license: MIT, explicitly authorized;
- exact end-to-end execution: passed;
- repository visibility: **private** pending explicit publication authorization.
