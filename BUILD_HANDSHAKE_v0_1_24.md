# BASIC# Build Handshake v0.1.24

## Project and version

- **Project:** BASIC# Ruby Bootstrap Compiler
- **Build:** v0.1.24 Stable Meaning Specification and Conformance Profile 1
- **Required base:** accepted v0.1.23 ASK Introspection and Deterministic Answers
- **Required commit:** `aa69291`
- **Required tag:** `v0.1.23`
- **Target version:** `v0.1.24`
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`

## Exact package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_24_STABLE_MEANING_SPECIFICATION_AND_CONFORMANCE_PROFILE_1_CHANGED_FILES_ONLY.zip`

## Completed changes

- Added normative Profile 1 specification, terminology, and compatibility policy.
- Added `bsharp.meaning.v1` manifest and 13 conformance cases.
- Added normalized source, BSIR, runtime, save, and ASK observations.
- Added deterministic expected-result hashes and a reusable conformance runner.
- Removed six abandoned names from the accepted Head set.
- Added plain invalid-Head guidance.
- Regenerated current BSIR and BSharp Save samples for v0.1.24.

## Excluded work

No new source feature, input tolerance, arithmetic, artifact schema migration, bytecode, VM, GUI, editor, engine bridge, self-hosting, or new DK-prefixed name.

## Validation

```text
218 runs
5,102 assertions
0 failures
0 errors
0 skips
```

All eight existing stress lanes and Profile 1 conformance must pass.

## Risks and controls

- Accidental Ruby behavior is excluded through normalized implementation-neutral fixtures.
- Profile hashes exclude line numbers, raw echoes, paths, timestamps, and Ruby objects.
- Dormant parser vocabulary is rejected rather than frozen.
- Future additive features remain possible when Profile 1 programs retain their meaning.

## Rollback point

```text
commit aa69291
tag v0.1.23
```

The installer must restore that accepted base on any post-mutation failure.

## Continuation

Derek installs and reviews the candidate before commit/tag. After acceptance, read all records and present a complete bytecode-design proposal.
