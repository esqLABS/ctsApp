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
    layout_columns(
      fill = FALSE,
      value_box(
        # title = "Building Blocks Summary",
        showcase = bs_icon("info-circle"),
        value = "DDI Clinical Trial Simulation Setup",
        theme = "primary",
        full_screen = FALSE,
        "This panel provides a summary of all selected building blocks from the sidebar."
      )
    ),
    layout_columns(
      col_widths = 1 / 2,
      card(
        height = "100%",
        card_header(
          class = "bg-primary text-white",
          div(
            class = "d-flex align-items-center",
            bs_icon("capsule", size = "1.5rem"),
            span(class = "ms-2", "Victim")
          )
        ),
        card_body(
          card(
            card_header("Compound"),
            card_body(
              shiny::htmlOutput(ns("victim_compound"))
            )
          ),
          card(
            card_header("Protocol"),
            card_body(
              shiny::htmlOutput(ns("victim_protocol"))
            )
          ),
          card(
            card_header("Formulation"),
            card_body(
              shiny::htmlOutput(ns("victim_formulation"))
            )
          )
        )
      ),
      card(
        height = "100%",
        card_header(
          class = "bg-primary text-white",
          div(
            class = "d-flex align-items-center",
            bs_icon("prescription", size = "1.5rem"),
            span(class = "ms-2", "Perpetrator")
          )
        ),
        card_body(
          card(
            card_header("Compound"),
            card_body(
              shiny::htmlOutput(ns("perpetrator_compound"))
            )
          ),
          card(
            card_header("Protocol"),
            card_body(
              shiny::htmlOutput(ns("perpetrator_protocol"))
            )
          ),
          card(
            card_header("Formulation"),
            card_body(
              shiny::htmlOutput(ns("perpetrator_formulation"))
            )
          )
        )
      )
      # card(
      #   height = "100%",
      #   card_header(
      #     class = "bg-primary text-white",
      #     div(
      #       class = "d-flex align-items-center",
      #       bs_icon("people-fill", size = "1.5rem"),
      #       span(class = "ms-2", "Population")
      #     )
      #   ),
      #   card_body(
      #     fill = FALSE,
      #     card(
      #       card_body(
      #         shiny::htmlOutput(ns("population"))
      #       )
      #     )
      #   )
      # )
    )
  )
}

#' Summary Server Function
#'
#' @noRd
mod_summary_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Victim information
    output$victim_compound <- renderPrint({
      req(r$inputs$victim)
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

      shiny::markdown(glue::glue(
        "
                                 **{r$inputs$victim}**

                                 * Molecular weight: {mw_data$Value} {mw_data$Unit}
                                 * Lipophilicity: {lipo_data$Value} {lipo_data$Unit}
                                 * Fraction unbound: {fu_data$Value} {fu_data$Unit}
                                 * Solubility: {solubility_data$Value} {solubility_data$Unit}
                                 * Processes: {glue::glue_collapse(enzymes,sep=',')}
                                 ",
        .null = ""
      ))
    })

    output$victim_protocol <- renderText({
      req(r$protocol_victim)

      shiny::markdown(
        paste(
          capture.output(
            r$protocol_victim
          ),
          collapse = "\n"
        ) |>
          stringr::str_replace_all("•", "*")
      )
    })

    output$victim_formulation <- renderPrint({
      req(r$formulation_victim)

      shiny::markdown(
        paste(
          capture.output(
            r$formulation_victim
          ),
          collapse = "\n"
        ) |>
          stringr::str_replace_all("•", "*")
      )
    })

    # Perpetrator information
    output$perpetrator_compound <- renderText({
      req(r$inputs$perpetrator)

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

      shiny::markdown(glue::glue(
        "
                                 **{r$inputs$perpetrator}**

                                 * Molecular weight: {mw_data$Value} {mw_data$Unit}
                                 * Lipophilicity: {lipo_data$Value} {lipo_data$Unit}
                                 * Fraction unbound: {fu_data$Value} {fu_data$Unit}
                                 * Solubility: {solubility_data$Value} {solubility_data$Unit}
                                 * Processes: {glue::glue_collapse(enzymes,sep=',')}
                                 ",
        .null = ""
      ))
    })

    output$perpetrator_protocol <- renderText({
      req(r$protocol_perpetrator)

      shiny::markdown(
        paste(
          capture.output(
            r$protocol_perpetrator
          ),
          collapse = "\n"
        ) |>
          stringr::str_replace_all("•", "*")
      )
    })

    output$perpetrator_formulation <- renderText({
      req(r$formulation_perpetrator)

      shiny::markdown(
        paste(
          capture.output(
            r$formulation_perpetrator
          ),
          collapse = "\n"
        ) |>
          stringr::str_replace_all("•", "*")
      )
    })

    # # Population information
    # output$population <- renderText({
    #   req(r$inputs$population)
    #
    # })
  })
}
