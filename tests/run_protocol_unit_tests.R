#!/usr/bin/env Rscript
source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1]]), mustWork=TRUE)), "..", "R", "project_paths.R"))
root <- ckm_repo_root()
source(file.path(root,"R","canonical","01_egfr_2021_ckdepi.R"))
source(file.path(root,"R","canonical","04_transition_definitions.R"))
t <- utils::read.csv(file.path(root,"config","EGFR_UNIT_TESTS.csv"), stringsAsFactors=FALSE)
scr <- ifelse(t$input_unit=="micromol/L", creatinine_umol_l_to_mg_dl(t$scr_input), t$scr_input)
obs <- ckd_epi_2021_cr(scr,t$age_years,t$RIAGENDR)
if (any(abs(obs-as.numeric(t$expected_egfr_ml_min_1_73m2)) > as.numeric(t$absolute_tolerance))) stop("EGFR_UNIT_TEST_FAIL")
g <- rep(c("G1","G2","G3a","G3b","G4","G5"),each=3); a <- rep(c("A1","A2","A3"),6)
tr <- derive_e01_transition(g,a)
if (anyNA(tr) || !all(levels(tr)==c("T01","T02","T03","T04","T05","T06","T07"))) stop("TRANSITION_UNIT_TEST_FAIL")
cat("CKM_UACR_PROTOCOL_UNIT_TESTS: PASS egfr=8 transition_grid=18
")
