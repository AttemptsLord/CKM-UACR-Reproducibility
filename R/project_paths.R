ckm_repo_root <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  f <- grep("^--file=", args, value = TRUE)
  if (length(f) != 1L) stop("REPO_ROOT_RESOLUTION_FAIL: script path unavailable")
  script <- normalizePath(sub("^--file=", "", f[[1]]), mustWork = TRUE)
  normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
}
