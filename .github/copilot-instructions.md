# GitHub Copilot Instructions

For comprehensive development guidance on this repository, **please read ../AGENTS.md**.

All authoritative agent instructions are maintained in AGENTS.md as the single source of truth.

## Quick Reference

This file provides quick reference guidance for GitHub Copilot when working with this R package.

### Coding Style & Conventions

- Use tidyverse-aligned R style: two-space indents, `<-` for assignment, snake_case for function and object names
- All exported functions require roxygen2 documentation blocks with `@export` tags and examples
- Prefer explicit namespace usage (e.g., `fs::dir_create()`, `data.table::fread()`)
- Use CRAN-compliant patterns: avoid side effects at package load, properly handle temp files with cleanup

### Testing Requirements

- Place tests in `tests/testthat/` with files named `test-*.R` matching source files
- Test files mirror source files: `test-log_funs.R` tests `R/log_funs.R`
- Maintain minimum 80% code coverage (check with `covr::package_coverage()`)
- Use testthat 3rd edition patterns (`expect_*()` functions)
- Mock filesystem operations where needed to avoid brittle tests

### Security & CRAN Compliance

- Never hardcode secrets or credentials in code
- Check package availability with `requireNamespace()` before using Suggests dependencies (`fs`, `jsonlite`, `R.utils`)
- Handle temp files properly: create in `tempdir()`, clean up on exit
- Set appropriate file permissions: writable when active, read-only after use
- Validate all external inputs (file paths, user arguments)

### Development Workflow

Before making changes:
```bash
# Restart R session first (Ctrl/Cmd+Shift+F10 in RStudio)
Rscript -e "devtools::document()"  # Regenerate docs
Rscript -e "devtools::test()"      # Run tests
Rscript -e "devtools::check()"     # Full R CMD check
```

After code changes:
- Update `man/` docs via `devtools::document()`
- Add new terms to `inst/WORDLIST` if spell check fails
- Verify coverage hasn't dropped below 80%
- Update `NEWS.md` for user-facing changes

### Documentation Standards

- Document all exported functions with roxygen2 blocks including:
  - `@title` and `@description`
  - `@param` for each parameter with clear descriptions
  - `@return` describing the return value
  - `@examples` with working, executable examples
  - `@export` tag for exported functions
- Keep examples concise but illustrative
- Use `\dontrun{}` for examples requiring special setup
- Reference related functions with `\code{\link{function_name}}`

### Package-Specific Notes

- **Logging system** maintains state in package environment `e` with fields: `log_is_active`, `log_file_path`, `log_dir_path`, `log_job_id`
- **Log format** is pipe-separated: `LEVEL|TIMESTAMP|MESSAGE|DETAIL`
- **open_log()** path resolution: explicit `path` → `options(rdstools.log_path)` → `RDSTOOLS_LOG_PATH` env var → `dir` arg → `options(rdstools.log_dir)` → `tempdir()`
- **RStudio addins** use `rstudioapi` package and should gracefully handle non-RStudio environments
- **Version numbering**: CRAN versions are clean (e.g., `0.3.1`), development adds `.9000` suffix (e.g., `0.3.1.9000`)

### Common Patterns

Checking for suggested packages:
```r
if (requireNamespace("fs", quietly = TRUE)) {
  fs::dir_create(path)
} else {
  dir.create(path, recursive = TRUE)
}
```

Handling temp files:
```r
temp_file <- tempfile(fileext = ".log")
on.exit(unlink(temp_file), add = TRUE)
```

Roxygen2 documentation example:
```r
#' @title Log a message
#' @description Writes a message to console and active log file
#' @param msg Character message to log
#' @param detail Optional additional detail
#' @return Invisibly returns NULL
#' @examples
#' log_info("Processing started")
#' log_info("Step complete", detail = "Records: 100")
#' @export
log_info <- function(msg, detail = "") {
  # implementation
}
```

### Preferred Libraries

- Use `data.table` for data manipulation (it's in Imports)
- Use `crayon` for colored console output (it's in Imports)
- Use `stringr` for string operations (it's in Imports)
- Use `rstudioapi` for RStudio integration (it's in Imports)
- Avoid adding new dependencies unless absolutely necessary

### Commit Message Style

Use imperative, action-oriented messages:
- ✅ "Add test coverage for log rotation"
- ✅ "Fix permission handling in close_log()"
- ✅ "Update README with installation instructions"
- ❌ "Added tests" or "Fixed bug"

### When in Doubt

- Consult `AGENTS.md` for detailed architectural guidance
- Check existing code patterns in `R/` directory for consistency
- Run full check suite before finalizing changes
- Maintain backwards compatibility unless explicitly breaking
