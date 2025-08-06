library(DBI)
library(RSQLite)
library(data.table)

test_that("database fetch query", {
  cn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(cn, "iris", data.table::rbindlist(rep(list(iris), 1000)))
  msg <- capture.output(dbQueryFetch(cn, "SELECT * FROM iris;", 1500))[100]
  expect_match(msg, "iteration\\: 100")
  DBI::dbDisconnect(cn)
})
