# Economy growth and counter-factory revision

This revision keeps the supplied unit matrix active and extends the existing local economic controller. It does not change manual ownership rules, visibility restrictions, stock archives or LuaRules. Enable/disable it with the existing **ECONOMY** control; **STOP AI** stops the automatic session.

## Expansion and worker recovery

The candidate pool remains all unclaimed public metal spots, including distant ones. There is no base-radius cutoff. The planner checks the approach in roughly 320-unit segments against observed contacts. Unseen approaches are surveyed with movement steps of at most 650 units; building occupancy is tested only in current LOS. Absence of a known threat is not proof of safety in fog.

Previously, a stalled worker was permanently excluded. Now an unchanged, identifiable AI order can be removed by its exact native queue tag after 35 seconds without progress. The builder remains enrolled, waits 20 seconds and tries another site; the failed job is suppressed for 120 seconds. Unrecognized queues and manual releases remain protected. A removal cannot include additional queue tags. New unit lifetimes clear old cooldowns.

Resource-starved construction is not treated as a navigation failure. In a critical energy shortage, at most one authorized builder per 30 seconds can leave its own tracked project to restore basic power. Free builders do not all join an expensive unfinished project while basic power is missing. Existing structures/frames and unrelated orders are retained.

Expansion gets two out of three discretionary job opportunities before upgrades; urgent power and necessary finishing work retain priority. This is a job allocation heuristic, not a guaranteed metal-spending percentage.

## Storage, generation and overdrive

The installed source and [official overdrive documentation](https://zero-k.info/mediawiki/index.php?title=Overdrive) establish that storage is a buffer, generation supplies energy, and connected mexes use surplus energy for overdrive. [Pylons](https://zero-k.info/mediawiki/Energy_Pylon) extend the grid but generate no energy themselves.

The planner reads owned structures' native `gridNumber`, `current_energyIncome`, `overdrive_energyDrain` and definition `pylonrange`, as exposed by installed `unit_mex_overdrive.lua`. It does not inspect hidden enemy grids.

- **Storage:** add a buffer when nearly full storage is small relative to income. Metal targets approximately 20 seconds of income; energy targets approximately ten. There is a 3,500-resource target cap and automatic additions stop once six owned storage structures exist. An unfinished storage blocks duplicates. Storage is not ordered merely because income exists while all resources are already being spent.
- **Basic power:** solar on land and tidal/wind in water remain the fallback. Placement can use actual grid overlap: solar's 100 range plus mex's 50 requires closer placement than the old 160-unit first search ring.
- **Fusion:** at metal income of at least 25, sufficient initial funding and a substantial energy deficit, develop fusion instead of endlessly adding small generators. Critical shortages still use fast basic power; an unbuildable fusion falls back to a valid small generator. Pending generation is counted before ordering more discretionary power.
- **Grid extension:** bridge a stronger grid toward a weaker mex grid, comparing generation per mex. Respect the actual source/pylon radii and observed route threats; do not connect nodes already in the same grid. Each planning pass considers at most 32 candidate approaches for route checking. Links beyond 1,800 units are not attempted as a single planning objective; successive completed links can extend a grid.
- **Surplus target:** discretionary generation aims for metal income plus up to six energy per mex, capped at 160 extra energy. This is a bounded heuristic, not an optimal-payback solver. The current implementation does not autonomously build geothermal or singularity reactors.

## Actual counter units and factories

The previous score divided role demand and matrix preference by the square root of unit cost. That favored cheap options even when the database covered the matchup.

For covered matchups, the new score compares role demand in price-neutral units using the same scale as a 100-metal reference unit. The uncovered share retains legacy scoring. The exact-pair preference contributes 1.5 times the same demand scale. Costs still govern funding, shared friendly/queued combat value and sustainability; they no longer give covered cheap units an automatic ranking bonus. Cheap units can still win when the database genuinely ranks them best for the observed composition.

Automatic production limits an unfunded choice to roughly 60 seconds of current metal income, with a 400-metal minimum allowance. Sufficient stored metal can fund a larger choice directly. The first five military units retain the early opening only while no covered visual matchup is known; losses cannot trap a force in cheap-opening mode against an identified counter threat. Constructor/recovery demand remains separate.

When income exceeds approximately 90% of existing factory build capacity and reserves permit, inspect the builder's actual factory options and each factory's affordable counter units. A new factory type must offer a meaningful scoring advantage over available production; otherwise add capacity to a suitable existing type. Native placement/build restrictions still apply. `FACTORY PLAN` logs name the proposed unit and contributing matchup. New factories join the existing automatic production controller; manually released factories remain excluded.

The database is used as requested. Its numerical consistency is not a substitute for measured combat outcomes, and no new performance guarantee is claimed.

## Validation and evidence

All **35 Lua regression suites** pass. New cases cover distant expansion, observed route danger, surveying without hidden occupancy checks, storage scaling, fusion planning, grid connectivity, exact-tag stall recovery, energy-emergency reassignment, manual release, and rejection of extra removal tags. A same-role test verifies that a ten-times-dearer matrix counter outranks a cheap alternative, and that a factory providing it can be selected. Turning the matrix off restores the existing-capacity fallback.

Native checks used the normal commander opening against installed Circuit Brutal, with no extra resources or scripted economic orders.

The final runtime, including counter scoring below five units when supported visual information is available, passed [a 900-second land check](benchmarks/economy-current-land/REPORT.md) and [a 600-second water check](benchmarks/economy-current-water/REPORT.md) without detected controller errors. Both were capped, not wins. Final land telemetry confirmed two completed fusions, three completed pylons and peak overdrive of **12.2591152 metal/second**. Water telemetry recorded peak overdrive of **4.13617039 metal/second**. These are observed integration outcomes, not optimal-efficiency claims.

The immediately preceding runtime, before the small-force scoring gate change, supplied additional economic evidence:

- [Folsom Dam, Shieldbot, both sides](benchmarks/economy-growth-land/REPORT.md): two 900-second capped checks, no detected controller error. Final own mex counts were 18 and 14. Logs and compositions show automatic fusion/pylon construction and production across multiple factory types.
- [SailAway, Shipyard](benchmarks/economy-growth-water/REPORT.md): one 600-second capped check, no detected controller error; eight own mexes at the cap and both naval and plane production.
- [Additional grid telemetry check](benchmarks/economy-grid/REPORT.md): same runtime, one 900-second Folsom check with extra read-only telemetry. Native player accounting recorded peak overdrive income of **10.661046 metal/second**. Telemetry confirmed a completed fusion, a completed pylon and up to four mexes in one grid. No completed storage occurred in this particular run; storage-trigger behavior is covered by regression fixtures.

All these matches reached their time caps; none is recorded as a win. They are functional checks, not a replacement for the complete training/holdout campaign. The holdout maps remain unused. The older 64-match training results evaluate earlier runtime versions.

Earlier diagnostic land/water runs remain locally retained in `benchmark-economy-growth`, `benchmark-economy-water`, `benchmark-economy-growth-final` and `benchmark-economy-water-final`; they predate the final scoring/energy-starvation fixes and are not mixed into the final check reports. Final source hashes are included with each published phase.

Remaining limits include terrain connectivity, transports and remote-island access, protection of expansion from newly revealed enemies, and overall combat strategy. Native pathfinding remains responsible for actual travel. Neither grid heuristics nor the matrix make an unseen route safe or guarantee a favorable engagement.
