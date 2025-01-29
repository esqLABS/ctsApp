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

  card(
    card_body(
      mod_results_vbs_ui(ns("results_vbs_ddi")),
      mod_results_plot_ui(ns("results_plot_ddi")))
  )
}

#' mod_results_ddi Server Functions
#'
#' @noRd
mod_mod_results_ddi_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    vbs_data <- reactiveValues()

    observe({
      vbs_data$auc = list(
            title = "AUC ratio",
            value = 0.53,
            threshold = 0.5,
            threshold_message = "Interaction detected",
            threshold_theme = "danger"
          )
      vbs_data$cmax = list(
            title = "Cmax ratio",
            value = runif(1)
          )
    })


    mod_results_vbs_server("results_vbs_ddi", vbs_data)
    mod_results_plot_server("results_plot_ddi")

  })
}

## To be copied in the UI
# mod_mod_results_ddi_ui("mod_results_ddi_1")

## To be copied in the server
# mod_mod_results_ddi_server("mod_results_ddi_1")
