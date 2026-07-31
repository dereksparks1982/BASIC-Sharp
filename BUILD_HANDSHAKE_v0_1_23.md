# BASIC# Build Handshake v0.1.23

## Project and version

- **Project:** BASIC# Ruby Bootstrap Compiler
- **Build:** v0.1.23 ASK Introspection and Deterministic Answers
- **Required base:** accepted v0.1.22 BSharp Save Files and Deterministic World Restore
- **Required commit:** `d991679`
- **Required tag:** `v0.1.22`
- **Target version:** `v0.1.23`
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`

## Exact package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_23_ASK_INTROSPECTION_AND_DETERMINISTIC_ANSWERS_CHANGED_FILES_ONLY.zip`

## Completed changes

- Added read-only `--ask` toolchain questions and repeated-question order.
- Added deterministic `--ask-json` output using `bsharp.ask.json`.
- Added Thing, Kind, membership, state, value, relationship, event-match, IF, world, and save inspection.
- Reused runtime event priority rules without executing inspected events.
- Added 256-question protection and bounded human lists with complete JSON.
- Added source, BSIR, and restored-save answer parity.
- Added ASK sample files, tests, stress lane, contracts, validation, and handoffs.

## Excluded work

No ASK Head or official word, unrestricted English, spelling correction, event simulation, mutation, new language syntax, arithmetic, bytecode, VM, GUI, engine bridge, self-hosting, or new DK-prefixed names.

## Validation

```text
212 runs
5,043 assertions
0 failures
0 errors
0 skips
```

All eight stress lanes pass.

## Risks and controls

- ASK mutation is blocked by read-only inspection methods and before/after state tests.
- Event inspection calls matching logic only and never action execution.
- Unsupported English receives an explicit supported-question guide.
- Large answers are bounded for humans and complete in JSON.
- Source, BSIR, and save disagreement is blocked by parity tests.

## Rollback point

```text
commit d991679
tag v0.1.22
```

The installer must restore that accepted base on any post-mutation failure.

## Continuation

Derek installs and reviews the candidate before commit/tag. After acceptance, read all current records and present the v0.1.24 Stable Meaning Specification proposal.
