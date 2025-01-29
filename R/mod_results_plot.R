#' results_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_plot_ui <- function(id) {
  ns <- NS(id)
  card(
    card_header(class = "d-flex justify-content-between",
                "Time Profile",
                checkboxInput("obs_data", "Display Observed Data", TRUE, width = "auto")
    ),
    card_body(
      plotOutput(ns("plot"))
    )
  )
}

#' results_plot Server Functions
#'
#' @noRd
mod_results_plot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$plot <- renderPlot({
      random_ggplot(type = "ribbon")
    })

  })
}

## To be copied in the UI
# mod_results_plot_ui("results_plot_1")

## To be copied in the server
# mod_results_plot_server("results_plot_1")
