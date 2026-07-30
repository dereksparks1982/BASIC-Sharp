# BASIC# Build Handshake v0.1.15

## Project

BASIC# Ruby Bootstrap Compiler

## Build name

Inherited Kind Matching

## Required base

```text
version: v0.1.14
commit: 49f00f1
tag: v0.1.14
branch: main
working tree: clean
path: /home/dereksparks1982/DKLab/Projects/BASIC#
```

## Target version

```text
v0.1.15
```

## Package filename

```text
BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_15_INHERITED_KIND_MATCHING_CHANGED_FILES_ONLY.zip
```

## Completed changes

- Activated inherited matching through the existing one-parent Kind chain.
- Added direct, parent, grandparent, and root family matching.
- Preserved exact named-Thing Trigger priority.
- Added nearest-compatible-Kind priority for overlapping Kind Triggers.
- Preserved event-local context for `that Kind` when a descendant Thing is selected.
- Expanded resolver Kind candidates to include descendants.
- Allowed known rootless built-in Kinds to receive one direct parent through existing syntax.
- Rejected second parents and circular source families plainly.
- Rejected unknown and circular parent chains in saved BSharp IR safely.
- Preserved source and saved-BSharp IR parity.
- Preserved accepted v0.1.13 saved-BSharp IR execution.

## Explicit exclusions

- No multiple inheritance.
- No standalone root-declaration syntax.
- No new Heads, Connectors, or official words.
- No values, damage amounts, time, repetition, event queue, ASK, bytecode, VM, engine bridge, or self-hosting work.
- No Git commit or tag before Derek accepts the installed build.

## Validation result

```text
73 runs
4,421 assertions
0 failures
0 errors
0 skips
```

```text
504 Things
10,003 events through source-built BSharp IR
10,003 events through saved BSharp IR
20,006 total event executions
Inherited Kind matching: PASS
source/saved-BSharp IR parity: PASS
separate runtime isolation: PASS
deterministic final world: PASS
```

## Known risks

- A broad ancestor Trigger can overlap a nearer Kind Trigger. v0.1.15 resolves this by choosing the nearest family distance.
- Old BSharp IR receives only the parent links it stores. Missing historical parent declarations are not invented.
- The current model remains single-parent only.
- BSharp IR remains a debug contract whose permanent public compatibility is not yet frozen.
- The `#` in the project path must remain quoted in shell commands.

## Rollback point

```text
commit: 49f00f1
tag: v0.1.14
path: /home/dereksparks1982/DKLab/Projects/BASIC#
```

## Acceptance and Git step

Only after Derek validates and accepts v0.1.15:

```bash
cd '/home/dereksparks1982/DKLab/Projects/BASIC#'
git add -A
git commit -m "BASIC# v0.1.15 Inherited Kind Matching"
git tag v0.1.15
git status
```

## Current continuation point

After acceptance, commit, and tag, prepare the exact v0.1.16 **Kind-Family Stress and Hardening** proposal. Do not implement it without a new explicit build command.
