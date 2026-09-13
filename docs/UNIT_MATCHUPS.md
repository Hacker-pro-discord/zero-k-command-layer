# Unit-by-unit production preferences

Enabled by default at the user's explicit request, using the unfinished supplied matrix. This is a later change than the 64 training matches in [the benchmark report](BENCHMARK_RESULTS.md); those results do not measure its benefit.

`CounterMatrixData.lua` preserves the supplied file unchanged, including original comments. `UnitMatchups.lua` is the adapter. The data cannot call order services or grant control. Its direction is candidate row -> enemy column: 1.00 is neutral, above 1 favors the candidate, below 1 penalizes it. The generic `#class` columns and `counteredBy` table are deliberately unused so uncovered matchups keep the existing role logic. Commander chassis aliases are not guessed; actual names that do not match retain fallback.

EnemyModel now stores the definition/name observed during visual contact and aggregates decayed metal value by exact unit type. Radar does not create or refresh identities. Remembered visual contacts keep the existing half-life and expiry; unknown radar contacts additionally reduce the matrix contribution. Spectator/replay/multiplayer gates remain unchanged.

For each actual factory build option, the existing role deficit score remains the base. The adapter adds half the existing production demand scale multiplied by the weighted `(pair value - 1)` contribution. It divides by the full undecayed observed value (minimum 300), including uncovered names, plus 50 per unknown radar contact. This retains uncovered demand and makes stale sightings less influential. Missing/invalid pairs contribute zero, and values of 1.00 leave the score unchanged. Values outside the supplied 0.05-1.95 range are rejected. All supplied exact values are provisional; no reviewed status is fabricated.

Conservative capability gates leave incompatible pairs on legacy scoring: ground-only roles do not receive anti-air matrix preferences, AA roles do not receive ground-counter preferences, and ground units do not receive submarine preferences. These are conservative classification checks, not a weapon/terrain simulation; some valid mixed-capability matchups can therefore remain on fallback.

All controlled factories share friendly completed/queued role value, updated after each purchase. Economy/recovery builder demand, actual build options, resource funding, idle native queues and manual factory exclusions still take priority. The first five military units keep the established opening selection; subsequent combat production uses the matrix supplement. Read-only production advice also considers exact pair scores when covered candidates exist. No building or combat orders originate from the data module.

Disable **Unit-by-unit counter matrix (unfinished draft)** in Command Layer settings to restore legacy production scoring. The setting persists. Production logs include signed bias, effective coverage and the strongest contributing pair, e.g. `shieldraid=1.15`. That pair is one contribution, not necessarily the sole reason a unit won the overall composition/resource comparison.

## Validation

- All 33 Lua regression suites pass, including new tests for matrix direction, same-role/same-cost unit choices across four factories, manual factory release, read-only advice, partial coverage, negative deficits, neutral/missing/invalid values, stale contact decay, radar identity refusal, capability fallback and the persisted off switch.
- A frozen five-game-minute native Red Comet/Cloakbot pilot against the same stock Circuit Brutal completed with no detected controller error. It is recorded as CENSORED at 300 seconds, not a win.
- Native production logs confirm the adapter was active: Knight decisions included `shieldraid=1.15`, and other decisions recorded nonzero positive/negative bias and partial coverage. Unknown radar counts remained explicit.
- [Pilot evidence and timeline](benchmarks/matrix-pilot/REPORT.md). This is an integration smoke test, not a playing-strength comparison. No holdout map was run and no claim of matrix-driven improvement is made.

Future revisions can replace this data file while preserving the adapter and fallback. Per-pair confidence/review metadata would improve diagnostics, but is not required for this explicitly requested draft activation. Attribution and the unresolved upstream author/license information are recorded in [Attribution](ATTRIBUTION.md).
