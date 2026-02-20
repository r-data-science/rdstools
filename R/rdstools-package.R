#' rdstools: Data Science Development Tools for R
#'
#' Utilities that support data-science workflows with helpers for structured
#' logging, reproducible debugging, package development automation, and
#' machine-readable package dumps for LLM-driven tooling.
#'
#' @section Feature Areas:
#' \itemize{
#'   \item \strong{Logging}: Colorized console logging with optional persistent
#'   file output via \code{open_log()}, \code{log_*()}, and \code{close_log()}.
#'   \item \strong{Debugging}: Reproducible object reconstruction via
#'   \code{catcall()}.
#'   \item \strong{Development}: RStudio addins and wrappers for common
#'   development commands (\code{document_package()}, \code{test_package()},
#'   \code{check_package()}, and related helpers).
#'   \item \strong{LLM package dumps}: \code{create_rdd()} generates package
#'   text artifacts from source/docs/vignettes using \pkg{rdocdump}.
#' }
#'
#' @docType package
#' @name rdstools-package
#' @aliases rdstools
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom data.table :=
#' @importFrom data.table .BY
#' @importFrom data.table .EACHI
#' @importFrom data.table .GRP
#' @importFrom data.table .I
#' @importFrom data.table .N
#' @importFrom data.table .NGRP
#' @importFrom data.table .SD
#' @importFrom data.table data.table
## usethis namespace: end
NULL


globalVariables(c("Detail", "Level", "TimestampUTC"))
