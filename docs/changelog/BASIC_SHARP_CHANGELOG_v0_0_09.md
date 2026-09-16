# DKScript Changelog v0.0.09

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## First Runtime Execution

- Added `compiler/runtime.rb`.
- Added one-event runtime execution through `--run "event"`.
- Runtime now creates Things from BSharp IR and applies START facts.
- Existing IF rules are checked once after START facts.
- Existing WHEN Triggers can run their Connector lines.
- Added working behavior for `(damage`, `(change`, `(carry`, and `(unlock`.
- Runtime prints the changed world state.
- Updated the sample from `ember is alive` to the more useful starting condition `ember is calm`.
- Corrected user-facing compiler terminology from Result/Order to Connector/official word.
- Added runtime, CLI, BSharp IR-loading, and state-change tests.
- Added the DKScript roadmap and cumulative handoff.
