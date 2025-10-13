#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny bslib bsicons
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    page_navbar(
      title = "Clinical Trial Simulator",
      sidebar = sidebar(
        # title = "Clinical Trial Simulator",
        width = "25vw",
        accordion(
          open = TRUE,
          style = "min-height: 75vh; max-height: 75vh; overflow-y: auto;",
          accordion_panel(
            "Victim",
            icon = bs_icon("capsule"),
            mod_compound_ui("victim"),
            mod_protocol_ui("protocol_victim"),
            mod_formulation_ui("formulation_victim")
          ),
          accordion_panel(
            "Population",
            icon = bs_icon("people fill"),
            mod_population_ui("individual_1")
          ),
          accordion_panel(
            "Perpetrator",
            icon = bs_icon("prescription"),
            mod_compound_ui("perpetrator"),
            mod_protocol_ui("protocol_perpetrator"),
            mod_formulation_ui("formulation_perpetrator")
          ),
          accordion_panel(
            "Simulation Parameters",
            icon = bs_icon("sliders"),
            mod_simulation_params_ui("simulation_params")
          )
        ),
        mod_simulation_ui("simulation_1")
      ),
      nav_panel(
        title = "Experiment Design",
        icon = icon("flask"),
        mod_summary_ui("summary_1")
      ),

      nav_panel(
        title = tooltip(
          trigger = "Results",
          id = "results-tooltip",
          placement = "bottom",
          show = FALSE,
          ""
        ),
        icon = icon("clipboard-check"),
        mod_results_ui("results_1")
      ),
      nav_spacer(),
      nav_item(tags$a(bs_icon("file-text"), "White Paper", href = "")),
      nav_panel(
        title = "About",
        mod_about_ui("about_1")
      ),
      nav_menu(
        "More",
        align = "right",
        nav_item(tags$a(bs_icon("github"), "Code Repository", href = "")),
        nav_item(tags$a(bs_icon("flag"), "Report an Issue", href = "")),
        nav_item(tags$a(bs_icon("envelope-at"), "Contact", href = ""))
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "ctsApp"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
