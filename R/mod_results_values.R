#' results_values UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_values_ui <- function(id) {
  ns <- NS(id)
    layout_column_wrap(
      height = "150px",
      fill = FALSE,
      width = 1/3,
      value_box(
        title = "1st value",
        value = "123",
        showcase = bs_icon("bar-chart"),
        showcase_layout = "left center",
        theme = "text-primary"
      ),
      value_box(
        title = "2nd value",
        value = "456",
        showcase = bs_icon("graph-up"),
        showcase_layout = "left center",
        theme = "text-primary"
      ),
      value_box(
        title = "3rd value",
        value = "789",
        showcase = bs_icon("pie-chart"),
        showcase_layout = "left center",
        theme = "text-primary"
      )
    )
}

#' results_values Server Functions
#'
#' @noRd
mod_results_values_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_results_values_ui("results_values_1")

## To be copied in the server
# mod_results_values_server("results_values_1")
