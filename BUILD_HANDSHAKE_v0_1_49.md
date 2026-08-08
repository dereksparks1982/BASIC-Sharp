# BASIC# Build Handshake v0.1.49

## Build

- Version: v0.1.49
- Title: Small Compiler Subset Parser Under Ruby Referee
- Required base: v0.1.48 commit `c67c74251aaa58e4f2fcded1144ea5187eebfb25`
- Required tag: `v0.1.48`
- Package type: changed-files-only ZIP

## Scope

Add a non-production small compiler subset parser implementation that reads TokenizerReader records and compares deterministic subset records against the existing Ruby Parser referee.

## Exclusions

No Profile 8, new creator syntax, production parser migration, runtime behavior change, BSharp IR change, BSharp Bytecode change, Save or ASK change, input-device behavior change, web export, browser work, engine bridge, or Ruby retirement.

## Acceptance

The package is accepted only after the installer reports full native validation PASS on Derek's machine, then Derek commits the exact tree and tags `v0.1.49`.
