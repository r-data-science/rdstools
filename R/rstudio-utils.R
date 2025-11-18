# Internal helpers for RStudio-specific functionality

rstudio_is_available <- function() {
  mock_is_rs <- base::getOption("rdstools.mock_rstudio_available", NULL)
  if (is.null(mock_is_rs)) {
    rstudioapi::isAvailable()
  } else {
    isTRUE(mock_is_rs)
  }
}

ensure_rstudio_available <- function() {
  if (!rstudio_is_available()) {
    stop("This function requires RStudio", call. = FALSE)
  }
  invisible(TRUE)
}
