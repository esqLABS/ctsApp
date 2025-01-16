#' individual UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_individual_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("population"), "Population",
                choices = c("European", "Asian", "White American", "African American"),
                selected = "European"),
    layout_column_wrap(
      width = 1/2,
      numericInput(ns("age"), "Age", value = 30),
      numericInput(ns("BMI"), "BMI", value = 25)
    )
  )
}

#' individual Server Functions
#'
#' @noRd
mod_individual_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_individual_ui("individual_1")

## To be copied in the server
# mod_individual_server("individual_1")
