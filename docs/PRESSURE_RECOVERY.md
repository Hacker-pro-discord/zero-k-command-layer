# Resource pressure and recovery continuity

This revision addresses idle behavior in local delegated map control. It does not change public-match permissions, the unit matchup matrix, or manual override.

## Changes

- Main and raiding detachments prefer public metal nodes over generic search squares when no suitable visible attack target is available. Owned mexes are skipped; different detachments reserve different destinations. Current observed resistance and recent failed approaches can redirect a mission. Scouts continue exploring the wider map. Unseen occupancy remains unknown: a public metal spot is not evidence of an enemy mex.
- Remote visual contacts no longer cancel a march every twelve seconds. Nearby visual contacts can still interrupt a search. Native Fight remains responsible for local combat.
- In map-control mode, main-army regrouping no longer absorbs or pauses the scout/raid detachments. Those groups retain their own injury/exposure withdrawal rules. Player-drawn corridor recovery retains its previous whole-force behavior.
- A quiet ground reserve rotates among owned infrastructure once the force reaches twenty units. New incident locations reset defensive dispatch cooldowns. Temporary path/empty-queue cooldowns do not prevent emergency defense; manual blocks, transport and native retreat still do. Skirmishers are now eligible ground defenders. Air/naval groups retain their existing domain-aware defensive responses.
- Destruction incidents recorded by Recovery can alert Defense even when a building dies between health samples. Reading an incident does not refresh its lifetime.
- Once enemies are no longer observed, the recovery escort shrinks toward ten percent of force value and ends after 45 seconds without a new incident. The remaining reinforcements return to field duty. Pending civil reconstruction is retained after escort expiry. Allocation is in whole units and can exceed the target by one unit.
- Automatic recovery can use actual mobile constructor build options from other factories, including water factories, rather than requiring a Cloakbot factory. Explicit economic/recovery assignment remains authoritative. At most one early/two later automatic recovery workers are requested.
- A stalled recovery job removes only its matching native queue tag, retains its worker, and retries after cooldown. Resource-starved construction is not classified as a navigation stall. An unknown queue change releases the worker instead of overwriting it.
- Recovery surveys move at most 500 game units per order and screen the route for observed threats. Failed surveys and their build jobs share cooldowns; a generic site survey cannot bypass that suppression. Losing a worker suppresses its task for 90 seconds. Nearby reconstruction jobs are considered first.
- Reconstruction starts with the same initial funding that Recovery reserves. The previous extra 100-metal condition could prevent a reserved job from starting. Native construction streams the remaining cost normally.

These changes aim for continuing reconnaissance, resource denial, defense and reconstruction. They do not instruct injured units to charge indefinitely or treat unseen terrain as safe. Only the Officer/validated order services issue orders.

## Verification

The Lua 5.1 suite covers public-node selection, disjoint resource missions, overwhelming observed threats, remote-contact cancellation, scouting during regroup, incident expiry, non-Conjurer recovery workers, exact reserved funding, stalled-order retries, resource starvation, manual override and escort release without lost reconstruction requests. Existing formation, thousand-unit ownership, native production quantity and visibility tests remain required.

All 37 Lua regression suites and seven benchmark-parser tests pass. Native test results are recorded below. Capped matches are not wins, and this targeted check does not replace the full multi-map campaign or consume the holdout maps.


## Native results, 2026-09-12

Seven normal-start Circuit Brutal checks were run during this revision, with no scripted opening, extra resources, flattened terrain, or opponent telemetry fed to the Officer. The final three use the production Lua files from commit `c87cb0d`; all three report zero detected controller errors. Each phase retains source/engine/AI hashes in its manifest.

| Final case | Result | End time | Resource-node missions (after 10 minutes) | Defense dispatches | Reconstruction / repair / wreck orders |
|---|---|---:|---:|---:|---:|
| Folsom, Shield, side 0 | Loss | 15:33 | 21 (0) | 33 | 0 / 5 / 3 |
| Folsom, Shield, side 1 | Censored | 20:00 | 39 (7) | 173 | 7 / 26 / 18 |
| Red Comet, Cloak, side 0 | Loss | 15:35 | 24 (1) | 107 | 3 / 12 / 5 |

These are logged dispatch counts, not proof that every building completed or every mission captured territory. A cap is not a win. The side-0 Folsom force was wiped out and stopped resource missions after ten minutes: **continuous effective pressure and the midgame collapse are not solved**. The other cases demonstrate continuing repair/reconstruction and node selection, but poor engagement trades, builder exposure and defense saturation remain serious weaknesses. Open-map final losses included 2,520 metal of Conjurers. No claim of improved win rate is supported.

The initial variant produced two Folsom caps and a Red Comet loss at 13:15. Separating scouts from main recovery produced a Red Comet loss at 11:25; survey/route recovery fixes were added after diagnosis. The final open-map run lasted longer, but the opponent chose a different factory, so this is not a controlled causal improvement. The final Folsom side-0 result was worse than the initial cap. These changes are retained as tested control/retry fixes, not promoted as a calibrated stronger doctrine.

Final logs and curves: [Folsom](benchmarks/pressure-release-folsom/REPORT.md), [Red Comet](benchmarks/pressure-release-open/REPORT.md), [dispatch summary](benchmarks/pressure-release-summary.json).

Intermediate evidence: [initial Folsom](benchmarks/pressure-initial-folsom/REPORT.md), [initial open map](benchmarks/pressure-initial-open/REPORT.md), [scout separation open map](benchmarks/pressure-scout-open/REPORT.md). Holdout maps were not used. A full training rerun and holdout validation are still required before any competitive-strength claim.
