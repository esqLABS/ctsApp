#' results_pd UI Function
#'
#' @description A shiny Module for PK-PD Analysis displaying Pearl Index
#' and Ovulation Rate based on progestin Cavg.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_pd_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("value_boxes"))
  )
}

#' results_pd Server Functions
#'
#' @noRd
mod_results_pd_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$value_boxes <- renderUI({
      req(r$results)

      victim <- r$inputs$victim

      # Get PD parameters for the victim progestin
      pd_params <- get_pd_params(victim)
      req(pd_params)

      # --- DDI Simulation ---
      pk_ddi <- r$results$pk_results$`DDI Simulation`
      cavg_ddi <- compute_cavg(pk_ddi, victim)

      pi_ddi <- calculate_pd(
        Cavg = cavg_ddi,
        BL = 85, Imax = 1,
        Kd = pd_params$Kd, tau = pd_params$tau_pi, hill = 9.653
      )
      or_ddi <- calculate_pd(
        Cavg = cavg_ddi,
        BL = 100, Imax = 1,
        Kd = pd_params$Kd, tau = pd_params$tau_or, hill = 25.462
      )

      pi_q_ddi <- signif(
        quantile(pi_ddi, probs = c(0.05, 0.5, 0.95), na.rm = TRUE), 4
      )
      or_q_ddi <- signif(
        quantile(or_ddi, probs = c(0.05, 0.5, 0.95), na.rm = TRUE), 4
      )

      # --- Single Simulation ---
      pk_single <- r$results$pk_results$`Single Simulation`
      cavg_single <- compute_cavg(pk_single, victim)

      pi_single <- calculate_pd(
        Cavg = cavg_single,
        BL = 85, Imax = 1,
        Kd = pd_params$Kd, tau = pd_params$tau_pi, hill = 9.653
      )
      or_single <- calculate_pd(
        Cavg = cavg_single,
        BL = 100, Imax = 1,
        Kd = pd_params$Kd, tau = pd_params$tau_or, hill = 25.462
      )

      pi_q_single <- signif(
        quantile(pi_single, probs = c(0.05, 0.5, 0.95), na.rm = TRUE), 4
      )
      or_q_single <- signif(
        quantile(or_single, probs = c(0.05, 0.5, 0.95), na.rm = TRUE), 4
      )

      tagList(
        h5(glue::glue("With {r$inputs$perpetrator} (DDI Simulation)")),
        layout_column_wrap(
          width = 1 / 2,
          quantile_value_box(
            tooltip(
              "Pearl Index",
              "Pearl Index: Number of unintended pregnancies per 100 woman-years of contraceptive use. Lower values indicate better efficacy."
            ),
            pi_q_ddi
          ),
          quantile_value_box(
            tooltip(
              "Ovulation Rate (%)",
              "Ovulation Rate: Percentage of women expected to ovulate. Lower values indicate better suppression."
            ),
            or_q_ddi
          )
        ),
        h5(glue::glue("Without {r$inputs$perpetrator} (Victim Only Simulation)")),
        layout_column_wrap(
          width = 1 / 2,
          quantile_value_box(
            tooltip(
              "Pearl Index",
              "Pearl Index: Number of unintended pregnancies per 100 woman-years of contraceptive use. Lower values indicate better efficacy."
            ),
            pi_q_single
          ),
          quantile_value_box(
            tooltip(
              "Ovulation Rate (%)",
              "Ovulation Rate: Percentage of women expected to ovulate. Lower values indicate better suppression."
            ),
            or_q_single
          )
        )
      )
    })
  })
}

#' Compute Cavg in log10(pmol/L) from PK analysis results
#'
#' Cavg = 0.5 * (C_max + C_trough) for the last dosing interval.
#' Falls back to C_max / C_trough_tEnd if last-dosing-interval params are not available.
#'
#' @param pk_data PK analysis results tibble
#' @param compound Name of the victim compound
#' @return Numeric vector of Cavg values in log10(pmol/L) per individual
#' @noRd
compute_cavg <- function(pk_data, compound) {
  cmax_result <- extract_pk_values(
    pk_data, "C_max_tDLast_tEnd", "C_max", compound
  )
  ctrough_result <- extract_pk_values(
    pk_data, "C_trough_tDLast", "C_trough", compound
  )

  # Values from PK analysis are in µmol/L; convert to pmol/L (multiply by 1e6)
  cavg <- 0.5 * (cmax_result$values + ctrough_result$values)
  cavg_pmol <- cavg * 1e6

  log10(cavg_pmol)
}

#' PD function for Pearl Index and Ovulation Rate
#'
#' @param Cavg Average concentration in log10(pmol/L)
#' @param BL Baseline value (85 for Pearl Index, 100 for Ovulation Rate)
#' @param Imax Maximum inhibition
#' @param Kd Dissociation constant in log10(pmol/L)
#' @param tau Drug-specific tau estimate
#' @param hill Hill coefficient
#' @return Numeric vector of PD values
#' @noRd
calculate_pd <- function(Cavg, BL, Imax, Kd, tau, hill) {
  BL * (1 - (Imax * tau^hill * Cavg^hill) /
    ((Kd + Cavg)^hill + (tau^hill * Cavg^hill)))
}

#' Get PD parameters for a given progestin
#'
#' @param victim Name of the victim compound
#' @return Named list with Kd, tau_pi (Pearl Index tau), and tau_or (Ovulation Rate tau),
#'   or NULL if the victim is not a supported progestin.
#' @noRd
get_pd_params <- function(victim) {
  if (victim == "Drospirenone") {
    list(Kd = 2.949, tau_pi = 2.602, tau_or = 1.867)
  } else if (victim == "Levonorgestrel 1") {
    list(Kd = 3.556, tau_pi = 3.046, tau_or = 2.172)
  } else {
    NULL
  }
}
