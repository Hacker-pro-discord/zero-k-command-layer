# Five-unit pressure and strategy adaptation (preview 5)

## Implemented behavior

Only explicitly delegated forces gain automatic recovery authority. Adviser-only and one-shot approved operations retain their existing approval contract. Five suitable units produce one scout and four MAIN units immediately after delegation; there is no production or large-army gate.

Failure triggers: over 25% review membership lost/released, average health below 40%, or 60 seconds without 128 units of forward progress. Recovery preserves the original objective corridor and passes every order through Officer and Orders ownership checks.

WITHDRAWING uses native movement toward the corridor origin. REFORMING restores Assault role zones, retaining the original facing so artillery stays behind the screen. At least 80% of surviving eligible stage units must be within 96 units of their slots to progress. HOLDING lasts at least eight seconds and waits for average health of 50%. A resumed attempt uses 65% of the previous step length (minimum 240), 20% wider spacing (maximum 256), and an alternate lane chosen using visible/radar uncertainty-weighted risk. No hidden identity is consulted. Recovery retries have 20-second cooldowns, a 45-second move timeout and a three-failure limit before holding for a new objective.

UI AI Details exposes strategy revision, formation, spacing, step and lane. Recovery timeouts now explain their reason rather than leaving only the original trigger message.

## Regression evidence

All 20 Lua 5.1 suites pass. New tests cover exactly five early units; no recovery proposal creation; fallback using RAW_MOVE; changed step/spacing/lane; manual release during recovery; health hysteresis; cancellation; keeping artillery behind the screen while moving backward; choosing away from known left-side resistance; and progressing with four of five units arrived. Existing 400/1,000-unit and production tests still pass.

## Five-unit real engine test

Zero-K v1.14.8.0 / engine 2025.06.21; 120 game seconds. Test-only fixture creates five raiders per team. Enemy fire is disabled for this controlled recovery test. Own health is set to 30% at second 30 and restored at second 50. These interventions are fixture code, not widget capabilities.

| Game second | Observation |
|---|---|
| 8 approximately | One scout and four MAIN units receive initial operations. |
| 16 | All five have moved over 32 units; average forward movement 557. |
| 26 | Average forward movement 1,036. |
| 30 | Controlled damage triggers automatic fallback. |
| 36 | WITHDRAWING; average forward position has fallen to 624. |
| 46 | HOLDING after regroup; all five remain alive. |
| 50 | Fixture restores health. |
| 52 approximately | ADAPT_RESUME: revised movement resumes without approval. |
| 56 | ADVANCING, all five queued; average forward movement 729. |
| 66 | Average forward movement 1,059. |
| 120 | Test completes, no approval proposals or Command Layer exceptions. |

Selected evidence: `early-five-engine.txt`. This demonstrates early pressure, fallback, regroup and a revised advance. It does not measure contested map ownership or winning against an active opponent.

## Heavy combat test and remaining failure

The final 180-second stress run uses 400 units per side and four own factories, with a scripted Fight opponent. At approximately second 50 the loss trigger starts a 286-unit withdrawal without asking for approval. Recovery times out, waits, and starts a 130-unit regroup at second 116. Congestion and continued losses prevent a clean resumed advance by second 180. The controller remains delegated and holds/retries within its existing authority; it does not silently require a new approval.

Original-roster survivors at second 180: 71 own / 105 enemy; surviving value 9,420 / 12,850. This excludes reinforcements. There is no win or strategy-strength claim: the test is asymmetric because own factories produce additional units, and runs are not a deterministic paired comparison.

The test changed behavior when the first approach failed, but **large-army recovery under heavy pressure remains a weakness**. Initial order reliability is not the same as successful tactical recovery. Terrain/path suitability and recovery geometry need further work. Selected final evidence: `adaptive-heavy-engine.txt`.

No Command Layer Lua exceptions or approval proposals appeared in these runs. The final heavy run includes the original-facing and 80%-arrival changes; the later edits improve debug wording/rule version and correct the initial Shock and Awe/Utter Destruction step reduction. Those final policy expressions pass the regression suite. New AI Details text has not had interactive visual QA.

## Reproduce

`python tools/run_combat_test.py --game PATH --directory SEPARATE_PATH --headless --seconds 120 --early-five`

`python tools/run_combat_test.py --game PATH --directory OTHER_SEPARATE_PATH --headless --seconds 180 --stress`

The fixtures never modify original game archives or a running user match. Autonomous behavior remains single-player only.
