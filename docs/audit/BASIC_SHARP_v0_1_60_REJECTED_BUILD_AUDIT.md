# BASIC# v0.1.60 Rejected Build Audit

**Date:** 2026-08-08  
**Rejected package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_60_SELF_HOSTING_MILESTONE_1_CHANGED_FILES_ONLY.zip`  
**SHA-256:** `5e20188ef8b6f0d4882083e0eb8f47a3354a08a3558dbfb4a1046a586eb6b802`  
**Required base:** v0.1.59 / `4d58c74aca68f826c0bdd0ecf50bec377d7063fe`

## Result

The owner-side installer passed base verification, payload verification, Ruby syntax, JSON parsing, the sealed validation inventory, the complete test suite at 526 runs / 8787 assertions / 0 failures / 0 errors / 0 skips, and the self-hosting lanes through the IR parity harness.

It then failed at `tools/small_compiler_subset_error_contract.rb` because `README.md` did not reference `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`.

The installer restored exact v0.1.59. Derek verified `main`, tag `v0.1.59`, commit `4d58c74aca68f826c0bdd0ecf50bec377d7063fe`, clean tree, no diff, and no untracked files. v0.1.60 was not committed, tagged, accepted, or made a baseline.

## Repair rule

v0.1.62 re-carries Self-Hosting Milestone 1 directly from accepted v0.1.59, adds the missing README contract reference, advances every active version surface to v0.1.62, and is not deliverable until the exact sealed v0.1.62 installer has passed against a disposable clean copy of accepted v0.1.59.
