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

test_that("create_rdd preserves dots in installed package names", {
  skip_if_not_installed("rdocdump")
  skip_if_not_installed("fs")

  dotted_pkgs <- rownames(utils::installed.packages())
  dotted_pkgs <- dotted_pkgs[grepl("\\.", dotted_pkgs)]
  skip_if(length(dotted_pkgs) == 0L, "No installed package with a dot in the name.")

  pkg <- dotted_pkgs[[1]]
  tmp <- fs::dir_create(fs::file_temp("rdd-test-dot-name-"))
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)

  out <- suppressWarnings(
    create_rdd(
      pkg = pkg,
      cachedir = fs::path(tmp, "cache"),
      outdir = fs::path(tmp, "out"),
      clean = FALSE
    )
  )

  expect_true(fs::file_exists(out))
  expect_identical(fs::path_file(out), paste0(pkg, ".txt"))
})

test_that(".create_rdd_output_stem preserves names and strips archive suffixes", {
  expect_identical(
    rdstools:::.create_rdd_output_stem("R.utils", is_local = FALSE, is_local_file = FALSE),
    "R.utils"
  )
  expect_identical(
    rdstools:::.create_rdd_output_stem("/tmp/mypkg_1.0.0.tar.gz", is_local = TRUE, is_local_file = TRUE),
    "mypkg_1.0.0"
  )
  expect_identical(
    rdstools:::.create_rdd_output_stem("/tmp/mypkg.local", is_local = TRUE, is_local_file = FALSE),
    "mypkg.local"
  )
  expect_identical(
    rdstools:::.create_rdd_output_stem("/tmp/mypkg.zip", is_local = TRUE, is_local_file = TRUE),
    "mypkg"
  )
})

test_that("create_rdd prefers AGENTS_SCRATCH for default output root", {
  skip_if_not_installed("rdocdump")
  skip_if_not_installed("fs")
  skip_if_not_installed("withr")

  tmp <- fs::dir_create(fs::file_temp("rdd-test-env-priority-"))
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)

  scratch_root <- fs::path(tmp, "scratch")
  agents_home <- fs::path(tmp, "agents-home")
  ws_root <- fs::path(tmp, "ws-root")
  home_root <- fs::path(tmp, "home")

  withr::local_envvar(c(
    AGENTS_SCRATCH = scratch_root,
    AGENTS_HOME = agents_home,
    WS_ROOT = ws_root,
    HOME = home_root
  ))

  out <- create_rdd(
    pkg = "stats",
    cachedir = fs::path(tmp, "cache"),
    outdir = NULL,
    clean = FALSE
  )

  expected_dir <- fs::path_abs(fs::path(scratch_root, "llm-docs", "rdd"))
  actual_dir <- fs::path_abs(fs::path_dir(out))

  expect_true(fs::file_exists(out))
  expect_identical(actual_dir, expected_dir)
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
