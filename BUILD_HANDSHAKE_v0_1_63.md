# BASIC# v0.1.63 Build Handshake

## Build title

BASIC# v0.1.63 UTF-8 Source Hardening, Elderedd Path Proof, and Small Compiler Subset BSBC Execution Parity

## Required base

- Base version: v0.1.62
- Base commit: e6b777669c48c6c516c5b7e875745407ee75129c
- Base tag: v0.1.62
- Branch: main
- Required tree: clean

## Scope

- Harden BASIC# source, BSharp IR JSON, BSharp Save JSON, and text fixture reads to explicit UTF-8.
- Add a minimal/no-locale UTF-8 source reading contract so non-ASCII creator text cannot crash source parsing under Ruby's US-ASCII default.
- Consolidate the roadmap's current continuation lane into one readable v0.1.63 section.
- Keep Elderedd as the active identity.
- Keep DKLab retired as compatibility/history only.
- Prove the canonical Elderedd path direction while preserving the DKLab compatibility bridge.
- Add small compiler subset BSBC execution parity under Ruby referee control.

## Exclusions

No parser meaning change, runtime meaning change, language syntax change, Profile 8, bytecode rename, BSBC rename, bridge removal, BCS implementation, servers, accounts, payments, Project Oracle, or Demon Killer work.

## Rollback

Installer rollback restores exact v0.1.62.

## Repaired Candidate Sweep

The first v0.1.63 candidate was rejected by `tools/text_value_stress.rb` because the sealed Text Value save fixture hash was stale after the v0.1.63 version/save identity change.

The second v0.1.63 candidate was rejected by `tools/number_change_stress.rb` because only the first exposed fixture hash had been repaired.

The accepted repair strategy for the next candidate is a full deterministic runtime fixture-family sweep: Text Value, Number Change, Compound IF, and OTHERWISE fixture specs and matching expected sample documents must be carried together. The same v0.1.63 version number is preserved because no v0.1.63 package has been accepted, committed, or tagged.


The third v0.1.63 candidate was rejected during sealed validation inventory because sealed documentation bytes changed after the inventory was generated.

The accepted repair strategy for the next candidate is a forensic package sweep: update every sealed validation inventory byte count and SHA-256 against the exact install tree, then update every package manifest payload record against the exact ZIP payload before release.
