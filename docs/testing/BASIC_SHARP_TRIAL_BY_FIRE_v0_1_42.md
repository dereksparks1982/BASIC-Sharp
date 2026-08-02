# BASIC# Trial by Fire Complete Re-Carry v0.1.42

## Purpose

Trial by Fire validates the complete already-accepted Profiles 1–7 language. It adds test machinery, not language meaning. An implementation is wrong when it disagrees with Derek-approved specifications and the independently reviewed golden trace; agreement between two implementations is useful evidence but not sufficient by itself.

## Principal campaign

`samples/trial_by_fire.bsharp` combines deep Kind families, direct and inherited selection, hundreds of Things, state/relation/whole-number/exact-text facts, exact and inherited event matching, `every #Kind`, `that #Kind`, follow-up events, reactive compound conditions, IF/OTHERWISE transitions, controls, platform declarations, Save/restore, and ASK.

The fixed event campaign and expected world after each event are sealed in `spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_GOLDEN_TRACE_v1.json`. The expected event order and state transitions were reviewed from the Stable Meaning Specifications. The trace is not generated during validation.

## Deterministic valid-program generator

- Re-carried recorded campaign seed: `11862336` (`0xB50140`), preserved from the failed v0.1.40 candidate so the same adversarial campaign remains directly comparable.
- Inventory: 256 programs.
- Profiles: v1–v4 each have 37 cases; v5–v7 each have 36.
- Variations: Kind depth, Thing count, initial values, damage, movement speeds, connector, exact text, event priority, action order, branch behavior, and selection size.
- Required parity: source and saved BSIR resolve to the expected profile; repeated compilation produces byte-identical BSBC and disassembly; source, saved-BSIR runtime, and BSharp VM produce identical event results and final worlds.

The sealed coverage matrix records every case and its feature tags.

## Complete version-bearing fixture gate

The prepackage inventory includes every known fixture whose expected bytes contain or depend on `BasicSharp::VERSION`: creator-facing text Save, number changes, compound IF, and OTHERWISE. A numbered build must regenerate all of them together and run every owning stress tool before the package is sealed.

## Native hammer phases

| Phase | Required default |
|---|---:|
| Events | 100,000 per source, saved-BSIR, and preferred-VM path, plus a repeated VM run |
| Platform movement | 100,000 frames |
| Read-only ASK | 25,000 questions |
| Save/restore | 1,000 checkpoints |
| World isolation | 256 simultaneously live worlds |
| Follow-up events | 1,023, 1,024, and 1,025 requested follow-ups |
| Valid programs | 256 |
| Mutations | 2,048 at each of four boundaries |
| Truncation | Every truncated prefix of the principal BSBC |

Existing focused/stress tools remain mandatory for large IF cascades, cycles, rearming, alternating OTHERWISE branches, deep ancestry, large/empty selections, overflow, underflow, missing values, and failed atomic actions.

## Hostile artifact rules

Source, saved BSIR, BSharp Save, and BSBC each receive 2,048 deterministic mutations. Rejection must be bounded, atomic, deterministic, and explanatory. A rejection may not mutate a live world, silently repair an artifact, emit a stack trace through the installer, or produce a partial Save.

## Regression capsules

Any discovered accepted-semantics defect must be minimized and added under `spec/trial_by_fire/regressions/` before repair. The index is authoritative. This build found no defect requiring a core semantic repair.

## Commands

```bash
ruby tools/trial_by_fire_generator.rb
ruby tools/trial_by_fire_mutation.rb
ruby tools/trial_by_fire_gauntlet.rb
```

Environment variables may reduce counts for developer preflight. Native installer acceptance uses the exact defaults above and does not set reduced values.
