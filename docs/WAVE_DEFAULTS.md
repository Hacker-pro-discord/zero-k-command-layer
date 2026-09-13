# Win the Game / Wave Tactics

## Control contract

Automatic local startup selects WIN THE GAME and WAVE TACTICS. Startup retains the existing local/private gate and saved automatic-start preference. Assignment alone grants no movement authority. Selecting a tactic alone issues no orders. STOP AI stops the current session; public multiplayer restrictions and legitimate-observation boundaries remain unchanged.

The Officer exposes factoryControl(ON/OFF/ENROLL/RELEASE) to its UI. ON explicitly enables existing-factory automation; ENROLL returns selected factories including manually excluded ones. RELEASE blocks future additions. All preserve existing native queues. ProductionController continues selecting actual build options using rolling visual intel and the counter matrix, with legacy fallback for unknown matchups.

## Wave implementation

The existing TacticalController remains the decision maker. The opening MAIN force receives its native Fight operation immediately. While that operation is active, newly assigned ground recruits gather into follow-up cohorts. A cohort of three is ready immediately if the 12-second launch cooldown is clear; a smaller cohort becomes ready after 12 seconds. Each cohort receives a role-aware plan toward the current main operation destination through Officer.executeDelegated and the shared Orders executor. Cohorts do not acquire new objectives independently. Later main advances do not reclaim units still owned by an active reinforcement operation.

This is repeated reinforcement-wave behavior, not synchronized multi-front offensives or sacrificial attacks. Failed geometry/authority validation can extend the wait. Retreating, transported, manually released and suspended units cannot enter a new cohort. Main-force recovery still cancels its offensive operations. Defense reserves remain separate. Air/sea retain domain-specific routing and control rather than being packed into ground waves.

Wave diagnostics include WAVE events, wave number and the selected tactic in AI DETAILS. CONTINUOUS PRESSURE retains immediate recruitment reinforcement. New manually assigned forces use the saved default tactic when explicitly delegated.

## Scouting and economy

Wave mode allows a suitable scout at three units (previously five); larger forces support up to four scout units and eight raiders. These are subgroup sizes, not guaranteed independently routed scout patrols. The classifier must find suitable units, and defense, casualties and native retreat can reduce availability.

WIN THE GAME prioritizes mex consideration on three of four discretionary job turns. Emergency power, spending limits, military catch-up capacity, occupancy, retry backoffs and observed-threat route checks remain in place. This increases expansion priority without treating fog as safe.

## Verification

40 Lua suites and seven Python benchmark tests pass, including a thousand-unit lifecycle scenario, manual overrides, factory queue preservation, default selection, early scouting, bounded reinforcement waiting and UI button callbacks. Native headless tests exercise the installed engine; interactive Chili rendering is not verified by the headless harness. Native reports below record censored matches as censored, never wins.


### Native results, 2026-09-12

Both final-source runs used stock Circuit Brutal, normal resources, side 0 and a 900-game-second cap. Neither reached a native winner before the cap; both were strategically behind. The harness reported zero runtime errors. All 34 production files matched the tested snapshots and the installed local widget files. These are two regression runs, not a completed calibration campaign; holdout maps were untouched.

| Final build | Outcome | Value killed / lost | Final mexes, ours / enemy | Ground follow-up waves |
|---|---|---:|---:|---:|
| [Folsom, Shield](benchmarks/wave-release-land/REPORT.md) | Censored at 15 min | 3,630 / 20,710 | 0 / 33 | 12 |
| [SailAway, Ship](benchmarks/wave-release-water/REPORT.md) | Censored at 15 min | 2,885 / 16,920 | 10 / 41 | 0 (domain control) |

The land force suffered a severe infrastructure collapse. Water also lost substantially more value than it killed. Both retain expansion-survival and engagement-selection problems; increased activity is not evidence of better win rate. Ground wave batching does not implement naval waves. A preceding land smoke run, before final default/manual-retreat validation adjustments, is retained separately in [initial results](benchmarks/wave-initial-land/REPORT.md); do not treat its different outcome as a controlled performance comparison.
