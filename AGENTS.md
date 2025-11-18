# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`rdstools` is an R package providing data science development utilities focused on three areas:
1. **Logging** - Color-coded console logs with persistent file output via `log_*()` functions
2. **Debugging** - `catcall()` helper to recreate data objects for reproducible diagnostics
3. **Development** - `report_coverage()` for automated coverage reporting with RStudio restart handling

## Project Structure & Module Organization
- `R/` holds the package logic; exported helpers live in files such as `log_funs.R` and `dev-utils.R` and follow roxygen2 documentation blocks.
- `man/` contains the generated Rd docs, while `inst/WORDLIST` backs the spelling checks; keep changes in sync by running roxygen before committing.
- Tests reside under `tests/testthat/` with supporting harness files in `tests/testthat.R`; use this layout when adding new test modules.
- Ancillary package metadata lives in `DESCRIPTION`, `NAMESPACE`, and `NEWS.md`; edit these rather than duplicating configuration in code.

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

## Coding Style & Naming Conventions
- Use tidyverse-aligned R style: two-space indents, `<-` for assignment, and snake_case for function and object names (`log_header`, `open_log`).
- All exported functions require roxygen2 blocks with `@export` tags and illustrative examples; mirror the structure in existing files.
- Prefer explicit namespace usage (e.g., `fs::dir_create`) and keep side-effectful code inside functions to satisfy CRAN policies.

## Testing Guidelines
- Place new tests in files named `test-*.R` under `tests/testthat/`; mirror the feature or function name for clarity.
- Test files mirror source files: `test-log_funs.R` tests `R/log_funs.R`
- Keep line coverage at or above 80%; use `Rscript -e "covr::report()"` to inspect regressions when modifying logging or filesystem code.
- Update `inst/WORDLIST` if new terminology introduces spelling false positives; keep spelling expectations deterministic.

## Commit & Pull Request Guidelines
- Commit messages are short, action-oriented statements (e.g., "Update README.md", "Ran revdepcheck"); follow that imperative tone.
- Reference related issues in the commit body or PR description, and summarize validation steps (tests run, spell check results).
- Pull requests should include a concise change overview, manual test notes, and any CRAN-impacting considerations (e.g., temp file handling).

## Release Management & CRAN Workflow

This package uses a **tag-based release workflow** where `main` always contains the latest code (for platform dependencies) and git tags mark CRAN versions.

### Version Numbering
- **CRAN versions**: Clean version numbers (e.g., `0.2.2`, `0.3.0`)
- **Development versions**: `.9000` suffix (e.g., `0.3.0.9000`) indicates development between CRAN releases

### Release Process
1. **Before CRAN submission**: Tag `main` as `vX.Y.Z-cran-submitted` (e.g., `v0.2.2-cran-submitted`)
2. **After submission**: Continue development on `main`; dependent platforms install from `main`
3. **When CRAN accepts**: Add official tag `vX.Y.Z` to the submission commit
4. **Post-release**: Bump `DESCRIPTION` version to `X.Y.Z.9000` and add development section to `NEWS.md`
5. **Next CRAN submission**: Wait 2+ months between submissions unless fixing critical bugs

### Tagging Commands
```bash
# Before CRAN submission
git tag v0.3.0-cran-submitted
git push origin v0.3.0-cran-submitted

# After CRAN acceptance
git checkout v0.3.0-cran-submitted
git tag v0.3.0
git push origin v0.3.0
```

### Installation Options
- Latest development: `remotes::install_github("r-data-science/rdstools")`
- Specific CRAN version: `remotes::install_github("r-data-science/rdstools@v0.2.2")`
- From CRAN (once accepted): `install.packages("rdstools")`

## Important Notes

- **Suggested packages**: `fs`, `jsonlite`, `R.utils` are in Suggests; check availability with `requireNamespace()` before use
- **CRAN constraints**: The package is published on CRAN, so changes must comply with CRAN policies (no temp file leaks, proper permission handling, etc.)
- Spell checks run via `tests/spelling.R` using `inst/WORDLIST`

## Additional Resources
- Project overview and status badges live in [`README.md`](README.md).
