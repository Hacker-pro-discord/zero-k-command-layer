# Temporary military catch-up spending

MilitaryBudget is a read-only policy shared by Economy and ProductionController. It operates only while both services have local/private automation authority. It cannot issue orders, take a manually released factory, or read enemy team resources. Its active state is not persisted across matches.

## Trigger and exit

- Require at least three identified enemy mex income samples from visual sightings within 90 seconds. Their mean decay weight must be at least 0.5.
- Compare own metal income with the sum of those decaying observed mex incomes. Own income must be between 80% and 150% of that estimate.
- Require at least 600 observed enemy mobile military value, and own completed mobile military value below 65% of that decaying estimate. Constructors and static defenses are excluded. Own unfinished units and production queues do not count as a ready army.
- Enter after these conditions persist for 15 game seconds.
- Exit after army value reaches 85% of the estimate, or parity/evidence ceases to qualify, for 30 seconds. Separate thresholds prevent rapid toggling.

This is a partial scouting estimate, **not the opponent's actual total income or army**. Unseen mexes, reclaim, innate income and other sources are not invented. Insufficient intel retains the existing spending policy. Radar neither identifies units nor refreshes economy evidence. The installed `LuaRules/Gadgets/unit_mex_overdrive.lua` publishes `current_metalIncome` with `inlosTrueTable`; this implementation samples that parameter only from visual mex contacts, then retains timestamped history. It does not use private `OD_team_*` opponent accounting or benchmark scorekeeper data.

## Spending changes

While active, factories prefer counter troops over additional economic/recovery constructors if at least one owned mobile builder survives. With no builder, ordinary replacement-worker rules remain available. Existing counter-matrix scoring and recovery's reconstruction funding reservation remain intact. The discretionary metal buffer falls from 100 to 40; the 100-energy reserve remains.

Economy defers new storage, grid pylons, fusion/overdrive upgrades and assistance to those unfinished projects. An existing tracked optional build order can be removed by its exact queue tag when current power is adequate; its foundation is retained. Existing manual orders and unrelated construction queues are preserved. Basic power, the initial/replacement factory and limited mex expansion remain possible. Mex spending requires enough cash beyond the troop initial-funding buffer. Independent Recovery continues its repair/reconstruction duties.

Extra factory capacity takes precedence over mex expansion only when saturation persists for 20 seconds: at least 75% of completed factories are busy, metal income exceeds their summed native build power by 10%, at least five seconds of income (minimum 150 metal) is stored, energy supports production, and no factory is already under construction. A busy factory is not proof of good unit choices; this check only diagnoses insufficient aggregate capacity. Idle factories do not justify another factory. Native build options, counter-factory selection and placement validation still apply.

Production status shows `MILITARY CATCH-UP`. The debug log records transitions with own/observed army and income. `GetEconomyAutomationStatus().budget` exposes the full current explanation for diagnostics.

## Validation

All 38 Lua regression suites pass, including timing/hysteresis, stale radar history, completed-army accounting, busy/idle factory capacity, optional infrastructure suppression, essential power, counter troop funding and manual factory release. These are behavioral tests, not evidence of improved win rate. An isolated normal-start Circuit Brutal check on Red Comet / Cloak / side 0 reached its 600-second cap with zero detected controller errors. Catch-up activated at 590.6 seconds: own army 155 versus observed 4,245; own income 6.0 versus observed mex income 5.7. This demonstrates live activation, not actual enemy-income parity or stronger performance. The enemy estimate is incomplete. See [native report and telemetry](benchmarks/military-budget/REPORT.md).
