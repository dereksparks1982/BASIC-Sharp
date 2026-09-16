# BASIC# Patch Notes v0.0.71

This patch repairs a test-harness issue, not a creator-language behaviour bug.

Under `LC_ALL= LANG= RUBYOPT=`, Ruby can tag output captured through `Open3.capture3` as US-ASCII even when the BASIC# CLI emits valid UTF-8 bytes. v0.0.71 centralizes CLI capture in tests and forces captured stdout/stderr to UTF-8 before assertions.

The fix keeps the v0.0.70 gauntlet intact and prepares the project for the larger v0.0.72 proposal/build discussion.
