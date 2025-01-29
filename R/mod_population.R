#' Population UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_population_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("population"), "Population",
                choices = c("European", "Asian", "White American", "African American"),
                selected = "European"),
    shinyWidgets::numericRangeInput(ns("age"), "Age", value = c(20,35), min = 20, max = 35),
    shinyWidgets::numericRangeInput(ns("bmi"), "BMI", value = c(18, 30), min = 16, max = 35)
  )
}

#' Population Server Functions
#'
#' @noRd
mod_population_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    observe({
      r$inputs$population <- list(
        population = input$population,
        age = input$age,
        bmi = input$bmi
      )
      cli::cli_alert_info("Population updated with:")
      cli::cli_li("source pop: {.field {input$population}}")
      cli::cli_li("age: {.field {input$age}}")
      cli::cli_li("bmi: {.field {input$bmi}}")
    })

  })
}

## To be copied in the UI
# mod_population_ui("individual_1")

## To be copied in the server
# mod_population_server("individual_1")
