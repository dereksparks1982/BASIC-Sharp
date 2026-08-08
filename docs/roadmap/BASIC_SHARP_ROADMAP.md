# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> BSharp IR
-> Stable Meaning Profile 1  [ACCEPTED: v0.1.24]
-> one canonical Company Bible  [ACCEPTED: v0.1.25]
-> BSharp Bytecode Profiles 1-7 and BSharp VM  [ACCEPTED: v0.1.26-v0.1.39]
-> Trial by Fire complete repair and BSharp VM hardening  [ACCEPTED: v0.1.42, 1d79a62]
-> v0.1.43 malformed self-hosting package  [REJECTED: installer NUL-byte bug, no mutation]
-> Self-Hosting Foundation and Rejected Package Repair Record  [ACCEPTED: v0.1.44]
-> v0.1.45 movement/input package  [REJECTED: native test timing failure, rollback restored v0.1.44]
-> Plain-English Movement and Input Contract  [CURRENT CANDIDATE: v0.1.46]
-> BASIC# tokenizer/reader contract
-> BASIC# tokenizer/reader implementation under Ruby referee
-> small compiler subset parser
-> BASIC# compiler subset emits BSharp IR
-> BASIC# compiler subset emits BSBC
-> byte-for-byte parity against approved Ruby bootstrap outputs
-> staged Ruby retirement only after validation earns it
-> BSharp native document app
-> game-engine bridge
-> independent BASIC# Semantic Oracle  [FUTURE CONCEPT]
-> staged BASIC# editor: Notepad -> Notepad++ -> Sublime-class
-> complete BASIC# IDE
```

## Current v0.1.46 lane

- Define the input-device meaning layer for keyboard, mouse/keyboard, PS5, Xbox, and generic gamepad events.
- Preserve the existing creator-facing `CONTROLS for PLAYER` language.
- Add an executable contract and tests proving device events map to existing top-down and platform movement host commands.
- Repair the rejected v0.1.45 Xbox jump timing assertion without expanding scope.
- Exclude remapping UI, platform drivers, engine bridge, graphics, haptics, camera controls, Profile 8, and Ruby replacement.

## Accepted v0.1.44 lane

- Preserve v0.1.43 as rejected and do not reuse its number.
- Add a permanent rejected-package audit and installer NUL-byte package rule.

- Define BSharp Compiler Subset 0.
- Add self-hosting foundation documentation, JSON spec, validator tool, and focused test.
- Preserve Ruby as bootstrap compiler and reference authority.
- Preserve all accepted Profiles 1-7 meaning and Trial-by-Fire gates.
- Regenerate all current version-bearing runtime fixtures for `0.1.44` together.
- Add no creator syntax, Profile 8, runtime semantics, engine bridge, document app, or Ruby replacement.

## Continuation after v0.1.46

1. Install and complete owner-side native validation from exact accepted commit `b630b031666a527d8549e6715e59065071a3efd0` and tag `v0.1.44`.
2. Commit and tag v0.1.46 immediately after every gate passes, then capture the accepted full-project snapshot.
3. Next focused build may either tighten movement wording further or return to the self-hosting tokenizer/reader contract.
4. Ruby remains the referee until BASIC# compiler pieces reproduce approved output deterministically.
5. BSharp native documents remain valuable, but they wait until the self-hosting runway is credible.

## Shelved commercial lane

Private/proprietary distribution remains under consideration, but licensing and monetization are deferred. Future Creator pricing must include a reasonable monthly option, annual billing may only be an optional discount, and an eligible paid local version must remain usable permanently under the eventual qualifying terms.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- No new `DK`-prefixed name without Derek's explicit approval.
- Difficult machinery belongs beneath understandable creator-facing language.
- The BSharp VM is preferred; Ruby remains temporary bootstrap support and reference verification.
- Self-hosting is earned through staged contracts and parity, not declared early.
- Every build requires an exact accepted base, approval, validation, changed-files-only package, handshake, commit, and tag.
- The complete Company Bible is `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.
- The active self-hosting contract is `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
- The active input-device contract is `spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json`.
