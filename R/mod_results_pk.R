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
    uiOutput(ns("value_boxes")),
    card(
      fill = TRUE,
      # card_header(
      #   class = "d-flex justify-content-between",
      #   "Time Profile",
      # ),
      card_body(
        checkboxInput(
          ns("show_perpetrator"),
          "Show Perpetrator",
          FALSE,
          width = "auto"
        ),
        plotlyOutput(ns("plot"))
      )
    )
  )
}

#' results_general Server Functions
#'
#' @noRd
#' @importFrom plotly plotlyOutput renderPlotly plot_ly add_ribbons add_lines layout config
mod_results_pk_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$plot <- renderPlotly({
      req(r$results)

      plot_data <-
        r$results$sim_results$`DDI Simulation` |>
        dplyr::filter(stringr::str_detect(
          paths,
          "Plasma \\(Peripheral Venous Blood\\)"
        )) |>
        dplyr::transmute(
          individual = IndividualId,
          time = lubridate::duration(Time, "minutes") /
            lubridate::duration(1, "hours"), # Time in hours
          molecule = stringr::str_extract(
            paths,
            pattern = "(?<=VenousBlood\\|)[^\\|]*"
          ),
          concentration = simulationValues * molWeight # concentration in µg/L
        )

      if (!input$show_perpetrator) {
        plot_data <- dplyr::filter(
          plot_data,
          stringr::str_detect(molecule, r$inputs$perpetrator, negate = TRUE)
        )
      }

      # Calculate summary statistics for each time point and molecule
      summary_data <- plot_data |>
        dplyr::group_by(time, molecule) |>
        dplyr::summarise(
          mean_conc = mean(concentration),
          min_conc = min(concentration),
          max_conc = max(concentration),
          .groups = "drop"
        )

      # Modern color palette
      n_molecules <- length(unique(summary_data$molecule))
      colors <- c("#667eea", "#764ba2", "#f093fb", "#4facfe", "#00f2fe")
      color_palette <- colors[1:min(n_molecules, length(colors))]

      # Create named color vector
      molecules <- unique(summary_data$molecule)
      color_map <- setNames(color_palette, molecules)

      # Create plotly object directly
      p <- plotly::plot_ly()

      # Add traces for each molecule
      for (mol in molecules) {
        mol_data <- summary_data[summary_data$molecule == mol, ]

        # Add lower bound of ribbon first
        p <- p |>
          plotly::add_trace(
            data = mol_data,
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
            data = mol_data,
            x = ~time,
            y = ~max_conc,
            type = 'scatter',
            mode = 'lines',
            line = list(width = 0),
            fillcolor = paste0(substr(color_map[mol], 1, 7), "66"),  # Add transparency
            fill = 'tonexty',
            showlegend = FALSE,
            hoverinfo = 'none'
          )
        
        # Add line with custom hovertemplate
        p <- p |>
          plotly::add_lines(
            data = mol_data,
            x = ~time,
            y = ~mean_conc,
            line = list(color = color_map[mol], width = 2),
            name = mol,
            showlegend = TRUE,
            text = ~paste0(round(min_conc, 2), " - ", round(max_conc, 2)),
            hovertemplate = paste0(
              "<b>", mol, "</b><br>",
              "Mean: %{y:.2f} µg/L<br>",
              "<span style='font-size:0.9em'>Range: [%{text}]</span>",
              "<extra></extra>"
            ),
            hoverlabel = list(bgcolor = color_map[mol])
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
            title = list(text = "Time [h]", font = list(size = 12)),
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
            title = list(text = "Compounds"),
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

      vb_data <- r$results$pk_results$`DDI Simulation`

      victim_cmax <- vb_data |>
        dplyr::filter(Parameter == "C_max_tDLast_tEnd") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      victim_molw <- r$results$sim_results$`DDI Simulation` |>
        dplyr::filter(stringr::str_detect(paths, r$inputs$victim)) |>
        dplyr::pull(molWeight) |>
        unique()

      victim_tmax <- vb_data |>
        dplyr::filter(Parameter == "t_max_tDLast_tEnd") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      victim_auc <- vb_data |>
        dplyr::filter(Parameter == "AUC_tDLast_minus_1_tDLast") |>
        dplyr::pull(r$inputs$victim) |>
        unlist()

      victim_cmax <- signif(
        quantile(victim_cmax * victim_molw, probs = c(0.05, .5, 0.95)),
        4
      ) # µmol/L -> µg/L
      victim_tmax <- signif(quantile(victim_tmax, probs = c(0.05, .5, 0.95)), 4) # hours
      victim_auc <- signif(
        quantile(victim_auc * victim_molw / 60, probs = c(0.05, .5, 0.95)),
        4
      ) # µmol*min/L -> µg*h/L

      layout_column_wrap(
        1 / 3,
        quantile_value_box(
          tooltip(
            "Cmax (µg/L)",
            "Maximum concentration following the last application (Cmax_tDlast_tEnd): The highest concentration reached in plasma after the last dose."
          ),
          victim_cmax
        ),
        quantile_value_box(
          tooltip(
            "Tmax (h)",
            "Time to maximum concentration following the last application (tmax_tDlast-tEnd): The time at which Cmax is reached after the last dose."
          ),
          victim_tmax
        ),
        quantile_value_box(
          tooltip(
            "AUC (µg*h/L)",
            "Area under the curve between the (last-1) and last application (AUC_tDlast-1_tDlast): The integral of the concentration-time curve during the last dosing interval, representing total drug exposure."
          ),
          victim_auc
        )
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
    paste0("Median: ", quantiles[2]),
    paste0("[", quantiles[1], " - ", quantiles[3], "]")
  )
}
