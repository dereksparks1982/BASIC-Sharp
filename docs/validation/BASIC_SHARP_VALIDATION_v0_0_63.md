# BASIC# Validation v0.0.63

Validation target:

```text
BASIC# v0.0.63 UTF-8 Source Hardening, Elderedd Path Proof, and Small Compiler Subset BSBC Execution Parity
```

Required validation:

- Ruby syntax
- JSON parsing
- sealed validation inventory
- complete test suite
- UTF-8 source reading contract under minimal/no-locale Ruby
- Elderedd identity contract
- Elderedd path bridge contract
- self-hosting contract chain
- small compiler subset BSBC execution parity
- full stress tool inventory
- full Trial by Fire gauntlet

Acceptance requires zero failures, zero errors, zero skips, zero stderr, and installer-side proof on Derek's machine.

## Repaired Candidate Sweep

The first v0.0.63 candidate was rejected by `tools/text_value_stress.rb` because the sealed Text Value save fixture hash was stale after the v0.0.63 version/save identity change.

The second v0.0.63 candidate was rejected by `tools/number_change_stress.rb` because only the first exposed fixture hash had been repaired.

The accepted repair strategy for the next candidate is a full deterministic runtime fixture-family sweep: Text Value, Number Change, Compound IF, and OTHERWISE fixture specs and matching expected sample documents must be carried together. The same v0.0.63 version number is preserved because no v0.0.63 package has been accepted, committed, or tagged.


The third v0.0.63 candidate was rejected during sealed validation inventory because sealed documentation bytes changed after the inventory was generated.

The accepted repair strategy for the next candidate is a forensic package sweep: update every sealed validation inventory byte count and SHA-256 against the exact install tree, then update every package manifest payload record against the exact ZIP payload before release.
