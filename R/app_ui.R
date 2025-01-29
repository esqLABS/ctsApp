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
        width = "30vw",
        accordion(
          open = TRUE,
          style = "min-height: 70vh; max-height: 70vh; overflow-y: auto;",
          accordion_panel(
            "Victim",icon = bs_icon("capsule"),
            mod_victim_ui("victim_1")
          ),
          accordion_panel(
            "Population", icon = bs_icon("people fill"),
            mod_population_ui("individual_1")
          ),
          accordion_panel(
            "Perpetrator", icon = bs_icon("prescription"),
            mod_perpetrator_ui("perpetrator_1")
          )
        ),
        input_task_button("run", "Run Simulation", icon = bs_icon("play"))
      ),
      nav_panel(title = "PK",
                mod_results_pk_ui("results_general_1")
      ),
      nav_panel(title = "DDI",
                mod_mod_results_ddi_ui("mod_results_ddi_1")
      ),
      nav_panel(title = "PK PD"),
      nav_spacer(),
      nav_item(tags$a(bs_icon("file-text"), "White Paper", href = "")),
      nav_panel(title = "About",
                mod_about_ui("about_1")),
      nav_menu("More",align = "right",
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
