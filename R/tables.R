#' Create GT Table Comparing Validation / Docs Model Fit Statistics
#'
#' @param model_stats_validation A data frame containing the model fit
#'   statistics computed by the validation team
#' @param model_stats_data A data frame containing the model fit statistics
#'   defined in the model documentation
#'
#' @return A GT table object
make_model_comparison_tbl <- function(model_stats_validation,
                                      model_stats_from_docs) {

  model_stats_validation |>
    dplyr::select(
      term,
      val_estimate = estimate
    ) |>
    dplyr::full_join(
      y = model_stats_from_docs |>
        dplyr::rename(docs_estimate = estimate),
      by = "term"
    ) |>
    dplyr::mutate(
      dplyr::across(
        .cols = -term,
        .fns = ~ round(.x, 4L)
      ),
      difference = round(val_estimate - docs_estimate, 4L)
    ) |>
    gt::gt() |>
    gt::fmt_number(
      columns = -term,
      decimals = 4L
    ) |>
    gt::cols_label(
      term = "Term",
      val_estimate = "Estimate (Validation)",
      docs_estimate = "Estimate (Documentation)",
      difference = "Difference"
    ) |>
    gt::tab_options(
      table.font.names = "Roboto"
    )

}