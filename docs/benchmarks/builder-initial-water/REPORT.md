# Benchmark results

Completed cases: 1. Outcomes: {'LOSS': 1}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| SailAway 2 / factoryship / 0 | LOSS | 3385 / 11335 | 0/34 |

## sailaway2-factoryship-s0

Opponent opening recorded by offline scorekeeper: factoryship.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('gunshipraid', 3080), ('shipriot', 1320), ('shiptorpraider', 1200), ('dyntrainer_strike_base', 1100), ('shipcon', 1020)].

At five minutes: income 10.6/22.8, mexes 2/10, combat value 1269/1127 (ours/opponent).

Own peak mexes: 4; peak combat value: 2235. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
