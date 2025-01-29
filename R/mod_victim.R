#' victim UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import shinyWidgets
mod_victim_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("compound_victim"), "Compound",
      c("Levonorgestrel 1.5mg + EE", "Drospirenone 3mg + EE"),
      selected = "Drospirenone 3mg + EE"
    )
  )
}

#' victim Server Functions
#'
#' @noRd
mod_victim_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    observeEvent(input$compound_victim, {
      r$inputs$victim <- input$compound_victim
      cli::cli_alert_info("Victim Compound Selected: {.field {r$inputs$victim}}")
    }
    )

  })
}

## To be copied in the UI
# mod_victim_ui("victim_1")

## To be copied in the server
# mod_victim_server("victim_1")
