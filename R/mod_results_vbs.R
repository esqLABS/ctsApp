#' results_values UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_vbs_ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("vbs"))
}

#' results_values Server Functions
#'
#' @noRd
mod_results_vbs_server <- function(id, vbs_data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$vbs <- renderUI({

      vbs <- purrr::map(reactiveValuesToList(vbs_data), function(vb_data){

        theme <- vb_data$theme %||% "text-primary"
        message <- NULL

        if(!is.null(vb_data$threshold)) {
          crossed_threshold <- vb_data$value > vb_data$threshold
          if(crossed_threshold) {
            theme <- vb_data$threshold_theme
            message <- vb_data$threshold_message
          }

        }
        value_box(
          title = vb_data$title,
          value = round(vb_data$value, digits = 4),
          theme = theme,
          message
        )

      }) %>% unname()

      layout_column_wrap(
        fill = FALSE,
        height = "100px",
        !!!vbs
      )
    })

  })
}

## To be copied in the UI
# mod_results_vbs_ui("results_vbs_1")

## To be copied in the server
# mod_results_vbs_server("results_vbs_1")
