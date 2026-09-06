# W06 authorization and exact-environment guard. No real-data inference may occur before this passes.
read_analysis_authorization_lock <- function(state_path = "PROJECT_STATE_SNAPSHOT.json") {
  if (!file.exists(state_path)) stop("STATE_FILE_MISSING: ", state_path)
  txt <- paste(readLines(state_path, warn = FALSE), collapse = "\n")
  m <- regexec('"ANALYSIS_AUTHORIZATION_LOCK"\\s*:\\s*"([^"]+)"', txt, perl = TRUE)
  hit <- regmatches(txt, m)[[1]]
  if (length(hit) != 2L) stop("ANALYSIS_AUTHORIZATION_LOCK_NOT_FOUND")
  hit[[2]]
}
assert_analysis_authorized <- function(state_path = "PROJECT_STATE_SNAPSHOT.json") {
  value <- read_analysis_authorization_lock(state_path)
  if (!identical(value, "PASS")) stop("INFERENTIAL_ANALYSIS_REFUSED: ANALYSIS_AUTHORIZATION_LOCK=", value, " (PASS required)")
  invisible(TRUE)
}
assert_exact_environment <- function() {
  if (!identical(as.character(getRversion()), "4.6.1")) stop("R_VERSION_MISMATCH expected=4.6.1 observed=", as.character(getRversion()))
  req <- c(survey="4.5", srvyr="1.3.1")
  for (p in names(req)) {
    if (!requireNamespace(p, quietly=TRUE)) stop("PACKAGE_MISSING: ", p)
    obs <- as.character(utils::packageVersion(p))
    if (!identical(obs, unname(req[[p]]))) stop("PACKAGE_VERSION_MISMATCH ",p," expected=",req[[p]]," observed=",obs)
  }
  Sys.setenv(TZ="UTC")
  loc <- suppressWarnings(Sys.setlocale("LC_ALL", "C"))
  if (is.na(loc) || !nzchar(loc)) stop("LOCALE_C_UNAVAILABLE")
  options(stringsAsFactors=FALSE, scipen=999,
          survey.lonely.psu="fail",
          survey.adjust.domain.lonely=FALSE)
  invisible(TRUE)
}
