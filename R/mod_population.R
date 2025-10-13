#' Population UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_population_ui <- function(id) {
  ns <- NS(id)

  tagList(
    layout_column_wrap(
      width = NULL,
      style = css(grid_template_columns = "2fr 1fr"),
      selectInput(ns("population"), "Population", choices = NULL),
      numericInput(ns("n"), "Indiv. Number", value = 10, min = 1, max = 100)
    ),
    shinyWidgets::numericRangeInput(
      ns("age"),
      "Age",
      value = c(20, 60),
      min = 0,
      max = 100
    ),
    uiOutput(ns("physical_params"))
  )
}

#' Population Server Functions
#'
#' @noRd
mod_population_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(r$default_snapshot, {
      req(r$default_snapshot)

      updateSelectInput(
        inputId = "population",
        choices = r$default_snapshot$get_names("populations"),
        selected = "Healthy Women"
      )
    })

    output$physical_params <- renderUI({
      req(input$population)

      selected_data <- purrr::keep(
        r$default_snapshot$populations,
        ~ .x$Name == input$population
      )[[1]]

      # Check if population uses BMI or Height/Weight
      if (!is.null(selected_data$Settings$BMI)) {
        # BMI parameters
        shinyWidgets::numericRangeInput(
          ns("bmi"),
          "BMI",
          value = c(
            selected_data$Settings$BMI$Min %||% 16,
            selected_data$Settings$BMI$Max %||% 35
          ),
          min = 16,
          max = 35
        )
      } else if (
        !is.null(selected_data$Settings$Height) &&
          !is.null(selected_data$Settings$Weight)
      ) {
        # Height and Weight parameters
        tagList(
          shinyWidgets::numericRangeInput(
            ns("height"),
            "Height (cm)",
            value = c(
              selected_data$Settings$Height$Min %||% 150,
              selected_data$Settings$Height$Max %||% 190
            ),
            min = 120,
            max = 220
          ),
          shinyWidgets::numericRangeInput(
            ns("weight"),
            "Weight (kg)",
            value = c(
              selected_data$Settings$Weight$Min %||% 50,
              selected_data$Settings$Weight$Max %||% 100
            ),
            min = 30,
            max = 150
          )
        )
      } else {
        # Fallback if neither is found
        tags$div(
          class = "alert alert-warning",
          "No BMI or Height/Weight parameters found for this population"
        )
      }
    })

    observe({
      req(input$population)

      population_data <- purrr::keep(
        r$default_snapshot$populations,
        ~ .x$Name == input$population
      )[[1]]

      population_data$Settings$NumberOfIndividuals <- input$n
      population_data$Seed <- 42

      population_data$Settings$Age$Min <- input$age[1]
      population_data$Settings$Age$Max <- input$age[2]

      # Update either BMI or Height/Weight based on what's available
      if (!is.null(input$bmi)) {
        population_data$Settings$BMI$Min <- input$bmi[1]
        population_data$Settings$BMI$Max <- input$bmi[2]

        info_text <- "bmi: {.field {input$bmi}}"

        r$population_characteristics <- ospsuite::createPopulationCharacteristics(
          species = population_data$Settings$Individual$OriginData$Species,
          population = population_data$Settings$Individual$OriginData$Population,
          numberOfIndividuals = input$n,
          proportionOfFemales = 1,
          BMIMin = population_data$Settings$BMI$Min,
          BMIMax = population_data$Settings$BMI$Max,
          ageMin = population_data$Settings$Age$Min,
          ageMax = population_data$Settings$Age$Max,
          seed = 42
        )
      } else if (!is.null(input$height) && !is.null(input$weight)) {
        population_data$Settings$Height$Min <- input$height[1]
        population_data$Settings$Height$Max <- input$height[2]
        population_data$Settings$Weight$Min <- input$weight[1]
        population_data$Settings$Weight$Max <- input$weight[2]

        info_text <-
          c(
            "Height: {.field {input$height}}",
            "Weight: {.field {input$weight}}"
          )

        r$population_characteristics <- ospsuite::createPopulationCharacteristics(
          species = population_data$Settings$Individual$OriginData$Species,
          population = population_data$Settings$Individual$OriginData$Population,
          numberOfIndividuals = input$n,
          proportionOfFemales = 1,
          weightMin = population_data$Settings$Weight$Min,
          weightMax = population_data$Settings$Weight$Max,
          weightUnit = population_data$Settings$Weight$Unit,
          heightMin = population_data$Settings$Height$Min,
          heightMax = population_data$Settings$Height$Max,
          heightUnit = population_data$Settings$Height$Unit,
          ageMin = population_data$Settings$Age$Min,
          ageMax = population_data$Settings$Age$Max,
          seed = 42
        )
      } else {
        info_text <- "no physical parameters"
      }

      r$inputs$population <- input$population
      r$population_data <- population_data

      cli::cli_alert_info("Population updated with:")
      cli::cli_li("source pop: {.field {input$population}}")
      cli::cli_li("age: {.field {input$age}}")
      cli::cli_li(info_text)
    })
  })

  observe({
    req(r$population_characteristics)
    generated_pop <- ospsuite::createPopulation(
      r$population_characteristics
    )
    r$demographics <- tibble::tibble(
      id = generated_pop$population$allIndividualIds,
      age = generated_pop$population$getParameterValues("Organism|Age"),
      weight = generated_pop$population$getParameterValues("Organism|Weight"),
      height = ospsuite::toUnit(
        ospsuite::ospDimensions$Length,
        generated_pop$population$getParameterValues("Organism|Height"),
        targetUnit = ospsuite::ospUnits$Length$cm
      )
    )

    cli::cli_inform("Population generated.")
  })
}

## To be copied in the UI
# mod_population_ui("individual_1")

## To be copied in the server
# mod_population_server("individual_1")
