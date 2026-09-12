# Adaptive composition and expanded control

Target remains installed Zero-K v1.14.8.0 / engine 2025.06.21.

## Verified references

- Installed `luaui/widgets/cmd_missile_silo.lua`: missiles are child units tagged `missile_parentSilo`; a completed missile receives native `CMD.ATTACK` with a ground point. Silo commands otherwise use the stock widget.
- Installed `luarules/gadgets/unit_missilesilo.lua` (reference only): capacity comes from `missile_silo_capacity`; owned missile-to-silo rules parameters are exposed by the game.
- Installed `luaui/widgets/gui_nukebutton.lua`, `unit_stockpile.lua`, and `luarules/gadgets/unit_stockpile.lua` (reference only): `GetUnitStockpile`, native STOCKPILE and ATTACK; do not simulate ammunition or bypass stockpile costs.
- Installed `units/staticnuke.lua`: `is_nuke`, weapon range and blast data. Runtime WeaponDefs supply the engine's radius representation.
- Installed `units/cloakcon.lua`: Conjurer identifier `cloakcon`. Its effective build options are read from runtime UnitDefs, not the empty raw table before game postprocessing.
- Installed Mex placement: TestBuildOrder and negative build-definition commands; installed CommandInsert: feature reclaim targets use feature ID plus Game.maxUnits.
- Existing Routing.lua uses TestMoveOrder with terrain-only checks; air/naval handling must not put ships onto land formation slots.

Official documentation consulted: [unit classes](https://zero-k.info/mediawiki/Unit_classes), [Trinity](https://zero-k.info/mediawiki/Trinity), [Missile Silo](https://zero-k.info/mediawiki/Missile_Silo), [Conjurer](https://zero-k.info/mediawiki/Conjurer).

## Services and authority

EnemyModel remembers visual sightings only, with a 90-second half-life and six-half-life cutoff. Radar never refreshes remembered identity. Production uses shared friendly completed and queued combat value and counter-role deficits across factories. Counters are transparent heuristics, not matchup guarantees.

Recovery will maintain records of owned infrastructure and attack sites, assign/produce a small Conjurer team, and issue native repair/reclaim/build orders through Orders with independent builder ownership. Explicit construction requests and factory/builder re-enrollment are exposed in the Control Panel. Busy queues and manual exclusions remain protected.

Air and naval detachments will use native movement/combat orders and domain-compatible destinations through Officer. Strategic weapons will use separate enrollment, actual readiness and currently observed target checks; no stale intel targeting or hidden anti-nuke discovery. No stock archives or LuaRules are modified.

## Milestone validation

Shared intel / factory re-enrollment: 27 suites passed. Isolated 60-second automatic production run completed, native Knight production logged, no EnemyModel/Command Layer errors. UI stubs cover existing controls; rendered UI inspection remains pending.
