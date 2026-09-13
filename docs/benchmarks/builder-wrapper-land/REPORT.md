# Benchmark results

Completed cases: 2. Outcomes: {'LOSS': 1, 'CENSORED': 1}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| FolsomDamDeluxeV4 / factoryshield / 0 | LOSS | 3020 / 35870 | 0/34 |
| FolsomDamDeluxeV4 / factoryshield / 1 | CENSORED | 10465 / 22085 | 12/34 |

## folsomdamdeluxev4-factoryshield-s0

Opponent opening recorded by offline scorekeeper: factorycloak.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('bomberheavy', 20000), ('energyfusion', 3000), ('factoryshield', 2100), ('staticmex', 2040), ('energysolar', 1610)].

At five minutes: income 16.8/22.4, mexes 6/8, combat value 1059/1310 (ours/opponent).

Own peak mexes: 13; peak combat value: 3922. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factoryshield-s1

Opponent opening recorded by offline scorekeeper: factorycloak.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('shieldraid', 5250), ('energyfusion', 3000), ('factoryshield', 2100), ('shieldscout', 1680), ('factoryplane', 1400)].

At five minutes: income 22.2/16.1, mexes 10/5, combat value 1492/959 (ours/opponent).

Own peak mexes: 17; peak combat value: 6317. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
