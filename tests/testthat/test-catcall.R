test_that("catcall prints to console when RStudio is not available", {
  withr::with_options(list(rdstools.mock_rstudio_available = FALSE), {
    txt <- stringr::str_squish(stringr::str_flatten(capture.output(catcall(letters))))
    expect_identical(letters, eval(rlang::parse_expr(txt)))
  })
})

test_that("catcall inserts into RStudio document when RStudio is available", {
  inserted <- NULL
  mock_insert <- function(text) {
    inserted <<- text
    invisible(NULL)
  }
  withr::with_options(
    list(
      rdstools.mock_rstudio_available = TRUE,
      rdstools.insert_text_fun = mock_insert
    ),
    {
      result <- withVisible(catcall(letters))
      expect_false(result$visible)
      expect_s3_class(result$value, "rdstools_catcall")
      expect_false(is.null(inserted))
      expect_identical(letters, eval(rlang::parse_expr(inserted)))
    }
  )
})
