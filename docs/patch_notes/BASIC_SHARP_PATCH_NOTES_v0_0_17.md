# BASIC# Patch Notes v0.0.17

IF is no longer a one-time startup check.

A rule now wakes when its condition becomes true, stays quiet while the condition remains true, and re-arms after the condition becomes false.

BASIC# finishes the complete WHEN action list before checking IF. That keeps rule behavior visible and predictable.

IF rules may wake other IF rules in creator source order. If rules begin waking each other forever, BASIC# stops the chain, explains what repeated, and leaves the current world visible.

No new IF syntax was added in this build.
