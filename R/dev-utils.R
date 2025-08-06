
#' Dev Tools
#'
#' @param ... arguments to covr::codecov
#'
#' @name dev-utils
NULL

#' @describeIn dev-utils Run package coverage and upload report
#' @export
report_coverage <- function(...) {
  args <- rlang::dots_list(...)

  if (!"quiet" %in% names(args))
    args$quiet <- FALSE
  if (!"path" %in% names(args))
    args$path <- "."

  # args <- list(quiet = FALSE, clean = FALSE)
  args <- list(args)

  expr_txt <- do.call(
    eval(parse(text = 'covr::codecov')),
    args = !!!args
  ) |> rlang::expr() |>
    deparse(nlines = 1, width.cutoff = 500)

  ## Evaluate if not on ci, not testing, and has rstudio
  is_rs <- rstudioapi::isAvailable()
  is_ci <- as.logical(Sys.getenv("CI", "false"))
  # Only call testthat::is_testing() if the package is installed
  if (requireNamespace("testthat", quietly = TRUE)) {
    is_tt <- testthat::is_testing()
  } else {
    is_tt <- FALSE
  }

  if (!is_ci && !is_tt && is_rs) {
    rstudioapi::restartSession(
      clean = TRUE,
      command = expr_txt
    )
  } else {
    rlang::parse_expr(expr_txt)
  }
}


