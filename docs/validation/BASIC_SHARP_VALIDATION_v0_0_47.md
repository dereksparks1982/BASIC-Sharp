# BASIC# Validation v0.0.47

## Build

- Version: v0.0.47
- Title: Tokenizer/Reader Contract and Universal Standard Doctrine
- Required base: v0.0.46 commit `b4d8ea2c5274e63cab3de6e6fcf003e2aef25a35`
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_0_47_TOKENIZER_READER_CONTRACT_CHANGED_FILES_ONLY.zip`

## Local candidate validation

Candidate validation was run in the build workspace with Ruby 3.3.8 and UTF-8 locale.

```text
Ruby syntax: PASS
JSON parsing: PASS
sealed validation inventory: PASS
complete test suite: PASS (464 runs, 8069 assertions, 0 failures, 0 errors, 0 skips)
```

Required tools were run successfully except that the hosted workspace could not complete the full native Trial-by-Fire gauntlet inside the available execution window. The installer remains configured to run the full native gauntlet on Derek's machine.

Confirmed required tool results include:

```text
tools/runtime_stress.rb: PASS
tools/kind_family_stress.rb: PASS
tools/if_rule_stress.rb: PASS
tools/multiple_selection_stress.rb: PASS
tools/value_amount_stress.rb: PASS
tools/follow_up_event_stress.rb: PASS
tools/world_save_stress.rb: PASS
tools/ask_stress.rb: PASS
tools/meaning_conformance.rb: PASS
tools/meaning_profile_2.rb: PASS
tools/meaning_profile_3.rb: PASS
tools/meaning_profile_4.rb: PASS
tools/meaning_profile_5.rb: PASS
tools/meaning_profile_6.rb: PASS
tools/meaning_profile_7.rb: PASS
tools/company_bible_audit.rb: PASS
tools/self_hosting_contract.rb: PASS
tools/tokenizer_reader_contract.rb: PASS
tools/bytecode_contract.rb: PASS
tools/bytecode_emitter.rb: PASS
tools/bytecode_loader.rb: PASS
tools/bytecode_virtual_machine.rb: PASS
tools/bytecode_profile_4.rb: PASS
tools/bytecode_profile_5.rb: PASS
tools/bytecode_profile_6.rb: PASS
tools/bytecode_profile_7.rb: PASS
tools/bytecode_vm_stress.rb: PASS
tools/runtime_transition.rb: PASS
tools/text_value_stress.rb: PASS
tools/demon_killer_input_stress.rb: PASS
tools/game_interaction_stress.rb: PASS
tools/comment_stress.rb: PASS
tools/platform_movement_stress.rb: PASS
tools/number_change_stress.rb: PASS
tools/compound_if_stress.rb: PASS
tools/otherwise_branch_stress.rb: PASS
tools/trial_by_fire_inventory.rb: PASS
tools/input_device_contract.rb: PASS
```

A reduced-count Trial-by-Fire smoke gauntlet passed in the build workspace:

```text
Counts: events=100/path frames=100 ASK=100 saves=10 worlds=8 programs=8 mutations=16/boundary
results_sha256: a06b9603028986751da4725631adced92fceb3e8bd19e9b2239545a5beeb7722
BASIC# v0.0.47 TRIAL BY FIRE: PASS
```

## Version-bearing fixture hashes

```text
Text-value Save:       72e310064d4147a95c5d18707cbbc0a2f5a8e4c862704f222260800c775d3a4e
Number-change result: 26a17995fa4868790f3d37d1144fe49b0746550ddd367961fb93e18aad018a20
Compound-IF result:   73b144f50a1c17508a081555dc7cdee59134beffcd3cbd4f03e8b60f85725506
OTHERWISE result:     e02918d368a3b124d611eddefd916168b06f43bd4d4c8e62ec9aadc91a84804b
```

## Owner-side required validation

Derek's installer must run from exact clean v0.0.46 commit `b4d8ea2c5274e63cab3de6e6fcf003e2aef25a35` and tag `v0.0.46`.

The package is not accepted until the installer reports full native PASS on Derek's machine.
