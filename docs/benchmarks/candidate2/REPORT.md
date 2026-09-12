# Benchmark results

Completed cases: 32. Outcomes: {'LOSS': 20, 'CENSORED': 12}.

Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.

[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.

| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |
|---|---|---:|---:|
| Adamantine Mountain 2 / factoryjump / 0 | LOSS | 7775 / 17705 | 0/33 |
| Adamantine Mountain 2 / factoryjump / 1 | LOSS | 3835 / 14190 | 0/36 |
| Adamantine Mountain 2 / factoryspider / 0 | LOSS | 1985 / 6965 | 0/19 |
| Adamantine Mountain 2 / factoryspider / 1 | LOSS | 2930 / 11455 | 0/25 |
| Altair_Crossing_V4 / factorycloak / 0 | LOSS | 3170 / 11545 | 0/28 |
| Altair_Crossing_V4 / factorycloak / 1 | LOSS | 4465 / 10045 | 0/23 |
| Altair_Crossing_V4 / factoryveh / 0 | LOSS | 1450 / 9610 | 0/23 |
| Altair_Crossing_V4 / factoryveh / 1 | CENSORED | 785 / 10810 | 0/26 |
| Aquatic Divide Revised v02 / factoryamph / 0 | LOSS | 1240 / 7905 | 0/15 |
| Aquatic Divide Revised v02 / factoryamph / 1 | LOSS | 2730 / 9175 | 0/20 |
| Aquatic Divide Revised v02 / factoryhover / 0 | LOSS | 1180 / 8985 | 1/12 |
| Aquatic Divide Revised v02 / factoryhover / 1 | LOSS | 4390 / 14410 | 0/14 |
| Comet Catcher Redux v3.1 / factorytank / 0 | LOSS | 6755 / 61490 | 0/72 |
| Comet Catcher Redux v3.1 / factorytank / 1 | LOSS | 4580 / 17700 | 0/72 |
| Comet Catcher Redux v3.1 / factoryveh / 0 | LOSS | 7000 / 27735 | 0/74 |
| Comet Catcher Redux v3.1 / factoryveh / 1 | LOSS | 6360 / 25730 | 0/71 |
| FolsomDamDeluxeV4 / factorycloak / 0 | CENSORED | 9350 / 22000 | 9/35 |
| FolsomDamDeluxeV4 / factorycloak / 1 | CENSORED | 7695 / 15230 | 24/15 |
| FolsomDamDeluxeV4 / factoryshield / 0 | CENSORED | 3695 / 27015 | 11/40 |
| FolsomDamDeluxeV4 / factoryshield / 1 | CENSORED | 8050 / 24265 | 0/48 |
| Porky_Islands / factoryamph / 0 | CENSORED | 7130 / 22790 | 24/20 |
| Porky_Islands / factoryamph / 1 | CENSORED | 15550 / 36230 | 15/39 |
| Porky_Islands / factoryship / 0 | CENSORED | 14030 / 24640 | 0/51 |
| Porky_Islands / factoryship / 1 | CENSORED | 10660 / 32025 | 0/45 |
| Red Comet Remake 1.7 / factorycloak / 0 | LOSS | 1545 / 10510 | 0/30 |
| Red Comet Remake 1.7 / factorycloak / 1 | LOSS | 2145 / 12635 | 0/31 |
| Red Comet Remake 1.7 / factoryveh / 0 | LOSS | 185 / 12180 | 0/33 |
| Red Comet Remake 1.7 / factoryveh / 1 | LOSS | 2600 / 20885 | 0/33 |
| SailAway 2 / factoryhover / 0 | CENSORED | 4185 / 27780 | 1/65 |
| SailAway 2 / factoryhover / 1 | CENSORED | 4915 / 29170 | 2/69 |
| SailAway 2 / factoryship / 0 | CENSORED | 9075 / 23500 | 1/69 |
| SailAway 2 / factoryship / 1 | LOSS | 10725 / 20195 | 0/63 |

## adamantine_mountain_2-factoryjump-s0

Opponent opening recorded by offline scorekeeper: factorycloak.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('jumpraid', 8360), ('factoryjump', 2100), ('staticmex', 2040), ('energysolar', 1680), ('jumpassault', 1200)].

At five minutes: income 17.6/21.2, mexes 6/9, combat value 1642/584 (ours/opponent).

Own peak mexes: 9; peak combat value: 2642. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## adamantine_mountain_2-factoryjump-s1

Opponent opening recorded by offline scorekeeper: factorycloak.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 14 samples waited for army health recovery; inspect whether repair/reinforcement was available.

Largest own losses by unit value: [('jumpraid', 7260), ('staticmex', 1615), ('dyntrainer_strike_base', 1100), ('jumparty', 900), ('energysolar', 770)].

At five minutes: income 16.3/19.4, mexes 8/9, combat value 1874/1070 (ours/opponent).

Own peak mexes: 12; peak combat value: 2018. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## adamantine_mountain_2-factoryspider-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('factoryspider', 1400), ('staticmex', 1190), ('dyntrainer_strike_base', 1100), ('energysolar', 980), ('spideremp', 760)].

At five minutes: income 19.2/16.5, mexes 12/6, combat value 1145/1333 (ours/opponent).

Own peak mexes: 13; peak combat value: 1170. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## adamantine_mountain_2-factoryspider-s1

Opponent opening recorded by offline scorekeeper: factoryspider.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('factoryspider', 2100), ('spideremp', 1710), ('staticmex', 1700), ('energysolar', 1260), ('spiderassault', 1160)].

At five minutes: income 17.0/19.1, mexes 8/10, combat value 1226/1512 (ours/opponent).

Own peak mexes: 11; peak combat value: 1401. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## altair_crossing_v4-factorycloak-s0

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('factorycloak', 3500), ('cloakraid', 2470), ('staticmex', 1275), ('energysolar', 1260), ('dyntrainer_strike_base', 1100)].

At five minutes: income 13.8/25.4, mexes 3/6, combat value 615/1350 (ours/opponent).

Own peak mexes: 7; peak combat value: 860. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## altair_crossing_v4-factorycloak-s1

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('cloakraid', 2405), ('factorycloak', 2100), ('dyntrainer_strike_base', 1100), ('energysolar', 1050), ('staticmex', 850)].

At five minutes: income 22.2/35.6, mexes 5/7, combat value 1412/1850 (ours/opponent).

Own peak mexes: 6; peak combat value: 1796. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## altair_crossing_v4-factoryveh-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('vehraid', 3510), ('factoryveh', 2100), ('energysolar', 1330), ('staticmex', 1020), ('vehcon', 480)].

At five minutes: income 23.3/22.1, mexes 8/7, combat value 650/1656 (ours/opponent).

Own peak mexes: 10; peak combat value: 1427. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## altair_crossing_v4-factoryveh-s1

Opponent opening recorded by offline scorekeeper: factoryhover.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('vehraid', 3120), ('factoryveh', 2800), ('energysolar', 1190), ('dyntrainer_strike_base', 1100), ('staticmex', 850)].

At five minutes: income 20.2/19.1, mexes 7/7, combat value 933/2340 (ours/opponent).

Own peak mexes: 9; peak combat value: 1190. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## aquatic_divide_revised_v02-factoryamph-s0

Opponent opening recorded by offline scorekeeper: factoryamph.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('factoryamph', 2100), ('amphraid', 1680), ('dyntrainer_strike_base', 1100), ('energysolar', 980), ('staticmex', 595)].

At five minutes: income 18.4/23.5, mexes 6/5, combat value 373/2058 (ours/opponent).

Own peak mexes: 6; peak combat value: 1204. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## aquatic_divide_revised_v02-factoryamph-s1

Opponent opening recorded by offline scorekeeper: factoryamph.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('amphraid', 1920), ('amphassault', 1900), ('factoryamph', 1400), ('dyntrainer_strike_base', 1100), ('energysolar', 840)].

At five minutes: income 18.2/28.9, mexes 5/5, combat value 1608/2020 (ours/opponent).

Own peak mexes: 7; peak combat value: 2530. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## aquatic_divide_revised_v02-factoryhover-s0

Opponent opening recorded by offline scorekeeper: factoryamph.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('hoverheavyraid', 4140), ('factoryhover', 1400), ('energysolar', 1120), ('dyntrainer_strike_base', 1100), ('staticmex', 765)].

At five minutes: income 18.7/24.5, mexes 7/6, combat value 366/1720 (ours/opponent).

Own peak mexes: 8; peak combat value: 970. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## aquatic_divide_revised_v02-factoryhover-s1

Opponent opening recorded by offline scorekeeper: factoryamph.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('hoverheavyraid', 4320), ('energysolar', 1400), ('factoryhover', 1400), ('hoverdepthcharge', 1200), ('hoverarty', 1100)].

At five minutes: income 18.6/26.3, mexes 6/5, combat value 1772/979 (ours/opponent).

Own peak mexes: 7; peak combat value: 3574. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factorytank-s0

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('tankheavyassault', 35200), ('tankheavyraid', 9900), ('energysolar', 3500), ('staticmex', 3145), ('factorytank', 2800)].

At five minutes: income 23.8/37.4, mexes 7/11, combat value 1869/1262 (ours/opponent).

Own peak mexes: 16; peak combat value: 5650. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factorytank-s1

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('tankheavyraid', 4200), ('staticmex', 2720), ('energysolar', 2660), ('tankheavyassault', 2200), ('factorytank', 2100)].

At five minutes: income 18.2/31.7, mexes 5/10, combat value 2002/1320 (ours/opponent).

Own peak mexes: 13; peak combat value: 3720. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factoryveh-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('vehraid', 7670), ('energysolar', 3220), ('vehaa', 2860), ('staticmex', 2805), ('vehriot', 2640)].

At five minutes: income 20.2/27.2, mexes 7/10, combat value 2100/1630 (ours/opponent).

Own peak mexes: 18; peak combat value: 3899. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## comet_catcher_redux_v3_1-factoryveh-s1

Opponent opening recorded by offline scorekeeper: factoryveh.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('vehraid', 7280), ('vehassault', 4500), ('vehriot', 2640), ('staticmex', 2125), ('factoryveh', 2100)].

At five minutes: income 34.2/28.7, mexes 12/9, combat value 1646/1140 (ours/opponent).

Own peak mexes: 15; peak combat value: 4603. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factorycloak-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 2 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('cloakraid', 8710), ('cloakskirm', 2340), ('energysolar', 2240), ('staticmex', 2125), ('cloakassault', 2100)].

At five minutes: income 29.9/18.6, mexes 10/7, combat value 1480/1730 (ours/opponent).

Own peak mexes: 21; peak combat value: 7529. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factorycloak-s1

Opponent opening recorded by offline scorekeeper: factorycloak.

No native winner before the game-time cap. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('cloakraid', 7800), ('cloakriot', 1470), ('factorycloak', 1400), ('staticmex', 1190), ('cloakassault', 1050)].

At five minutes: income 22.6/19.1, mexes 8/3, combat value 1518/635 (ours/opponent).

Own peak mexes: 26; peak combat value: 4695. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factoryshield-s0

Opponent opening recorded by offline scorekeeper: factoryamph.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('shieldriot', 7500), ('shieldraid', 6600), ('shieldassault', 2800), ('shieldskirm', 2500), ('factoryshield', 2100)].

At five minutes: income 21.3/23.7, mexes 10/9, combat value 1879/1731 (ours/opponent).

Own peak mexes: 18; peak combat value: 5727. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## folsomdamdeluxev4-factoryshield-s1

Opponent opening recorded by offline scorekeeper: factoryhover.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation. 4 samples waited for army health recovery; inspect whether repair/reinforcement was available.

Largest own losses by unit value: [('shieldraid', 6750), ('shieldriot', 3750), ('staticmex', 2635), ('shieldassault', 2450), ('factoryshield', 2100)].

At five minutes: income 27.6/20.8, mexes 12/8, combat value 1728/1706 (ours/opponent).

Own peak mexes: 18; peak combat value: 4683. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## porky_islands-factoryamph-s0

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('amphraid', 9840), ('factoryamph', 5600), ('amphriot', 2340), ('energywind', 1400), ('amphcon', 900)].

At five minutes: income 34.1/12.6, mexes 11/3, combat value 1681/834 (ours/opponent).

Own peak mexes: 27; peak combat value: 5828. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## porky_islands-factoryamph-s1

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('amphraid', 13680), ('amphfloater', 5600), ('amphassault', 3800), ('amphriot', 3380), ('staticmex', 2125)].

At five minutes: income 36.7/26.1, mexes 14/9, combat value 1864/1888 (ours/opponent).

Own peak mexes: 27; peak combat value: 9524. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## porky_islands-factoryship-s0

Opponent opening recorded by offline scorekeeper: factoryamph.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('shiptorpraider', 9100), ('shipskirm', 5500), ('staticmex', 2040), ('shipriot', 1980), ('factoryship', 1400)].

At five minutes: income 19.6/25.9, mexes 5/7, combat value 2115/1520 (ours/opponent).

Own peak mexes: 8; peak combat value: 5526. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## porky_islands-factoryship-s1

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('shiptorpraider', 10000), ('factoryship', 4900), ('shipskirm', 3740), ('shipriot', 2860), ('staticmex', 2635)].

At five minutes: income 33.5/26.7, mexes 12/8, combat value 2051/1335 (ours/opponent).

Own peak mexes: 21; peak combat value: 7730. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factorycloak-s0

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('factorycloak', 2100), ('cloakraid', 2080), ('energysolar', 1820), ('staticmex', 1360), ('dyntrainer_strike_base', 1100)].

At five minutes: income 25.2/23.6, mexes 8/9, combat value 1106/1730 (ours/opponent).

Own peak mexes: 10; peak combat value: 1530. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factorycloak-s1

Opponent opening recorded by offline scorekeeper: factoryhover.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('cloakraid', 3705), ('energysolar', 1750), ('staticmex', 1530), ('factorycloak', 1400), ('dyntrainer_strike_base', 1100)].

At five minutes: income 24.4/30.1, mexes 9/8, combat value 1527/1971 (ours/opponent).

Own peak mexes: 11; peak combat value: 1800. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factoryveh-s0

Opponent opening recorded by offline scorekeeper: factorytank.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure.

Largest own losses by unit value: [('vehraid', 4030), ('staticmex', 1870), ('energysolar', 1750), ('factoryveh', 1400), ('dyntrainer_strike_base', 1100)].

At five minutes: income 38.3/23.0, mexes 13/7, combat value 1250/2258 (ours/opponent).

Own peak mexes: 15; peak combat value: 1250. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## red_comet_remake_1_7-factoryveh-s1

Opponent opening recorded by offline scorekeeper: factoryshield.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('vehraid', 6500), ('vehriot', 4560), ('factoryveh', 2100), ('energysolar', 1680), ('vehassault', 1250)].

At five minutes: income 22.1/31.3, mexes 8/11, combat value 1588/1557 (ours/opponent).

Own peak mexes: 10; peak combat value: 2046. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## sailaway2-factoryhover-s0

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('hoverheavyraid', 5400), ('factoryhover', 4200), ('hoverdepthcharge', 3300), ('staticmex', 2890), ('hoverassault', 2520)].

At five minutes: income 26.1/20.8, mexes 8/6, combat value 1763/1329 (ours/opponent).

Own peak mexes: 19; peak combat value: 3828. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## sailaway2-factoryhover-s1

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('hoverheavyraid', 9900), ('factoryhover', 4200), ('staticmex', 2890), ('hoverskirm', 2200), ('hoverassault', 2100)].

At five minutes: income 20.2/24.1, mexes 7/8, combat value 1655/1552 (ours/opponent).

Own peak mexes: 18; peak combat value: 5734. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## sailaway2-factoryship-s0

Opponent opening recorded by offline scorekeeper: factoryship.

No native winner before the game-time cap. Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Lost more than twice attributed killed value; inspect engagements and builder exposure. Defense/recovery occupied over 60% of samples; possible response saturation.

Largest own losses by unit value: [('shipskirm', 7040), ('shiptorpraider', 5800), ('factoryship', 2100), ('staticmex', 1785), ('shipriot', 1760)].

At five minutes: income 23.7/27.0, mexes 8/9, combat value 1858/1394 (ours/opponent).

Own peak mexes: 10; peak combat value: 5852. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.

## sailaway2-factoryship-s1

Opponent opening recorded by offline scorekeeper: factoryship.

Final income below 60% of opponent; expansion survival/capture deficit. Final combat value below half of opponent. Defense/recovery occupied over 60% of samples; possible response saturation. 1 worker stall releases recorded; autonomous capacity was lost pending manual re-enrollment.

Largest own losses by unit value: [('shiptorpraider', 5500), ('shipriot', 2860), ('factoryship', 2100), ('staticmex', 1955), ('shipskirm', 1760)].

At five minutes: income 19.2/23.0, mexes 7/7, combat value 2180/1565 (ours/opponent).

Own peak mexes: 10; peak combat value: 5905. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL.
