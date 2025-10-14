#' formulation UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_formulation_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("formulation"), "Formulation", choices = NULL),
    conditionalPanel(
      ns = ns,
      condition = "input.formulation == 'Create New Formulation'",
      div(
        style = "background-color: #f8f9fa; padding: 1em; border-radius: 6px;",
        selectInput(
          ns("formulation_type"),
          "Formulation Type",
          c(
            "Dissolved" = "dissolved",
            "Weibull" = "weibull",
            "Lint80" = "lint80",
            "Particle" = "particle",
            "Table" = "table",
            "Zero Order" = "zero",
            "First Order" = "first"
          ),
          selected = "dissolved"
        ),
        conditionalPanel(
          ns = ns,
          condition = "input.formulation == 'Create New Formulation' & input.formulation_type != 'dissolved'",
          accordion(
            open = TRUE,
            style = "overflow-y: auto;",
            accordion_panel(
              "Additional Parameters",
              style = "background-color: #f8f9fa; border-radius: 6px;",
              # Weibull formulation inputs
              conditionalPanel(
                ns = ns,
                condition = "input.formulation_type == 'weibull'",
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  numericInput(
                    ns("dissolution_time_weibull"),
                    "Dissolution Time (80%)",
                    value = 240
                  ),
                  selectInput(
                    ns("dissolution_time_unit_weibull"),
                    "Time Unit",
                    choices = c("s", "min", "h"),
                    selected = "min"
                  )
                ),
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  numericInput(ns("lag_time_weibull"), "Lag Time", value = 0),
                  selectInput(
                    ns("lag_time_unit_weibull"),
                    "Time Unit",
                    choices = c("s", "min", "h"),
                    selected = "min"
                  )
                ),
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  numericInput(
                    ns("dissolution_shape"),
                    "Dissolution Shape",
                    value = 0.92
                  ),
                  checkboxInput(
                    ns("suspension_weibull"),
                    "Use as suspension",
                    value = TRUE
                  )
                )
              ),

              # Lint80 formulation inputs
              conditionalPanel(
                ns = ns,
                condition = "input.formulation_type == 'lint80'",
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  numericInput(
                    ns("dissolution_time_lint80"),
                    "Dissolution Time (80%)",
                    value = 240
                  ),
                  selectInput(
                    ns("dissolution_time_unit_lint80"),
                    "Time Unit",
                    choices = c("s", "min", "h"),
                    selected = "min"
                  )
                ),
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  numericInput(ns("lag_time_lint80"), "Lag Time", value = 0),
                  selectInput(
                    ns("lag_time_unit_lint80"),
                    "Time Unit",
                    choices = c("s", "min", "h"),
                    selected = "min"
                  )
                ),
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  checkboxInput(
                    ns("suspension_lint80"),
                    "Use as suspension",
                    value = TRUE
                  )
                )
              ),

              # Particle formulation inputs
              conditionalPanel(
                ns = ns,
                condition = "input.formulation_type == 'particle'",
                selectInput(
                  ns("distribution_type"),
                  "Distribution Type",
                  choices = c("Monodisperse" = "mono", "Polydisperse" = "poly"),
                  selected = "mono"
                ),
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  numericInput(
                    ns("thickness"),
                    "Thickness of unstirred water layer",
                    value = 30
                  ),
                  selectInput(
                    ns("thickness_unit"),
                    "Unit",
                    choices = c("µm", "mm", "cm"),
                    selected = "µm"
                  )
                ),
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  numericInput(ns("radius"), "Particle Radius", value = 10),
                  selectInput(
                    ns("radius_unit"),
                    "Radius Unit",
                    choices = c("µm", "mm", "cm"),
                    selected = "µm"
                  )
                ),
                # Polydisperse parameters
                conditionalPanel(
                  ns = ns,
                  condition = "input.distribution_type == 'poly'",
                  selectInput(
                    ns("particle_size_distribution"),
                    "Particle Size Distribution",
                    choices = c(
                      "Normal" = "normal",
                      "Log-normal" = "lognormal"
                    ),
                    selected = "normal"
                  ),
                  # Normal distribution parameters
                  conditionalPanel(
                    ns = ns,
                    condition = "input.particle_size_distribution == 'normal'",
                    layout_column_wrap(
                      width = 1 / 2,
                      gap = "10px",
                      numericInput(
                        ns("radius_sd"),
                        "Radius Standard Deviation",
                        value = 3
                      ),
                      selectInput(
                        ns("radius_sd_unit"),
                        "Unit",
                        choices = c("µm", "mm", "cm"),
                        selected = "µm"
                      )
                    )
                  ),
                  # Log-normal distribution parameters
                  conditionalPanel(
                    ns = ns,
                    condition = "input.particle_size_distribution == 'lognormal'",
                    layout_column_wrap(
                      width = 1 / 2,
                      gap = "10px",
                      numericInput(
                        ns("radius_cv"),
                        "Radius Coefficient of Variation",
                        value = 1.5
                      )
                    )
                  ),
                  layout_column_wrap(
                    width = 1 / 2,
                    gap = "10px",
                    numericInput(ns("radius_min"), "Minimum Radius", value = 1),
                    selectInput(
                      ns("radius_min_unit"),
                      "Unit",
                      choices = c("µm", "mm", "cm"),
                      selected = "µm"
                    )
                  ),
                  layout_column_wrap(
                    width = 1 / 2,
                    gap = "10px",
                    numericInput(
                      ns("radius_max"),
                      "Maximum Radius",
                      value = 19
                    ),
                    selectInput(
                      ns("radius_max_unit"),
                      "Unit",
                      choices = c("µm", "mm", "cm"),
                      selected = "µm"
                    )
                  ),
                  layout_column_wrap(
                    width = 1 / 2,
                    gap = "10px",
                    numericInput(ns("n_bins"), "Number of Bins", value = 3)
                  )
                )
              ),

              # Table formulation inputs
              conditionalPanel(
                ns = ns,
                condition = "input.formulation_type == 'table'",
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  textInput(
                    ns("tableX"),
                    "Time Points (comma-separated hours)",
                    value = "0,1,2,4,8"
                  ),
                  textInput(
                    ns("tableY"),
                    "Fraction of Dose (comma-separated values)",
                    value = "0,0.3,0.5,0.8,1.0"
                  )
                ),
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  checkboxInput(
                    ns("suspension_table"),
                    "Use as suspension",
                    value = TRUE
                  )
                )
              ),

              # Zero order formulation inputs
              conditionalPanel(
                ns = ns,
                condition = "input.formulation_type == 'zero'",
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  numericInput(ns("end_time"), "End Time", value = 60),
                  selectInput(
                    ns("end_time_unit"),
                    "Time Unit",
                    choices = c("s", "min", "h"),
                    selected = "min"
                  )
                )
              ),

              # First order formulation inputs
              conditionalPanel(
                ns = ns,
                condition = "input.formulation_type == 'first'",
                layout_column_wrap(
                  width = 1 / 2,
                  gap = "10px",
                  numericInput(ns("thalf"), "Half-life", value = 0.01),
                  selectInput(
                    ns("thalf_unit"),
                    "Time Unit",
                    choices = c("s", "min", "h"),
                    selected = "min"
                  )
                )
              )
            )
          )
        )
      )
    )
  )
}

#' formulation Server Functions
#'
#' @noRd
mod_formulation_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(r$default_snapshot, {
      req(r$default_snapshot)

      all_formulation_names <- r$default_snapshot$get_names("formulations")

      selected_formulation <- if (grepl("victim", id)) {
        "DRSP oral tablet"
      } else {
        "ITZ oral tablet"
      }

      updateSelectInput(
        inputId = "formulation",
        choices = c(
          all_formulation_names,
          "Create New Formulation"
        ),
        selected = selected_formulation
      )
    })

    observe({
      req(input$formulation)
      r$inputs[[id]] <- input$formulation

      if (input$formulation != "Create New Formulation") {
        r[[id]] <- purrr::keep(
          r$default_snapshot$formulations,
          ~ .x$name == input$formulation
        )[[1]]
      } else {
        # Clear the formulation object when "Create New Formulation" is selected
        # This ensures buttons are disabled until all custom inputs are ready
        r[[id]] <- NULL
        
        req(input$formulation_type)

        formulation_args <- list(
          name = "New Custom Formulation"
        )

        if (input$formulation_type == "dissolved") {
          formulation_args <- c(
            formulation_args,
            list(
              type = "dissolved"
            )
          )
        } else if (input$formulation_type == "weibull") {
          req(input$dissolution_time_weibull)
          req(input$dissolution_time_unit_weibull)
          req(input$lag_time_weibull)
          req(input$lag_time_unit_weibull)
          req(input$dissolution_shape)
          req(input$suspension_weibull)
          formulation_args <- c(
            formulation_args,
            list(
              type = "weibull",
              dissolution_time = input$dissolution_time_weibull,
              dissolution_time_unit = input$dissolution_time_unit_weibull,
              lag_time = input$lag_time_weibull,
              lag_time_unit = input$lag_time_unit_weibull,
              dissolution_shape = input$dissolution_shape,
              suspension = input$suspension_weibull
            )
          )
        } else if (input$formulation_type == "lint80") {
          req(input$dissolution_time_lint80)
          req(input$dissolution_time_unit_lint80)
          req(input$lag_time_lint80)
          req(input$lag_time_unit_lint80)
          req(input$suspension_lint80)
          formulation_args <- c(
            formulation_args,
            list(
              type = "lint80",
              dissolution_time = input$dissolution_time_lint80,
              dissolution_time_unit = input$dissolution_time_unit_lint80,
              lag_time = input$lag_time_lint80,
              lag_time_unit = input$lag_time_unit_lint80,
              suspension = input$suspension_lint80
            )
          )
        } else if (input$formulation_type == "particle") {
          req(input$distribution_type)
          req(input$thickness)
          req(input$thickness_unit)
          req(input$radius)
          req(input$radius_unit)
          formulation_args <- c(
            formulation_args,
            list(
              type = "particle",
              distribution_type = input$distribution_type,
              thickness = input$thickness,
              thickness_unit = input$thickness_unit,
              radius = input$radius,
              radius_unit = input$radius_unit
            )
          )
          if (input$distribution_type == "poly") {
            formulation_args <- c(
              formulation_args,
              list(
                particle_size_distribution = input$particle_size_distribution,
                radius_min = input$radius_min,
                radius_min_unit = input$radius_min_unit,
                radius_max = input$radius_max,
                radius_max_unit = input$radius_max_unit,
                n_bins = input$n_bins,
                radius_sd = input$radius_sd,
                radius_sd_unit = input$radius_sd_unit,
                radius_cv = input$radius_cv
              )
            )
          }
        } else if (input$formulation_type == "table") {
          req(input$tableX)
          req(input$tableY)
          req(input$suspension_table)
          tableX <- as.numeric(unlist(strsplit(input$tableX, ",")))
          tableY <- as.numeric(unlist(strsplit(input$tableY, ",")))

          formulation_args <- c(
            formulation_args,
            list(
              type = "table",
              tableX = tableX,
              tableY = tableY,
              suspension = input$suspension_table
            )
          )
        } else if (input$formulation_type == "zero") {
          req(input$end_time)
          req(input$end_time_unit)
          formulation_args <- c(
            formulation_args,
            list(
              type = "zero",
              end_time = input$end_time,
              end_time_unit = input$end_time_unit
            )
          )
        } else if (input$formulation_type == "first") {
          req(input$thalf)
          req(input$thalf_unit)
          formulation_args <- c(
            formulation_args,
            list(
              type = "first",
              thalf = input$thalf,
              thalf_unit = input$thalf_unit
            )
          )
        }

        r[[id]] <- rlang::inject(
          cts::create_formulation(
            !!!formulation_args
          )
        )
      }
    })
  })
}

## To be copied in the UI
# mod_formulation_ui("formulation_1")

## To be copied in the server
# mod_formulation_server("formulation_1")
