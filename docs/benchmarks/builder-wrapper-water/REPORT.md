# Benchmark results

Completed cases: 1. Outcomes: {'CENSORED': 1}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| SailAway 2 / factoryship / 0 | CENSORED | 4750 / 29700 | 7/38 |

## sailaway2-factoryship-s0

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('gunshipassault', 17000), ('gunshipraid', 2200), ('shiptorpraider', 1100), ('shipriot', 1100), ('dyntrainer_strike_base', 1100)].

At five minutes: income 16.3/19.3, mexes 4/6, combat value 1560/1890 (ours/opponent).

Own peak mexes: 9; peak combat value: 3464. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
