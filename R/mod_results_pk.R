#' results_general UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_pk_ui <- function(id) {
  ns <- NS(id)
  tagList(
    card(
      card_body(
        uiOutput(ns("value_boxes")),
        card(
          card_header(
            class = "d-flex justify-content-between",
            "Time Profile",
            # checkboxInput(ns("show_obs"), "Display Observed Data", TRUE, width = "auto"),
            checkboxInput(ns("show_perpetrator"), "Display Perpetrator", FALSE, width = "auto")
          ),
          card_body(
            plotOutput(ns("plot"))
          )
        )
      )
    )
  )
}

#' results_general Server Functions
#'
#' @noRd
#' @importFrom ggplot2 ggplot aes stat_summary labs guides
mod_results_pk_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$plot <- renderPlot({
      req(r$results)

      plot_data <-
        r$results$sim_results$`DDI Simulation` |>
        dplyr::filter(stringr::str_detect(paths, "Plasma \\(Peripheral Venous Blood\\)")) |>
        dplyr::transmute(
          individual = IndividualId,
          time = lubridate::duration(Time, "minutes") / lubridate::duration(1, "hours"), # Time in hours
          molecule = stringr::str_extract(paths, pattern = "(?<=VenousBlood\\|)[^\\|]*"),
          concentration = simulationValues * molWeight # concentration in µg/L
        )

      if (!input$show_perpetrator) {
        plot_data <- dplyr::filter(
          plot_data,
          stringr::str_detect(molecule,
            r$inputs$perpetrator,
            negate = TRUE
          )
        )
      }
      ggplot(plot_data, aes(x = time, y = concentration)) +
        stat_summary(aes(color = molecule), geom = "line", fun = "mean") +
        stat_summary(aes(fill = molecule), geom = "ribbon", fun.max = "max", fun.min = "min", alpha = 0.6) +
        labs(
          title = "Concentration Time Profile",
          fill = "Compounds",
          y = "Concentration [µg/L]",
          x = "Time [h]"
        ) +
        guides(color = FALSE)
    })


    output$value_boxes <- renderUI({
      req(r$results)

      vb_data <- r$results$pk_results$`DDI Simulation`

      victim_cmax <- vb_data |>
        dplyr::filter(Parameter == "C_max") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      victim_molw <- r$results$sim_results$`DDI Simulation` |>
        dplyr::filter(stringr::str_detect(paths, r$inputs$victim)) |>
        dplyr::pull(molWeight) |>
        unique()

      victim_tmax <- vb_data |>
        dplyr::filter(Parameter == "t_max") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      victim_auc <- vb_data |>
        dplyr::filter(Parameter == "AUC_tEnd") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      victim_cmax <- signif(quantile(victim_cmax * victim_molw, probs = c(0.05, .5, 0.95)), 4) # µmol/L -> µg/L
      victim_tmax <- signif(quantile(victim_tmax, probs = c(0.05, .5, 0.95)), 4) # hours
      victim_auc <- signif(quantile(victim_auc * victim_molw / 60, probs = c(0.05, .5, 0.95)), 4) # µmol*min/L -> µg*h/L



      layout_column_wrap(
        1 / 3,
        quantile_value_box("Cmax (µg/L)", victim_cmax),
        quantile_value_box("Tmax (h)", victim_tmax),
        quantile_value_box("AUC (µg*h/L)", victim_auc)
      )
    })
  })
}

## To be copied in the UI
# mod_results_pk_ui("results_general_1")

## To be copied in the server
# mod_results_pk_server("results_general_1")


quantile_value_box <- function(title, quantiles, icon = NULL) {
  bslib::value_box(
    title,
    quantiles[2],
    paste0("[", quantiles[2], " - ", quantiles[3], "]")
  )
}
