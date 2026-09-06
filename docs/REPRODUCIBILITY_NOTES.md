# Reproducibility notes

## Accepted evidence lineage

- W09 production analysis: PASS; two complete immutable-source-to-results runs produced byte-identical analytic/result objects.
- W10 independent results red-team: final corrected v1.0.3 implementation reconstructed from raw official XPTs twice before opening W09; both independent runs were reproducible, and all **1,492** mapped W09 comparison fields passed the frozen equality/tolerance standard.
- W10 post-freeze analytic identity checks: eligible SEQN set, WTSAF2YR, UACR, eGFR, G, A, transition, missing-UACR coding, and joint-analyzable identity all passed.

## Equality policy in this public release candidate

The accepted W09 result CSVs were byte-identical across the original two runs. The cleaned repository therefore requires **byte equality** for all six published machine-readable result tables. It does not use a numerical tolerance to conceal drift.

The historical independent W10 audit used exact equality for counts/categories and a documented `<=1e-10` comparison tolerance for point estimates, CIs, and bounds. Those audit results are retained as evidence in `validation/reference/W10_ACCEPTED/`.

## Current curation-session limitation

The curation environment used to assemble this release candidate did not contain R. Therefore the newly cleaned wrappers could not be executed end-to-end here. The canonical scientific R files were instead checked by SHA256 against accepted W09, and the new source-input verifier was tested against the supplied frozen W04 XPT snapshot. An exact-runtime end-to-end run is a required manual release gate.

## W12 authority gap

The exact W12 manuscript package was not present in the supplied code archive and was not retrievable as a file during this curation session. The user-provided W12 smoke checks are enforced, but the exact final manuscript title/table/figure mapping and any W12-specific result manifest still require direct cross-check before public release.
