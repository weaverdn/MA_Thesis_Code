
library(tidyverse)
library(urbnmapr)
library(stargazer)
library(knitr)
library(stringr)
library(xtable)
library(openxlsx)
library(did)
library(fixest)
library(bacondecomp)
library(DIDmultiplegt)
library(haven)

# helper functions:


# Not in:
`%!in%` <- Negate(`%in%`)

# Bin Function for Event Study:
bin_me = function(dataset, lowerbin, upperbin, treatment) {
  dataset["t_bin"] = rep(0, nrow(dataset))
  
  if (treatment == "cs") {
    for (i in 1:nrow(dataset)) {
      if (is.na(dataset["timetotreat_cs"][i,])) {dataset["t_bin"][i,] = NA}
      else {
        if (dataset["timetotreat_cs"][i,] > upperbin) {dataset["t_bin"][i,] = upperbin}
        else if (dataset["timetotreat_cs"][i,] < lowerbin) {dataset["t_bin"][i,] = lowerbin}
        else dataset["t_bin"][i,] = dataset["timetotreat_cs"][i,]
      }
    }
    return(dataset)
  }
  
  if (treatment == "do") {
    for (i in 1:nrow(dataset)) {
      if (is.na(dataset["timetotreat_do"][i,])) {dataset["t_bin"][i,] = NA}
      else {
        if (dataset["timetotreat_do"][i,] > upperbin) {dataset["t_bin"][i,] = upperbin}
        else if (dataset["timetotreat_do"][i,] < lowerbin) {dataset["t_bin"][i,] = lowerbin}
        else dataset["t_bin"][i,] = dataset["timetotreat_do"][i,]
      }
    }
    return(dataset)
  }
}


 

  

##############################
## STEP 1 - IMPORT DATASETS ##
##############################

# Standard Datasets
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/All Counties")

complete_udataset_ufac <- read.xlsx("ghg_cmp_upanel_ufac.xlsx") %>% 
  mutate(year = as.numeric(year), 
         cs_firsttreat = as.numeric(cs_firsttreat),
         do_firsttreat = as.numeric(do_firsttreat))

complete_bdataset_ufac <- read.xlsx("ghg_cmp_bpanel_ufac.xlsx") %>% 
  mutate(year = as.numeric(year), 
         cs_firsttreat = as.numeric(cs_firsttreat),
         do_firsttreat = as.numeric(do_firsttreat))

complete_bdataset_bfac <- read.xlsx("ghg_cmp_bpanel_bfac.xlsx") %>% 
  mutate(year = as.numeric(year), 
         cs_firsttreat = as.numeric(cs_firsttreat),
         do_firsttreat = as.numeric(do_firsttreat))

# Safe Datasets
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/Counties without NA Communities")

scomplete_udataset_ufac <- read.xlsx("sghg_cmp_upanel_ufac.xlsx") %>% 
  mutate(year = as.numeric(year), 
         cs_firsttreat = as.numeric(cs_firsttreat),
         do_firsttreat = as.numeric(do_firsttreat))

scomplete_bdataset_ufac <- read.xlsx("sghg_cmp_bpanel_ufac.xlsx") %>% 
  mutate(year = as.numeric(year), 
         cs_firsttreat = as.numeric(cs_firsttreat),
         do_firsttreat = as.numeric(do_firsttreat))

scomplete_bdataset_bfac <- read.xlsx("sghg_cmp_bpanel_bfac.xlsx") %>% 
  mutate(year = as.numeric(year), 
         cs_firsttreat = as.numeric(cs_firsttreat),
         do_firsttreat = as.numeric(do_firsttreat))

 


  

###########################
### Clean Datasets - 
###########################

complete_udataset_ufac <- complete_udataset_ufac %>% 
  mutate(cs_firsttreat = ifelse(is.na(cs_firsttreat),0,cs_firsttreat),
         do_firsttreat = ifelse(is.na(do_firsttreat),0,do_firsttreat),
         county_fips = as.numeric(county_fips)) %>% 
  mutate(ch4pop = ch4/Population)

complete_bdataset_ufac <- complete_bdataset_ufac %>% 
  mutate(cs_firsttreat = ifelse(is.na(cs_firsttreat),0,cs_firsttreat),
         do_firsttreat = ifelse(is.na(do_firsttreat),0,do_firsttreat),
         county_fips = as.numeric(county_fips)) %>% 
  mutate(ch4pop = ch4/Population)

complete_bdataset_bfac <- complete_bdataset_bfac %>% 
  mutate(cs_firsttreat = ifelse(is.na(cs_firsttreat),0,cs_firsttreat),
         do_firsttreat = ifelse(is.na(do_firsttreat),0,do_firsttreat),
         county_fips = as.numeric(county_fips)) %>% 
  mutate(ch4pop = ch4/Population)

scomplete_udataset_ufac <- scomplete_udataset_ufac %>% 
  mutate(cs_firsttreat = ifelse(is.na(cs_firsttreat),0,cs_firsttreat),
         do_firsttreat = ifelse(is.na(do_firsttreat),0,do_firsttreat),
         county_fips = as.numeric(county_fips)) %>% 
  mutate(ch4pop = ch4/Population)

scomplete_bdataset_ufac <- scomplete_bdataset_ufac %>% 
  mutate(cs_firsttreat = ifelse(is.na(cs_firsttreat),0,cs_firsttreat),
         do_firsttreat = ifelse(is.na(do_firsttreat),0,do_firsttreat),
         county_fips = as.numeric(county_fips)) %>% 
  mutate(ch4pop = ch4/Population)

scomplete_bdataset_bfac <- scomplete_bdataset_bfac %>% 
  mutate(cs_firsttreat = ifelse(is.na(cs_firsttreat),0,cs_firsttreat),
         do_firsttreat = ifelse(is.na(do_firsttreat),0,do_firsttreat),
         county_fips = as.numeric(county_fips)) %>% 
  mutate(ch4pop = ch4/Population)

 


# ============================================================
# ============================================================ 
# ============== STEP 2 - CONTINUOUS TREATMENT =============== 
# ============================================================ 
# ============================================================ 


  

# ALL REG OUTPUT DONE IN STATA - DID_MULTIPLEGT PACKAGE

# BELOW I READ THE OUTPUT FROM THE STATA FILE TO PUT IT INTO A CLEAN TABLE:

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput")

pvalue <-  function(coef,df, se)  {
  tstat = (coef - 0)/se
  pval = pt(abs(tstat), df = df, lower.tail = F)*2
  return(pval)
}

# ======================== UU DATASET: ========================

#Binary
UUb1.dta <- read_dta("UUb1.dta") %>% mutate(Dataset = "UUb1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUb2.dta <- read_dta("UUb2.dta") %>% mutate(Dataset = "UUb2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUb3.dta <- read_dta("UUb3.dta") %>% mutate(Dataset = "UUb3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUb4.dta <- read_dta("UUb4.dta") %>% mutate(Dataset = "UUb4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUb5.dta <- read_dta("UUb5.dta") %>% mutate(Dataset = "UUb5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUb6.dta <- read_dta("UUb6.dta") %>% mutate(Dataset = "UUb6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUb7.dta <- read_dta("UUb7.dta") %>% mutate(Dataset = "UUb7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUb8.dta <- read_dta("UUb8.dta") %>% mutate(Dataset = "UUb8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

#Continuous
UUc1.dta <- read_dta("UUc1.dta") %>% mutate(Dataset = "UUc1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUc2.dta <- read_dta("UUc2.dta") %>% mutate(Dataset = "UUc2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUc3.dta <- read_dta("UUc3.dta") %>% mutate(Dataset = "UUc3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUc4.dta <- read_dta("UUc4.dta") %>% mutate(Dataset = "UUc4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUc5.dta <- read_dta("UUc5.dta") %>% mutate(Dataset = "UUc5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUc6.dta <- read_dta("UUc6.dta") %>% mutate(Dataset = "UUc6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUc7.dta <- read_dta("UUc7.dta") %>% mutate(Dataset = "UUc7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
UUc8.dta <- read_dta("UUc8.dta") %>% mutate(Dataset = "UUc8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

# ======================== BU DATASET: =========================

#Binary
BUb1.dta <- read_dta("BUb1.dta") %>% mutate(Dataset = "BUb1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUb2.dta <- read_dta("BUb2.dta") %>% mutate(Dataset = "BUb2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUb3.dta <- read_dta("BUb3.dta") %>% mutate(Dataset = "BUb3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUb4.dta <- read_dta("BUb4.dta") %>% mutate(Dataset = "BUb4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUb5.dta <- read_dta("BUb5.dta") %>% mutate(Dataset = "BUb5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUb6.dta <- read_dta("BUb6.dta") %>% mutate(Dataset = "BUb6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUb7.dta <- read_dta("BUb7.dta") %>% mutate(Dataset = "BUb7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUb8.dta <- read_dta("BUb8.dta") %>% mutate(Dataset = "BUb8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

#Continuous
BUc1.dta <- read_dta("BUc1.dta") %>% mutate(Dataset = "BUc1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUc2.dta <- read_dta("BUc2.dta") %>% mutate(Dataset = "BUc2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUc3.dta <- read_dta("BUc3.dta") %>% mutate(Dataset = "BUc3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUc4.dta <- read_dta("BUc4.dta") %>% mutate(Dataset = "BUc4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUc5.dta <- read_dta("BUc5.dta") %>% mutate(Dataset = "BUc5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUc6.dta <- read_dta("BUc6.dta") %>% mutate(Dataset = "BUc6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUc7.dta <- read_dta("BUc7.dta") %>% mutate(Dataset = "BUc7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BUc8.dta <- read_dta("BUc8.dta") %>% mutate(Dataset = "BUc8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

# ======================== BB DATASET: =========================

#Binary
BBb1.dta <- read_dta("BBb1.dta") %>% mutate(Dataset = "BBb1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBb2.dta <- read_dta("BBb2.dta") %>% mutate(Dataset = "BBb2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBb3.dta <- read_dta("BBb3.dta") %>% mutate(Dataset = "BBb3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBb4.dta <- read_dta("BBb4.dta") %>% mutate(Dataset = "BBb4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBb5.dta <- read_dta("BBb5.dta") %>% mutate(Dataset = "BBb5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBb6.dta <- read_dta("BBb6.dta") %>% mutate(Dataset = "BBb6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBb7.dta <- read_dta("BBb7.dta") %>% mutate(Dataset = "BBb7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBb8.dta <- read_dta("BBb8.dta") %>% mutate(Dataset = "BBb8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

#Continuous
BBc1.dta <- read_dta("BBc1.dta") %>% mutate(Dataset = "BBc1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBc2.dta <- read_dta("BBc2.dta") %>% mutate(Dataset = "BBc2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBc3.dta <- read_dta("BBc3.dta") %>% mutate(Dataset = "BBc3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBc4.dta <- read_dta("BBc4.dta") %>% mutate(Dataset = "BBc4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBc5.dta <- read_dta("BBc5.dta") %>% mutate(Dataset = "BBc5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBc6.dta <- read_dta("BBc6.dta") %>% mutate(Dataset = "BBc6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBc7.dta <- read_dta("BBc7.dta") %>% mutate(Dataset = "BBc7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
BBc8.dta <- read_dta("BBc8.dta") %>% mutate(Dataset = "BBc8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)


# ======================== SUU DATASET: =========================

SUUb1.dta <- read_dta("SUUb1.dta") %>% mutate(Dataset = "SUUb1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUb2.dta <- read_dta("SUUb2.dta") %>% mutate(Dataset = "SUUb2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUb3.dta <- read_dta("SUUb3.dta") %>% mutate(Dataset = "SUUb3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUb4.dta <- read_dta("SUUb4.dta") %>% mutate(Dataset = "SUUb4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUb5.dta <- read_dta("SUUb5.dta") %>% mutate(Dataset = "SUUb5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUb6.dta <- read_dta("SUUb6.dta") %>% mutate(Dataset = "SUUb6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUb7.dta <- read_dta("SUUb7.dta") %>% mutate(Dataset = "SUUb7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUb8.dta <- read_dta("SUUb8.dta") %>% mutate(Dataset = "SUUb8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

#Continuous
SUUc1.dta <- read_dta("SUUc1.dta") %>% mutate(Dataset = "SUUc1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUc2.dta <- read_dta("SUUc2.dta") %>% mutate(Dataset = "SUUc2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUc3.dta <- read_dta("SUUc3.dta") %>% mutate(Dataset = "SUUc3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUc4.dta <- read_dta("SUUc4.dta") %>% mutate(Dataset = "SUUc4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUc5.dta <- read_dta("SUUc5.dta") %>% mutate(Dataset = "SUUc5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUc6.dta <- read_dta("SUUc6.dta") %>% mutate(Dataset = "SUUc6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUc7.dta <- read_dta("SUUc7.dta") %>% mutate(Dataset = "SUUc7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SUUc8.dta <- read_dta("SUUc8.dta") %>% mutate(Dataset = "SUUc8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

# ======================== SBU DATASET: =========================

#Binary
SBUb1.dta <- read_dta("SBUb1.dta") %>% mutate(Dataset = "SBUb1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUb2.dta <- read_dta("SBUb2.dta") %>% mutate(Dataset = "SBUb2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1) 
SBUb3.dta <- read_dta("SBUb3.dta") %>% mutate(Dataset = "SBUb3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUb4.dta <- read_dta("SBUb4.dta") %>% mutate(Dataset = "SBUb4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUb5.dta <- read_dta("SBUb5.dta") %>% mutate(Dataset = "SBUb5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUb6.dta <- read_dta("SBUb6.dta") %>% mutate(Dataset = "SBUb6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUb7.dta <- read_dta("SBUb7.dta") %>% mutate(Dataset = "SBUb7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUb8.dta <- read_dta("SBUb8.dta") %>% mutate(Dataset = "SBUb8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

#Continuous
SBUc1.dta <- read_dta("SBUc1.dta") %>% mutate(Dataset = "SBUc1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUc2.dta <- read_dta("SBUc2.dta") %>% mutate(Dataset = "SBUc2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUc3.dta <- read_dta("SBUc3.dta") %>% mutate(Dataset = "SBUc3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUc4.dta <- read_dta("SBUc4.dta") %>% mutate(Dataset = "SBUc4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUc5.dta <- read_dta("SBUc5.dta") %>% mutate(Dataset = "SBUc5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUc6.dta <- read_dta("SBUc6.dta") %>% mutate(Dataset = "SBUc6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUc7.dta <- read_dta("SBUc7.dta") %>% mutate(Dataset = "SBUc7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBUc8.dta <- read_dta("SBUc8.dta") %>% mutate(Dataset = "SBUc8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

# ======================== SBB DATASET: =========================

#Binary
SBBb1.dta <- read_dta("BBb1.dta") %>% mutate(Dataset = "SBBb1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBb2.dta <- read_dta("BBb2.dta") %>% mutate(Dataset = "SBBb2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBb3.dta <- read_dta("BBb3.dta") %>% mutate(Dataset = "SBBb3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBb4.dta <- read_dta("BBb4.dta") %>% mutate(Dataset = "SBBb4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBb5.dta <- read_dta("BBb5.dta") %>% mutate(Dataset = "SBBb5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBb6.dta <- read_dta("BBb6.dta") %>% mutate(Dataset = "SBBb6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBb7.dta <- read_dta("BBb7.dta") %>% mutate(Dataset = "SBBb7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBb8.dta <- read_dta("BBb8.dta") %>% mutate(Dataset = "SBBb8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)

#Continuous
SBBc1.dta <- read_dta("SBBc1.dta") %>% mutate(Dataset = "SBBc1") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBc2.dta <- read_dta("SBBc2.dta") %>% mutate(Dataset = "SBBc2") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBc3.dta <- read_dta("SBBc3.dta") %>% mutate(Dataset = "SBBc3") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBc4.dta <- read_dta("SBBc4.dta") %>% mutate(Dataset = "SBBc4") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBc5.dta <- read_dta("SBBc5.dta") %>% mutate(Dataset = "SBBc5") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBc6.dta <- read_dta("SBBc6.dta") %>% mutate(Dataset = "SBBc6") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBc7.dta <- read_dta("SBBc7.dta") %>% mutate(Dataset = "SBBc7") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)
SBBc8.dta <- read_dta("SBBc8.dta") %>% mutate(Dataset = "SBBc8") %>% rowwise() %>% mutate(P = pvalue(treatment_effect, N_treatment_effect, se_treatment_effect)) %>% tail(n=1)


# ============== JOIN INTO DATAFRAMES ================

# UU DATASET

# Binary
uub.dta = rbind(UUb1.dta, UUb2.dta, UUb3.dta, UUb4.dta, UUb5.dta, UUb6.dta, UUb7.dta, UUb8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

# Continuous
uuc.dta = rbind(UUc1.dta, UUc2.dta, UUc3.dta, UUc4.dta, UUc5.dta, UUc6.dta, UUc7.dta, UUc8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))


# BU DATASET

# Binary
bub.dta = rbind(BUb1.dta, BUb2.dta, BUb3.dta, BUb4.dta, BUb5.dta, BUb6.dta, BUb7.dta, BUb8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

# Continuous
buc.dta = rbind(BUc1.dta, BUc2.dta, BUc3.dta, BUc4.dta, BUc5.dta, BUc6.dta, BUc7.dta, BUc8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

# BB DATASET

# Binary
bbb.dta = rbind(BBb1.dta, BBb2.dta, BBb3.dta, BBb4.dta, BBb5.dta, BBb6.dta, BBb7.dta, BBb8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

# Continuous
bbc.dta = rbind(BBc1.dta, BBc2.dta, BBc3.dta, BBc4.dta, BBc5.dta, BBc6.dta, BBc7.dta, BBc8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))


# SUU DATASET

# Binary
suub.dta = rbind(SUUb1.dta, SUUb2.dta, SUUb3.dta, SUUb4.dta, SUUb5.dta, SUUb6.dta, SUUb7.dta, SUUb8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

# Continuous
suuc.dta = rbind(SUUc1.dta, SUUc2.dta, SUUc3.dta, SUUc4.dta, SUUc5.dta, SUUc6.dta, SUUc7.dta, SUUc8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

# SBU DATASET

# Binary
sbub.dta = rbind(SBUb1.dta, SBUb2.dta, SBUb3.dta, SBUb4.dta, SBUb5.dta, SBUb6.dta, SBUb7.dta, SBUb8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

# Continuous
sbuc.dta = rbind(SBUc1.dta, SBUc2.dta, SBUc3.dta, SBUc4.dta, SBUc5.dta, SBUc6.dta, SBUc7.dta, SBUc8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

# BB DATASET

# Binary
sbbb.dta = rbind(SBBb1.dta, SBBb2.dta, SBBb3.dta, SBBb4.dta, SBBb5.dta, SBBb6.dta, SBBb7.dta, SBBb8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

# Continuous
sbbc.dta = rbind(SBBc1.dta, SBBc2.dta, SBBc3.dta, SBBc4.dta, SBBc5.dta, SBBc6.dta, SBBc7.dta, SBBc8.dta) %>% 
  relocate(treatment_effect_upper_95CI, .after = treatment_effect_lower_95CI) %>%
  rename(ATT = treatment_effect, se = se_treatment_effect, N = N_treatment_effect, Lower95 = treatment_effect_lower_95CI, Upper95 = treatment_effect_upper_95CI) %>%
  select(-c(time_to_treatment))

 

  

#Regression Tables for each dataset and treatment type:

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

# Binary:

BinaryRegTable <-  rbind(uub.dta, bub.dta, bbb.dta, suub.dta, sbub.dta, sbbb.dta) 
BinaryRegTable <-  as.data.frame(BinaryRegTable) %>% filter(substrRight(c(Dataset), 1) %in% c("1", "5", "6", "7", "8"))
ContinuousRegTable <- rbind(uuc.dta, buc.dta, bbc.dta, suuc.dta, sbuc.dta, sbbc.dta)
ContinuousRegTable <- as.data.frame(ContinuousRegTable) %>% filter(substrRight(c(Dataset), 1) %in% c("1", "5", "6", "7", "8"))

ContinuousRegTable
xtable(ContinuousRegTable, digits=3)


 



# ============================================================
# ============================================================ 
# ================ STEP 3 - BALANCE TABLES  ================== 
# ============================================================ 
# ============================================================ 

  
uutab1 <- complete_udataset_ufac %>%
  filter(binarytreat_cs == 1) %>%
  summarize(CH4perHH = mean(ch4, na.rm=T),
            Facilities = mean(facnum,na.rm=T),
            AvgHHSize = mean(AvgHHSize,na.rm=T),
            MedianIncome = mean(MedianIncome,na.rm=T),
            Population = mean(Population,na.rm=T),
            RenterFraction = mean(RenterFraction,na.rm=T),
            DemShare = mean(demshare,na.rm=T))

uutab2 <- complete_udataset_ufac %>%
  filter(binarytreat_cs != 1) %>%
  summarize(CH4perHH = mean(ch4, na.rm=T),
            Facilities = mean(facnum,na.rm=T),
            AvgHHSize = mean(AvgHHSize,na.rm=T),
            MedianIncome = mean(MedianIncome,na.rm=T),
            Population = mean(Population,na.rm=T),
            RenterFraction = mean(RenterFraction,na.rm=T),
            DemShare = mean(demshare,na.rm=T))

balancetableUU <- round(data.frame(cbind(t(uutab1), t(uutab2))) %>% rename(Treated = X1, Untreated = X2),3)



summary(lm(ch4hh ~ cs_treatshare + do_treatshare + facnum + AvgHHSize + RenterFraction + Population + demshare, data=complete_udataset_ufac))

show(balancetableUU)
xtable(BinaryRegTable)
 

# ============================================================
# ============================================================ 
# ================ STEP 4 - BINARY TREAT AND EVENT STUDY   ===
# ============================================================ 
# ============================================================ 


 {r warning=FALSE}


###############################################
###############################################
################# BINARY TREATMENT ############
###############################################
###############################################

## UU DATASET: 

olsuu1b <- feols(ch4hh ~ binarytreat_cs | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac) 
olsuu2b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac)   
olsuu3b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac)   
olsuu4b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac)
olsuu5b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac)
e1b <- etable(olsuu1b, olsuu2b, olsuu3b, olsuu4b, olsuu5b, se.below=T,digits=3)[3:4,]
colnames(e1b) = c("basic", "demographic", "facnum", "demshare", "do")

## BU DATASET: 

olsbu1b <- feols(ch4hh ~ binarytreat_cs | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac) 
olsbu2b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac)   
olsbu3b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac)   
olsbu4b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac)
olsbu5b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac)
e2b <- etable(olsbu1b, olsbu2b, olsbu3b, olsbu4b, olsbu5b, se.below=T,digits=3)[3:4,]
colnames(e2b) = c("basic", "demographic", "facnum", "demshare", "do")

## BB DATASET:

olsbb1b <- feols(ch4hh ~ binarytreat_cs | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac) 
olsbb2b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_bfac)   
olsbb3b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_bfac)   
olsbb4b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_bfac)
olsbb5b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_bfac)
e3b <- etable(olsbb1b, olsbb2b, olsbb3b, olsbb4b, olsbb5b, se.below=T,digits=3)[3:4,]
colnames(e3b) = c("basic", "demographic", "facnum", "demshare", "do")

## SUU DATASET:

olssuu1b <- feols(ch4hh ~ binarytreat_cs | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac) 
olssuu2b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=scomplete_udataset_ufac)   
olssuu3b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=scomplete_udataset_ufac)   
olssuu4b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=scomplete_udataset_ufac)
olssuu5b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=scomplete_udataset_ufac)
e4b <- etable(olssuu1b, olssuu2b, olssuu3b, olssuu4b, olssuu5b, se.below=T,digits=3)[3:4,]
colnames(e4b) = c("basic", "demographic", "facnum", "demshare", "do")

## SBU DATASET:

olssbu1b <- feols(ch4hh ~ binarytreat_cs | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac) 
olssbu2b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_ufac)   
olssbu3b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_ufac)   
olssbu4b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_ufac)
olssbu5b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_ufac)
e5b <- etable(olsbu1b, olssbu2b, olssbu3b, olssbu4b, olssbu5b, se.below=T,digits=3)[3:4,]
colnames(e5b) = c("basic", "demographic", "facnum", "demshare", "do")

## SBB DATASET:

olssbb1b <- feols(ch4hh ~ binarytreat_cs | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac) 
olssbb2b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_bfac)   
olssbb3b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_bfac)   
olssbb4b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_bfac)
olssbb5b <- feols(ch4hh ~ binarytreat_cs + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare| year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_bfac)
e6b <- etable(olsbb1b, olssbb2b, olssbb3b, olssbb4b, olssbb5b,se.below = T,digits=3)[3:4,]
colnames(e6b) = c("basic", "demographic", "facnum", "demshare", "do")

TWFEbinOLS <- rbind(e1b, e2b, e3b, e4b, e5b, e6b)
xtable(TWFEbinOLS)

 

  

###############################################
###############################################
################# CTS TREATMENT ###############
###############################################
###############################################


## UU DATASET: 

olsuu1c <- feols(ch4hh ~ cs_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac) 
olsuu2c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac)   
olsuu3c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac)   
olsuu4c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac)
olsuu5c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac)
e1c <- etable(olsuu1c, olsuu2c, olsuu3c, olsuu4c, olsuu5c, se.below=T,digits=3)[3:4,]
colnames(e1c) = c("basic", "demographic", "facnum", "demshare", "do")

## BU DATASET: 

olsbu1c <- feols(ch4hh ~ cs_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac) 
olsbu2c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac)   
olsbu3c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac)   
olsbu4c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac)
olsbu5c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac)
e2c <- etable(olsbu1c, olsbu2c, olsbu3c, olsbu4c, olsbu5c, se.below=T,digits=3)[3:4,]
colnames(e2c) = c("basic", "demographic", "facnum", "demshare", "do")

## BB DATASET:

olsbb1c <- feols(ch4hh ~ cs_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_ufac) 
olsbb2c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_bfac)   
olsbb3c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_bfac)   
olsbb4c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_bfac)
olsbb5c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_bdataset_bfac)
e3c <- etable(olsbb1c, olsbb2c, olsbb3c, olsbb4c, olsbb5c, se.below=T,digits=3)[3:4,]
colnames(e3c) = c("basic", "demographic", "facnum", "demshare", "do")

## SUU DATASET:

olssuu1c <- feols(ch4hh ~ cs_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac) 
olssuu2c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=scomplete_udataset_ufac)   
olssuu3c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=scomplete_udataset_ufac)   
olssuu4c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=scomplete_udataset_ufac)
olssuu5c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=scomplete_udataset_ufac)
e4c <- etable(olssuu1c, olssuu2c, olssuu3c, olssuu4c, olssuu5c, se.below=T,digits=3)[3:4,]
colnames(e4c) = c("basic", "demographic", "facnum", "demshare", "do")

## SBU DATASET:

olssbu1c <- feols(ch4hh ~ cs_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac) 
olssbu2c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_ufac)   
olssbu3c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_ufac)   
olssbu4c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_ufac)
olssbu5c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_ufac)
e5c <- etable(olsbu1c, olssbu2c, olssbu3c, olssbu4c, olssbu5c, se.below=T,digits=3)[3:4,]
colnames(e5c) = c("basic", "demographic", "facnum", "demshare", "do")

## SBB DATASET:

olssbb1c <- feols(ch4hh ~ cs_treatshare | year + county_fips, cluster=c("county_fips"), data=complete_udataset_ufac) 
olssbb2c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_bfac)   
olssbb3c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_bfac)   
olssbb4c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_bfac)
olssbb5c <- feols(ch4hh ~ cs_treatshare + Population + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=scomplete_bdataset_bfac)
e6c <- etable(olsbb1c, olssbb2c, olssbb3c, olssbb4c, olssbb5c,se.below = T, digits=3)[3:4,]
colnames(e6c) = c("basic", "demographic", "facnum", "demshare", "do")

TWFEctsOLS <- rbind(e1c, e2c, e3c, e4c, e5c, e6c)
xtable(TWFEctsOLS, digits=1)

 


  


#####################################################################
#####################################################################
################# BINARY TREATMENT EVENT STUDIES ####################
#####################################################################
#####################################################################


# UU EVENT STUDY
uuevent_data = bin_me(complete_udataset_ufac,-100,100,"cs") %>% filter(t_bin %in% c(-6:6) | is.na(t_bin))

eventuub <- feols(ch4hh ~ i(t_bin, ref=-1) + Population + RenterFraction + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=uuevent_data)

iplot(eventuub, 
      xlab = 'Time to treatment',
      ylab = 'ATT (95% Confidence Interval)',
      ylim = c(-0.55,0.55),
      xlim = c(-5,5))

# BU EVENT STUDY 
buevent_data = bin_me(complete_bdataset_ufac,-100,100,"cs") %>% filter(t_bin %in% c(-6:6) | is.na(t_bin))
eventbub <- feols(ch4hh ~ i(t_bin, ref=-1) + Population + RenterFraction + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=buevent_data)

iplot(eventbub, 
      xlab = 'Time to treatment',
      ylab = 'ATT (95% Confidence Interval)',
      ylim = c(-0.55,0.55),
      xlim = c(-5,5))

# BB EVENT STUDY 
bbevent_data = bin_me(complete_bdataset_bfac,-100,100,"cs") %>% filter(t_bin %in% c(-6:6) | is.na(t_bin))
eventbbb <- feols(ch4hh ~ i(t_bin, ref=-1) + Population + RenterFraction + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=bbevent_data)

iplot(eventbbb, 
      xlab = 'Time to treatment',
      ylab = 'ATT (95% Confidence Interval)',
      ylim = c(-0.55,0.55),
      xlim = c(-5,5))

# SUU EVENT STUDY 
suuevent_data = bin_me(scomplete_udataset_ufac,-100,100,"cs") %>% filter(t_bin %in% c(-6:6) | is.na(t_bin))
eventsuub <- feols(ch4hh ~ i(t_bin, ref=-1) + Population + RenterFraction + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=suuevent_data)

iplot(eventsuub, 
      xlab = 'Time to treatment',
      ylab = 'ATT (95% Confidence Interval)',
      ylim = c(-0.55,0.55),
      xlim = c(-5,5))

# SBU EVENT STUDY 
sbuevent_data = bin_me(scomplete_bdataset_ufac,-100,100,"cs") %>% filter(t_bin %in% c(-6:6) | is.na(t_bin))
eventsbub <- feols(ch4hh ~ i(t_bin, ref=-1) + Population+ RenterFraction + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=sbuevent_data)

iplot(eventsbub, 
      xlab = 'Time to treatment',
      ylab = 'ATT (95% Confidence Interval)',
      ylim = c(-0.55,0.55),
      xlim = c(-5,5))


# SBB EVENT STUDY 
sbbevent_data = bin_me(scomplete_bdataset_bfac,-100,100,"cs") %>% filter(t_bin %in% c(-6:6) | is.na(t_bin))
eventsbbb <- feols(ch4hh ~ i(t_bin, ref=-1) + Population + RenterFraction + AvgHHSize + MedianIncome + facnum + demshare + do_treatshare | year + county_fips, cluster=c("county_fips"), data=sbbevent_data)

iplot(eventsbbb, 
      xlab = 'Time to treatment',
      ylab = 'ATT (95% Confidence Interval)',
      ylim = c(-0.55,0.55),
      xlim = c(-5,5))


 



