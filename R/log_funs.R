#' Log Messages
#'
#' @param msg Main log message
#' @param add Additional details, typically a message from R
#' @param level param for internal function ..log
#' @param ... internally used by ..log
#' @param fnam name for log file
#' @param gather if TRUE, gather logs and return on close
#' @param jobId optional job number to group a set of log files
#' @param dir Optional directory for log files. Defaults to \code{tempdir()}
#'   unless \code{options(rdstools.log_dir)} is set.
#' @param path Optional fully qualified path to the log file. Takes precedence
#'   over \code{dir}, and may also be supplied through
#'   \code{options(rdstools.log_path)} or the environment variable
#'   \code{RDSTOOLS_LOG_PATH}.
#' @param append Should an existing log file be appended to when \code{path}
#'   points at an existing file?
#' @param create_dir Should parent directories be created when they do not
#'   already exist? Defaults to \code{TRUE}.
#' @param lf log file name
#' @param detail_parse if TRUE, will parse the details column in the logs
#' @param detail_sep Used to split the details column by separator (if \code{detail_parse} is TRUE)
#' @param ... additional arguments to pass to read_logs
#'
#' @import stringr
#' @import crayon
#' @import data.table
#'
#' @family logging
#' @concept logging
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
#' @return A length-one character vector containing the formatted log header.
log_header <- function() {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Logging requires package 'jsonlite'", call. = FALSE)
  }
  hd_brdr <- stringr::str_pad("#", pad = "=", side = "right", width = 65)
  tmp1 <- jsonlite::toJSON(as.list(Sys.info()), pretty = TRUE, auto_unbox = TRUE)
  tmp2 <- jsonlite::unbox(jsonlite::prettify(tmp1, 3))
  tmp3 <- stringr::str_trim(stringr::str_remove_all(tmp2, "\\{|\n\\}\n"), "left")
  hd_body <- stringr::str_c("#   ", stringr::str_replace_all(tmp3, "\n", "\n#"))
  log_hdr <- stringr::str_c(hd_brdr, "\n", hd_body, "\n", hd_brdr, "\n")
  return(log_hdr)
}


#' @describeIn log_funs open log
#' @return Invisibly returns the path to the log file that was opened.
#' @export
open_log <- function(fnam = NULL,
                     jobId = NULL,
                     dir = NULL,
                     path = NULL,
                     append = TRUE,
                     create_dir = TRUE) {
  if (!requireNamespace("fs", quietly = TRUE)) {
    stop("Logging requires package 'fs'", call. = FALSE)
  }
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Logging requires package 'jsonlite'", call. = FALSE)
  }

  # Ensure jobId is a character string
  if (is.null(jobId)) jobId <- ""

  resolve_dir <- function(target_dir) {
    if (!is.null(target_dir) && nzchar(target_dir)) {
      target_dir <- fs::path_abs(target_dir)
      if (!fs::dir_exists(target_dir)) {
        if (create_dir) {
          fs::dir_create(target_dir, recurse = TRUE)
        } else {
          stop("Log directory does not exist: ", target_dir, call. = FALSE)
        }
      }
      return(target_dir)
    }
    NULL
  }

  # Check for explicit path via function argument, option, or env var
  if (is.null(path) || !nzchar(path)) {
    path <- base::getOption("rdstools.log_path")
  }
  if (is.null(path) || !nzchar(path)) {
    env_path <- Sys.getenv("RDSTOOLS_LOG_PATH", "")
    if (nzchar(env_path)) {
      path <- env_path
    }
  }

  new_file <- FALSE

  if (!is.null(path) && nzchar(path)) {
    path <- fs::path_norm(fs::path_abs(path))
    parent_dir <- fs::path_dir(path)
    if (!fs::dir_exists(parent_dir)) {
      if (create_dir) {
        fs::dir_create(parent_dir, recurse = TRUE)
      } else {
        stop("Log directory does not exist: ", parent_dir, call. = FALSE)
      }
    }
    target_path <- path
  } else {
    # Determine directory priority: argument, option, then tempdir default
    dir <- resolve_dir(dir)
    if (is.null(dir)) {
      dir_option <- base::getOption("rdstools.log_dir")
      dir <- resolve_dir(dir_option)
    }
    if (is.null(dir)) {
      dir <- fs::path(tempdir(), "rdstools_logs", jobId)
      dir <- resolve_dir(dir)
    }

    # Determine log file name: if unspecified, create a temporary file within dir
    if (is.null(fnam)) {
      fnam <- fs::path_file(fs::file_temp("log", tmp_dir = dir))
    }
    fnam <- as.character(fnam)
    if (!nzchar(fs::path_ext(fnam))) {
      fnam <- paste0(fnam, ".log")
    }
    target_path <- fs::path(dir, fnam)
  }

  target_path <- fs::path_norm(target_path)

  if (fs::file_exists(target_path)) {
    if (!append) {
      stop("Log file already exists: ", target_path, call. = FALSE)
    }
    tryCatch(fs::file_chmod(target_path, "a=rw"),
      error = function(err) {
        warning("Unable to set log file writable: ",
          conditionMessage(err),
          call. = FALSE
        )
        NULL
      }
    )
  } else {
    new_file <- TRUE
    fs::file_create(target_path, mode = "a=wrx")
    cat(log_header(), "\n", file = target_path)
  }

  # Update internal state only after file is ready
  e$log_job_id <- jobId
  e$log_is_active <- TRUE
  e$log_dir_path <- fs::path_dir(target_path)
  e$log_file_path <- as.character(target_path)

  ini_msg <- if (new_file) "Log File Created" else "Log File Reattached"
  log_ini(ini_msg, add = target_path)

  invisible(as.character(target_path))
}

#' @describeIn log_funs close log
#' @return Returns a \code{data.table} of log entries when \code{gather = TRUE}; otherwise invisibly returns \code{NULL}.
#' @export
close_log <- function(gather = TRUE, ...) {
  if (!requireNamespace("fs", quietly = TRUE)) {
    stop("Logging requires package 'fs'", call. = FALSE)
  }

  if (!e$log_is_active) {
    warning("No active log file to close")
  } else {
    log_path <- e$log_file_path
    log_end("Log File Closed", log_path)

    ## change file permissions to read only
    tryCatch(fs::file_chmod(log_path, "a=r"),
      error = function(err) {
        warning("Unable to update permissions on log file: ",
          conditionMessage(err),
          call. = FALSE
        )
        NULL
      }
    )
    if (gather) {
      out <- tryCatch(
        setkey(read_logs(...), Level)[!c("OPEN", "CLOSE")][order(TimestampUTC)][],
        error = function(err) {
          warning("Unable to gather log entries: ", conditionMessage(err), call. = FALSE)
          NULL
        }
      )
    } else {
      out <- log_path
    }

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
    LEV <- bgBlack(white("OPEN"))
    TST <- blue(as.character(ts))
    RLG <- bold(blue("<path>"))
  }

  if (level == "c") {
    LEV <- bgBlack(white("CLOSE"))
    TST <- blue(as.character(ts))
    RLG <- bold(blue("<path>"))
  }

  if (level == "e") {
    LEV <- bgRed(white("ERROR"))
    TST <- red(as.character(ts))
    RLG <- bold(red("<error>"))
  }

  if (level == "w") {
    LEV <- bgYellow(white("WARNING"))
    TST <- yellow(bold(as.character(ts)))
    RLG <- bold(yellow("<warn>"))
  }

  if (level == "i") {
    LEV <- bgBlue(white("INFO"))
    TST <- blue(bold(as.character(ts)))
    RLG <- bold(blue("<info>"))
  }

  if (level == "s") {
    LEV <- bgGreen(white("SUCCESS"))
    TST <- green(bold(as.character(ts)))
    RLG <- bold(green("<succ>"))
  }

  ARG <- list(...)

  msg <- ARG[[1]]
  add <- ARG[[2]]
  lf <- ARG[[3]]
  echo <- ARG[[4]]

  if (!is.null(add) & is.null(msg)) {
    stop("Arg 'msg' is required when 'add' is given")
  }

  if (!is.null(msg)) msg <- str_c(as.character(msg), collapse = " ")
  if (!is.null(add)) add <- str_c(as.character(add), collapse = " ")

  MSG <- cyan(italic(msg))
  ADD <- cyan(italic(add))
  SEP <- silver("|")
  P1 <- str_glue("{LEV}{SEP}{TST}")
  P2 <- str_glue("{SEP}{MSG}")
  P3 <- str_glue("{SEP}{RLG} {ADD}")

  LOG <- paste0(P1, P2, P3)

  if (echo) {
    output <- if (has_color()) LOG else strip_style(LOG)
    message(output)
  }

  ## if log file is given, append to it
  if (!is.null(lf)) {
    lf_chr <- as.character(lf)
    write_ok <- tryCatch(
      {
        con <- suppressWarnings(file(lf_chr, open = "at"))
        on.exit(close(con), add = TRUE)
        writeLines(str_trim(strip_style(LOG), "both"), con)
        TRUE
      },
      error = function(err) {
        warning(
          sprintf(
            "Unable to write log entry to '%s': %s",
            lf_chr,
            conditionMessage(err)
          ),
          call. = FALSE
        )
        FALSE
      }
    )
    if (!write_ok) {
      lf_chr <- NULL
    }
  } else {
    lf_chr <- NULL
  }
  # return null or log path invisibly
  return(invisible(lf_chr))
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
#' @return Invisibly returns the active log file path, if available.
#' @export
log_err <- function(msg = NULL, add = NULL) {
  ..log(level = "e", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Log warning
#' @return Invisibly returns the active log file path, if available.
#' @export
log_wrn <- function(msg = NULL, add = NULL) {
  ..log(level = "w", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Log success
#' @return Invisibly returns the active log file path, if available.
#' @export
log_suc <- function(msg = NULL, add = NULL) {
  ..log(level = "s", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Log info
#' @return Invisibly returns the active log file path, if available.
#' @export
log_inf <- function(msg = NULL, add = NULL) {
  ..log(level = "i", msg, add, e$log_file_path, echo = TRUE)
}

#' @describeIn log_funs Read logs
#' @return Returns a \code{data.table} with log details parsed into columns.
#' @export
read_logs <- function(detail_parse = TRUE, detail_sep = "|", lf = NULL) {
  if (!requireNamespace("fs", quietly = TRUE)) {
    stop("Logging requires package 'fs'", call. = FALSE)
  }

  lf[is.null(lf)] <- e$log_file_path

  log_cols <- c("Level", "TimestampUTC", "Message", "Detail")

  if (!is.null(lf)) {
    if (fs::file_exists(lf)) {
      tmp <- stringr::str_trim(readLines(lf), "right")
      open_idx <- stringr::str_which(tmp, "^OPEN")
      if (length(open_idx)) {
        lines <- tmp[seq.int(min(open_idx), length(tmp))]
      } else {
        lines <- tmp
      }

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

#' @describeIn log_funs Check if a log file is currently active
#' @return A logical scalar indicating whether a log file is active.
#' @export
log_is_active <- function() {
  isTRUE(e$log_is_active) && !is.null(e$log_file_path)
}
