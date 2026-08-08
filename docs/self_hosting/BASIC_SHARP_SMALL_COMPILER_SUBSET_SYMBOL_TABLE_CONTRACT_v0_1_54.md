# BASIC# Small Compiler Subset Symbol Table Contract v0.1.55

v0.1.55 adds a symbol-table contract for the small compiler subset while Ruby remains the parser, resolver, compiler, runtime, and referee authority.

The contract records deterministic symbol tables for approved BASIC# subset examples. It tracks:

- Kinds
- Things / objects
- Official action words used by subset results
- Value names found in approved `has` forms
- Scene heads for WHEN and IF blocks

It also locks plain-English errors for duplicate names and unknown references. These errors are contract-level records for the small compiler subset. They do not replace the production Ruby compiler path.

## ByteTide decision record

`ByteTide` was considered as a creator-facing metaphor for the flow of words becoming executable meaning. The idea was passed on for now because bytecode, BSBC, bytecode profiles, bytecode emitter, bytecode loader, and bytecode VM are already stable across tools, specs, tests, fixtures, manifests, and validation.

Decision: do not rename the system.

Status: optional metaphor only, not an official system term.

## Non-goals

- No Profile 8.
- No bytecode rename.
- No BSBC rename.
- No runtime changes.
- No Ruby retirement.
- No claim that BASIC# is self-hosted.

## Validation

The following gate must pass:

`ruby tools/small_compiler_subset_symbol_table_contract.rb`

Self-hosting spec: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
