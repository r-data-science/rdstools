test_that("Dev-tools Report Coverage", {
  expr <- report_coverage()
  is.call(expr) |>
    expect_true()
})

test_that("report_coverage requests an RStudio restart when available", {
  old_ci <- Sys.getenv("CI")
  on.exit(Sys.setenv(CI = old_ci), add = TRUE)
  Sys.setenv(CI = "false")
  old_opts <- options(
    rdstools.mock_rstudio_available = TRUE,
    rdstools.restart_session_fun = function(clean, command) invisible(list(clean = clean, command = command)),
    rdstools.mock_is_testing = FALSE
  )
  on.exit(options(old_opts), add = TRUE)
  expect_null(report_coverage())
})
