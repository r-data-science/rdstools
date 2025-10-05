# rdstools 0.3.0

This release focuses on production-grade logging so Shiny applications can fan
out console messages to persistent log files without destabilizing running
sessions.

## Highlights

* `open_log()` now accepts explicit `path` and `dir` arguments (plus the
  `RDSTOOLS_LOG_PATH` environment variable and matching options) so parent
  applications can direct logs to existing log files. Existing calls that omit
  these parameters continue to create files under `tempdir()`.
* Reattaching to an existing log is now supported; the helper restores
  write-permissions and records a "Log File Reattached" entry instead of
  failing.
* File writes are wrapped in guarded I/O that surfaces a warning rather than an
  error when the OS denies access, preventing downstream packages from
  crashing when log files disappear or become read-only.
* Added `log_is_active()` so dependent modules can detect whether a shared log
  has been opened by the host application.
* `read_logs()` tolerates multiple `OPEN` entries, eliminating prior warnings
  when a session reattached to a log file.
* Extended test coverage around custom log paths, append behavior, and failure
  modes; updated documentation to describe the new configuration knobs.

# rdstools 0.1.3

This release prepares **rdstools** for CRAN submission and improves the package usability while maintaining backwards compatibility with dependent projects.

## Notable changes

* **Safe log storage:** `open_log()` now writes log files inside the session's temporary directory (`tempdir()`) rather than creating a `log/` directory in the working directory. This change complies with CRAN's file‑system policies. The returned log file path is still absolute, so existing code that captures the return value continues to work.
* **Documentation improvements:**
  - Corrected parameter descriptions (e.g. `detail_sep` now references a separator.
  - Updated the `@describeIn` tags for logging helper functions to accurately describe their behavior (e.g. `log_ini()` now documented as “Log initiation (open)” rather than “Log errors”).
  - Added runnable examples to `catcall()` demonstrating basic usage.
* **Package metadata:**
  - Updated the package title to “Data Science Development Tools” to better reflect its purpose.
  - Bumped version number to 0.1.3 and removed `LazyData` as the package contains no data.
  - Moved `testthat` to the **Suggests** field. The optional call to `testthat::is_testing()` in `report_coverage()` is now guarded with a `requireNamespace()` check.
* **Testing adjustments:** The test suite has been updated to accommodate the new logging directory. A helper function now cleans up temporary log directories created during testing.

These changes should ensure that **rdstools** passes `R CMD check --as-cran` without notes or warnings while preserving its API for downstream packages.
