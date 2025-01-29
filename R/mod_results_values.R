#' results_values UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_values_ui <- function(id, vbs_data) {
  ns <- NS(id)
  vbs <- purrr::map(vbs_data, function(vb_data){
    value_box(
      title = vb_data$title,
      value = textOutput(ns(vb_data$variable)),
      theme = vb_data$theme %||% "text-primary"
    )
  }) %>% unname()

  layout_column_wrap(
    fill = FALSE,
    height = "100px",
    !!!vbs
  )
}

#' results_values Server Functions
#'
#' @noRd
mod_results_values_server <- function(id, variables, values){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    purrr::walk(variables, function(variable){
      output[[variable]] <- renderText({values[[variable]]})
    })

  })
}

## To be copied in the UI
# mod_results_values_ui("results_values_1")

## To be copied in the server
# mod_results_values_server("results_values_1")
