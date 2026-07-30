# Company Bible Addendum: Windows-Safe Validation Telemetry

**Version:** v0.3.37  
**Date:** 2026-07-09  
**Status:** Mandatory

## Rule

A live validator heartbeat that is actively polled by the open Godot editor must not repeatedly delete and rename the same destination file on Windows.

For DK Live Builder and future monitored validators:

1. Live progress may be written directly to the polled progress path.
2. Live-progress writes must use a small bounded retry when the file is briefly unavailable.
3. The editor-side reader must treat missing, locked, empty, or partially written progress JSON as **no new heartbeat yet** and retain the last valid heartbeat.
4. A transient incomplete read is not a project warning or error.
5. A true publication failure after all bounded retries remains fatal and must be reported.
6. Final-result publication may remain atomic when it is not concurrently polled, but it must also use bounded retry and cleanup.
7. Telemetry repair must not weaken timeout, cancellation, PID monitoring, resource-load checks, warnings-as-errors, errors-as-errors, or exit-code requirements.

## Historical lesson

v0.3.36 completed all 208 discovered resources with zero load failures and exit code `0`, but the runner and open editor collided while replacing the live-progress JSON file. Windows rejected the final rename during the reader's access window. The validator correctly failed because the emitted error was real. v0.3.37 removes that replacement race without hiding genuine failures.
