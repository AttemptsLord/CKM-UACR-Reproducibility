#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 3L) stop("usage: w09_analysis.R PACKAGE_ROOT OUT_DIR CODE_DIR")
pkg <- normalizePath(args[[1]], mustWork=TRUE)
out <- args[[2]]
code <- normalizePath(args[[3]], mustWork=TRUE)
dir.create(out, recursive=TRUE, showWarnings=FALSE)
dir.create(file.path(out,"objects"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path(out,"provenance"), recursive=TRUE, showWarnings=FALSE)

source(file.path(code,"00_protocol_guard.R"))
assert_analysis_authorized(file.path(pkg,"PROJECT_STATE.json"))
assert_exact_environment()
source(file.path(code,"01_egfr_2021_ckdepi.R"))
source(file.path(code,"02_survey_design_helpers.R"))
source(file.path(code,"03_korn_graubard_reliability.R"))
source(file.path(code,"04_transition_definitions.R"))

if (!requireNamespace("foreign", quietly=TRUE)) stop("IMPORT_NAMESPACE_MISSING: foreign")
if (!identical(as.character(getRversion()),"4.6.1")) stop("R_VERSION_DRIFT")
if (!identical(as.character(utils::packageVersion("survey")),"4.5")) stop("SURVEY_VERSION_DRIFT")
if (!identical(as.character(utils::packageVersion("srvyr")),"1.3.1")) stop("SRVYR_VERSION_DRIFT")
if (!identical(getOption("survey.lonely.psu"),"fail")) stop("LONELY_PSU_OPTION_DRIFT")
if (!identical(getOption("survey.adjust.domain.lonely"),FALSE)) stop("DOMAIN_LONELY_OPTION_DRIFT")
if (!identical(Sys.getenv("TZ"),"UTC")) stop("TZ_DRIFT")
if (!grepl("^C$", Sys.getlocale("LC_ALL"))) stop("LOCALE_DRIFT: ",Sys.getlocale("LC_ALL"))

src <- file.path(pkg,"analysis_inputs","source_xpt")
frozen_ids_path <- file.path(pkg,"analysis_inputs","locks","FROZEN_PRIMARY_ELIGIBLE_SEQN.txt")

resolve_col <- function(d, logical) {
  if (logical %in% names(d)) return(logical)
  hits <- names(d)[toupper(names(d)) == toupper(logical)]
  if (length(hits) != 1L) stop("COLUMN_RESOLUTION_FAIL ",logical," hits=",paste(hits,collapse=";"))
  hits[[1]]
}
read_select <- function(fid, vars) {
  p <- file.path(src,paste0(fid,".xpt"))
  d <- foreign::read.xport(p)
  actual <- vapply(vars, function(v) resolve_col(d,v), character(1))
  z <- d[actual]
  names(z) <- vars
  z
}
left_join_seqn <- function(x,y) {
  if (anyDuplicated(x$SEQN) || anyDuplicated(y$SEQN)) stop("SEQN_DUPLICATE")
  idx <- match(x$SEQN,y$SEQN)
  for (nm in setdiff(names(y),"SEQN")) x[[nm]] <- y[[nm]][idx]
  x
}
obs_eq <- function(x,v) is.finite(as.numeric(x)) & as.numeric(x)==v
obs_ge <- function(x,v) is.finite(as.numeric(x)) & as.numeric(x)>=v
obs_lt <- function(x,v) is.finite(as.numeric(x)) & as.numeric(x)<v
obs_between <- function(x,lo,hi) is.finite(as.numeric(x)) & as.numeric(x)>=lo & as.numeric(x)<=hi
row_mean_available <- function(d, vars) {
  m <- as.matrix(d[vars]); storage.mode(m) <- "double"
  nobs <- rowSums(is.finite(m))
  z <- rowMeans(m, na.rm=TRUE); z[nobs==0] <- NA_real_; z
}

select <- list(
  DEMO_L=c("SEQN","RIDAGEYR","RIAGENDR","RIDRETH3","SDMVSTRA","SDMVPSU","WTMEC2YR"),
  BMX_L=c("SEQN","BMXBMI","BMXWAIST"),
  GHB_L=c("SEQN","WTPH2YR","LBXGH"),
  GLU_L=c("SEQN","WTSAF2YR","LBXGLU"),
  TRIGLY_L=c("SEQN","LBXTLG"),
  HDL_L=c("SEQN","LBDHDD"),
  BPXO_L=c("SEQN","BPXOSY1","BPXOSY2","BPXOSY3","BPXODI1","BPXODI2","BPXODI3"),
  BPQ_L=c("SEQN","BPQ030","BPQ150"),
  BIOPRO_L=c("SEQN","LBXSCR"),
  MCQ_L=c("SEQN","MCQ160b","MCQ160c","MCQ160d","MCQ160e","MCQ160f"),
  DIQ_L=c("SEQN","DIQ010")
)
pre_order <- names(select)
frames <- lapply(pre_order, function(fid) read_select(fid,select[[fid]])); names(frames)<-pre_order
frames$GHB_L$WTPH2YR <- normalize_documented_weight_zero(frames$GHB_L$WTPH2YR)
frames$GLU_L$WTSAF2YR <- normalize_documented_weight_zero(frames$GLU_L$WTSAF2YR)
x <- frames$DEMO_L
for (fid in pre_order[-1]) x <- left_join_seqn(x,frames[[fid]])

adult <- obs_ge(x$RIDAGEYR,18)
asian <- obs_eq(x$RIDRETH3,6)
male <- obs_eq(x$RIAGENDR,1); female <- obs_eq(x$RIAGENDR,2)
sbp <- row_mean_available(x,c("BPXOSY1","BPXOSY2","BPXOSY3"))
dbp <- row_mean_available(x,c("BPXODI1","BPXODI2","BPXODI3"))
bp <- obs_ge(sbp,130) | obs_ge(dbp,80) | obs_eq(x$BPQ150,1)
bp_hist <- obs_eq(x$BPQ030,1) | obs_eq(x$BPQ150,1)
egfr_pre <- ckd_epi_2021_cr(x$LBXSCR,x$RIDAGEYR,x$RIAGENDR)
egfr_lt60 <- is.finite(egfr_pre) & egfr_pre < 60
bmi_threshold <- ifelse(asian,23,25)
waist_f_threshold <- ifelse(asian,80,88)
waist_m_threshold <- ifelse(asian,90,102)
waist <- (female & obs_ge(x$BMXWAIST,waist_f_threshold)) | (male & obs_ge(x$BMXWAIST,waist_m_threshold))
adiposity <- obs_ge(x$BMXBMI,bmi_threshold) | waist
a1c_pred <- obs_between(x$LBXGH,5.7,6.4)
a1c_t2d <- obs_ge(x$LBXGH,6.5)
observed_cvd <- Reduce(`|`, lapply(c("MCQ160b","MCQ160c","MCQ160d","MCQ160e","MCQ160f"), function(v) obs_eq(x[[v]],1)))

primary_domain <- adult & is.finite(x$WTSAF2YR) & x$WTSAF2YR>0
fg_pred <- obs_between(x$LBXGLU,100,125) & primary_domain
fg_t2d <- obs_ge(x$LBXGLU,126) & primary_domain
tg <- obs_ge(x$LBXTLG,150) & primary_domain
low_hdl <- (male & obs_lt(x$LBDHDD,40)) | (female & obs_lt(x$LBDHDD,50))
glucose_mets <- obs_ge(x$LBXGLU,100) & primary_domain
mets_n <- rowSums(cbind(waist,low_hdl,tg,bp,glucose_mets))
mets <- mets_n>=3
stage1 <- adiposity | a1c_pred | fg_pred
stage2 <- bp | tg | a1c_t2d | fg_t2d | mets | egfr_lt60
stage4 <- observed_cvd & (stage1 | stage2)
eligible_computed <- primary_domain & (stage2 | stage4)

frozen_ids <- scan(frozen_ids_path,what=integer(),quiet=TRUE)
if (length(frozen_ids)!=1985L || anyDuplicated(frozen_ids)) stop("FROZEN_DENOMINATOR_ID_FAIL")
computed_ids <- sort(as.integer(x$SEQN[eligible_computed]))
if (!identical(computed_ids,sort(as.integer(frozen_ids)))) stop("PRIMARY_DENOMINATOR_RECOMPUTE_MISMATCH")
x$pre_uacr_eligible <- x$SEQN %in% frozen_ids
if (sum(x$pre_uacr_eligible)!=1985L) stop("PRIMARY_DENOMINATOR_MEMBERSHIP_FAIL")

# Prespecified sensitivities, still pre-UACR.
sens_domain_v1 <- adult & is.finite(x$WTPH2YR) & x$WTPH2YR>0
s_stage1 <- adiposity | a1c_pred
s_stage2 <- bp | a1c_t2d | egfr_lt60
s_stage4 <- observed_cvd & (s_stage1 | s_stage2)
x$eligible_V1 <- sens_domain_v1 & (s_stage2 | s_stage4)
if (sum(x$eligible_V1)!=3481L) stop("V1_LOCKED_W04_COUNT_MISMATCH observed=",sum(x$eligible_V1))
other_v2 <- bp | tg | a1c_t2d | fg_t2d | mets | stage4
x$eligible_V2 <- primary_domain & other_v2
# V3: measured-BP component replaced everywhere by BP history/medication rule.
mets_v3_n <- rowSums(cbind(waist,low_hdl,tg,bp_hist,glucose_mets))
mets_v3 <- mets_v3_n>=3
stage2_v3 <- bp_hist | tg | a1c_t2d | fg_t2d | mets_v3 | egfr_lt60
stage4_v3 <- observed_cvd & (stage1 | stage2_v3)
x$eligible_V3 <- primary_domain & (stage2_v3 | stage4_v3)
x$eligible_V4 <- primary_domain & ((stage2 | stage4) | obs_eq(x$DIQ010,1))
x$eligible_V5 <- primary_domain & stage2

# Only now open post-freeze UACR source.
u <- read_select("ALB_CR_L",c("SEQN","URDACT"))
x <- left_join_seqn(x,u)
x$egfr_2021 <- ckd_epi_2021_cr(x$LBXSCR,x$RIDAGEYR,x$RIAGENDR)
x$G_cat <- ckd_g_category(x$egfr_2021)
x$A_cat <- uacr_a_category(x$URDACT)
x$transition_cell <- derive_e01_transition(x$G_cat,x$A_cat)
x$primary_joint_analyzable <- x$pre_uacr_eligible & !is.na(x$G_cat) & !is.na(x$A_cat)
for (v in paste0("eligible_V",1:5)) x[[paste0(v,"_joint")]] <- x[[v]] & !is.na(x$G_cat) & !is.na(x$A_cat)

saveRDS(x,file.path(out,"objects","ANALYTIC_DATA.rds"),compress=FALSE,version=3)

safe_binary <- function(des, variable_name, force_context=FALSE) {
  xvar <- des$variables[[variable_name]]
  if (anyNA(xvar) || any(!xvar %in% c(0,1))) stop("BINARY_INVALID ",variable_name)
  est <- survey::svymean(stats::as.formula(paste0("~",variable_name)),des,na.rm=FALSE)
  p <- as.numeric(stats::coef(est)[[1]]); vp <- as.numeric(stats::vcov(est)[1,1])
  n <- length(xvar); events <- sum(xvar==1); d <- domain_df_nchs(des); ddf <- as.integer(d[["df"]])
  q <- tryCatch(qualify_nchs_proportion(p,vp,n,events,ddf,force_context), error=function(e) NULL)
  if (is.null(q)) {
    return(list(estimate=p,variance=vp,n=n,events=events,strata=as.integer(d[["strata"]]),psus=as.integer(d[["psus"]]),df=ddf,
                action="SUPPRESS",flags=c("NONFINITE_VARIANCE_OR_CI","STATISTICAL_REVIEW_REQUIRED"),lower=NA_real_,upper=NA_real_,n_eff=NA_real_,n_eff_df=NA_real_))
  }
  list(estimate=p,variance=vp,n=n,events=events,strata=as.integer(d[["strata"]]),psus=as.integer(d[["psus"]]),df=ddf,
       action=q$action,flags=q$flags,lower=q$lower,upper=q$upper,n_eff=q$n_eff,n_eff_df=q$n_eff_df)
}
base_row <- function(id,q,estimate_internal=NULL,extra=list()) {
  est <- if (is.null(estimate_internal)) q$estimate else estimate_internal
  disp <- if (identical(q$action,"SUPPRESS")) NA_real_ else est
  c(list(cell_id=id,estimate_internal=est,display_estimate=disp,ci_lower=q$lower,ci_upper=q$upper,n=q$n,events=q$events,
         strata=q$strata,psus=q$psus,df=q$df,n_eff=q$n_eff,n_eff_df=q$n_eff_df,
         reliability_action=q$action,reliability_flags=paste(q$flags,collapse=";")),extra)
}
rows_to_df <- function(rows) {
  cols <- unique(unlist(lapply(rows,names)))
  outd <- lapply(cols,function(cc) vapply(rows,function(r) if (cc %in% names(r)) as.character(r[[cc]]) else "",character(1)))
  names(outd)<-cols; as.data.frame(outd,stringsAsFactors=FALSE,check.names=FALSE)
}
write_det <- function(d,path) utils::write.csv(d,path,row.names=FALSE,na="",quote=TRUE)

transition_rows <- function(des, prefix_extra=list(), force_context=FALSE) {
  lev <- paste0("T0",1:7)
  vec <- survey::svymean(~factor(transition_cell,levels=c("T01","T02","T03","T04","T05","T06","T07")),des,na.rm=FALSE)
  pvec <- as.numeric(stats::coef(vec))
  if (length(pvec)!=7L || any(!is.finite(pvec)) || abs(sum(pvec)-1)>1e-10) stop("TRANSITION_VECTOR_SUM_FAIL")
  rows <- vector("list",7)
  for (i in seq_along(lev)) {
    nm <- paste0("ind_",lev[[i]])
    des$variables[[nm]] <- as.integer(as.character(des$variables$transition_cell)==lev[[i]])
    q <- safe_binary(des,nm,force_context)
    if (abs(q$estimate-pvec[[i]])>1e-12) stop("TRANSITION_BINARY_VECTOR_MISMATCH ",lev[[i]])
    rows[[i]] <- base_row(lev[[i]],q,pvec[[i]],prefix_extra)
  }
  rows
}

# Primary E01.
des_full <- make_nhanes_design(x,"WTSAF2YR")
des_elig <- subset(des_full,pre_uacr_eligible)
des_an <- subset(des_elig,primary_joint_analyzable)
primary_rows <- transition_rows(des_an)
primary <- rows_to_df(primary_rows)
write_det(primary,file.path(out,"PRIMARY_RESULTS.csv"))

# Secondary S1-S5.
secondary_rows <- list()
add_secondary_binary <- function(des, estimand_id, cell_id, indicator, force_context=FALSE, required_flags=character()) {
  nm <- paste0("sec_",gsub("[^A-Za-z0-9]","_",estimand_id),"_",gsub("[^A-Za-z0-9]","_",cell_id))
  des$variables[[nm]] <- as.integer(indicator)
  q <- safe_binary(des,nm,force_context)
  q$flags <- unique(c(q$flags, required_flags))
  secondary_rows[[length(secondary_rows)+1]] <<- base_row(cell_id,q,NULL,list(estimand_id=estimand_id))
}
valid_uacr <- is.finite(x$URDACT) & x$URDACT>=0
x$valid_uacr <- valid_uacr
# Rebuild design to include newly added variable.
des_full <- make_nhanes_design(x,"WTSAF2YR"); des_elig <- subset(des_full,pre_uacr_eligible)
des_uacr <- subset(des_elig,valid_uacr)
add_secondary_binary(des_uacr,"S1","UACR_GE30",des_uacr$variables$URDACT>=30,FALSE)
for (a in c("A1","A2","A3")) add_secondary_binary(des_uacr,"S2A",a,as.character(des_uacr$variables$A_cat)==a,identical(a,"A3"))
# Check A vector.
s2a_tmp <- tail(secondary_rows,3); if (abs(sum(vapply(s2a_tmp,function(r) as.numeric(r$estimate_internal),numeric(1)))-1)>1e-10) stop("S2A_SUM_FAIL")
des_ga <- subset(des_elig,!is.na(G_cat) & !is.na(A_cat))
for (g in c("G1","G2","G3a","G3b","G4","G5")) for (a in c("A1","A2","A3")) {
  cid <- paste(g,a,sep="_")
  add_secondary_binary(des_ga,"S2B",cid,as.character(des_ga$variables$G_cat)==g & as.character(des_ga$variables$A_cat)==a,identical(a,"A3"))
}
s2b_tmp <- tail(secondary_rows,18); if (abs(sum(vapply(s2b_tmp,function(r) as.numeric(r$estimate_internal),numeric(1)))-1)>1e-10) stop("S2B_SUM_FAIL")
add_secondary_binary(des_uacr,"S3","UACR_GE100",des_uacr$variables$URDACT>=100,TRUE)
add_secondary_binary(des_uacr,"S4","UACR_GE200",des_uacr$variables$URDACT>=200,TRUE,c("INHERITED_SPARSE_SUPPORT"))
add_secondary_binary(des_uacr,"S5","UACR_GE300_A3",des_uacr$variables$URDACT>=300,TRUE,c("INHERITED_SPARSE_SUPPORT","HIGH_SPARSE_SUPPORT"))
secondary <- rows_to_df(secondary_rows)
write_det(secondary,file.path(out,"SECONDARY_RESULTS.csv"))

# Prespecified H1/H2 only.
subgroup_rows <- list()
des_full <- make_nhanes_design(x,"WTSAF2YR"); des_an <- subset(des_full,pre_uacr_eligible & primary_joint_analyzable)
sg_defs <- list(
  list(id="H1",name="AGE_GROUP",label="18-44",mask=function(v) v$RIDAGEYR>=18 & v$RIDAGEYR<=44),
  list(id="H1",name="AGE_GROUP",label="45-64",mask=function(v) v$RIDAGEYR>=45 & v$RIDAGEYR<=64),
  list(id="H1",name="AGE_GROUP",label="65+",mask=function(v) v$RIDAGEYR>=65),
  list(id="H2",name="SEX",label="Male",mask=function(v) v$RIAGENDR==1),
  list(id="H2",name="SEX",label="Female",mask=function(v) v$RIAGENDR==2)
)
for (sg in sg_defs) {
  m <- sg$mask(des_an$variables); m[is.na(m)]<-FALSE
  dsg <- subset(des_an,m)
  rr <- transition_rows(dsg,list(subgroup_id=sg$id,subgroup_name=sg$name,subgroup_level=sg$label))
  subgroup_rows <- c(subgroup_rows,rr)
}
subgroups <- rows_to_df(subgroup_rows)
write_det(subgroups,file.path(out,"SUBGROUP_RESULTS.csv"))

# V1-V5 exactly.
sensitivity_rows <- list()
for (vid in paste0("V",1:5)) {
  w <- if (vid=="V1") "WTPH2YR" else "WTSAF2YR"
  elig_nm <- paste0("eligible_",vid)
  d0 <- make_nhanes_design(x,w)
  d0$variables$SENS_DOMAIN_TMP <- d0$variables[[elig_nm]] & !is.na(d0$variables$G_cat) & !is.na(d0$variables$A_cat)
  dan <- subset(d0,SENS_DOMAIN_TMP)
  rr <- transition_rows(dan,list(sensitivity_id=vid,weight=w))
  sensitivity_rows <- c(sensitivity_rows,rr)
}
sens <- rows_to_df(sensitivity_rows)
write_det(sens,file.path(out,"SENSITIVITY_RESULTS.csv"))

# Missingness diagnostics in frozen eligible population and H1/H2 subgroups.
missing_rows <- list()
des_full <- make_nhanes_design(x,"WTSAF2YR"); des_elig <- subset(des_full,pre_uacr_eligible)
missing_rows[[1]] <- list(metric_id="FROZEN_ELIGIBLE_N",scope="ALL",scope_level="ALL",unweighted_count=length(des_elig$variables$SEQN),estimate_internal="",display_estimate="",ci_lower="",ci_upper="",n=length(des_elig$variables$SEQN),events="",strata="",psus="",df="",n_eff="",n_eff_df="",reliability_action="IDENTITY",reliability_flags="")
missing_metrics <- list(
  list(id="UACR_MISSING",fun=function(v) is.na(v$A_cat)),
  list(id="EGFR_INVALID_OR_MISSING",fun=function(v) is.na(v$G_cat)),
  list(id="JOINT_ANALYZABLE",fun=function(v) !is.na(v$G_cat) & !is.na(v$A_cat))
)
add_missing_scope <- function(des, scope, level) {
  for (mm in missing_metrics) {
    nm <- paste0("mis_",mm$id)
    ind <- mm$fun(des$variables); ind[is.na(ind)]<-FALSE
    des$variables[[nm]] <- as.integer(ind)
    q <- safe_binary(des,nm,FALSE)
    missing_rows[[length(missing_rows)+1]] <<- c(base_row(mm$id,q,NULL,list()),list(metric_id=mm$id,scope=scope,scope_level=level,unweighted_count=q$events))
  }
}
add_missing_scope(des_elig,"ALL","ALL")
for (sg in sg_defs) {
  # Missingness subgroups are subsets of frozen eligible, not joint-analyzable.
  m <- sg$mask(des_elig$variables); m[is.na(m)]<-FALSE
  dsg <- subset(des_elig,m)
  add_missing_scope(dsg,sg$id,sg$label)
}
missing_df <- rows_to_df(missing_rows)
# Remove duplicate cell_id column if present; metric_id is controlling.
if ("cell_id" %in% names(missing_df)) missing_df$cell_id <- NULL
write_det(missing_df,file.path(out,"MISSINGNESS_RESULTS.csv"))

# M1 nonparametric transition-identification bounds. No sampling CI.
w <- normalize_documented_weight_zero(x$WTSAF2YR)
elig <- x$pre_uacr_eligible & is.finite(w) & w>0
den_w <- sum(w[elig])
if (!is.finite(den_w) || den_w<=0) stop("M1_DENOMINATOR_INVALID")
bound_rows <- list()
for (tk in paste0("T0",1:7)) {
  obs <- elig & !is.na(x$transition_cell) & as.character(x$transition_cell)==tk
  miss_g <- elig & is.na(x$G_cat)
  miss_a_known_g <- elig & !is.na(x$G_cat) & is.na(x$A_cat)
  gg <- as.character(x$G_cat)
  compat_known <- switch(tk,
    T01=gg %in% c("G1","G2"), T02=gg %in% c("G1","G2"),
    T03=gg=="G3a", T04=gg=="G3a",
    T05=gg=="G3b", T06=gg=="G3b",
    T07=gg %in% c("G4","G5"))
  compat <- miss_g | (miss_a_known_g & compat_known)
  lower <- sum(w[obs])/den_w
  upper <- (sum(w[obs])+sum(w[compat]))/den_w
  if (lower < -1e-15 || upper > 1+1e-12 || lower>upper+1e-15) stop("M1_BOUND_INVALID ",tk)
  bound_rows[[length(bound_rows)+1]] <- list(cell_id=tk,lower_bound=max(0,lower),upper_bound=min(1,upper),interval_type="IDENTIFICATION_BOUND_NOT_CI")
}
bounds <- rows_to_df(bound_rows)
write_det(bounds,file.path(out,"IDENTIFICATION_BOUNDS.csv"))

# Exact session and runtime capture.
sink(file.path(out,"provenance","sessionInfo.txt"))
cat("R.version.string=",R.version.string,"\n",sep="")
cat("survey=",as.character(utils::packageVersion("survey")),"\n",sep="")
cat("srvyr=",as.character(utils::packageVersion("srvyr")),"\n",sep="")
cat("foreign_import_only=",as.character(utils::packageVersion("foreign")),"\n",sep="")
cat("locale=",Sys.getlocale("LC_ALL"),"\n",sep="")
cat("timezone=",Sys.getenv("TZ"),"\n",sep="")
cat("survey.lonely.psu=",getOption("survey.lonely.psu"),"\n",sep="")
cat("survey.adjust.domain.lonely=",getOption("survey.adjust.domain.lonely"),"\n",sep="")
print(sessionInfo())
sink()
writeLines(c(
  paste("R_version",as.character(getRversion()),sep="\t"),
  paste("survey_version",as.character(utils::packageVersion("survey")),sep="\t"),
  paste("srvyr_version",as.character(utils::packageVersion("srvyr")),sep="\t"),
  paste("foreign_version_import_only",as.character(utils::packageVersion("foreign")),sep="\t"),
  paste("LC_ALL",Sys.getlocale("LC_ALL"),sep="\t"),
  paste("TZ",Sys.getenv("TZ"),sep="\t"),
  paste("survey.lonely.psu",getOption("survey.lonely.psu"),sep="\t"),
  paste("survey.adjust.domain.lonely",as.character(getOption("survey.adjust.domain.lonely")),sep="\t")
),file.path(out,"runtime_fields.tsv"))
cat("W09_R_ANALYSIS_RUN: PASS primary_sum=",format(sum(as.numeric(primary$estimate_internal)),digits=17)," primary_joint_n=",nrow(des_an$variables),"\n",sep="")
