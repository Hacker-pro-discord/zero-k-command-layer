# Zero-K Command Layer — Assisted Officer V1

Local widgets for **Zero-K v1.14.8.0 / engine 2025.06.21**. Installed in your existing Zero-K data directory. Original archives, stock widgets and LuaRules are untouched.

## Start using it

1. Start a match. Open the widget list with **Alt+F11** and enable **Zero-K Command Layer** if its window is absent. Local widgets must be permitted. Keep Chili Framework, Mex Placement, CommandInsert and CustomFormations2 enabled.
2. **Logistics:** select constructors → click **MEX + 2 ENERGY** → drag the usual Area Mex region. Native placement chooses generator substitutions and skips blocked construction. Other Mex and repair/reclaim buttons work similarly. Shift queues; Space inserts through the native handler. Native Ctrl filtering remains intact.
3. **Formations:** select an army → choose **DOUBLE LINE** or **ASSAULT** → right-drag a movement line, or select Fight and left-drag a line. Draw another line to advance and reform without selecting the formation again. Single-unit and Alt path gestures remain native. Constructors, including builder commanders, are excluded by default. Aircraft/ships in mixed selections receive ordinary destinations without maintenance.
4. **Officer:** in local/skirmish or explicitly private testing, click **LOCAL / PRIVATE TEST SESSION**, select a force and click **ASSIGN TO OFFICER**. **SET OBJECTIVE** arms a left-drag line. **ASK OFFICER** requests advice. Review **SHOW PLAN**, then approve or decline. Assignment and silence issue no orders. Each approval authorizes one displayed Fight action, ending on arrival, cancellation or override.
5. **SHOW DETAILS** opens production advice. **DISMISS** removes it. There is no build/queue approval button or production automation.

The window is movable. The formation preset remains selected across orders and selection changes; it starts OFF after reload. Settings and window position persist through Zero-K's configuration. Force assignments, proposals, operations and private-session permission do not persist.

## Controls and behavior

- **Arrival:** destinations once; used for ordinary public-match formations.
- **Loose:** default in explicitly enabled private tests; substantial drift corrections at least five seconds apart, yielding when nearby contacts are observed.
- **Strict:** corrections at least two seconds apart. Position priority can interrupt native kiting/dodging.
- Shared maintenance budget: 60 unit corrections/second, one outstanding correction per unit. Maintenance stops on arrival, ten seconds of stalled progress, override, transport, retreat, transfer, loss or unexpected queue replacement.
- **FORMATION OFF / CANCEL ACTION:** revoke further control. Native destination orders remain. Known tagged temporary correction orders are removed where still owned.
- Manual commands release affected units. The optional suspension setting requires **RESUME**, which restores advice only, never an old approval.
- **PREVIOUS FORCE / NEXT FORCE** choose assigned-force records. Selection changes do not change membership. The adviser formation is captured on assignment; reassign after choosing a different preset to change it.
- One proposal dialog is visible at a time; other offers appear in order. Approval expires after 60 game seconds by default; the brief stays visible until dismissed or refreshed. Membership, objective, ownership, position, health or observed-threat changes invalidate them. Use REFRESH for a fresh review; stale approval never executes. Declining suppresses that suggestion for 60 seconds; automatic offers are limited to one per force per 10 seconds.
- Rank/depth sliders and bindable command actions are under **Settings → Interface → Command Layer**. Bind preferred hotkeys through Zero-K's normal UI. Existing keys are not overwritten. Window sizing follows the game's global Chili UI scale; the reserved module scale field is not separately exposed.

## Officer front controls

- **ASSIGN ALL MILITARY** snapshots all your completed mobile military units, including air/naval and mobile support. Builders (including builder commanders), structures, unfinished units and allied units are excluded. It merges the captured units into one new force; existing assignments lose those members. It does not recruit later production automatically.
- **ADVANCE / HOLD / FLANK LEFT / FLANK RIGHT** set the active force's front approach. Use separate selected-unit assignments and objective lines for separate fronts, switching with PREVIOUS/NEXT FORCE. Changing approach revokes maintenance and invalidates pending approval; native destination orders remain.
- **HOLD** offers reformation around the current position, not sustained autonomous sector defense. **ADVANCE** offers the objective line. A **FLANK** offers one intermediate side approach toward that line (up to 256 units lateral offset); arrival requires another approval for further movement. Near the objective it offers the final push. The yellow preview shows the approved corridor. This is a player-chosen geometric approach, not terrain-aware routing or detection of an exposed enemy flank.
- Assignment and front changes issue no orders. Aircraft/ships receive ordinary Fight destinations with completion tracking, without ground formation corrections. All-domain path suitability still needs player review.
- Brief lifetime (30�180 seconds) and suggestion interval (5�60 seconds) are adjustable in Command Layer settings. Defaults are 60 and 10. Unread expired/invalid briefs are not silently replaced. REFRESH creates a new plan requiring a separate approval click.

## Installation and removal

Already installed at `C:\common_attachment\Steam\steamapps\common\Zero-K\LuaUI\Widgets`. Reload LuaUI or start a new match for the latest revision.

For another installation, with Python available:

```powershell
python tools/install.py --game "C:\path\to\Zero-K"
python tools/uninstall.py --game "C:\path\to\Zero-K" --dry-run
python tools/uninstall.py --game "C:\path\to\Zero-K"
```

Or copy `LuaUI/Widgets/gui_command_layer.lua` and `LuaUI/Widgets/Include/CommandLayer/` into matching local data directories. Disable the widget before uninstalling. The remover deletes only matching suite files and retains modified files for review. Tests and the engine test driver are **not installed** by the installer.

## Compatibility and limits

Assisted features and maintenance require explicit local/private testing enabled each session. Autohost matches advertising `sendspringiedata` stay locked. This conservative guard is not a complete public/private detector; do not attest public matches as private. No spectator/replay orders or observation collection. Dialog approval is not multiplayer permission.

This is a first playable implementation, not an autonomous doctrine system. Native aiming, firing, target acquisition and tactical AI remain enabled. Geometry is approximate on curves, map edges and difficult terrain; the engine handles navigation and stalled positioning is released. Tight curves can compress adjacent ranks. Observation snapshots contain current visual and anonymous radar contacts; stale history is reserved for later work. No learned weights, online research execution, autonomous reserves or strategic economy control are included.

See [validation](docs/VALIDATION.md), [architecture and research](docs/ARCHITECTURE.md), [attribution](docs/ATTRIBUTION.md), [milestone evidence](docs/MILESTONES.md), and [service contracts](docs/API.md).
