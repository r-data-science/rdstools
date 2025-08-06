#' Log Messages
#'
#' @param msg Main log message
#' @param add Additional details, typically a message from R
#' @param level param for internal function ..log
#' @param ... internally used by ..log
#' @param fnam name for log file
#' @param gather if TRUE, gather logs and return on close
#' @param jobId optional job number to group a set of log files
#' @param lf log file name
#' @param detail_parse if TRUE, will parse the details column in the logs
#' @param detail_sep Used to split the details column by separator (if `detail_parse` is TRUE)
#' @param ... additional arguments to pass to read_logs
#'
#' @import stringr
#' @import crayon
#' @import data.table
#'
#' @examples
#' log_err(msg = "My error Message", add = "Error information from R")
#' log_err(msg = "My error Message")
#'
#' @name log_funs
NULL

e <- new.env()
e$log_is_active <- FALSE
e$log_dir_path <- NULL
e$log_job_id <- ""
e$log_file_path <- NULL



#' @describeIn log_funs get log header
log_header <- function() {
  if (!requireNamespace("jsonlite", quietly = TRUE))
    stop("Logging requires package 'jsonlite'", call. = FALSE)
  hd_brdr <- stringr::str_pad("#", pad = "=", side = "right", width = 65)
  tmp1 <- jsonlite::toJSON(as.list(Sys.info()), pretty = TRUE, auto_unbox = TRUE)
  tmp2 <- jsonlite::unbox(jsonlite::prettify(tmp1, 3))
  tmp3 <- stringr::str_trim(stringr::str_remove_all(tmp2, "\\{|\n\\}\n"), "left")
  hd_body <- stringr::str_c("#   ", stringr::str_replace_all(tmp3, "\n", "\n#"))
  log_hdr <- stringr::str_c(hd_brdr, "\n", hd_body, "\n", hd_brdr, "\n")
  return(log_hdr)
}


#' @describeIn log_funs open log
#' @export
open_log <- function(fnam = NULL, jobId = NULL) {
  if (!requireNamespace("fs", quietly = TRUE))
    stop("Logging requires package 'fs'", call. = FALSE)
  if (!requireNamespace("jsonlite", quietly = TRUE))
    stop("Logging requires package 'jsonlite'", call. = FALSE)

  # Ensure jobId is a character string
  if (is.null(jobId)) jobId <- ""
  # Create log directory under the session temp directory to satisfy CRAN policy
  # Use a dedicated subdirectory ("rdstools_logs") to avoid cluttering tempdir()
  ldir <- fs::dir_create(fs::path(tempdir(), "rdstools_logs", jobId))
  # Determine log file name: if unspecified, create a temporary file within ldir
  if (is.null(fnam)) {
    fnam <- fs::path_file(fs::file_temp("log", tmp_dir = ldir))
  }
  fnam <- as.character(fnam)
  # Ensure file has .log extension
  fs::path_ext(fnam) <- ".log"

  ## set internal environ params
  ##
  e$log_job_id <- jobId
  e$log_is_active <- TRUE
  e$log_dir_path <- ldir
  e$log_file_path <- fs::path(ldir, fnam)

  if (fs::file_exists(e$log_file_path))
    stop("Log file at path exists and is not empty", call. = FALSE)

  fp <- fs::file_create(e$log_file_path, mode = "a=wrx")
  cat(log_header(), "\n", file = fp)
  log_ini("Log File Created", add = fp)

  invisible(as.character(fp))
}

#' @describeIn log_funs close log
#' @export
close_log <- function(gather = TRUE, ...) {
  if (!requireNamespace("fs", quietly = TRUE))
    stop("Logging requires package 'fs'", call. = FALSE)

  if (!e$log_is_active) {
    warning("No active log file to close")
  } else {

    log_end("Log File Closed", e$log_file_path)

    ## change file permissions to read only
    out <- fs::file_chmod(e$log_file_path, "a=r")
    if (gather)
      out <- setkey(read_logs(...), Level)[!c("OPEN", "CLOSE")][order(TimestampUTC)][]

    e$log_is_active <- FALSE
    e$log_dir_path <- NULL
    e$log_job_id <- ""
    e$log_file_path <- NULL

    return(invisible(out))
  }
  return(invisible(NULL))
}

#' @describeIn log_funs Internal function for logging
..log <- function(level = c("e", "i", "w", "s", "o", "c"), ...) {
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  if (level == "o") {
    LEV <- bgBlack(white('OPEN'))
    TST <- blue(as.character(ts))
    RLG <- bold(blue('<path>'))
  }

  if (level == "c") {
    LEV <- bgBlack(white('CLOSE'))
    TST <- blue(as.character(ts))
    RLG <- bold(blue('<path>'))
  }

  if (level == "e") {
    LEV <- bgRed(white('ERROR'))
    TST <- red(as.character(ts))
    RLG <- bold(red('<error>'))
  }

  if (level == "w") {
    LEV <- bgYellow(white('WARNING'))
    TST <- yellow(bold(as.character(ts)))
    RLG <- bold(yellow('<warn>'))
  }

  if (level == "i") {
    LEV <- bgBlue(white('INFO'))
    TST <- blue(bold(as.character(ts)))
    RLG <- bold(blue('<info>'))
  }

  if (level == "s") {
    LEV <- bgGreen(white('SUCCESS'))
    TST <- green(bold(as.character(ts)))
    RLG <- bold(green('<succ>'))
  }

  ARG <- list(...)

  msg  <- ARG[[1]]
  add  <- ARG[[2]]
  lf   <- ARG[[3]]
  echo <- ARG[[4]]

  if (!is.null(add) & is.null(msg))
    stop("Arg 'msg' is required when 'add' is given")

  if (!is.null(msg)) msg <- str_c(as.character(msg), collapse = " ")
  if (!is.null(add)) add <- str_c(as.character(add), collapse = " ")

  MSG <- cyan(italic(msg))
  ADD <- cyan(italic(add))
  SEP <- silver('|')
  P1 <- str_glue("{LEV}{SEP}{TST}")
  P2 <- str_glue("{SEP}{MSG}")
  P3 <- str_glue("{SEP}{RLG} {ADD}")

  LOG <- paste0(P1, P2, P3)

  if (has_color()) {
    cat(LOG, '\n')
  } else if (echo) {
    cat(strip_style(LOG), '\n')
  }

  ## if log file is given, append to it
  if ( !is.null(lf) ) {
    cat(str_trim(strip_style(LOG), "both"), "\n", file = lf, append = TRUE)
    lf <- as.character(lf)
  }
  # return null or log path invisibly
  return(invisible(lf))
}


#' @describeIn log_funs Log initiation (open)
log_ini <- function(msg = NULL, add = NULL) {
  ..log(level = "o", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Log closure
log_end <- function(msg = NULL, add = NULL) {
  ..log(level = "c", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Log error messages
#' @export
log_err <- function(msg = NULL, add = NULL) {
  ..log(level = "e", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Log warning
#' @export
log_wrn <- function(msg = NULL, add = NULL) {
  ..log(level = "w", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Log success
#' @export
log_suc <- function(msg = NULL, add = NULL) {
  ..log(level = "s", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Log info
#' @export
log_inf <- function(msg = NULL, add = NULL) {
  ..log(level = "i", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Read logs
#' @export
read_logs <- function(detail_parse = TRUE, detail_sep = "|", lf = NULL) {
  if (!requireNamespace("fs", quietly = TRUE))
    stop("Logging requires package 'fs'", call. = FALSE)

  lf[is.null(lf)] <- e$log_file_path

  log_cols <- c("Level", "TimestampUTC", "Message", "Detail")

  if (!is.null(lf)) {
    if (fs::file_exists(lf)) {

      tmp <- stringr::str_trim(readLines(lf), "right")
      lines <- tmp[stringr::str_which(tmp, "^OPEN"):length(tmp)]

      OUT <- setkey(setnames(
        as.data.table(stringr::str_split(lines, "\\|", n = 4, simplify = TRUE)),
        log_cols
      )[, TimestampUTC := as.POSIXct(TimestampUTC)], TimestampUTC)

      if (detail_parse) {
        OUT[, Detail := stringr::str_remove(Detail, "<(?<=\\<).+(?=\\>)> ")]
        OUT <- OUT[, c(.SD[, !"Detail"], transpose(stringr::str_split(Detail, stringr::fixed(detail_sep))))]
        setnames(OUT, 1:4, log_cols)
        setnames(OUT, c(log_cols, stringr::str_c("Detail.", seq_along(stringr::str_subset(names(OUT), "^V")))))
      }
    } else {
      stop("Unable to locate log: ", lf, call. = FALSE)
    }
    return(OUT[])
  } else {
    stop("log file path not found")
  }
}
