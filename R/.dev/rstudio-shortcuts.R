## Edit Key Files

usethis::edit_r_environ()

usethis::edit_r_profile()

## -------------------------------------------
## Package Development
## -------------------------------------------

rstudioapi::restartSession()

devtools::load_all()

devtools::document()

devtools::build()

devtools::test()

devtools::check()

pkg_coverage <- function() {
  cr <- covr::package_coverage()
  print(cr)
  return(invisible(cr))
}
pkg_coverage()


## -------------------------------------------
## Focus RStudio Panes (visible/focused)
## -------------------------------------------

##
## Terminal
##
# - Create a terminal if none exists
# - Make visible and change cursor focus to terminal

rstudioapi::terminalActivate()

##
## TODO: Console
##
# - If terminal or something else is active, first bring console to front
# - Then move focus to console (place cursor in console after making it visible)


##
## TODO: Editor
##
# Toggle cursor through source editor columns and all tabs in each
# - move cursor to first editor in first source column
# - navigate through editor tabs in column or move cursor to next column


## -------------------------------------------
## Change RStudio IDE Layout (4/3/2 columns)
## -------------------------------------------

## TODO: Set to default layout (2-col; topleft is source, bottomleft is console, topright contains environments and friends, bottom right is the files panel and friends)
## TODO: Shift to 3-Column Layout (adds additional source column to left side of the default 2-column layout)
## TODO: Shift to 4-Column Layout (adds 2 additional source columns to left side of the default 2-column layout)


## -------------------------------------------
## Switch RStudio Themes
## -------------------------------------------

switch_rsthemes <- function(type = "dark", which = NULL) {
  dark_themes <- c("Horizon Dark {rsthemes}", "Yule RStudio {rsthemes}", "Elm Dark {rsthemes}")
  light_themes <- c("Github {rsthemes}", "Flat White {rsthemes}", "Elm Light {rsthemes}")

  stopifnot("type must be 'dark' or 'light'" = type %in% c("dark", "light"))

  if (is.null(which)) {
    which <- switch(type,
      "dark" = sample(1:length(dark_themes), 1),
      "light" = sample(1:length(light_themes), 1),
    )
  }

  if (which < 1 | which > length(dark_themes)) {
    stop(paste("Which must be between 1 and", length(dark_themes)))
  }

  if (type == "dark") rstudioapi::applyTheme(dark_themes[which])
  if (type == "light") rstudioapi::applyTheme(light_themes[which])
}

switch_rsthemes() # random dark theme

switch_rsthemes("light") # random light theme

switch_rsthemes(which = 2) # second dark theme

switch_rsthemes("light", 1) # first light theme
