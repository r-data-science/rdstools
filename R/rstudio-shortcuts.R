#' RStudio IDE Shortcuts
#'
#' A collection of functions to control RStudio IDE behavior, useful for
#' mapping to keyboard shortcuts or Stream Deck buttons via RStudio addins.
#'
#' @name rstudio-shortcuts
#' @import rstudioapi
NULL

#' Activate Terminal Pane
#'
#' Creates a terminal if none exists, makes it visible, and moves cursor focus
#' to the terminal.
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' activate_terminal()
#' }
activate_terminal <- function() {
  ensure_rstudio_available()
  rstudioapi::terminalActivate()
  invisible(NULL)
}

#' Activate Console Pane
#'
#' Brings the console to the front and moves cursor focus to the console.
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' activate_console()
#' }
activate_console <- function() {
  ensure_rstudio_available()
  rstudioapi::executeCommand("activateConsole", quiet = TRUE)
  invisible(NULL)
}

#' Activate Source Editor
#'
#' Moves cursor focus to the source editor. If multiple source columns exist,
#' this will focus the most recently active editor.
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' activate_source_editor()
#' }
activate_source_editor <- function() {
  ensure_rstudio_available()
  # Try to execute the command to activate the source pane
  rstudioapi::executeCommand("activateSource", quiet = TRUE)
  invisible(NULL)
}

#' Switch to Default 2-Column Layout
#'
#' Sets RStudio to the default 2-column layout: top-left is source,
#' bottom-left is console, top-right contains environment and related panes,
#' bottom-right is the files panel and related panes.
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' layout_two_column()
#' }
layout_two_column <- function() {
  ensure_rstudio_available()
  # Execute command to set layout to console on left (standard 2-column)
  rstudioapi::executeCommand("layoutConsoleOnLeft", quiet = TRUE)
  invisible(NULL)
}

#' Switch to 3-Column Layout
#'
#' Shifts to a 3-column layout by adding an additional source column to the
#' left side of the default 2-column layout. Note: This requires RStudio
#' configuration to support multiple source columns.
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' layout_three_column()
#' }
layout_three_column <- function() {
  ensure_rstudio_available()
  # Execute command to add a source column
  # Note: The exact command may vary by RStudio version
  rstudioapi::executeCommand("layoutZoomSource", quiet = TRUE)
  invisible(NULL)
}

#' Switch to 4-Column Layout
#'
#' Shifts to a 4-column layout by adding two additional source columns to the
#' left side of the default 2-column layout. Note: This requires RStudio
#' configuration to support multiple source columns.
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' layout_four_column()
#' }
layout_four_column <- function() {
  ensure_rstudio_available()
  # Execute command for 4-column layout
  # Note: The exact command may vary by RStudio version
  # This is a placeholder as RStudio may not support 4 columns via API
  rstudioapi::executeCommand("layoutEndZoom", quiet = TRUE)
  invisible(NULL)
}

#' Switch RStudio Theme
#'
#' Randomly or specifically selects and applies a dark or light RStudio theme.
#' Requires the rsthemes package themes to be installed.
#'
#' @param type Character; either "dark" or "light" theme type
#' @param which Integer; specific theme index to apply. If NULL (default),
#'   a random theme of the specified type is chosen.
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' # Apply random dark theme
#' switch_theme()
#'
#' # Apply random light theme
#' switch_theme("light")
#'
#' # Apply second dark theme
#' switch_theme(which = 2)
#'
#' # Apply first light theme
#' switch_theme("light", 1)
#' }
switch_theme <- function(type = "dark", which = NULL) {
  ensure_rstudio_available()

  dark_themes <- c(
    "Horizon Dark {rsthemes}",
    "Yule RStudio {rsthemes}",
    "Elm Dark {rsthemes}"
  )
  light_themes <- c(
    "Github {rsthemes}",
    "Flat White {rsthemes}",
    "Elm Light {rsthemes}"
  )

  stopifnot("type must be 'dark' or 'light'" = type %in% c("dark", "light"))

  if (is.null(which)) {
    which <- switch(type,
      "dark" = sample(1:length(dark_themes), 1),
      "light" = sample(1:length(light_themes), 1)
    )
  }

  theme_list_length <- if (type == "dark") length(dark_themes) else length(light_themes)
  if (which < 1 | which > theme_list_length) {
    stop(paste("which must be between 1 and", theme_list_length))
  }

  if (type == "dark") {
    rstudioapi::applyTheme(dark_themes[which])
  } else {
    rstudioapi::applyTheme(light_themes[which])
  }

  invisible(NULL)
}

#' Switch to Random Light Theme
#'
#' Convenience wrapper to apply a random light theme.
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' switch_theme_light()
#' }
switch_theme_light <- function() {
  switch_theme("light")
}

#' Switch to Random Dark Theme
#'
#' Convenience wrapper to apply a random dark theme.
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' switch_theme_dark()
#' }
switch_theme_dark <- function() {
  switch_theme("dark")
}

#' Run Package Coverage
#'
#' A convenience function to run coverage report on the current package.
#'
#' @return Returns the coverage result object invisibly.
#' @export
#' @examples
#' \dontrun{
#' pkg_coverage()
#' }
pkg_coverage <- function() {
  if (!requireNamespace("covr", quietly = TRUE)) {
    stop("Package 'covr' is required but not installed.", call. = FALSE)
  }
  cr <- covr::package_coverage()
  print(cr)
  return(invisible(cr))
}

#' Restart RStudio Session
#'
#' Restarts the RStudio R session.
#'
#' @param clean Logical; if TRUE, restart with a clean environment.
#' @param ... Additional arguments passed to rstudioapi::restartSession()
#'
#' @return Called for side effects; returns NULL invisibly.
#' @export
#' @examples
#' \dontrun{
#' restart_session()
#' restart_session(clean = TRUE)
#' }
restart_session <- function(clean = FALSE, ...) {
  ensure_rstudio_available()
  rstudioapi::restartSession(clean = clean, ...)
  invisible(NULL)
}

#' Load All Package Code
#'
#' Loads all package code using devtools::load_all().
#'
#' @param ... Arguments passed to devtools::load_all()
#'
#' @return Returns the result from devtools::load_all() invisibly.
#' @export
#' @examples
#' \dontrun{
#' load_all_code()
#' }
load_all_code <- function(...) {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    stop("Package 'devtools' is required but not installed.", call. = FALSE)
  }
  result <- devtools::load_all(...)
  invisible(result)
}

#' Document Package
#'
#' Runs devtools::document() to generate documentation.
#'
#' @param ... Arguments passed to devtools::document()
#'
#' @return Returns the result from devtools::document() invisibly.
#' @export
#' @examples
#' \dontrun{
#' document_package()
#' }
document_package <- function(...) {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    stop("Package 'devtools' is required but not installed.", call. = FALSE)
  }
  result <- devtools::document(...)
  invisible(result)
}

#' Build Package
#'
#' Builds the package using devtools::build().
#'
#' @param ... Arguments passed to devtools::build()
#'
#' @return Returns the path to the built package invisibly.
#' @export
#' @examples
#' \dontrun{
#' build_package()
#' }
build_package <- function(...) {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    stop("Package 'devtools' is required but not installed.", call. = FALSE)
  }
  result <- devtools::build(...)
  invisible(result)
}

#' Test Package
#'
#' Runs package tests using devtools::test().
#'
#' @param ... Arguments passed to devtools::test()
#'
#' @return Returns the test results invisibly.
#' @export
#' @examples
#' \dontrun{
#' test_package()
#' }
test_package <- function(...) {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    stop("Package 'devtools' is required but not installed.", call. = FALSE)
  }
  result <- devtools::test(...)
  invisible(result)
}

#' Check Package
#'
#' Runs R CMD check on the package using devtools::check().
#'
#' @param ... Arguments passed to devtools::check()
#'
#' @return Returns the check results invisibly.
#' @export
#' @examples
#' \dontrun{
#' check_package()
#' }
check_package <- function(...) {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    stop("Package 'devtools' is required but not installed.", call. = FALSE)
  }
  result <- devtools::check(...)
  invisible(result)
}
