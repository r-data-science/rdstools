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

## Additional Resources
- Project overview and status badges live in [`README.md`](README.md).

