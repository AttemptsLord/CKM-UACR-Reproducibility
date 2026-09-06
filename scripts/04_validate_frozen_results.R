#!/usr/bin/env Rscript
source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1]]), mustWork=TRUE)), "..", "R", "project_paths.R"))
root <- ckm_repo_root()
source(file.path(root,"config","analysis_config.R"))
out <- file.path(root,"outputs","current")
ref <- file.path(root,"validation","reference","W09_ACCEPTED")
if (!dir.exists(out)) stop("OUTPUT_DIRECTORY_MISSING: run analysis first")
read_raw <- function(p) { n <- file.info(p)$size; con <- file(p,"rb"); on.exit(close(con)); readBin(con,"raw",n=n) }
for (f in CKM_UACR_REFERENCE_FILES) {
  op <- file.path(out,f); rp <- file.path(ref,f)
  if (!file.exists(op)) stop("RESULT_MISSING: ",f)
  if (!identical(read_raw(op),read_raw(rp))) stop("FROZEN_RESULT_BYTE_MISMATCH: ",f)
}
ids <- scan(file.path(root,"config","FROZEN_PRIMARY_ELIGIBLE_SEQN.txt"),what=integer(),quiet=TRUE)
if (length(ids)!=CKM_UACR_EXPECTED$main_denominator_n || anyDuplicated(ids)) stop("MAIN_DENOMINATOR_MISMATCH")
p <- utils::read.csv(file.path(out,"PRIMARY_RESULTS.csv"),stringsAsFactors=FALSE)
t02 <- p[p$cell_id==CKM_UACR_EXPECTED$primary_cell,,drop=FALSE]
if (nrow(t02)!=1L) stop("PRIMARY_T02_ROW_MISSING_OR_DUPLICATE")
if (t02$n[[1]]!=CKM_UACR_EXPECTED$joint_analyzable_n) stop("JOINT_ANALYZABLE_N_MISMATCH")
for (nm in c("estimate_internal","ci_lower","ci_upper")) {
  exp <- CKM_UACR_EXPECTED[[switch(nm,estimate_internal="primary_estimate",ci_lower="primary_ci_lower",ci_upper="primary_ci_upper")]]
  if (!identical(as.numeric(t02[[nm]][[1]]), exp)) stop("PRIMARY_EXACT_VALUE_MISMATCH: ",nm)
}
b <- utils::read.csv(file.path(out,"IDENTIFICATION_BOUNDS.csv"),stringsAsFactors=FALSE)
b2 <- b[b$cell_id=="T02",,drop=FALSE]
if (nrow(b2)!=1L || !identical(as.numeric(b2$lower_bound[[1]]),CKM_UACR_EXPECTED$missingness_bound_lower) || !identical(as.numeric(b2$upper_bound[[1]]),CKM_UACR_EXPECTED$missingness_bound_upper)) stop("MISSINGNESS_BOUNDS_EXACT_MISMATCH")
# Publication-rounding smoke checks from frozen W12 instruction.
if (!identical(round(100*CKM_UACR_EXPECTED$primary_estimate,1),10.3)) stop("PRIMARY_ROUNDING_SMOKE_FAIL")
if (!identical(round(100*CKM_UACR_EXPECTED$primary_ci_lower,1),8.8) || !identical(round(100*CKM_UACR_EXPECTED$primary_ci_upper,1),12.0)) stop("PRIMARY_CI_ROUNDING_SMOKE_FAIL")
if (!identical(round(100*CKM_UACR_EXPECTED$missingness_bound_lower,1),9.7) || !identical(round(100*CKM_UACR_EXPECTED$missingness_bound_upper,1),15.6)) stop("BOUNDS_ROUNDING_SMOKE_FAIL")
# Reliability/context hierarchy is protected by byte equality; explicitly verify all result families that carry reliability fields.
for (f in c("PRIMARY_RESULTS.csv","SECONDARY_RESULTS.csv","SUBGROUP_RESULTS.csv","SENSITIVITY_RESULTS.csv","MISSINGNESS_RESULTS.csv")) {
  cur <- utils::read.csv(file.path(out,f), stringsAsFactors=FALSE)
  old <- utils::read.csv(file.path(ref,f), stringsAsFactors=FALSE)
  if (!all(c("reliability_action","reliability_flags") %in% names(cur))) stop("RELIABILITY_FIELDS_MISSING: ",f)
  if (!identical(cur$reliability_action,old$reliability_action) || !identical(cur$reliability_flags,old$reliability_flags)) stop("RELIABILITY_HIERARCHY_MISMATCH: ",f)
}
# The exact W12 reader-facing context-only/publication mapping is not present in this release candidate; repository_ready remains false until cross-checked.
cat("CKM_UACR_FROZEN_RESULT_VALIDATION: PASS denominator=1985 joint=1851 T02=10.3% CI=8.8%-12.0% bounds=9.7%-15.6% reference_tables=6
")
