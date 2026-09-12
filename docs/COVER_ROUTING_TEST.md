# Covered withdrawal and local routing — preview 6

Tested against Zero-K v1.14.8.0, engine 2025.06.21, Windows, 2026-09-12.

## Behavior

RetreatPriority separates a first evacuation wave from healthy cover. Health tiers take precedence over price: below 30%, below 60%, then healthy. Within each tier the score is `metalCost * (2 - healthFraction)`. Cheap critical units are not sacrificed merely because they are cheap. Cover uses at most 30% of the force, preferring inexpensive healthy armed frontline roles (at least 65% health), never artillery/support. Only units currently inside the accepted corridor cover; displaced units evacuate instead.

The Officer issues native Fight at covering units' current positions, then prioritizes evacuation dispatch. Cover withdraws after at most 12 seconds, when 80% of the first wave clears the fallback progress threshold, or when any covering unit falls below 60% health. This offers a head start; it does not guarantee interception or survival. Existing ownership, manual override, native retreat and local/private restrictions apply. No extra approval is required under existing delegation. Assignment alone still does not delegate.

Routing adjusts known blocked slots within 256 game units and considers one short intermediate waypoint at offsets up to 512, bounded by the assigned corridor. It checks full-footprint terrain, not unit/object occupancy, and only probes positions in current LOS. Unknown terrain and unresolved geometry retain native pathfinding. Tests are cached with a 2,048-probe ceiling per plan. Route validation precedes dispatch; waypoints retain Move/Fight intent, with the final destination appended. This does not solve global terrain navigation, congestion, or evasive combat routing.

API basis: installed Zero-K widgets demonstrate native path APIs; the engine's [LuaSyncedRead implementation](https://raw.githubusercontent.com/beyond-all-reason/RecoilEngine/master/rts/Lua/LuaSyncedRead.cpp) defines `TestMoveOrder(unitDefID,x,y,z,dx,dy,dz,testTerrain,testObjects,centerOnly)`. The routing flags are `true,false,false`; outside-LOS positions are explicitly treated as unknown before calling this API.

## Regression tests

All 21 Lua 5.1 suites and module syntax checks pass. New tests cover damaged cheap/expensive ordering, healthy cover, wounded-cover release, manual override, displaced cover, LOS-only probes, blocked destination adjustment, detours, queue ordering and corridor rejection. Existing 400/1,000-unit, production, approval, observation and strategy-recovery tests remain enabled.

```powershell
python tests/run.py
python tools/run_combat_test.py --game "C:\path\to\Zero-K" --directory "C:\test\covered-retreat" --headless --seconds 120 --cover-retreat
python tools/run_combat_test.py --game "C:\path\to\Zero-K" --directory "C:\test\routing-stress" --headless --seconds 180 --stress
```

Fixtures are test-only LuaRules in isolated directories, never installed into ordinary games. They are not Officer observation inputs. These are scripted engine benchmarks, not Circuit-AI wins or public multiplayer validation.

## Engine evidence

The first controlled 10-vs-10 run completed 120 game seconds. Each side started with 1,580 combat value. At second 30, six friendly units were set to 5% health and four to 90%; the enemy held fire. Three healthy units covered while seven withdrew. Cover released at second 32, regroup began at 40, and revised advancement resumed at 58 after test-only healing at 50. All ten survived. The original log incorrectly labels the evacuation stage as ten units (whole-force count); the final code logs only the moving wave and corrects fixture labels.

The first 400-vs-400 run exercised visible-terrain slot adjustments and detours, but cover was rejected when a candidate was outside the corridor. This led to filtering displaced cover into evacuation and calculating the covering center from valid cover units. The regression reproduces this failure. Heavy recovery still suffered congestion and timed out under sustained fire; local routing must not be advertised as a complete fix for this.

Final-build checks and selected engine logs are recorded alongside this report. No claim of broad map coverage, superior combat results or hundreds of units regrouping reliably under every condition is made.

The 70-second final-code controlled rerun confirms three covering units and seven first-wave units at second 30, cover withdrawal at 34, and adaptive advancement resumed at 60. This includes the corrected cover center and dispatch-count logging. No units were lost in this passive-enemy fixture.

The second 180-second stress run, after corridor filtering, formed cover with 86 units while 209 evacuated at second 48. Cover took damage and withdrew at second 50. The evacuation plan adjusted one blocked slot and used 15 intermediate detours, with six unresolved checks left to native pathfinding. It still timed out during recovery. The later cover-center correction is covered by regression and the controlled rerun; that small correction was not present in the second stress process's copied files.

At 180 seconds the second stress run ended with 76 original friendly units / 10,850 value and 114 original enemy units / 13,530 value. Friendly reinforcements are excluded from these original-roster counts. Four friendly factories supplied extra units, so this is a control/load benchmark, not an equal total-investment match. Withdrawal and reform each timed out; revised advance did not resume before the test ended. Both final test processes exited normally, with no Command Layer Lua traceback observed.

Selected logs: [controlled rerun](covered-retreat-engine.txt), [400-unit stress rerun](routing-stress-engine.txt).
