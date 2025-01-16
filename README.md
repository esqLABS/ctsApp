
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{ctsApp}`

<!-- badges: start -->
<!-- badges: end -->

## Installation

You can install the development version of `{ctsApp}` like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Run

You can launch the application by running:

``` r
ctsApp::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-01-16 14:32:46 CET"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ══ Documenting ═════════════════════════════════════════════════════════════════
#> ℹ Installed roxygen2 version (7.3.2) doesn't match required (7.1.1)
#> ✖ `check()` will not re-document this package
#> ── R CMD check results ────────────────────────────────── ctsApp 0.0.0.9000 ────
#> Duration: 10.5s
#> 
#> ❯ checking for future file timestamps ... NOTE
#>   unable to verify current time
#> 
#> ❯ checking top-level files ... NOTE
#>   Non-standard file/directory found at top level:
#>     ‘dev’
#> 
#> 0 errors ✔ | 0 warnings ✔ | 2 notes ✖
```

``` r
covr::package_coverage()
#> Error in loadNamespace(x): there is no package called 'covr'
```
