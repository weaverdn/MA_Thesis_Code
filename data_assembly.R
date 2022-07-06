library(tidyverse)
library(plm)
library(knitr)
library(stringr)
library(RCurl)
library(RJSONIO)
library(pdftables)
library(openxlsx)
library(reshape2)
library(tidycensus)

# Helper functions:

# Standard "Not In":
`%!in%` <- function(x,y)!(`%in%`(x,y))

# Mode:

Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}


 

# ==============================================================
# ==============================================================
# ========= PART I - MSW GHG DATA CLEAN/MERGE/LOCATE ===========
# ==============================================================
# ==============================================================

  

############################################################
#### Step 1 - Create Unbalanced Panel of MSW GHG Data ######
############################################################

# Read GHG Emissions data for 2010-2019. Subset for only municipal waste sector (HH).

ghg2010 <-  read.csv("ghgp_data_2010_8_4_19.csv", skip=3)
ghg2010$year <- 2010
ghg2010_filtered <-  ghg2010 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2010_filtered <-  ghg2010_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

ghg2011 <-  read.csv("ghgp_data_2011_8_4_19.csv", skip=3)
ghg2011$year <-  2011
ghg2011_filtered <-  ghg2011 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2011_filtered <-  ghg2011_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

ghg2012 <- read.csv("ghgp_data_2012_8_4_19.csv", skip=3)
ghg2012$year <- 2012
ghg2012_filtered <- ghg2012 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2012_filtered <- ghg2012_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

ghg2013 <- read.csv("ghgp_data_2013_9_26_20.csv", skip=3)
ghg2013$year <- 2013
ghg2013_filtered <- ghg2013 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2013_filtered <- ghg2013_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

ghg2014 <- read.csv("ghgp_data_2014_8_7_2021.csv", skip=3)
ghg2014$year <- 2014
ghg2014_filtered <- ghg2014 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2014_filtered <- ghg2014_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

ghg2015 <- read.csv("ghgp_data_2015_8_7_2021.csv", skip=3)
ghg2015$year <- 2015
ghg2015_filtered <- ghg2015 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2015_filtered <- ghg2015_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

ghg2016 <- read.csv("ghgp_data_2016_8_7_2021.csv", skip=3)
ghg2016$year <- 2016
ghg2016_filtered <- ghg2016 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2016_filtered <- ghg2016_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

ghg2017 <- read.csv("ghgp_data_2017_8_7_2021.csv", skip=3)
ghg2017$year <- 2017
ghg2017_filtered <- ghg2017 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2017_filtered <- ghg2017_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

ghg2018 <- read.csv("ghgp_data_2018_8_7_2021.csv", skip=3)
ghg2018$year <- 2018
ghg2018_filtered <- ghg2018 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2018_filtered <- ghg2018_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

ghg2019 <- read.csv("ghgp_data_2019_8_7_2021.csv", skip=3)
ghg2019$year <- 2019
ghg2019_filtered <- ghg2019 %>% select(year, County, State, Facility.Id, Facility.Name, City, Zip.Code, Latitude, Longitude, Industry.Type..subparts., Industry.Type..sectors., Total.reported.direct.emissions, Methane..CH4..emissions)
ghg2019_filtered <- ghg2019_filtered %>% filter(grepl("HH",Industry.Type..subparts.) == TRUE)

# Join into a single panel
ghgmerge = list(ghg2010_filtered, ghg2011_filtered, ghg2012_filtered,
                ghg2013_filtered, ghg2014_filtered, ghg2015_filtered, 
                ghg2016_filtered, ghg2017_filtered, ghg2018_filtered,
                ghg2019_filtered)

ghg <- ghgmerge %>% bind_rows(.id = "column_label")
ghgclean <- ghg

#write.csv(ghgclean,"mswghg.csv")
 


  

############################################################
#### Step 2 - Geolocate MSW Waste Facilities by County #####
############################################################

# Problem: Only County name is provided. Need FIPS to merge with census data and Map Data
# Write function to add FIPS based on latitude and longitude

latlong2fips <- function(latitude, longitude) {
  url <- "https://geo.fcc.gov/api/census/block/find?format=json&latitude=%f&longitude=%f"
  if (is.na(latitude) | is.na(longitude)) {
    NA 
  }
  
  else {
    url <- sprintf(url, latitude, longitude)
    json <- getURL(url)
    json <- fromJSON(json)
    as.character(json$County['FIPS']) }
}

# Execute function. This function takes 2 hours to run and is unstable. 

holder = rep(0,nrow(ghg))
i = 1
# for (j in 1:nrow(ghg)) {
#
#   obs = ghg[i,]
#   fips = latlong2fips(latitude=obs$Latitude, longitude=obs$Longitude)
#   holder[i] = fips
#   i = i + 1
# }

holderdf = data.frame(holder)
# The output of the function is in file ordered_fips.csv

# write_csv(holderdf,"fips_ordered.csv")

 

  

############################################################
#### Step 3 - Merge GHG Data with FIPS, Save Output    #####
############################################################

#ghg_fips = cbind(ghg, holderdf)
#urbn_ghg = ghg_fips %>% rename(county_fips = holder)

# One Exception: NULL value for Toytown facility, St. petersburg. Manually add Pinellas County (county 12103)

#urbg_ghg = urbn_ghg %>% mutate(county_fips = ifelse(Facility.Id ==1006532),"12103", county_fips)
#write_csv(urbn_ghg, "mswch4panel_fips.csv")

 

# ==============================================================
# ==============================================================
# ===== PART II - ADD LANDFILL CHARACTERISTICS TO GHG  =========
# ==============================================================
# ==============================================================

  

############################################################
#### Step 1 - LOAD LANDFILL CHARACTERISTICS AND COUNTS  ####
############################################################

# WILL DEAL WITH THIS, TIME PERMITTING. THINGS TO LOOK OUT FOR:

# 1) FACILITY ACREAGE -> TOTAL COUNTY MSW ACRES
# 2) PUBLIC/PVT -> TOTAL COUNTY PVT AND TOTAL COUNTY PVT (REPLACE TOTAL FAC NUM)
# 3) WASTE TO DATE -> TOTAL WASTE TO DATE BY COUNTY
# 4) LFG CAPTURE IN YEAR (PROJECT START DATE AND SHUTDOWN DATE) TIMES CURRENT YEAR EMISSIONS REDUCTIONS (DIRECT) -> ADD TO TWFE EVENT-STUDY 
 


# ==============================================================
# ==============================================================
# ===== PART II - CONVERT BIOCYCLE PDF TO COMPOST DATABASE =====
# ==============================================================
# ==============================================================

  
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Compost Data")

############################################################
##### STEP 1 - CONVERT PDF TO XSLX USING PDFTABLES   #######
############################################################

# Note: Personal API used. Please purchase API to replicate.

#convert_pdf('biocycle_data2017.pdf', output_file = NULL, format = "xlsx-single", message = TRUE, api_key = INSERT API KEY HERE)
 


  
############################################################
########### STEP 2 - MANUALLY CLEAN SPACING:  ##############
############################################################

# Manually cleaned incorrect spacing and added column for state, rather than row identifier in Excel. Cleaned file is biocycle_data2017_fromPDF.xslx
 


  

############################################################
########### STEP 3 - ADD TREATMENT START DATES :  ##########
############################################################

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Compost Data")

# Load Biocycle Data
biocycle <- read.xlsx("biocycle_data2017_fromPDF.xlsx", startRow=3)

# Clean Treatment Year and separate by Dropoff or Curbside:
biocycle <- biocycle %>% 
  mutate(Curbside = ifelse(is.na(Curbside) == F & Curbside == "x",1,0),
         Drop.Off = ifelse(is.na(Drop.Off) == F & Drop.Off == "x",1,0)) %>%
  mutate(CS.Start.Date = 
           ifelse(Curbside == 1, 
                  ifelse(Drop.Off == 1,
                         ifelse(grepl("^CS",Start.Date), 
                                substring(Start.Date,5,8),Start.Date),Start.Date),"None")) %>%
  mutate(DO.Start.Date = 
           ifelse(Drop.Off == 1,
                  ifelse(Curbside == 1,
                         ifelse(grepl("^CS",Start.Date),
                                substring(Start.Date,15,18),Start.Date), Start.Date),"None"))


# Deal with Boulder, Colorado Exception (varied treatment):

biocycle <- biocycle %>% 
  mutate(CS.Start.Date = 
           ifelse(`State/City/County/Waste.District` == "Boulder County (11)1",
                  "varies",CS.Start.Date),
         DO.Start.Date =
           ifelse(`State/City/County/Waste.District` == "Boulder County (11)1",
                  "varies",DO.Start.Date))

# Rename Household Variable to specify community:
biocycle <- biocycle %>% rename(hh_cs_community = Households.with.Access.to.Curbside,
                                hh_do_community = Households.with.Access.to.Drop.Off)

# Change NA to 0 for Households affected. 
# NOTE these are TRUE zeroes. Empty cell in survey implies no homes receiving treatment.
# The only exception is Barnstable, MA. There, the number of Households with Drop.Off is genuinely unknown.
biocycle <- biocycle %>% mutate(hh_cs_community = ifelse(is.na(hh_cs_community), 0, hh_cs_community),
                                hh_do_community = ifelse(is.na(hh_do_community), 0, hh_do_community)) %>%
  mutate(hh_do_community = 
           ifelse(`State/City/County/Waste.District` == "Barnstable",
                  NA, hh_do_community))

 


  

############################################################
########### STEP 4 - ADD FIPS TO COMMUNITIES :  ############
############################################################

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Compost Data")

# Load FIPS - Community Crosswalk, Compiled by Me
crosswalk <- read.xlsx("Compost_FIPS_Crosswalk.xlsx",startRow = 3,sheet=1)

# Join with cleaned compost data and weigh affected households by population coverage:

biocycle_fips <- crosswalk %>% 
  left_join(biocycle, by="State/City/County/Waste.District") %>%
  mutate(hh_cs_county = PopulationCoverage * hh_cs_community,
         hh_do_county = PopulationCoverage * hh_do_community)

write.xlsx(biocycle_fips,"biocycle_data2017clean.xlsx")
 


# ==============================================================
# ==============================================================
# ======== PART III - CENSUS & ACS & ELECTIONS   ===============
# ==============================================================
# ==============================================================

  
################################################################
##### Step 1 - Census Data 2010 - Population & HHs #############
################################################################

# Read Census Household and Population Data, ready for merge.
pop10lookup <- load_variables(2010 ,"pl")
pop10 <- get_decennial(year = 2010, geography="county", 
                       variables=c("P001001","H013001"))

pop10 <- pop10 %>% rename(val = value) %>% 
  dcast(GEOID + NAME ~ variable) %>%
  rename(hh = H013001, pop = P001001, county_fips = GEOID)


################################################################
##### Step 2 - ACS Data 2010-2017 - Various Variables ##########
################################################################

# Read American Community Survey Population and HH data:
# Variables: Population, Households, AvgHHsize, Median Income, Median Age, Homeowner%ofHousingUnits


acs10 <- get_acs(geography="county",
                 variables=c("DP05_0001E","DP02_0001E", "DP02_0016E","DP03_0062E","DP04_0046PE"),
                 survey="acs5", year=2010) %>%
  mutate(variable = ifelse(variable == "DP05_0001", "Population", 
                           ifelse(variable == "DP02_0001", "Households",
                                  ifelse(variable == "DP02_0016", "AvgHHSize",
                                         ifelse(variable == "DP03_0062", "MedianIncome", 
                                                ifelse(variable == "DP04_0046P", "RenterFraction", "x")))))) %>%
  rename(value = estimate) %>%
  select(GEOID, NAME, variable, value) %>%
  dcast(GEOID + NAME ~ variable) %>%
  mutate(year = 2010)

acs11 <- get_acs(geography="county",
                 variables=c("DP05_0001E","DP02_0001E", "DP02_0016E","DP03_0062E","DP04_0046PE"),
                 survey="acs5", year=2011) %>%
  mutate(variable = ifelse(variable == "DP05_0001", "Population", 
                           ifelse(variable == "DP02_0001", "Households",
                                  ifelse(variable == "DP02_0016", "AvgHHSize",
                                         ifelse(variable == "DP03_0062", "MedianIncome", 
                                                ifelse(variable == "DP04_0046P", "RenterFraction", "x")))))) %>%
  rename(value = estimate) %>%
  select(GEOID, NAME, variable, value) %>%
  dcast(GEOID + NAME ~ variable) %>%
  mutate(year = 2011)

acs12 <- get_acs(geography="county",
                 variables=c("DP05_0001E","DP02_0001E", "DP02_0016E","DP03_0062E","DP04_0046PE"),
                 survey="acs5", year=2012) %>%
  mutate(variable = ifelse(variable == "DP05_0001", "Population", 
                           ifelse(variable == "DP02_0001", "Households",
                                  ifelse(variable == "DP02_0016", "AvgHHSize",
                                         ifelse(variable == "DP03_0062", "MedianIncome", 
                                                ifelse(variable == "DP04_0046P", "RenterFraction", "x")))))) %>%
  rename(value = estimate) %>%
  select(GEOID, NAME, variable, value) %>%
  dcast(GEOID + NAME ~ variable) %>%
  mutate(year = 2012)

acs13 <- get_acs(geography="county",
                 variables=c("DP05_0001E","DP02_0001E", "DP02_0016E","DP03_0062E","DP04_0046PE"),
                 survey="acs5", year=2013) %>%
  mutate(variable = ifelse(variable == "DP05_0001", "Population", 
                           ifelse(variable == "DP02_0001", "Households",
                                  ifelse(variable == "DP02_0016", "AvgHHSize",
                                         ifelse(variable == "DP03_0062", "MedianIncome", 
                                                ifelse(variable == "DP04_0046P", "RenterFraction", "x")))))) %>%
  rename(value = estimate) %>%
  select(GEOID, NAME, variable, value) %>%
  dcast(GEOID + NAME ~ variable) %>%
  mutate(year = 2013)

acs14 <- get_acs(geography="county",
                 variables=c("DP05_0001E","DP02_0001E", "DP02_0016E","DP03_0062E","DP04_0046PE"),
                 survey="acs5", year=2014) %>%
  mutate(variable = ifelse(variable == "DP05_0001", "Population", 
                           ifelse(variable == "DP02_0001", "Households",
                                  ifelse(variable == "DP02_0016", "AvgHHSize",
                                         ifelse(variable == "DP03_0062", "MedianIncome", 
                                                ifelse(variable == "DP04_0046P", "RenterFraction", "x")))))) %>%
  rename(value = estimate) %>%
  select(GEOID, NAME, variable, value) %>%
  dcast(GEOID + NAME ~ variable) %>%
  mutate(year = 2014)

acs15 <- get_acs(geography="county",
                 variables=c("DP05_0001E","DP02_0001E", "DP02_0016E","DP03_0062E","DP04_0046PE"),
                 survey="acs5", year=2015) %>%
  mutate(variable = ifelse(variable == "DP05_0001", "Population", 
                           ifelse(variable == "DP02_0001", "Households",
                                  ifelse(variable == "DP02_0016", "AvgHHSize",
                                         ifelse(variable == "DP03_0062", "MedianIncome", 
                                                ifelse(variable == "DP04_0046P", "RenterFraction", "x")))))) %>%
  rename(value = estimate) %>%
  select(GEOID, NAME, variable, value) %>%
  dcast(GEOID + NAME ~ variable) %>%
  mutate(year = 2015)

acs16 <- get_acs(geography="county",
                 variables=c("DP05_0001E","DP02_0001E", "DP02_0016E","DP03_0062E","DP04_0046PE"),
                 survey="acs5", year=2016) %>%
  mutate(variable = ifelse(variable == "DP05_0001", "Population", 
                           ifelse(variable == "DP02_0001", "Households",
                                  ifelse(variable == "DP02_0016", "AvgHHSize",
                                         ifelse(variable == "DP03_0062", "MedianIncome", 
                                                ifelse(variable == "DP04_0046P", "RenterFraction", "x")))))) %>%
  rename(value = estimate) %>%
  select(GEOID, NAME, variable, value) %>%
  dcast(GEOID + NAME ~ variable) %>%
  mutate(year = 2016)

acs17 <- get_acs(geography="county",
                 variables=c("DP05_0001E","DP02_0001E", "DP02_0016E","DP03_0062E","DP04_0046PE"),
                 survey="acs5", year=2017) %>%
  mutate(variable = ifelse(variable == "DP05_0001", "Population", 
                           ifelse(variable == "DP02_0001", "Households",
                                  ifelse(variable == "DP02_0016", "AvgHHSize",
                                         ifelse(variable == "DP03_0062", "MedianIncome", 
                                                ifelse(variable == "DP04_0046P", "RenterFraction", "x")))))) %>%
  rename(value = estimate) %>%
  select(GEOID, NAME, variable, value) %>%
  dcast(GEOID + NAME ~ variable) %>%
  mutate(year = 2017)

acs <- rbind(acs10,acs11,acs12,acs13,acs14,acs15,acs16,acs17)

# NOTE: The Household Renter Pct Variable Changes in 2014:
# 2010-2014, DP04_0046PE measures % renting. 2015 onwards, it is % owning. 
# I want %Renting:
# Convert value in years after 2015 to inverse:

acs <- acs %>% mutate(RenterFraction = ifelse(year >=2015, (100 - RenterFraction)/100, RenterFraction/100))

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Census")
write.xlsx(pop10,"census_households.xlsx")
write.xlsx(acs, "acs_counties.xlsx")
 


  
################################################################
##### Step 3 - ELECTION Data 2010-2017 - County % Democrat #####
################################################################

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Elections")
elections <-  read.csv("countypres_2000-2020.csv") %>% 
  filter(party == "DEMOCRAT", mode == "TOTAL",
         year >=2008, year<=2017) %>%
  mutate(county_fips = ifelse(nchar(county_fips) == 4,
                              paste("0",county_fips,sep=""),
                              county_fips)) %>%
  select(year, county_fips, candidatevotes, totalvotes) %>% 
  rowwise() %>%
  mutate(demshare = candidatevotes/totalvotes) %>%
  select(year, county_fips, demshare)

# Assemble a dataframe for 2010-2017 with last election demshare results:

el10 <- elections %>% filter(year == 2008) %>% mutate(year = 2010)
el11 <- elections %>% filter(year == 2008) %>% mutate(year = 2011)
el12 <- elections %>% filter(year == 2012)
el13 <- elections %>% filter(year == 2012) %>% mutate(year = 2013)
el14 <- elections %>% filter(year == 2012) %>% mutate(year = 2014)
el15 <- elections %>% filter(year == 2012) %>% mutate(year = 2015)
el16 <- elections %>% filter(year == 2016)
el17 <- elections %>% filter(year == 2016) %>% mutate(year = 2017)

elections <- rbind(el10,el11,el12,el13,el14,el15,el16,el17)

# Export: 

write.xlsx(elections, "countyvote_clean.xlsx")

 


# =====================================================================
# =====================================================================
# === PART IV - PREPARE COMPOST, GHG, FOR MERGING AT COUNTY LEVEL  ====
# =====================================================================
# =====================================================================

  

##############################################################################
##### STEP 1 - Aggregate  GHG data to County-Year Level + ready for merge  ###
##############################################################################

# Read Methane Data, ready for merge.
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/GHG Emissions and Sinks")
ghg_to_merge <-  read.csv("mswch4panel_fips.csv")

# Get Unbalanced and Balanced Facilities: Define Balanced as Facility with GHG for 2010-2017.

ghg_to_merge_balanced <- ghg_to_merge %>%
  filter(Total.reported.direct.emissions !=0) %>% # remove zero
  filter(year %in% c(2010:2017)) %>% 
  group_by(Facility.Id) %>% 
  mutate(cnt = n()) %>% filter(cnt == 8) %>% select(-c(cnt))

ghg_to_merge_unbalanced <- ghg_to_merge %>% filter(year %in% c(2010:2017))

##############################################################################################
### Aside - Find facilities with >1 county associated (error in fips matching for a year) ###
##############################################################################################

# Investigate the error:
fipserror_facs <- ghg_to_merge %>% group_by(Facility.Id) %>% 
  mutate(cnt = length(unique(county_fips))) %>% 
  filter(cnt >=2) %>% 
  select(year, Facility.Name, Facility.Id, Latitude, Longitude, county_fips)

# The Error here is caused by Longitude/Latitude Rounding.
# 2010 Facilities can sometimes differ in county because of rounding errors versus 2011-2019.
# I assume that the location hasn't actually changed, and that the 2010 county SHOULD be the 2011-2019 county.
# By this rule, I apply the majority county to the 2010 rounding error values.

# While I'm at it, I eliminate facility-years that report 0 emissions. it is either an error, or operations have yet to start.
ghg_to_merge_balanced <- ghg_to_merge_balanced %>%
  group_by(Facility.Id) %>% 
  mutate(county_fips = Mode(county_fips))

ghg_to_merge_unbalanced <- ghg_to_merge_unbalanced %>% 
  filter(Total.reported.direct.emissions !=0) %>% # Remove zero facilities.
  group_by(Facility.Id) %>% 
  mutate(county_fips = Mode(county_fips))

facility_level_balanced <- ghg_to_merge_balanced
facility_level_unbalanced <- ghg_to_merge_unbalanced

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/GHG Emissions and Sinks/Facility Community Level")
write.xlsx(facility_level_balanced, "facility_level_balanced.xlsx")
write.xlsx(facility_level_unbalanced, "facility_level_unbalanced.xlsx")

##############################################
### ASIDE FINISHED. CONTINUE MAIN ASSEMBLY ###
##############################################

# Create County-level emissions data:
ghg_to_merge_balanced <- ghg_to_merge_balanced %>%
  mutate(county_fips = as.character(county_fips)) %>%
  mutate(county_fips = ifelse(nchar(county_fips) == 4,
                              paste("0",county_fips,sep=""), county_fips)) %>%
  group_by(year, county_fips) %>%
  summarise(facnum = n_distinct(Facility.Id),
            ghg = sum(Total.reported.direct.emissions,na.rm=T),
            ch4 = sum(Methane..CH4..emissions,na.rm=T))

ghg_to_merge_unbalanced <- ghg_to_merge_unbalanced %>% 
  mutate(county_fips = as.character(county_fips)) %>%
  mutate(county_fips = ifelse(nchar(county_fips) == 4,
                              paste("0",county_fips,sep=""), county_fips)) %>%
  group_by(year, county_fips) %>%
  summarise(facnum = n_distinct(Facility.Id),
            ghg = sum(Total.reported.direct.emissions,na.rm=T),
            ch4 = sum(Methane..CH4..emissions,na.rm=T))
 

  

####################################################
##### STEP 3 - CREATE PANEL FOR COUNTY GHG #########
####################################################

# GHG PANEL - Create a panel of ALL counties reporting GHG, 2010-2017:

# ====================== Unbalanced Facilities ======================
ghg_panel_unbfac <- pdata.frame(ghg_to_merge_unbalanced, index = c("county_fips","year"))
ghg_panel_unbfac_balanced <- make.pbalanced(ghg_panel_unbfac) # NA values for counties not in a year
ghg_panel_unbfac_drop <- ghg_panel_unbfac %>% 
  filter(year %in% c(2010:2017)) %>%
  group_by(county_fips) %>%
  mutate(cnt = n()) %>%
  filter(cnt == 8) # Panel of only counties present all 8 years. 

# ====================== Balacnced Facilities ========================
ghg_panel_bfac <- pdata.frame(ghg_to_merge_balanced, index = c("county_fips","year"))

# Only one dataset is needed because balanced facilities implies balanced counties.

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/GHG Emissions and Sinks/County Level Panel")
write.xlsx(ghg_panel_unbfac_balanced,"countyCH4_unbalancedfac.xlsx") # unbalanced facilities
write.xlsx(ghg_panel_unbfac_drop, "countyCH4_unbalancedfac_balcnty.xlsx") # unbalanced fac, bal cnty
write.xlsx(ghg_panel_bfac,"countyCH4_balancedfac.xlsx") # balanced facility and county
 

  

#################################################################################
##### STEP 3 - Aggregate Compost data to County-Year Level + ready for merge  ###
#################################################################################

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Compost Data")

# Read cleaned biocycle survey:
cmp_ <- read.xlsx("biocycle_data2017clean.xlsx")

###### === DROP OBSERVATIONS MISSING START YEAR, FIPS, & BOULDER ====

# Keep list of fips affected by dropped observations:

hh_affectedby_NA <- cmp_ %>% 
  group_by(FIPS) %>%
  mutate(total_hh_cs = sum(hh_cs_county,na.rm=T), 
         total_hh_do = sum(hh_do_county,na.rm=T)) %>%
  ungroup() %>%
  filter(is.na(CS.Start.Date) == T | is.na(DO.Start.Date) == T) %>%
  group_by(FIPS) %>%
  summarize(hhcs_drop = sum(hh_cs_county,na.rm=T)/total_hh_cs, 
            hhdo_drop = sum(hh_do_county,na.rm=T)/total_hh_do)

biased_counties <- unique(hh_affectedby_NA$FIPS)

# Note: there are no counties that have NA for Curbside or Dropoff but a known date for another. Therefore, remove.

# Filter main dataset to exclude Boulder county and communities missing start date.
cmp_ <- cmp_ %>% 
  drop_na(FIPS) %>%        
  filter(FIPS != "08013") %>% # Boulder and others in county
  filter(is.na(CS.Start.Date) == F,
         is.na(DO.Start.Date) == F) # eliminate if missing start (NA not None)

# Aggregate compost data to county level.
cmp_county <- cmp_ %>%
  rename(county_fips = FIPS,
         cs_year = CS.Start.Date,
         do_year = DO.Start.Date) %>%
  group_by(cs_year, do_year, county_fips) %>%
  summarise(hh_cs = sum(hh_cs_county), hh_do = sum(hh_do_county))

# Replace "None" treatment type with NaN.
# A note: NA refers to MISSING data. NaN refers to "not a number", i.e. no treatment.
cmp_county$do_year = ifelse(cmp_county$do_year == "None", NaN, cmp_county$do_year)
cmp_county$cs_year = ifelse(cmp_county$cs_year == "None", NaN, cmp_county$cs_year)

# Calcualte No. of treated households pre-2010:
pre2010_hhcs <- cmp_county %>% group_by(county_fips,cs_year) %>%
  filter(cs_year < 2010) %>% 
  group_by(county_fips) %>%
  mutate(pre10hh_cs = sum(hh_cs)) %>%
  select(county_fips, pre10hh_cs) %>% distinct()

pre2010_hhdo <- cmp_county %>% group_by(county_fips,do_year) %>%
  filter(do_year < 2010) %>% 
  group_by(county_fips) %>%
  mutate(pre10hh_do = sum(hh_do)) %>%
  select(county_fips,pre10hh_do) %>% distinct()

# Add list of years county gets treatment:
treatyears <- cmp_county %>%
  group_by(county_fips) %>%
  summarise(cs_treatyears = as.character(list(cs_year)),
            do_treatyears = as.character(list(do_year)))

# Add list of households treated in FIP each year:
hhtreat <- cmp_county %>%
  group_by(county_fips) %>%
  summarise(cs_new_list = as.character(list(hh_cs)),
            do_new_list = as.character(list(hh_do)))

# Merge
treatment_rollout <- left_join(treatyears,hhtreat,by = "county_fips")

 

  

########################################################
##### STEP 4 - CREATE PANEL FOR COUNTY COMPOST #########
########################################################

# Create a 2010 to 2017 Panel of all Eventually Treated Counties.
unique_cmp_fips <- unique(cmp_county$county_fips)
cmp_years = 2010:2017

cmp_panel <- data.frame("year" = rep(cmp_years,length(unique_cmp_fips))) %>%
  arrange(year, by_group=FALSE) %>%
  mutate(county_fips = rep(unique_cmp_fips,8)) %>%
  pdata.frame(index = c("county_fips","year"))

# Add amount of CS and DO treated before 2010:
cmp_panel <- cmp_panel %>% left_join(pre2010_hhcs, by = "county_fips") %>%
  mutate(pre10hh_cs = ifelse(is.na(pre10hh_cs), 0, pre10hh_cs)) %>%
  left_join(pre2010_hhdo, by = "county_fips") %>%
  mutate(pre10hh_do = ifelse(is.na(pre10hh_do), 0, pre10hh_do))

# Add treatment year list:
cmp_panel <- cmp_panel %>% 
  left_join(treatment_rollout, by="county_fips")


# Add new treated HH to cmp_panel by year:
cmp_panel <- cmp_panel %>% left_join(cmp_county[,-c(2,5)], by=c("county_fips","year" = "cs_year")) %>%
  left_join(cmp_county[,-c(1,4)], by=c("county_fips","year" = "do_year")) %>%
  rename(new_hhcs = hh_cs, new_hhdo = hh_do) %>%
  mutate(new_hhcs = replace(new_hhcs, is.na(new_hhcs),0),
         new_hhdo = replace(new_hhdo, is.na(new_hhdo),0))

# Add cumulative treatment tracking:
cmp_panel <- cmp_panel %>% 
  group_by(county_fips) %>% 
  mutate(curbside_hh = cumsum(new_hhcs),
         dropoff_hh = cumsum(new_hhdo)) %>%
  rowwise() %>%
  mutate(curbside_hh = sum(curbside_hh,pre10hh_cs,na.rm=T),
         dropoff_hh = sum(dropoff_hh,pre10hh_do,na.rm=T))

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Compost Data")
write.xlsx(cmp_panel,"compost_county_panel.xlsx")

 

# ===============================================================
# ===============================================================
# === PART V - MERGE GHG DATA WITH COMPOST AND CENSUS DATA  =====
# ===============================================================
# ===============================================================

  

##################################################
##### STEP 1 - IMPORT COUNTY-LEVEL DATA  #########
##################################################

# Read compost data:
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Compost Data")
compost <- read.xlsx("compost_county_panel.xlsx")

# Read GHG data:
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/GHG Emissions and Sinks/County Level Panel")

# Read data but ignore observations with 0 values for CH4 (before operation)
ghg_unbfac_unbcnty <- read.xlsx("countyCH4_unbalancedfac.xlsx") %>% filter(ch4 != 0)
ghg_bfac <- read.xlsx("countyCH4_balancedfac.xlsx") %>% filter(ch4 != 0)
ghg_unbfac_bcnty <- read.xlsx("countyCH4_unbalancedfac_balcnty.xlsx") %>% filter(ch4 != 0)

# Read Census Data:
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Census")
census <- read.xlsx("census_households.xlsx")
acs <- read.xlsx("acs_counties.xlsx") %>% 
  rename(county_fips = GEOID) %>%
  mutate(year = as.character(year))

# Read Election Data:
setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Elections")
elect <- read.xlsx("countyvote_clean.xlsx") %>%
  mutate(year = as.character(year))

 


  
##################################################
####### STEP 2 - MERGE WITH GHG AS BASE  #########
##################################################

# Unbalanced Facilities, unbalanced counties:
complete_udataset_ufac <- ghg_unbfac_unbcnty %>% 
  filter(ch4 != 0) %>%
  left_join(compost, by=c("county_fips","year")) %>%
  left_join(acs, by=c("county_fips", "year")) %>% 
  left_join(elect,by=c("county_fips", "year")) %>% rowwise() %>%
  mutate(cs_treatshare = curbside_hh/Households,
         do_treatshare = dropoff_hh/Households)  %>%
  mutate(cs_treatshare = replace(cs_treatshare, is.na(cs_treatshare),0),
         do_treatshare = replace(do_treatshare, is.na(do_treatshare),0)) %>%
  mutate(do_treatshare = ifelse(do_treatshare >= 1, 1, do_treatshare))

# Unbalanced Facilities, balanced counties
complete_bdataset_ufac <- ghg_unbfac_bcnty %>% 
  filter(ch4 != 0) %>%
  left_join(compost, by=c("county_fips","year")) %>%
  left_join(acs, by=c("county_fips", "year")) %>% 
  left_join(elect,by=c("county_fips", "year")) %>% rowwise() %>%
  mutate(cs_treatshare = curbside_hh/Households,
         do_treatshare = dropoff_hh/Households)  %>%
  mutate(cs_treatshare = replace(cs_treatshare, is.na(cs_treatshare),0),
         do_treatshare = replace(do_treatshare, is.na(do_treatshare),0)) %>%
  mutate(do_treatshare = ifelse(do_treatshare >= 1, 1, do_treatshare))

# Balanced Facilities, balanced counties
complete_bdataset_bfac <- ghg_bfac %>% 
  filter(ch4 != 0) %>%
  left_join(compost, by=c("county_fips","year")) %>%
  left_join(acs, by=c("county_fips", "year")) %>% 
  left_join(elect,by=c("county_fips", "year")) %>% rowwise() %>%
  mutate(cs_treatshare = curbside_hh/Households,
         do_treatshare = dropoff_hh/Households)  %>%
  mutate(cs_treatshare = replace(cs_treatshare, is.na(cs_treatshare),0),
         do_treatshare = replace(do_treatshare, is.na(do_treatshare),0)) %>%
  mutate(do_treatshare = ifelse(do_treatshare >= 1, 1, do_treatshare))

 


  

##################################################
####### STEP 3 - EXPORT DATASET VARIANTS  ########
##################################################

# MAIN SPECIFICATIONS:

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/All Counties")
write.xlsx(complete_udataset_ufac, "ghg_cmp_upanel_ufac.xlsx")
write.xlsx(complete_bdataset_ufac, "ghg_cmp_bpanel_ufac.xlsx")
write.xlsx(complete_bdataset_bfac, "ghg_cmp_bpanel_bfac.xlsx")

# ALTERNATIVE SPCECIFICATIONS: 

setwd("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/Counties without NA Communities")
# Drop county if county has a community with unknown treat year:
dataset = complete_udataset_ufac %>% filter(county_fips %!in% biased_counties)
write.xlsx(dataset, "dghg_cmp_upanel_ufac.xlsx")
dataset = complete_bdataset_ufac %>% filter(county_fips %!in% biased_counties)
write.xlsx(dataset, "dghg_cmp_bpanel_ufac.xlsx")
dataset = complete_bdataset_bfac %>% filter(county_fips %!in% biased_counties)
write.xlsx(dataset, "dghg_cmp_bpanel_bfac.xlsx")

 

