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
      ns("victim_compound"), "Compound",
      c("Levonorgestrel", "Drospirenonne"),
      selected = "Levonorgestrel"
    ),
    layout_column_wrap(
      width = 1/2,
      layout_column_wrap(
        width = 1/2,
        # style = css(grid_template_columns = "1fr 2fr"),
        gap = "10px",
        numericInput(ns("victim_dose"), "Dose", value = 1),
        selectInput(ns("victim_unit"), "Unit", c("mg", "g"), selected = "mg")
      ),
      selectInput(ns("protocol"), "Protocol",
                  c("Once", "Daily", "Twice Daily"),
                  selected = "Daily"),
    ),
    layout_column_wrap(
      width = 1/2,
      numericInput(ns("duration"), "Duration (Days)", value = 30),
      shinyWidgets::timeInput(ns("time"), "First Dose Time", value = "08:00")
    )
  )
}

#' victim Server Functions
#'
#' @noRd
mod_victim_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_victim_ui("victim_1")

## To be copied in the server
# mod_victim_server("victim_1")
