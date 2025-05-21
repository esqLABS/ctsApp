#' mod_results_ddi UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_ddi_ui <- function(id) {
  ns <- NS(id)

  tagList(
    uiOutput(ns("value_boxes")),
    card(
      fill = TRUE,
      card_header(
        class = "d-flex justify-content-between",
        "DDI Comparison"
      ),
      card_body(
        plotOutput(ns("plot"))
      )
    )
  )
}

#' mod_results_ddi Server Functions
#'
#' @noRd
mod_results_ddi_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Add an output to track if results are available
    output$has_results <- reactive({
      !is.null(r$results)
    })
    outputOptions(output, "has_results", suspendWhenHidden = FALSE)

    output$plot <- renderPlot({
      req(r$results)

      plot_data <-
        dplyr::bind_rows(
          dplyr::mutate(
            .data = r$results$sim_results$`DDI Simulation`,
            sim = glue::glue("With {r$inputs$perpetrator}")
          ),
          dplyr::mutate(
            .data = r$results$sim_results$`Single Simulation`,
            sim = glue::glue("Without {r$inputs$perpetrator}")
          )
        ) |>
        dplyr::filter(
          stringr::str_detect(paths, "Plasma \\(Peripheral Venous Blood\\)"),
          stringr::str_detect(paths, r$inputs$victim)
        ) |>
        dplyr::transmute(
          individual = IndividualId,
          time = lubridate::duration(Time, "minutes") /
            lubridate::duration(1, "hours"), # Time in hours
          molecule = stringr::str_extract(
            paths,
            pattern = "(?<=VenousBlood\\|)[^\\|]*"
          ),
          concentration = simulationValues * molWeight, # concentration in µg/L
          sim = sim
        )

      ggplot(plot_data, aes(x = time, y = concentration)) +
        stat_summary(aes(color = sim), geom = "line", fun = "mean") +
        stat_summary(
          aes(fill = sim),
          geom = "ribbon",
          fun.max = "max",
          fun.min = "min",
          alpha = 0.6
        ) +
        labs(
          title = glue::glue("Concentration Time Profile of {r$inputs$victim}"),
          fill = NULL,
          y = "Concentration [µg/L]",
          x = "Time [h]"
        ) +
        guides(color = FALSE)
    })

    output$value_boxes <- renderUI({
      req(r$results)

      pk_data_ddi <- r$results$pk_results$`DDI Simulation`
      pk_data_single <- r$results$pk_results$`Single Simulation`

      auc_ddi <- pk_data_ddi |>
        dplyr::filter(Parameter == "AUC_tEnd") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      auc_single <- pk_data_single |>
        dplyr::filter(Parameter == "AUC_tEnd") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      cmax_ddi <- pk_data_ddi |>
        dplyr::filter(Parameter == "C_max") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      cmax_single <- pk_data_single |>
        dplyr::filter(Parameter == "C_max") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      tmax_ddi <- pk_data_ddi |>
        dplyr::filter(Parameter == "t_max") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      tmax_single <- pk_data_single |>
        dplyr::filter(Parameter == "t_max") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      victim_molw <- r$results$sim_results$`DDI Simulation` |>
        dplyr::filter(stringr::str_detect(paths, r$inputs$victim)) |>
        dplyr::pull(molWeight) |>
        unique()

      auc_ratio <- signif(
        quantile(auc_ddi / auc_single, probs = c(0.05, .5, 0.95)),
        4
      )
      cmax_ratio <- signif(
        quantile(cmax_ddi / cmax_single, probs = c(0.05, .5, 0.95)),
        4
      )
      tmax_ratio <- signif(
        quantile(tmax_ddi / tmax_single, probs = c(0.05, .5, 0.95)),
        4
      )

      layout_column_wrap(
        1 / 3,
        quantile_value_box("AUC ratio", auc_ratio),
        quantile_value_box("Cmax ratio", cmax_ratio),
        quantile_value_box("Tmax ratio", tmax_ratio)
      )
    })
  })
}

## To be copied in the UI
# mod_results_ddi_ui("mod_results_ddi_1")

## To be copied in the server
# mod_results_ddi_server("mod_results_ddi_1")
