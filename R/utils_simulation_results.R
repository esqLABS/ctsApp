#' Check if current inputs match default configuration
#'
#' @param r Reactive values object containing all input parameters
#'
#' @return Logical indicating if all inputs match defaults
#' @noRd
inputs_are_default <- function(r) {
  # Check if all required inputs exist
  if (
    is.null(r$inputs$victim) ||
      is.null(r$inputs$perpetrator) ||
      is.null(r$inputs$population) ||
      is.null(r$simulation_params)
  ) {
    return(FALSE)
  }

  # Check EE status (default is FALSE/NULL)
  model_ee <- r$model_ee %||% FALSE

  # Define default values
  default_victim <- "Drospirenone"
  default_perpetrator <- "Itraconazole"
  default_population <- "European (ICRP, 2002)"
  default_duration_value <- 24
  default_duration_unit <- "h"
  default_resolution <- 4
  default_model_ee <- FALSE

  # Check each input against defaults
  victim_match <- r$inputs$victim == default_victim
  perpetrator_match <- r$inputs$perpetrator == default_perpetrator
  population_match <- r$inputs$population == default_population
  duration_value_match <- r$simulation_params$duration_value ==
    default_duration_value
  duration_unit_match <- r$simulation_params$duration_unit ==
    default_duration_unit
  resolution_match <- r$simulation_params$resolution == default_resolution
  ee_match <- isTRUE(model_ee) == default_model_ee

  # Return TRUE only if all match
  all(
    victim_match,
    perpetrator_match,
    population_match,
    duration_value_match,
    duration_unit_match,
    resolution_match,
    ee_match
  )
}

#' Get path to saved default results file
#'
#' @return Character path to the RDS file containing default results
#' @noRd
get_default_results_path <- function() {
  system.file("extdata", "default_simulation_results.rds", package = "ctsApp")
}

#' Toggle to enable/disable automatic saving of simulation results
#' Set to TRUE to save results, FALSE to disable saving
#' @export
SAVE_SIMULATION_RESULTS <- FALSE

#' Save simulation results as default results
#'
#' @param results List containing sim_results and pk_results
#' @param r Reactive values object containing input configuration
#'
#' @return Invisible NULL. Writes results to inst/extdata/default_simulation_results.rds
#' @export
save_default_results <- function(results, r) {
  # Create metadata
  metadata <- list(
    victim = r$inputs$victim,
    perpetrator = r$inputs$perpetrator,
    population = r$inputs$population,
    duration_value = r$simulation_params$duration_value,
    duration_unit = r$simulation_params$duration_unit,
    resolution = r$simulation_params$resolution,
    model_ee = r$model_ee %||% FALSE,
    timestamp = Sys.time(),
    platform = Sys.info()[["sysname"]]
  )

  # Bundle results with metadata
  saved_data <- list(
    metadata = metadata,
    sim_results = results$sim_results,
    pk_results = results$pk_results
  )

  # Determine save path using system.file
  extdata_dir <- system.file("extdata", package = "ctsApp")

  # If package is not installed (development mode), save to inst/extdata
  if (extdata_dir == "") {
    inst_extdata_dir <- file.path("inst", "extdata")
    if (!dir.exists(inst_extdata_dir)) {
      dir.create(inst_extdata_dir, recursive = TRUE)
    }
    save_path <- file.path(inst_extdata_dir, "default_simulation_results.rds")
  } else {
    # Installed package - save to package extdata directory
    save_path <- file.path(extdata_dir, "default_simulation_results.rds")
  }

  # Save results
  saveRDS(saved_data, save_path)

  cli::cli_alert_success(
    "Saved default simulation results to {.file {save_path}}"
  )
  cli::cli_alert_info(
    "Platform: {metadata$platform}, Timestamp: {metadata$timestamp}"
  )

  invisible(NULL)
}

#' Load saved default simulation results
#'
#' @return List containing sim_results and pk_results, or NULL if not available
#' @noRd
load_default_results <- function() {
  results_path <- get_default_results_path()

  # Check if file exists
  if (!file.exists(results_path) || results_path == "") {
    return(NULL)
  }

  # Load saved data
  tryCatch(
    {
      saved_data <- readRDS(results_path)

      # Validate structure
      if (
        !all(c("metadata", "sim_results", "pk_results") %in% names(saved_data))
      ) {
        cli::cli_alert_warning("Saved results file has invalid structure")
        return(NULL)
      }

      # Log metadata
      cli::cli_alert_success("Loaded pre-saved simulation results")
      cli::cli_alert_info(
        "Configuration: {saved_data$metadata$victim} + {saved_data$metadata$perpetrator}"
      )
      cli::cli_alert_info(
        "Saved on {saved_data$metadata$platform} at {saved_data$metadata$timestamp}"
      )

      # Return just the results (not metadata)
      list(
        sim_results = saved_data$sim_results,
        pk_results = saved_data$pk_results
      )
    },
    error = function(e) {
      cli::cli_alert_warning("Error loading saved results: {e$message}")
      NULL
    }
  )
}
