#!/usr/bin/env Rscript
source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1]]), mustWork=TRUE)), "..", "R", "project_paths.R"))
root <- ckm_repo_root()
fail <- character()
if (!identical(as.character(getRversion()), "4.6.1")) fail <- c(fail, paste0("R expected 4.6.1 observed ", getRversion()))
req <- c(survey="4.5", srvyr="1.3.1", foreign="0.8.91")
for (p in names(req)) {
  if (!requireNamespace(p, quietly=TRUE)) fail <- c(fail, paste0("missing package ", p))
  else if (!identical(as.character(utils::packageVersion(p)), unname(req[[p]]))) fail <- c(fail, paste0(p," expected ",req[[p]]," observed ",utils::packageVersion(p)))
}
Sys.setenv(TZ="UTC")
loc <- suppressWarnings(Sys.setlocale("LC_ALL", "C"))
if (is.na(loc) || !nzchar(loc)) fail <- c(fail, "LC_ALL=C unavailable")
options(survey.lonely.psu="fail", survey.adjust.domain.lonely=FALSE)
if (length(fail)) { cat("CKM_UACR_ENVIRONMENT: FAIL
", paste0("- ",fail,collapse="
"),"
",sep=""); quit(status=1) }
cat("CKM_UACR_ENVIRONMENT: PASS R=4.6.1 survey=4.5 srvyr=1.3.1 foreign=0.8-91 LC_ALL=C TZ=UTC lonely=fail domain_adjust=FALSE
")
cat("platform=", R.version$platform, "
", sep="")
