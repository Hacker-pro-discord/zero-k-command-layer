# Preview 3: objective policies and optional production

Recruitment no longer increments the force's approval revision. Proposal validation checks its original unit snapshot for continued membership, ownership and safety, rather than requiring exact equality with the enlarged force. This avoids recruitment-triggered replacement dialogs without adding unreviewed units to an approved action. Removal, override and changed observations still invalidate affected proposals.

The Chili objective chooser distinguishes Advice Only from explicit delegated Win Objective, Utter Destruction and Shock and Awe policies. Authority starts only after drawing a valid objective line. Cancelling the gesture does not change the active policy. Utter Destruction uses the entire assigned force in MAIN; Shock and Awe uses Assault role zones and 900-unit phases. These are limited game policies inside a corridor, not a full strategic victory planner.

ProductionController has a separate, session-only grant over a snapshot of existing owned factories. Orders is still the only order executor. It validates ownership, multiplayer restrictions, current build options, completion and an empty factory command queue immediately before dispatch. A manual factory command releases that factory. It queues one affordable mobile military unit per five seconds with metal/energy reserves. Production advice is separate and remains read-only. Factory construction, rally points and repeat state are not modified; existing repeat queues can remain busy and continue their native behavior.

UnitCreated records the source factory so completed AI-production units join the intended force rather than whichever force the user is currently inspecting. Auto Assign may be toggled off. Stop Production ends additions and preserves existing queues. Stop AI also disables production.

## Source verification

Inspected installed Zero-K v1.14.8.0 archive:

- `LuaUI/Widgets/gui_chili_facpanel.lua`: GetFactoryCommands and negative build command IDs passed to GiveOrderToUnit with empty parameter tables.
- `LuaUI/Widgets/gui_chili_integral_menu.lua`: native factory queue handling.
- `LuaUI/Widgets/unit_auto_group.lua`: UnitCreated(unitID, unitDefID, teamID, builderID).

No stock file is changed.

## Validation on 2026-09-12

- Lua 5.1 syntax and 17 regression suites pass, including objective gesture authority, full-force vs detachment policies, production opt-in, empty-queue checks, resource reserve, manual factory release, multiplayer lockout, force routing and added-member approval stability.
- Isolated engine production smoke: actual factory added by the test-only mutator; Knight queued at frame 181, completed and assigned to Force 1 at frame 1233, test completed at frame 1800 (60 game seconds). No Command Layer exception found. Selected logs are in `production-engine.txt`.
- Existing headless shader/translation warnings were unrelated to this suite.

New chooser buttons have not received interactive visual QA. The production run establishes real queuing/completion/recruitment, not optimal composition, economic sustainability or strong long-game tactics. The production fixture adds an own factory and must not be described as an equal-army benchmark.

Reproduce with `python tools/run_combat_test.py --game PATH --directory SEPARATE_PATH --headless --seconds 60 --production`.

Services: `SetAutoProduction(boolean)` and `GetProductionStatus()` expose explicit production authority and its status. Public/ranked autonomy remains disabled.
