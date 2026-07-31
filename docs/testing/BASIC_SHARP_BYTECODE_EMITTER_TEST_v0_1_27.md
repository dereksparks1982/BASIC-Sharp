# BASIC# v0.1.27 Bytecode Emitter Test

## Automated suite

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

Expected floor:

```text
253 runs
5,534 assertions
0 failures
0 errors
0 skips
```

## Focused emitter lane

```bash
ruby tools/bytecode_emitter.rb
```

The lane verifies:

- six sample source/BSIR byte comparisons;
- twelve valid Meaning Profile cases;
- invalid case 13 rejection;
- repeated deterministic emission;
- blank-line and line-number independence;
- header and section geometry;
- instruction, selector, and IF lowering;
- BSharp Save fingerprint parity;
- deterministic disassembly;
- atomic pair output;
- fixture hashes;
- absence of Ruby-specific serialized data.

## CLI tests

Tests cover default output, custom `--out`, source/BSIR parity, BSharp Save rejection, conflicting mode rejection, and `.bsbc` extension enforcement.
