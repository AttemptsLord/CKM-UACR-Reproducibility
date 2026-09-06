#!/usr/bin/env Rscript
script <- file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1]]), mustWork=TRUE)), "..", "scripts", "04_validate_frozen_results.R")
status <- system2(file.path(R.home("bin"),"Rscript"), shQuote(script))
if (status!=0) quit(status=status)
