#' Database Connection
#'
#' @param cfg e.g. prod, devel
#' @param dbin database name
#' @param conn_string Optional. Given priority when provided
#' @param cn connection object to close
#'
#' @return connection
#'
#' @name database
NULL



#' @describeIn database connect
#' @export
dbc <- function(cfg = NULL, dbin = NULL, conn_string = NULL) {
  ## Check For Deps
  if (!requireNamespace("DBI", quietly = TRUE)) {
    stop("'DBI' not available", call. = FALSE)
  } else if (!requireNamespace("fs", quietly = TRUE)) {
    stop("'fs' not available", call. = FALSE)
  } else if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("'yaml' not available", call. = FALSE)
  } else if (!requireNamespace("RPostgres", quietly = TRUE)) {
    stop("'RPostgres' not available", call. = FALSE)
  }

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
dbd <- function(cn) {
  if (!requireNamespace("DBI", quietly = TRUE)) {
    stop("'DBI' not available", call. = FALSE)
  }
  DBI::dbDisconnect(cn)
}

#' @describeIn database TBD
ld_odbc <- function(cfg, dbin) {
  cfg <- match.arg(cfg, c("prod2", "dev2")) # make sure cfg matches one
  xdfp <- function(fn) {
    fs::path_package("rdtools", "extdata", fs::path_ext(fn), fn)
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
