#' Print the code to construct data
#'
#' @param vec print the call for this data to the console
#'
#' @importFrom stringr str_sub str_length
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
  cat("\n", txt, "\n\n")
}

