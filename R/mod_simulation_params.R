#' Simulation Parameters UI Function
#'
#' @description A shiny Module for simulation duration and resolution settings.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_simulation_params_ui <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            column(
                6,
                numericInput(
                    ns("duration_value"),
                    "Duration",
                    value = 24,
                    min = 1
                )
            ),
            column(
                6,
                selectInput(
                    ns("duration_unit"),
                    "Unit",
                    choices = c(
                        "Seconds" = "s",
                        "Minutes" = "min",
                        "Hours" = "h",
                        "Days" = "day(s)",
                        "Weeks" = "week(s)",
                        "Months" = "month(s)"
                    ),
                    selected = "h"
                )
            )
        ),
        fluidRow(
            column(
                12,
                numericInput(
                    ns("resolution"),
                    "Resolution (pts/h)",
                    value = 4,
                    min = 1
                )
            )
        )
    )
}

#' Simulation Parameters Server Function
#'
#' @description Server logic for simulation parameters.
#'
#' @param id,r Internal parameters for {shiny}.
#'
#' @noRd
mod_simulation_params_server <- function(id, r) {
    moduleServer(id, function(input, output, session) {
        # Update reactive values when inputs change
        observe({
            r$simulation_params <- list(
                duration_value = input$duration_value,
                duration_unit = input$duration_unit,
                resolution = input$resolution
            )
        })

        # Calculate end time based on protocol end times if needed
        observe({
            # Check if protocol end times are available
            req(r$inputs$protocol_victim_end_time)
            req(r$inputs$protocol_perpetrator_end_time)
            
            # Get the maximum protocol end time
            max_end_time <- max(
                r$inputs$protocol_victim_end_time,
                r$inputs$protocol_perpetrator_end_time,
                na.rm = TRUE
            )
            
            # Validate that we have a valid end time
            req(is.finite(max_end_time))
            req(max_end_time > 0)

            suggested_end_time <- 1.1 * max_end_time

            # Suggest appropriate unit based on the end time
            suggested_unit <- "h" # Default to hours

            if (suggested_end_time > 720 * 2) {
                # If more than 60 days (720h * 2), use months
                suggested_unit <- "month(s)"
                suggested_end_time <- suggested_end_time / 720
            } else if (suggested_end_time > 168 * 2) {
                # If more than 14 days (168h * 2), use weeks
                suggested_unit <- "week(s)"
                suggested_end_time <- suggested_end_time / 168
            } else if (suggested_end_time > 48) {
                # If more than 48 hours, use days
                suggested_unit <- "day(s)"
                suggested_end_time <- suggested_end_time / 24
            } else if (suggested_end_time < 1) {
                # If less than 1 hour, use minutes
                suggested_unit <- "min"
                suggested_end_time <- suggested_end_time * 60
            }

            # Round the suggested end time to make it cleaner to the closest integer
            suggested_end_time <- ceiling(suggested_end_time)

            # Update the UI
            updateNumericInput(
                session,
                "duration_value",
                value = suggested_end_time
            )

            updateSelectInput(
                session,
                "duration_unit",
                selected = suggested_unit
            )
        })
    })
}

## To be copied in the UI
# mod_simulation_params_ui("simulation_params")

## To be copied in the server
# mod_simulation_params_server("simulation_params", r)
