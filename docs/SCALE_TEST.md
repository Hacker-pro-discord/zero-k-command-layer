# Multi-factory, early movement and scale test (preview 4)

## Fixes found by tests

1. The production controller chose one global candidate per five seconds, unnecessarily leaving other affordable idle factories waiting. It now visits all controlled factories, queues one unit per idle factory per pass, subtracts planned costs from a local metal budget, and rotates priority to avoid a fixed first winner when funds are scarce. Busy, manually released, unfinished and non-owned factories remain excluded. Native repeat queues are preserved.
2. A 1,000-unit test near a map edge found that the temporary front line could extend off-map and be rejected before packing. The line is now clipped into map bounds before the corridor packing step. Destinations still undergo corridor and ownership checks.

## Automated regression evidence

All 19 Lua 5.1 regression suites pass.

- Four factories all receive production on the same pass; busy queues remain untouched.
- A 230-metal snapshot with 65-metal units permits only two additions and retains the 100-metal reserve. This catches overspending caused by reading unchanged resources for every factory.
- Manually released and transferred factories receive no additions.
- Six early military units receive scout/main orders on the first tactical tick after delegation; the main phase advances 600 game units. There is no large-army or production-completion gate.
- 1,000 simulated units receive orders, progress through six successive operation cycles, and preserve manual override of 25 released units. The earlier 400-unit pairwise-spacing and single-approval tests also pass.

## Real engine stress run

Zero-K v1.14.8.0 / engine 2025.06.21, headless, 120 game seconds. Test-only fixture: 400 units per side, with four additional own factories. Scripted native Fight opponent. No existing user match or stock game files were modified. Selected logs: `stress-engine.txt`.

At game second 6 the controller queued:

| Factory | Unit |
|---|---|
| Cloakbot | Knight |
| Rover | Ravager |
| Shieldbot | Thug |
| Hovercraft | Halberd |

All 400 original units received initial control operations at approximately second 8: 2 scout, 4 raid and 394 main units.

| Game second | Original units alive | Moved over 32 units | Mean forward movement | Blocked units |
|---|---:|---:|---:|---:|
| 16 | 400 | 398 | 223 | 0 |
| 26 | 400 | 398 | 355 | 3 |
| 36 | 394 | 392 | 362 | 3 |
| 46 | 308 | 306 | 323 | 3 |

The controller entered ENGAGING under native combat behavior. At second 48 it crossed the configured membership-loss threshold and stopped delegation for an approved regroup. The test deliberately did not approve that new plan. Native queued combat continued; subsequent movement is not evidence of continued delegated control. Several completed production units joined automatically. A later visible-riot response queued a Scalpel.

At second 120, the original combat rosters had 119 own and 126 enemy survivors (14,880 vs 14,325 surviving metal value). This excludes newly produced units and is not a fair victory benchmark because the production fixture adds own factories. No Command Layer Lua exception occurred; existing headless shader warnings were unrelated.

## What is established / still open

Multi-factory dispatch, hundreds of real initial orders, early movement, native combat coexistence, large simulated repeated operation cycles, manual override and loss-triggered review are tested. Three units did encounter stall handling: reliability does not mean all terrain congestion is solved. Two original units had not moved 32 units at the early samples.

Early advancement toward an assigned objective is verified. Broad map ownership, economic expansion, winning against Circuit AI, and sustained autonomous combat after a required review are not established. The 1,000-unit case is mocked, not a live match. Live stress preceded the edge-clipping fix; that final change is covered by the new mocked regression.

Reproduce: `python tools/run_combat_test.py --game PATH --directory SEPARATE_PATH --headless --seconds 120 --stress`.
