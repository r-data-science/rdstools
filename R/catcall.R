#' Print the code to construct data
#'
#' @param vec print the call for this data to the console
#' @param x An object produced by \code{catcall()}.
#' @param ... Additional arguments passed to \code{print()}.
#' @return An object of class \code{rdstools_catcall} containing the deparsed expression.
#'
#' @importFrom stringr str_sub str_length
#'
#' @family debugging
#' @concept debugging
#'
#' @examples
#' # Print the code to recreate a vector
#' x <- 1:3
#' catcall(x)
#'
#' @export
catcall <- function(vec) {
  tmp <- deparse1(call("{", vec))
  txt <- stringr::str_sub(tmp, 2, stringr::str_length(tmp) - 1)
  structure(txt, class = "rdstools_catcall")
}

#' @export
#' @rdname catcall
print.rdstools_catcall <- function(x, ...) {
  cat("\n", unclass(x), "\n\n", sep = "")
  invisible(x)
}
