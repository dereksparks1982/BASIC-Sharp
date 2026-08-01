# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> BSharp IR
-> Stable Meaning Profile 1  [ACCEPTED: v0.1.24]
-> one canonical Company Bible  [ACCEPTED: v0.1.25]
-> BSharp Bytecode Profile 1 and deterministic BSBC  [ACCEPTED: v0.1.26-v0.1.28]
-> first BSharp VM, parity, Save, ASK, and hardening  [ACCEPTED: v0.1.29-v0.1.30]
-> BSharp VM preferred runtime and shadow parity  [ACCEPTED: v0.1.31]
-> creator-facing text values and Profile 2  [ACCEPTED: v0.1.32]
-> v0.1.33 Profile 3 candidate  [REJECTED: focused emitter validator]
-> v0.1.34 repaired emitter but retained stale runtime-banner validation  [REJECTED]
-> complete Profile 3 re-carry and runtime-transition validation repair  [ACCEPTED: v0.1.35]
-> plain-English platform movement and Profile 4  [ACCEPTED: v0.1.36]
-> plain-English number changes, comparisons, and Profile 5  [CURRENT CANDIDATE: v0.1.37]
-> owner validation and acceptance
-> expand the usable language and standard library
-> mature the BSharp VM through real programs and games
-> game-engine bridge
-> BASIC# self-hosting compiler
-> staged BASIC# editor: Notepad -> Notepad++ -> Sublime-class
-> complete BASIC# IDE
```

## Current v0.1.37 lane

- Accept `(increase score of PLAYER by 10` and `(decrease health of PLAYER by 3` for existing whole-number values.
- Accept exact equality plus `at least`, `more than`, `at most`, and `less than` IF comparisons.
- Stop missing-value, type mismatch, overflow, and underflow failures atomically before any selected Thing changes.
- Carry the new meaning through BSIR, Meaning Profile 5, BSharp Bytecode Profile 5, loader, BSharp VM, reference runtime, ASK, Save format 5, and shadow parity.
- Preserve all accepted Profile 1 through Profile 4 behavior and committed BSBC/disassembly bytes.

## Continuation after v0.1.37

1. Install and complete owner-side native validation.
2. Commit and tag v0.1.37 immediately after every gate passes, then capture the accepted full project snapshot.
3. Discuss the next focused creator-language build; no engine bridge begins without its own exact proposal and approval.
4. Expand creator-useful language meaning: more values, computation, conditions, events, collections, reusable behavior, official words, and non-programmer diagnostics.
5. Mature the BSharp VM as the permanent normal runtime while Ruby remains the bootstrap/reference oracle until replacement is proven.
6. Build a practical standard library for files, text, input, output, timing, math, collections, and everyday program needs.
7. Create the game-engine bridge for objects, worlds, interfaces, sound, movement, and engine events.
8. Prove BASIC# through actual programs and games and use those needs to guide hardening.
9. Build the self-hosting compiler only after BASIC# can express and verify it reliably.
10. Build the editor in stages: basic open/save/typing, then tabs/search/highlighting, then Sublime-class projects, navigation, autocomplete, definitions, compiler output, and Run controls.

## Shelved commercial lane

Private/proprietary distribution remains under consideration, but licensing and monetization are deferred. Future Creator pricing must include a reasonable monthly option, annual billing may only be an optional discount, and an eligible paid local version must remain usable permanently under the eventual qualifying terms.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- No new `DK`-prefixed name without Derek's explicit approval.
- Difficult machinery belongs beneath understandable creator-facing language.
- The BSharp VM is preferred; Ruby remains temporary bootstrap support and reference verification.
- Every build requires an exact accepted base, approval, validation, changed-files-only package, handshake, commit, and tag.
- The complete Company Bible is `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.
