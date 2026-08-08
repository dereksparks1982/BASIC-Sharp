# BASIC# Build Handshake v0.1.61

## Identity

- Version: v0.1.61
- Name: Small Compiler Subset Error Contract
- Required base: v0.1.51
- Required commit: `2962fa19b3e452e529ac7166ad3e751bf621cde4`
- Required tag: `v0.1.51`
- Required branch: `main`
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_52_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_CHANGED_FILES_ONLY.zip`

## Scope

Add a non-production plain-English error contract for invalid small compiler subset examples. The contract locks stable error IDs, line numbers, severities, creator-facing explanations, underlying Ruby-referee diagnostics, and per-fixture digests.

## Explicit exclusions

No Profile 8. No new syntax. No runtime changes. No BSharp Bytecode changes. No web export. No browser. No engine bridge. No Ruby retirement. No production parser/compiler replacement.

## Rollback

If any installer phase fails after mutation begins, the installer restores the exact v0.1.51 base files and removes candidate v0.1.61 added paths.

## Acceptance

The package is accepted only after the installer reports full native validation PASS on Derek's machine, then Derek commits the exact tree and tags `v0.1.61`.

## Documentation repair scope

This repaired package also adds the BASIC# Five Point Paradigm to the canonical Company Bible and adds `docs/BASIC_SHARP_DOCUMENTATION_MAP.md` as the documentation front door. These are documentation-only doctrine/navigation changes and do not change runtime, bytecode, syntax, Profile 8, web export, browser, engine bridge, or Ruby retirement status.
