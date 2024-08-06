#' Internal Function for Data.Tables
#'
#' Print progress of group based calculations when the by column is specified
#'
#' @param n print every n iterations
#'
#' @export
.catprogress <- function(n) {
  par_env <- parent.frame()
  G <- par_env$`.GRP` - 1
  NG <- par_env$`.NGRP`
  if (G %% n == 0)
    cat("progress...", paste0(round(G / NG, 2) * 100, "%"), "\n")
}
