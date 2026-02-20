#' Create a Machine-Readable Package Dump for LLM Tools
#'
#' Create a text artifact from package documentation, vignettes, and source code
#' using \code{rdocdump::rdd_to_txt()}. Local paths and installed packages are
#' used directly; package names not installed locally are fetched from CRAN.
#'
#' @details Package resolution follows this order:
#' \itemize{
#'   \item Existing local directory/archive path in \code{pkg}:
#'   use local source.
#'   \item Installed package name: use installed package files.
#'   \item Uninstalled package name: fetch package source from CRAN.
#' }
#'
#' The output text includes docs, vignettes, and code (\code{content = "all"})
#' and keeps both cached archive and extracted files
#' (\code{keep_files = "both"}).
#' Set \code{clean = TRUE} with implicit cache selection to remove temporary
#' cache files when the function exits.
#'
#' @param pkg A package name, local package directory, or package archive path.
#' @param cachedir Optional cache directory for \pkg{rdocdump}. When omitted,
#'   this function uses \code{RDD_CACHE} or \code{tempdir()}.
#' @param outdir Optional output directory. When omitted, this function resolves
#'   the directory from \code{AGENTS_SCRATCH}, then \code{AGENTS_HOME}, then
#'   \code{WS_ROOT}, then \code{HOME}, and appends \code{llm-docs/rdd}.
#' @param clean Logical; when \code{TRUE} and \code{cachedir} is omitted, remove
#'   the cache directory created for this call on exit.
#'
#' @return A length-one character vector containing the path to the generated
#'   \code{.txt} file.
#'
#' @family development
#' @concept development
#' @concept llm
#'
#' @examples
#' \dontrun{
#' # 1) Dump an installed package
#' out_installed <- create_rdd("stats")
#' readLines(out_installed, n = 10)
#'
#' # 2) Dump a local package source directory
#' out_local <- create_rdd(
#'   pkg = "/path/to/local/package",
#'   cachedir = tempdir(),
#'   outdir = file.path(tempdir(), "llm-docs", "rdd"),
#'   clean = FALSE
#' )
#' readLines(out_local, n = 10)
#'
#' # 3) Use environment-variable defaults for output location
#' Sys.setenv(AGENTS_SCRATCH = tempdir())
#' out_env <- create_rdd("rdstools")
#' readLines(out_env, n = 5)
#' }
#'
#' @export
create_rdd <- function(pkg, cachedir = NULL, outdir = NULL, clean = TRUE) {
  if (!requireNamespace("fs", quietly = TRUE)) {
    stop("create_rdd() requires package 'fs'.", call. = FALSE)
  }
  if (!requireNamespace("rdocdump", quietly = TRUE)) {
    stop("create_rdd() requires package 'rdocdump'.", call. = FALSE)
  }

  if (!is.character(pkg) || length(pkg) != 1L || is.na(pkg) || !nzchar(pkg)) {
    stop("`pkg` must be a single non-empty character string.", call. = FALSE)
  }
  invalid_cachedir <- !is.character(cachedir) ||
    length(cachedir) != 1L ||
    is.na(cachedir) ||
    !nzchar(cachedir)
  if (!is.null(cachedir) && invalid_cachedir) {
    stop(
      "`cachedir` must be NULL or a single non-empty character string.",
      call. = FALSE
    )
  }
  invalid_outdir <- !is.character(outdir) ||
    length(outdir) != 1L ||
    is.na(outdir) ||
    !nzchar(outdir)
  if (!is.null(outdir) && invalid_outdir) {
    stop(
      "`outdir` must be NULL or a single non-empty character string.",
      call. = FALSE
    )
  }
  if (!is.logical(clean) || length(clean) != 1L || is.na(clean)) {
    stop("`clean` must be either TRUE or FALSE.", call. = FALSE)
  }

  old_cache <- base::getOption("rdocdump.cache_path", NULL)
  on.exit(options(rdocdump.cache_path = old_cache), add = TRUE)

  cache_root <- cachedir
  if (is.null(cache_root)) {
    cache_root <- Sys.getenv("RDD_CACHE", unset = tempdir())
  }
  cache_path <- cache_root |>
    fs::path_expand() |>
    fs::path_abs() |>
    fs::path_norm()

  fs::dir_create(cache_path, recurse = TRUE)
  rdocdump::rdd_set_cache_path(cache_path)

  if (is.null(cachedir) && isTRUE(clean)) {
    on.exit(unlink(cache_path, recursive = TRUE, force = TRUE), add = TRUE)
  }

  is_local <- fs::dir_exists(pkg) || fs::file_exists(pkg)
  pkg_input <- pkg
  if (is_local) {
    pkg_input <- pkg |>
      fs::path_expand() |>
      fs::path_abs() |>
      fs::path_norm()
  }

  looks_like_path <- grepl("[/\\\\]", pkg) ||
    grepl("\\.tar\\.gz$", pkg, ignore.case = TRUE)
  if (!is_local && looks_like_path) {
    stop(
      "`pkg` looks like a local path/archive but does not exist: ",
      pkg,
      call. = FALSE
    )
  }

  is_pkg_name <- !is_local &&
    !grepl("[/\\\\]", pkg_input) &&
    !grepl("\\.tar\\.gz$", pkg_input, ignore.case = TRUE)
  is_installed <- is_pkg_name && requireNamespace(pkg_input, quietly = TRUE)

  if (is.null(outdir)) {
    output_root <- Sys.getenv("AGENTS_SCRATCH", unset = "")
    if (!nzchar(output_root)) {
      output_root <- Sys.getenv("AGENTS_HOME", unset = "")
    }
    if (!nzchar(output_root)) output_root <- Sys.getenv("WS_ROOT", unset = "")
    if (!nzchar(output_root)) output_root <- Sys.getenv("HOME", unset = "~")
    outdir <- fs::path(output_root, "llm-docs", "rdd")
  }

  output_dir <- outdir |>
    fs::path_expand() |>
    fs::path_abs() |>
    fs::path_norm()
  fs::dir_create(output_dir, recurse = TRUE)

  pkg_name <- fs::path_file(pkg_input)
  if (grepl("\\.tar\\.gz$", pkg_name, ignore.case = TRUE)) {
    pkg_name <- sub("\\.tar\\.gz$", "", pkg_name, ignore.case = TRUE)
  } else {
    pkg_name <- tools::file_path_sans_ext(pkg_name)
  }
  if (!nzchar(pkg_name)) {
    pkg_name <- "package"
  }

  output_file <- fs::path(output_dir, paste0(pkg_name, ".txt"))
  result <- rdocdump::rdd_to_txt(
    pkg = pkg_input,
    file = output_file,
    content = "all",
    keep_files = "both",
    force_fetch = !is_local && !is_installed
  )

  as.character(result)
}
