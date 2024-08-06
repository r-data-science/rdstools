test_that("Dev-tools Report Coverage", {
  expr <- report_coverage()
  is.call(expr) |>
    expect_true()
})
