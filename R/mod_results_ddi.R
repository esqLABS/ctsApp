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
      card_body(
        plotlyOutput(ns("plot"))
      )
    )
  )
}

#' mod_results_ddi Server Functions
#'
#' @noRd
#' @importFrom plotly plotlyOutput renderPlotly plot_ly add_ribbons add_lines layout config
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
            lubridate::duration(1, "days"), # Time in days
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

      # Modern color palette for comparison
      comparison_colors <- c("#f43d3dff", "#667eea")

      # Create named color vector
      sims <- unique(summary_data$sim)
      color_map <- setNames(comparison_colors, sims)

      # Create plotly object directly
      p <- plotly::plot_ly()

      # Add traces for each simulation
      for (s in sims) {
        sim_data <- summary_data[summary_data$sim == s, ]
        
        # Add lower bound of ribbon first
        p <- p |>
          plotly::add_trace(
            data = sim_data,
            x = ~time,
            y = ~min_conc,
            type = 'scatter',
            mode = 'lines',
            line = list(width = 0),
            showlegend = FALSE,
            hoverinfo = 'none'
          )
        
        # Add upper bound of ribbon (fills to previous trace)
        p <- p |>
          plotly::add_trace(
            data = sim_data,
            x = ~time,
            y = ~max_conc,
            type = 'scatter',
            mode = 'lines',
            line = list(width = 0),
            fillcolor = paste0(substr(color_map[s], 1, 7), "66"),  # Add transparency
            fill = 'tonexty',
            showlegend = FALSE,
            hoverinfo = 'none'
          )
        
        # Add line with custom hovertemplate
        p <- p |>
          plotly::add_lines(
            data = sim_data,
            x = ~time,
            y = ~mean_conc,
            line = list(color = color_map[s], width = 2),
            name = s,
            showlegend = TRUE,
            text = ~paste0(round(min_conc, 2), " - ", round(max_conc, 2)),
            hovertemplate = paste0(
              "<b>", s, "</b><br>",
              "Mean: %{y:.2f} µg/L<br>",
              "<span style='font-size:0.9em'>Range: [%{text}]</span>",
              "<extra></extra>"
            ),
            hoverlabel = list(bgcolor = color_map[s])
          )
      }

      # Apply layout
      p |>
        plotly::layout(
          title = list(
            text = glue::glue(
              "Concentration Time Profile of {r$inputs$victim}"
            ),
            font = list(
              size = 15,
              family = "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif"
            )
          ),
          hovermode = "x unified",
          plot_bgcolor = "#ffffff",
          paper_bgcolor = "#ffffff",
          font = list(
            family = "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif",
            size = 13,
            color = "#2d3748"
          ),
          xaxis = list(
            title = list(text = "Time [days]", font = list(size = 12)),
            gridcolor = "#f7fafc",
            gridwidth = 1,
            zerolinecolor = "#e2e8f0",
            zerolinewidth = 2
          ),
          yaxis = list(
            title = list(text = "Concentration [µg/L]", font = list(size = 12)),
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
