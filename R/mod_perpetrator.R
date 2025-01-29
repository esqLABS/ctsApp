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
      ns("perp_compound"), "Compound",
      c("Rifampicin", "Midazolam", "Add Custom Compound"),
      selected = "Rifampicin"
    ),
    conditionalPanel(
      ns = ns,
      condition = "input.perp_compound == 'Add Custom Compound'",
      fileInput(ns("compound_file"), "Upload Compound File", accept = ".json", multiple = FALSE)
    ),
    tagList(
      layout_column_wrap(
        width = 1/2,
        layout_column_wrap(
          width = 1/2,
          # style = css(grid_template_columns = "1fr 2fr"),
          gap = "10px",
          numericInput(ns("perp_dose"), "Dose", value = 1),
          selectInput(ns("perp_unit"), "Unit", c("mg", "g"), selected = "mg")
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
  )
}

#' perpetrator Server Functions
#'
#' @noRd
mod_perpetrator_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    observe({
      r$inputs$perpetrator <- reactive({
        list(
          compound = input$perp_compound,
          dose = input$perp_dose,
          unit = input$perp_unit,
          protocol = input$protocol,
          duration = input$duration,
          time = input$time
        )
      })
      cli::cli_alert_info("Perpetrator updated with:")
      cli::cli_li("Compound: {.field {input$perp_compound}}")
      cli::cli_li("Dose: {.field {input$perp_dose}}")
      cli::cli_li("Unit: {.field {input$perp_unit}}")
      cli::cli_li("Protocol: {.field {input$protocol}}")
      cli::cli_li("Duration: {.field {input$duration}}")
      cli::cli_li("Time: {.field {input$time}}")


    })

  })
}

## To be copied in the UI
# mod_perpetrator_ui("perpetrator_1")

## To be copied in the server
# mod_perpetrator_server("perpetrator_1")
