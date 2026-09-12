# Zero-K Command Layer

Experimental local widgets for **Zero-K v1.14.8.0 / engine 2025.06.21**: logistics shortcuts, persistent formations, an approval-based Officer, and optional single-player scouting/raiding/attack automation.

You choose the army and objective. Native Zero-K unit AI still handles firing, aiming and ordinary combat behavior. Normal installation adds uniquely named local widgets; it does not edit stock widgets, game archives or LuaRules. This is a community experiment, not an official Zero-K component or a competitive-play recommendation.

## Install

Manual installation needs no Python.

1. Download a ZIP from [Releases](https://github.com/Hacker-pro-discord/zero-k-command-layer/releases), or **Code > Download ZIP**, and extract it.
2. Find the Zero-K **data directory**, containing `games` and `LuaUI`. Steam installations commonly use `steamapps/common/Zero-K`; use your actual location, not the engine-version directory.
3. Copy the package's `LuaUI/Widgets/gui_command_layer.lua` and entire `LuaUI/Widgets/Include/CommandLayer/` directory into the matching paths. Create missing folders. The result should be:

   ```text
   Zero-K/
     LuaUI/
       Widgets/
         gui_command_layer.lua
         Include/
           CommandLayer/
             Officer.lua
             UI.lua
             ...all other included modules...
   ```

   Do not leave an extra project-name folder between `Widgets` and these files. Do not install files from `tests` as ordinary widgets.
4. Start a **local skirmish**. Open **F10 > Settings**, disable **Simple Settings**, then under **Misc** enable **Show Advanced Settings**. Open **Local Widget Config**, enable local widgets, close the dialog and enter `/luaui reload` in the game command/chat input.
5. Open **Alt+F11**, or **Settings > Misc > Widget List**, and enable **Zero-K Command Layer** under **User local**. Keep Chili Framework, Mex Placement, CommandInsert and CustomFormations2 enabled.

See the [official widget configuration guide](https://zero-k.info/mediawiki/Widget_Configuration). Match restrictions can prohibit local widgets; the suite honors them.

Alternatively, with Python 3.9+ in the extracted package:

```powershell
python tools/install.py --game "C:\path\to\Zero-K"
```

The installer copies only production widget files and expects `games/zk-stable.sdz`. Manual installation is available for other layouts, but compatibility is unverified. Windows is the tested platform.

## Logistics

Select constructors, click a preset, then draw the normal native area command.

| Buttons | Behavior |
|---|---|
| MEX ONLY; MEX + 1 / 2 / 4 ENERGY | Native Area Mex with the installed game's Ctrl/Alt variations supplied automatically. |
| AREA REPAIR; PERSISTENT REPAIR | Native repair area; persistent uses Alt. |
| AREA RECLAIM; PERSISTENT RECLAIM | Native reclaim area; persistent uses Alt. |

Native placement, generator substitution, target filtering and blocked-placement behavior remain in charge. Shift queues; Space uses native insertion. Incompatible command/selection changes cancel a pending preset. A preset does not guarantee every requested structure will fit.

**Example:** select constructors, click **MEX + 2 ENERGY**, then drag the Area Mex region.

## Persistent formations

Shapes: **LINE, DOUBLE LINE, TRIPLE LINE, COLUMN, WEDGE, ECHELON LEFT, ECHELON RIGHT, BOX, SCREEN and ASSAULT**.

Select an army, choose a formation, then right-drag a movement line or activate Fight and left-drag a line. Draw another line to advance and reform without choosing the preset again. Rank formations follow sampled curves; other shapes use the overall axis. Native single-unit/Alt path gestures and unrelated commands remain native.

ASSAULT separates light units, heavier frontline/riot units, AA/support and rear ranged units. Classification uses capabilities, role icons and descriptions; unknown units remain OTHER. Ground, hover and amphibious units receive formation geometry. Aircraft/ships receive ordinary destinations without ground formation corrections. Constructors, including builder commanders, are excluded by default.

| Mode | Behavior |
|---|---|
| ARRIVAL | Positions once, then leaves behavior to the game. |
| LOOSE | Default private-test maintenance: occasional substantial drift corrections; yields near observed combat. |
| STRICT | Prioritizes relative positions; corrections can interrupt native kiting/dodging. |

Ordinary non-private operation falls back to ARRIVAL. Corrections use per-unit cooldowns (five seconds Loose, two Strict), one outstanding correction per unit and a shared budget of 60 corrections/second. Arrival, overrides, unexpected queues, loss, transfer, transport, retreat and stalled movement release maintenance. Delegated native Fight can continue while nearby contacts remain.

Optional previews show positions, facing, role zones and corridors. Geometry is approximate: cliffs, narrow corridors, tight curves and map edges can cause poor placement or compressed spacing. The engine handles navigation.

## Officer with approval

Enable **LOCAL / PRIVATE TEST SESSION** for authorized local/private testing, then:

1. **ASSIGN TO OFFICER** assigns selected eligible units for advice only. **ASSIGN ALL MILITARY** captures your completed mobile military units, excluding builders, structures, unfinished units and allied units.
2. **SET OBJECTIVE** arms a left-drag objective line. **ASK OFFICER** requests tactical and production advice.
3. Read the brief, inspect **SHOW PLAN**, and approve one displayed action or dismiss it.

Assignment, silence and declined proposals issue no orders. Approval covers one reform, push or side approach, not the next attack. Briefs allow 60 game seconds by default and remain readable after expiry. Membership, ownership, position, health, objective or observed-threat changes invalidate approval. Invalid offers can refresh after five seconds; the replacement requires new approval. Repeated approval cannot execute twice.

**ADVANCE / HOLD / FLANK LEFT / FLANK RIGHT** choose a force's approach. Adviser flank proposals are geometric side approaches, not proof of an exposed enemy flank. Separate assignments/objectives can represent fronts; PREVIOUS/NEXT FORCE changes the active record. There is no coordinated multi-front strategic planner.

Production advice uses actual factory build options, friendly capability gaps and legitimately observed enemies. **SHOW DETAILS** explains evidence, cost and alternatives. Advice never places buildings, queues units or selects constructors.

## Delegated pressure: single-player only

For sustained control:

**LOCAL / PRIVATE TEST SESSION > ASSIGN ALL MILITARY (or selected force) > SET OBJECTIVE > DELEGATE PRESSURE**

This explicitly authorizes repeated actions for that force inside the drawn corridor:

- Small SCOUT/RAIDER detachments revisit corridor edges, preferring unobserved and less recently checked points.
- Small raider groups approach suitable **visually identified** local targets or patrol for opportunities.
- MAIN repeatedly advances with native Fight, considering intermediate side approaches with less observed resistance and wider spacing against visible riots.
- Compatible units already assigned to MAIN can replace lost light detachments. Artillery is not substituted as disposable scouts.
- Damaged/exposed light detachments can withdraw with native movement. New main advances pause at very low average health.
- At the final line MAIN holds under control; light detachments may continue within the corridor.

**AI DETAILS** shows group availability, observed composition, rule version, state and reasons. **STOP AI** revokes sustained authority. Manual orders release affected units. Changing the objective/front requires explicit delegation again. Future production is **not** automatically recruited.

Delegation requires a private-session assertion **and a single-player roster**. Multiplayer delegation is disabled. There is no autonomous economy, production, map-wide strategic targeting, reserve commitment, neural model or learned weights.

The widget does not browse the web or learn strategies during a match. The separate [research helper](docs/TACTICAL_RESEARCH.md) fetches public source metadata and writes review-only candidates. Those files cannot issue orders or automatically change doctrine rules.

## Settings, stopping and removal

Move the Chili window by its title bar. Settings and bindable actions are under **Settings > Interface > Command Layer**: spacing, rank/support/artillery depth, constructors, overlays, maintenance mode, approval lifetime and suggestion interval. Use Zero-K's normal hotkey interface; existing keys are not overwritten. UI sizing follows the global Chili scale.

Settings and window position persist. **Assignments, proposals, operations and private/delegated authority do not.** Formation mode starts OFF after reload. Choose the adviser formation before assignment; reassign to capture a different preset.

Cancel/Stop/OFF ends future Officer control. It does **not** erase ordinary destination orders already in native queues. Issue a normal Stop/manual command if you also want units to stop moving. Optional suspension requires Resume, which restores advice only.

To update, replace the same production files and reload LuaUI or restart the match. Back up local edits first: the installer overwrites this suite's files.

To disable, use the widget list. To uninstall, disable first and remove only `gui_command_layer.lua` and `Include/CommandLayer/`, or run:

```powershell
python tools/uninstall.py --game "C:\path\to\Zero-K" --dry-run
python tools/uninstall.py --game "C:\path\to\Zero-K"
```

The uninstaller retains files differing from this checkout and leaves unrelated widgets and native configuration alone.

## Multiplayer and information boundaries

Developer approval for public/ranked use of the new Officer features has **not** been obtained. Ordinary helpers and one-shot formations remain separate from automation. The local/private toggle is an assertion, not a complete room-type detector; autohost metadata is additionally checked. Do not classify public matches as private.

There are no orders or observation collection while spectating/replaying. Enemy identity is read only with visual contact; radar-only contacts stay UNKNOWN. The suite does not expose fog-of-war data, conceal control or bypass local-widget restrictions.

## Test evidence and limitations

- Thirteen Lua 5.1 regression suites cover ownership, stale/duplicate approvals, radar anonymity, logistics modifiers, geometry, delegation, withdrawal and status.
- Isolated engine tests verified native orders, actual movement, repeated scout/raid/main operations and cancellation.
- A visible equal-army test started with 32 identical units and 3,010 metal of combat value each. The corrected two-minute run ended with **nine units and 910 value each**: a stalemate, not a victory or completed objective. The opponent was scripted native Fight, not a full Circuit AI match.
- UI panels and live details were inspected. Broad terrain coverage, long-match strength, other versions/platforms and public multiplayer permission are not established.

Read [combat results and reproduction](docs/COMBAT_TEST.md) and [validation history](docs/VALIDATION.md). For local regressions:

```powershell
python -m pip install lupa
python tests/run.py
```

The [separate-session launcher](tools/run_combat_test.py) uses test-only LuaRules fixtures outside the installed game. Never install those fixtures into a normal match. Supply both `--game` and a separate `--directory` when using that launcher.

## Architecture, contributions and license

UI/input > Officer > observation/classification/formation services > ownership-validated Orders > native Zero-K unit AI. Logistics uses native handlers independently. TacticalRules and TacticalController extend the same Officer and do not issue raw combat orders directly.

Read the [API](docs/API.md), [architecture](docs/ARCHITECTURE.md), [tactical rules/research](docs/TACTICAL_RESEARCH.md), [future design](docs/FUTURE_TACTICAL_ARMY_AI.md) and [attribution](docs/ATTRIBUTION.md). Bug reports should include game/engine versions, exact steps, whether delegation was enabled and relevant `[CommandLayer]` log lines. Review logs for private information before sharing.

Licensed **GPL-2.0-or-later**; see [LICENSE](LICENSE) and [NOTICE]. Credit to Zero-K, Chili and engine contributors whose conventions and services this builds upon.
