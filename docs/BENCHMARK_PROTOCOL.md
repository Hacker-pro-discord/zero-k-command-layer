# Circuit Brutal calibration protocol

Pinned target: Zero-K v1.14.8.0, engine 2025.06.21, installed 1052188CircuitAIBrutal64/stable (Circuit Brutal 1.2.15). The installed Dev build fails EVENT_INIT with error 201 and is not a valid opponent. AI options use shipped defaults, including LOS cheating off. See [Circuit source](https://github.com/rlcevg/CircuitAI/tree/zk) and the [official difficulty list](https://zero-k.info/Forum/Post/176480).

`tests/benchmark_maps.json` freezes eight training maps and three holdout maps. Each has two opening factories and both spawn sides: 32 training cases and 12 holdout cases. Terrain categories/start positions come from installed native metadata/start boxes. Height statistics include mapinfo/SMD overrides. Side B swaps coordinates and ally-team/start-box IDs. Terrain inspection is permitted before validation; holdout match performance is not.

Run baseline, diagnose training failures, freeze a candidate, rerun all 32 training cases, then evaluate 12 holdout cases without tuning on them. Four cases per map are a modest sample. Engine FixedRNGSeed is recorded; Circuit's internal RNG is not guaranteed deterministic. Seeds are paired across revisions. Each case snapshots widget/harness source, hashes engine/AI files and saves demo, infolog, events and summary. Use a new directory per revision.

Matches start with native commanders/resources. The Officer builds the requested factory and manages ongoing economy itself. No scripted opening orders, bonuses, invulnerability, terrain flattening or spawned armies. Cap: 1,200 game seconds at requested 20x speed, three isolated headless processes. A cap is CENSORED, never a win. Native GameOver determines wins/losses. Missing client telemetry, absent enemy activity, AI initialization failures and controller errors invalidate runs. Wall timeout is a separate failure.

The synced scorekeeper only logs for post-match analysis; it issues no orders and exposes no data to LuaUI. Officer observations use normal player LOS/radar. Ground-truth economy/army/casualty curves are evaluation-only. Client telemetry samples current LOS, cumulative explored cells and cells visited by the assigned scout detachment on a 16x16 grid. These are coverage proxies, not exact territorial ownership. Mex share is the resource-control proxy. Native kill attribution can miss environmental/unattributed damage; report total losses separately.

Collect reserve/recovery/regroup/withdrawal states, production mix and strategy reasons. Diagnose each loss from timelines and final state, distinguishing evidence from causal hypotheses. Retain invalid pilot records. Passing regression tests does not mean calibrated performance.

Run `python tools/benchmark.py --game GAME_DIRECTORY --directory NEW_RESULTS_DIRECTORY --split train` from the repository. Benchmark data stays outside the installed game. Only production LuaUI files are installable; scorekeeper and driver are test-only.

Initial 8x runs are preliminary timing/diagnostic pilots and excluded from the paired campaign. All formal baseline/candidate/holdout cases request 20x with three workers; actual speed may be CPU limited.

Population fields count spawned units, including unfinished frames; army value is weighted by build completion. The first-five-created metric is not the first-five-completed metric. Candidate telemetry additionally records completed military count and native factory queue quantities/repeat states. These extra fields do not alter the controller; earlier records lacking them stay unavailable. Baseline subgroup lists can retain dead entries; native population metrics are the authoritative counts.
