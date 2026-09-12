# Reserve and home-defense validation — preview 9

Test date: 2026-09-12. Installed target: Zero-K v1.14.8.0, engine 2025.06.21. Only project widget modules and isolated test fixtures were changed.

## Implementation

`Defense.lua` is a decision service under TacticalController/Officer. It partitions assigned units into RESERVE and DEFENSE without removing their force membership. Transfers invalidate old operation ownership; all new orders pass through Officer and Orders. Reserve recruitment uses roughly 20% of assigned metal value, suitable healthy ground combat roles, and distance to a home factory. The percentage is locally persisted and clamped to 0–40.

Owned asset health is sampled every tactical tick (two game seconds). Only own assets and Observations contacts are read. Radar contacts retain UNKNOWN identity. A damage report without a current contact uses the victim's known position. Current threats commit reserves, then nearby compatible field units, up to a response target of 70% of assigned value. Twenty seconds without a current threat releases the emergency deployment; a damage signal itself lasts twelve seconds. Redispatch has a ten-second cooldown; a new emergency bypasses the prior reserve-hold cooldown.

Field fallback excludes reserve/defense units and preserves their operations. Recruits catching up with MAIN must actually belong to MAIN. Retry-blocked scouts/raiders still occupy their subgroup capacity, preventing repeated replenishment from inflating detachment sizes.

## Automated checks

`python tests/run.py`: all 26 Lua suites pass, plus Lua 5.1 syntax checks for production modules.

The new defense suite verifies:

- Assignment alone issues no commands; delegation is required.
- Standing reserve allocation, home anchor and disjoint membership.
- Asset damage commits reserves before additional field troops.
- Manual overrides are not reacquired; Stop prevents further defense commands.
- Unknown radar evidence is not classified as an identified enemy.
- No per-tick order spam during a persistent threat.
- Cooldown-based return to MAIN and reserve reconstruction.
- Changing the reserve percentage to zero releases reserve ownership.
- Five-unit force: one reserve, one scout, three MAIN.
- 1,000-unit synthetic force: 200 reserve, two scouts, four raiders, 794 MAIN; no duplicate membership.
- Field fallback does not cancel or withdraw the reserve.
- Default percentage, persistence and range validation.

Older movement fixtures explicitly set reserve percentage to zero to retain their original scenario assumptions; the new suite exercises the shipped 20% policy.

## Engine checks

Runs use separate headless data directories on Absolution 2. The opponent is a scripted native-Fight fixture, not a Circuit AI match. These establish execution and movement, not general tactical effectiveness.

The base-defense scenario starts with 32 mixed units per side, adds an own factory, and creates eight raiders beside it at 30 game seconds with controlled initial factory damage. Surviving scripted raiders are removed at 60 seconds to exercise clearance and reserve reconstruction. Extra production, injected raiders and controlled damage mean this is **not an equal-army performance comparison**.

The final 100-second run completed with no Command Layer Lua errors. At 30 seconds the Officer dispatched four defenders. At 36 seconds two were within 500 game units of the threatened position; at 46 seconds three of four were nearby; at 56 seconds four of five were nearby. At 66 seconds the reserve had rebuilt to three units / 770 metal, all within 500 of home. The force continued its separate scouting/raiding/main operations. See `defense-engine.txt` for selected engine evidence.

An earlier 120-second development run and a 100-second verification run also completed. Arrival times varied with movement and congestion; the measured final-run values above are used rather than the fastest observed response.

The separate 60-second early-five run completed. At six seconds it had one reserve, one scout and three MAIN units. At 16 and 26 seconds four of five units had moved at least 32 game units while the reserve remained within 500 of home. Controlled damage at 30 seconds and healing at 50 exercise the existing fallback behavior. See `defense-early-engine.txt`.

## Limits

- The 1,000-unit reserve allocation check is simulated, not a completed 1,000-unit headless battle for this revision.
- Native pathfinding/congestion still affects arrival; defense is not an instant teleport or guaranteed save.
- No specialized anti-air reserve selection or multi-force defense coordination yet.
- Drawn-line grants continue to constrain response destinations. Map-control grants permit map-wide defense.
- Chili text/state logic is covered with widget stubs; the expanded details window was not visually checked in a rendered game this turn.
- Headless logs include pre-existing stock translation/shader warnings; project errors are checked separately.
