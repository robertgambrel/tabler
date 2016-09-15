
tabler: quick and simple regression tables
==========================================

<!-- README.md is generated from README.Rmd. Please edit that file -->
The `tabler` package offer a quick way to make nicely-formatted tables of multiple regression models. This is not meant to have all of the customizability of other packages like [stargazer](https://cran.r-project.org/web/packages/stargazer/vignettes/stargazer.pdf) or [estout](https://cran.r-project.org/web/packages/estout/estout.pdf), and it currently exports to spreadsheet format (csv or xls/xlsx) only. However, it provides a convenient way to quickly convey results when shared amongst collaborators.

Installation and Documentation
------------------------------

`tabler` is still under active development and testing and has not yet been submitted to CRAN.

You can also install the development version of the broom package using [devtools](https://github.com/hadley/devtools):

    library(devtools)
    install_github("robertgambrel/tabler")

Usage
-----

``` r
library(tabler)

lm1 <- lm(mpg ~ cyl, data = mtcars)
lm2 <- lm(mpg ~ hp, data = mtcars)
lm3 <- lm(mpg ~ cyl + hp, data = mtcars)

esttab(lm1, lm2, lm3)
#> [[1]]
#>      Variable      Result   Model 1   Model 2   Model 3
#> 1         cyl Coefficient -2.876***      <NA> -2.265***
#> 2         cyl     p.value         0      <NA>         0
#> 3          hp Coefficient      <NA> -0.068***    -0.019
#> 4          hp     p.value      <NA>         0     0.213
#> 5 (Intercept) Coefficient 37.885*** 30.099*** 36.908***
#> 6 (Intercept)     p.value         0         0         0
#> 7           N                    32        32        32
#> 
#> [[2]]
#> [1] "p<0.1: * p<0.05: ** p<0.01: ***"
esttab(lm1, lm2, lm3, cutoffs = c(0.05, 0.01, 0.001))
#> [[1]]
#>      Variable      Result   Model 1   Model 2   Model 3
#> 1         cyl Coefficient -2.876***      <NA> -2.265***
#> 2         cyl     p.value         0      <NA>         0
#> 3          hp Coefficient      <NA> -0.068***    -0.019
#> 4          hp     p.value      <NA>         0     0.213
#> 5 (Intercept) Coefficient 37.885*** 30.099*** 36.908***
#> 6 (Intercept)     p.value         0         0         0
#> 7           N                    32        32        32
#> 
#> [[2]]
#> [1] "p<0.05: * p<0.01: ** p<0.001: ***"
```

For more examples on how to use some of the functionality, check out the Vignettes.

    browseVignettes(package="tabler")
