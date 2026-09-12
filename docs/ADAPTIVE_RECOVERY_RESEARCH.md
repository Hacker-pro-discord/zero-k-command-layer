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

Recovery maintains records of owned infrastructure and attack sites, assigns/produces a small Conjurer team, and issues native repair/reclaim/build orders through Orders with independent builder ownership. Explicit construction requests and factory/builder re-enrollment are exposed in the Control Panel. Busy queues and manual exclusions remain protected.

Air and naval detachments use native movement/combat orders and domain-compatible destinations through Officer. Strategic weapons use separate enrollment, actual readiness and currently observed target checks; no stale intel targeting or hidden anti-nuke discovery. No stock archives or LuaRules are modified.

## Milestone validation

Shared intel / factory re-enrollment: 27 suites passed. Isolated 60-second automatic production run completed, native Knight production logged, no EnemyModel/Command Layer errors. UI stubs cover existing controls; rendered UI inspection remains pending.


Recovery diagnostics found native RAW_BUILD approach commands stalling on the initial forced-spawn scenario. The test fixture now validates terrain/spawn placement, and the separate construction pipeline scenario uses an explicitly flattened test pad (isolated mutator only). These runs are not routing victories. Recovery prioritizes the feature ID returned by TestBuildOrder, offsets reserve escort positions from work sites, and releases builders after 25 seconds without approach/work progress. Other builders can take the pending job. Native queues are preserved for manual review.

TestBuildOrder's second result is a blocking reclaimable feature ID; its compatibility codes map open/reclaimable to 2. Confirmed in Recoil's public LuaSyncedRead.cpp, in addition to installed Mex/CommandInsert usage. Runtime calls remain LOS-filtered. Terrain fixture calls to SetHeightMapFunc/LevelHeightMap follow installed api_map_structures.lua and never enter production widgets.

Recovery milestone: 28 Lua suites passed. The 180-game-second flat-pad run completed with two Conjurers, native factory repair, replacement solar `energysolar:20969` at full build, and native wreck reclamation. See recovery-engine.txt. Earlier uneven-terrain runs failed to finish reconstruction; this remains a routing limitation, with timeout/manual re-enrollment available. No claim of full terrain reliability.


Preview 10 additionally validates native air/naval detachment movement on Porky_Islands, native nuke firing and Eos construction/firing with explicit launcher authority. Eos range is 3,500 in installed `units/tacnuke.lua`; its raw areaOfEffect is 192, converted by the engine to runtime radius. Missile Silo production must use GetFactoryCommands, not its movement queue. A regression test and a second engine run cover the corrected queue lookup.

The native stockpile widget independently queued ten Trinity missiles on creation and one replacement after the shot in the fixture. Command Layer preserves these existing native queues; it only requests ammunition itself when ready plus queued is zero. Test-only SetUnitStockpile preloads one nuke to avoid waiting three minutes. Production code never changes stockpile readiness.

Public engine reference: [LuaSyncedRead.cpp](https://github.com/beyond-all-reason/spring/blob/master/rts/Lua/LuaSyncedRead.cpp). Installed `gamedata/featuredefs_post.lua` marks unit wrecks/heaps with customParams.fromunit; recovery filters generic cleanup to these rather than indefinitely harvesting terrain rocks.
