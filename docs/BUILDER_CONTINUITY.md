# Constructor and army control continuity

## Verified causes

The installed `LuaRules/Gadgets/cmd_raw_move.lua`, in `CheckConstructorBuild` and `GetConstructorCommandPos`, inserts `RAW_BUILD` ahead of an existing build, static repair or feature reclaim order. Recovery previously checked only the queue head and classified that approach as an external order. Economy could also release a stalled worker because its head command was not the recorded build.

An isolated normal-start diagnostic additionally recorded this native queue:

```
task: build factory at [1048, 241.49, 3536]
head: Move [1201.28, 241.49, 3536], internal=true, coded=8
next: original factory build, internal=false, coded=0
```

That internal clearance move was incorrectly releasing the commander at the opening. It is distinct from a player Move command. Separately, Officer marked native retreat and transport as permanent combat blocks, leaving recovered survivors outside subsequent dispatches.

## Changes

`NativeQueue` is a shared recognizer for Economy and Recovery. It accepts the original command or one verified wrapper directly ahead of that same original command. RAW_BUILD must match the task's target position. Internal Move must carry the engine's `internal=true` flag and remain within a bounded target clearance (at least 256 game units, scaled for large building footprints). An ordinary Move, unrelated destination, or different underlying order is rejected. Repair targets are owned; reclaim uses visible or previously recorded legitimate feature coordinates.

Stall removal targets only the original owned command's tag. The native gadget cleans up its approach when the underlying job disappears. If an internal clearance move remains after the build disappears, the worker waits for that native move to drain, retaining service ownership. No arbitrary queue tags are deleted.

Constructors pause during native retreat/transport and wait for the native queue to drain before taking another job. Combat units use a temporary retry block for native retreat/transport instead of a permanent block; eligibility still prevents orders while retreating or transported. The stock conversion of Move to RAW_MOVE at the identical destination is also recognized.

Automatically borrowed recovery constructors with no dispatchable work for 15 seconds return to the economy service. A 60-second loan cooldown prevents immediate ownership ping-pong. Explicitly assigned recovery builders retain their chosen duty. A manual release removes ownership and remains excluded; no global reset of exclusions was added. Recycled unit IDs clear old loan/pause state.

`GetBuilderControlStatus()` reports controlled, idle, native-wrapper, paused and excluded counts per builder service. A service exclusion can mean assignment to the other service; it is not necessarily lost global control. Benchmark telemetry now records these counters. Unexpected economy queues include their command IDs, parameters and internal flags in diagnostics.

These fixes address units silently dropping out of control and recovery workers waiting without work. They do not establish that attack selection, spending balance or unit trades are competitively strong.

## Validation

All 39 Lua regression suites and seven benchmark-parser tests pass. New checks cover native build/repair/reclaim wrappers, exact owned-tag stall removal, invalid and non-internal Move rejection, native retreat recovery, idle loans, manual assignment/release and native Move replacement. Final native results are recorded after the land and water checks complete.
