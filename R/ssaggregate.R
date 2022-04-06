#' Create industry-level aggregates for shift-share IV
#'
#' @description
#'   ssaggregate converts "location-level" variables in a shift-share IV
#'   dataset to a dataset of exposure-weighted "industry-level" aggregates,
#'   as described in Borusyak, Hull, and Jaravel (2022).
#'   
#' @details
#'   There are two ways to specify ssaggregate, depending on whether the 
#'   industry exposure weights are saved in "long" format (unique rows for 
#'   industry x location) in a separate dataset `shares` or in "wide" format 
#'   (unique rows for location and columns for each industry) as part of `df`. 
#'   In general `ssaggregate` will execute faster with "long" exposure weights. 
#'   See the examples for proper syntax in both cases.
#' 
#'   In the "long" case the dataset in memory must be uniquely identified by 
#'   the cross-sectional variables in `l` and, when applicable, the period 
#'   identifiers in `t`. The separate shares dataset is given by `shares` and
#'   should be uniquely indexed by the variables in `l` and `n` (and `t`, when 
#'   specified). `s` should contain the name of the exposure weight variable, 
#'   and the two datasets should contain only matching values of `l` and `t`.
#'     
#'   In the "wide" case the `s` option should contain the common stub of the 
#'   names of exposure weight variables, and `n` should contain the target 
#'   name of the shock identifier. For example, `s = "share"` should be 
#'   specified when the exposure variables are named share101, share102, etc., 
#'   with 101 and 102 being values of the shock identifier in `n`.  The string 
#'   option should be specified when the shock identifer is a string variable. 
#'   Missing values in any of the exposure weight variables are interpreted as 
#'   zeros.  The dataset in memory may be a panel or repeated cross section, 
#'   with periods indexed by `t`.
#'
#'   In both cases there should be no missing values for the location-level 
#'   variables, conditional on any if and in sample restrictions. The resulting 
#'   industry-level dataset will contain exposure-weighted de-meaned averages of
#'   the location-level variables, along with the average exposure weight `s_n`. 
#'   This dataset will be be indexed by the variables in `n` (and `t`, when 
#'   specified).
#' 
#'   When the `controls` option is included the location-level variables are 
#'   first residualized by the control variables. Formula following 
#'   \code{\link[fixest:feols]{fixest::feols}}. Fixed effects specified after 
#'   "`|`".The transformation of variable `y` is also named `y`.
#'   
#'   Including the addmissing option generates a "missing industry" observation, 
#'   with exposure weights equal to one minus the sum of a location's exposure 
#'   weights. Borusyak, Hull, and Jaravel (2022) recommend including this option 
#'   when the the sum of exposure weights varies across locations 
#'   (see Section 3.2). The missing industry observations will be identified by 
#'   `NA` in `n`.
#'   
#'    Note that no information on industry shocks is used in the execution of 
#'    ssaggregate; once run, users can merge shocks and any industry-level 
#'    controls to the aggregated dataset.  They can then estimate and validate
#'    quasi-experimental shift-share IV regressions with other R procedures. 
#'    See Section 4 of Borusyak, Hull, and Jaravel (2022) for details and 
#'    below for examples of such procedures.
#'
#' @param data Data.frame of data
#' @param vars RHS formula of variables, i.e. `~ y + x + ...`
#' @param weights String. Variable name indicating the weights used
#' @param n String. Variable name indicating industry identifiers
#' @param l String. Variable name indicating location identifiers
#' @param t String. Variable name indicating period identifiers
#' @param controls RHS formula of control variables and fixed effects that will
#'   be partialled out.
#'   Formula following \code{\link[fixest:feols]{fixest::feols}}.
#'   Fixed effects specified after "`|`".
#' @param shares Data.frame that contains the shares dataset.
#'   Each row should be uniquely indexed by the variables in `l` and `n`
#'   (and `t`, when specified).
#' @param s String. Variable name indicating name of exposure weight variable.
#'   If using "wideformat", `s` should denote the stub name.
#' @param addmissing Logical. If true, creates "missing industry" observations
#'
#' @return A `data.table` of exposure-weighted "industry-level" aggregates, as 
#'   described in Borusyak, Hull, and Jaravel (2022).
#'   
#' @section Examples:
#'
#' ### Using `ssaggregate`
#'
#' Using sepearate "long" share dataset
#' 
#' ```{r, comment = "#>", collapse = TRUE}
#' data("df")
#' data("shares")
#' industry = ssaggregate(
#'   data = df,
#'   shares = shares,
#'   vars = ~ y + x + z + l_sh_routine33,
#'   weights = "wei",
#'   n = "sic87dd",
#'   t = "year",
#'   s = "ind_share",
#'   l = "czone",
#'   controls = ~ t2 + Lsh_manuf
#' )
#' 
#' head(industry)
#' ```
#' 
#' Using "wide" shares in dataset
#'
#' ```{r, comment = "#>", collapse = TRUE}
#' data("df_wide")
#' industry_df = ssaggregate(
#'   data = df_wide,
#'   vars = ~ y + x + z + l_sh_routine33,
#'   weights = "wei",
#'   n = "sic87dd",
#'   t = "year",
#'   s = "ind_share",
#'   controls = ~ t2 + Lsh_manuf
#' )
#' 
#' head(industry_df)
#' ```
#' 
#' Including the "missing industry"
#' 
#' ```{r, comment = "#>", collapse = TRUE}
#' data("df")
#' data("shares")
#' industry_df = ssaggregate(
#'   data = df,
#'   shares = shares,
#'   vars = ~ y + x + z + l_sh_routine33,
#'   weights = "wei",
#'   n = "sic87dd",
#'   t = "year",
#'   s = "ind_share",
#'   l = "czone",
#'   controls = ~ t2 + Lsh_manuf,
#'   addmissing = TRUE
#' )
#' 
#' head(industry_df)
#' ```
#' 
#' After aggregation, shocks and any shock-level controls can be merged on to 
#'   the new dataset. For example, after the previous command a user could run
#'  
#' ```{r, comment = "#>", collapse = TRUE}
#' industry_df[is.na(sic87dd), sic87dd := 0]
#' data("shocks")
#' data("industries")
#' industry_df = merge(industry_df, shocks, by=c("sic87dd", "year"), all.x=T)
#' industry_df = merge(industry_df, industries, by=c("sic87dd"), all.x=T)
#' 
#' industry_df[is.na(g), let(g = 0, year = 0, sic3 = 0)]
#' ```
#'  
#' 
#' ### Running the shock-level IV regression
#' 
#' Basic shift-share IV 
#' 
#' ```{r, comment = "#>", collapse = TRUE}
#' fixest::feols(y ~ year | 0 | x ~ g, data = industry_df, 
#'               weights = ~ s_n, vcov = "hc1")
#' ```
#' Conditional shift-share IV with clustered standard errors
#' 
#' ```{r, comment = "#>", collapse = TRUE}
#' fixest::feols(y ~ year | 0 | x ~ g, data = industry_df[g < 45, ], 
#'               weights = ~ s_n, cluster = ~ sic3)
#' ```
#' 
#' Shift-share reduced form regression (`y` on `z`)
#' 
#' ```{r, comment = "#>", collapse = TRUE}
#' fixest::feols(y ~ year | 0 | z ~ g, data = industry_df, 
#'               weights = ~ s_n, vcov = "hc1")
#' ```
#' 
#' Shock-level balance check
#' ```{r, comment = "#>", collapse = TRUE}
#' fixest::feols(l_sh_routine33 ~ g + year, data = industry_df,
#'               weights = ~ s_n, vcov = "hc1")
#' ```
#'
#' *See Borusyak, Hull, and Jaravel (2022) for other examples of shock-level 
#' analyses and guidance on specifying and validating a quasi-experimental 
#' shift-share IV.*
#'   
#' @export
ssaggregate = function(data, vars, weights = NULL, n, shares = NULL, s, 
                        l = NULL, t, controls, addmissing = F) {
  
  data.table::setDT(data)
  if(!is.null(shares)) data.table::setDT(shares)

  # shares not specified => wide-format
  wideformat = is.null(shares)
  if(wideformat & !is.null(l)) {
    stop("Option l may not be used with shares in wide format")
  }

  # Make sure variables are in dataset
  var_names = attr(stats::terms(vars), "term.labels")
  if(!all(var_names %in% colnames(data))) {
    stop("`vars` must only contain variables in data")
  }
  
  
  # If wideformat, create shares variable
  if (wideformat) {
    l = "location_ids"
    data[, location_ids := .I]
    keep_vars = colnames(data) 
    keep_vars = keep_vars[
        keep_vars %in% c("location_ids", t) | 
        grepl(s, keep_vars)
      ]
    
    shares = data[, .SD, .SDcols = keep_vars]
    
    shares = data.table::melt(shares, 
         id.vars = c("location_ids", t),
         variable.name = n,
         value.name = s
    )
    
    shares[[n]] = gsub(s, "", as.character(shares[[n]]))
  }

  # If sum of shares varies, will verify S_l is controlled for
  check_controls = (stats::sd(shares[[s]]) > 10^-5)

  # Calculate total s_l
  s_total = paste0(s, "0")
  shares[, 
         s_total := sum(s),
         by = list(l, t), 
         env = list(s_total = s_total, s = s, l = l, t = t)
   ]

  # 1 - \sum s_ln
  shares_missing = shares[,
    list(s = sum(s)),
    by = list(l, t),
    env = list(s = s, l = l, t = t)
  ][,
    # calculate missing share
    s := 1 - s,
    env = list(s = s)
  ]

  # If addmissing, append shares_missing as an NA industry
  if (addmissing) {
    # Add industry as NA
    shares_missing[, n := NA, env = list(n = n)]
    shares = data.table::rbindlist(
      list(shares_missing, shares), use.names = T, fill = T
    )
  }


  if (check_controls) {
    # Add missing shares
    temp = merge(data, shares_missing, by = c(l, t))
    
    # Make sure S_l is controlled for (r^2 = 1)
    rsq = fixest::feols(fixest::xpd(lhs = s, rhs = controls), data = temp) |> fixest::r2(type="r2")
    if(is.na(rsq)) rsq = 1
    if(rsq < 0.9999) {
      if(!addmissing) {
        print(
          "WARNING: You are in the incomplete share case (the sum of exposure 
          shares varies) and you have not controlled for the sum of shares. 
          You should either include the missing industry or (better in most 
          cases) add the sum-of-share control. Otherwise the shock-level IV 
          coefficient does not equal the shift-share IV."
        )
      }
    }
  }
  
  weights_vec = NULL
  if(!is.null(weights)) weights_vec = data[[weights]]
  
  # Residualize vars by control variables
  data[,
       c(var_names) := lapply(var_names, \(x) {
         fixest::feols(
           fixest::xpd(lhs = x, rhs = controls), 
           data = data, weights = weights_vec
         ) |> 
           stats::resid()
       })
     ]
  
  
  # Merge in shares
  if(wideformat) data[, .SD, .SDcols = !grepl(s, colnames(data))]
  data = merge(data, shares, by = c(l, t))
  
  
  # Collapse to industry level
  if(!is.null(weights)) {
    data[, s := s * weights, env = list(weights = weights, s = s)]
  }
  
  
  collapsed = data[,
       c(
         s_n = sum(s),
         var_names = lapply(.SD, \(x) { sum(x * s/sum(s)) })
       ),
       by = list(n, t),
       .SDcols = var_names,
       env = list(n = n, t = t, s = s)
   ][
     ,
     s_n := s_n/sum(s_n)
   ][
     order(n, t),
     env = list(n = n, t = t)
   ]
  
  return(collapsed)
}
