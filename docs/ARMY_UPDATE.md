# Preview 2 validation

Changes: overflow ranks replace corridor-edge stacking; congestion cooldowns replace permanent exclusion for stalls; partial arrivals do not escalate total-failure counters. Whole-army proposals consume one approval and revoke parallel delegation. UnitFinished can opt in newly completed military units to the active force without modifying an existing operation's membership. Progress/loss review stops delegation and proposes a role regroup.

Validation on 2026-09-12:

- Lua 5.1 syntax checks and all 15 regression files pass.
- `test_large_army.lua`: 400 units; all receive orders, pairwise minimum separation in packed MAIN slots, corridor containment, whole-force approval without prior orders, duplicate approval rejection, arrival without another delegation, new-member invalidation, and non-executing adaptive regroup.
- `test_reinforcements_recovery.lua`: opt-in reinforcement under delegation, no changes to current operation units, exclusion of unfinished/enemy/builder units, congestion retry, manual override not reclaimed.
- Isolated 30-second headless engine smoke: real 32-unit native scout/raid/main operations, ENGAGING at 16 and 26 seconds, zero blocked units at those samples, completion and clean shutdown. No Command Layer runtime exception found. See `army-update-engine.txt` for selected log lines. Standard headless shader warnings are unrelated.

Limits: the live smoke uses the existing small scripted-Fight fixture. New buttons, UnitFinished recruitment, whole-army approval and 400-unit gameplay have not been interactively validated in-engine. Tests establish command contracts and geometry, not battlefield strength. No multiplayer permission is implied.

New service hooks: `WG.CommandLayer.ReviewArmyPush(forceID)` creates a proposal; `SetAutoAssign(boolean)` changes recruitment preference. Both reuse Officer authority rules. Existing assignment/proposal APIs remain compatible.
