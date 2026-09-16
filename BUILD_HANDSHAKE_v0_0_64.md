# BASIC# v0.0.64 Build Handshake

## Build

BASIC# v0.0.64 Self-Hosting Execution Expansion and Release Gate Hardening

## Accepted base

```text
v0.0.63
a1ca9501f49f51b937bb6c736824dd96568a5f0b
```

## Purpose

Expand small compiler subset BSBC execution parity while adding release gates that prevent stale deterministic hashes, sealed inventory drift, and payload manifest mismatches from reaching Derek.

## Guardrails

No DKLab bridge removal. No BCS implementation. No Profile 8. No syntax change. No runtime behavior change. Ruby remains the bootstrap compiler and referee. BASIC# is not fully self-hosted.

## Validation

The candidate is acceptable only when the exact changed-files package completes full native installer validation on Derek's machine.
