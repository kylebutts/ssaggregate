# library(haven)
# library(data.table)
# library(here)
# library(fixest)
# 
# df <- read_dta(here("data/location_level.dta"))
# 
# # "wide" shares in memory
# shares <- read_dta(here("data/Lshares_wide.dta"))
# df <- merge(df, shares, by=c("czone", "year"))
# 
# data = df
# shares = NULL
# vars = ~ y + x + z + l_sh_routine33
# weights = "wei"
# l = NULL
# t = "year"
# n = "sic87dd"
# s = "ind_share"
# controls = ~ t2 + Lsh_manuf
# addmissing = F
# 
# ssaggregate(
#   data = df,
#   vars = ~ y + x + z + l_sh_routine33,
#   weights = "wei",
#   n = "sic87dd",
#   t = "year",
#   s = "ind_share",
#   controls = ~ t2 + Lsh_manuf
# )
# 
# 
# 
# seperate "long" share dataset
# shares <- read_dta(here("data/Lshares.dta"))
# 
# data = df
# shares = shares
# vars = ~ y + x + z + l_sh_routine33
# weights = "wei"
# l = "czone"
# t = "year"
# n = "sic87dd"
# s = "ind_share"
# controls = ~ t2 + Lsh_manuf
# addmissing = T
# 
# ssaggregate(
#   data = df,
#   shares = shares,
#   vars = ~ y + x + z + l_sh_routine33,
#   weights = "wei",
#   n = "sic87dd",
#   t = "year",
#   s = "ind_share",
#   l = "czone",
#   controls = ~ t2 + Lsh_manuf,
#   addmissing = T
# )