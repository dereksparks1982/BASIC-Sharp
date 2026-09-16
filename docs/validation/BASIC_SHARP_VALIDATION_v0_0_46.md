# BASIC# Validation v0.0.46

## Build-environment validation

Native Ruby is not available in the packaging workspace. Ruby-WASM is used for focused input-device, contract, and fixture checks. Owner-side native Ruby remains the acceptance authority.

v0.0.46 also records v0.0.45 as rejected. The native failure was a timing/isolation error in the Xbox jump test, not a rejected controller-mapping design.

Required build-workspace checks:

- Complete Company Bible reread.
- JSON parsing for package records and input-device spec.
- Input device contract.
- Focused movement/input tests.
- Platform movement stress.
- Demon Killer input stress.
- Trial-by-Fire sealed validation inventory.
- Fresh extraction and package manifest verification.
- Installer source NUL-byte verification before delivery.

Completed in the build workspace:

- Input device contract: PASS.
- Focused platform movement input tests: PASS.
- Focused Demon Killer/top-down input tests: PASS.
- Input device contract test: PASS.
- Platform movement stress: PASS.
- Demon Killer input stress: PASS.
- Text value, number change, compound IF, and OTHERWISE fixture stress gates at reduced counts: PASS.
- Trial-by-Fire sealed validation inventory: PASS.
- Company Bible audit: PASS.

## v0.0.46 version-bearing fixture hashes

```text
Text-value Save:       d017c872c42cf19681f4cc1d12294b89d3590d779ff11a254d6d475fb06a2f4a
Number-change result: 5aff7cf11f60937e0f2b1f9d1551b07b65442ca3791e5c70385c7b08d246dd76
Compound-IF result:   4b26523add4393d83923796fcf1b6000cbea590fcd685862a0e4afdb3d4053ae
OTHERWISE result:     e7bf4ea88b6785fb2bc75979c665be1aaca0d9129d6e27b017c0b418187c4f6e
```

## Repaired package correction

The first v0.0.46 changed-files-only package was rejected because version-bearing fixture hashes were stale. This repaired package records the native Ruby v0.0.46 fixture hashes and is the only v0.0.46 package that should be installed from the rescued v0.0.44 base.

## Required native acceptance

The v0.0.46 installer must run from exact accepted v0.0.44 commit `b630b031666a527d8549e6715e59065071a3efd0`, tag `v0.0.44`, clean `main`.

It must pass:

- Ruby syntax with warnings as failures;
- JSON parsing;
- sealed Trial-by-Fire validation inventory;
- complete test suite with zero failures, errors, skips, warnings, or stderr;
- every inventory-listed tool, including `tools/input_device_contract.rb`;
- the full native Trial-by-Fire gauntlet from the beginning.

Any post-mutation failure restores exact v0.0.44. Derek acceptance requires native PASS, commit, tag `v0.0.46`, clean tree, and accepted full-project snapshot.
