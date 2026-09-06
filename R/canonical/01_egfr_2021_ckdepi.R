# 2021 CKD-EPI creatinine equation without race; NIDDK/CKD-EPI source-locked by W06.
ckd_epi_2021_cr <- function(scr_mg_dl, age_years, sex_riagendr) {
  n <- max(length(scr_mg_dl), length(age_years), length(sex_riagendr))
  scr <- rep_len(as.numeric(scr_mg_dl), n)
  age <- rep_len(as.numeric(age_years), n)
  sex <- rep_len(as.integer(sex_riagendr), n)
  out <- rep(NA_real_, n)
  valid <- is.finite(scr) & scr > 0 & is.finite(age) & age >= 18 & sex %in% c(1L,2L)
  kappa <- ifelse(sex == 2L, 0.7, 0.9)
  alpha <- ifelse(sex == 2L, -0.241, -0.302)
  sex_mult <- ifelse(sex == 2L, 1.012, 1.0)
  ratio <- scr / kappa
  out[valid] <- 142 * pmin(ratio[valid],1)^alpha[valid] *
    pmax(ratio[valid],1)^(-1.200) * (0.9938^age[valid]) * sex_mult[valid]
  out
}
creatinine_umol_l_to_mg_dl <- function(x) as.numeric(x) / 88.4
ckd_g_category <- function(egfr) {
  x <- as.numeric(egfr); out <- rep(NA_character_, length(x)); ok <- is.finite(x) & x >= 0
  out[ok & x >= 90] <- "G1"
  out[ok & x >= 60 & x < 90] <- "G2"
  out[ok & x >= 45 & x < 60] <- "G3a"
  out[ok & x >= 30 & x < 45] <- "G3b"
  out[ok & x >= 15 & x < 30] <- "G4"
  out[ok & x < 15] <- "G5"
  factor(out, levels=c("G1","G2","G3a","G3b","G4","G5"))
}
