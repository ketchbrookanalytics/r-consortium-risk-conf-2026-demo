#' Fit GLM Loss Model
#'
#' Fits a generalized linear model (GLM) with a binomial family and logit link
#' to predict loan defaults based on macroeconomic and loan-level predictors.
#'
#' @param data A data frame containing the required predictor variables:
#'   - `default`: Binary outcome variable (1 = default, 0 = no default)
#'   - `unemployment_rate`: Unemployment rate
#'   - `cpi`: Consumer Price Index
#'   - `gdp_growth`: GDP growth rate
#'   - `principal_balance`: Loan principal balance (will be log-transformed)
#'   - `credit_score`: Borrower credit score
#'   - `dti_ratio`: Debt-to-income ratio
#'   - `interest_rate`: Loan interest rate
#'
#' @return A fitted `glm` model object
#'
#' @examples
#' # Read in the data from CSV
#' credit_data <- read_credit_data()
#'
#' # Fit the GLM Model and retrieve the model parameters
#' fit_glm_loss_model(credit_data)
fit_glm_loss_model <- function(data) {

  cli::cli_alert_info("Fitting glm model...")

  # For demo purposes, let's pretend this model takes a long time to fit
  Sys.sleep(5L)

  mdl <- glm(
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

  cli::cli_alert_success("Model fit complete")

  # Return the model parameters
  broom::tidy(mdl)

}




#' Get Model Parameters from Documentation
#'
#' Returns a tibble containing pre-defined model parameter estimates
#' for the loss model terms based upon the client's documentation that was
#' provided to the validation team
#'
#' @return A tibble with two columns: `term` (character) containing the
#'   model term names and `estimate` (numeric) containing the coefficient
#'   estimates.
#'
#' @examples
#' get_model_params_from_docs()
get_model_params_from_docs <- function() {

  tibble::tribble(
    ~term, ~estimate,
    "(Intercept)", 5.0288,
    "unemployment_rate", 0.4065,
    "cpi", -0.0092,
    "gdp_growth", -0.0138,
    "log(principal_balance)", -0.2113,   # this is purposely incorrect
    "credit_score", -0.0159,
    "dti_ratio", 0.0538,
    "interest_rate", -0.2893
  )

}
