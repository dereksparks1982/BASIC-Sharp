# DKScript Build Handshake v0.0.13

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Project

BASIC# language using the DKScript Ruby Bootstrap Compiler

## Version

v0.0.13

## Build name

Focused Runtime Stress Test and Contract Hardening

## Required base version

Accepted v0.0.12 Plain-Language Runtime Trace.

```text
commit 25c9265
tag v0.0.12
owner validation: 42 runs, 252 assertions, 0 failures, 0 errors, 0 skips
owner validation repeated twice on 2026-07-30
```

The corrected v0.0.13 package is an incremental changed-files-only patch over the exact `v0.0.12` tag.

## Target version

v0.0.13

## Corrected package filename

`DKScript_Ruby_Bootstrap_Compiler_v0_0_13_FOCUSED_RUNTIME_STRESS_TEST_AND_CONTRACT_HARDENING_CORRECTED_CHANGED_FILES_ONLY.zip`

## Rejected package warning

Earlier v0.0.13 archives are rejected. One was installed and passed all runtime tests but incorrectly included unchanged v0.0.12 files. It must not be committed, tagged, or used as a baseline.

The failure record is preserved at:

```text
docs/audit/BASIC_SHARP_v0_0_13_REJECTED_PACKAGE_AUDIT.md
```

## Active project path

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

## Download location expectation

```text
/home/dereksparks1982/Downloads/
```

## Exact scope completed

- Preserve all accepted v0.0.12 plain-language trace behavior.
- Stress hundreds of Things and thousands of events.
- Stress exact and direct-Kind Triggers together.
- Stress repeated `(damage`, `(change`, `(carry`, and startup `(unlock`.
- Prove event context stays local.
- Prove separate Runtime instances do not share state.
- Prove deterministic execution.
- Prove source and saved-BSharp IR parity under long event sequences.
- Add reusable `tools/runtime_stress.rb`.
- Add focused automated stress suite.
- Reject duplicate BSharp IR Thing names.
- Reject missing or unsupported BSharp IR format.
- Require runtime top-level BSharp IR fields to be lists.
- Add formal BSharp IR meaning contract.
- Log and evaluate Claude's review.
- Add Lisp research.
- Record `(` as the creator-facing visual guide for official words.
- Preserve the rejected package audit trail.
- Add a dedicated new-thread handoff for tomorrow.
- Advance active version surfaces to 0.0.13.
- Update README, contracts, roadmap, handoffs, changelog, patch notes, session log, validation, changed-files record, and manifest.

## Excluded work

- No new BASIC# syntax.
- No new official words.
- No Kind Families.
- No multiple selected Things.
- No event queue.
- No creator-facing values or amounts.
- No time or repetition language feature.
- No ASK implementation.
- No capitalization or source-spacing behavior change.
- No technical rename.
- No bytecode, VM, engine bridge, or self-hosting implementation.

## Code and test files touched

```text
compiler/ast_nodes.rb
compiler/runtime.rb
tests/test_cli_output.rb
tests/test_ir_output.rb
tests/test_runtime_stress.rb
tools/runtime_stress.rb
samples/first_room.bsir.json
```

The authoritative full path list is:

```text
docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_0_13.txt
```

## Risks

- BSharp IR validation is stricter; manually written JSON without the supported format is rejected.
- Duplicate normalized Thing names are rejected instead of silently overwriting.
- Direct Kind matching does not yet follow Kind Families.
- Exact rules are checked before direct-Kind rules.
- The first matching rule runs.
- One selected Thing is stored per Kind during one event.
- IF rules still run once during startup.
- Damage remains an internal integer count without creator-facing amount syntax.
- BSharp IR remains debug JSON rather than bytecode.
- Long-term BSharp IR version compatibility is not frozen.

## Rollback and repair plan

The user's current working tree contains the rejected, uncommitted v0.0.13 install. Restore tracked files to the accepted baseline before applying the corrected package:

```bash
git reset --hard v0.0.12
```

No accepted commit is removed. The rejected v0.0.13 candidate was never committed or tagged.

## Validation plan

```bash
for file in compiler/*.rb tools/*.rb; do ruby -c "$file"; done
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.bsir.json
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks henry"
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
ruby compiler/basic_sharp.rb samples/first_room.bsir.json --run "player attacks henry"
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
ruby tools/runtime_stress.rb
```

## Internal validation result

```text
Ruby syntax: PASS
Compiler sample: PASS
Compiler errors: 0
Compiler warnings: 0
Source/saved-BSharp IR trace parity: PASS
Automated suite: 54 runs, 4,330 assertions
Failures: 0
Errors: 0
Skips: 0
Standalone stress Things: 504
Standalone stress events per path: 10,002
Standalone total event executions: 20,004
Standalone stress: PASS
```

## Packaging validation

The final payload was generated from the actual file difference between a clean v0.0.12 tree and the v0.0.13 candidate.

Required checks:

- direct project-root layout;
- no wrapper folder;
- no deletion request;
- manifest format `BASIC_SHARP_CHANGED_FILES_PATCH` version 1;
- no unchanged v0.0.12 path in the archive;
- every packaged file listed in the changed-files record;
- every non-manifest file listed with exact byte count and SHA-256;
- extracted payload reproduces the tested v0.0.13 tree;
- compiler proof, automated suite, and standalone stress runner pass after clean overlay.

Internal corrected-overlay status: PASS.

## Owner validation status

Pending. The rejected package passed, but the corrected archive must be applied from `v0.0.12` and validated again before v0.0.13 is accepted.

## Current continuation point

1. Download the corrected package.
2. Reset the project to `v0.0.12`.
3. Apply the corrected package.
4. Run the complete validation command.
5. If it passes, commit and tag v0.0.13.
6. Resume tomorrow using `docs/hand_off/BASIC_SHARP_v0_0_13_NEW_THREAD_HANDOFF.md`.
7. Do not begin v0.0.14 without an exact proposal and Derek's explicit approval.

## Required input and artifacts for continuation

- accepted local Git tag `v0.0.12`;
- corrected v0.0.13 ZIP in `/home/dereksparks1982/Downloads/`;
- owner terminal output from the corrected validation run;
- current repository `git status` after validation.
