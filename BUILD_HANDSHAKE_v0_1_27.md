# BASIC# Build Handshake v0.1.27

## Identity

```text
Project: BASIC# Ruby Bootstrap Compiler
Target: v0.1.27
Build: BSharp Bytecode Emitter and Deterministic Disassembly 1
Required base: v0.1.26
Required commit: 479db66
Required tag: v0.1.26
Branch: main
Package: BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_27_BSHARP_BYTECODE_EMITTER_AND_DETERMINISTIC_DISASSEMBLY_1_CHANGED_FILES_ONLY.zip
```

## Completed

- Real deterministic `.bsbc` emission from `.bsharp` and `.bsir.json`.
- Deterministic `.bsbc.txt` disassembly.
- Canonical Profile 1 lowering and ordering.
- Atomic binary/text output pair.
- Six committed sample pairs and machine-readable fixture hashes.
- Emitter tests and validation lane.

## Excluded

Loader, VM, bytecode execution, Ruby runtime replacement, optimization, compression, new language behavior, editor, IDE, engine bridge, self-hosting, and business systems.

## Changed scope

```text
26 modified paths
25 added paths
0 deleted paths
51 project paths total
```

See `docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_1_27.txt`.

## Validation

```text
253 runs
5,534 assertions
0 failures
0 errors
0 skips
```

All eight established stress lanes, Meaning Profile 1, Company Bible audit, Bytecode Contract audit, Bytecode Emitter lane, artifact parity, scope, and rollback proofs pass.

## Risks

- Loader and execution remain deliberately absent.
- The emitted format is limited to accepted Meaning Profile 1.
- A future format-breaking change requires a new bytecode profile and migration plan.

## Rollback

```text
git reset --hard 479db66
git clean -fd
```

## Continuation

After owner installation, acceptance, commit, and tag, the next eligible proposal is BSharp Bytecode Loader and Complete Validation 1.
