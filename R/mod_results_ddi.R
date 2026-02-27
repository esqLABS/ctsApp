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
        fillable = TRUE,
        checkboxInput(
          ns("show_perpetrator"),
          "Show Perpetrator",
          FALSE,
          width = "auto"
        ),
        plotlyOutput(ns("plot"), height = "100%")
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
          stringr::str_detect(paths, "Plasma \\(Peripheral Venous Blood\\)")
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

      if (!input$show_perpetrator) {
        plot_data <- dplyr::filter(
          plot_data,
          stringr::str_detect(molecule, r$inputs$perpetrator, negate = TRUE)
        )
      }

      # Calculate summary statistics for each time point, simulation, and molecule
      summary_data <- plot_data |>
        dplyr::group_by(time, sim, molecule) |>
        dplyr::summarise(
          mean_conc = mean(concentration),
          min_conc = min(concentration),
          max_conc = max(concentration),
          .groups = "drop"
        )

      # Create a combined label for legend grouping
      summary_data$trace_label <- paste0(summary_data$molecule, " (", summary_data$sim, ")")

      # Modern color palette for traces
      trace_labels <- unique(summary_data$trace_label)
      colors <- c("#f43d3dff", "#667eea", "#764ba2", "#f093fb", "#4facfe", "#00f2fe")
      color_palette <- colors[seq_along(trace_labels)]
      color_map <- setNames(color_palette, trace_labels)

      # Create plotly object directly
      p <- plotly::plot_ly()

      # Add traces for each combination
      for (tl in trace_labels) {
        trace_data <- summary_data[summary_data$trace_label == tl, ]

        # Add lower bound of ribbon first
        p <- p |>
          plotly::add_trace(
            data = trace_data,
            x = ~time,
            y = ~min_conc,
            type = 'scatter',
            mode = 'lines',
            line = list(width = 0),
            legendgroup = tl,
            showlegend = FALSE,
            hoverinfo = 'none'
          )

        # Add upper bound of ribbon (fills to previous trace)
        p <- p |>
          plotly::add_trace(
            data = trace_data,
            x = ~time,
            y = ~max_conc,
            type = 'scatter',
            mode = 'lines',
            line = list(width = 0),
            fillcolor = paste0(substr(color_map[tl], 1, 7), "66"),  # Add transparency
            fill = 'tonexty',
            legendgroup = tl,
            showlegend = FALSE,
            hoverinfo = 'none'
          )

        # Add line with custom hovertemplate
        p <- p |>
          plotly::add_lines(
            data = trace_data,
            x = ~time,
            y = ~mean_conc,
            line = list(color = color_map[tl], width = 2),
            name = tl,
            legendgroup = tl,
            showlegend = TRUE,
            text = ~paste0(signif(min_conc, 3), " - ", signif(max_conc, 3)),
            hovertemplate = paste0(
              "<b>", tl, "</b><br>",
              "Mean: %{y:.3g} µg/L<br>",
              "<span style='font-size:0.9em'>Range: [%{text}]</span>",
              "<extra></extra>"
            ),
            hoverlabel = list(bgcolor = color_map[tl])
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

      auc_ddi_result <- extract_pk_values(
        pk_data_ddi, "AUC_tDLast_minus_1_tDLast", "AUC_tEnd", r$inputs$victim
      )
      auc_single_result <- extract_pk_values(
        pk_data_single, "AUC_tDLast_minus_1_tDLast", "AUC_tEnd", r$inputs$victim
      )

      cmax_ddi_result <- extract_pk_values(
        pk_data_ddi, "C_max_tDLast_tEnd", "C_max", r$inputs$victim
      )
      cmax_single_result <- extract_pk_values(
        pk_data_single, "C_max_tDLast_tEnd", "C_max", r$inputs$victim
      )

      tmax_ddi_result <- extract_pk_values(
        pk_data_ddi, "t_max_tDLast_tEnd", "t_max", r$inputs$victim
      )
      tmax_single_result <- extract_pk_values(
        pk_data_single, "t_max_tDLast_tEnd", "t_max", r$inputs$victim
      )

      auc_ratio <- signif(
        quantile(
          auc_ddi_result$values / auc_single_result$values,
          probs = c(0.05, .5, 0.95), na.rm = TRUE
        ),
        4
      )
      cmax_ratio <- signif(
        quantile(
          cmax_ddi_result$values / cmax_single_result$values,
          probs = c(0.05, .5, 0.95), na.rm = TRUE
        ),
        4
      )
      tmax_ratio <- signif(
        quantile(
          tmax_ddi_result$values / tmax_single_result$values,
          probs = c(0.05, .5, 0.95), na.rm = TRUE
        ),
        4
      )

      layout_column_wrap(
        width = 1 / 3,
        quantile_value_box("Cmax ratio", cmax_ratio),
        quantile_value_box("AUC ratio", auc_ratio),
        quantile_value_box("Tmax ratio", tmax_ratio)
      )
    })
  })
}

## To be copied in the UI
# mod_results_ddi_ui("mod_results_ddi_1")

## To be copied in the server
# mod_results_ddi_server("mod_results_ddi_1")
