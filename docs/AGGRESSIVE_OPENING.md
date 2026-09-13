# Faster opening and combined field attacks

## Diagnosis and changes

The existing controller did not literally wait for complete enemy composition. Delays came from a five-second factory polling interval, 100-metal/100-energy buffers, high constructor priority, and dispersed ground detachments. AUTO opening was essentially Cloak on land and Ship underwater. This change addresses those specific decisions rather than claiming all passivity is solved.

### Starting factory

OpeningPlan ranks the commander's actual factory build options from a 7x7 public height sample. It considers sampled water fraction, local underwater start, roughness and map area. Preferred openings: Ship for a predominantly water map with an underwater start, Hover for mixed water, Spider for rough terrain, Rover for larger open land, otherwise Cloak. Native construction placement validates the ranked candidates in order. Strider Hub is excluded as an initial factory. No enemy coordinates, hidden structures or enemy economy are consulted. This is a coarse heuristic, not path analysis or a guarantee of the best competitive factory. Existing/manual opening selections are preserved.

### Production and scouts

- Poll controlled idle factories every game second, retaining one native addition per factory per pass and round-robin scheduling.
- Lower minimum stored energy from 100 to 30, metal buffer to 40, and economic streaming reserve from max(65, six seconds of income) to max(40, three seconds). No negative-resource or free-build tricks.
- Reserve an early affordable fast SCOUT/RAIDER from actual factory options (speed at least 70, cost at most 240); rank by speed relative to cost with a modest scout-role bonus. When none exists, ordinary army production continues. Completed units and factory queues count toward this quota; an unfinished unit is not counted twice.
- A first eligible fast ground scout/raider can enter reconnaissance immediately. Air/naval units continue their domain controllers; this change does not create independent naval scout subgroups.
- Before identified enemy mobile military/armed-defense intel, use a count-deficit opening mix favoring raiders, riot, skirmishers and assault units. Do not demand speculative AA before seeing air. A visible mex alone is not enemy army composition. Existing matrix-based counters resume once combat intel is available.
- With a builder already alive, delay additional builders until three combat units, then bound builder demand relative to combat count. Scouts can precede additional builder requests. Recovery funding reservations are bounded so they cannot indefinitely exclude military production.

### Expansion

With three military units, economy can request a second worker; subsequent demand scales with income toward a cap of ten. WIN THE GAME considers expansion before discretionary investment on five of six job turns. Emergency energy and military catch-up retain priority. Automatic defense/support construction defers until own mobile combat value reaches 1,200. Existing threat/route checks, mex occupancy and retry handling remain in place. Unobserved routes are not declared safe.

### 25 / 50 troop commitments

In delegated ground map-control mode, count healthy eligible MAIN/RAID/SCOUT/RESERVE units (at least 55% health). At 25, combine main and raid detachments into one field force; at 50, refresh the combined commitment once. At least half the counted force must be eligible field troops, so a defense-depleted army does not trigger a token attack. Retain scouts and the configured reserve. No combat-intel prerequisite and no extra approval is required within the already delegated authority.

Existing MAIN/RAID/reinforcement positioning is cancelled before the combined native Fight plan; other domains/defense operations remain separate. Further raid recruitment is suppressed for that delegation. The operation uses normal formation/routing/Orders validation, and no trigger runs during recovery or HOLD. There is a 45-second interval between commitments. After commitment, public resource objectives receive a capped preference for progress away from the force's initial map-control position. Enemy locations are not inferred from hidden state. Smaller groups keep acting before these milestones; this is not a minimum army-size gate.

## Validation

45 Lua suites plus seven Python tests pass, including public-terrain choices, first-scout low-buffer production, unfinished-unit accounting, no-intel army production, combined commitments at 25/50 with a reserve retained, manual override, existing multiplayer gates and large-force lifecycle checks.

The native benchmark tool now accepts --auto-factory and records AUTO in each case manifest; existing fixed-factory benchmarking is unchanged. Tests below are local isolated Circuit Brutal runs with normal resources, not live ranked games. Holdouts remain untouched. No claim of improved win rate follows from these short checks.


### Native runs, 2026-09-13

The final source was rerun on both selected training maps after fixing unfinished-unit double counting and distinguishing visible economy from combat intel. Each ran for 600 game seconds, side 0, against stock Circuit Brutal with normal resources. Both were censored, not wins; zero Command Layer runtime errors were reported. All 37 production files match their native source snapshots and the installed files.

| Map | AUTO opening | First queue | First five ready, benchmark metric | Killed / lost | Final mexes ours / enemy |
|---|---|---|---:|---:|---:|
| [Red Comet](benchmarks/opening-final-land/REPORT.md) | Rover | Dart at 5.3s | 120.2s | 2,885 / 6,495 | 3 / 20 |
| [SailAway](benchmarks/opening-final-water/REPORT.md) | Ship | Cutter at 5.3s | 110.3s | 1,535 / 3,535 | 7 / 21 |

No native ARMY COMMIT event occurred: these runs did not reach the healthy ground-force threshold. The 25/50 commitment and retained-reserve behavior is verified by the automated scenario test, not by these native matches. Naval units continue their separate grouped controller. Both matches remained strategically behind; faster queues and early scouts are not proof of stronger overall play. Live ranked performance has not been retested.

Pre-correction runs are preserved separately in [initial land](benchmarks/opening-initial-land/REPORT.md) and [initial water](benchmarks/opening-initial-water/REPORT.md). Opponent openings can differ, and these are not controlled win-rate comparisons. The full diverse-map campaign and holdout validation remain outstanding.
