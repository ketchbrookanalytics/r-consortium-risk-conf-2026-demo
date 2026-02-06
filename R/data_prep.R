#' Read Credit Data
#'
#' Reads the synthetic credit data from a CSV file.
#'
#' @param file Path to the CSV file containing credit data
#'
#' @return A data frame containing the credit data with loan_type as a factor.
#'
#' @examples
#' credit_data <- read_credit_data(file = "data/synthetic_credit_data.csv")
read_credit_data <- function(file) {
  # Define the factor levels for the `loan_type` column variable
  loan_type_levels <- c(
    "Auto",
    "Credit Card",
    "Mortgage",
    "Personal"
  )

  # Read in the CSV while defining the column types
  readr::read_csv(
    file = file,
    col_types = readr::cols(
      loan_id = readr::col_character(),
      default = readr::col_logical(),
      unemployment_rate = readr::col_double(),
      cpi = readr::col_double(),
      gdp_growth = readr::col_double(),
      principal_balance = readr::col_double(),
      credit_score = readr::col_integer(),
      dti_ratio = readr::col_double(),
      interest_rate = readr::col_double(),
      loan_term = readr::col_integer(),
      loan_age = readr::col_integer(),
      loan_type = readr::col_factor(levels = loan_type_levels)
    )
  )
}
