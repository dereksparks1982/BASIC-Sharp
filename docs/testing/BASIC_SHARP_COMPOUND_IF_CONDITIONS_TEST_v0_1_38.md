# BASIC# Compound IF Conditions Test v0.1.38

Mandatory coverage includes parsing outside quoted text, `and` all-clause truth, `or` any-clause truth, startup truth, false-to-true crossing, quiet-while-true behavior, rearming, source order, state/relation/text/number/threshold combinations, malformed mixed connectors, incomplete clauses, Save format 6, ASK, restore, direct VM execution, reference parity, and runtime-transition shadow parity.

`tools/compound_if_stress.rb` performs 5,000 cycles and 20,000 events per runtime across both connectors while comparing every source-runtime result with the direct BSharp VM result. `tests/test_bytecode_profile_6.rb` also recompiles every committed Profile 1–5 sample and requires exact binary and disassembly bytes.
