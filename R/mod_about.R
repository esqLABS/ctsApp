#' about UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_about_ui <- function(id) {
  ns <- NS(id)
  tagList(
    layout_columns(
      col_widths = c(12, 6, 6, 12),
      # Main description card
      card(
        card_header(
          class = "bg-primary",
          tags$h4(bsicons::bs_icon("info-circle"), " About ctsApp")
        ),
        card_body(
          tags$p(
            "The ", tags$strong("ctsApp"), " package provides a graphical user
            interface (Shiny app) for the ", tags$strong("cts"),
            " (Contraceptives DDI Trial Simulation Platform) package."
          ),
          tags$p(
            "It offers an intuitive web-based interface to design and simulate
            drug-drug interactions (DDI) involving contraceptive drugs using
            physiologically based pharmacokinetic (PBPK) models."
          )
        )
      ),
      # Features card
      card(
        card_header(tags$h5(bsicons::bs_icon("list-check"), " Key Features")),
        card_body(
          tags$ul(
            tags$li("Import and explore compound models from the OSP model library"),
            tags$li("Design DDI simulations between victim and perpetrator compounds"),
            tags$li("Configure dosing protocols (oral, IV bolus, IV infusion)"),
            tags$li("Define population parameters and individual characteristics"),
            tags$li("Run simulations and analyze results with interactive plots"),
            tags$li("Export simulation results for further analysis in PK-Sim")
          )
        )
      ),
      # Resources card
      card(
        card_header(tags$h5(bsicons::bs_icon("link-45deg"), " Resources")),
        card_body(
          tags$ul(
            tags$li(
              tags$a(
                href = "https://github.com/esqLABS/cts",
                target = "_blank",
                bsicons::bs_icon("github"), " cts Package"
              )
            ),
            tags$li(
              tags$a(
                href = "https://github.com/esqLABS/ctsApp",
                target = "_blank",
                bsicons::bs_icon("github"), " ctsApp Repository"
              )
            ),
            tags$li(
              tags$a(
                href = "https://github.com/esqLABS/ctsApp/issues",
                target = "_blank",
                bsicons::bs_icon("bug"), " Report Issues"
              )
            ),
            tags$li(
              tags$a(
                href = "https://www.open-systems-pharmacology.org/",
                target = "_blank",
                bsicons::bs_icon("box-arrow-up-right"), " Open Systems Pharmacology"
              )
            )
          )
        )
      ),
      # Credits card
      card(
        card_header(tags$h5(bsicons::bs_icon("people"), " Credits")),
        card_body(
          tags$p(
            "Developed by ", tags$strong("ESQlabs GmbH")
          ),
          tags$p(
            tags$strong("Authors:"),
            tags$br(),
            "Felix MIL (Author, Maintainer)",
            tags$br(),
            "Sia Mirza (Author, Contributor)",
            tags$br(),
            "Diane Lefaudeux (Contributor, Maintainer)"
          ),
          tags$p(
            tags$strong("Version: "),
            as.character(utils::packageVersion("ctsApp"))
          ),
          tags$p(
            tags$strong("License: "), "MIT"
          )
        )
      )
    )
  )
}

#' about Server Functions
#'
#' @noRd
mod_about_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_about_ui("about_1")

## To be copied in the server
# mod_about_server("about_1")
