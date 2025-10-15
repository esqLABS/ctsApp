
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

## Prerequisites

Before installing `{ctsApp}`, you need to install the `{cts}` package
and its dependencies:

``` r
# Install the cts package
# install.packages("pak")
pak::pak("esqLABS/cts")
#> 
#> ✔ Updated metadata database: 7.62 MB in 9 files.
#> 
#> ℹ Updating metadata database
#> ✔ Updating metadata database ... done
#> 
#> 
#> → Will install 63 packages.
#> → Will download 58 CRAN packages (78.89 MB).
#> → Will download 5 packages with unknown size.
#> + bit              4.6.0       🔧 ⬇ (730.79 kB)
#> + bit64            4.6.0-1     🔧 ⬇ (581.86 kB)
#> + cli              3.6.5       🔧 ⬇ (1.47 MB)
#> + clipr            0.8.0        ⬇ (51.91 kB)
#> + commonmark       2.0.0       🔧 ⬇ (139.17 kB)
#> + crayon           1.5.3        ⬇ (164.91 kB)
#> + cts              1.1.0.9008  👷‍♂️🔧 ⬇ (GitHub: a266340)
#> + curl             7.0.0       🔧 ⬇ (1.21 MB)
#> + data.table       1.17.8      🔧 ⬇ (3.07 MB)
#> + dplyr            1.1.4       🔧 ⬇ (1.61 MB)
#> + farver           2.1.2       🔧 ⬇ (1.97 MB)
#> + fs               1.6.6       🔧 ⬇ (641.28 kB)
#> + generics         0.1.4        ⬇ (82.60 kB)
#> + ggplot2          4.0.0        ⬇ (5.92 MB)
#> + ggtext           0.1.2        ⬇ (1.26 MB)
#> + glue             1.8.0       🔧 ⬇ (175.14 kB)
#> + gridtext         0.1.5       🔧 ⬇ (979.20 kB)
#> + gtable           0.3.6        ⬇ (225.12 kB)
#> + hms              1.1.3        ⬇ (100.51 kB)
#> + isoband          0.2.7       🔧 ⬇ (1.87 MB)
#> + jpeg             0.1-11      🔧 ⬇ (407.46 kB)
#> + jsonlite         2.0.0       🔧 ⬇ (1.11 MB)
#> + labeling         0.4.3        ⬇ (61.83 kB)
#> + lifecycle        1.0.4        ⬇ (125.64 kB)
#> + litedown         0.7          ⬇ (370.56 kB)
#> + logger           0.4.1        ⬇ (853.34 kB)
#> + magrittr         2.0.4       🔧 ⬇ (231.97 kB)
#> + markdown         2.0          ⬇ (64.51 kB)
#> + openxlsx         4.2.8       🔧 ⬇ (3.41 MB)
#> + ospsuite         12.3.2.9003 👷‍♀️🔧 ⬇ (GitHub: d4b188f)
#> + ospsuite.utils   1.8.0.9005  👷🏽‍♂️🔧 ⬇ (GitHub: ac02d1c)
#> + patchwork        1.3.2        ⬇ (3.35 MB)
#> + pillar           1.11.1       ⬇ (660.11 kB)
#> + pkgconfig        2.0.3        ⬇ (18.47 kB)
#> + png              0.1-8       🔧 ⬇ (378.13 kB)
#> + purrr            1.1.0       🔧 ⬇ (585.88 kB)
#> + R6               2.6.1        ⬇ (87.28 kB)
#> + RColorBrewer     1.1-3        ⬇ (51.79 kB)
#> + Rcpp             1.1.0       🔧 ⬇ (3.37 MB)
#> + readr            2.1.5       🔧 ⬇ (1.99 MB)
#> + rlang            1.1.6       🔧 ⬇ (1.91 MB)
#> + rSharp           1.1.2.9000  👷🏽‍♀️🔧 ⬇ (GitHub: 8f9bce6)
#> + S7               0.2.0       🔧 ⬇ (343.17 kB)
#> + scales           1.4.0        ⬇ (873.34 kB)
#> + showtext         0.9-7       🔧 ⬇ (465.05 kB)
#> + showtextdb       3.0          ⬇ (2.01 MB)
#> + snakecase        0.11.1       ⬇ (161.79 kB)
#> + stringi          1.8.7       🔧 ⬇ (14.79 MB)
#> + stringr          1.5.2        ⬇ (313.18 kB)
#> + sysfonts         0.8.9       🔧 ⬇ (7.05 MB)
#> + tibble           3.3.0       🔧 ⬇ (692.99 kB)
#> + tidyr            1.3.1       🔧 ⬇ (1.32 MB)
#> + tidyselect       1.2.1        ⬇ (226.89 kB)
#> + tlf              1.6.1       👷🏿‍♂️🔧 ⬇ (GitHub: 822d831)
#> + tzdb             0.5.0       🔧 ⬇ (1.28 MB)
#> + utf8             1.2.6       🔧 ⬇ (209.74 kB)
#> + vctrs            0.6.5       🔧 ⬇ (1.89 MB)
#> + viridisLite      0.4.2        ⬇ (1.30 MB)
#> + vroom            1.6.6       🔧 ⬇ (3.12 MB)
#> + withr            3.0.2        ⬇ (224.91 kB)
#> + xfun             0.53        🔧 ⬇ (592.19 kB)
#> + xml2             1.4.0       🔧 ⬇ (519.20 kB)
#> + zip              2.3.3       🔧 ⬇ (225.84 kB)
#> ℹ Getting 58 pkgs (78.89 MB) and 5 pkgs with unknown sizes
#> ✔ Cached copy of rSharp 1.1.2.9000 (source) is the latest build
#> ✔ Cached copy of ospsuite.utils 1.8.0.9005 (source) is the latest build
#> ✔ Got clipr 0.8.0 (aarch64-apple-darwin20) (51.91 kB)
#> ✔ Got R6 2.6.1 (aarch64-apple-darwin20) (87.28 kB)
#> ✔ Got crayon 1.5.3 (aarch64-apple-darwin20) (164.91 kB)
#> ✔ Got bit64 4.6.0-1 (aarch64-apple-darwin20) (581.86 kB)
#> ✔ Got bit 4.6.0 (aarch64-apple-darwin20) (730.79 kB)
#> ✔ Got cli 3.6.5 (aarch64-apple-darwin20) (1.47 MB)
#> ✔ Got purrr 1.1.0 (aarch64-apple-darwin20) (585.88 kB)
#> ✔ Got S7 0.2.0 (aarch64-apple-darwin20) (343.17 kB)
#> ✔ Got tibble 3.3.0 (aarch64-apple-darwin20) (692.99 kB)
#> ✔ Got readr 2.1.5 (aarch64-apple-darwin20) (1.99 MB)
#> ✔ Got withr 3.0.2 (aarch64-apple-darwin20) (224.91 kB)
#> ✔ Got tzdb 0.5.0 (aarch64-apple-darwin20) (1.28 MB)
#> ✔ Got utf8 1.2.6 (aarch64-apple-darwin20) (209.74 kB)
#> ✔ Got RColorBrewer 1.1-3 (aarch64-apple-darwin20) (51.79 kB)
#> ✔ Got cts 1.1.0.9008 (source) (2.71 MB)
#> ✔ Got openxlsx 4.2.8 (aarch64-apple-darwin20) (3.41 MB)
#> ✔ Got farver 2.1.2 (aarch64-apple-darwin20) (1.97 MB)
#> ✔ Got png 0.1-8 (aarch64-apple-darwin20) (378.13 kB)
#> ✔ Got showtext 0.9-7 (aarch64-apple-darwin20) (465.05 kB)
#> ✔ Got tidyr 1.3.1 (aarch64-apple-darwin20) (1.32 MB)
#> ✔ Got patchwork 1.3.2 (aarch64-apple-darwin20) (3.35 MB)
#> ✔ Got zip 2.3.3 (aarch64-apple-darwin20) (225.84 kB)
#> ✔ Got glue 1.8.0 (aarch64-apple-darwin20) (175.14 kB)
#> ✔ Got logger 0.4.1 (aarch64-apple-darwin20) (853.34 kB)
#> ✔ Got jsonlite 2.0.0 (aarch64-apple-darwin20) (1.11 MB)
#> ✔ Got hms 1.1.3 (aarch64-apple-darwin20) (100.51 kB)
#> ✔ Got snakecase 0.11.1 (aarch64-apple-darwin20) (161.79 kB)
#> ✔ Got stringr 1.5.2 (aarch64-apple-darwin20) (313.18 kB)
#> ✔ Got pkgconfig 2.0.3 (aarch64-apple-darwin20) (18.47 kB)
#> ✔ Got ggtext 0.1.2 (aarch64-apple-darwin20) (1.26 MB)
#> ✔ Got fs 1.6.6 (aarch64-apple-darwin20) (641.28 kB)
#> ✔ Got labeling 0.4.3 (aarch64-apple-darwin20) (61.83 kB)
#> ✔ Got sysfonts 0.8.9 (aarch64-apple-darwin20) (7.05 MB)
#> ✔ Got gtable 0.3.6 (aarch64-apple-darwin20) (225.12 kB)
#> ✔ Got xfun 0.53 (aarch64-apple-darwin20) (592.19 kB)
#> ✔ Got gridtext 0.1.5 (aarch64-apple-darwin20) (979.20 kB)
#> ✔ Got litedown 0.7 (aarch64-apple-darwin20) (370.56 kB)
#> ✔ Got showtextdb 3.0 (aarch64-apple-darwin20) (2.01 MB)
#> ✔ Got magrittr 2.0.4 (aarch64-apple-darwin20) (231.97 kB)
#> ✔ Got dplyr 1.1.4 (aarch64-apple-darwin20) (1.61 MB)
#> ✔ Got data.table 1.17.8 (aarch64-apple-darwin20) (3.07 MB)
#> ✔ Got pillar 1.11.1 (aarch64-apple-darwin20) (660.11 kB)
#> ✔ Got rlang 1.1.6 (aarch64-apple-darwin20) (1.91 MB)
#> ✔ Got vctrs 0.6.5 (aarch64-apple-darwin20) (1.89 MB)
#> ✔ Got xml2 1.4.0 (aarch64-apple-darwin20) (519.20 kB)
#> ✔ Got scales 1.4.0 (aarch64-apple-darwin20) (873.34 kB)
#> ✔ Got lifecycle 1.0.4 (aarch64-apple-darwin20) (125.64 kB)
#> ✔ Got vroom 1.6.6 (aarch64-apple-darwin20) (3.12 MB)
#> ✔ Got markdown 2.0 (aarch64-apple-darwin20) (64.51 kB)
#> ✔ Got jpeg 0.1-11 (aarch64-apple-darwin20) (407.46 kB)
#> ✔ Got isoband 0.2.7 (aarch64-apple-darwin20) (1.87 MB)
#> ✔ Got generics 0.1.4 (aarch64-apple-darwin20) (82.60 kB)
#> ✔ Got Rcpp 1.1.0 (aarch64-apple-darwin20) (3.37 MB)
#> ✔ Got tidyselect 1.2.1 (aarch64-apple-darwin20) (226.89 kB)
#> ✔ Got viridisLite 0.4.2 (aarch64-apple-darwin20) (1.30 MB)
#> ✔ Got stringi 1.8.7 (aarch64-apple-darwin20) (14.79 MB)
#> ✔ Got commonmark 2.0.0 (aarch64-apple-darwin20) (139.17 kB)
#> ✔ Got curl 7.0.0 (aarch64-apple-darwin20) (1.21 MB)
#> ✔ Got ggplot2 4.0.0 (aarch64-apple-darwin20) (5.92 MB)
#> ✔ Got tlf 1.6.1 (source) (8.16 MB)
#> ✔ Got ospsuite 12.3.2.9003 (source) (38.10 MB)
#> ✔ Installed rSharp 1.1.2.9000 (github::Open-Systems-Pharmacology/rSharp@8f9bce6) (104ms)
#> ✔ Installed ospsuite.utils 1.8.0.9005 (github::Open-Systems-Pharmacology/OSPSuite.RUtils@ac02d1c) (133ms)
#> ✔ Installed R6 2.6.1  (135ms)
#> ✔ Installed bit64 4.6.0-1  (134ms)
#> ✔ Installed bit 4.6.0  (133ms)
#> ✔ Installed cli 3.6.5  (132ms)
#> ✔ Installed clipr 0.8.0  (131ms)
#> ✔ Installed crayon 1.5.3  (129ms)
#> ✔ Installed curl 7.0.0  (129ms)
#> ✔ Installed dplyr 1.1.4  (170ms)
#> ✔ Installed fs 1.6.6  (45ms)
#> ✔ Installed generics 0.1.4  (35ms)
#> ✔ Installed glue 1.8.0  (31ms)
#> ✔ Installed hms 1.1.3  (48ms)
#> ✔ Installed jsonlite 2.0.0  (43ms)
#> ✔ Installed lifecycle 1.0.4  (32ms)
#> ✔ Installed magrittr 2.0.4  (33ms)
#> ✔ Installed pillar 1.11.1  (68ms)
#> ✔ Installed pkgconfig 2.0.3  (40ms)
#> ✔ Installed purrr 1.1.0  (34ms)
#> ✔ Installed readr 2.1.5  (34ms)
#> ✔ Installed rlang 1.1.6  (33ms)
#> ✔ Installed snakecase 0.11.1  (31ms)
#> ✔ Installed stringr 1.5.2  (16ms)
#> ✔ Installed stringi 1.8.7  (69ms)
#> ✔ Installed tibble 3.3.0  (69ms)
#> ✔ Installed tidyr 1.3.1  (39ms)
#> ✔ Installed tidyselect 1.2.1  (33ms)
#> ✔ Installed tzdb 0.5.0  (34ms)
#> ✔ Installed utf8 1.2.6  (33ms)
#> ✔ Installed vctrs 0.6.5  (35ms)
#> ✔ Installed vroom 1.6.6  (37ms)
#> ✔ Installed withr 3.0.2  (58ms)
#> ✔ Installed RColorBrewer 1.1-3  (64ms)
#> ✔ Installed S7 0.2.0  (18ms)
#> ✔ Installed data.table 1.17.8  (43ms)
#> ✔ Installed Rcpp 1.1.0  (131ms)
#> ✔ Installed farver 2.1.2  (33ms)
#> ✔ Installed ggplot2 4.0.0  (36ms)
#> ✔ Installed gtable 0.3.6  (34ms)
#> ✔ Installed isoband 0.2.7  (56ms)
#> ✔ Installed labeling 0.4.3  (59ms)
#> ✔ Installed openxlsx 4.2.8  (35ms)
#> ✔ Installed scales 1.4.0  (32ms)
#> ✔ Installed showtext 0.9-7  (30ms)
#> ✔ Installed showtextdb 3.0  (30ms)
#> ✔ Installed viridisLite 0.4.2  (13ms)
#> ✔ Installed sysfonts 0.8.9  (60ms)
#> ✔ Installed xml2 1.4.0  (61ms)
#> ✔ Installed zip 2.3.3  (26ms)
#> ✔ Installed logger 0.4.1  (17ms)
#> ✔ Installed commonmark 2.0.0  (12ms)
#> ✔ Installed ggtext 0.1.2  (16ms)
#> ✔ Installed gridtext 0.1.5  (16ms)
#> ✔ Installed jpeg 0.1-11  (13ms)
#> ✔ Installed litedown 0.7  (16ms)
#> ✔ Installed markdown 2.0  (18ms)
#> ✔ Installed patchwork 1.3.2  (28ms)
#> ✔ Installed png 0.1-8  (14ms)
#> ✔ Installed xfun 0.53  (15ms)
#> ℹ Packaging tlf 1.6.1
#> ✔ Packaged tlf 1.6.1 (3.4s)
#> ℹ Building tlf 1.6.1
#> ✔ Built tlf 1.6.1 (17.9s)
#> ✔ Installed tlf 1.6.1 (github::Open-Systems-Pharmacology/TLF-Library@822d831) (30ms)
#> ℹ Packaging ospsuite 12.3.2.9003
#> ✔ Packaged ospsuite 12.3.2.9003 (9.8s)
#> ℹ Building ospsuite 12.3.2.9003
#> ✔ Built ospsuite 12.3.2.9003 (15.7s)
#> ✔ Installed ospsuite 12.3.2.9003 (github::Open-Systems-Pharmacology/OSPSuite-R@d4b188f) (139ms)
#> ℹ Packaging cts 1.1.0.9008
#> ✔ Packaged cts 1.1.0.9008 (542ms)
#> ℹ Building cts 1.1.0.9008
#> ✔ Built cts 1.1.0.9008 (2.1s)
#> ✔ Installed cts 1.1.0.9008 (github::esqLABS/cts@a266340) (14ms)
#> ✔ 1 pkg + 62 deps: added 63, dld 61 (NA B) [1m 7.7s]
```

## Installation

You can install the development version of `{ctsApp}` from
[GitHub](https://github.com/esqLABS/cstApp) with:

``` r
# install.packages("pak")
pak::pak("esqLABS/cstApp")
#> 
#> → Will install 46 packages.
#> → Will update 1 package.
#> → Will download 46 CRAN packages (45.81 MB).
#> → Will download 1 package with unknown size.
#> + askpass                   1.2.1      🔧 ⬇ (25.12 kB)
#> + attempt                   0.3.1       ⬇ (109.60 kB)
#> + base64enc                 0.1-3      🔧 ⬇ (35.07 kB)
#> + bsicons                   0.1.2       ⬇ (254.16 kB)
#> + bslib                     0.9.0       ⬇ (5.68 MB)
#> + cachem                    1.1.0      🔧 ⬇ (71.08 kB)
#> + config                    0.3.2       ⬇ (100.58 kB)
#> + crosstalk                 1.2.2       ⬇ (412.40 kB)
#> + ctsApp       0.1.0.9001 → 0.1.0.9001 👷🏾‍♀️🔧 ⬇ (GitHub: 35ef5e0)
#> + digest                    0.6.37     🔧 ⬇ (356.98 kB)
#> + DT                        0.34.0      ⬇ (1.78 MB)
#> + dygraphs                  1.1.1.6     ⬇ (428.81 kB)
#> + evaluate                  1.0.5       ⬇ (102.94 kB)
#> + fastmap                   1.2.0      🔧 ⬇ (192.97 kB)
#> + fontawesome               0.5.3       ⬇ (1.39 MB)
#> + golem                     0.5.1       ⬇ (1.20 MB)
#> + here                      1.0.2       ⬇ (51.70 kB)
#> + highr                     0.11        ⬇ (37.70 kB)
#> + htmltools                 0.5.8.1    🔧 ⬇ (361.75 kB)
#> + htmlwidgets               1.6.4       ⬇ (805.97 kB)
#> + httpuv                    1.6.16     🔧 ⬇ (2.79 MB)
#> + httr                      1.4.7       ⬇ (491.11 kB)
#> + jquerylib                 0.1.4       ⬇ (526.50 kB)
#> + knitr                     1.50        ⬇ (1.11 MB)
#> + later                     1.4.4      🔧 ⬇ (755.51 kB)
#> + lazyeval                  0.2.2      🔧 ⬇ (162.31 kB)
#> + lubridate                 1.9.4      🔧 ⬇ (1.01 MB)
#> + memoise                   2.0.1       ⬇ (49.48 kB)
#> + mime                      0.13       🔧 ⬇ (48.28 kB)
#> + openssl                   2.3.4      🔧 ⬇ (3.88 MB)
#> + plotly                    4.11.0      ⬇ (3.86 MB)
#> + promises                  1.3.3      🔧 ⬇ (1.86 MB)
#> + rappdirs                  0.3.3      🔧 ⬇ (48.63 kB)
#> + rmarkdown                 2.30        ⬇ (2.63 MB)
#> + rprojroot                 2.1.1       ⬇ (113.09 kB)
#> + sass                      0.4.10     🔧 ⬇ (2.41 MB)
#> + shinipsum                 0.1.1       ⬇ (358.48 kB)
#> + shiny                     1.11.1      ⬇ (4.44 MB)
#> + shinyWidgets              0.9.0       ⬇ (1.40 MB)
#> + sourcetools               0.1.7-1    🔧 ⬇ (135.37 kB)
#> + sys                       3.4.3      🔧 ⬇ (51.87 kB)
#> + timechange                0.3.0      🔧 ⬇ (888.95 kB)
#> + tinytex                   0.57        ⬇ (144.98 kB)
#> + xtable                    1.8-4       ⬇ (706.86 kB)
#> + xts                       0.14.1     🔧 ⬇ (1.28 MB)
#> + yaml                      2.3.10     🔧 ⬇ (217.99 kB)
#> + zoo                       1.8-14     🔧 ⬇ (1.04 MB)
#> ℹ Getting 46 pkgs (45.81 MB) and 1 pkg with unknown size
#> ✔ Got askpass 1.2.1 (aarch64-apple-darwin20) (25.12 kB)
#> ✔ Got base64enc 0.1-3 (aarch64-apple-darwin20) (35.07 kB)
#> ✔ Got attempt 0.3.1 (aarch64-apple-darwin20) (109.60 kB)
#> ✔ Got bsicons 0.1.2 (aarch64-apple-darwin20) (254.16 kB)
#> ✔ Got dygraphs 1.1.1.6 (aarch64-apple-darwin20) (428.81 kB)
#> ✔ Got htmlwidgets 1.6.4 (aarch64-apple-darwin20) (805.97 kB)
#> ✔ Got DT 0.34.0 (aarch64-apple-darwin20) (1.78 MB)
#> ✔ Got bslib 0.9.0 (aarch64-apple-darwin20) (5.68 MB)
#> ✔ Got fontawesome 0.5.3 (aarch64-apple-darwin20) (1.39 MB)
#> ✔ Got ctsApp 0.1.0.9001 (source) (71.44 kB)
#> ✔ Got mime 0.13 (aarch64-apple-darwin20) (48.28 kB)
#> ✔ Got openssl 2.3.4 (aarch64-apple-darwin20) (3.88 MB)
#> ✔ Got shinipsum 0.1.1 (aarch64-apple-darwin20) (358.48 kB)
#> ✔ Got later 1.4.4 (aarch64-apple-darwin20) (755.51 kB)
#> ✔ Got xtable 1.8-4 (aarch64-apple-darwin20) (706.86 kB)
#> ✔ Got config 0.3.2 (aarch64-apple-darwin20) (100.58 kB)
#> ✔ Got digest 0.6.37 (aarch64-apple-darwin20) (356.98 kB)
#> ✔ Got lazyeval 0.2.2 (aarch64-apple-darwin20) (162.31 kB)
#> ✔ Got golem 0.5.1 (aarch64-apple-darwin20) (1.20 MB)
#> ✔ Got highr 0.11 (aarch64-apple-darwin20) (37.70 kB)
#> ✔ Got htmltools 0.5.8.1 (aarch64-apple-darwin20) (361.75 kB)
#> ✔ Got httr 1.4.7 (aarch64-apple-darwin20) (491.11 kB)
#> ✔ Got memoise 2.0.1 (aarch64-apple-darwin20) (49.48 kB)
#> ✔ Got promises 1.3.3 (aarch64-apple-darwin20) (1.86 MB)
#> ✔ Got yaml 2.3.10 (aarch64-apple-darwin20) (217.99 kB)
#> ✔ Got rprojroot 2.1.1 (aarch64-apple-darwin20) (113.09 kB)
#> ✔ Got sys 3.4.3 (aarch64-apple-darwin20) (51.87 kB)
#> ✔ Got sourcetools 0.1.7-1 (aarch64-apple-darwin20) (135.37 kB)
#> ✔ Got tinytex 0.57 (aarch64-apple-darwin20) (144.98 kB)
#> ✔ Got fastmap 1.2.0 (aarch64-apple-darwin20) (192.97 kB)
#> ✔ Got jquerylib 0.1.4 (aarch64-apple-darwin20) (526.50 kB)
#> ✔ Got zoo 1.8-14 (aarch64-apple-darwin20) (1.04 MB)
#> ✔ Got shiny 1.11.1 (aarch64-apple-darwin20) (4.44 MB)
#> ✔ Got knitr 1.50 (aarch64-apple-darwin20) (1.11 MB)
#> ✔ Got evaluate 1.0.5 (aarch64-apple-darwin20) (102.94 kB)
#> ✔ Got rmarkdown 2.30 (aarch64-apple-darwin20) (2.63 MB)
#> ✔ Got cachem 1.1.0 (aarch64-apple-darwin20) (71.08 kB)
#> ✔ Got xts 0.14.1 (aarch64-apple-darwin20) (1.28 MB)
#> ✔ Got crosstalk 1.2.2 (aarch64-apple-darwin20) (412.40 kB)
#> ✔ Got sass 0.4.10 (aarch64-apple-darwin20) (2.41 MB)
#> ✔ Got shinyWidgets 0.9.0 (aarch64-apple-darwin20) (1.40 MB)
#> ✔ Got plotly 4.11.0 (aarch64-apple-darwin20) (3.86 MB)
#> ✔ Got timechange 0.3.0 (aarch64-apple-darwin20) (888.95 kB)
#> ✔ Got here 1.0.2 (aarch64-apple-darwin20) (51.70 kB)
#> ✔ Got lubridate 1.9.4 (aarch64-apple-darwin20) (1.01 MB)
#> ✔ Got rappdirs 0.3.3 (aarch64-apple-darwin20) (48.63 kB)
#> ✔ Got httpuv 1.6.16 (aarch64-apple-darwin20) (2.79 MB)
#> ✔ Installed DT 0.34.0  (126ms)
#> ✔ Installed askpass 1.2.1  (121ms)
#> ✔ Installed attempt 0.3.1  (122ms)
#> ✔ Installed base64enc 0.1-3  (120ms)
#> ✔ Installed bsicons 0.1.2  (120ms)
#> ✔ Installed cachem 1.1.0  (109ms)
#> ✔ Installed config 0.3.2  (129ms)
#> ✔ Installed crosstalk 1.2.2  (129ms)
#> ✔ Installed bslib 0.9.0  (191ms)
#> ✔ Installed digest 0.6.37  (158ms)
#> ✔ Installed dygraphs 1.1.1.6  (50ms)
#> ✔ Installed evaluate 1.0.5  (34ms)
#> ✔ Installed fastmap 1.2.0  (32ms)
#> ✔ Installed fontawesome 0.5.3  (67ms)
#> ✔ Installed golem 0.5.1  (44ms)
#> ✔ Installed here 1.0.2  (34ms)
#> ✔ Installed highr 0.11  (32ms)
#> ✔ Installed htmltools 0.5.8.1  (34ms)
#> ✔ Installed htmlwidgets 1.6.4  (33ms)
#> ✔ Installed httpuv 1.6.16  (56ms)
#> ✔ Installed httr 1.4.7  (62ms)
#> ✔ Installed jquerylib 0.1.4  (33ms)
#> ✔ Installed knitr 1.50  (39ms)
#> ✔ Installed later 1.4.4  (39ms)
#> ✔ Installed lazyeval 0.2.2  (32ms)
#> ✔ Installed lubridate 1.9.4  (33ms)
#> ✔ Installed memoise 2.0.1  (66ms)
#> ✔ Installed mime 0.13  (44ms)
#> ✔ Installed openssl 2.3.4  (34ms)
#> ✔ Installed plotly 4.11.0  (46ms)
#> ✔ Installed promises 1.3.3  (45ms)
#> ✔ Installed rappdirs 0.3.3  (34ms)
#> ✔ Installed rprojroot 2.1.1  (47ms)
#> ✔ Installed rmarkdown 2.30  (117ms)
#> ✔ Installed sass 0.4.10  (47ms)
#> ✔ Installed shinipsum 0.1.1  (36ms)
#> ✔ Installed shinyWidgets 0.9.0  (92ms)
#> ✔ Installed shiny 1.11.1  (96ms)
#> ✔ Installed sourcetools 0.1.7-1  (37ms)
#> ✔ Installed sys 3.4.3  (52ms)
#> ✔ Installed timechange 0.3.0  (71ms)
#> ✔ Installed tinytex 0.57  (40ms)
#> ✔ Installed xtable 1.8-4  (33ms)
#> ✔ Installed xts 0.14.1  (34ms)
#> ✔ Installed yaml 2.3.10  (37ms)
#> ✔ Installed zoo 1.8-14  (23ms)
#> ℹ Packaging ctsApp 0.1.0.9001
#> ✔ Packaged ctsApp 0.1.0.9001 (347ms)
#> ℹ Building ctsApp 0.1.0.9001
#> ✔ Built ctsApp 0.1.0.9001 (3.7s)
#> ✔ Installed ctsApp 0.1.0.9001 (github::esqLABS/cstApp@35ef5e0) (17ms)
#> ✔ 1 pkg + 82 deps: kept 36, upd 1, added 46, dld 47 (NA B) [9.8s]
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

## About

You are reading the doc about version : 0.1.0.9001

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-10-15 17:08:03 CEST"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading ctsApp
#> ── R CMD check results ────────────────────────────────── ctsApp 0.1.0.9001 ────
#> Duration: 57.8s
#> 
#> ❯ checking tests ...
#>   See below...
#> 
#> ❯ checking package subdirectories ... WARNING
#>   Found the following non-empty subdirectories of ‘inst’ also used by R:
#>     inst/data
#>   It is recommended not to interfere with package subdirectories used by
#>   R.
#> 
#> ❯ checking code files for non-ASCII characters ... WARNING
#>   Found the following files with non-ASCII characters:
#>     R/mod_formulation.R
#>     R/mod_protocol.R
#>     R/mod_results_ddi.R
#>     R/mod_results_pk.R
#>   Portable packages must use only ASCII characters in their R code and
#>   NAMESPACE directives, except perhaps in comments.
#>   Use \uxxxx escapes for other characters.
#>   Function ‘tools::showNonASCIIfile’ can help in finding non-ASCII
#>   characters in files.
#> 
#> ❯ checking dependencies in R code ... WARNING
#>   '::' or ':::' imports not declared from:
#>     ‘cts’ ‘ospsuite’ ‘tibble’
#>   Namespace in Imports field not imported from: ‘tidyr’
#>     All declared Imports should be used.
#>   Unexported object imported by a ':::' call: ‘cts:::Snapshot’
#>     See the note in ?`:::` about the use of this operator.
#> 
#> ❯ checking for hidden files and directories ... NOTE
#>   Found the following hidden files and directories:
#>     .cursor
#>     .github
#>   These were most likely included in error. See section ‘Package
#>   structure’ in the ‘Writing R Extensions’ manual.
#> 
#> ❯ checking for future file timestamps ... NOTE
#>   unable to verify current time
#> 
#> ❯ checking top-level files ... NOTE
#>   Non-standard file/directory found at top level:
#>     ‘dev’
#> 
#> ❯ checking R code for possible problems ... NOTE
#>   mod_results_ddi_server : <anonymous>: no visible binding for global
#>     variable ‘paths’
#>   mod_results_ddi_server : <anonymous>: no visible binding for global
#>     variable ‘IndividualId’
#>   mod_results_ddi_server : <anonymous>: no visible binding for global
#>     variable ‘Time’
#>   mod_results_ddi_server : <anonymous>: no visible binding for global
#>     variable ‘simulationValues’
#>   mod_results_ddi_server : <anonymous>: no visible binding for global
#>     variable ‘molWeight’
#>   mod_results_ddi_server : <anonymous>: no visible binding for global
#>     variable ‘sim’
#>   mod_results_ddi_server : <anonymous>: no visible binding for global
#>     variable ‘time’
#>   mod_results_ddi_server : <anonymous>: no visible binding for global
#>     variable ‘concentration’
#>   mod_results_ddi_server : <anonymous>: no visible global function
#>     definition for ‘setNames’
#>   mod_results_ddi_server : <anonymous>: no visible binding for global
#>     variable ‘Parameter’
#>   mod_results_ddi_server : <anonymous>: no visible global function
#>     definition for ‘quantile’
#>   mod_results_pk_server : <anonymous>: no visible binding for global
#>     variable ‘paths’
#>   mod_results_pk_server : <anonymous>: no visible binding for global
#>     variable ‘IndividualId’
#>   mod_results_pk_server : <anonymous>: no visible binding for global
#>     variable ‘Time’
#>   mod_results_pk_server : <anonymous>: no visible binding for global
#>     variable ‘simulationValues’
#>   mod_results_pk_server : <anonymous>: no visible binding for global
#>     variable ‘molWeight’
#>   mod_results_pk_server : <anonymous>: no visible binding for global
#>     variable ‘molecule’
#>   mod_results_pk_server : <anonymous>: no visible binding for global
#>     variable ‘time’
#>   mod_results_pk_server : <anonymous>: no visible binding for global
#>     variable ‘concentration’
#>   mod_results_pk_server : <anonymous>: no visible global function
#>     definition for ‘setNames’
#>   mod_results_pk_server : <anonymous>: no visible binding for global
#>     variable ‘Parameter’
#>   mod_results_pk_server : <anonymous>: no visible global function
#>     definition for ‘quantile’
#>   mod_summary_server : <anonymous>: no visible global function definition
#>     for ‘sd’
#>   mod_summary_server : <anonymous>: no visible binding for global
#>     variable ‘age’
#>   mod_summary_server : <anonymous>: no visible binding for global
#>     variable ‘weight’
#>   mod_summary_server : <anonymous>: no visible binding for global
#>     variable ‘height’
#>   mod_summary_server : <anonymous>: no visible binding for global
#>     variable ‘bmi’
#>   Undefined global functions or variables:
#>     IndividualId Parameter Time age bmi concentration height molWeight
#>     molecule paths quantile sd setNames sim simulationValues time weight
#>   Consider adding
#>     importFrom("stats", "quantile", "sd", "setNames", "time")
#>   to your NAMESPACE file.
#> 
#> ── Test failures ───────────────────────────────────────────────── testthat ────
#> 
#> > # This file is part of the standard setup for testthat.
#> > # It is recommended that you do not modify it.
#> > #
#> > # Where should you do additional test configuration?
#> > # Learn more about the roles of various files in:
#> > # * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
#> > # * https://testthat.r-lib.org/articles/special-files.html
#> > 
#> > library(testthat)
#> > library(ctsApp)
#> > 
#> > test_check("ctsApp")
#> Loading required package: shiny
#> ✔ Loaded pre-saved simulation results
#> ℹ Configuration: Drospirenone + Itraconazole
#> ℹ Saved on Windows at 2025-10-15 13:57:00.95945
#> [ FAIL 6 | WARN 0 | SKIP 1 | PASS 95 ]
#> 
#> ══ Skipped tests (1) ═══════════════════════════════════════════════════════════
#> • rlang_is_interactive() is not TRUE (1): 'test-golem-recommended.R:72:5'
#> 
#> ══ Failed tests ════════════════════════════════════════════════════════════════
#> ── Error ('test-mod_perpetrator.R:1:1'): (code run outside of `test_that()`) ───
#> Error in `eval(code, test_env)`: object 'mod_perpetrator_server' not found
#> Backtrace:
#>     ▆
#>  1. └─shiny::testServer(...) at test-mod_perpetrator.R:1:1
#>  2.   └─shiny:::isModuleServer(app)
#> ── Error ('test-mod_results_interactions.R:1:1'): (code run outside of `test_that()`) ──
#> Error in `eval(code, test_env)`: object 'mod_mod_results_ddi_server' not found
#> Backtrace:
#>     ▆
#>  1. └─shiny::testServer(...) at test-mod_results_interactions.R:1:1
#>  2.   └─shiny:::isModuleServer(app)
#> ── Error ('test-mod_results_pannels.R:1:1'): (code run outside of `test_that()`) ──
#> Error in `eval(code, test_env)`: object 'mod_results_pannels_server' not found
#> Backtrace:
#>     ▆
#>  1. └─shiny::testServer(...) at test-mod_results_pannels.R:1:1
#>  2.   └─shiny:::isModuleServer(app)
#> ── Error ('test-mod_results_plot.R:1:1'): (code run outside of `test_that()`) ──
#> Error in `eval(code, test_env)`: object 'mod_results_plot_server' not found
#> Backtrace:
#>     ▆
#>  1. └─shiny::testServer(...) at test-mod_results_plot.R:1:1
#>  2.   └─shiny:::isModuleServer(app)
#> ── Error ('test-mod_results_values.R:1:1'): (code run outside of `test_that()`) ──
#> Error in `eval(code, test_env)`: object 'mod_results_values_server' not found
#> Backtrace:
#>     ▆
#>  1. └─shiny::testServer(...) at test-mod_results_values.R:1:1
#>  2.   └─shiny:::isModuleServer(app)
#> ── Error ('test-mod_victim.R:1:1'): (code run outside of `test_that()`) ────────
#> Error in `eval(code, test_env)`: object 'mod_victim_server' not found
#> Backtrace:
#>     ▆
#>  1. └─shiny::testServer(...) at test-mod_victim.R:1:1
#>  2.   └─shiny:::isModuleServer(app)
#> 
#> [ FAIL 6 | WARN 0 | SKIP 1 | PASS 95 ]
#> Error: Test failures
#> Execution halted
#> 
#> 1 error ✖ | 3 warnings ✖ | 4 notes ✖
#> Error: R CMD check found ERRORs
```

``` r
covr::package_coverage()
#> Error: Failure in `/private/var/folders/_6/hdp78hfx2qg6415svlx5rb680000gn/T/RtmpfTcTj6/R_LIBS68471a83fe31/ctsApp/ctsApp-tests/testthat.Rout.fail`
#> _server' not found
#> Backtrace:
#>     ▆
#>  1. └─shiny::testServer(...) at test-mod_results_values.R:1:1
#>  2.   └─shiny:::isModuleServer(app)
#> ── Error ('test-mod_victim.R:1:1'): (code run outside of `test_that()`) ────────
#> Error in `eval(code, test_env)`: object 'mod_victim_server' not found
#> Backtrace:
#>     ▆
#>  1. └─shiny::testServer(...) at test-mod_victim.R:1:1
#>  2.   └─shiny:::isModuleServer(app)
#> 
#> [ FAIL 6 | WARN 0 | SKIP 1 | PASS 95 ]
#> Error: Test failures
#> Execution halted
```
