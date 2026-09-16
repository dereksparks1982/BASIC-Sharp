# BSharp VM Hardening v0.0.42

## Protected compatibility

BSharp Bytecode Profiles 1–7, their instructions, fingerprints, section layouts, committed `.bsbc` bytes, and deterministic disassemblies are unchanged. Fourteen protected artifacts are sealed in the validation inventory.

## Adversarial boundary

The campaign attacks magic, format versions, profile declarations, fingerprints, section counts, offsets, lengths, duplicate section identifiers, overlapping sections, unknown sections, appended bytes, malformed records, wrong BSIR/Save types and references, reordered objects/rules, unsupported older-profile features, invalid UTF-8 source, and every truncated principal BSBC prefix.

Every loader/restore rejection must finish within the enclosing validation phase, provide a nonempty first-line reason, and leave any existing world unchanged. No mutation is accepted by silent correction.

v0.0.42 changes no opcode, section, bytecode profile, optimizer, JIT, native execution feature, or accepted meaning. Its repair is limited to complete version-bearing runtime-fixture regeneration, validation evidence, workflow law, version identity, and the full Trial-by-Fire re-carry.
