# Circuit Brutal training campaign: results and limits

The corrected Officer is **not consistently competitive with Circuit Brutal**. Two complete 32-case training passes recorded no wins. The campaign has useful failure evidence and verified implementation fixes; it has not achieved the requested playing-strength goal. Independent holdout validation is deferred.

| Frozen phase | Wins | Losses | 20-minute caps | Invalid |
|---|---:|---:|---:|---:|
| Initial ongoing-economy baseline | 0 | 25 | 7 | 0 |
| Corrected candidate 2 | 0 | 20 | 12 | 0 |

Each phase used eight maps, two starting factories per map and both spawn sides. Maps cover open/small/large land, rough terrain, chokepoints, coast/amphibious play, islands and true water. Native commander/resources; the Officer builds and expands its own economy. Opponent: installed 1052188CircuitAIBrutal64/stable, Circuit Brutal 1.2.15, with shipped options and LOS cheating off. Engine 2025.06.21; Zero-K v1.14.8.0. No artificial opening, extra resources or terrain editing.

Caps mean no native winner by 1,200 game seconds, not wins or draws. Several capped games were already badly disadvantaged. Four scenarios per map are a modest sample, and Circuit's internal RNG can change its opening despite the paired engine seed. These results do not establish statistical significance.

- [Complete paired comparison](benchmarks/COMPARISON.md) and [CSV](benchmarks/paired.csv).
- [Baseline: every case, loss indicators and checkpoints](benchmarks/baseline/REPORT.md).
- [Candidate: every case, loss indicators and checkpoints](benchmarks/candidate2/REPORT.md).
- Candidate curves: [army](benchmarks/candidate2/curves_armyValue.png), [income](benchmarks/candidate2/curves_metalIncome.png), [mexes](benchmarks/candidate2/curves_mexes.png), [coverage](benchmarks/candidate2/curves_coverage.png).
- [Preliminary candidate 1](benchmarks/preliminary-candidate1/REPORT.md): six completed losses and three aborted cases, excluded from the full comparison after the storage-threshold fix required a restart.

## What improved and what was verified

The sample median nominal killed/lost ratio rose from 0.07 to 0.26. Median own/opponent metal-income ratio at five minutes rose from 0.76 to 0.86. These are descriptive measurements of the whole fix bundle, not proof that any individual heuristic caused an improvement. Nominal casualty values include unfinished frames and are not exact paid-resource accounting.

Confirmed fixes include native factory quantity modifiers, Zero-K overdrive energy accounting, streaming funding under normal storage limits, early military allocation, builder service ownership, recycled unit IDs, bounded defense allocation and recent failed-area avoidance. See [calibration notes](CALIBRATION_NOTES.md) for evidence and source references.

Across 5,252 sampled native factory queues in candidate 2, maximum queue length was one and repeat was never enabled. Native matches created additional factories and produced through multiple factories. Five completed military units appeared between approximately 30 and 201 game seconds depending on the opening; the land pilot's 60-second result does not generalize to every factory/map.

All 32 Lua regression suites and seven benchmark-parser tests pass. Candidate runtime files match the frozen source manifest. All 32 native candidate matches supplied player telemetry and an active compatible stock AI without detected controller errors. Headless testing does not validate visible Chili rendering or human mouse interaction; the new economy controls have fixture coverage, not new visual in-game acceptance in this campaign.

## Remaining failure mechanisms

These are supported diagnostic priorities, not a claim of a complete causal attribution for each death. Each case's report contains its opponent opening, five-minute economy/army checkpoint, peak expansion, casualty mix, state frequencies and relevant stall/health-wait indicators. JSONL files retain all curves and emitted Officer decisions with game timestamps.

1. **Expansion survives poorly under pressure.** Some openings establish a competitive early economy, then lose mexes, builders and factories. Red Comet vehicle side 0 had 13 mexes versus seven at five minutes but still lost. Expansion needs protection and a better spending balance, not simply more mex orders.
2. **Combat trades remain unfavorable.** Even the corrected median ratio is far below one. Coarse role weights, local risk thresholds and separate detachments do not provide robust force concentration, artillery employment or an effective answer to established defenses. The matrix alone would not solve these control problems.
3. **Defense can dominate the operation.** Many matches spend most sampled time defending or escorting recovery. The allocation cap prevents one category of overcommitment, but does not establish good front selection or coordinated counter-pressure.
4. **Water-compatible points do not establish route connectivity.** Island openings can retain a very small economy while the opponent expands widely. Constructor access, land/water transitions, domain-specific expansion and inaccessible-site recovery require stronger planning. Transport logistics are not implemented.
5. **Recovery can lose productive capacity.** Stalled workers are released pending manual review. Damaged forces can wait for average health recovery while automatic repair concentrates on infrastructure. A future fix must distinguish voluntary manual release from recoverable navigation failure and coordinate mobile-unit repair without seizing manually controlled units.
6. **Late economy is basic.** The new service supports factories, public mex spots, basic energy and builder capacity. It does not implement a complete fusion/pylon/overdrive network or terrain-aware base-defense planner. Circuit often pulls far ahead later.

## Holdout and next calibration

Agalta, Trojan Hills and Bellicose Islands remain unused for performance evaluation: 12 planned holdout cases are **NOT RUN**. After training showed no wins, validation was deferred to preserve an independent test for a stronger frozen candidate. No holdout result was used to tune these fixes. The overall benchmark/validation objective remains unfinished.

The next tuning cycle should address expansion protection, sustainable recovery and connected land/naval routing, then rerun all 32 training scenarios. Do not replace the full set with a favorable map. Use the holdout only after the training candidate demonstrates wins across terrain families; do not tune against those validation results.

The user-supplied unfinished matchup matrix remains inactive and outside the distributable package. [Its review](MATRIX_DRAFT_REVIEW.md) defines reviewed-pair integration, confidence/coverage reporting and unchanged legacy fallback for unknown or unreviewed pairs. A future matrix candidate starts with non-executing comparisons and its own frozen training pass.

Raw demos, original logs and source snapshots remain in the local isolated benchmark directories. Published data is sanitized to benchmark/Officer records. Synced scoring data is offline evaluation only and is never supplied to the Officer. Manual override, normal visibility restrictions and the single-player automation gate remain in force.
