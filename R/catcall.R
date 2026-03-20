#' Print the code to construct data
#'
#' Generates the code to recreate a data object and inserts it directly into
#' the active RStudio document at the current cursor position when RStudio is
#' available. Falls back to printing to the console otherwise.
#'
#' @param vec The data object whose construction code should be generated and inserted.
#' @param x An object produced by \code{catcall()}.
#' @param ... Additional arguments passed to \code{print()}.
#' @return Invisibly returns an object of class \code{rdstools_catcall} containing
#'   the deparsed expression. Called primarily for the side effect of inserting
#'   text into the active RStudio document (or printing to the console).
#'
#' @importFrom stringr str_sub str_length
#'
#' @family debugging
#' @concept debugging
#'
#' @examples
#' # Generate the code to recreate a vector (inserts into RStudio document when available)
#' x <- 1:3
#' catcall(x)
#'
#' @export
catcall <- function(vec) {
  tmp <- deparse1(call("{", vec))
  txt <- stringr::str_sub(tmp, 2, stringr::str_length(tmp) - 1)
  result <- structure(txt, class = "rdstools_catcall")
  if (rstudio_is_available()) {
    # The rdstools.insert_text_fun option allows overriding insertText for testing
    insert_fun <- base::getOption("rdstools.insert_text_fun", rstudioapi::insertText)
    insert_fun(unclass(result))
    return(invisible(result))
  }
  result
}

#' @export
#' @rdname catcall
print.rdstools_catcall <- function(x, ...) {
  cat("\n", unclass(x), "\n\n", sep = "")
  invisible(x)
}
