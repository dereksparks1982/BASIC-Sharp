# BASIC# v0.0.21 Session Log

**Date:** 2026-07-30  
**Base:** v0.0.20, commit `c94faec`, tag `v0.0.20`  
**Decision:** Derek approved explicit follow-up events and deterministic event order.

## Owner-approved scope

- Use `(cause` to create a visible follow-up event.
- Complete the current WHEN body before follow-up events.
- Settle IF rules before follow-up events.
- Use first-created, first-run order.
- Append nested events to the end.
- Capture `that Kind` as the selected Thing.
- Continue after unmatched follow-ups.
- Stop after a follow-up runtime error.
- Stop self-feeding chains after 1,024 follow-up events.
- Add no automatic hidden events and no plural caused events.

## Result

The compiler, BSharp IR, runtime, trace, tests, sample, stress tools, contracts, handoffs, roadmap, manifest, installer, and validation records were updated. The complete suite and all six stress lanes passed internally.

## Corrected installer record

The first package stopped before mutation because its expected v0.0.20 hash for `README.md` came from an incomplete reconstructed workspace. Derek's accepted commit `c94faec` remained clean and authoritative. The candidate was rebuilt on the exact accepted v0.0.20 files, all generated BSIR samples were regenerated, and the full validation and clean-base installer proof were repeated.
