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
    page_sidebar(
      title = "Clinical Trial Simulator",
      sidebar = sidebar(
        width = "30vw",
        accordion(
          open = TRUE,
          style = "min-height: 70vh; max-height: 70vh; overflow-y: auto;",
          accordion_panel(
            "Victim",icon = bs_icon("capsule"),
            mod_victim_ui("victim_1")
          ),
          accordion_panel(
            "Individual", icon = bs_icon("person-fill"),
            mod_individual_ui("individual_1")
          ),
          accordion_panel(
            "Perpetrator", icon = bs_icon("prescription"),
            mod_perpetrator_ui("perpetrator_1")
          )
        ),
        input_task_button("run", "Run Simulation", icon = bs_icon("play"))
      ),
      mod_results_values_ui("results_values_1"),
      mod_results_plot_ui("results_plot_1"),
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
