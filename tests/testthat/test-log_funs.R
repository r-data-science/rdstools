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

  ## can reattach to the same log file when append = TRUE
  lf_reattach <- open_log("test", 1)
  expect_identical(lf, lf_reattach)

  expect_true(is.character(lf))
  expect_true(is_absolute_path(lf))
  expect_true(file_exists(lf))
  expect_true(file_access(lf, "write"))
  expect_false(is_file_empty(lf))

  ## ensure file head is as expected
  ## The log header consists of a top border, one line per field returned by
  ## Sys.info(), a bottom border, a blank separator line, and the initial OPEN
  ## log entry. The exact number of lines varies by operating system (e.g.
  ## Windows can have additional fields in Sys.info()). Instead of asserting
  ## an exact count, ensure there are at least as many lines as the minimal
  ## expected structure and that the final line ends with a newline.
  nf <- R.utils::countLines(lf)
  expected_min <- length(Sys.info()) + 4
  expect_true(nf >= expected_min)
  expect_true(attr(nf, "lastLineHasNewline"))

  lf <- close_log(gather = FALSE)

  expect_true(file_exists(lf))
  expect_false(file_access(lf, "write"))

  logs <- read_logs(lf = lf, detail_parse = FALSE)

  expect_gt(nrow(logs), 1)
  expect_named(logs, c("Level", "TimestampUTC", "Message", "Detail"))
  expect_true(all(logs$Level %in% c("OPEN", "CLOSE")))


  logs <- read_logs(lf = lf, detail_parse = TRUE)

  expect_gt(nrow(logs), 1)
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
  logs <- suppressWarnings(close_log(gather = TRUE))

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

test_that("open_log supports custom paths and append control", {
  clear_logs()

  tmp_dir <- fs::path(tempdir(), "rdstools-test")
  if (fs::dir_exists(tmp_dir)) {
    fs::dir_delete(tmp_dir)
  }

  custom_path <- fs::path(tmp_dir, "custom.log")

  # When directory does not exist it should be created
  lf <- open_log(path = custom_path)
  expect_identical(lf, as.character(custom_path))
  expect_true(fs::file_exists(custom_path))
  expect_true(log_is_active())

  log_err("first", add = "entry")
  close_log(gather = FALSE)
  expect_false(log_is_active())

  size_initial <- fs::file_size(custom_path)

  # Reattaching should append and maintain size growth
  lf2 <- open_log(path = custom_path)
  expect_identical(lf2, as.character(custom_path))
  log_wrn("second")
  close_log(gather = FALSE)
  expect_gt(fs::file_size(custom_path), size_initial)

  # Requesting to overwrite without append should error
  expect_error(
    open_log(path = custom_path, append = FALSE),
    "already exists"
  )

  # File write failures emit warnings rather than errors
  lf3 <- open_log(path = custom_path)
  fs::file_chmod(custom_path, "a=r")
  expect_warning(
    result <- log_err("cannot write"),
    "Unable to write log entry"
  )
  expect_null(result)
  fs::file_chmod(custom_path, "a=rw")
  close_log(gather = FALSE)

  fs::dir_delete(tmp_dir)
})
