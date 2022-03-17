
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ssaggregate

<!-- badges: start -->
<!-- badges: end -->

ssaggregate converts “location-level” variables in a shift-share IV
dataset to a dataset of exposure-weighted “industry-level” aggregates,
as described in [Borusyak, Hull, and Jaravel
(2020)](https://uc6b7982a5764cd8c439602fced8.dl.dropboxusercontent.com/cd/0/inline2/BhreAHbJxwFfC325p4h_eLzzk9UsTf2ILha-np-4EXHOruYsWACqtHjKLIyjStn8b1nhJGZj99mEZjoc1pDf1wsdkRzdug_MrLsc_sd8e4nxTcDJpMpAvIXGMAnc5-okB1jakQRZUF9_rdgB8jOevC8Z8CAbgkl2OygM9ck3nljB4a3JYgc9A3URadjmnkXaGyjvz66G11Q7kfD3k7Dum9LEOEBi57gphYl8ncporsEGA0Kc3RfHKQN_mUqyjkekupU7ggmlZ6FgfdraXawftrf794iI1RTRIeX0OG1dLv-dIVIQ00wJCyCog3AlgkJIeU4_U3mW6Bif2MIlvkLNBSXhTmjxPK-SF5kdNDCR7dO-dBv3aumB_kJwmR0PUqniDThG51sC0KXWV-jXPoGaW0FcN2DWfVaohX2KREtcU1gJyg/file).

## Details

There are two ways to specify ssaggregate, depending on whether the
industry exposure weights are saved in “long” format (unique rows for
industry x location) in a separate dataset `shares` or in “wide” format
(unique rows for location and columns for each industry) as part of
`df`. In general `ssaggregate` will execute faster with “long” exposure
weights. See the examples for proper syntax in both cases.

In the “long” case the dataset in memory must be uniquely identified by
the cross-sectional variables in `l` and, when applicable, the period
identifiers in `t`. The separate shares dataset is given by `shares` and
should be uniquely indexed by the variables in `l` and `n` (and `t`,
when specified). `s` should contain the name of the exposure weight
variable, and the two datasets should contain only matching values of
`l` and `t`.

In the “wide” case the `s` option should contain the common stub of the
names of exposure weight variables, and `n` should contain the target
name of the shock identifier. For example, `s = "share"` should be
specified when the exposure variables are named share101, share102,
etc., with 101 and 102 being values of the shock identifier in `n`. The
string option should be specified when the shock identifer is a string
variable. Missing values in any of the exposure weight variables are
interpreted as zeros. The dataset in memory may be a panel or repeated
cross section, with periods indexed by `t`.

In both cases there should be no missing values for the location-level
variables, conditional on any if and in sample restrictions. The
resulting industry-level dataset will contain exposure-weighted
de-meaned averages of the location-level variables, along with the
average exposure weight `s_n`. This dataset will be be indexed by the
variables in `n` (and `t`, when specified).

When the `controls` option is included the location-level variables are
first residualized by the control variables. Formula following
`fixest::feols`. Fixed effects specified after “`|`”.The transformation
of variable `y` is also named `y`.

Including the addmissing option generates a “missing industry”
observation, with exposure weights equal to one minus the sum of a
location’s exposure weights. Borusyak, Hull, and Jaravel (2020)
recommend including this option when the the sum of exposure weights
varies across locations (see Section 3.2). The missing industry
observations will be identified by `NA` in `n`.

Note that no information on industry shocks is used in the execution of
ssaggregate; once run, users can merge shocks and any industry-level
controls to the aggregated dataset. They can then estimate and validate
quasi-experimental shift-share IV regressions with other Stata
procedures. See Section 4 of Borusyak, Hull, and Jaravel (2020) for
details and below for examples of such procedures.

## `ssaggregate` examples

Using sepearate “long” share dataset:

``` r
library(ssaggregate)
library(fixest)

data("df")
data("shares")
industry = ssaggregate(
  data = df,
  shares = shares,
  vars = ~ y + x + z + l_sh_routine33,
  weights = "wei",
  n = "sic87dd",
  t = "year",
  s = "ind_share",
  l = "czone",
  controls = ~ t2 + Lsh_manuf
)

head(industry)
#>    sic87dd  year          s_n          y          x           z l_sh_routine33
#>      <num> <num>        <num>      <num>      <num>       <num>          <num>
#> 1:    2011  1990 5.991178e-03  0.9038660 -0.1129257 -0.15226680      -1.065246
#> 2:    2011  2000 4.729078e-03  0.5532335  0.3898516 -0.09367913      -1.178196
#> 3:    2015  1990 3.802834e-03  0.7228411 -0.4026864  0.08561252      -2.407878
#> 4:    2015  2000 4.638681e-03 -0.1133174 -0.1762856 -0.34968672      -2.320667
#> 5:    2021  1990 8.723289e-05  2.2034699  0.1183517 -0.03164776      -2.788844
#> 6:    2021  2000 4.436779e-05  0.3604907  0.2456597 -0.39783282      -1.195864
```

Using “wide” shares in dataset:

``` r
data("df_wide")
industry_df = ssaggregate(
  data = df_wide,
  vars = ~ y + x + z + l_sh_routine33,
  weights = "wei",
  n = "sic87dd",
  t = "year",
  s = "ind_share",
  controls = ~ t2 + Lsh_manuf
)
#> Warning: Invalid .internal.selfref detected and fixed by taking a (shallow)
#> copy of the data.table so that := can add this new column by reference. At an
#> earlier point, this data.table has been copied by R (or was created manually
#> using structure() or similar). Avoid names<- and attr<- which in R currently
#> (and oddly) may copy the whole data.table. Use set* syntax instead to avoid
#> copying: ?set, ?setnames and ?setattr. If this message doesn't help, please
#> report your use case to the data.table issue tracker so the root cause can be
#> fixed or this message improved.

head(industry_df)
#>    sic87dd  year          s_n          y          x           z l_sh_routine33
#>     <char> <num>        <num>      <num>      <num>       <num>          <num>
#> 1:    2011  1990 5.991178e-03  0.9038660 -0.1129257 -0.15226680      -1.065246
#> 2:    2011  2000 4.729078e-03  0.5532335  0.3898516 -0.09367913      -1.178196
#> 3:    2015  1990 3.802834e-03  0.7228411 -0.4026864  0.08561252      -2.407878
#> 4:    2015  2000 4.638681e-03 -0.1133174 -0.1762856 -0.34968672      -2.320667
#> 5:    2021  1990 8.723289e-05  2.2034699  0.1183517 -0.03164776      -2.788844
#> 6:    2021  2000 4.436779e-05  0.3604907  0.2456597 -0.39783282      -1.195864
```

Including the “missing industry”:

``` r
data("df")
data("shares")
industry_df = ssaggregate(
  data = df,
  shares = shares,
  vars = ~ y + x + z + l_sh_routine33,
  weights = "wei",
  n = "sic87dd",
  t = "year",
  s = "ind_share",
  l = "czone",
  controls = ~ t2 + Lsh_manuf,
  addmissing = TRUE
)

head(industry_df)
#>    sic87dd  year          s_n          y          x           z l_sh_routine33
#>      <num> <num>        <num>      <num>      <num>       <num>          <num>
#> 1:    2011  1990 1.456902e-03  0.9038660 -0.1129257 -0.15226680      -1.065246
#> 2:    2011  2000 1.149991e-03  0.5532335  0.3898516 -0.09367913      -1.178196
#> 3:    2015  1990 9.247522e-04  0.7228411 -0.4026864  0.08561252      -2.407878
#> 4:    2015  2000 1.128009e-03 -0.1133174 -0.1762856 -0.34968672      -2.320667
#> 5:    2021  1990 2.121282e-05  2.2034699  0.1183517 -0.03164776      -2.788844
#> 6:    2021  2000 1.078912e-05  0.3604907  0.2456597 -0.39783282      -1.195864
```

After aggregation, shocks and any shock-level controls can be merged on
to the new dataset. For example, after the previous command a user could
run

``` r
industry_df[is.na(sic87dd), sic87dd := 0]
data("shocks")
data("industries")
industry_df = merge(industry_df, shocks, by=c("sic87dd", "year"), all.x=T)
industry_df = merge(industry_df, industries, by=c("sic87dd"), all.x=T)

industry_df[is.na(g), let(g = 0, year = 0, sic3 = 0)]
```

## Shock-level IV regression examples

Basic shift-share IV:

``` r
fixest::feols(y ~ year | 0 | x ~ g, data = industry_df, 
              weights = ~ s_n, vcov = "hc1")
#> TSLS estimation, Dep. Var.: y, Endo.: x, Instr.: g
#> Second stage: Dep. Var.: y
#> Observations: 796 
#> Standard-errors: Heteroskedasticity-robust 
#>                 Estimate Std. Error   t value   Pr(>|t|)    
#> (Intercept)  0.000088298   0.024946  0.003540 9.9718e-01    
#> fit_x       -0.464302730   0.087633 -5.298243 1.5162e-07 ***
#> year        -0.000000182   0.000021 -0.008516 9.9321e-01    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> RMSE: 0.009783   Adj. R2: 0.149066
#> F-test (1st stage), x: stat = 160.1    , p < 2.2e-16 , on 1 and 793 DoF.
#>            Wu-Hausman: stat =   1.02823, p = 0.310884, on 1 and 792 DoF.
```

Conditional shift-share IV with clustered standard errors:

``` r
fixest::feols(y ~ year | 0 | x ~ g, data = industry_df[g < 45, ], 
              weights = ~ s_n, cluster = ~ sic3)
#> TSLS estimation, Dep. Var.: y, Endo.: x, Instr.: g
#> Second stage: Dep. Var.: y
#> Observations: 757 
#> Standard-errors: Clustered (sic3) 
#>                Estimate Std. Error   t value   Pr(>|t|)    
#> (Intercept)  0.00007456   0.000081  0.918778 3.5987e-01    
#> fit_x       -0.59570752   0.141843 -4.199764 4.8623e-05 ***
#> year        -0.00000135   0.000019 -0.070177 9.4416e-01    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> RMSE: 0.009944   Adj. R2: 0.153545
#> F-test (1st stage), x: stat = 236.6     , p < 2.2e-16 , on 1 and 754 DoF.
#>            Wu-Hausman: stat =   3.958e-5, p = 0.994982, on 1 and 753 DoF.
```

Shift-share reduced form regression (`y` on `z`):

``` r
fixest::feols(y ~ year | 0 | z ~ g, data = industry_df, 
              weights = ~ s_n, vcov = "hc1")
#> TSLS estimation, Dep. Var.: y, Endo.: z, Instr.: g
#> Second stage: Dep. Var.: y
#> Observations: 796 
#> Standard-errors: Heteroskedasticity-robust 
#>                 Estimate Std. Error   t value   Pr(>|t|)    
#> (Intercept)  0.000103048   0.029114  0.003540 0.99717677    
#> fit_z       -0.318593633   0.067554 -4.716113 0.00000284 ***
#> year        -0.000000212   0.000023 -0.009319 0.99256692    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> RMSE: 0.009811   Adj. R2: 0.144315
#> F-test (1st stage), z: stat = 377.3, p < 2.2e-16 , on 1 and 793 DoF.
#>            Wu-Hausman: stat =  18.5, p = 1.958e-5, on 1 and 792 DoF.
```

Shock-level balance check:

``` r
fixest::feols(l_sh_routine33 ~ g + year, data = industry_df,
              weights = ~ s_n, vcov = "hc1")
#> OLS estimation, Dep. Var.: l_sh_routine33
#> Observations: 796 
#> Standard-errors: Heteroskedasticity-robust 
#>                Estimate Std. Error   t value Pr(>|t|) 
#> (Intercept)  0.00002335   0.009037  0.002583  0.99794 
#> g           -0.00244245   0.001645 -1.484810  0.13799 
#> year         0.00000898   0.000043  0.208076  0.83522 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> RMSE: 0.018808   Adj. R2: -2.71e-4
```

*See Borusyak, Hull, and Jaravel (2020) for other examples of
shock-level analyses and guidance on specifying and validating a
quasi-experimental shift-share IV.*
