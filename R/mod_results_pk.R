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

  vbs_data <- list(
    auc = list(
      title = "AUC",
      variable = "auc"
    ),
    cmax = list(
      title = "Cmax",
      variable = "cmax"
    )
  )

  card(
    card_body(
      mod_results_values_ui(ns("results_values_general"),
                            vbs_data = vbs_data),
      mod_results_plot_ui(ns("results_plot_general")))
  )

}

#' results_general Server Functions
#'
#' @noRd
mod_results_pk_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    vbs_variables <- c("auc", "cmax")

    vbs_values <- reactiveValues()

    observe({
      vbs_values$auc = runif(1)
      vbs_values$cmax = runif(1)
    })

    mod_results_values_server("results_values_general",
                              variables = vbs_variables,
                              values = vbs_values)

    mod_results_plot_server("results_plot_general")
  })
}

## To be copied in the UI
# mod_results_pk_ui("results_general_1")

## To be copied in the server
# mod_results_pk_server("results_general_1")
