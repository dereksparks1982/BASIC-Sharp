# BASIC# Build Handshake v0.1.63

## Identity

- Version: v0.1.63
- Name: Small Compiler Subset IR Golden Parity Harness
- Required base: v0.1.50
- Required commit: `8506fcec102c9ab0c7f8577a03414abb721d7a5a`
- Required tag: `v0.1.50`
- Required branch: `main`
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_52_IR_GOLDEN_PARITY_HARNESS_CHANGED_FILES_ONLY.zip`

## Scope

Add a non-production golden parity harness that locks deterministic BSharp IR SHA256 digests for the small compiler subset and compares them against the Ruby Parser plus SemanticResolver referee.

## Explicit exclusions

No Profile 8. No new syntax. No runtime changes. No BSharp Bytecode changes. No web export. No browser. No engine bridge. No Ruby retirement. No production parser/compiler replacement.

## Rollback

If any installer phase fails after mutation begins, the installer restores the exact v0.1.50 base files and removes candidate v0.1.63 added paths.

## Acceptance

The package is accepted only after the installer reports full native validation PASS on Derek's machine, then Derek commits the exact tree and tags `v0.1.63`.
