# Benchmark results

Completed cases: 2. Outcomes: {'CENSORED': 2}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| FolsomDamDeluxeV4 / factoryshield / 0 | CENSORED | 10180 / 49411 | 5/36 |
| FolsomDamDeluxeV4 / factoryshield / 1 | CENSORED | 13075 / 20590 | 23/30 |

## folsomdamdeluxev4-factoryshield-s0

Opponent opening recorded by offline scorekeeper: factorycloak.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('planecon', 5600), ('gunshipraid', 3740), ('factoryplane', 3500), ('shieldraid', 3075), ('gunshipheavyskirm', 3040)].

At five minutes: income 30.1/26.2, mexes 11/9, combat value 1753/955 (ours/opponent).

Own peak mexes: 26; peak combat value: 7235. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factoryshield-s1

Opponent opening recorded by offline scorekeeper: factorycloak.

No native winner before the game-time cap. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('gunshipassault', 2550), ('shieldraid', 2400), ('gunshipheavyskirm', 2280), ('shieldfelon', 1860), ('bomberstrike', 1600)].

At five minutes: income 30.0/15.8, mexes 12/5, combat value 1472/767 (ours/opponent).

Own peak mexes: 24; peak combat value: 12959. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
