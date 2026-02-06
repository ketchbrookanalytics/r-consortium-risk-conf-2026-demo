# ============================================================================
# Synthetic Credit Loss Dataset Generator
# Creates 500 loans with macroeconomic and loan-level features
# ============================================================================

# Set seed for reproducibility
set.seed(42)

# Number of loans
n_loans <- 500

# Generate Macroeconomic Variables ----

# Unemployment rate (%) - realistic range 3.5% to 10%
unemployment_rate <- runif(n_loans, min = 3.5, max = 10)

# Consumer Price Index - baseline around 300 with variation
cpi <- rnorm(n_loans, mean = 300, sd = 15)

# GDP growth rate (%) - additional macro variable
gdp_growth <- rnorm(n_loans, mean = 2.5, sd = 1.5)


# Generate Loan-Level Variables ----

# Principal balance ($) - range from $5,000 to $500,000
principal_balance <- exp(runif(n_loans, log(5000), log(500000)))
principal_balance <- round(principal_balance, 2)

# Credit score - normally distributed around 680, bound between 300-850

credit_score <- rnorm(n_loans, mean = 680, sd = 60)
credit_score <- pmax(pmin(round(credit_score), 850), 300)

# Debt-to-income ratio (%) - realistic range
dti_ratio <- rbeta(n_loans, 2, 5) * 60 # Skewed toward lower values, max ~60%

# Interest rate (%) - influenced by credit score
base_rate <- 5
interest_rate <- base_rate + (750 - credit_score) / 50 + rnorm(n_loans, 0, 0.5)
interest_rate <- pmax(interest_rate, 3) # Floor at 3%

# Loan term (months)
loan_term <- sample(
  x = c(12, 24, 36, 48, 60, 72, 84),
  size = n_loans,
  replace = TRUE,
  prob = c(0.05, 0.10, 0.25, 0.25, 0.20, 0.10, 0.05)
)

# Loan age (months since origination)
loan_age <- sapply(loan_term, function(term) sample(x = 1:term, size = 1L))

# Loan type
loan_type <- sample(
  x = c("Personal", "Auto", "Mortgage", "Credit Card"),
  size = n_loans,
  replace = TRUE,
  prob = c(0.30, 0.25, 0.25, 0.20)
)


# Generate Default Status (Dependent Variable) ----

# Create linear predictor for default probability using logistic model
# Coefficients chosen to create realistic default rates (~5-15%)
log_odds <- -4.5 + # Intercept
  0.25 * (unemployment_rate - 5) + # Higher unemployment, more defaults
  0.01 * (cpi - 300) + # Higher CPI → slightly more defaults
  -0.15 * (gdp_growth - 2.5) + # Lower GDP growth → more defaults
  0.3 * log10(principal_balance / 10000) + # Larger loans → more defaults
  -0.03 * (credit_score - 680) / 10 + # Lower credit score → more defaults
  0.05 * (dti_ratio - 30) + # Higher DTI → more defaults
  0.1 * (interest_rate - 8) # Higher rate → more defaults

# Convert to probability
default_prob <- 1 / (1 + exp(-log_odds))

# Generate binary default status
default_status <- rbinom(
  n = n_loans,
  size = 1L,
  prob = default_prob
)

# Create the dataset ----

credit_data <- data.frame(
  loan_id = paste0("LN", sprintf("%05d", 1:n_loans)),

  # Dependent variable
  default = default_status,

  # Macroeconomic variables
  unemployment_rate = round(unemployment_rate, 2L),
  cpi = round(cpi, 2L),
  gdp_growth = round(gdp_growth, 2L),

  # Loan characteristics
  principal_balance = principal_balance,
  credit_score = credit_score,
  dti_ratio = round(dti_ratio, 2L),
  interest_rate = round(interest_rate, 2L),
  loan_term = loan_term,
  loan_age = loan_age,
  loan_type = as.factor(loan_type)
)

# Display dataset statistics ----

cli::cli_h1("Synthetic Credit Loss Dataset Summary")
cli::cli_text("Dataset Statistics")
cli::cli_bullets(c(
  "*" = "{nrow(credit_data)} loans",
  "*" = "{ncol(credit_data)} variables",
  "*" = "Default Rate: {round(mean(credit_data$default) * 100, 2L)}%"
))

# Fit the GLM model ----

model <- glm(
  formula = default ~ unemployment_rate +
    cpi +
    gdp_growth +
    log(principal_balance) +
    credit_score +
    dti_ratio +
    interest_rate,
  data = credit_data,
  family = binomial(link = "logit")
)

# Show a model summary
summary(model)

# Write out to CSV file ----

write.csv(
  x = credit_data,
  file = "data/synthetic_credit_data.csv",
  row.names = FALSE
)
