## Resubmission

This submission focuses on hardening file logging while remaining backward compatible for dependent Shiny modules.

- `open_log()` gains optional `path`/`dir` arguments and honours the `RDSTOOLS_LOG_PATH` environment variable so hosts can route logs to shared files.
- File writes are wrapped in guarded I/O; permission issues now raise warnings and leave the application running.
- Added `log_is_active()` and updated tests/documentation covering reattachment and failure cases.

## R CMD check results

0 errors | 0 warnings | 0 notes
