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
            lubridate::duration(1, "days"), # Time in days
          molecule = stringr::str_extract(
            paths,
            pattern = "(?<=VenousBlood\\|)[^\\|]*"
          ),
          concentration = simulationValues * molWeight # concentration in µg/L
        )

      perpetrator_label <- r$results$perpetrator_name %||% r$inputs$perpetrator

      if (!input$show_perpetrator) {
        plot_data <- dplyr::filter(
          plot_data,
          stringr::str_detect(molecule, perpetrator_label, negate = TRUE)
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
            legendgroup = mol,
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
            legendgroup = mol,
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
            legendgroup = mol,
            showlegend = TRUE,
            text = ~paste0(signif(min_conc, 3), " - ", signif(max_conc, 3)),
            hovertemplate = paste0(
              "<b>", mol, "</b><br>",
              "Mean: %{y:.3g} µg/L<br>",
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
              "Concentration Time Profile of {r$results$victim_name %||% r$inputs$victim}"
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
      victim_label <- r$results$victim_name %||% r$inputs$victim

      cmax_result <- extract_pk_values(
        vb_data, "C_max_tDLast_tEnd", "C_max", victim_label
      )

      victim_molw <- r$results$sim_results$`DDI Simulation` |>
        dplyr::filter(stringr::str_detect(paths, victim_label)) |>
        dplyr::pull(molWeight) |>
        unique()

      tmax_result <- extract_pk_values(
        vb_data, "t_max_tDLast_tEnd", "t_max", victim_label
      )

      auc_result <- extract_pk_values(
        vb_data, "AUC_tDLast_minus_1_tDLast", "AUC_tEnd", victim_label
      )

      victim_cmax <- signif(
        quantile(cmax_result$values * victim_molw, probs = c(0.05, .5, 0.95)),
        4
      ) # µmol/L -> µg/L
      victim_tmax <- signif(
        quantile(tmax_result$values, probs = c(0.05, .5, 0.95)),
        4
      ) # hours
      victim_auc <- signif(
        quantile(auc_result$values * victim_molw / 60, probs = c(0.05, .5, 0.95)),
        4
      ) # µmol*min/L -> µg*h/L

      # Dynamic tooltip based on which AUC parameter was used
      if (auc_result$param_used == "AUC_tDLast_minus_1_tDLast") {
        auc_tooltip_text <- "Area under the curve between the (last-1) and last application (AUC_tDlast-1_tDlast): The integral of the concentration-time curve during the last dosing interval, representing total drug exposure."
      } else {
        auc_tooltip_text <- "Area under the curve from start to end of simulation (AUC_tEnd): Total drug exposure over the entire simulation period. Shown because a single dose protocol has no last dosing interval."
      }

      layout_column_wrap(
        width = 1 / 3,
        quantile_value_box(
          tooltip(
            "Cmax (µg/L)",
            "Maximum concentration following the last application (Cmax_tDlast_tEnd): The highest concentration reached in plasma after the last dose."
          ),
          victim_cmax
        ),
        quantile_value_box(
          tooltip(
            "AUC (µg*h/L)",
            auc_tooltip_text
          ),
          victim_auc
        ),
        quantile_value_box(
          tooltip(
            "Tmax (h)",
            "Time to maximum concentration following the last application (tmax_tDlast-tEnd): The time at which Cmax is reached after the last dose."
          ),
          victim_tmax
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

#' Extract PK parameter values with fallback for single-dose scenarios
#'
#' @param pk_data A tibble of PK analysis results (pivoted)
#' @param param Primary parameter name to extract
#' @param fallback_param Fallback parameter name if primary returns no valid data
#' @param compound Column name for the compound to pull values from
#' @return A list with `values` (numeric vector) and `param_used` (character)
#' @noRd
extract_pk_values <- function(pk_data, param, fallback_param, compound) {
  vals <- pk_data |>
    dplyr::filter(Parameter == param) |>
    dplyr::pull(compound) |>
    unlist()

  if (length(vals) > 0 && !all(is.na(vals) | is.nan(vals))) {
    return(list(values = vals, param_used = param))
  }

  vals <- pk_data |>
    dplyr::filter(Parameter == fallback_param) |>
    dplyr::pull(compound) |>
    unlist()

  return(list(values = vals, param_used = fallback_param))
}
