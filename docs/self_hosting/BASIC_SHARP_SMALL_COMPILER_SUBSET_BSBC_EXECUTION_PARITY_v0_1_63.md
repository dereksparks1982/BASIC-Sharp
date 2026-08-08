# BASIC# v0.1.63 Small Compiler Subset BSBC Execution Parity

## Status

Implemented in v0.1.63 candidate under Ruby referee control.

## Purpose

This lane proves that approved small compiler subset programs can travel through:

```text
BASIC# source -> BSharp IR -> BSBC bytes -> BSharp Virtual Machine execution
```

and match the Ruby referee runtime for:

- event results;
- final world snapshots;
- BSharp Save documents;
- matched event counts.

## Guardrails

This is not full self-hosting. Ruby remains the bootstrap compiler, production parser authority, production resolver authority, runtime authority, and reference referee.

This build does not add Profile 8, does not rename bytecode or BSBC, does not change production runtime behaviour, and does not remove the DKLab compatibility bridge.

## Files

```text
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
compiler/small_compiler_subset_bsbc_execution_parity.rb
tools/small_compiler_subset_bsbc_execution_parity.rb
tests/test_small_compiler_subset_bsbc_execution_parity.rb
```

## Compatibility

The lane is part of the Elderedd migration proof. Elderedd is the active identity. DKLab is retired and remains only as compatibility, rollback, migration, or archival history.
