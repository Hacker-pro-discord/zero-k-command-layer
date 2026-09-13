# Basic visible-target priorities

The Officer now prioritizes visible repair-capable constructors, support units, mexes, factories and threatening turrets instead of choosing contacts mostly by proximity. A visible constructor working on a visible, damaged, completed target receives a stronger repairing priority. Without that evidence it is described only as repair-capable. Units that damaged our owned units within the preceding 12 seconds receive an immediate-threat bonus, but only if their attacker ID was visually observed. Radar-only contacts retain UNKNOWN identity.

## Two layers

1. Map-wide main-army and air/naval mission choices, plus corridor raiding, use the shared Targeting scorer. Distance, observed protection and force value still constrain choices. A visible mex is distinct from an unobserved public metal spot. Existing corridor/routing boundaries remain. Scouts continue reconnaissance rather than being redirected into focus fire.
2. For actively delegated units with an owned operation, the Officer can issue Zero-K's native UNIT_SET_TARGET against a currently visible priority target already within estimated weapon range. This command is independent of the movement queue. Native aiming, firing, movement and weapon legality remain active. AA focus is restricted to airborne targets; non-AA focus currently excludes airborne targets. Native unsupported targeting commands are skipped.

This is basic priority targeting, not optimized damage allocation or a guarantee that every weapon fires at the chosen unit. Range is approximate; obstruction, elevation and weapon-specific restrictions still apply. Direct player formations and adviser-only assignments do not gain focus-fire authority.

## Stability and ownership

Native target commands are routed through Officer.focusTarget and Orders.setFocus. Authority, ownership generation, transport/retreat state, live LOS, definition identity, alliance, objective boundary and approximate range are rechecked after command hooks immediately before dispatch. Pre-existing manual priority targets are preserved. Manual native Set Target/Cancel Target events discard the Officer's marker before override cleanup, so the player's new target wins.

Each force rotates through at most 128 members every two game seconds, issuing at most 40 new priority commands per pass. This is a per-force limit. Retargeting requires at least six seconds and a 200-score improvement while the existing target remains in observations. Main/raid map approaches reconsider a substantially better nearby contact after 12 seconds with a 250-score margin.

The Officer clears only its matching native priority target on operation completion, cancellation, ownership release, retreat/transport, LOS loss, out-of-range/out-of-corridor movement or a 12-second lease timeout. Cleanup is not subject to the new-target budget, so revoked targeting can be removed promptly. Large armies may wait for their turn in the scan and continue native target selection meanwhile. No movement queue is cleared or replaced by priority targeting.

## Source baseline

Inspected installed Zero-K v1.14.8.0 source:

- `LuaRules/Gadgets/unit_target_on_the_move.lua`: UNIT_SET_TARGET / UNIT_CANCEL_TARGET, one-unit target parameter, target_type=2 and target_id rules parameters; native priority is independent of the command queue. Reference only; unmodified.
- `LuaUI/Widgets/gui_chili_core_selector.lua` and factory panels: GetUnitIsBuilding pattern. The new observation query runs only for currently visible builders and never inspects enemy command queues. A work target's health is read only if that target is also currently visual.
- Existing Command Layer observation, routing, Officer ownership and order hooks are reused.

## Tests

42 Lua suites plus seven Python tests cover the existing suite and new priorities, map mission selection, radar anonymity, visible-only work inspection, native target dispatch, unchanged movement queues, loss-of-LOS clearing, revoked-grant cleanup, and preservation of manual priority targets. Native runtime evidence is recorded below; competitive strength remains experimental.


### Native regression run

[Folsom / Shield against stock Circuit Brutal](benchmarks/targeting-land/REPORT.md), side 0, normal resources, ten-minute cap: 13 native target assignments and 8 approach reviews logged. Zero Command Layer runtime errors. All 36 production files match the native test snapshot and installed files.

Censored at 600 seconds, not a win: 675 value killed / 1,540 lost, 16/17 final mexes. The opponent chose Spider this time, so this is not a controlled performance comparison with earlier Amph or Cloak opponents. Broader map/weapon compatibility and full-match tactical calibration remain unfinished. No holdout maps were used.
