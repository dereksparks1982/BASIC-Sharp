# BASIC# Validation v0.1.68

Required validation includes the full Ruby test suite, all stress tools in the sealed Trial by Fire inventory, deterministic fixture hash sweep, release package preflight, `tools/plain_english_movement_intent.rb`, and `tools/plain_english_input_mapping.rb`.

Repair validation note:
- Initial candidate failed `tools/text_value_stress.rb` at `Save fixture hash`. The repaired candidate reseals the full stale fixture family found during repair: Profile 2 text-value save hash, Profile 5 number-change expected hash, Profile 6 compound-IF expected hash, and Profile 7 OTHERWISE expected hash. The repaired candidate reruns the deterministic fixture family before acceptance testing.
