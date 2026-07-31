# BASIC# BSharp Bytecode Compatibility Policy v0.1.26

## Stable promise

An implementation claiming `bsharp.bytecode.v1` must preserve the identities, binary geometry, ordering, instruction operands, selector contexts, condition operands, malformed-artifact rejection, and Profile 1 meaning defined by the machine contract.

## Meaning compatibility

BSBC is compatible only when its required meaning profile and normalized meaning fingerprint match the program expected by the runtime and any BSharp Save being loaded.

## Allowed implementation freedom

Compilers and VMs may change internal classes, data structures, caching, optimization, and host language. They may not change observable Profile 1 meaning or the bytes required by the same normalized meaning.

## Breaking changes

A breaking bytecode change requires:

- Derek's explicit approval;
- a new numeric BASIC# build;
- a new bytecode profile or binary format version;
- migration and rejection rules;
- new deterministic fixtures and validation;
- updated canonical Company Bible identity only when protected names or permanent workflow rules change.

## v0.1.26 boundary

This build freezes Contract 1 only. It does not promise that an emitter, loader, or VM exists yet. Those components must claim and prove conformance separately.
