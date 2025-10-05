# Repository Guidelines

## Project Structure & Module Organization
- `R/` holds the package logic; exported helpers live in files such as `log_funs.R` and `dev-utils.R` and follow roxygen2 documentation blocks.
- `man/` contains the generated Rd docs, while `inst/WORDLIST` backs the spelling checks; keep changes in sync by running roxygen before committing.
- Tests reside under `tests/testthat/` with supporting harness files in `tests/testthat.R`; use this layout when adding new test modules.
- Ancillary package metadata lives in `DESCRIPTION`, `NAMESPACE`, and `NEWS.md`; edit these rather than duplicating configuration in code.

## Build, Test, and Development Commands
- Start with a clean R session (e.g., RStudio `Ctrl/Cmd+Shift+F10`) before redocumenting to avoid stale state.
- `Rscript -e "devtools::document()"` regenerates Rd files and `NAMESPACE` via roxygen2 after code changes.
- `Rscript -e "devtools::test()"` runs the testthat suite in `tests/testthat/`.
- `Rscript -e "devtools::check()"` performs the full `R CMD check`, including spell checks defined in `tests/spelling.R`.
- `Rscript -e "covr::package_coverage()"` must report ≥ 0.80 before merging; review the per-file breakdown if coverage dips.
- `Rscript -e "pkgload::load_all()"` reloads the package for interactive exploration between these steps.
- Follow the sequence: restart R → document → test → check → confirm coverage before opening a PR.

## Coding Style & Naming Conventions
- Use tidyverse-aligned R style: two-space indents, `<-` for assignment, and snake_case for function and object names (`log_header`, `open_log`).
- All exported functions require roxygen2 blocks with `@export` tags and illustrative examples; mirror the structure in existing files.
- Prefer explicit namespace usage (e.g., `fs::dir_create`) and keep side-effectful code inside functions to satisfy CRAN policies.

## Testing Guidelines
- Place new tests in files named `test-*.R` under `tests/testthat/`; mirror the feature or function name for clarity.
- Keep line coverage at or above 80%; use `Rscript -e "covr::report()"` to inspect regressions when modifying logging or filesystem code.
- Update `inst/WORDLIST` if new terminology introduces spelling false positives; keep spelling expectations deterministic.

## Commit & Pull Request Guidelines
- Commit messages are short, action-oriented statements (e.g., “Update README.md”, “Ran revdepcheck”); follow that imperative tone.
- Reference related issues in the commit body or PR description, and summarize validation steps (tests run, spell check results).
- Pull requests should include a concise change overview, manual test notes, and any CRAN-impacting considerations (e.g., temp file handling).

## Additional Resources
- Project overview and status badges live in [`README.md`](README.md).

