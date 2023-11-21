test_that("catcall", {
  txt <- stringr::str_squish(stringr::str_flatten(capture.output(catcall(letters))))
  expect_identical(letters, eval(rlang::parse_expr(txt)))
})
