#!/usr/bin/env Rscript
source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1]]), mustWork=TRUE)), "..", "R", "project_paths.R"))
root <- ckm_repo_root()
out <- file.path(root,"outputs","current")
unlink(out, recursive=TRUE, force=TRUE)
dir.create(out, recursive=TRUE, showWarnings=FALSE)
rscript <- file.path(R.home("bin"), "Rscript")
args <- c(
  file.path(root,"R","canonical","w09_analysis.R"),
  file.path(root,"work","analysis_package"),
  out,
  file.path(root,"R","canonical")
)
status <- system2(rscript, shQuote(args))
if (status != 0) stop("CANONICAL_W09_ANALYSIS_FAILED status=",status)
cat("CKM_UACR_RUN_FROZEN_ANALYSIS: PASS
")
