# Benchmark results

Completed cases: 1. Outcomes: {'CENSORED': 1}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| SailAway 2 / factoryship / 0 | CENSORED | 4990 / 18185 | 3/55 |

## sailaway2-factoryship-s0

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('shiptorpraider', 5500), ('factoryship', 1400), ('factorygunship', 1400), ('energywind', 1120), ('staticmex', 1105)].

At five minutes: income 12.1/26.3, mexes 3/11, combat value 1215/987 (ours/opponent).

Own peak mexes: 10; peak combat value: 3475. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
