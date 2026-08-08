# BASIC# Build Handshake v0.1.50

## Identity

- Version: v0.1.50
- Title: Small Compiler Subset Emits BSharp IR Under Ruby Referee
- Required base: v0.1.50
- Required commit: `936c01340c518af655fce21f11d9b99f1863f3f1`
- Required tag: `v0.1.50`
- Required branch: `main`
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_50_SMALL_COMPILER_SUBSET_IR_EMITTER_CHANGED_FILES_ONLY.zip`

## Scope

Add a non-production small compiler subset BSharp IR emitter that consumes the v0.1.50 parser path, emits BSharp IR for sealed fixtures, and verifies the output against the Ruby Parser plus SemanticResolver referee.

## Exclusions

No Profile 8, new creator syntax, production compiler migration, runtime behavior change, BSharp Bytecode change, Save/ASK behavior change, input-device change, web export, browser work, engine bridge, or Ruby retirement.

## Rollback

If any installer phase fails after mutation begins, the installer restores the exact v0.1.50 base files and removes candidate v0.1.50 added paths.

## Acceptance

The package is accepted only after the installer reports full native validation PASS on Derek's machine, then Derek commits the exact tree and tags `v0.1.50`.
