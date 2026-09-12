# Autonomous startup and full-suite checks — preview 7

2026-09-12, installed Zero-K v1.14.8.0 / engine 2025.06.21, Windows.

## User-visible failures reproduced

- Production was only inside the objective dialog; that dialog required an already assigned force. A fresh game had no usable path from no army to production.
- Auto Assign displayed ON when local testing was disabled. UnitFinished also required an existing force, with no reconciliation for existing units or missed events.
- Recruits joined MAIN membership but could wait for its entire operation to finish before receiving an order.
- At 1,000 units, an automatically chosen oblique corridor lost columns to the map edge. Packing counted nominal columns, creating too few usable slots and rejecting the main group.

## Changes

PRODUCTION and START MAP CONTROL are directly on the Officer panel. Production can create an empty receiving force and queue existing idle factories before the first combat unit. Newly completed factories join production; manual factory commands keep that factory excluded until production is explicitly re-enabled. Initial production prioritizes raiders until five military units exist, then uses the existing capability-gap rules.

Auto Assign creates a receiving force, performs a one-second reconciliation, and retains a fixed receiving-force ID instead of changing it just because the player views another force. It excludes builders, structures, unfinished units, units controlled by other forces, native retreat/transport and previously released units. Frozen approvals do not expand. The UI displays WAIT while local testing is unavailable and refreshes toggle state after external changes.

START MAP CONTROL is explicit session authority: recruitment, existing-factory production, and repeated corridor-bound military commands. With no prior objective it chooses a broad line toward the opposite map quarter using only map geometry and owned unit positions. It begins with one unit, creates scouts at five and raiding groups at eight. It does not discover hidden bases or manage construction/economy. New recruits catch up to the active main phase rather than restarting that phase for everyone. A wiped force can receive new production and restart under this standing authority; Stop revokes that startup authority.

Packing now counts usable on-map destinations and extends ranks within the existing corridor when clipped columns reduce capacity. It still rejects genuinely insufficient space and never merges slots to fake capacity.

## Automated regression coverage

All **24 Lua 5.1 suites plus syntax checks** pass. Coverage includes all formation shapes, classification, logistics modifiers, observations/radar anonymity, approvals and stale/double approval, manual override, production resources and multi-factory scheduling, early movement, reinforcement membership, recovery, retreat priority, routing, zero-army startup, UI callbacks and 400/1,000-unit plans/lifecycle.

New startup tests verify zero orders without session authority; production with no army; first-unit autonomous movement; catch-up without resetting the main operation; no reacquisition after manual release; new factories versus manually released factories; force wipe/recruit recovery; Stop without automatic restart; multiplayer denial. The 1,000-unit startup test verifies an owner/order for every unit and twenty reconciliation ticks with no additional orders. These are mocked tests, not proof of combat strength.

## Actual engine and UI checks

- **Zero-army, four-factory, 120-second engine run:** no preassigned army or manual objective. All four factories queued at second 6 (Scorcher, Bandit, Glaive, Bolas). The first unit completed around 12.5 seconds; by 14 both completed units had orders. At 22 seconds, five units had orders and the first scout was operating. At 30 seconds, eight units supported a raid group. By 118 seconds, 31 units were assigned; 12 had native queues at that snapshot. Some had arrived/were waiting with their formation, and one was marked blocked. This does not mean all 31 were moving continuously.
- **60-second rerun:** final packing/UI changes loaded; zero-army recruitment and production ran again, reaching 17 assigned units by second 58, with no Command Layer Lua traceback observed. The final small wipe/restart state correction was regression-tested after this process copied its files.
- **Visible Chili test:** opened OFFICER in a separate game, observed both new controls without opening the objective dialog, clicked PRODUCTION ON → OFF → ON, and observed actual factory queueing after re-enable. STOP AI stopped production/delegation. That test exposed a stale button caption after Stop; final UI now refreshes state automatically, with regression coverage. Final automatic-refresh code was not reloaded in that older visible process. The original player game was not reloaded or restarted.
- **400-vs-400, 180 seconds:** 398 original units moved by second 16. At 180 seconds, 91 original friendly units / 12,475 value and 105 original enemy units / 12,315 value remained. Withdrawal and regroup each timed out once. Four friendly production factories add reinforcements, so this is not an equal total-investment comparison or a victory claim.
- **1,000-vs-1,000:** each original roster spawned at 91,000 combat value. By second 16, 967 original friendly units had moved at least 32 game units. This exercises real engine dispatch and movement beyond the mocked lifecycle tests. Terrain/congestion stragglers remain; successful dispatch does not prove every unit reaches its destination.

Headless fixtures use actual LuaUI and native commands but a scripted Fight/NullAI opponent. They are not full Circuit-AI matches, long-duration balance tests, or validation on every map. Broad map navigation and regrouping under heavy fire remain experimental. Public/ranked autonomous use remains disabled.

## Reproduction

```powershell
python tests/run.py
python tools/run_combat_test.py --game "C:\path\to\Zero-K" --directory "C:\test\startup" --startup --headless --seconds 120
python tools/run_combat_test.py --game "C:\path\to\Zero-K" --directory "C:\test\stress" --stress --headless --seconds 180
python tools/run_combat_test.py --game "C:\path\to\Zero-K" --directory "C:\test\thousand" --thousand --headless --seconds 90
```

Omit --headless for visual inspection. Use a separate directory outside the installed game; never install test fixtures as ordinary widgets. Selected logs accompany this report.

The 1,000-vs-1,000 run completed 90 game seconds with 535 original friendly units / 59,160 combat value and 428 original enemy units / 53,620 value. Friendly factory reinforcements are additional; this is not an equal total-investment result. Thirty-three original units had not moved 32 units by second 26. All headless runs reached their end marker without a Command Layer Lua traceback. The small final empty-force restart and objective-specific recruitment-pin changes are covered by regressions rather than an additional full combat replay.

Selected logs: [zero-army startup](startup-engine.txt), [60-second rerun](startup-final-engine.txt), [400-unit battle](startup-400-engine.txt), [1,000-unit battle](startup-1000-engine.txt).
