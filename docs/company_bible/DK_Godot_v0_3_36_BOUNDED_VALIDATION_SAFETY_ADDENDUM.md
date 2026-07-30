# Company Bible Addendum: Bounded Child-Process Validation

**Version:** v0.3.36  
**Date:** 2026-07-09  
**Status:** Mandatory

## Rule

A DK validation tool must never be allowed to trap the editor indefinitely or perform an unbounded recursive resource-reload stress pass.

For DK Live Builder and future project validators:

1. A long-running validation process must run outside the editor process and expose its process ID.
2. The editor interface must remain responsive while validation runs.
3. Validation must provide visible progress or a heartbeat, including the current stage and last resource attempted.
4. The user must have a cancellation control.
5. Every validation run must have a hard timeout and terminate its child process when that limit is reached.
6. Resource scans must use normal cache reuse unless a separately approved diagnostic build explicitly requires another mode.
7. Warnings, errors, resource-load failures, missing completion records, cancellation, timeout, and nonzero exit codes remain failures.
8. A validator crash or freeze must be logged and corrected in a new numeric build before roadmap work resumes.
9. Tool safety must not be achieved by hiding or filtering genuine project errors.

## Historical lesson

v0.3.35 removed the runner parse error but loaded every selected resource with `CACHE_MODE_IGNORE_DEEP` through a blocking validation call. The resulting repeated dependency rebuilding froze and crashed the local validation process. The project gate must be strict, but it must also be bounded and recoverable.
