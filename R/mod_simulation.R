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
    layout_column_wrap(
      width = 1 / 2,
      input_task_button(ns("run"), "Run Simulation", icon = bs_icon("play")),
      downloadButton(
        ns("export"),
        "Export Snapshot",
        icon = icon("download"),
        class = "btn-secondary w-100"
      )
    )
  )
}

#' simulation Server Functions
#'
#' @noRd
mod_simulation_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Function to create DDI object from user inputs
    create_ddi <- function() {
      req(r$inputs$victim)
      req(r$inputs$perpetrator)
      req(r$population_data)
      req(r$formulation_victim)
      req(r$formulation_perpetrator)
      req(r$protocol_victim)
      req(r$protocol_perpetrator)

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

      ddi <- cts::add_simulation(
        ddi,
        ddi_sim,
        options = list(
          add_interactions = TRUE,
          add_processes = TRUE
        )
      )

      return(ddi)
    }

    # Reactive to comprehensively validate all inputs for DDI creation
    inputs_ready <- reactive({
      # Wrap in tryCatch to catch any unexpected errors during validation
      tryCatch({
        # 1. Check compounds are selected
        if (is.null(r$inputs$victim) || r$inputs$victim == "") return(FALSE)
        if (is.null(r$inputs$perpetrator) || r$inputs$perpetrator == "") return(FALSE)
        
        # 2. Check population is fully configured and valid
        if (is.null(r$inputs$population) || r$inputs$population == "") return(FALSE)
        if (is.null(r$population_data)) return(FALSE)
        if (is.null(r$population_characteristics)) return(FALSE)  # Only set when valid
        
        # 3. Check formulations are configured
        if (is.null(r$formulation_victim)) return(FALSE)
        if (is.null(r$formulation_perpetrator)) return(FALSE)
        # Check formulation objects have required fields
        if (is.null(r$formulation_victim$name)) return(FALSE)
        if (is.null(r$formulation_perpetrator$name)) return(FALSE)
        
        # 4. Check protocols are configured
        if (is.null(r$protocol_victim)) return(FALSE)
        if (is.null(r$protocol_perpetrator)) return(FALSE)
        # Check protocol objects have required fields
        if (is.null(r$protocol_victim$name)) return(FALSE)
        if (is.null(r$protocol_perpetrator$name)) return(FALSE)
        
        # 5. Check simulation parameters are valid
        if (is.null(r$simulation_params)) return(FALSE)
        if (is.null(r$simulation_params$duration_value) || is.na(r$simulation_params$duration_value)) return(FALSE)
        if (is.null(r$simulation_params$duration_unit) || r$simulation_params$duration_unit == "") return(FALSE)
        if (is.null(r$simulation_params$resolution) || is.na(r$simulation_params$resolution)) return(FALSE)
        if (r$simulation_params$duration_value <= 0) return(FALSE)
        if (r$simulation_params$resolution <= 0) return(FALSE)
        
        # All validations passed
        return(TRUE)
      }, error = function(e) {
        # If any validation check errors out, inputs are not ready
        return(FALSE)
      })
    })

    # Enable/disable export button based on input availability
    observe({
      if (inputs_ready()) {
        shinyjs::enable("export")
      } else {
        shinyjs::disable("export")
      }
    })

    # Run simulation button handler
    observeEvent(input$run, {
      r$ddi <- create_ddi()
      req(r$ddi)

      r$inputs$run_btn <- input$run
      r$results$sim_results <- cts::run_ddi(r$ddi)
      r$results$pk_results <- cts::run_pk_analysis(r$ddi)
    })

    # Export DDI snapshot
    output$export <- downloadHandler(
      filename = function() {
        timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
        victim <- r$inputs$victim %||% "victim"
        perpetrator <- r$inputs$perpetrator %||% "perpetrator"
        glue::glue("DDI_{victim}_{perpetrator}_{timestamp}.json")
      },
      content = function(file) {
        ddi <- create_ddi()
        req(ddi)
        cts::export_ddi(ddi, file)
      }
    )
  })
}

## To be copied in the UI
# mod_simulation_ui("simulation_1")

## To be copied in the server
# mod_simulation_server("simulation_1")
