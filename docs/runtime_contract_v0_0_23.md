# BASIC# Runtime Contract v0.0.23

## Execution order with ASK

```text
build from START or restore a BSharp Save
-> run one explicitly requested external event, when present
-> finish its complete IF and follow-up-event settlement
-> answer ASK questions in command order
-> write a requested save only after all ASK questions succeed
```

ASK is not run after an unmatched or failed external event.

## Read-only inspection

Runtime exposes deterministic inspection views for:

- one Thing;
- one Kind and its direct/inherited members;
- event-rule matching;
- IF truth and active state;
- world summary;
- loaded-save summary.

These views do not call action execution, IF settlement, follow-up-event draining, or save mutation.

## Existing behavior retained

- START and restored-world construction remain unchanged.
- Event matching retains exact-Thing, nearest-Kind, and source-order priority.
- Follow-up events remain first-created/first-run and bounded at 1,024.
- Saves remain settled-only and atomic.
- ASK failure prevents a later `--save-world` write in the same command.
