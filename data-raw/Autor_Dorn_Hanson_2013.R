## code to prepare `Autor_Dorn_Hanson_2013` dataset goes here

df <- haven::read_dta("data-raw/location_level.dta")
shares <- haven::read_dta("data-raw/Lshares.dta")

shares_wide <- haven::read_dta("data-raw/Lshares_wide.dta")
df_wide <- merge(df, shares_wide, by=c("czone", "year"))

shocks <- haven::read_dta("data-raw/shocks.dta")
industries <- haven::read_dta("data-raw/industries.dta")

usethis::use_data(df, overwrite = TRUE)
usethis::use_data(df_wide, overwrite = TRUE)
usethis::use_data(shares, overwrite = TRUE)
usethis::use_data(shocks, overwrite = TRUE)
usethis::use_data(industries, overwrite = TRUE)
