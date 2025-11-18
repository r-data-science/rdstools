test_that("RStudio shortcuts functions exist and are callable", {
  # Test that all exported functions exist
  expect_true(exists("activate_terminal"))
  expect_true(exists("activate_console"))
  expect_true(exists("activate_source_editor"))
  expect_true(exists("layout_two_column"))
  expect_true(exists("layout_three_column"))
  expect_true(exists("layout_four_column"))
  expect_true(exists("switch_theme"))
  expect_true(exists("switch_theme_dark"))
  expect_true(exists("switch_theme_light"))
  expect_true(exists("restart_session"))
  expect_true(exists("load_all_code"))
  expect_true(exists("document_package"))
  expect_true(exists("build_package"))
  expect_true(exists("test_package"))
  expect_true(exists("check_package"))
  expect_true(exists("pkg_coverage"))
})

test_that("switch_theme validates input correctly", {
  # Mock RStudio availability
  old_opts <- options(rdstools.mock_rstudio_available = FALSE)
  on.exit(options(old_opts), add = TRUE)
  
  # Should fail when RStudio is not available
  expect_error(
    switch_theme("dark"),
    "This function requires RStudio"
  )
  
  # Enable mock RStudio
  options(rdstools.mock_rstudio_available = TRUE)
  
  # Test input validation (will still fail due to missing applyTheme, but validates type)
  expect_error(
    switch_theme("invalid"),
    "type must be 'dark' or 'light'"
  )
  
  expect_error(
    switch_theme("dark", which = 10),
    "which must be between"
  )
})

test_that("RStudio pane functions handle missing RStudio", {
  # Test that functions check for RStudio availability
  # These will fail in test environment but should produce expected error
  expect_error(
    activate_terminal(),
    "This function requires RStudio"
  )
  
  expect_error(
    activate_console(),
    "This function requires RStudio"
  )
  
  expect_error(
    activate_source_editor(),
    "This function requires RStudio"
  )
})

test_that("Layout functions handle missing RStudio", {
  expect_error(
    layout_two_column(),
    "This function requires RStudio"
  )
  
  expect_error(
    layout_three_column(),
    "This function requires RStudio"
  )
  
  expect_error(
    layout_four_column(),
    "This function requires RStudio"
  )
})

test_that("Development helper functions check for dependencies", {
  # pkg_coverage should check for covr
  if (!requireNamespace("covr", quietly = TRUE)) {
    expect_error(
      pkg_coverage(),
      "Package 'covr' is required"
    )
  }
  
  # load_all_code should check for devtools
  if (!requireNamespace("devtools", quietly = TRUE)) {
    expect_error(
      load_all_code(),
      "Package 'devtools' is required"
    )
  }
  
  # document_package should check for devtools
  if (!requireNamespace("devtools", quietly = TRUE)) {
    expect_error(
      document_package(),
      "Package 'devtools' is required"
    )
  }
})

test_that("Theme wrapper functions call switch_theme correctly", {
  # Mock RStudio to prevent actual theme switching
  old_opts <- options(rdstools.mock_rstudio_available = FALSE)
  on.exit(options(old_opts), add = TRUE)
  
  # Both wrappers should error when RStudio not available
  expect_error(
    switch_theme_dark(),
    "This function requires RStudio"
  )
  
  expect_error(
    switch_theme_light(),
    "This function requires RStudio"
  )
})
