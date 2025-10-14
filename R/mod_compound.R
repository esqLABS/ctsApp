#' victim UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import shinyWidgets
mod_compound_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("compound"),
      "Compound",
      choices = NULL
    ),
    # Show upload option only for perpetrator when "Upload Compound" is selected
    if (id == "perpetrator") {
      conditionalPanel(
        condition = "input.compound == 'Upload Compound'",
        ns = ns,
        div(
          style = "background-color: #f0f8ff; padding: 1em; border-radius: 6px; margin-top: 0.5em;",
          fileInput(
            ns("upload_snapshot"),
            "Upload Compound Snapshot",
            accept = c(".json"),
            buttonLabel = "Browse...",
            placeholder = "No file selected"
          )
        )
      )
    }
  )
}

#' victim Server Functions
#'
#' @noRd
mod_compound_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    model_directory <- system.file("data/models", package = "ctsApp")

    observe({
      r$default_snapshot <- cts:::Snapshot$new(file.path(
        model_directory,
        "ddi_oral_contraceptives.json"
      ))
    })

    # Handle snapshot upload for perpetrator
    observeEvent(input$upload_snapshot, {
      req(input$upload_snapshot)
      req(id == "perpetrator")

      tryCatch(
        {
          # Load the uploaded snapshot
          uploaded_snapshot <- cts:::Snapshot$new(
            input$upload_snapshot$datapath
          )

          # Extract compounds from uploaded snapshot
          if (length(uploaded_snapshot$compounds) > 0) {
            # Get existing compound names (track as we add)
            existing_names <- r$default_snapshot$get_names("compounds")

            # Process each uploaded compound
            for (compound in uploaded_snapshot$compounds) {
              compound_name <- compound$Name

              # If name already exists, append (imported)
              if (compound_name %in% existing_names) {
                compound$Name <- paste0(compound_name, " (imported)")
              }

              # Add compound to default snapshot
              r$default_snapshot$compounds <- c(
                r$default_snapshot$compounds,
                list(compound)
              )

              # Update existing names to include this newly added compound
              existing_names <- c(existing_names, compound$Name)
            }

            # Update the compound dropdown
            compound_names <- r$default_snapshot$get_names("compounds")
            compound_names <- stringr::str_subset(
              compound_names,
              pattern = "Drospirenone|Levonorgestrel",
              negate = TRUE
            )

            # Add "Upload Compound" option at the beginning for perpetrator
            compound_names <- c("Upload Compound", compound_names)

            # Select the first imported compound (last one added)
            last_compound <- r$default_snapshot$get_names("compounds")
            last_compound <- last_compound[length(last_compound)]

            updateSelectInput(
              inputId = "compound",
              choices = compound_names,
              selected = last_compound
            )

            cli::cli_alert_success(
              "Imported {length(uploaded_snapshot$compounds)} compound(s) from snapshot"
            )
          } else {
            cli::cli_alert_warning("No compounds found in uploaded snapshot")
          }
        },
        error = function(e) {
          cli::cli_alert_danger("Error importing snapshot: {e$message}")
        }
      )
    })

    observeEvent(r$default_snapshot, {
      compound_names <- r$default_snapshot$get_names("compounds")

      if (id == "victim") {
        compound_names <- stringr::str_subset(
          compound_names,
          pattern = "Drospirenone|Levonorgestrel"
        )
        updateSelectInput(
          inputId = "compound",
          choices = compound_names,
          selected = "Drospirenone"
        )
      } else {
        # For perpetrator, add "Upload Compound" option at the beginning
        compound_names <- stringr::str_subset(
          compound_names,
          pattern = "Drospirenone|Levonorgestrel",
          negate = TRUE
        )
        compound_names <- c("Upload Compound", compound_names)
        updateSelectInput(
          inputId = "compound",
          choices = compound_names,
          selected = "Itraconazole"
        )
      }
    })

    observe({
      req(input$compound)

      # Only set r$inputs[[id]] if a valid compound is selected
      # Do NOT set it if "Upload Compound" is selected
      if (input$compound != "Upload Compound") {
        r$inputs[[id]] <- input$compound
        cli::cli_alert_info(
          "Compound Selected as {id}: {.field {input$compound}}"
        )
      } else {
        # Clear the input when "Upload Compound" is selected
        r$inputs[[id]] <- NULL
        cli::cli_alert_info(
          "Waiting for compound upload for {id}"
        )
      }
    })
  })
}

## To be copied in the UI
# mod_compound_ui("victim_1")

## To be copied in the server
# mod_compound_server("victim_1")
