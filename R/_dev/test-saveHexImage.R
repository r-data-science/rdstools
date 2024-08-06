test_that("saving hex image works", {
  skip_on_ci()
  fp <- saveHexImage("Cartoon cabbage smoking cannabis")
  expect_true(file.exists(fp))
  expect_true(file.remove(fp))
})
