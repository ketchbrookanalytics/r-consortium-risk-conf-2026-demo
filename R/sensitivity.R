#' Plot Sensitivity for a Single Predictor
#'
#' Hold all other predictors at their baseline (median) values, sweep the focal
#' predictor across its observed range, and return a `ggplot` of the predicted
#' default probability.
#'
#' @param var Character scalar naming the predictor column to sweep.
#' @param fit A fitted `glm` object.
#' @param data The original data frame used for fitting (supplies observed
#'   ranges).
#' @param baseline A single-row data frame of median predictor values.
#' @param predictor_labels A named character vector mapping predictor names to
#'   human-readable axis labels.
#' @param n_grid Integer number of points in the sweep grid (default 200).
#'
#' @return A `ggplot` object.
#' @keywords internal
plot_sensitivity <- function(
  var,
  fit,
  data,
  baseline,
  predictor_labels,
  n_grid = 200L
) {
  grid <- baseline[rep(1L, n_grid), , drop = FALSE]
  grid[[var]] <- seq(
    min(data[[var]]),
    max(data[[var]]),
    length.out = n_grid
  )

  grid$predicted_default_prob <- stats::predict(
    fit,
    newdata = grid,
    type = "response"
  )

  ggplot2::ggplot(
    grid,
    ggplot2::aes(x = .data[[var]], y = predicted_default_prob)
  ) +
    ggplot2::geom_line(linewidth = 1, colour = "#2f70c8") +
    ggplot2::scale_y_continuous(
      labels = scales::label_percent(),
      limits = c(0, NA)
    ) +
    ggplot2::labs(
      x = predictor_labels[[var]],
      y = "Predicted Default Probability"
    ) +
    ggplot2::theme_minimal(
      base_size = 11
    )
}


#' Generate Sensitivity Analysis Plots
#'
#' For each continuous predictor in the GLM model, hold all other predictors at
#' their median (or mode) values and sweep the focal predictor across its
#' observed range.
#' The resulting predicted default probability is plotted against the focal
#' predictor to visualise model sensitivity.
#'
#' @param data A data frame of credit data produced by `read_credit_data()`
#' @param model_params A tibble of tidy model parameters produced by
#'   `fit_glm_loss_model()`
#'
#' @return A named list of `ggplot` objects, one per continuous predictor
#'
#' @examples
#' # Load {targets} objects
#' targets::tar_load(credit_data)
#' targets::tar_load(model_params_validation)
#'
#' # Create all of the sensitivity plots
#' plots <- make_sensitivity_plots(credit_data, model_params_validation)
#'
#' # Take a look at a single plot
#' plots[["credit_score"]]
make_sensitivity_plots <- function(data, model_params) {
  # Re-fit the GLM model so we can use `predict()``
  fit <- glm(
    formula = default ~ unemployment_rate +
      cpi +
      gdp_growth +
      log(principal_balance) +
      credit_score +
      dti_ratio +
      interest_rate,
    data = data,
    family = binomial(link = "logit")
  )

  # Define the continuous predictors to sweep
  predictors <- c(
    "unemployment_rate",
    "cpi",
    "gdp_growth",
    "principal_balance",
    "credit_score",
    "dti_ratio",
    "interest_rate"
  )

  # Define better labels for the x-axes
  predictor_labels <- c(
    unemployment_rate = "Unemployment Rate (%)",
    cpi = "Consumer Price Index",
    gdp_growth = "GDP Growth Rate (%)",
    principal_balance = "Principal Balance ($)",
    credit_score = "Credit Score",
    dti_ratio = "Debt-to-Income Ratio (%)",
    interest_rate = "Interest Rate (%)"
  )

  # Build a baseline (median) observation
  baseline <- data.frame(
    unemployment_rate = stats::median(data$unemployment_rate),
    cpi = stats::median(data$cpi),
    gdp_growth = stats::median(data$gdp_growth),
    principal_balance = stats::median(data$principal_balance),
    credit_score = stats::median(data$credit_score),
    dti_ratio = stats::median(data$dti_ratio),
    interest_rate = stats::median(data$interest_rate)
  )

  # Sweep each predictor and predict
  predictors |>
    purrr::set_names() |>
    purrr::map(
      plot_sensitivity,
      fit = fit,
      data = data,
      baseline = baseline,
      predictor_labels = predictor_labels
    )
}
