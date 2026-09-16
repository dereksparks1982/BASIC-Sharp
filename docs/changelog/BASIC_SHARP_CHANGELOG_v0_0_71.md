# BASIC# Changelog v0.0.71

v0.0.71 fixes the no-locale CLI capture encoding defect found after v0.0.70.

## Changed

- Added `tests/support/cli_capture.rb` as the shared CLI shell-out helper.
- Updated test-side CLI captures to force captured stdout/stderr to UTF-8.
- Preserved the compiler/runtime path without new creator-facing syntax or runtime behaviour.
- Updated active version truth to `0.0.71`.
- Regenerated version-bearing golden records where the version bump legitimately changes BSIR, BSBC, save, or runtime digests.
- Updated release truth records so v0.0.72 can return to the larger self-hosting/game-making path.
