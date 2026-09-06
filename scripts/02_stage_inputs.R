#!/usr/bin/env Rscript
source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1]]), mustWork=TRUE)), "..", "R", "project_paths.R"))
root <- ckm_repo_root()
py <- Sys.which("python3")
if (!nzchar(py)) stop("PYTHON3_REQUIRED_FOR_SHA256_INPUT_CHECK")
status <- system2(py, shQuote(file.path(root,"scripts","01_download_or_locate_nhanes.py")), stdout="", stderr="")
if (status != 0) stop("NHANES_INPUT_VALIDATION_FAILED")
stage <- file.path(root,"work","analysis_package")
unlink(stage, recursive=TRUE, force=TRUE)
dir.create(file.path(stage,"analysis_inputs","source_xpt"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path(stage,"analysis_inputs","locks"), recursive=TRUE, showWarnings=FALSE)
files <- utils::read.csv(file.path(root,"config","SOURCE_FILE_FREEZE.csv"), stringsAsFactors=FALSE)$local_filename
for (f in files) {
  ok <- file.copy(file.path(root,"data","raw",f), file.path(stage,"analysis_inputs","source_xpt",f), overwrite=TRUE, copy.mode=FALSE, copy.date=FALSE)
  if (!ok) stop("INPUT_STAGE_COPY_FAIL: ", f)
}
if (!file.copy(file.path(root,"config","FROZEN_PRIMARY_ELIGIBLE_SEQN.txt"), file.path(stage,"analysis_inputs","locks","FROZEN_PRIMARY_ELIGIBLE_SEQN.txt"), overwrite=TRUE)) stop("DENOMINATOR_STAGE_COPY_FAIL")
if (!file.copy(file.path(root,"config","PROJECT_STATE.json"), file.path(stage,"PROJECT_STATE.json"), overwrite=TRUE)) stop("PROJECT_STATE_STAGE_COPY_FAIL")
cat("CKM_UACR_STAGE_INPUTS: PASS package=work/analysis_package
")
