# Benchmark results

Completed cases: 2. Outcomes: {'CENSORED': 2}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| FolsomDamDeluxeV4 / factoryshield / 0 | CENSORED | 3340 / 7115 | 18/29 |
| FolsomDamDeluxeV4 / factoryshield / 1 | CENSORED | 5280 / 6390 | 14/31 |

## folsomdamdeluxev4-factoryshield-s0

Opponent opening recorded by offline scorekeeper: factoryamph.

No native winner before the game-time cap. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('shieldfelon', 1240), ('gunshipbomb', 1155), ('vehraid', 1040), ('shieldriot', 1000), ('shieldraid', 600)].

At five minutes: income 27.7/19.7, mexes 12/5, combat value 1320/1366 (ours/opponent).

Own peak mexes: 18; peak combat value: 9952. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factoryshield-s1

Opponent opening recorded by offline scorekeeper: factorycloak.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('shieldraid', 2475), ('staticmex', 935), ('gunshipbomb', 660), ('shieldfelon', 620), ('energysolar', 560)].

At five minutes: income 21.0/27.8, mexes 7/8, combat value 1274/1297 (ours/opponent).

Own peak mexes: 14; peak combat value: 5153. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
