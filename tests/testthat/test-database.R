test_that("Testing yaml parameters", {
  nams <- c("host", "password", "drv", "user", "port",
            "connect_timeout", "timezone", "application_name",
            "client_encoding", "dbname")
  expect_named(ld_odbc("prod2", "integrated"), nams)
  expect_named(ld_odbc("dev2", "integrated"), nams)
  expect_error(ld_odbc("blahblah", "integrated"),
               "'arg' should be one of \"prod2\", \"dev2\"")
})
