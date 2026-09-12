# Benchmark results

Completed cases: 9. Outcomes: {'ABORTED_FOR_FIX': 3, 'LOSS': 6}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| Adamantine Mountain 2 / factoryspider / 0 | ABORTED_FOR_FIX | 1320 / 6220 | 0/15 |
| Comet Catcher Redux v3.1 / factorytank / 0 | ABORTED_FOR_FIX | 1015 / 795 | 11/15 |
| Comet Catcher Redux v3.1 / factorytank / 1 | ABORTED_FOR_FIX | 0 / 0 | 0/0 |
| Comet Catcher Redux v3.1 / factoryveh / 0 | LOSS | 165 / 9575 | 1/61 |
| Comet Catcher Redux v3.1 / factoryveh / 1 | LOSS | 4115 / 12135 | 0/78 |
| Red Comet Remake 1.7 / factorycloak / 0 | LOSS | 2210 / 7925 | 0/32 |
| Red Comet Remake 1.7 / factorycloak / 1 | LOSS | 3600 / 10230 | 0/37 |
| Red Comet Remake 1.7 / factoryveh / 0 | LOSS | 3940 / 11000 | 0/35 |
| Red Comet Remake 1.7 / factoryveh / 1 | LOSS | 1310 / 11655 | 0/27 |

## adamantine_mountain_2-factoryspider-s0

Opponent opening recorded by offline scorekeeper: factoryamph.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('staticmex', 1275), ('dyntrainer_strike_base', 1100), ('energysolar', 980), ('spideremp', 760), ('factoryspider', 700)].

At five minutes: income 18.4/19.5, mexes 11/9, combat value 723/1520 (ours/opponent).

Own peak mexes: 11; peak combat value: 824. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factorytank-s0

Opponent opening recorded by offline scorekeeper: factoryveh.

No automatic diagnostic flag; review the full timeline.

Largest own losses by unit value: [('staticmex', 425), ('tankheavyraid', 300), ('energysolar', 70)].

At five minutes: income 24.3/31.9, mexes 9/10, combat value 1616/1220 (ours/opponent).

Own peak mexes: 13; peak combat value: 2467. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factorytank-s1

Opponent opening recorded by offline scorekeeper: unavailable.

No automatic diagnostic flag; review the full timeline.

Largest own losses by unit value: [].

Own peak mexes: 0; peak combat value: 0. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factoryveh-s0

Opponent opening recorded by offline scorekeeper: factorytank.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('staticmex', 2465), ('energysolar', 1960), ('dyntrainer_strike_base', 1100), ('vehraid', 780), ('factoryveh', 700)].

At five minutes: income 39.9/24.0, mexes 15/7, combat value 1770/2220 (ours/opponent).

Own peak mexes: 24; peak combat value: 1870. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factoryveh-s1

Opponent opening recorded by offline scorekeeper: factoryveh.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('vehraid', 2990), ('staticmex', 2210), ('energysolar', 1820), ('factoryveh', 1400), ('vehcon', 840)].

At five minutes: income 36.5/29.0, mexes 13/9, combat value 2072/1440 (ours/opponent).

Own peak mexes: 16; peak combat value: 2599. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factorycloak-s0

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('energysolar', 1540), ('cloakraid', 1365), ('staticmex', 1360), ('dyntrainer_strike_base', 1100), ('cloakcon', 720)].

At five minutes: income 23.5/29.9, mexes 7/9, combat value 1055/1720 (ours/opponent).

Own peak mexes: 10; peak combat value: 1310. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factorycloak-s1

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('cloakraid', 2340), ('energysolar', 1820), ('staticmex', 1530), ('dyntrainer_strike_base', 1100), ('cloakskirm', 720)].

At five minutes: income 23.0/25.9, mexes 6/9, combat value 1263/1782 (ours/opponent).

Own peak mexes: 9; peak combat value: 1779. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factoryveh-s0

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('vehraid', 2080), ('energysolar', 2030), ('staticmex', 1700), ('dyntrainer_strike_base', 1100), ('vehriot', 960)].

At five minutes: income 26.7/26.9, mexes 11/8, combat value 1632/1047 (ours/opponent).

Own peak mexes: 16; peak combat value: 1860. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factoryveh-s1

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('vehraid', 3900), ('energysolar', 1610), ('staticmex', 1445), ('dyntrainer_strike_base', 1100), ('vehriot', 960)].

At five minutes: income 29.0/26.1, mexes 10/9, combat value 1486/1924 (ours/opponent).

Own peak mexes: 13; peak combat value: 1586. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
