# BASIC# Self-Hosting Foundation v0.0.44

## Purpose

v0.0.44 re-carries the self-hosting lane after the rejected v0.0.43 package and starts it without pretending BASIC# can replace Ruby yet. It defines **BSharp Compiler Subset 0**, the first compiler-writing contract for future BASIC# compiler work.

Status: `foundation_contract_only`.

Ruby remains the bootstrap compiler and reference authority. BASIC# is not self-hosted in this build.

## Why this comes first

The BSharp native document app and future application tools should be built with BASIC# when BASIC# is strong enough to carry that load. The next old-school step is making BASIC# capable of describing and validating pieces of its own compiler in a controlled subset.

That means the project needs a contract before code starts moving:

- what the future compiler subset may use;
- what it must not claim yet;
- what validation proves;
- where Ruby still referees the result.

## BSharp Compiler Subset 0

Subset 0 is a planning and validation contract, not a new runtime profile. Creator-facing programs still use accepted Meaning Profiles 1 through 7.

Allowed in this foundation:

- deterministic token-record and compiler-data contracts;
- JSON specifications for future compiler pieces;
- examples marked as future sketches, not executable compiler code;
- existing accepted BASIC# visual grammar as the creator surface to preserve.

Forbidden until later approval:

- replacing the Ruby bootstrap compiler;
- claiming BASIC# is self-hosted;
- Profile 8;
- new creator syntax;
- new bytecode instructions;
- loops;
- functions or reusable user-defined words;
- collections;
- string concatenation or interpolation;
- native code generation;
- engine bridge work;
- BSharp native document application work.

## Validation authority

The executable contract is:

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
tools/self_hosting_contract.rb
tests/test_self_hosting_contract.rb
```

The contract tool must run inside the Trial-by-Fire validation inventory. If this spec drifts, the installer must stop before acceptance.

## Future sequence

1. v0.0.44 records v0.0.43 as rejected, then freezes this contract and validation gate.
2. Next build may define the BASIC# tokenizer/reader contract and fixtures.
3. Later builds may implement tokenizer pieces while Ruby verifies the records.
4. Later builds may parse a small approved compiler subset into BSharp IR.
5. Only after locked parity may BASIC# emit BSBC for compiler code.
6. Ruby is removed only after BASIC# reproduces approved compiler outputs under hard validation.

That is the runway. No costume, no shortcut, no fake victory lap.
