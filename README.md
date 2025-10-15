
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{ctsApp}`

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The `{ctsApp}` package provides a graphical user interface (Shiny app)
for the `{cts}` (Contraceptives DDI Trial Simulation Platform) package.
It offers an intuitive web-based interface to design and simulate
drug-drug interactions (DDI) involving contraceptive drugs using
physiologically based pharmacokinetic (PBPK) models.

## Installation

You can install the development version of `{ctsApp}` from
[GitHub](https://github.com/esqLABS/cstApp) with:

``` r
# install.packages("pak")
pak::pak("esqLABS/cstApp")
```

## Run

You can launch the Shiny application by running:

``` r
ctsApp::run_app()
```

This will open the application in your default web browser, providing an
interactive interface to:

- Import and explore compound models from the OSP model library
- Design DDI simulations between compounds
- Configure dosing protocols and individual characteristics
- Run simulations and analyze results with built-in plots and tables
- Export simulation results for further analysis in PK-Sim
