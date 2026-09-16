# BASIC# v0.0.34 Rejected Build Audit

**Date:** 2026-07-31  
**Status:** Preserved failure record  
**Accepted baseline:** v0.0.32, commit `3566b02`, tag `v0.0.32`

## What passed

Derek installed the v0.0.34 changed-files package from the exact accepted v0.0.32 base. Base Git identity, clean tree, base and payload hashes, the exact 106-modified and 68-added path installation, Ruby syntax, JSON parsing, and the complete suite passed. The suite reported:

```text
369 runs
7,692 assertions
0 failures
0 errors
0 skips
```

Every focused lane through `tools/bytecode_vm_stress.rb` also passed, including the v0.0.33 emitter repair.

## Failure

The next lane stopped at:

```text
Direct BSBC remains BSharp VM: FAIL
```

The direct `.bsbc` CLI route was still implemented by `BasicSharp::BytecodeVirtualMachine` and correctly reported `BSharp Virtual Machine v0.0.34`. The standalone validator still searched for the retired literal `BSharp Virtual Machine v0.0.32`, so it falsely reported a runtime-route failure. Its later reference-runtime check also retained `BASIC# Runtime v0.0.32` and would have produced the next false failure.

## Recovery

The rollback-safe installer restored every modified v0.0.32 file and removed every v0.0.34 added path. v0.0.34 was not accepted, committed, tagged, or used as a baseline.

## Corrective action

v0.0.35 re-carries the complete Profile 3 work from accepted v0.0.32, binds both version-sensitive runtime banner checks to `BasicSharp::VERSION`, adds a regression gate against pinned runtime banners, tightens the direct `.bsbc` CLI assertion, and retains the complete validation order so later lanes are still exercised.
