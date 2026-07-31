# BASIC# v0.1.28 Bytecode Loader Test

## Command

```bash
ruby tools/bytecode_loader.rb
```

## Required coverage

- six committed sample artifacts;
- twelve valid Meaning Profile cases;
- source and BSIR fingerprint comparison;
- binary-derived disassembly parity;
- repeated-load determinism and loader isolation;
- deeply frozen trusted models;
- all 41 malformed-bytecode rules;
- every truncated prefix of the reference sample;
- no partial model exposure.

## Expected result

```text
BSharp Bytecode Loader v0.1.28
Sample artifacts: 6
Valid Meaning Profile cases: 12
Malformed fixture cases: 41
...
BYTECODE LOADER: PASS
```
