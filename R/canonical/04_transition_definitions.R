# Post-freeze A categories and W05-locked T01-T07 transition map.
uacr_a_category <- function(urdact_mg_g) {
  x <- as.numeric(urdact_mg_g); out <- rep(NA_character_,length(x)); ok <- is.finite(x) & x >= 0
  out[ok & x < 30] <- "A1"
  out[ok & x >= 30 & x < 300] <- "A2"
  out[ok & x >= 300] <- "A3"
  factor(out, levels=c("A1","A2","A3"))
}
derive_e01_transition <- function(g, a) {
  gg <- as.character(g); aa <- as.character(a); out <- rep(NA_character_, max(length(gg),length(aa)))
  gg <- rep_len(gg,length(out)); aa <- rep_len(aa,length(out)); valid <- !is.na(gg) & !is.na(aa)
  out[valid & gg %in% c("G1","G2") & aa=="A1"] <- "T01"
  out[valid & gg %in% c("G1","G2") & aa %in% c("A2","A3")] <- "T02"
  out[valid & gg=="G3a" & aa %in% c("A1","A2")] <- "T03"
  out[valid & gg=="G3a" & aa=="A3"] <- "T04"
  out[valid & gg=="G3b" & aa=="A1"] <- "T05"
  out[valid & gg=="G3b" & aa %in% c("A2","A3")] <- "T06"
  out[valid & gg %in% c("G4","G5") & aa %in% c("A1","A2","A3")] <- "T07"
  factor(out, levels=c("T01","T02","T03","T04","T05","T06","T07"))
}
