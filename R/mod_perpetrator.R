#' perpetrator UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_perpetrator_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("perpetrator_compound"), "Compound",
      c("Rifampicin", "Midazolam"),
      selected = "Rifampicin"
    ),
    tagList(
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
        numericInput(ns("duration"), "Duration", value = 7),
        shinyWidgets::timeInput(ns("time"), "Intake Time", value = "08:00")
      )
    )
# For custom compound, add a tab
#     navset_pill(
#       nav_panel(title = "Preloaded",
# ),
#       nav_panel(title = "Custom",
#                 numericInput(ns("logp"), "LogP", value = 1),
#                 numericInput(ns("uf"), "Fraction unbound", value=1/2)),
#       footer =
#     )
  )
}

#' perpetrator Server Functions
#'
#' @noRd
mod_perpetrator_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_perpetrator_ui("perpetrator_1")

## To be copied in the server
# mod_perpetrator_server("perpetrator_1")
