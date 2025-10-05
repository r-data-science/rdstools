
#' Dev Tools
#'
#' @param ... arguments to covr::codecov
#'
#' @name dev-utils
NULL

#' @describeIn dev-utils Run package coverage and upload report
#' @return Invisibly returns the expression prepared for execution when no restart is triggered; otherwise called for side effects.
#' @details Set the option \code{rdstools.mock_rstudio_available} to \code{TRUE} and provide a custom restart function via \code{rdstools.restart_session_fun}; optionally use \code{rdstools.mock_is_testing} to emulate non-testing sessions during automation.
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
  mock_is_rs <- getOption("rdstools.mock_rstudio_available", NULL)
  is_rs <- if (is.null(mock_is_rs)) {
    rstudioapi::isAvailable()
  } else {
    isTRUE(mock_is_rs)
  }
  restart_fun <- getOption("rdstools.restart_session_fun", rstudioapi::restartSession)
  is_ci <- as.logical(Sys.getenv("CI", "false"))
  mock_is_tt <- getOption("rdstools.mock_is_testing", NULL)
  # Only call testthat::is_testing() if the package is installed
  if (is.null(mock_is_tt)) {
    if (requireNamespace("testthat", quietly = TRUE)) {
      is_tt <- testthat::is_testing()
    } else {
      is_tt <- FALSE
    }
  } else {
    is_tt <- isTRUE(mock_is_tt)
  }

  if (!is_ci && !is_tt && is_rs) {
    restart_fun(
      clean = TRUE,
      command = expr_txt
    )
    return(invisible(NULL))
  }

  invisible(rlang::parse_expr(expr_txt))
}


