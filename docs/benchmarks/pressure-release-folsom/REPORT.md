# Benchmark results

Completed cases: 2. Outcomes: {'LOSS': 1, 'CENSORED': 1}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| FolsomDamDeluxeV4 / factoryshield / 0 | LOSS | 1900 / 24735 | 0/32 |
| FolsomDamDeluxeV4 / factoryshield / 1 | CENSORED | 5860 / 29210 | 0/43 |

## folsomdamdeluxev4-factoryshield-s0

Opponent opening recorded by offline scorekeeper: factorycloak.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('planescout', 8160), ('energyfusion', 3000), ('bomberassault', 3000), ('shieldcon', 2160), ('factoryshield', 2100)].

At five minutes: income 24.8/20.3, mexes 9/8, combat value 1387/1167 (ours/opponent).

Own peak mexes: 11; peak combat value: 3481. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factoryshield-s1

Opponent opening recorded by offline scorekeeper: factoryhover.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('planescout', 4080), ('shieldcon', 2880), ('staticmex', 2380), ('energyfusion', 2000), ('energysolar', 1680)].

At five minutes: income 15.0/23.2, mexes 5/6, combat value 827/1890 (ours/opponent).

Own peak mexes: 10; peak combat value: 3755. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
