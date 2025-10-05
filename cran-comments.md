## Resubmission

This submission addresses the 2025-10-05 feedback from CRAN:

- Expanded the Description field to describe the logging utilities and coverage helpers in detail.
- Added explicit value sections for all exported functions documented in \code{catcall}, \code{dev-utils}, and \code{log_funs}.
- Updated logging helpers to emit information with \code{message()} so output can be suppressed via \code{suppressMessages()}.
- Added testing hooks to exercise coverage workflows and documented the return values accordingly.

## R CMD check results

0 errors | 0 warnings | 0 notes
