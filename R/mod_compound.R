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
mod_compound_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("compound"),
      "Compound",
      choices = NULL
    )
  )
}

#' victim Server Functions
#'
#' @noRd
mod_compound_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    model_directory <- system.file("data/models", package = "ctsApp")

    observe({
      r$default_snapshot <- cts:::Snapshot$new(file.path(model_directory, "ddi_oral_contraceptives.json"))
    })

    observeEvent(r$default_snapshot, {
      compound_names <- r$default_snapshot$get_names("compounds")

      if(id == "victim"){
        compound_names <- stringr::str_subset(compound_names, pattern = "Drospirenone|Levonorgestrel")
        updateSelectInput(inputId = "compound",
                          choices = compound_names,
                          selected = "Drospirenone")
      } else {
        compound_names <- stringr::str_subset(compound_names, pattern = "Drospirenone|Levonorgestrel", negate = TRUE)
        updateSelectInput(inputId = "compound",
                          choices = compound_names,
                          selected = "Ketoconazole")
      }
    })


    observe({
      req(input$compound)

      r$inputs[[id]] <- input$compound
      cli::cli_alert_info(
        "Compound Selected as {id}: {.field {input$compound}}"
      )
    })
  })
}

## To be copied in the UI
# mod_compound_ui("victim_1")

## To be copied in the server
# mod_compound_server("victim_1")
