# Preview 10 validation

Target: installed Zero-K v1.14.8.0, engine 2025.06.21, Windows. Tests use separate data directories/mutators; no original game archive, stock widget or stock LuaRules was edited.

## Automated checks

30 Lua 5.1 regression suites, plus syntax loading of all production modules. Coverage includes:

- Shared visual intel decay, radar non-refresh, visible-only destruction removal, coordinated four-factory counters and individual re-enrollment preserving other manual exclusions.
- Recovery builder acquisition, real build options, requests, budgets, repair/rebuild/reclaim order ownership, threat withdrawal and stalled-worker release.
- Air/naval grouping, water-compatible destinations, native rearm yielding, new recruits and manual overrides.
- Launcher explicit authority, no radar-only firing, friendly blast exclusion, one outstanding shot, native ammo replenishment, parent/child release, manual queue/tag preservation and authority changes during callbacks.
- Existing Logistics, formations, approval contracts, early five-unit behavior, 1,000-unit lifecycle, retreat, routing and UI button wiring.

Run `python tests/run.py` with Python and lupa.lua51 installed. These are simulated API tests, not engine or competitive benchmarks.

## In-engine recovery

A 300-game-second scripted raid test completed at speed 3. A dedicated flat construction pad is created only by the isolated test mutator. Eight raiders attack the recorded home site; remaining scripted raiders are removed at 60 seconds.

The raid destroyed the solar collector and factory. Two Conjurers reclaimed blocking wrecks, rebuilt the solar (fully built by 100 seconds), then reconstructed the factory (fully built by 210 seconds). Defenders stayed in ESCORTING RECOVERY through 216 seconds and were RESERVE READY at 226 seconds. Later recruitment changed reserve membership. See [selected log](recovery-final-engine.txt).

Earlier uneven-terrain fixtures stalled native RAW_BUILD approaches and failed reconstruction. This is a known routing limitation. Workers now release after 25 seconds without progress; pending work can pass to another builder. The successful flat-pad run does not establish reliability on arbitrary terrain or at inaccessible remote islands.

## Air and sea

A 90-game-second Porky_Islands fixture completed. Seven aircraft and six naval units moved; no logged ship destination was on land. Native aircraft rearm is additionally covered in regression tests. See [selected log](domains-engine.txt). The opponent is scripted/passive; this is a movement integration test, not evidence of good naval/air combat tactics. Compatible destination checks do not prove water connectivity.

## Rendered controls

A separate rendered engine session loaded Chili and the suite. Opened OFFICER then CONTROL PANEL using the actual UI. Factory re-enrollment, builder enrollment, build requests/cancellation, launcher arming/stopping, current intel, Refresh and Close were visible and legible at 1600 by 1000. The original session was left untouched. Native tutorial/main HUD can overlap the movable main panel; move the panel or dismiss the tutorial as needed. Button dispatch is separately covered by UI regression tests.

## Strategic weapons and scale

The final 90-game-second weapons fixture completed. Trinity launched a real native projectile at frame 306; Eos launched at frame 2131 after native silo construction. One nuke was preloaded by the isolated test gadget only; production widgets never set ammunition. The silo issued one construction order per completed missile rather than resetting its busy queue. The native stockpile widget independently maintained ten queued missiles plus a replacement. See [selected weapons log](arsenal-engine.txt).

Earlier Eos fixtures placed the target outside native 3,500 range and correctly received no fire. One initial silo test exposed the wrong queue API and was corrected. A diagnostic tostring call also failed when a launched missile disappeared; the test harness was fixed and rerun to completion. The successful final run had no Command Layer/test driver Lua errors; stock headless rendering widgets still emit unrelated shader warnings.

A final 60-game-second 1,000-units-per-side scale fixture completed, with four own factories. Commanders were protected in this isolated fixture to prevent early game-over. At 16 seconds all 1,000 original own units were alive, 954 had moved more than 32 units and 947 had queues. At 56 seconds 507 survived, 471 had moved and 398 had queues; casualties, reserves, combat and recovery affect these counts. All four factory types issued shared-model orders (Rogue, Ravager, Scalpel and recovery Conjurer among them). See [scale log](adaptive-scale-engine.txt). This confirms continued execution under load, not favorable trades, complete route success or competitive strength. An earlier unprotected run ended early through native game-over/autoquit.

## Limits

No public/ranked autonomous testing. No hidden enemy identities, hidden anti-nuke discovery, stockpile manipulation in production, or arbitrary web-to-order rules. Launcher grants are explicit and temporary. Construction does not perform general economic expansion: it rebuilds recorded own infrastructure or executes player-added requests. Domain control does not implement autonomous transport loading or every special ability.
