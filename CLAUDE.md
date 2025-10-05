# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`rdstools` is an R package providing data science development utilities focused on three areas:
1. **Logging** - Color-coded console logs with persistent file output via `log_*()` functions
2. **Debugging** - `catcall()` helper to recreate data objects for reproducible diagnostics
3. **Development** - `report_coverage()` for automated coverage reporting with RStudio restart handling

## Build, Test, and Development Commands

Start with a clean R session (RStudio `Ctrl/Cmd+Shift+F10`) before redocumenting:

```bash
# Regenerate Rd files and NAMESPACE after code changes
Rscript -e "devtools::document()"

# Run the testthat suite
Rscript -e "devtools::test()"

# Full R CMD check (includes spell checks)
Rscript -e "devtools::check()"

# Check coverage (must be ≥ 80%)
Rscript -e "covr::package_coverage()"

# Reload package for interactive exploration
Rscript -e "pkgload::load_all()"
```

**Workflow sequence**: restart R → document → test → check → confirm coverage before PR.

## Architecture

### Logging System (R/log_funs.R)

The logging system maintains state in a package-level environment (`e`) with these fields:
- `log_is_active` - boolean indicating if a log file is open
- `log_file_path` - path to the active log file
- `log_dir_path` - directory containing the log file
- `log_job_id` - optional job identifier for grouping logs

**Key behavior**:
- `open_log()` resolves file paths via: explicit `path` argument → `options(rdstools.log_path)` → `RDSTOOLS_LOG_PATH` env var → `dir` argument → `options(rdstools.log_dir)` → `tempdir()` default
- `open_log()` creates parent directories by default (`create_dir = TRUE`) and appends to existing files unless `append = FALSE`
- All `log_*()` functions write to console AND the active log file (if open)
- `close_log(gather = TRUE)` returns a `data.table` of parsed log entries
- Logs use pipe-separated format: `LEVEL|TIMESTAMP|MESSAGE|DETAIL`
- File permissions are managed: writable when active, read-only after `close_log()`

### Testing Conventions (tests/testthat/)

- Test files mirror source files: `test-log_funs.R` tests `R/log_funs.R`
- Maintain ≥ 80% line coverage; use `Rscript -e "covr::report()"` to inspect regressions
- Update `inst/WORDLIST` for new terminology to prevent spelling false positives

### Code Style

- Tidyverse-aligned: two-space indents, `<-` for assignment, snake_case names
- Explicit namespace usage (e.g., `fs::dir_create`) to satisfy CRAN policies
- All exported functions require roxygen2 blocks with `@export` and examples
- Keep side effects inside functions (no top-level execution)

## Important Notes

- **Suggested packages**: `fs`, `jsonlite`, `R.utils` are in Suggests; check availability with `requireNamespace()` before use
- **CRAN constraints**: The package is published on CRAN, so changes must comply with CRAN policies (no temp file leaks, proper permission handling, etc.)
- Spell checks run via `tests/spelling.R` using `inst/WORDLIST`
