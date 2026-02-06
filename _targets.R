# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(quarto)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Replace the target list below with your own:
list(
  # Data Loading/Preparation ----
  tar_target(
    name = credit_data_file,
    command = fs::path("data", "synthetic_credit_data.csv"),
    format = "file"
  ),
  # we can use the previous target (which just returns a file path) in any
  # downstream target
  tar_target(
    name = credit_data,
    command = read_credit_data(file = credit_data_file)
  ),

  # Model Documentation Objects ----
  tar_target(
    name = model_params_docs,
    command = get_model_params_from_docs()
  ),

  # Validation (re-performed) GLM Model ----
  # Using upstream target `credit_data`
  tar_target(
    name = model_params_validation,
    command = fit_glm_loss_model(data = credit_data)
  ),

  # Model Parameters Comparison ----
  # Create {gt} table comparing model parameters between model documentation and
  # validation re-performance
  tar_target(
    name = model_comparison_tbl,
    command = make_model_comparison_tbl(
      model_stats_validation = model_params_validation,
      model_stats_from_docs = model_params_docs
    )
  ),

  # Sensitivity Analysis ----
  # One-at-a-time sensitivity plots for each continuous predictor
  tar_target(
    name = sensitivity_plots,
    command = make_sensitivity_plots(
      data = credit_data,
      model_params = model_params_validation
    )
  ),

  # Render the report to "_output/"
  tar_quarto(
    name = report,
    path = "report.qmd"
  )
)
