#' Print the code to construct data
#'
#' @param vec print the call for this data to the console
#'
#' @importFrom stringr str_sub str_length
#'
#' @export
catcall <- function(vec) {
  tmp <- deparse1(call("{", vec))
  txt <- stringr::str_sub(tmp, 2, stringr::str_length(tmp) - 1)
  cat("\n", txt, "\n\n")
}

