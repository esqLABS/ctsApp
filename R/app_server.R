#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny purrr shinipsum cli
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  r <- reactiveValues()
  r$inputs <- reactiveValues()

  # Inputs
  mod_victim_server("victim_1", r)
  mod_population_server("individual_1", r)
  mod_perpetrator_server("perpetrator_1", r)

  # Results
  mod_results_pk_server("results_general_1", r)
  mod_mod_results_ddi_server("mod_results_ddi_1", r)


}
