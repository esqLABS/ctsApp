#' Results UI Function
#'
#' @description A shiny Module that combines PK and DDI results in tabbed cards.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_ui <- function(id) {
    ns <- NS(id)
    tagList(
        conditionalPanel(
            ns = ns,
            condition = paste0("!output.has_results"),
            div(
                style = "text-align: center; padding: 2em;",
                "Please run the simulation to view results."
            )
        ),
        conditionalPanel(
            ns = ns,
            condition = paste0("output.has_results"),
            navset_card_tab(
                full_screen = TRUE,
                title = "Simulation Results",
                height = "100%",
                nav_panel(
                    title = "Pharmacokinetics",
                    mod_results_pk_ui(ns("pk"))
                ),
                nav_panel(
                    title = "DDI Analysis",
                    mod_results_ddi_ui(ns("ddi"))
                )
            )
        )
    )
}

#' Results Server Functions
#'
#' @noRd
mod_results_server <- function(id, r) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        # Add an output to track if results are available
        output$has_results <- reactive({
            !is.null(r$results)
        })
        outputOptions(output, "has_results", suspendWhenHidden = FALSE)

        # Call the individual module servers
        mod_results_pk_server("pk", r)
        mod_results_ddi_server("ddi", r)
    })
}

## To be copied in the UI
# mod_results_ui("results")

## To be copied in the server
# mod_results_server("results", r)
