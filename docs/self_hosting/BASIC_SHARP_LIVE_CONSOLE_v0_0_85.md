# BASIC# Live Console: v0.0.85 source-only development candidate

**Branch:** main only. **Status:** unaccepted and untested. No compilation, no
test execution, no GitHub Actions, no installer, and no release tag.

The repository root index.html is a static GitHub Pages entrypoint. It imports
the existing browser-native BASIC# source-to-IR compiler and the new
compiler/portable/bsharp_sandbox.mjs simulation runtime directly as ES modules.

The console provides:
- Editable BASIC# source, supplied examples, Execute, Reset, and Ctrl+Enter.
- Clickable WHEN event triggers that perform real state and number changes.
- START facts, state changes, damage, carry, unlock, number changes, and
  reactive IF/OTHERWISE clauses, limited to supported direct object references.
- Inspectable event trace, world state, and generated BSharp IR.
- Local editor persistence (best effort) and plain-English error reporting.
- No eval, no remote code service, no arbitrary JavaScript execution.

The runtime is **not** a full BSharp VM or .bsbc executor. BSharp IR produced
by the independent JavaScript compiler is interpreted directly for a deliberately
bounded BASIC# language subset. Unsupported operations are rejected before
execution where possible, and the accepted Ruby compiler remains unchanged.

The site is placed in the repository root for GitHub Pages configurations that
publish from main/(root). If Pages is configured for /docs or a custom Actions
workflow, the deployment source will need to point to the appropriate content
before the site becomes visible. We could not verify Pages settings via the
available GitHub connection, and no settings were changed.

Known limitations: no full selectors, text/phrase value semantics, CONTROLS,
HOVER, CONTEXT, generated BSBC, BSBC VM, true game rendering, world saves,
remote publishing, proof of parity or native compiler self-hosting. The console
must not be advertised as a completed Ruby replacement.

This source-only candidate must not be accepted as a numbered release until
the owner resumes testing and the mandatory full suite and contract audit pass.
Failed previous v0.1.85 local installer attempts remain acknowledged history.

Next: strengthen the JavaScript compiler's semantic parity and add a
Ruby-independent BSBC emitter and VM, then bring the full language to the
interactive console. Creator syntax and profiles 1 through 7 are protected.

## Condition/value interpretation extension (same unaccepted candidate)

The browser sandbox gained numeric threshold IF comparisons, exact quoted text
value storage/comparisons/changes, one-object definite Kind references, and
plain-English object-interaction lowering. The console gained examples for
these features. None of the additions were compiled, executed or validated;
they do not turn the sandbox into a real BSBC VM. See
`docs/self_hosting/BASIC_SHARP_PORTABLE_CONDITION_VALUES_v0_0_85.md`.
