#' Autor, Dorn, and Hanson (2013)
#'
#' A dataset containing commuting-zone panel data for 1990-2000 from Autor,
#'   Dorn, and Hanson (2013). This dataset is in "long" format with shares 
#'   stored in `ssaggregate::shares`
#'
#' @format A data frame with 1444 rows and 243 variables
"df"

#' Autor, Dorn, and Hanson (2013)
#'
#' A dataset of industry shares in "long" format. Each row is a commuting zone,
#'   year, sic code with the corresponding industrial share.
#'
#' @format A data frame with 573268 rows and 4 variables:
#' \describe{
#'   \item{czone}{Commuting Zone code}
#'   \item{year}{Year}
#'   \item{sic87dd}{Industry code (SIC87)}
#'   \item{ind_share}{Employment share of industry in commuting zone}
#' }
"shares"

#' Autor, Dorn, and Hanson (2013)
#'
#' A dataset containing industry observations
#'
#' @format A data frame with 1444 rows and 640 variables
"df_wide"

#' Autor, Dorn, and Hanson (2013)
#'
#' A dataset containing commuting-zone panel data for 1990-2000 from Autor,
#'   Dorn, and Hanson (2013). This dataset is in a "wide" format with industry 
#'   shares as column variables
#'
#' @format A data frame with 1444 rows and 640 variables
"industries"

#' Autor, Dorn, and Hanson (2013)
#'
#' A dataset containing industry-year observations of shocks
#'
#' @format A data frame with 794 rows and 21 variables
"shocks"