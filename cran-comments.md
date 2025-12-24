## Resubmission

Fixed invalid file URI in README.md as requested by CRAN reviewers.

### Previous CRAN Feedback

> Found the following (possibly) invalid file URI:
> URI: AGENTS.md
> From: README.md
>
> Please fix and resubmit.

### Resolution

Changed relative file link `AGENTS.md` to full GitHub URL:
`https://github.com/r-data-science/rdstools/blob/main/AGENTS.md`

This ensures all documentation links are valid URLs accessible to users of the installed package.

## Package Description

This submission focuses on hardening file logging while remaining backward compatible for dependent Shiny modules.

- `open_log()` gains optional `path`/`dir` arguments and honours the `RDSTOOLS_LOG_PATH` environment variable so hosts can route logs to shared files.
- File writes are wrapped in guarded I/O; permission issues now raise warnings and leave the application running.
- Added `log_is_active()` and updated tests/documentation covering reattachment and failure cases.

## R CMD check results

0 errors | 0 warnings | 0 notes
