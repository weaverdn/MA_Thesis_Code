wastekgperweek_to_tonmethaneperyar <- function(kgwaste_per_week, co2e) {
  x = kgwaste_per_week
  x = 52*x # KG WASTE PER YEAR
  x = x/1000 # TON WASTE PER YEAR
  x = x*co2e # TON CO2e PER YEAR
  x = x/25 # TON METHANE PER YEAR
  return(x)
}


tonmethaneperyear_to_wastekgperweek <- function(tonmethane_per_year,co2e) {
  x = tonmethane_per_year
  x = x/52 # TON METHANE PER WEEK
  x = x*1000 # KG METHANE PER WEEK
  x = x*25 # KG CO2e PER WEEK
  x = x/co2e # KG WASTE PER WEEK
  return(x)
}
