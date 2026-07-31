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
-> creator-facing text values and Profile 2  [CURRENT CANDIDATE: v0.1.32]
-> owner validation and acceptance
-> propose plain-English movement control commands  [NEXT DISCUSSION]
-> expand the usable language and standard library
-> mature the BSharp VM through real programs and games
-> game-engine bridge
-> BASIC# self-hosting compiler
-> staged BASIC# editor: Notepad -> Notepad++ -> Sublime-class
-> complete BASIC# IDE
```

## Current v0.1.32 lane

- Add straight-double-quoted, single-line UTF-8 creator text.
- Preserve creator text exactly through source, BSIR, fingerprinting, Profile 2 BSBC, validation, VM execution, Save, ASK, restore, and shadow parity.
- Add `START_TEXT_VALUE`, `CHANGE_TEXT_VALUE`, and `TEXT_VALUE_EQUALS` to BSharp Bytecode Profile 2.
- Preserve accepted Profile 1 meaning and artifacts.
- Keep interpolation, concatenation, escapes, multiline text, `(speak ...)`, text event matching, editor work, and unrelated syntax outside this build.

## Major continuation after v0.1.32

1. First discuss a focused build for plain-English movement control commands, as Derek requested after v0.1.32 acceptance. The initial use case is left/right platformer control with a creator-chosen speed, while input polling, direction math, frame timing, velocity, collision movement, and engine calls stay hidden beneath short BASIC# English. Exact words—including whether `PLAYER` or `<move>` becomes official syntax—remain a separate owner decision and require their own proposal and approval.
2. Expand creator-useful language meaning: more values and computation, conditions, events, collections, reusable behavior, official words, and non-programmer diagnostics.
3. Mature the BSharp VM as the permanent normal runtime while Ruby remains the bootstrap/reference oracle until replacement is proven.
4. Build a practical standard library for files, text, input, output, timing, math, collections, and everyday program needs.
5. Create the game-engine bridge for objects, worlds, interfaces, sound, movement, and engine events.
6. Prove BASIC# through actual programs and games and use those needs to guide hardening.
7. Build the self-hosting compiler only after BASIC# can express and verify it reliably.
8. Build the editor in stages: basic open/save/typing, then tabs/search/highlighting, then Sublime-class projects, navigation, autocomplete, definitions, compiler output, and Run controls.
9. Grow the editor into an IDE with compiler/debugger integration, plain-language trace/ASK tools, project management, game integration, and education support.

## Completed foundation

- Five accepted Heads: KINDS, DEFINE, START, WHEN, and IF.
- Things, inherited Kind families, deterministic event matching, set actions, reactive IF rules, whole-number values, and deterministic follow-up events.
- BSharp IR, BSharp Save, BSharp ASK, Profile 1 conformance, one Company Bible, deterministic BSBC, complete validation, direct VM execution, and VM/reference parity.

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
