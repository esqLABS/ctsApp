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
      card_header(
        class = "d-flex justify-content-between",
        "Time Profile",
        checkboxInput(
          ns("show_perpetrator"),
          "Display Perpetrator",
          FALSE,
          width = "auto"
        )
      ),
      card_body(
        plotlyOutput(ns("plot"))
      )
    )
  )
}

#' results_general Server Functions
#'
#' @noRd
#' @importFrom ggplot2 ggplot aes stat_summary labs guides geom_line geom_ribbon scale_color_manual scale_fill_manual theme_minimal theme element_text element_blank element_line
#' @importFrom plotly plotlyOutput renderPlotly ggplotly layout config
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

      # Create a column with the hover text
      summary_data$hovertext <- paste0(
        "<b>",
        summary_data$molecule,
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

      # Modern color palette
      n_molecules <- length(unique(summary_data$molecule))
      colors <- c("#667eea", "#764ba2", "#f093fb", "#4facfe", "#00f2fe")
      color_palette <- colors[1:min(n_molecules, length(colors))]

      p <- ggplot2::ggplot(
        summary_data,
        aes(x = time, y = mean_conc, group = molecule)
      ) +
        ggplot2::geom_ribbon(
          aes(
            ymin = min_conc,
            ymax = max_conc,
            fill = molecule,
            text = hovertext
          ),
          alpha = 0.4
        ) +
        ggplot2::geom_line(
          aes(color = molecule),
          linewidth = 1
        ) +
        ggplot2::scale_color_manual(values = color_palette) +
        ggplot2::scale_fill_manual(values = color_palette) +
        ggplot2::labs(
          title = "Concentration Time Profile",
          fill = "Compounds",
          y = "Concentration [µg/L]",
          x = "Time [h]"
        ) +
        ggplot2::guides(color = "none") +
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
    quantiles[2],
    paste0("[", quantiles[2], " - ", quantiles[3], "]")
  )
}
