# rdstools <img src="man/figures/logo.png" align="right" height="120" alt="" />


<!-- badges: start -->
[![lint](https://github.com/r-data-science/rdstools/actions/workflows/lint.yaml/badge.svg)](https://github.com/r-data-science/rdstools/actions/workflows/lint.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/rdstools)](https://CRAN.R-project.org/package=rdstools)
<!-- badges: end -->

For contributor workflow details, see [`AGENTS.md`](AGENTS.md).

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
