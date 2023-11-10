#' Database Connection
#'
#' @param cfg e.g. prod, devel
#' @param dbin database name
#' @param conn_string Optional. Given priority when provided
#' @param cn connection object to close
#'
#' @importFrom DBI dbConnect dbDisconnect
#' @importFrom fs path_package path_ext
#' @importFrom yaml yaml.load_file
#' @importFrom RPostgres Postgres
#'
#' @return connection
#'
#' @name database
NULL

#' @describeIn database connect
#' @export
dbc <- function(cfg = NULL, dbin = NULL, conn_string = NULL) {
  if (!is.null(conn_string)) {
    args <- strsplit(strsplit(conn_string, ";")[[1]], "=")
    vals <- lapply(args, `[`, 2)
    names(vals) <- lapply(args, `[`, 1)
    do.call(DBI::dbConnect, c(RPostgres::Postgres(), vals))
  } else {
    do.call(DBI::dbConnect, ld_odbc(cfg, dbin))
  }
}



#' @describeIn database disconnect
#' @export
dbd <- function(cn) DBI::dbDisconnect(cn)

#' @describeIn database TBD
#' @export
ld_odbc <- function(cfg, dbin) {
  cfg <- match.arg(cfg, c("prod2", "dev2")) # make sure cfg matches one
  xdfp <- function(fn) {
    fs::path_package("hcatools", "extdata", fs::path_ext(fn), fn)
  }

  ## load db connection parameters
  ll <- yaml::yaml.load_file(xdfp("odbc.yml"), eval.expr = TRUE)

  ## Structure args for DBI::dbConnect
  cn_args <- c(
    ll[["host"]][[cfg]]["host"],
    ll[["host"]][[cfg]]["password"],
    ll[["args"]],
    ll[["options"]],
    ll[["user"]],
    list(dbname = dbin)
  )
  return(cn_args)
}
