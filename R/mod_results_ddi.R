#' mod_results_ddi UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_mod_results_ddi_ui <- function(id) {
  ns <- NS(id)

  vbs_data <- list(
    auc = list(
      title = "AUC ratio",
      variable = "auc_r"
    ),
    cmax = list(
      title = "Cmax ratio",
      variable = "cmax_r"
    )
  )

  card(
    card_body(
      mod_results_values_ui(ns("results_values_interactions"),
                            vbs_data = vbs_data),
      mod_results_plot_ui(ns("results_plot_interactions")))
  )
}

#' mod_results_ddi Server Functions
#'
#' @noRd
mod_mod_results_ddi_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    vbs_variables <- c("auc_r", "cmax_r")

    vbs_values <- reactiveValues()

    observe({
      vbs_values$auc_r = runif(1)
      vbs_values$cmax_r = runif(1)
    })

    mod_results_values_server("results_values_interactions",
                              variables = vbs_variables,
                              values = vbs_values)

    mod_results_plot_server("results_plot_interactions")
  })
}

## To be copied in the UI
# mod_mod_results_ddi_ui("mod_results_ddi_1")

## To be copied in the server
# mod_mod_results_ddi_server("mod_results_ddi_1")
