# DKScript Patch Notes v0.0.09

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


This is the first build that performs DKScript instead of only checking and translating it.

Run:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
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
