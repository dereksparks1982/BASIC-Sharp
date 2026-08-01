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
-> complete Profile 3 re-carry and runtime-transition validation repair  [CURRENT CANDIDATE: v0.1.35]
-> owner validation and acceptance
-> plain-English movement commands  [NEXT DISCUSSION]
-> expand the usable language and standard library
-> mature the BSharp VM through real programs and games
-> game-engine bridge
-> BASIC# self-hosting compiler
-> staged BASIC# editor: Notepad -> Notepad++ -> Sublime-class
-> complete BASIC# IDE
```

## Current v0.1.35 lane

- Carry forward every approved v0.1.33 feature from accepted v0.1.32 because the rejected build rolled back completely.
- Preserve the emitter-selected bytecode profile reader and Profile 1/2/3 proof from the rejected v0.1.34 candidate.
- Bind direct-BSBC and explicit reference-runtime banner checks to `BasicSharp::VERSION`.
- Reject hard-coded numeric runtime banners through automated regression coverage.
- Preserve the v0.1.33 and v0.1.34 failure records and automatic rollback evidence.
- Preserve accepted Profile 1 and Profile 2 meaning and committed bytecode artifacts.
- Keep all new language features outside this surgical repair.

## Continuation after v0.1.35

1. Install and complete owner-side native validation.
2. Accept, commit, and tag v0.1.35 only after every gate passes.
3. Capture the accepted full v0.1.35 project snapshot and current handshake.
4. Discuss a focused build for plain-English movement commands, as Derek requested. The initial use case is left/right platformer movement with creator-chosen speed while polling, timing, velocity, collision movement, and engine calls remain hidden beneath short BASIC# English.
5. Expand creator-useful language meaning: more values, computation, conditions, events, collections, reusable behavior, official words, and non-programmer diagnostics.
6. Mature the BSharp VM as the permanent normal runtime while Ruby remains the bootstrap/reference oracle until replacement is proven.
7. Build a practical standard library for files, text, input, output, timing, math, collections, and everyday program needs.
8. Create the game-engine bridge for objects, worlds, interfaces, sound, movement, and engine events.
9. Prove BASIC# through actual programs and games and use those needs to guide hardening.
10. Build the self-hosting compiler only after BASIC# can express and verify it reliably.
11. Build the editor in stages: basic open/save/typing, then tabs/search/highlighting, then Sublime-class projects, navigation, autocomplete, definitions, compiler output, and Run controls.

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
