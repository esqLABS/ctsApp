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
        plotlyOutput(ns("plot"))
      )
    )
  )
}

#' mod_results_ddi Server Functions
#'
#' @noRd
#' @importFrom ggplot2 ggplot aes labs guides geom_line geom_ribbon scale_color_manual scale_fill_manual theme_minimal theme element_text element_blank element_line
#' @importFrom plotly plotlyOutput renderPlotly ggplotly layout config
mod_results_ddi_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Add an output to track if results are available
    output$has_results <- reactive({
      !is.null(r$results)
    })
    outputOptions(output, "has_results", suspendWhenHidden = FALSE)

    output$plot <- renderPlotly({
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

      # Calculate summary statistics for each time point and simulation
      summary_data <- plot_data |>
        dplyr::group_by(time, sim) |>
        dplyr::summarise(
          mean_conc = mean(concentration),
          min_conc = min(concentration),
          max_conc = max(concentration),
          .groups = "drop"
        )

      # Create a column with the hover text
      summary_data$hovertext <- paste0(
        "<b>",
        summary_data$sim,
        "</b><br>",
        "Time: ",
        round(summary_data$time, 2),
        " h<br>",
        "Mean: ",
        round(summary_data$mean_conc, 2),
        " µg/L<br>",
        "Range: [",
        round(summary_data$min_conc, 2),
        " - ",
        round(summary_data$max_conc, 2),
        "] µg/L"
      )

      # Modern color palette for comparison
      comparison_colors <- c("#667eea", "#f093fb")

      p <- ggplot2::ggplot(
        summary_data,
        aes(x = time, y = mean_conc, group = sim)
      ) +
        ggplot2::geom_ribbon(
          aes(ymin = min_conc, ymax = max_conc, fill = sim, text = hovertext),
          alpha = 0.4
        ) +
        ggplot2::geom_line(
          aes(color = sim),
          linewidth = 0.8
        ) +
        ggplot2::scale_color_manual(values = comparison_colors) +
        ggplot2::scale_fill_manual(values = comparison_colors) +
        ggplot2::labs(
          title = glue::glue("Concentration Time Profile of {r$inputs$victim}"),
          fill = NULL,
          color = NULL,
          y = "Concentration [µg/L]",
          x = "Time [h]"
        ) +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(
          plot.title = element_text(face = "bold", size = 15),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_line(color = "#f0f0f0", linewidth = 0.5),
          axis.title = element_text(face = "bold", size = 12),
          legend.position = "bottom"
        )

      # Create plotly object with tooltip using the text aesthetic
      plotly::ggplotly(p, tooltip = "text") |>
        plotly::layout(
          hovermode = "closest",
          plot_bgcolor = "#ffffff",
          paper_bgcolor = "#ffffff",
          font = list(
            family = "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif",
            size = 13,
            color = "#2d3748"
          ),
          xaxis = list(
            gridcolor = "#f7fafc",
            gridwidth = 1,
            zerolinecolor = "#e2e8f0",
            zerolinewidth = 2
          ),
          yaxis = list(
            gridcolor = "#f7fafc",
            gridwidth = 1,
            zerolinecolor = "#e2e8f0",
            zerolinewidth = 2
          ),
          legend = list(
            orientation = "h",
            xanchor = "center",
            x = 0.5,
            y = -0.15,
            yanchor = "top",
            bgcolor = "rgba(255,255,255,0.9)",
            bordercolor = "#e2e8f0",
            borderwidth = 1
          )
        ) |>
        plotly::config(
          modeBarButtonsToRemove = c(
            "pan2d",
            "select2d",
            "lasso2d",
            "hoverClosestCartesian",
            "hoverCompareCartesian",
            "toggleSpikelines",
            "resetScale2d",
            "zoomIn2d",
            "zoomOut2d",
            "resetViewMapbox"
          ),
          displaylogo = FALSE
        )
    })

    output$value_boxes <- renderUI({
      req(r$results)

      pk_data_ddi <- r$results$pk_results$`DDI Simulation`
      pk_data_single <- r$results$pk_results$`Single Simulation`

      auc_ddi <- pk_data_ddi |>
        dplyr::filter(Parameter == "AUC_tDLast_minus_1_tDLast") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      auc_single <- pk_data_single |>
        dplyr::filter(Parameter == "AUC_tDLast_minus_1_tDLast") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      cmax_ddi <- pk_data_ddi |>
        dplyr::filter(Parameter == "C_max_tDLast_tEnd") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      cmax_single <- pk_data_single |>
        dplyr::filter(Parameter == "C_max_tDLast_tEnd") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      tmax_ddi <- pk_data_ddi |>
        dplyr::filter(Parameter == "t_max_tDLast_tEnd") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      tmax_single <- pk_data_single |>
        dplyr::filter(Parameter == "t_max_tDLast_tEnd") |>
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
