# BASIC# v0.1.82 Patch Notes

BASIC# bytecode now participates in semantic-family routing after the already-native parser dispatch stage. The bounded independent semantic resolver asks a persisted BASIC# semantic router how each accepted parsed structure should be resolved. Wrong or unknown native decisions fail visibly rather than falling back to hidden Ruby routing logic.
