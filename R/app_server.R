#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny purrr shinipsum
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  r <- reactiveValues()
  mod_results_pk_server("results_general_1", r)
  mod_mod_results_ddi_server("mod_results_ddi_1", r)


}
