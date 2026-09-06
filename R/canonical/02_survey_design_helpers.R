# Survey design mechanics frozen by W06. Requires survey 4.5.
normalize_documented_weight_zero <- function(x) {
  y <- as.numeric(x)
  # Inherited W04 XPORT decoder repair: only survey-weight variables use this rule.
  y[is.finite(y) & y < 1] <- 0
  y
}
make_nhanes_design <- function(df, weight_var) {
  stopifnot(weight_var %in% names(df), all(c("SDMVSTRA","SDMVPSU") %in% names(df)))
  df[[weight_var]] <- normalize_documented_weight_zero(df[[weight_var]])
  keep <- is.finite(df[[weight_var]]) & df[[weight_var]] > 0
  d <- df[keep, , drop=FALSE]  # only zero/nonfinite selected weight may be removed before design creation
  f_w <- stats::as.formula(paste0("~", weight_var))
  survey::svydesign(ids=~SDMVPSU, strata=~SDMVSTRA, weights=f_w, data=d, nest=TRUE)
}
domain_df_nchs <- function(design) {
  v <- design$variables
  if (!all(c("SDMVSTRA","SDMVPSU") %in% names(v))) stop("DESIGN_VARIABLES_MISSING")
  p <- unique(v[c("SDMVSTRA","SDMVPSU")])
  ns <- length(unique(p$SDMVSTRA)); np <- nrow(p); df <- np - ns
  c(strata=ns, psus=np, df=df)
}
assert_primary_denominator_membership <- function(df, frozen_ids_path="locks/FROZEN_PRIMARY_ELIGIBLE_SEQN.txt") {
  ids <- scan(frozen_ids_path, what=integer(), quiet=TRUE)
  if (anyDuplicated(ids)) stop("FROZEN_ID_DUPLICATE")
  if (!"SEQN" %in% names(df)) stop("SEQN_MISSING")
  frozen <- df$SEQN %in% ids
  if (sum(frozen, na.rm=TRUE) != length(ids)) stop("FROZEN_ID_MEMBERSHIP_MISMATCH")
  frozen
}
