doc.data.table <- function(DT,
                           name = NULL,
                           title = NULL,
                           descr = NULL,
                           src = NULL) {
  # Validate argument dataset
  if (!is.data.table(DT)) {
    stop("Argument DT is not a data.table", call. = FALSE)
  }

  if (!is.null(name)) {
    # valid name consists of only letters/numbers, and can include underscores
    # Additionally, name must start with a letter and ends with a letter or number
    pat <- "(?=^[A-Za-z])[A-Za-z0-9_]+(?<=[A-Za-z0-9])$"
    if (!str_detect(name, pat)) {
      stop("Name of dataset has invalid characters")
    }
  }

  # Replace null args with helpful placeholder text
  name[is.null(name)] <- "<NAME>"
  title[is.null(title)] <- "<TITLE>"
  descr[is.null(descr)] <- "<DESCRIBE>"
  src[is.null(src)] <- "<DATASOURCE>"


  gl <- function(txt) {
    env <- parent.frame(1)
    glue::glue(txt, .open = "%", .close = "%", .null = "<PLACEHOLDER>", .envir = env)
  }

  # Get header of documentation
  nrows <- nrow(DT)
  ncols <- ncol(DT)

  descr <- paste0(str_split_1(descr, "\n"), collapse = "\n#' ")
  a <- "#' %title%\n#'\n#' %descr%\n#'\n#' @format ## `%name%`\n"
  b <- "#' A data.table with %nrows% rows and %ncols% columns."
  header <- c(gl(a), gl(b))

  # Build documentation contents
  doc <- str_c(c(
    header,
    "#' \\describe{",
    unlist(lapply(names(DT), function(x) {
      col_class <- class(DT[, get(x)])[1]
      gl("#'   \\item{%x%}{[%col_class%] %NULL%}")
    })),
    gl("#' }\n#' @source %src%\n\"%name%\"")
  ), collapse = "\n")

  # write contents to tempfile and open in Rstudio
  fp <- tempfile()
  writeLines(doc, fp)

  if (rstudioapi::isAvailable()) {
    rstudioapi::navigateToFile(fp)
  } else {
    message("Documentation written to ", fp)
  }
}
