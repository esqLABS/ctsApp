#' protocol UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_protocol_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("protocol"), "Protocol", choices = NULL),
    conditionalPanel(
      ns = ns,
      condition = "input.protocol == 'Create New Protocol'",
      layout_column_wrap(
        width = 1 / 2,
        # style = css(grid_template_columns = "1fr 2fr"),
        gap = "10px",
        numericInput(ns("dose"),
          "Dose",
          value = 1
        ),
        selectInput(ns("dose_unit"), "Unit",
          c("mg", "g"),
          selected = "mg"
        )
      ),
      layout_column_wrap(
        width = 1 / 2,
        selectInput(ns("protocol_type"), "Type",
          c(
            "Oral" = "oral",
            "Intravenous Bolus" = "ivb",
            "Intravenous" = "iv"
          ),
          selected = "oral"
        ),
        selectInput(
          ns("protocol_interval"), "interval",
          c(
            "Single Dose" = "single",
            "Once per day" = "24",
            "Twice a day" = "12-12",
            "Thrice a day" = "8-8-8",
            "Four times a day" = "6-6-6-6"
          )
        )
      ),
      conditionalPanel(
        ns = ns,
        condition = "input.protocol_type == 'oral'",
        layout_column_wrap(
          width = 1 / 2,
          numericInput(ns("water_vol_per_body_weight"),
            "Water Volume/Body Weight",
            value = 3.5
          ),
          selectInput(ns("water_vol_per_body_weight_unit"),
            "Water Volume/Body Weight Unit",
            choices = c("l/kg", "ml/kg", "µl/kg"),
            selected = "ml/kg"
          )
        )
      ),
      conditionalPanel(
        ns = ns,
        condition = "input.protocol_type == 'ivb' | input.protocol_type == 'iv'  ",
        layout_column_wrap(
          width = 1 / 2,
          numericInput(ns("infusion_time"),
            "Infusion Time",
            value = 0.5
          ),
          selectInput(ns("infusion_time_unit"),
            "Infusion Time Unit",
            choices = c("s", "min", "h", "day(s)", "week(s)", "month(s)", "year(s)", "ks"),
            selected = "h"
          )
        )
      ),
      layout_column_wrap(
        width = 1 / 2,
        numericInput(ns("duration"), "Duration (days)", value = 7),
        shinyWidgets::timeInput(ns("start_time"), "First Intake Time", value = "08:00")
      )
    )
  )
}

#' protocol Server Functions
#'
#' @noRd
mod_protocol_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns


    observeEvent(r$default_snapshot, {
      req(r$default_snapshot)
      if (grepl("victim", id)) {
        selected <- "IV DRSP 0.5 mg of DRSP"
      } else {
        selected <- "Ketoconazole 200 mg BID"
      }
      updateSelectInput(
        inputId = "protocol",
        choices = c(r$default_snapshot$get_names("protocols"), "Create New Protocol"),
        selected = selected
      )
    })

    observe({
      req(input$protocol)
      r$inputs[[id]] <- input$protocol

      r$inputs$end_time <- input$duration * 24 # transforms days in hours

      if(input$protocol !=  "Create New Protocol") {
        # browser()
        r[[id]] <- purrr::keep(r$default_snapshot$protocols, ~ .x$name == input$protocol)[[1]]
      } else {
        if (input$protocol_type == "oral") {
          extra_args <- list(
            "water_vol_per_body_weight" = input$water_vol_per_body_weight,
            "water_vol_per_body_weight_unit" = input$water_vol_per_body_weight_unit
          )
        } else {
          extra_args <- list(
            "infusion_time" = input$infusion_time,
            "infusion_time_unit" = input$infusion_time_unit
          )
        }

        r[[id]] <- rlang::inject(
          cts::create_protocol(
            name = as.numeric(Sys.time()),
            type = input$protocol_type,
            interval = input$protocol_interval,
            dose = input$dose,
            dose_unit = input$dose_unit,
            end_time = r$inputs$end_time,
            end_time_unit = "h",
            ... = !!!extra_args
          )
        )
      }

    })
  })
}

## To be copied in the UI
# mod_protocol_ui("protocol_1")

## To be copied in the server
# mod_protocol_server("protocol_1")
