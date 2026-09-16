# DKScript Validation v0.0.09

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Required base

Accepted v0.0.08 at commit `d6c92d1`, tag `v0.0.08`.

## Baseline reconstruction

The accepted v0.0.08 tree was reconstructed from the full v0.0.03 archive and the accepted changed-files packages from v0.0.04 through v0.0.08.

```text
27 runs
95 assertions
0 failures
0 errors
0 skips
```

Result: PASS.

## Ruby syntax

Every file under `compiler/*.rb` was checked with `ruby -c`.

Result: PASS.

## Compiler proof

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
```

```text
DKScript Ruby Bootstrap Compiler v0.0.09
statements: 6
kinds: 1
definitions: 5
facts: 4
events: 2
if rules: 1
objects: 6
official words: 4
errors: 0
warnings: 0
```

Result: PASS.

## BSharp IR proof

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.bsir.json
```

Result: PASS.

## Runtime proof from source

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
```

Required state:

```text
ember: kind=dragon; states=angry; damage=1
north door: kind=door; states=unlocked
```

Result: PASS.

## Runtime proof from existing BSharp IR

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsir.json --run "player attacks ember"
```

Result: PASS.

## Carry proof

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player takes brass key"
```

Required state:

```text
brass key: kind=key; carried by=player
```

Result: PASS.

## Full automated suite

```text
35 runs
138 assertions
0 failures
0 errors
0 skips
```

Result: PASS.

## Package checks

- ZIP integrity: PASS.
- Direct project-root layout with no wrapper folder: PASS.
- Overlay onto reconstructed accepted v0.0.08: PASS.
- Compiler proof after clean overlay: PASS, 0 errors, 0 warnings.
- Runtime attack proof after clean overlay: PASS.
- Runtime carry proof after clean overlay: PASS.
- Existing BSharp IR runtime proof after clean overlay: PASS.
- Full suite after clean overlay: PASS, 35 runs, 138 assertions, 0 failures, 0 errors, 0 skips.
