# Multiplayer session control

## Reported permission

On 2026-09-13 the project owner confirmed permission for ranked and for the full autonomous economy, production and army suite. This change implements that scope. No approval wording or public link was provided, so this document records the owner's report rather than independently verified developer endorsement. Earlier milestone documents describing a single-player-only lock reflect the previous implementation; this document and the current README supersede that restriction.

## Controls

In a multiplayer or autohost match, OFFICER shows ENABLE MULTIPLAYER AI. Clicking it grants session authority and starts the existing automatic startup flow: assigned own army, automatic recruitment, factory production, and economic/recovery control according to existing settings. Win the Game and the saved tactic remain the defaults. Arsenal arming, expensive Special construction requests and other existing separate controls are unchanged.

MULTIPLAYER AI: ON / DISABLE revokes session authority, stops the startup controller, production and builder services, and cancels Officer operations. Existing native queues remain; owned priority targets are cleaned up by the existing targeting lifecycle. STOP AI stops current automation without automatically restarting it.

Settings > Interface > Command Layer also has Enable full Multiplayer AI for this match. WG.CommandLayer.SetMultiplayerSession(true) enables authority without itself starting orders; StartAutonomous() starts the existing flow. SetMultiplayerSession(false) revokes authority.

The multiplayer flag is deliberately not serialized. Neither saved configuration nor local automatic startup silently starts multiplayer after a reload. Enable it again for each match/LuaUI load.

## Retained boundaries

- Own-team units only, including factory and constructor ownership validation. Allied units are never recruited merely because their information is visible.
- Legitimate shared player-perspective LOS/radar; radar identities remain unknown.
- Manual control, generation validation, and per-order authority checks remain intact.
- No control or observation while spectating/replaying.
- disable_local_widgets is honored during initialization and by runtime authority checks. The opt-in does not modify server options or game files.
- Multiple players joining no longer revoke an explicitly enabled multiplayer session. A local-only session still loses delegated authority if another player joins without multiplayer opt-in.
- Autohost metadata is allowed only with the explicit multiplayer flag; it remains blocked for ordinary local-only authority.

## Validation

43 Lua suites and seven Python tests pass. The new multiplayer fixture uses ranked/autohost metadata and multiple player IDs. It verifies no automatic startup, explicit full-service start, ownership boundaries, manual release, roster growth, authority revocation, no persisted session flags, runtime widget restrictions, and spectator/replay rejection. These are simulated API tests, not a network match.

A native local-engine startup regression is recorded separately below. No public/ranked match was joined or played during this change. Live multiplayer networking, large team-game load and interactions with other players' widgets remain untested.


### Native startup smoke check

[Folsom / Shield, 180-second local check](benchmarks/multiplayer-gates-smoke/REPORT.md), stock engine 2025.06.21, normal resources, Circuit Brutal: completed to the cap with zero Command Layer runtime errors. The 36 production Lua files match the tested snapshot and installed files. This validates unchanged local startup/loading after the gate changes, not live ranked interoperability or competitive performance.
