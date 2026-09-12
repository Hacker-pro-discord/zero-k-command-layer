# Benchmark results

Completed cases: 32. Outcomes: {'LOSS': 25, 'CENSORED': 7}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| Adamantine Mountain 2 / factoryjump / 0 | LOSS | 2500 / 16605 | 0/21 |
| Adamantine Mountain 2 / factoryjump / 1 | LOSS | 340 / 12140 | 0/34 |
| Adamantine Mountain 2 / factoryspider / 0 | LOSS | 250 / 11755 | 0/27 |
| Adamantine Mountain 2 / factoryspider / 1 | LOSS | 675 / 7665 | 0/21 |
| Altair_Crossing_V4 / factorycloak / 0 | LOSS | 880 / 8140 | 0/17 |
| Altair_Crossing_V4 / factorycloak / 1 | LOSS | 1320 / 7770 | 0/26 |
| Altair_Crossing_V4 / factoryveh / 0 | LOSS | 640 / 7800 | 0/17 |
| Altair_Crossing_V4 / factoryveh / 1 | LOSS | 0 / 6365 | 0/11 |
| Aquatic Divide Revised v02 / factoryamph / 0 | LOSS | 2460 / 8425 | 1/14 |
| Aquatic Divide Revised v02 / factoryamph / 1 | LOSS | 240 / 8215 | 0/12 |
| Aquatic Divide Revised v02 / factoryhover / 0 | CENSORED | 2525 / 14245 | 0/21 |
| Aquatic Divide Revised v02 / factoryhover / 1 | LOSS | 320 / 7245 | 0/11 |
| Comet Catcher Redux v3.1 / factorytank / 0 | LOSS | 1980 / 14590 | 0/63 |
| Comet Catcher Redux v3.1 / factorytank / 1 | LOSS | 4075 / 11905 | 0/63 |
| Comet Catcher Redux v3.1 / factoryveh / 0 | LOSS | 4500 / 14155 | 0/76 |
| Comet Catcher Redux v3.1 / factoryveh / 1 | LOSS | 1135 / 16770 | 0/60 |
| FolsomDamDeluxeV4 / factorycloak / 0 | LOSS | 65 / 13780 | 1/46 |
| FolsomDamDeluxeV4 / factorycloak / 1 | CENSORED | 7805 / 11490 | 16/38 |
| FolsomDamDeluxeV4 / factoryshield / 0 | CENSORED | 730 / 14175 | 0/48 |
| FolsomDamDeluxeV4 / factoryshield / 1 | CENSORED | 390 / 16860 | 0/39 |
| Porky_Islands / factoryamph / 0 | LOSS | 720 / 4770 | 0/11 |
| Porky_Islands / factoryamph / 1 | CENSORED | 970 / 14985 | 12/41 |
| Porky_Islands / factoryship / 0 | LOSS | 80 / 6755 | 0/44 |
| Porky_Islands / factoryship / 1 | LOSS | 970 / 16755 | 0/52 |
| Red Comet Remake 1.7 / factorycloak / 0 | LOSS | 2415 / 12475 | 0/40 |
| Red Comet Remake 1.7 / factorycloak / 1 | LOSS | 3280 / 13175 | 0/30 |
| Red Comet Remake 1.7 / factoryveh / 0 | LOSS | 80 / 13925 | 1/30 |
| Red Comet Remake 1.7 / factoryveh / 1 | LOSS | 380 / 7815 | 0/35 |
| SailAway 2 / factoryhover / 0 | CENSORED | 1400 / 19025 | 0/70 |
| SailAway 2 / factoryhover / 1 | CENSORED | 930 / 22535 | 0/69 |
| SailAway 2 / factoryship / 0 | LOSS | 510 / 16470 | 0/55 |
| SailAway 2 / factoryship / 1 | LOSS | 5045 / 13600 | 1/65 |

## adamantine_mountain_2-factoryjump-s0

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('jumpraid', 6600), ('factoryjump', 2800), ('energysolar', 2240), ('staticmex', 1615), ('jumpcon', 1350)].

At five minutes: income 22.5/22.1, mexes 9/10, combat value 206/1200 (ours/opponent).

Own peak mexes: 10; peak combat value: 880. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## adamantine_mountain_2-factoryjump-s1

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('factoryjump', 5600), ('energysolar', 2660), ('staticmex', 2125), ('jumpcon', 1755)].

At five minutes: income 7.6/21.2, mexes 3/11, combat value 0/1625 (ours/opponent).

Own peak mexes: 7; peak combat value: 0. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## adamantine_mountain_2-factoryspider-s0

Opponent opening recorded by offline scorekeeper: factorycloak.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('spidercon', 6630), ('factoryspider', 2800), ('staticmex', 1275), ('energysolar', 1050)].

At five minutes: income 16.9/28.7, mexes 5/13, combat value 0/1094 (ours/opponent).

Own peak mexes: 7; peak combat value: 0. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## adamantine_mountain_2-factoryspider-s1

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('factoryspider', 2800), ('staticmex', 1530), ('energysolar', 1260), ('dyntrainer_strike_base', 1100), ('spidercon', 850)].

At five minutes: income 9.3/23.1, mexes 4/11, combat value 0/1490 (ours/opponent).

Own peak mexes: 6; peak combat value: 75. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## altair_crossing_v4-factorycloak-s0

Opponent opening recorded by offline scorekeeper: factoryamph.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('factorycloak', 4200), ('energysolar', 1190), ('dyntrainer_strike_base', 1100), ('cloakcon', 840), ('staticmex', 680)].

At five minutes: income 8.6/20.3, mexes 1/5, combat value 0/2657 (ours/opponent).

Own peak mexes: 3; peak combat value: 63. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## altair_crossing_v4-factorycloak-s1

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 1 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('energysolar', 1890), ('cloakraid', 1430), ('factorycloak', 1400), ('dyntrainer_strike_base', 1100), ('staticmex', 1020)].

At five minutes: income 12.9/27.8, mexes 3/9, combat value 54/1661 (ours/opponent).

Own peak mexes: 7; peak combat value: 565. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## altair_crossing_v4-factoryveh-s0

Opponent opening recorded by offline scorekeeper: factoryamph.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. 1 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('factoryveh', 3500), ('vehcon', 2520), ('energysolar', 700), ('staticmex', 680), ('vehscout', 400)].

At five minutes: income 7.0/23.6, mexes 1/7, combat value 0/2188 (ours/opponent).

Own peak mexes: 5; peak combat value: 20. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## altair_crossing_v4-factoryveh-s1

Opponent opening recorded by offline scorekeeper: factoryamph.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('factoryveh', 2800), ('dyntrainer_strike_base', 1100), ('energysolar', 1050), ('staticmex', 935), ('vehcon', 480)].

At five minutes: income 11.8/36.8, mexes 2/7, combat value 0/2560 (ours/opponent).

Own peak mexes: 5; peak combat value: 0. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## aquatic_divide_revised_v02-factoryamph-s0

Opponent opening recorded by offline scorekeeper: factoryveh.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('amphraid', 2000), ('energysolar', 1610), ('amphcon', 1500), ('dyntrainer_strike_base', 1100), ('amphbomb', 800)].

At five minutes: income 14.2/19.0, mexes 4/5, combat value 475/1240 (ours/opponent).

Own peak mexes: 5; peak combat value: 720. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## aquatic_divide_revised_v02-factoryamph-s1

Opponent opening recorded by offline scorekeeper: factoryamph.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('factoryamph', 2800), ('amphraid', 2240), ('dyntrainer_strike_base', 1100), ('staticmex', 765), ('amphcon', 750)].

At five minutes: income 12.4/25.4, mexes 3/6, combat value 0/2867 (ours/opponent).

Own peak mexes: 5; peak combat value: 5. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## aquatic_divide_revised_v02-factoryhover-s0

Opponent opening recorded by offline scorekeeper: factoryshield.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('hovercon', 3125), ('energysolar', 2730), ('hoverheavyraid', 1800), ('hoverdepthcharge', 1500), ('factoryhover', 1400)].

At five minutes: income 25.5/24.3, mexes 9/7, combat value 586/1675 (ours/opponent).

Own peak mexes: 10; peak combat value: 900. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## aquatic_divide_revised_v02-factoryhover-s1

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('energysolar', 1680), ('hoverraid', 1600), ('dyntrainer_strike_base', 1100), ('hoverheavyraid', 900), ('staticmex', 765)].

At five minutes: income 19.0/26.6, mexes 5/6, combat value 345/2502 (ours/opponent).

Own peak mexes: 6; peak combat value: 720. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factorytank-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('energysolar', 4200), ('tankheavyraid', 3000), ('staticmex', 2890), ('tankcon', 1850), ('dyntrainer_strike_base', 1100)].

At five minutes: income 41.2/31.1, mexes 16/12, combat value 1075/1210 (ours/opponent).

Own peak mexes: 20; peak combat value: 1860. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factorytank-s1

Opponent opening recorded by offline scorekeeper: factorycloak.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 1 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('energysolar', 2870), ('factorytank', 2100), ('staticmex', 1870), ('tankraid', 1700), ('tankcon', 1665)].

At five minutes: income 24.3/31.1, mexes 10/12, combat value 1410/1095 (ours/opponent).

Own peak mexes: 13; peak combat value: 2000. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factoryveh-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('energysolar', 4200), ('staticmex', 2805), ('vehraid', 1300), ('vehassault', 1250), ('vehcon', 1200)].

At five minutes: income 47.8/31.4, mexes 18/10, combat value 1435/2075 (ours/opponent).

Own peak mexes: 23; peak combat value: 2210. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factoryveh-s1

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('vehraid', 5070), ('energysolar', 3290), ('staticmex', 2210), ('factoryveh', 2100), ('vehcon', 1200)].

At five minutes: income 28.5/33.4, mexes 9/12, combat value 805/1750 (ours/opponent).

Own peak mexes: 11; peak combat value: 1850. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factorycloak-s0

Opponent opening recorded by offline scorekeeper: factorycloak.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 2 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('factorycloak', 4900), ('energysolar', 3430), ('staticmex', 2295), ('cloakcon', 1200), ('dyntrainer_strike_base', 1100)].

At five minutes: income 16.3/29.1, mexes 5/10, combat value 0/1151 (ours/opponent).

Own peak mexes: 11; peak combat value: 105. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factorycloak-s1

Opponent opening recorded by offline scorekeeper: factorycloak.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Defense/recovery occupied over 60% of samples; possible response saturation. 2 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('cloakraid', 2860), ('energysolar', 2590), ('cloakassault', 1750), ('cloakriot', 1680), ('staticmex', 1530)].

At five minutes: income 37.4/24.1, mexes 10/11, combat value 995/830 (ours/opponent).

Own peak mexes: 25; peak combat value: 3855. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factoryshield-s0

Opponent opening recorded by offline scorekeeper: factorycloak.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('factoryshield', 7000), ('energysolar', 3080), ('staticmex', 2295), ('shieldcon', 1800)].

At five minutes: income 10.2/18.6, mexes 2/7, combat value 0/1115 (ours/opponent).

Own peak mexes: 6; peak combat value: 0. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factoryshield-s1

Opponent opening recorded by offline scorekeeper: factorycloak.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('factoryshield', 5600), ('energysolar', 3850), ('shieldcon', 3120), ('staticmex', 2890), ('shieldassault', 875)].

At five minutes: income 22.0/27.8, mexes 8/8, combat value 0/1180 (ours/opponent).

Own peak mexes: 12; peak combat value: 680. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## porky_islands-factoryamph-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('factoryamph', 1400), ('dyntrainer_strike_base', 1100), ('staticmex', 765), ('energysolar', 630), ('amphcon', 600)].

At five minutes: income 16.0/25.9, mexes 3/8, combat value 0/2370 (ours/opponent).

Own peak mexes: 5; peak combat value: 9. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## porky_islands-factoryamph-s1

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 1 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('energysolar', 3570), ('staticmex', 2805), ('amphcon', 2700), ('amphraid', 1600), ('amphfloater', 1400)].

At five minutes: income 36.4/21.4, mexes 13/7, combat value 990/1915 (ours/opponent).

Own peak mexes: 30; peak combat value: 2520. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## porky_islands-factoryship-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('factoryship', 2800), ('shipcon', 2210), ('energywind', 840), ('shipscout', 440), ('staticmex', 255)].

At five minutes: income 8.2/29.6, mexes 1/9, combat value 0/2044 (ours/opponent).

Own peak mexes: 3; peak combat value: 51. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## porky_islands-factoryship-s1

Opponent opening recorded by offline scorekeeper: factoryship.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('shiptorpraider', 3100), ('factoryship', 2800), ('energywind', 2205), ('staticmex', 2125), ('shipcon', 1700)].

At five minutes: income 25.8/23.9, mexes 9/9, combat value 1246/1794 (ours/opponent).

Own peak mexes: 21; peak combat value: 1796. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factorycloak-s0

Opponent opening recorded by offline scorekeeper: factoryveh.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 1 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('energysolar', 3080), ('staticmex', 1870), ('cloakraid', 1625), ('factorycloak', 1400), ('cloakcon', 1200)].

At five minutes: income 30.8/29.4, mexes 10/9, combat value 745/1618 (ours/opponent).

Own peak mexes: 11; peak combat value: 1270. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factorycloak-s1

Opponent opening recorded by offline scorekeeper: factoryveh.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 1 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('energysolar', 2870), ('factorycloak', 2100), ('staticmex', 1955), ('cloakraid', 1950), ('cloakcon', 1200)].

At five minutes: income 24.9/26.7, mexes 11/9, combat value 1255/1536 (ours/opponent).

Own peak mexes: 11; peak combat value: 1340. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factoryveh-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('vehcon', 7920), ('factoryveh', 2100), ('energysolar', 1400), ('dyntrainer_strike_base', 1100), ('staticmex', 765)].

At five minutes: income 12.6/30.1, mexes 3/10, combat value 0/2248 (ours/opponent).

Own peak mexes: 6; peak combat value: 240. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factoryveh-s1

Opponent opening recorded by offline scorekeeper: factoryveh.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('factoryveh', 2100), ('vehcon', 1800), ('energysolar', 1400), ('dyntrainer_strike_base', 1100), ('staticmex', 935)].

At five minutes: income 16.0/36.2, mexes 4/12, combat value 0/1736 (ours/opponent).

Own peak mexes: 4; peak combat value: 205. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## sailaway2-factoryhover-s0

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('staticmex', 4675), ('factoryhover', 2800), ('energysolar', 2660), ('energywind', 2065), ('hoverheavyraid', 1800)].

At five minutes: income 48.3/24.8, mexes 22/9, combat value 1555/1550 (ours/opponent).

Own peak mexes: 42; peak combat value: 2030. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## sailaway2-factoryhover-s1

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('staticmex', 4845), ('hovercon', 3875), ('energysolar', 3780), ('energywind', 2555), ('factoryhover', 2100)].

At five minutes: income 45.5/21.3, mexes 19/6, combat value 1435/1640 (ours/opponent).

Own peak mexes: 36; peak combat value: 1880. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## sailaway2-factoryship-s0

Opponent opening recorded by offline scorekeeper: factoryship.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('shiptorpraider', 5800), ('factoryship', 3500), ('staticmex', 2295), ('energywind', 1890), ('shipriot', 1100)].

At five minutes: income 36.1/24.2, mexes 14/7, combat value 1116/1797 (ours/opponent).

Own peak mexes: 20; peak combat value: 1116. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## sailaway2-factoryship-s1

Opponent opening recorded by offline scorekeeper: factoryship.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 1 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('shiptorpraider', 2400), ('shipriot', 2200), ('factoryship', 2100), ('staticmex', 1445), ('energywind', 1225)].

At five minutes: income 20.2/25.5, mexes 7/10, combat value 1231/1411 (ours/opponent).

Own peak mexes: 11; peak combat value: 2266. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
