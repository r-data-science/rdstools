test_that("create_rdd writes output for an installed package", {
  skip_if_not_installed("rdocdump")
  skip_if_not_installed("fs")

  tmp <- fs::dir_create(fs::file_temp("rdd-test-"))
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)

  outdir <- fs::path(tmp, "out")
  cachedir <- fs::path(tmp, "cache")

  out <- create_rdd(
    pkg = "stats",
    cachedir = cachedir,
    outdir = outdir,
    clean = FALSE
  )

  expect_true(fs::file_exists(out))
  expect_match(fs::path_file(out), "^stats\\.txt$")
  expect_gt(length(readLines(out, n = 20, warn = FALSE)), 0)
  expect_true(fs::dir_exists(cachedir))
})

test_that("create_rdd cleans implicit cache when requested", {
  skip_if_not_installed("rdocdump")
  skip_if_not_installed("fs")

  tmp <- fs::dir_create(fs::file_temp("rdd-test-cache-"))
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)

  cache_path <- fs::path(tmp, "implicit-cache")
  old_cache <- Sys.getenv("RDD_CACHE", unset = NA_character_)
  if (is.na(old_cache)) {
    on.exit(Sys.unsetenv("RDD_CACHE"), add = TRUE)
  } else {
    on.exit(Sys.setenv(RDD_CACHE = old_cache), add = TRUE)
  }
  Sys.setenv(RDD_CACHE = cache_path)

  out <- create_rdd(
    pkg = "stats",
    outdir = fs::path(tmp, "out"),
    clean = TRUE
  )

  expect_true(fs::file_exists(out))
  expect_false(fs::dir_exists(cache_path))
})

test_that("create_rdd validates inputs", {
  expect_error(create_rdd(pkg = ""), "`pkg` must be")
  expect_error(create_rdd(pkg = ".", cachedir = ""), "`cachedir` must be")
  expect_error(create_rdd(pkg = ".", outdir = ""), "`outdir` must be")
  expect_error(create_rdd(pkg = ".", clean = NA), "`clean` must be")
  expect_error(
    create_rdd(pkg = file.path(tempdir(), "does-not-exist", "pkg")),
    "looks like a local path/archive"
  )
})
