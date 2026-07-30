# DKScript Patch Notes v0.1.09

This is the first build that performs DKScript instead of only checking and translating it.

Run:

```bash
ruby compiler/dks.rb samples/first_room.dks --run "player attacks ember"
```

Expected proof:

```text
starting rules:
  (unlock north door
event words:
  (damage ember
  (change ember to angry
```

The printed world state must show Ember as angry with damage `1`, and the north door as unlocked.
