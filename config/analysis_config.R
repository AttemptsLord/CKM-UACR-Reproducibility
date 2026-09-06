# Public-repository path and validation configuration only.
# Scientific definitions remain in R/canonical/ and are byte-identical to accepted W09.
CKM_UACR_EXPECTED <- list(
  main_denominator_n = 1985L,
  joint_analyzable_n = 1851L,
  primary_cell = "T02",
  primary_estimate = 0.103172973415295,
  primary_ci_lower = 0.0879820038682535,
  primary_ci_upper = 0.119993423020615,
  missingness_bound_lower = 0.0966011488663732,
  missingness_bound_upper = 0.156357196461054
)
CKM_UACR_REFERENCE_FILES <- c(
  "PRIMARY_RESULTS.csv",
  "SECONDARY_RESULTS.csv",
  "SUBGROUP_RESULTS.csv",
  "SENSITIVITY_RESULTS.csv",
  "MISSINGNESS_RESULTS.csv",
  "IDENTIFICATION_BOUNDS.csv"
)
