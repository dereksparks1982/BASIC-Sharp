# BASIC# Validation v0.0.37

## Required native acceptance result

```text
minimum runs: 394
minimum assertions: 7,791
failures: 0
errors: 0
skips: 0
Ruby warnings/stderr: 0
```

Every established Profile 1 through Profile 4 test and tool remains mandatory. Profile 5 additionally requires:

```text
tools/meaning_profile_5.rb
tools/bytecode_profile_5.rb
tools/number_change_stress.rb
```

Required proofs include source/BSIR/BSBC parity, direct BSharp VM/reference parity, ASK, Save format 5 restore, all four threshold boundaries, IF crossing/rearming, missing-value and type errors, set atomicity, overflow/underflow atomicity, 20,000 repeated changes, and byte-identical preservation of committed Profile 1 through Profile 4 BSBC and disassembly.

The installer must verify clean `main` at commit `ef43056`, tag `v0.0.36`, every base and payload hash, exact scope, the complete native suite, every focused/stress lane, and automatic exact rollback to v0.0.36 after any post-mutation failure.

Exact project scope: 45 modified, 51 added, 0 deleted; 96 paths total.

## Completed build-environment validation

- Ruby syntax compilation: PASS for all compiler, test, and tool files.
- JSON parsing: PASS for all project JSON files.
- Focused Profile 5 tests: PASS (10 runs, 36 assertions).
- Complete in-environment suite: 394 tests discovered; every executable assertion passed. Thirty-four native-bound tests stop only where WebAssembly lacks process pipes, atomic rename, or host temporary-directory behavior.
- Meaning Profile 5: PASS (10 cases).
- BSharp Bytecode Profile 5 contract, fixture hashes, loading, disassembly, and direct VM execution: PASS.
- Number-change stress: PASS (10,000 increases plus 10,000 decreases per runtime path).
- Every executable default-count established stress lane: PASS.
- Profile 1 through Profile 4 committed BSBC and disassembly reproduction: byte-identical PASS.
- Native process-pipe, atomic-rename, complete aggregate, exact Git-scope, and rollback gates remain mandatory in Derek's installer.
