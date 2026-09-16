# BASIC# Self-Hosting Milestone 2 Proposal v0.0.72

## Status

Proposal only. This document does not implement Self-Hosting Milestone 2.

## Accepted truth

Self-Hosting Milestone 1 remains the accepted milestone: BSharp Compiler Subset 0 has reader, parser, IR emitter, BSBC emitter, fixture corpus, parity harnesses, runtime smoke lane, bootstrap boundary audit, and milestone gate under Ruby referee control.

Ruby remains the bootstrap compiler and reference referee. BASIC# is not fully self-hosted.

## Milestone 2 direction

Milestone 2 should be the first bigger forward slice after the v0.0.71 no-locale repair. It should add real compiler capability or self-hosting fixture depth instead of another broad governance layer.

Preferred implementation candidates for the next build:

1. Add one bounded compiler-subset feature that makes BASIC#-authored compiler fixtures more realistic.
2. Expand the execution corpus with BASIC#-authored source fixtures that travel through reader, parser, IR, BSBC, and VM parity.
3. Keep Ruby as referee authority while proving deterministic equality at every accepted boundary.
4. Avoid Profile 8, object interaction, BCS, server, pricing, or runtime-meaning changes unless Derek explicitly approves a different lane.

## Guardrails

- No Ruby retirement claim.
- No full self-hosting claim.
- No object interaction in this proposal build.
- No new syntax in this proposal build.
- No governance layer unless it repairs a proven failure.

## Relationship to game-making

Game-making forward motion remains important. If Derek chooses game power next, v0.0.73 may pivot to object interaction instead of implementing the first Milestone 2 slice.
