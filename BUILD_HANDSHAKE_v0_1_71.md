# BASIC# Build Handshake v0.1.71

Build name: No-Locale CLI Capture Encoding Repair

Base: v0.1.70 (`88a376f8e0e0e98a1b57dc92102bdd28a9f8d1fb`)

Purpose: repair the confirmed Ruby `Open3.capture3` test-harness encoding gap so CLI output captured under minimal/no-locale environments is force-tagged as UTF-8 before assertions compare it with UTF-8 creator text.

Scope:
- Add a shared CLI capture helper for tests.
- Route CLI shell-out tests through the helper.
- Preserve runtime/compiler behaviour.
- Bump active release truth from v0.1.70 to v0.1.71.
- Regenerate version-bearing self-hosting golden records affected by `BasicSharp::VERSION`.

Non-scope:
- No new syntax.
- No object interaction expansion.
- No Profile 8.
- No Ruby retirement or self-hosting claim.
- No new governance/audit layer.

Next intended build: v0.1.72 Self-Hosting Milestone 2 Proposal.
