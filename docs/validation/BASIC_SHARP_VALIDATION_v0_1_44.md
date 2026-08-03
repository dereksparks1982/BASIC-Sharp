# BASIC# Validation v0.1.44

## Build-environment validation

Native Ruby is not available in the packaging workspace. Ruby-WASM was restored for focused contract and fixture checks, but owner-side native Ruby remains the acceptance authority.

Completed in the build workspace:

- Complete Company Bible reread.
- v0.1.44 version-bearing fixture audit.
- Runtime-generated fixture hashes reproduced with `BasicSharp::VERSION` forced to `0.1.44`.
- JSON parsing for package records.
- Self-hosting contract added to Trial-by-Fire inventory.
- Fresh extraction and package manifest verification.
- Installer source NUL-byte verification required before delivery.

## v0.1.44 version-bearing fixture hashes

```text
Text-value Save:       410f9b77ec4d58485c693ba0bc6439808d312da43e9ead1006baf2498d2ed6e8
Number-change result: c3156c0b7df4730cf3534c93fe88235f433dc6e01ff2910a5dc8bc36cee64963
Compound-IF result:   d67504e22737c0e79ca299c09cce53a8a966479d2fc81e9d3b26d60ac507d597
OTHERWISE result:     b9e68aef8cd1faa764333edfa0f9b730c3289e64dc895212ca6ff72fa7002969
```

## Required native acceptance

The v0.1.44 installer must run from exact accepted v0.1.42 commit `1d79a6221a388ffd6e372d6bfe21d9df1cb38c2c`, tag `v0.1.42`, clean `main`.

It must pass:

- Ruby syntax with warnings as failures;
- JSON parsing;
- sealed Trial-by-Fire validation inventory;
- complete test suite with zero failures, errors, skips, warnings, or stderr;
- every inventory-listed tool, including `tools/self_hosting_contract.rb`;
- the full native Trial-by-Fire gauntlet from the beginning.

Any post-mutation failure restores exact v0.1.42. Derek acceptance requires native PASS, commit, tag `v0.1.44`, clean tree, and accepted full-project snapshot.
