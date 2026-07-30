# BASIC# Runtime Contract v0.1.20

## Accepted saved representation

The runtime accepts BSharp IR documents whose format marker is exactly:

```text
bsir.debug.json
```

Current saved debug filenames use:

```text
*.bsir.json
```

## Retired DKIR behavior

The runtime does not execute, normalize, or silently convert `dkir.debug.json` documents. It rejects them with exactly:

```text
This file uses the retired DKIR format.
BASIC# v0.1.20 uses BSharp IR.
Recompile the original .bsharp source to create a new BSIR file.
```

The CLI prints that message without an added prefix.

## Meaning preservation

This build does not change:

- START construction;
- Kind inheritance;
- event matching priority;
- singular `that Kind` context;
- deterministic `every Kind` selection and action-line order;
- reactive IF settlement and loop protection;
- whole-number ranges;
- damage amounts;
- exact value assignment;
- missing-value and overflow atomicity;
- runtime reporting structure.

Source execution and saved-BSIR execution must remain identical.

## Invalid current documents

Unsupported or malformed current documents use BSharp IR wording, including:

```text
BSharp IR format '...' is not supported
BSharp IR 'objects' must be a list
BSharp IR contains errors and cannot run
```
