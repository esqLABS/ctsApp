#' results_general UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_pk_ui <- function(id) {
  ns <- NS(id)

  # vbs_data <- list(
  #   auc = list(
  #     title = "AUC",
  #     variable = "auc"
  #   ),
  #   cmax = list(
  #     title = "Cmax",
  #     variable = "cmax"
  #   )
  # )
  #
  card(
    card_body(
      mod_results_vbs_ui(ns("results_vbs_pk")),
      mod_results_plot_ui(ns("results_plot_pk")))
  )

}

#' results_general Server Functions
#'
#' @noRd
mod_results_pk_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    vbs_data <- reactiveValues()

    observe({
      vbs_data$auc = list(
        title = "AUC",
        value = runif(1)
      )
      vbs_data$cmax = list(
        title = "Cmax",
        value = runif(1,min = 300, max = 600)
      )
    })


    mod_results_vbs_server("results_vbs_pk", vbs_data)
    mod_results_plot_server("results_plot_pk", r)
  })
}

## To be copied in the UI
# mod_results_pk_ui("results_general_1")

## To be copied in the server
# mod_results_pk_server("results_general_1")
