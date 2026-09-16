# BASIC# BSharp IR Identity Migration Test v0.0.20

## Automated proof

```text
139 runs
4,739 assertions
0 failures
0 errors
0 skips
```

## Identity checks

- New documents emit `bsir.debug.json`.
- Current samples and fixtures use `.bsir.json`.
- Current IR contracts use `BSIR_` filenames.
- The active package manifest uses `BASIC_SHARP_PATCH_MANIFEST.json`.
- The old active names are absent.
- Retired DKIR input receives the approved exact diagnostic.
- The CLI adds no unwanted prefix to that message.

## Regression checks

All five established stress lanes pass with BSharp IR wording and source/saved-BSIR parity.
