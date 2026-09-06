# Cleaning changelog

## Scientific code

- Copied accepted W09 `w09_analysis.R` byte-for-byte into `R/canonical/`.
- Copied the five frozen W06/W09 helper modules byte-for-byte into `R/canonical/`.
- Did **not** change estimands, eligibility, thresholds, factor levels, eGFR equation, survey weights/design, subgroup/sensitivity definitions, missingness rules, reliability rules, or rounding logic.

## Public-repository changes

- Replaced hard-coded/local shell orchestration with project-relative R wrappers.
- Replaced the source acquisition wrapper with a Python-standard-library downloader/verifier that reads the exact frozen W04 URL/hash manifest.
- Excluded raw XPTs from version control and documented how to obtain them.
- Added explicit environment checks and protocol unit-test entrypoints.
- Added accepted W09 machine-readable results as validation references.
- Added accepted final W10 red-team evidence as validation provenance, while excluding obsolete W10 auditor generations from runtime.
- Added byte-level result validation and explicit headline smoke checks.
- Removed `.DS_Store`, `__MACOSX`, AppleDouble metadata, local execution trees, temporary downloads, packaging-only scripts, and repeated copies from the public repository.
- Sanitized the accepted session-info record to remove machine-specific absolute library paths while retaining versions, platform, locale, timezone, and namespace versions.
- Did not create manuscript table/figure code because the exact W12 reader-facing mapping was not supplied.
- Did not invent a GitHub username, DOI, affiliation, ethics determination, public contact email, package-installation lockfile, or public software license.
