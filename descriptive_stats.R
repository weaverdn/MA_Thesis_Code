library(tidyverse)
library(urbnmapr)
library(stargazer)
library(knitr)
library(stringr)
library(ggalt)
library(xtable)
library(openxlsx)
library(tidycensus)
library(reshape2)
library(RColorBrewer)
 

# ==================================================================
# ==================================================================
# ============ PART I - SUMMARY STATS FOR EPA GHG DATA =============
# ==================================================================
# ==================================================================


#========================================
#===== STEP 1 - READ GHG DATASETS =======
#========================================
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/GHG Emissions and Sinks")
ghg <-  read.csv("mswch4panel_fips.csv")


#=========================================================
#===== STEP 2 - NUM OF UNIQUE FACILITIES, COUNTIES  ======
#=========================================================

facilities_by_year <- ghg %>% group_by(year) %>% count()

counties_by_year <- ghg %>% group_by(year) %>% summarise(n = length(unique(County)))

summarystats1 <-merge(facilities_by_year, counties_by_year, by="year")
colnames(summarystats1) = c("year", "Facilities", "Unique Counties")

ghgsum <-  ghg %>% group_by(year) %>% summarise(Methane = sum(Methane..CH4..emissions, na.rm=TRUE))
summarystats2 <-  merge(summarystats1, ghgsum, by="year")

summarystats2
 
#========================================================================
#===== STEP 3 - TOTAL ANNUAL EMISSIONS PLOT (BALANCED/UNBALANCED)  ======
#========================================================================

# Define a balanced facility as one from 2010-2017 continuously reporting values.
ghg_balanced <-  ghg %>% 
  group_by(Facility.Id) %>%
  mutate(cnt = n()) %>%
  filter(cnt == 10)

balanced_facilities <-  ghg_balanced %>% group_by(year) %>% count()
n_balanced <-  unique(balanced_facilities$n)
n_balanced
balanced_methane = ghg_balanced %>% group_by(year) %>% summarise(Methane = sum(Methane..CH4..emissions, na.rm=TRUE))

summarystats3 = merge(summarystats2, balanced_methane, by="year")

colnames(summarystats3) = c("year", "Facilities", "Unique Counties", "MethaneUnbalanced", "MethaneBalanced")

plot_frame = summarystats3

methaneplot = ggplot(plot_frame) + 
  geom_point(aes(x = year, y = MethaneUnbalanced, color="darkred"), size = 3) +
  geom_xspline(data=plot_frame, aes(x=year, y= MethaneUnbalanced), color="darkred", spline_shape=0.4, size=0.4) + 
  geom_point(aes(x=year,y=MethaneBalanced, color="blue"),size = 3) +
  geom_xspline(data=plot_frame, aes(x=year, y= MethaneBalanced), color="blue", spline_shape=0.4, size=0.4) + 
  scale_x_continuous(breaks = round(seq(min(plot_frame$year), max(plot_frame$year), by = 1),1)) +
  labs(y = "Metric Tons of CH4 Emissions", x = "Year") +
  theme(plot.title = element_text(hjust = 0.5, size=10)) +
  scale_color_manual(labels = c("Balanced", "Unbalanced"), values = c("blue", "darkred")) +
  labs(color = "Data:")

methaneplot
plot_frame

 

  

#================================================
#===== STEP 4 - EXPORT SUMMARY STAT TABLE  ======
#================================================

# Balanced v Unbalanced
xtable(summarystats3)
summarystats3
 

  

#==================================================================
#===== STEP 4 - PLOT AVG ANNUAL COUNTY LEVEL CH4 DATA ON MAP  =====
#==================================================================

urbn_ghg = ghg
urbn_ghg2 = urbn_ghg %>%
  select(year, county_fips, Methane..CH4..emissions) %>%
  mutate(county_fips = as.character(county_fips))


counties_sf <- get_urbn_map(map = "counties", sf = TRUE)
county_groups = urbn_ghg2 %>% group_by(county_fips) %>% summarise(mean = mean(Methane..CH4..emissions, na.rm= TRUE))

emissions_data = left_join(counties_sf, county_groups, by="county_fips")

emissions_data %>%
  ggplot() +
  geom_sf(mapping = aes(fill = mean),
          color = "#ffffff", size = 0.03) +
  labs(fill = "Average Annual CH4")

 


  

#==================================================================
#===== STEP 4 - PERCENT OF POP COVERED BY GHG DATA  ===============
#==================================================================

pop10 <- get_decennial(year = 2010, geography="county", variables=c("P001001","H013001"))
pop10 <- pop10 %>% rename(val = value) %>% 
  dcast(GEOID + NAME ~ variable) %>%
  rename(hh = H013001, pop = P001001, county_fips = GEOID)

usa_population <- pop10 %>% filter(county_fips %in% counties_sf$county_fips) %>%
  summarise(pop = sum(pop))
pop_covered <- pop10 %>% 
  filter(county_fips %in% urbn_ghg2$county_fips) %>% 
  summarise(pop = sum(pop))

coverage_percent <- pop_covered/usa_population
coverage_percent

 


# ==============================================================
# ==============================================================
# ============ PART II - SUMMARY STATS FOR COMPOST =============
# ==============================================================
# ==============================================================

  

###########################
### STEP 1 - BIOCYCLE MAP
###########################

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Compost Data")

compost <- read.xlsx("biocycle_data2017clean.xlsx")

compost_county <- compost %>% rename(county_fips = FIPS, cs=hh_cs_county,
                                     doff = hh_do_county) %>%
  group_by(county_fips) %>%
  mutate(county_fips = as.character(county_fips)) %>%
  summarize(cs = sum(cs,na.rm=T), cd = sum(doff,na.rm=T)) %>%
  mutate(total = rowSums(cbind(cs,cd),na.rm=T))

compost_plot = left_join(counties_sf, compost_county, by="county_fips")

compost_plot %>%
  ggplot() +
  geom_sf(mapping = aes(fill = total),
          color = "#ffffff", size = 0.03) +
  labs(fill = "County Households")

 

  

###########################
### STEP 2 - SUMMARY STATS
###########################

# Number of Households Affected:

comp_hh_cs <-  compost_county %>% summarise(sum(cs))
comp_hh_cd <-  compost_county %>% summarise(sum(cd))

# Number of counties with curbside and/or dropoff:

comp_no_cnty <- compost_county %>% tally()

curbside_no_cnty <- compost_county %>%
  filter(cs > 0) %>%
  tally() %>% 
  as.numeric()

dropoff_no_cnty <- compost_county %>%
  filter(cd > 0) %>%
  tally() %>% 
  as.numeric()

# Amount of counties after GHG Merge:

comp_to_ghg_total_cnty <- compost_county %>% filter(county_fips %in% unique(ghg$county_fips)) %>% tally()

comp_to_ghg_curb_cnty <- compost_county %>%
  filter(cs > 0) %>% 
  filter(county_fips %in% unique(ghg$county_fips)) %>%
  tally()


comp_to_ghg_drop_cnty <- compost_county %>%
  filter(cd > 0) %>% 
  filter(county_fips %in% unique(ghg$county_fips)) %>%
  tally()

# Amount of Composting HH after GHG Merge:

comp_to_ghg_curb_hh <- compost_county %>%
  filter(cs > 0) %>% 
  filter(county_fips %in% unique(ghg$county_fips)) %>%
  summarise(num = sum(cs))

comp_to_ghg_curb_hh

 

# =================================================
# =================================================
# PART III - Summary stats by final dataset =======
# =================================================
# =================================================

There are six final datasets for analysis:
  
  #### (1) Unbalanced Baseline: (unbalanced facilities and counties)
  
  Removed the following:
  (A) GHG facility-year (observation) that:
  - Report Zero Emissions in a year (consider it an unbalanced facility)
(B) Composting communities that:
  - Remove communities with unknown treatment year(s).
- Remove communities with unknown FIPS (ex. Waste Areas, unable to locate using city-fips lookup).

#### (2) Balanced Counties, Unbalanced Facilities:

Removed the following: 
  - Any county that does not have reporting for all 8 years of the data (2010-2017).

#### (3) Balanced Baseline: (balanced facilities and implied counties)

Removed the following:
  - Any facility that does not have reporting for all 8 years of the data (2010-2017).
- By extension, this implies counties are also balanced.

#### (4) NA Adjusted Unbalanced Counties and Facilities:
- Adjusts (1) to drop any counties entirely (not just the community) if there is a community with unknown treatment years

#### (5) NA Adjusted Balanced Counties, Unbalanced Facilities:
- Adjusts (1) to drop any counties entirely (not just the community) if there is a community with unknown treatment years


Summary Statistics for each dataset I want:
  
  (1) Observational:
  - Observations, Unique Counties, Unique Landfills, Unique Communities
- Number of HH treated with CS and DO.

(2) Plot:
  - Plot and table of total GHG per year.

(3) Histogram:
  - Histogram of CS treatment.

(4) Maps:
  - Counties in Each dataset?
  
  
  ###### APPROACH TO CALCULATING OBSERVATIONAL STATISTICS:
  
  (1) # of counties, GHG, Observations, and HH affected are all very simple

(2) # of communities:

Single value for number of unique communities in the dataset 
Steps:
  - List of county FIPS in the entire final dataset being analyzed
-Drop any community from clean community level that is in a FIPS not in the final dataset 
- Drop WSAs and Boulder 
- Drop no start date communities 
- Tally() 


  

##############################
#### STEP 1 Read Datasets ####
##############################

# Community and county level data:
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/GHG Emissions and Sinks/Facility Community Level")

b_fac_ghg <- read.xlsx("facility_level_balanced.xlsx")
u_fac_ghg <- read.xlsx("facility_level_unbalanced.xlsx")


# Standard Datasets
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/All Counties")

complete_udataset_ufac <- read.xlsx("ghg_cmp_upanel_ufac.xlsx")
complete_bdataset_ufac <- read.xlsx("ghg_cmp_bpanel_ufac.xlsx")
complete_bdataset_bfac <- read.xlsx("ghg_cmp_bpanel_bfac.xlsx")


# Safe Datasets
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/Counties without NA Communities")

scomplete_udataset_ufac <- read.xlsx("dghg_cmp_upanel_ufac.xlsx")
scomplete_bdataset_ufac <- read.xlsx("dghg_cmp_bpanel_ufac.xlsx")
scomplete_bdataset_bfac <- read.xlsx("dghg_cmp_bpanel_bfac.xlsx")


 


  

#########################################
#### STEP 2 OBSERVATIONAL STATISTICS ####
#########################################

########################
#Unique FIPS in each Dataset:
########################

uu_fips <- unique(complete_udataset_ufac$county_fips)
bu_fips <- unique(complete_bdataset_ufac$county_fips)
bb_fips <- unique(complete_bdataset_bfac$county_fips)
suu_fips <- unique(scomplete_udataset_ufac$county_fips)
sbu_fips <- unique(scomplete_bdataset_ufac$county_fips)
sbb_fips <- unique(scomplete_bdataset_bfac$county_fips)

#####################
### UNIQUE FACILITIES
#####################

# Baseline Unique Facilities:
# Filtered to exclude zero facilities in all cases. 

# U U 
uu_facnum <- u_fac_ghg %>% mutate(year = as.character(year)) %>%
  group_by(year) %>% 
  summarise(Facilities = n_distinct(Facility.Id)) %>% 
  add_row(year = "Total:", Facilities = length(unique(u_fac_ghg$Facility.Id)))

# U and B -> additionally filter out facilities in FIPS that are dropped.
bu_reference <-  u_fac_ghg %>% filter(county_fips %in% bu_fips)
bu_facnum <- u_fac_ghg %>% mutate(year = as.character(year)) %>%
  filter(county_fips %in% bu_fips) %>%
  group_by(year) %>% 
  summarise(Facilities = n_distinct(Facility.Id)) %>% 
  add_row(year = "Total:", Facilities = length(unique(bu_reference$Facility.Id)))

# B and B
bb_facnum <- b_fac_ghg %>% mutate(year = as.character(year)) %>%
  group_by(year) %>% 
  summarise(Facilities = n_distinct(Facility.Id)) %>% 
  add_row(year = "Total:", Facilities = length(unique(b_fac_ghg$Facility.Id)))

# Safe U U 
suu_reference <-  u_fac_ghg %>% filter(county_fips %in% suu_fips)
suu_facnum <- u_fac_ghg %>% mutate(year = as.character(year)) %>%
  filter(county_fips %in% suu_fips) %>%
  group_by(year) %>% 
  summarise(Facilities = n_distinct(Facility.Id)) %>% 
  add_row(year = "Total:", Facilities = length(unique(suu_reference$Facility.Id)))

# Safe B U
sbu_reference <-  u_fac_ghg %>% filter(county_fips %in% sbu_fips)
sbu_facnum <- u_fac_ghg %>% mutate(year = as.character(year)) %>%
  filter(county_fips %in% sbu_fips) %>%
  group_by(year) %>% 
  summarise(Facilities = n_distinct(Facility.Id)) %>% 
  add_row(year = "Total:", Facilities = length(unique(sbu_reference$Facility.Id)))

# Safe B B
sbb_reference <- b_fac_ghg %>% filter(county_fips %in% sbb_fips)
sbb_facnum <- b_fac_ghg %>% mutate(year = as.character(year)) %>%
  filter(county_fips %in% sbb_fips) %>%
  group_by(year) %>% 
  summarise(Facilities = n_distinct(Facility.Id)) %>% 
  add_row(year = "Total:", Facilities = length(unique(sbb_reference$Facility.Id)))

#####################
### UNIQUE COMMUNITIES
#####################

# Baseline unique communities:
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Compost Data")
compost_ <- read.xlsx("biocycle_data2017clean.xlsx")
unsafe_cnty <- compost_ %>% filter(is.na(Start.Date) == T) %>% select(FIPS) %>% unique()
compost <- compost_ %>% 
  drop_na(Start.Date, FIPS) %>% # These observations aren't used in any datasets.
  rename(Region = `State/City/County/Waste.District`) %>% # Neither are these
  filter(Region != "Boulder County (11)1") # Multiple treatments in observation. Dropped.

# Unbalanced
uu_cmp <- compost %>% filter(FIPS %in% uu_fips) %>% tally()

# Bal FIPS unbal Community
bu_cmp <- compost %>% filter(FIPS %in% bu_fips) %>% tally()

# Balanaced
bb_cmp <- compost %>% filter(FIPS %in% bb_fips) %>% tally()

# Safe Unbalanced
suu_cmp <- compost %>% filter(FIPS %in% suu_fips) %>% tally()

# Safe FIPS bal unbal Com
sbu_cmp <- compost %>% filter(FIPS %in% sbu_fips) %>% tally()

# Safe Bal
sbb_cmp <- compost %>% filter(FIPS %in% sbb_fips) %>% tally()



# Observations, Unique Counties, Unique Landfills, Unique Communities
# Number of HH treated with CS and DO (From Balanced vs Unbalanced Facilities)

# Unbalanced facility and county:
uusummary <- complete_udataset_ufac %>% group_by(year) %>% 
  summarise(Observations = n(), 
            Counties = n_distinct(county_fips),
            CurbsideHHCumulative = sum(curbside_hh,na.rm=T),
            DropOffHHCumulative = sum(dropoff_hh,na.rm=T),
            CH4 = sum(ch4,na.rm=T)) %>%
  add_row(year = "Total:", Observations = sum(.$Observations),
          Counties = n_distinct(complete_udataset_ufac$county_fips),
          CurbsideHHCumulative = max(.$CurbsideHHCumulative),
          DropOffHHCumulative =  max(.$DropOffHHCumulative),
          CH4 = sum(.$CH4)) %>%
  left_join(uu_facnum, by = "year") %>%
  add_row(year =paste("Unique Communities: ",uu_cmp))

# Unbalanced facility and Balanced county:
busummary <- complete_bdataset_ufac %>% group_by(year) %>% 
  summarise(Observations = n(), 
            CurbsideHHCumulative = sum(curbside_hh,na.rm=T),
            DropOffHHCumulative = sum(dropoff_hh,na.rm=T),
            CH4 = sum(ch4,na.rm=T)) %>%
  add_row(year = "Total:", Observations = sum(.$Observations),
          CurbsideHHCumulative = max(.$CurbsideHHCumulative),
          DropOffHHCumulative =  max(.$DropOffHHCumulative),
          CH4 = sum(.$CH4)) %>%
  left_join(bu_facnum, by = "year") %>%
  add_row(year =paste("Unique Communities: ", bu_cmp))


# Balanced Facility and County:
bbsummary <- complete_bdataset_bfac %>% group_by(year) %>% 
  summarise(Observations = n(), 
            CurbsideHHCumulative = sum(curbside_hh,na.rm=T),
            DropOffHHCumulative = sum(dropoff_hh,na.rm=T),
            CH4 = sum(ch4,na.rm=T)) %>%
  add_row(year = "Total:", Observations = sum(.$Observations),
          CurbsideHHCumulative = max(.$CurbsideHHCumulative),
          DropOffHHCumulative =  max(.$DropOffHHCumulative),
          CH4 = sum(.$CH4)) %>%
  left_join(bb_facnum, by = "year") %>%
  add_row(year =paste("Unique Communities: ", bb_cmp))

# "Safe" Unbalanced facility and county:
suusummary <- scomplete_udataset_ufac %>% group_by(year) %>% 
  summarise(Observations = n(), 
            CurbsideHHCumulative = sum(curbside_hh,na.rm=T),
            DropOffHHCumulative = sum(dropoff_hh,na.rm=T),
            CH4 = sum(ch4,na.rm=T)) %>%
  add_row(year = "Total:", Observations = sum(.$Observations),
          CurbsideHHCumulative = max(.$CurbsideHHCumulative),
          DropOffHHCumulative =  max(.$DropOffHHCumulative),
          CH4 = sum(.$CH4)) %>%
  left_join(suu_facnum, by = "year") %>%
  add_row(year =paste("Unique Communities: ", suu_cmp))


# "Safe" Unbalanced facility and Balanced County
sbusummary <- scomplete_bdataset_ufac %>% group_by(year) %>% 
  summarise(Observations = n(), 
            CurbsideHHCumulative = sum(curbside_hh,na.rm=T),
            DropOffHHCumulative = sum(dropoff_hh,na.rm=T),
            CH4 = sum(ch4,na.rm=T)) %>%
  add_row(year = "Total:", Observations = sum(.$Observations),
          CurbsideHHCumulative = max(.$CurbsideHHCumulative),
          DropOffHHCumulative =  max(.$DropOffHHCumulative),
          CH4 = sum(.$CH4)) %>%
  left_join(sbu_facnum, by = "year") %>%
  add_row(year =paste("Unique Communities: ", sbu_cmp))

# "Safe" Balanced facility and County
sbbsummary <- scomplete_bdataset_bfac %>% group_by(year) %>% 
  summarise(Observations = n(), 
            CurbsideHHCumulative = sum(curbside_hh,na.rm=T),
            DropOffHHCumulative = sum(dropoff_hh,na.rm=T),
            CH4 = sum(ch4,na.rm=T)) %>%
  add_row(year = "Total:", Observations = sum(.$Observations),
          CurbsideHHCumulative = max(.$CurbsideHHCumulative),
          DropOffHHCumulative =  max(.$DropOffHHCumulative),
          CH4 = sum(.$CH4)) %>%
  left_join(sbb_facnum, by = "year") %>%
  add_row(year =paste("Unique Communities: ", sbb_cmp))
uusummary
busummary
bbsummary
suusummary
sbusummary
sbbsummary

 

  

####################################
#### STEP 3 GHG PLOT BY DATASET ####
####################################

# Get methane data
plotframe <- data.frame(cbind(uusummary$year,
                              uusummary$CH4,
                              busummary$CH4,
                              bbsummary$CH4,
                              suusummary$CH4,
                              sbusummary$CH4,
                              sbbsummary$CH4))
colnames(plotframe) = c("year","UU", "BU", "BB", "SUU", "SBU", "SBB")

plotframe <- plotframe[1:8,] %>% 
  mutate(year = as.numeric(as.character(year)),
         UU = as.numeric(as.character(UU)),
         BU = as.numeric(as.character(BU)),
         BB = as.numeric(as.character(BB)),
         SUU = as.numeric(as.character(SUU)),
         SBU = as.numeric(as.character(SBU)),
         SBB = as.numeric(as.character(SBB)))

# Graph it:
methaneplot2 <-  ggplot(plotframe) + 
  geom_line(aes(x=year,y=UU, color="UU")) +
  geom_line(aes(x=year,y=BU, color="BU")) +
  geom_line(aes(x=year,y=BB, color="BB")) +
  geom_line(aes(x=year,y=SUU, color="SUU")) +
  geom_line(aes(x=year,y=SBU, color="SBU")) +
  geom_line(aes(x=year,y=SBB, color="SBB")) +
  scale_x_continuous(breaks = round(seq(min(plotframe$year), max(plotframe$year), by = 1),1)) +
  scale_y_continuous(breaks = round(seq(70600000, 100600000, by = 2500000),1)) +
  labs(y = "Metric Tons of CH4 Emissions", x = "Year") +
  scale_color_manual(name = "Datasets", values = c("UU"= "#1B9E77", "BU" = "#D95F02","BB" = "#7570B3", "SUU" = "#E7298A", "SBU" = "#66A61E", "SBB" = "#E6AB02")) +
  theme(plot.title = element_text(hjust = 0.5, size=10)) + labs(color = "Data:")
show(methaneplot2)
 

  
##############################################
#### STEP 4 CS SHARE HISTOGRAM BY DATASET ####
##############################################

complete_udataset_ufac %>% filter(cs_treatshare > 0) %>% ggplot(aes(x = cs_treatshare)) + 
  geom_histogram(color="black", binwidth = 0.1,  fill="#1B9E77") +
  labs(y = "Frequency", x = "Treated Observation Share of HH with Curbside Composting")  +
  ylim(0,80)
complete_bdataset_ufac %>% filter(cs_treatshare > 0) %>% ggplot(aes(x = cs_treatshare)) + 
  geom_histogram(color="black", binwidth = 0.1,  fill="#D95F02") +
  labs(y = "Frequency", x = "Treated Observation Share of HH with Curbside Composting")  +
  ylim(0,80)
complete_bdataset_bfac %>% filter(cs_treatshare > 0) %>% ggplot(aes(x = cs_treatshare)) + 
  geom_histogram(color="black", binwidth = 0.1,  fill="#7570B3") +
  labs(y = "Frequency", x = "Treated Observation Share of HH with Curbside Composting")  +
  ylim(0,80)
scomplete_udataset_ufac %>% filter(cs_treatshare > 0) %>% ggplot(aes(x = cs_treatshare)) + 
  geom_histogram(color="black", binwidth = 0.1,  fill="#E7298A") +
  labs(y = "Frequency", x = "Treated Observation Share of HH with Curbside Composting")  +
  ylim(0,80)
scomplete_bdataset_ufac %>% filter(cs_treatshare > 0) %>% ggplot(aes(x = cs_treatshare)) + 
  geom_histogram(color="black", binwidth = 0.1,  fill="#66A61E") +
  labs(y = "Frequency", x = "Treated Observation Share of HH with Curbside Composting")  +
  ylim(0,80)
scomplete_bdataset_bfac %>% filter(cs_treatshare > 0) %>% ggplot(aes(x = cs_treatshare)) + 
  geom_histogram(color="black", binwidth = 0.1,  fill="#E6AB02") +
  labs(y = "Frequency", x = "Treated Observation Share of HH with Curbside Composting")  +
  ylim(0,80)
 



  

##############################################
#### STEP 4 CS NEW HH TREATMENT BY YEAR ######
##############################################

UUcs <- complete_udataset_ufac %>% group_by(year) %>%
  summarise(UU = sum(new_hhcs,na.rm=T))
BUcs <- complete_bdataset_ufac %>% group_by(year) %>%
  summarise(BU = sum(new_hhcs,na.rm=T))
BBcs <- complete_bdataset_bfac %>% group_by(year) %>%
  summarise(BB = sum(new_hhcs,na.rm=T))
SUUcs <- scomplete_udataset_ufac %>% group_by(year) %>%
  summarise(SUU = sum(new_hhcs,na.rm=T))
SBUcs <- scomplete_bdataset_ufac %>% group_by(year) %>%
  summarise(SBU = sum(new_hhcs,na.rm=T))
SBBcs <- scomplete_bdataset_bfac %>% group_by(year) %>%
  summarise(SBB = sum(new_hhcs,na.rm=T))

plotframe3 <- UUcs %>% left_join(BUcs, by="year") %>%
  left_join(BBcs, by="year") %>%
  left_join(SUUcs, by="year") %>%
  left_join(SBUcs, by="year") %>%  
  left_join(SBBcs, by="year") %>%
  mutate(year = as.double(year))
plotframe3
treatyear <-  ggplot(plotframe3) + 
  geom_line(aes(x=year,y=UU, color="UU")) +
  geom_line(aes(x=year,y=BU, color="BU")) +
  geom_line(aes(x=year,y=BB, color="BB")) +
  geom_line(aes(x=year,y=SUU, color="SUU")) +
  geom_line(aes(x=year,y=SBU, color="SBU")) +
  geom_line(aes(x=year,y=SBB, color="SBB")) +
  scale_x_continuous(breaks = round(seq(min(plotframe3$year), max(plotframe3$year), by = 1),1)) +
  scale_y_continuous(breaks = round(seq(0, 600000, by = 60000),1)) +
  labs(y = "New Households with Curbside Composting", x = "Year") +
  scale_color_manual(name = "Datasets", values = c("UU"= "#1B9E77", "BU" = "#D95F02","BB" = "#7570B3", "SUU" = "#E7298A", "SBU" = "#66A61E", "SBB" = "#E6AB02")) +
  theme(plot.title = element_text(hjust = 0.5, size=10)) + labs(color = "Data:")

show(treatyear)
 

















