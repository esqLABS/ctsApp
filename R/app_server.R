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
  mod_compound_server("victim", r)
  mod_population_server("individual_1", r)
  mod_compound_server("perpetrator", r)
  mod_protocol_server("protocol_victim", r)
  mod_protocol_server("protocol_perpetrator", r)
  mod_formulation_server("formulation_victim", r)
  mod_formulation_server("formulation_perpetrator", r)

  # Simulation Parameters
  mod_simulation_params_server("simulation_params", r)

  # Simulation
  mod_simulation_server("simulation_1", r)

  # Summary
  mod_summary_server("summary_1", r)

  # Results
  mod_results_server("results_1", r)
}
