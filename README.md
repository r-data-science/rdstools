# rdstools <img src="man/figures/logo.png" align="right" height="120" alt="" />


<!-- badges: start -->
[![lint](https://github.com/r-data-science/rdstools/actions/workflows/lint.yaml/badge.svg)](https://github.com/r-data-science/rdstools/actions/workflows/lint.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/rdstools)](https://CRAN.R-project.org/package=rdstools)
<!-- badges: end -->

For contributor workflow details, see [`AGENTS.md`](https://github.com/r-data-science/rdstools/blob/main/AGENTS.md).

## Installation

```r
# Install the latest development version from GitHub
remotes::install_github("r-data-science/rdstools")

# Install a specific CRAN release version
remotes::install_github("r-data-science/rdstools@v0.2.2")

# Install from CRAN (once accepted)
install.packages("rdstools")
```

## RStudio Addins for IDE Control

`rdstools` provides RStudio addins to control common IDE operations, making them
easy to map to keyboard shortcuts or Stream Deck buttons:

```r
# Activate different panes
rdstools::activate_terminal()
rdstools::activate_console()
rdstools::activate_source_editor()

# Change IDE layout
rdstools::layout_two_column()
rdstools::layout_three_column()
rdstools::layout_four_column()

# Switch themes (requires rsthemes package)
rdstools::switch_theme_dark()   # Random dark theme
rdstools::switch_theme_light()  # Random light theme

# Package development shortcuts
rdstools::restart_session()
rdstools::load_all_code()
rdstools::document_package()
rdstools::build_package()
rdstools::test_package()
rdstools::check_package()
rdstools::pkg_coverage()
```

### Setting Up Keyboard Shortcuts

After installing the package:

1. In RStudio, go to **Tools > Modify Keyboard Shortcuts**
2. Search for "rdstools" or the specific addin name
3. Click in the Shortcut column and press your desired key combination
4. Click Apply

For Stream Deck integration:

1. Set keyboard shortcuts in RStudio for each addin
2. In Stream Deck software, create buttons that trigger those keyboard shortcuts
3. Optionally add icons and labels to identify each function

## Logging to Files

`rdstools::log_*()` helpers still write to the console by default. To capture
the same entries in a file, open a log once at application start:

```r
rdstools::open_log(path = "/var/log/app/session.log")
```

You can also set `options(rdstools.log_path = ...)` or
`Sys.setenv(RDSTOOLS_LOG_PATH = ...)` before the first log call; subsequent log
writers will append to the configured file and you can query
`rdstools::log_is_active()` to confirm a sink is active.

Call `rdstools::close_log()` during shutdown to flush and close the file; the
logging functions will continue to operate but fall back to console output if
the file becomes unavailable.

## Release Process

This package uses a **tag-based release workflow** to support both CRAN releases and continuous platform development:

- **`main` branch**: Always contains the latest code. Platform dependencies install from `main` to get immediate fixes and features.
- **Git tags**: Mark specific CRAN versions (e.g., `v0.2.2`, `v0.3.0`) for stable releases.
- **Version numbering**:
  - CRAN versions use clean numbers: `0.2.2`, `0.3.0`
  - Development versions add `.9000`: `0.3.0.9000` (between CRAN releases)

### For Contributors

When preparing a CRAN release:

1. **Before submission**: Tag the commit as `vX.Y.Z-cran-submitted`
2. **Continue development**: Merge new features to `main` immediately
3. **After CRAN acceptance**: Tag the submission commit as `vX.Y.Z`
4. **Post-release**: Bump version to `X.Y.Z.9000` in `DESCRIPTION`

CRAN submissions should be spaced **2+ months apart** unless addressing critical bugs.

See [`AGENTS.md`](AGENTS.md) for detailed release management guidelines.
