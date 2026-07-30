# Company Bible Addendum: Invisible Region Boundaries

**Version:** v0.3.38  
**Date:** 2026-07-09  
**Status:** Mandatory

## Rule

A streaming region-cell boundary must not be visible or physically perceptible during ordinary play.

For the seamless-region world:

1. Normal walking across a region boundary must not pause, slow, hitch, twitch the camera, interrupt animation, pop scenery, or interrupt audio.
2. Region-cell instantiation, removal, and other expensive scene-tree work must not occur on the crossing physics frame.
3. Small test worlds that fit safely in memory may keep their region cells resident rather than manufacturing artificial streaming churn.
4. Larger worlds must prepare incoming cells before the player reaches the boundary and retire distant cells later, outside the crossing frame.
5. Primary-region bookkeeping, Event Log reporting, and diagnostics must remain functional without turning the seam into a visible event.
6. A Main Scene Test with a noticeable region-boundary slowdown is a failed acceptance test even when project validation passes.

## v0.3.38 application

The current 3 x 3 seamless foundation contains nine region cells. v0.3.38 instantiates those nine cells once during world startup and keeps them resident, so ordinary crossings perform no add, remove, instantiate, or free operation. Future expansion beyond this small foundation must extend the resident/prefetch policy before the larger grid is accepted.
