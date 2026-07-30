# BASIC# Changelog v0.1.15

## Inherited Kind Matching

- Activated the parent relationships already stored by `KINDS`.
- Added direct, parent, grandparent, and root Kind matching.
- Preserved exact named-Thing Trigger priority.
- Added nearest-compatible-Kind priority before source-order tie breaking.
- Kept `that Kind` context local to one event.
- Expanded resolver Kind candidates to include descendants.
- Allowed a known rootless built-in Kind to receive one direct parent through the existing declaration form.
- Added plain-language unknown-parent, duplicate-parent, and circular-family protection.
- Preserved source and saved-BSharp IR parity and accepted v0.1.13 BSharp IR compatibility.
