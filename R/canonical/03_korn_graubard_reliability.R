# NCHS Korn-Graubard CI and deterministic W06 reliability translation.
clopper_pearson_actual_n <- function(events, n, level=0.95) {
  alpha <- 1-level
  lo <- if (events == 0) 0 else stats::qbeta(alpha/2, events, n-events+1)
  hi <- if (events == n) 1 else stats::qbeta(1-alpha/2, events+1, n-events)
  c(lower=lo, upper=hi)
}
korn_graubard_ci <- function(p, var_p, n, domain_df, level=0.95) {
  if (!is.finite(p) || p < 0 || p > 1 || n < 1 || domain_df <= 0) stop("KG_INVALID_INPUT")
  alpha <- 1-level
  if (p == 0 || p == 1) {
    ev <- if (p == 0) 0L else as.integer(n)
    ci <- clopper_pearson_actual_n(ev, as.integer(n), level)
    return(list(lower=ci[[1]], upper=ci[[2]], n_eff=NA_real_, n_eff_df=NA_real_, boundary=TRUE))
  }
  if (!is.finite(var_p) || var_p <= 0) stop("KG_NONPOSITIVE_VARIANCE")
  n_eff <- min(n, p*(1-p)/var_p)
  n_eff_df <- min(n, n_eff * (stats::qt(alpha/2, df=n-1) / stats::qt(alpha/2, df=domain_df))^2)
  x_eff <- n_eff_df * p
  lo <- stats::qbeta(alpha/2, x_eff, n_eff_df-x_eff+1)
  hi <- stats::qbeta(1-alpha/2, x_eff+1, n_eff_df-x_eff)
  list(lower=lo, upper=hi, n_eff=n_eff, n_eff_df=n_eff_df, boundary=FALSE)
}
qualify_nchs_proportion <- function(p, var_p, n, events, domain_df, force_context=FALSE) {
  ci <- korn_graubard_ci(p,var_p,n,domain_df,0.95)
  width <- ci$upper-ci$lower
  rel_width <- if (p > 0) 100*width/p else NA_real_
  flags <- character()
  hard <- FALSE
  if (n < 30) { flags <- c(flags,"N_LT30"); hard <- TRUE }
  if (!is.na(ci$n_eff) && ci$n_eff < 30) { flags <- c(flags,"NEFF_LT30"); hard <- TRUE }
  if (width >= 0.30) { flags <- c(flags,"CI_ABS_WIDTH_GE_0_30"); hard <- TRUE }
  if (p > 0 && width > 0.05 && width < 0.30 && rel_width > 130) { flags <- c(flags,"CI_REL_WIDTH_GT_130"); hard <- TRUE }
  complement_rel_width <- if (p < 1) 100*width/(1-p) else NA_real_
  if (p < 1 && width > 0.05 && width < 0.30 && complement_rel_width > 130) flags <- c(flags,"COMPLEMENT_UNRELIABLE_FOOTNOTE")
  if (events == 0) flags <- c(flags,"ZERO_EVENT","STATISTICAL_REVIEW_REQUIRED")
  if (events == n) flags <- c(flags,"ZERO_COMPLEMENT","STATISTICAL_REVIEW_REQUIRED","COMPLEMENT_UNRELIABLE_FOOTNOTE")
  if (domain_df < 8) flags <- c(flags,"DF_LT8","STATISTICAL_REVIEW_REQUIRED")
  action <- if (hard) "SUPPRESS" else if (force_context) "CONTEXT_ONLY" else if (events %in% c(0,n) || domain_df < 8) "FLAG_UNRELIABLE" else "REPORT"
  list(action=action, flags=unique(flags), lower=ci$lower, upper=ci$upper,
       n_eff=ci$n_eff, n_eff_df=ci$n_eff_df, abs_ci_width=width, rel_ci_width_pct=rel_width, complement_rel_ci_width_pct=complement_rel_width)
}
estimate_binary_kg <- function(design, variable_name, force_context=FALSE) {
  x <- design$variables[[variable_name]]
  if (anyNA(x) || any(!x %in% c(0,1))) stop("BINARY_INDICATOR_INVALID: ",variable_name)
  f <- stats::as.formula(paste0("~",variable_name))
  est <- survey::svymean(f, design, na.rm=FALSE)
  p <- as.numeric(stats::coef(est)[[1]]); var_p <- as.numeric(stats::vcov(est)[1,1])
  n <- length(x); events <- sum(x==1); d <- domain_df_nchs(design)
  q <- qualify_nchs_proportion(p,var_p,n,events,as.integer(d[["df"]]),force_context)
  c(list(estimate=p, variance=var_p, n=n, events=events, strata=d[["strata"]], psus=d[["psus"]], df=d[["df"]]), q)
}
