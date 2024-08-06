library(data.table)
library(stringr)

test_that("show progress", {
  DT <- setDT(copy(datasets::beaver1))[]
  txt <- stringr::str_squish(capture.output(x <- DT[, .catprogress(1), day]))
  chk <- c("progress... 0%", "progress... 50%")
  expect_equal(txt, chk)
})
