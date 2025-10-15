#' Summary UI Function
#'
#' @description A shiny Module that displays information about selected building blocks.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_summary_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Top row: Victim and Perpetrator (2 columns)
    layout_columns(
      height = "60%",
      col_widths = 1 / 2,
      card(
        card_header(
          class = "bg-primary text-white",
          div(
            class = "d-flex align-items-center",
            bs_icon("capsule", size = "1.5rem"),
            span(class = "ms-2", "Victim")
          )
        ),
        card_body(
          shiny::uiOutput(ns("victim_cards"))
        )
      ),
      card(
        card_header(
          class = "bg-primary text-white",
          div(
            class = "d-flex align-items-center",
            bs_icon("prescription", size = "1.5rem"),
            span(class = "ms-2", "Perpetrator")
          )
        ),
        card_body(
          shiny::uiOutput(ns("perpetrator_cards"))
        )
      )
    ),
    # Bottom row: Population Demographics (full width)
    card(
      card_header(
        class = "bg-primary text-white",
        div(
          class = "d-flex align-items-center",
          bs_icon("people-fill", size = "1.5rem"),
          span(class = "ms-2", "Population Demographics")
        )
      ),
      card_body(
        layout_column_wrap(
          width = 1 / 4,
          heights_equal = "row",
          shiny::plotOutput(ns("plot_age"), height = "250px"),
          shiny::plotOutput(ns("plot_weight"), height = "250px"),
          shiny::plotOutput(ns("plot_height"), height = "250px"),
          shiny::plotOutput(ns("plot_bmi"), height = "250px")
        )
      )
    )
  )
}

#' Summary Server Function
#'
#' @noRd
mod_summary_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Victim information cards
    output$victim_cards <- renderUI({
      req(r$inputs$victim, r$protocol_victim, r$formulation_victim)

      # Get compound data
      cp <- purrr::keep(
        r$default_snapshot$compounds,
        ~ .x$Name == r$inputs$victim
      )[[1]]

      mw_data <- purrr::keep(
        cp$Parameters,
        ~ .x$Name == "Molecular weight"
      )[[1]]

      lipo_data <- purrr::keep(
        cp$Lipophilicity[[1]]$Parameters,
        ~ .x$Name == "Lipophilicity"
      )[[1]]

      fu_data <- purrr::keep(
        cp$FractionUnbound[[1]]$Parameters,
        ~ grepl("Fraction unbound", .x$Name)
      )[[1]]

      solubility_data <- purrr::keep(
        cp$Solubility[[1]]$Parameters,
        ~ .x$Name == "Solubility at reference pH"
      )[[1]]

      enzymes <- unique(purrr::map(cp$Processes, "Molecule") |> purrr::list_c())

      # Return content with headers and bullet points
      shiny::markdown(glue::glue(
        "
        **Compound: {r$inputs$victim}**
          * Molecular weight: {mw_data$Value} {mw_data$Unit}
          * Lipophilicity: {lipo_data$Value} {lipo_data$Unit}
          * Fraction unbound: {fu_data$Value} {fu_data$Unit}
          * Solubility: {solubility_data$Value} {solubility_data$Unit}
          * Processes: {glue::glue_collapse(enzymes,sep=',')}

        **Protocol: {r$protocol_victim$name %||% 'N/A'}**
          * Application Type: {r$protocol_victim$type %||% 'N/A'}
          * Dosing Interval: {r$protocol_victim$interval %||% 'N/A'}
          * Dose: {r$protocol_victim$dose %||% 'N/A'} {r$protocol_victim$dose_unit %||% ''}
          * Start Time: {r$protocol_victim$start_time %||% 'N/A'} {r$protocol_victim$start_time_unit %||% ''}
          * End Time: {r$protocol_victim$end_time %||% 'N/A'} {r$protocol_victim$end_time_unit %||% ''}
          * Volume of water/body weight: {r$protocol_victim$water_vol_per_body_weight %||% 'N/A'} {r$protocol_victim$water_vol_per_body_weight_unit %||% ''}

        **Formulation: {r$formulation_victim$name %||% 'N/A'}**
          * Type: {r$formulation_victim$type %||% 'N/A'}
        ",
        .null = "N/A"
      ))
    })

    # Perpetrator information cards
    output$perpetrator_cards <- renderUI({
      req(
        r$inputs$perpetrator,
        r$protocol_perpetrator,
        r$formulation_perpetrator
      )

      # Get compound data
      cp <- purrr::keep(
        r$default_snapshot$compounds,
        ~ .x$Name == r$inputs$perpetrator
      )[[1]]

      mw_data <- purrr::keep(
        cp$Parameters,
        ~ .x$Name == "Molecular weight"
      )[[1]]

      lipo_data <- purrr::keep(
        cp$Lipophilicity[[1]]$Parameters,
        ~ .x$Name == "Lipophilicity"
      )[[1]]

      fu_data <- purrr::keep(
        cp$FractionUnbound[[1]]$Parameters,
        ~ grepl("Fraction unbound", .x$Name)
      )[[1]]

      solubility_data <- purrr::keep(
        cp$Solubility[[1]]$Parameters,
        ~ .x$Name == "Solubility at reference pH"
      )[[1]]

      enzymes <- unique(purrr::map(cp$Processes, "Molecule") |> purrr::list_c())

      # Return content with headers and bullet points
      shiny::markdown(glue::glue(
        "
        **Compound: {r$inputs$perpetrator}**
          * Molecular weight: {mw_data$Value} {mw_data$Unit}
          * Lipophilicity: {lipo_data$Value} {lipo_data$Unit}
          * Fraction unbound: {fu_data$Value} {fu_data$Unit}
          * Solubility: {solubility_data$Value} {solubility_data$Unit}
          * Processes: {glue::glue_collapse(enzymes,sep=',')}

        **Protocol: {r$protocol_perpetrator$name %||% 'N/A'}**
          * Application Type: {r$protocol_perpetrator$type %||% 'N/A'}
          * Dosing Interval: {r$protocol_perpetrator$interval %||% 'N/A'}
          * Dose: {r$protocol_perpetrator$dose %||% 'N/A'} {r$protocol_perpetrator$dose_unit %||% ''}
          * Start Time: {r$protocol_perpetrator$start_time %||% 'N/A'} {r$protocol_perpetrator$start_time_unit %||% ''}
          * End Time: {r$protocol_perpetrator$end_time %||% 'N/A'} {r$protocol_perpetrator$end_time_unit %||% ''}
          * Volume of water/body weight: {r$protocol_perpetrator$water_vol_per_body_weight %||% 'N/A'} {r$protocol_perpetrator$water_vol_per_body_weight_unit %||% ''}

        **Formulation: {r$formulation_perpetrator$name %||% 'N/A'}**
          * Type: {r$formulation_perpetrator$type %||% 'N/A'}
        ",
        .null = "N/A"
      ))
    })

    # Population demographics plots - Color palette
    colors <- c(
      age = "#007bc2",
      weight = "#007bc2",
      height = "#007bc2",
      bmi = "#007bc2"
    )

    # Age plot
    output$plot_age <- shiny::renderPlot({
      req(r$demographics)
      demo <- r$demographics

      age_label <- sprintf(
        "Range: %.1f-%.1f \nMean: %.1f \nSD: %.1f ",
        min(demo$age),
        max(demo$age),
        mean(demo$age),
        sd(demo$age)
      )

      ggplot2::ggplot(demo, ggplot2::aes(x = age)) +
        ggplot2::geom_density(
          fill = colors["age"],
          alpha = 0.6,
          color = colors["age"],
          linewidth = 1.2
        ) +
        ggplot2::scale_x_continuous(expand = ggplot2::expansion(0, 0)) +
        ggplot2::scale_y_continuous(
          expand = ggplot2::expansion(c(0, .15), c(0, 0))
        ) +
        ggplot2::annotate(
          "text",
          x = min(demo$age) + 0.97 * diff(range(demo$age)),
          y = -Inf,
          label = age_label,
          hjust = "inward",
          vjust = -.25,
          size = 3.5,
          color = "#333333",
          fontface = "bold"
        ) +
        ggplot2::labs(
          x = "Age (years)",
          y = NULL
        ) +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank(),
          panel.grid.major.y = ggplot2::element_blank(),
          panel.grid.minor.y = ggplot2::element_blank()
        )
    })

    # Weight plot
    output$plot_weight <- shiny::renderPlot({
      req(r$demographics)
      demo <- r$demographics

      weight_label <- sprintf(
        "Range: %.1f-%.1f  \nMean: %.1f  \nSD: %.1f  ",
        min(demo$weight),
        max(demo$weight),
        mean(demo$weight),
        sd(demo$weight)
      )

      ggplot2::ggplot(demo, ggplot2::aes(x = weight)) +
        ggplot2::geom_density(
          fill = colors["weight"],
          alpha = 0.6,
          color = colors["weight"],
          linewidth = 1.2
        ) +
        ggplot2::scale_x_continuous(expand = ggplot2::expansion(0, 0)) +
        ggplot2::scale_y_continuous(
          expand = ggplot2::expansion(c(0, .15), c(0, 0))
        ) +
        ggplot2::annotate(
          "text",
          x = min(demo$weight) + 0.97 * diff(range(demo$weight)),
          y = -Inf,
          label = weight_label,
          hjust = "inward",
          vjust = -.25,
          size = 3.5,
          color = "#333333",
          fontface = "bold"
        ) +
        ggplot2::labs(
          x = "Weight (kg)",
          y = NULL
        ) +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank(),
          panel.grid.major.y = ggplot2::element_blank(),
          panel.grid.minor.y = ggplot2::element_blank()
        )
    })

    # Height plot
    output$plot_height <- shiny::renderPlot({
      req(r$demographics)
      demo <- r$demographics

      height_label <- sprintf(
        "Range: %.1f-%.1f  \nMean: %.1f  \nSD: %.1f  ",
        min(demo$height),
        max(demo$height),
        mean(demo$height),
        sd(demo$height)
      )

      ggplot2::ggplot(demo, ggplot2::aes(x = height)) +
        ggplot2::geom_density(
          fill = colors["height"],
          alpha = 0.6,
          color = colors["height"],
          linewidth = 1.2
        ) +
        ggplot2::scale_x_continuous(expand = ggplot2::expansion(0, 0)) +
        ggplot2::scale_y_continuous(
          expand = ggplot2::expansion(c(0, .15), c(0, 0))
        ) +
        ggplot2::annotate(
          "text",
          x = min(demo$height) + 0.97 * diff(range(demo$height)),
          y = -Inf,
          label = height_label,
          hjust = "inward",
          vjust = -.25,
          size = 3.5,
          color = "#333333",
          fontface = "bold"
        ) +
        ggplot2::labs(
          x = "Height (cm)",
          y = NULL
        ) +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank(),
          panel.grid.major.y = ggplot2::element_blank(),
          panel.grid.minor.y = ggplot2::element_blank()
        )
    })

    # BMI plot
    output$plot_bmi <- shiny::renderPlot({
      req(r$demographics)
      demo <- r$demographics
      demo$bmi <- demo$weight / ((demo$height / 100)^2)

      bmi_label <- sprintf(
        "Range: %.1f-%.1f \nMean: %.1f \nSD: %.1f ",
        min(demo$bmi),
        max(demo$bmi),
        mean(demo$bmi),
        sd(demo$bmi)
      )

      ggplot2::ggplot(demo, ggplot2::aes(x = bmi)) +
        ggplot2::geom_density(
          fill = colors["bmi"],
          alpha = 0.6,
          color = colors["bmi"],
          linewidth = 1.2
        ) +
        ggplot2::scale_x_continuous(expand = ggplot2::expansion(0, 0)) +
        ggplot2::scale_y_continuous(
          expand = ggplot2::expansion(c(0, .15), c(0, 0))
        ) +
        ggplot2::annotate(
          "text",
          x = min(demo$bmi) + 0.97 * diff(range(demo$bmi)),
          y = -Inf,
          label = bmi_label,
          hjust = "inward",
          vjust = -.25,
          size = 3.5,
          color = "#333333",
          fontface = "bold"
        ) +
        ggplot2::labs(x = "BMI", y = NULL) +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank(),
          panel.grid.major.y = ggplot2::element_blank(),
          panel.grid.minor.y = ggplot2::element_blank()
        )
    })
  })
}
