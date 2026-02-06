#' victim UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyWidgets numericRangeInput updateNumericRangeInput
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

    # Initialize a version counter to trigger updates
    observe({
      req(r$default_snapshot)
      if (is.null(r$snapshot_version)) {
        r$snapshot_version <- 1
      }
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

          # Count imported items
          imported_compounds <- length(uploaded_snapshot$compounds)
          imported_formulations <- if (
            !is.null(uploaded_snapshot$formulations)
          ) {
            length(uploaded_snapshot$formulations)
          } else {
            0
          }
          imported_protocols <- if (!is.null(uploaded_snapshot$protocols)) {
            length(uploaded_snapshot$protocols)
          } else {
            0
          }

          # Import compounds from uploaded snapshot
          new_compound_names <- character(0)
          if (imported_compounds > 0) {
            existing_names <- r$default_snapshot$get_names("compounds")
            for (compound in uploaded_snapshot$compounds) {
              compound_name <- compound$Name
              if (compound_name %in% existing_names) {
                compound$Name <- paste0(compound_name, " (imported)")
              }
              r$default_snapshot$compounds <- c(r$default_snapshot$compounds, list(compound))
              new_compound_names <- c(new_compound_names, compound$Name)
            }
          }

          # Import formulations from uploaded snapshot  
          new_formulation_names <- character(0)
          if (imported_formulations > 0) {
            existing_names <- r$default_snapshot$get_names("formulations")
            for (formulation in uploaded_snapshot$formulations) {
              formulation_name <- formulation$name
              if (formulation_name %in% existing_names) {
                formulation$name <- paste0(formulation_name, " (imported)")
              }
              r$default_snapshot$formulations <- c(r$default_snapshot$formulations, list(formulation))
              new_formulation_names <- c(new_formulation_names, formulation$name)
            }
          }

          # Import protocols from uploaded snapshot
          new_protocol_names <- character(0)
          if (imported_protocols > 0) {
            existing_names <- r$default_snapshot$get_names("protocols")
            for (protocol in uploaded_snapshot$protocols) {
              protocol_name <- protocol$name
              if (protocol_name %in% existing_names) {
                protocol$name <- paste0(protocol_name, " (imported)")
              }
              r$default_snapshot$protocols <- c(r$default_snapshot$protocols, list(protocol))
              new_protocol_names <- c(new_protocol_names, protocol$name)
            }
          }

          # Track which compound to select and trigger update
          if (imported_compounds > 0) {
            r$perpetrator_selected_compound <- new_compound_names[1]  # Select first imported compound
          }
          
          # Trigger dropdown updates
          r$snapshot_version <- r$snapshot_version + 1

          # Show success message
          if (
            imported_compounds > 0 ||
              imported_formulations > 0 ||
              imported_protocols > 0
          ) {
            cli::cli_alert_success(
              "Imported {imported_compounds} compound(s), {imported_formulations} formulation(s), and {imported_protocols} protocol(s) from snapshot"
            )
          } else {
            cli::cli_alert_warning("No items found in uploaded snapshot")
          }
        },
        error = function(e) {
          cli::cli_alert_danger("Error importing snapshot: {e$message}")
        }
      )
    })

    # Observe compounds - update dropdown when snapshot changes
    observeEvent(r$snapshot_version, {
      req(r$default_snapshot)
      
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
      } else if (id == "perpetrator") {
        compound_names <- stringr::str_subset(
          compound_names,
          pattern = "Drospirenone|Levonorgestrel",
          negate = TRUE
        )
        compound_names <- c("Upload Compound", compound_names)
        
        # Use tracked selection if available, otherwise default to Itraconazole
        selected_compound <- if (!is.null(r$perpetrator_selected_compound)) {
          sel <- r$perpetrator_selected_compound
          r$perpetrator_selected_compound <- NULL  # Clear after use
          sel
        } else {
          "Itraconazole"
        }
        
        updateSelectInput(
          inputId = "compound",
          choices = compound_names,
          selected = selected_compound
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
