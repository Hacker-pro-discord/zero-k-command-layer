# Defence / Special construction

## Native compatibility

Category membership is read at runtime from the installed `LuaUI/Configs/integral_menu_commands_build.lua` using its third and fourth return tables. Only named UnitDef entries are retained, then intersected with selected owned builders' actual buildOptions. Numeric terraform commands are excluded. No stock files are edited. Baseline: Zero-K v1.14.8.0, engine 2025.06.21. If the menu cannot be loaded, category-specific automation remains unavailable rather than inventing build options.

The construction browser uses the existing GetCmdDescIndex / SetActiveCommand native build-ghost pattern. Placement enters Recovery.request and then the validated Orders service. Browsing or arming a ghost issues no unit order. Placement and facing are native. Every requested building needs a capable enrolled builder, valid terrain, appropriate funding and a route without observed combat. Explicit requests can include all available named Special buildings, including artillery, missile silos, antinukes, nukes and superweapons. Terraform still uses native manual controls. Arsenal firing requires its existing separate enrollment.

## Automatic policy

StructurePlanning makes decisions only; Economy owns builders and issues commands. With AUTO STRUCTURES enabled, economy running and local/private authority valid:

- Consider radar near owned factories/mexes, respecting nearby radar coverage.
- Add limited light defenses once the army is worth at least 650 metal, or in response to observed nearby ground pressure.
- Consider local AA or torpedoes against visually identified nearby air/naval contacts. Radar-only identities never select a counter.
- Consider jammer/shield support under observed ground pressure once mobile combat value reaches 4,000.

Only builders within 1,400 units of an owned factory/mex anchor participate. Native placement must be visible, buildable and outside the existing observed-combat exclusion radius. No constructor rushes into an active fight to build a turret.

Require at least 180 stored metal, 200 stored energy and energy income at least metal income. A building must leave 100 metal; existing Defence/Special investment plus its full cost may not exceed max(120, 20% of mobile combat value). One automatic structure starts at most every 30 game seconds. Existing and unfinished coverage suppress duplicate coverage. Emergency power and military catch-up take precedence; automatic structures pause during catch-up. The toggle persists but does not grant session authority. Turning it off preserves native construction already issued.

Automatic strategic artillery/nukes/superweapons are not implemented by this change; use the explicit request browser. No new strategic-fire authority is implied.

## Recovery and override

Recovery records owned Defence/Special structures, including their placement and facing, for repair/rebuilding under the existing threat, funding and retry checks. This also includes expensive structures; cancel pending build requests if you do not want a recorded asset rebuilt. Explicit player dismantling remains excluded by the existing forget path. Manual constructor commands release builders until re-enrolled. Rebuilding is attempted when conditions permit, not guaranteed during combat or resource starvation.

## Verification

41 Lua suites and seven Python tests pass. New tests cover category filtering, unsupported builders, non-executing preview, native command dispatch, coverage suppression, affordability/authority gates, military catch-up deferral, manual override, Special requests, recorded radar loss and UI callbacks. Interactive Chili rendering is not verified by the headless test harness.


### Native engine check

[Folsom / Shield, stock Circuit Brutal, side 0](benchmarks/structures-land/REPORT.md), 600 game seconds, normal resources. The native run emitted STRUCTURE PLAN events and completed radar, Lotus and Picket construction. No Command Layer runtime errors were reported. All 35 production Lua files matched the native snapshot and installed files.

The match was censored at ten minutes, not a win: 3,140 value killed versus 6,410 lost, final mexes 10/20. This verifies construction execution, not improved competitive strength. Naval structure placement, strategic megaproject completion and interactive browser rendering still need live acceptance testing. Existing native naval terrain checks remain in use.
