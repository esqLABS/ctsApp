#' simulation UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_simulation_ui <- function(id) {
  ns <- NS(id)
  tagList(
    input_task_button(ns("run"), "Run Simulation", icon = bs_icon("play"))
  )
}

#' simulation Server Functions
#'
#' @noRd
mod_simulation_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(input$run, {
      req(r$inputs$victim)
      req(r$inputs$perpetrator)
      req(r$population_data)
      req(r$formulation_victim)
      req(r$formulation_perpetrator)
      req(r$protocol_victim)
      req(r$protocol_perpetrator)

      r$inputs$run_btn <- input$run

      ddi <- cts::create_ddi(cts::compound(r$default_snapshot$source))

      ddi$remove_formulation(ddi$get_names("formulations"))
      ddi$remove_protocol(ddi$get_names("protocols"))
      ddi$populations <- list(r$population_data)
      ddi$formulations <- c(r$formulation_victim, r$formulation_perpetrator)
      ddi$protocols <- c(r$protocol_victim, r$protocol_perpetrator)

      single_sim <-
        cts::create_simulation(
          "Single Simulation",
          population = r$inputs$population,
          victim = r$inputs$victim
        ) |>
        cts::set_compound_protocol(
          r$inputs$victim,
          protocol = r$protocol_victim$name,
          formulation = r$formulation_victim$name
        ) |>
        cts::set_outputs(
          paths = glue::glue(
            "Organism|PeripheralVenousBlood|{c(r$inputs$victim)}|Plasma (Peripheral Venous Blood)"
          )
        ) |>
        cts::set_output_interval(
          start_time = 0,
          end_time = r$simulation_params$duration_value,
          resolution = r$simulation_params$resolution,
          unit = r$simulation_params$duration_unit
        )

      cts::add_simulation(
        ddi,
        single_sim,
        options = list(
          add_interactions = TRUE,
          add_processes = TRUE
        )
      )

      ddi_sim <-
        cts::create_simulation(
          "DDI Simulation",
          population = r$inputs$population,
          victim = r$inputs$victim,
          perpetrators = r$inputs$perpetrator
        ) |>
        cts::set_compound_protocol(
          r$inputs$victim,
          protocol = r$protocol_victim$name,
          formulation = r$formulation_victim$name
        ) |>
        cts::set_compound_protocol(
          r$inputs$perpetrator,
          protocol = r$protocol_perpetrator$name,
          formulation = r$formulation_perpetrator$name
        ) |>
        cts::set_outputs(
          paths = glue::glue(
            "Organism|PeripheralVenousBlood|{c(r$inputs$victim, r$inputs$perpetrator)}|Plasma (Peripheral Venous Blood)"
          )
        ) |>
        cts::set_output_interval(
          start_time = 0,
          end_time = r$simulation_params$duration_value,
          resolution = r$simulation_params$resolution,
          unit = r$simulation_params$duration_unit
        )

      r$ddi <- cts::add_simulation(
        ddi,
        ddi_sim,
        options = list(
          add_interactions = TRUE,
          add_processes = TRUE
        )
      )

      req(r$ddi)

      r$results$sim_results <- cts::run_ddi(r$ddi)

      r$results$pk_results <- cts::run_pk_analysis(r$ddi)
    })
  })
}

## To be copied in the UI
# mod_simulation_ui("simulation_1")

## To be copied in the server
# mod_simulation_server("simulation_1")
