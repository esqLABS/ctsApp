#' results_pd UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_pd_ui <- function(id) {
  ns <- NS(id)
  tagList()
}

#' results_pd Server Functions
#'
#' @noRd
mod_results_pd_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  })
}

## To be copied in the UI
# mod_results_pd_ui("results_pd_1")

## To be copied in the server
# mod_results_pd_server("results_pd_1")
