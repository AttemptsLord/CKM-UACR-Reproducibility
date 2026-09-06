#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)
source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1]]), mustWork=TRUE)), "..", "R", "project_paths.R"))
root <- ckm_repo_root()
rscript <- file.path(R.home("bin"),"Rscript")
run_r <- function(rel) {
  st <- system2(rscript, shQuote(file.path(root,rel)))
  if (st!=0) stop("PIPELINE_STEP_FAILED: ",rel," status=",st)
}
run_r("scripts/00_check_environment.R")
if ("--download" %in% args) {
  py <- Sys.which("python3"); if (!nzchar(py)) stop("python3 required for --download")
  st <- system2(py, c(shQuote(file.path(root,"scripts","01_download_or_locate_nhanes.py")),"--download"))
  if (st!=0) stop("NHANES_DOWNLOAD_FAILED")
}
run_r("scripts/02_stage_inputs.R")
run_r("tests/run_protocol_unit_tests.R")
run_r("scripts/03_run_frozen_analysis.R")
run_r("scripts/04_validate_frozen_results.R")
cat("CKM_UACR_RUN_ALL: PASS
")
