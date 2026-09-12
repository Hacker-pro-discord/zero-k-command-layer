# Assisted Officer V1

Target: installed Zero-K v1.14.8.0, Recoil 2025.06.21. Research performed 2026-09-12 against the installed zk-stable.sdz without modifying it. Mex and CustomFormations2 match upstream f4c1406722134fb07be6761750bf0822c69afbc0.

## Authority
Player and proposal UI -> Officer -> pure Formations -> Orders -> native unit AI. Logistics independently wraps native commands. Assignment is observation permission, not permission to move. Approval grants one immutable bounded operation. Manual orders revoke authority. No autonomous doctrine, production execution, research downloader or neural model is included.

## Source map
Sources at https://github.com/ZeroK-RTS/Zero-K/tree/f4c1406722134fb07be6761750bf0822c69afbc0
- LuaUI/cawidgets.lua: ascending input priority (reverse iteration over a descending list), mouse owner, CommandNotify/UnitCommandNotify, GetConfigData/SetConfigData, disable_local_widgets.
- LuaUI/Widgets/gui_chili_global_commands.lua: WG.Chili.Window/Button, GetCmdDescIndex and SetActiveCommand.
- LuaUI/Widgets/cmd_mex_placement.lua: Ctrl=1 generator, Alt=2, both=4; native substitutions and WG.CommandInsert. Build orders use negative UnitDef IDs.
- LuaUI/Widgets/cmd_commandinsert.lua: Shift/Space and CMD.INSERT semantics.
- LuaUI/Widgets/cmd_customformations2.lua: mouse gestures, rank offset curves, per-unit notifying orders, DrawWorld. CommandNotify alone cannot receive a complete dragged line.
- LuaUI/Widgets/unit_tree_reclaim.lua: preserve native tree filtering.
- LuaUI/Widgets/unit_auto_group.lua and unit_start_state.lua: preserve group assignments and factory states; never recruit by autogroup.
- LuaUI/Widgets/gui_chili_economy_panel2.lua: team economy readings and overdrive accounting.
- LuaRules/Gadgets/unit_tactical_ai.lua, cmd_raw_move.lua, cmd_retreat.lua: reference only. Respect native AI, retreat and internal order provenance.
- units/*.lua and LuaUI/Configs/icontypes.lua: capabilities and role icons; no universal customParams.role.

Engine reference: https://github.com/beyond-all-reason/spring/tree/2025.06.21/rts/Lua
LuaUnsyncedCtrl.cpp verifies GiveOrderToUnit/Array, pairwise GiveOrderArrayToUnitArray and SetActiveCommand. LuaSyncedRead.cpp verifies LOS/radar, team resources, command queues; TestMoveOrder is inconclusive outside LOS. LuaHandle.cpp verifies command provenance and tags.

Official documentation: https://zero-k.info/mediawiki/Widget_Configuration ; /Unit_commands ; /Area_Mex_Command ; /Unit_AI ; /Unit_classes ; /Unit_states ; /Hotkeys ; /Repair_Command ; /Zero-K:Developing ; /Zero-K:Code_of_Conduct . Installed source resolves conflicting wiki Mex modifier descriptions.

## Modules and persistence
Core, UI, Input, Officer, ForceRegistry, ProposalService, TacticalAdvisor, ProductionAdvisor, Formations, UnitClassification, Observations, Orders, Logistics, Settings and Debug are separate Lua modules. Only Orders writes combat orders. Global WG.CommandLayer exposes copied force/proposal/status snapshots and Officer entry points. Persist preferences, never force authority, proposal approval or private-session attestations.

## Constraints
Ground formations; constructors excluded unless enabled. Loose default; strict accepts interference with dodging. Native CustomFormations2 stays enabled. Formation mode owns only eligible world gestures. Spectator/replay and prohibited local-widget matches issue no commands. Assisted features and maintenance require a local/private test-session attestation, reset on reload. Ordinary public behavior is arrival-only. Unknown radar contacts remain unknown. Do not infer obstacles from failed out-of-LOS movement tests.

## Future Tactical Army AI
Extend Officer with delegated authority, state-machine doctrines and accepted maneuver corridors. Geometry, observation and execution stay shared. Validate HOLD POSITION then ARTILLERY PUSH, sequential phases, role-compatible reserves, withdrawal, local targets and multiple forces separately. Final delegated objectives hold until cancellation; approved V1 actions return to adviser status. Research produces reviewed, tested game rules, never executable web content. Learning begins as reviewable statistics. Public/ranked autonomous control needs explicit Zero-K developer approval.

Input priority is layer -1339, before native Unit Reclaimer (-1338), Tree Reclaim (-1337) and CommandInsert (5), Chili (1000), Mex (1001) and CustomFormations2 (1000000). Input explicitly yields over Chili controls. UI initialization waits for Chili when necessary. This ordering was corrected by the live Mex +2 and reclaim tests.

Detailed future subsystem design: [Future Tactical Army AI](FUTURE_TACTICAL_ARMY_AI.md).
