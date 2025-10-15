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
      div(
        style = "background-color: #f0f8ff; padding: 1em; border-radius: 6px;",
        layout_column_wrap(
          width = 1 / 2,
          # style = css(grid_template_columns = "1fr 2fr"),
          gap = "10px",
          numericInput(ns("dose"), "Dose", value = 1),
          selectInput(ns("dose_unit"), "Unit", c("mg", "g"), selected = "mg")
        ),
        layout_column_wrap(
          width = 1 / 2,
          selectInput(
            ns("protocol_type"),
            "Type",
            c(
              "Oral" = "oral",
              "Intravenous Bolus" = "ivb",
              "Intravenous" = "iv"
            ),
            selected = "oral"
          ),
          selectInput(
            ns("protocol_interval"),
            "interval",
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
          div(
            style = "background-color: #e8f4f8; padding: 0.8em; border-radius: 4px; margin-top: 0.5em;",
            layout_column_wrap(
              width = 1 / 2,
              numericInput(
                ns("water_vol_per_body_weight"),
                "Water Volume/Body Weight",
                value = 3.5
              ),
              selectInput(
                ns("water_vol_per_body_weight_unit"),
                "Water Volume/Body Weight Unit",
                choices = c("l/kg", "ml/kg", "µl/kg"),
                selected = "ml/kg"
              )
            )
          )
        ),
        conditionalPanel(
          ns = ns,
          condition = "input.protocol_type == 'ivb' | input.protocol_type == 'iv'  ",
          div(
            style = "background-color: #e8f4f8; padding: 0.8em; border-radius: 4px; margin-top: 0.5em;",
            layout_column_wrap(
              width = 1 / 2,
              numericInput(ns("infusion_time"), "Infusion Time", value = 0.5),
              selectInput(
                ns("infusion_time_unit"),
                "Infusion Time Unit",
                choices = c(
                  "s",
                  "min",
                  "h",
                  "day(s)",
                  "week(s)",
                  "month(s)",
                  "year(s)",
                  "ks"
                ),
                selected = "h"
              )
            )
          )
        ),
        layout_column_wrap(
          width = 1 / 2,
          numericInput(ns("start_time"), "Start Time", value = 0),
          selectInput(
            ns("start_time_unit"),
            "Start Time Unit",
            choices = c(
              "s",
              "min",
              "h",
              "day(s)",
              "week(s)",
              "month(s)",
              "year(s)",
              selected = "day(s)"
            )
          )
        ),
        layout_column_wrap(
          width = 1 / 2,
          numericInput(ns("end_time"), "End Time", value = 30),
          selectInput(
            ns("end_time_unit"),
            "End Time Unit",
            choices = c(
              "s",
              "min",
              "h",
              "day(s)",
              "week(s)",
              "month(s)",
              "year(s)"
            ),
            selected = "day(s)"
          )
        )
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

    # Observe protocols - update dropdown when snapshot changes
    observeEvent(r$snapshot_version, {
      req(r$default_snapshot)
      
      all_protocols <- r$default_snapshot$get_names("protocols")
      
      if (grepl("perpetrator", id)) {
        updateSelectInput(
          inputId = "protocol",
          choices = c(all_protocols, "Create New Protocol"),
          selected = "ITZ 100mg 10 days"
        )
      } else {
        # Victim and EE protocols - filter to DRSP, LNG, or EE
        filtered_protocols <- stringr::str_subset(
          all_protocols,
          pattern = "DRSP|LNG|EE"
        )

        selected_protocol <- if (grepl("ee", id)) {
          "EE 30ug 21 days"
        } else {
          "DRSP_3mg 21 days"
        }

        updateSelectInput(
          inputId = "protocol",
          choices = c(filtered_protocols, "Create New Protocol"),
          selected = selected_protocol
        )
      }
    })

    observe({
      req(input$protocol)

      r$inputs[[id]] <- input$protocol

      if (input$protocol != "Create New Protocol") {
        r[[id]] <- purrr::keep(
          r$default_snapshot$protocols,
          ~ .x$name == input$protocol
        )[[1]]

        end_time <- r[[id]]$end_time
        end_time_unit <- r[[id]]$end_time_unit

        if (!is.null(end_time)) {
          r$inputs[[paste0(id, "_end_time")]] <- lubridate::duration(
            end_time,
            osp_to_lubridate(end_time_unit)
          ) /
            lubridate::duration(1, "hours")
          #TODO support advanced protocol to define end_time
        }
      } else {
        # Clear the protocol object when "Create New Protocol" is selected
        # This ensures buttons are disabled until all custom inputs are ready
        r[[id]] <- NULL
        
        req(input$dose)
        req(input$dose_unit)
        req(input$protocol_type)
        req(input$protocol_interval)
        req(input$start_time)
        req(input$start_time_unit)
        req(input$end_time)
        req(input$end_time_unit)

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

        # Convert end_time to hours for simulation
        r$inputs[[paste0(id, "_end_time")]] <- lubridate::duration(
          input$end_time,
          osp_to_lubridate(input$end_time_unit)
        ) /
          lubridate::duration(1, "hours")

        r[[id]] <- rlang::inject(
          cts::create_protocol(
            name = "New Custom Protocol",
            type = input$protocol_type,
            interval = input$protocol_interval,
            dose = input$dose,
            dose_unit = input$dose_unit,
            start_time = input$start_time,
            start_time_unit = input$start_time_unit,
            end_time = input$end_time,
            end_time_unit = input$end_time_unit,
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

osp_to_lubridate <- function(time_unit) {
  dplyr::case_match(
    time_unit,
    "s" ~ "seconds",
    "min" ~ "minutes",
    "h" ~ "hours",
    "day(s)" ~ "days",
    "week(s)" ~ "weeks",
    "year(s)" ~ "years"
  )
}
