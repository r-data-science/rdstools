#' Fetch Query Data
#'
#' Send Query and Fetch Until Complete
#'
#' @param cn connection object
#' @param qry query to iterate and fetch until completion
#' @param n total rows to get in each iteration. If NULL (default) then value to be used is 1M
#'
#' @importFrom data.table setDT rbindlist
#' @importFrom DBI dbSendQuery dbClearResult dbFetch dbHasCompleted
#'
#' @return Object of class data.table
#'
#' @name database_utils
NULL

#' @describeIn database_utils internal function to iterate a query over a connection
#' @export
dbQueryFetch <- function(cn, qry, n = NULL) {
  n <- ifelse(is.null(n), 10^6, n)
  res <- DBI::dbSendQuery(cn, qry)
  on.exit(DBI::dbClearResult(res))
  DT <- data.table::setDT(DBI::dbFetch(res, 1))
  iter <- 0
  while (!DBI::dbHasCompleted(res)) {
    iter <- iter + 1
    cat("Query iteration:", iter, "\n")
    DT <- data.table::rbindlist(list(DT, data.table::setDT(DBI::dbFetch(res, n))))
  }
  return(DT[])
}
