library(fs)
library(R.utils)
library(jsonlite)

clear_logs <- function() {
  # Clean up any log directories created in tempdir().
  log_dir <- fs::path(tempdir(), "rdstools_logs")
  if (fs::dir_exists(log_dir)) {
    fs::dir_delete(log_dir)
  }
}



test_that("Logging works!", {

  fp <- fs::file_create("test.log")
  x <- ..log(level = "e", "message", "add", lf = fp, TRUE)
  expect_true(fs::file_exists(x))
  fs::file_delete("test.log")

  clear_logs()

  expect_error(read_logs(), "log file path not found")
  expect_error(read_logs(lf = "test"), "Unable to locate log: test")

  lf <- open_log()
  expect_true(fs::file_exists(lf))


  clear_logs()


  lf <- open_log("test", 1)

  ## cant open again
  expect_error(open_log("test", 1))

  expect_true(is.character(lf))
  expect_true(is_absolute_path(lf))
  expect_true(file_exists(lf))
  expect_true(file_access(lf, "write"))
  expect_false(is_file_empty(lf))

  ## ensure file head is as expected
  ## The number of lines in the header depends on the length of Sys.info(), which
  ## can vary across operating systems (Windows reports an additional field).
  ## The header is composed of a top border, one line per Sys.info entry, a
  ## bottom border, a blank separator line, and the initial OPEN log entry.
  nf <- R.utils::countLines(lf)
  expected_lines <- length(Sys.info()) + 4
  expect_equal(nf, expected_lines)
  expect_true(attr(nf, "lastLineHasNewline"))

  lf <- close_log(gather = FALSE)

  expect_true(file_exists(lf))
  expect_false(file_access(lf, "write"))

  logs <- read_logs(lf = lf, detail_parse = FALSE)

  expect_true(nrow(logs) == 2)
  expect_named(logs, c("Level", "TimestampUTC", "Message", "Detail"))


  logs <- read_logs(lf = lf, detail_parse = TRUE)

  expect_true(nrow(logs) == 2)
  expect_named(logs, c("Level", "TimestampUTC", "Message", "Detail"))



  lf <- open_log("test", 2)

  expect_true(file_access(lf, "write"))

  for (i in 1:3) {
    Sys.sleep(1)
    expect_equal(lf, log_err(msg = "My error Message",
                             add = "Error information from R"))
    expect_equal(lf, log_err(msg = "My error Message"))
    expect_equal(lf, log_err())

    expect_equal(lf, log_wrn(msg = "My Warning Message",
                             add = "Warning information from R"))
    expect_equal(lf, log_wrn(msg = "My Warning Message"))
    expect_equal(lf, log_wrn())

    expect_equal(lf, log_inf(msg = "My Info Message",
                             add = "Warning information from R"))
    expect_equal(lf, log_inf(msg = "My Info Message"))
    expect_equal(lf, log_inf())

    expect_equal(lf, log_suc(msg = "My Success Message",
                             add = "Success information from R"))
    expect_equal(lf, log_suc(msg = "My Success Message"))
    expect_equal(lf, log_suc(msg = "success",
                             "split this|into|various|details"))
  }


  expect_error(log_err(add = "Add details"))

  Sys.sleep(1)
  logs <- close_log(gather = TRUE)

  expect_true(is.data.frame(logs))
  expect_true(nrow(logs) == 36)

  levs <- logs[, .N, keyby = Level][, Level]

  expect_equal(levs, c("ERROR", "INFO", "SUCCESS", "WARNING"))

  expect_warning(close_log())

  expect_null(log_err(msg = "My error Message"))

  expect_false(file_access(lf, "write"))
  expect_true(file_exists(lf))


  clear_logs()
})
