# Runtime requirements

The accepted W09/W10 analysis lineage used **R 4.6.1**, `survey` **4.5**, `srvyr` **1.3.1**, and `foreign` **0.8-91**, with `LC_ALL=C`, `TZ=UTC`, `survey.lonely.psu="fail"`, and `survey.adjust.domain.lonely=FALSE`.

`foreign` is used only to import NHANES XPT files. The estimation code is locked to `survey` 4.5; package substitution is not permitted for a frozen-result reproduction run.

The supplied forensic bundle did not include a package-manager lockfile or a validated package-installation recipe. Therefore this repository checks the exact versions but does **not** invent an installation source or `renv.lock`. Install the exact versions using a trusted R package archive/source appropriate to your system, then run `Rscript scripts/00_check_environment.R`.

The accepted run was recorded on an ARM64 macOS platform. The frozen R code itself does not explicitly require that OS, but a non-macOS execution has not been independently accepted as an exact-runtime reproduction in the supplied lineage.
