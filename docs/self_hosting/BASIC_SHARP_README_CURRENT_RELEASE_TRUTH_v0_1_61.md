# BASIC# README Current Release Truth Gate v0.1.63

This gate protects the public GitHub landing page.

The root README current-release section must describe the active build title: BASIC# v0.1.63 Self-Hosting Milestone 1. It must not carry stale release text from older lanes, including the old IR golden parity paragraph that previously appeared under newer version numbers.

The gate fails if the current section omits the milestone, omits Ruby referee guardrails, claims full self-hosting, or describes an older build lane as the active release.

Canonical self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
