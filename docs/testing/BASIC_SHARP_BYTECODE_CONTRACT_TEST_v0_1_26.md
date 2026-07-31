# BASIC# Bytecode Contract Test v0.1.26

## Command

```bash
ruby tools/bytecode_contract.rb
```

## Automated coverage

`tests/test_bytecode_contract.rb` verifies:

- exact artifact identity, magic bytes, profile, extension, byte order, and limits;
- complete 32-byte header and 16-byte section-directory geometry;
- exact ordered eight-section set;
- unique fixed instruction, selector, and condition identities;
- fixed operand contracts and complete reserved-code partitions;
- all 13 Meaning Profile cases represented;
- diagnostic block-bounded disassembly;
- complete atomic malformed-artifact rejection;
- deterministic canonical JSON independent of hash insertion order;
- absence of Ruby objects, machine paths, and timestamps;
- rejection of mutated identity, opcode, and coverage data.

The contract audit does not claim an emitter, loader, or VM exists.
