# Equal-army combat test  -  2026-09-12

## Environment

A new visible Spring 2025.06.21 session ran Zero-K v1.14.8.0 through a separate local test mutator on Absolution 2. The user's existing game process was not restarted. Test-only LuaRules and driver files live in the isolated directory, never in the normal widget installation or stock archive.

Each combat roster contained 18 Glaives, four riots, four skirmishers, four artillery units and two AA units: **32 units and 3,010 metal per side**. Starting commanders remained outside the combat fixture. Player units used ASSAULT and delegated pressure; the opponent received native Fight destinations toward the opposing line. NullAI supplies the team slot; the opposing army is a scripted native-Fight benchmark, **not Circuit Beginner or a complete strategic AI**. Neither side built reinforcements.

A first setup attempt incorrectly destroyed starting commanders and triggered defeat logic. It was discarded. A subsequent baseline exposed incorrect resource storage setup: both sides had equal grants but no usable storage. That baseline is retained for diagnostics, not an improvement comparison.

The corrected fixture gives each side 20,000 engine storage (10,000 visible after Zero-K's hidden-storage allowance) and an equal raw grant of 15,000 metal/energy. Overflow settles at the visible cap. Logs recorded identical banks and storage for both teams; the live UI showed full 10,000 resource banks. The earlier claim of 5,000 usable resources was incorrect for these test runs.

## Corrected 120-second result

| Metric | Officer | Scripted opponent |
|---|---:|---:|
| Starting units | 32 | 32 |
| Starting combat value | 3,010 | 3,010 |
| Surviving units | 9 | 9 |
| Surviving combat value | 910 | 910 |
| Combat value lost | 2,100 | 2,100 |

Both armies advanced and exchanged fire. Scouting, harassment and withdrawal decisions occurred. Native combat continued without constant replacement of main-force orders. The Officer did **not** complete its objective during the test; this ended as a combat stalemate, not a victory. One run on one terrain layout does not establish strength or improvement. A reverse-side trial and tests against Circuit AI remain useful future checks.

The visible test session was left open after its automated 120-second stop. Native destination orders may continue afterward; report results use only the frame-3600 snapshot.

## Fixes

1. Raider withdrawal was issued as Fight, allowing continued target acquisition during withdrawal. WITHDRAW now uses native RAW_MOVE, including raiders. A regression verifies no Fight dispatch for that withdrawal.
2. The live UI reported HARASS after light detachments had no available survivors while MAIN was exchanging fire. Empty groups now report UNAVAILABLE; active main operations report ADVANCING or ENGAGING from player-visible nearby contacts. The aggregate status follows the active main operation. ENGAGING is a contact-based state, not proof every unit fired that frame.
3. Test resources now account for the hidden-storage allowance, and the test fixture retains starting commanders to avoid accidental defeat.

Thirteen Lua 5.1 suites pass. The final 30-second headless engine regression completed successfully and reported ENGAGING during real combat with no blocked units at its 26-second sample. Withdrawal dispatch is also covered by the Lua regression. World UI controls and the AI DETAILS window were inspected in the visible combat session. Original archives and stock widgets remain unchanged.

Logs are in [combat-tests](combat-tests/corrected-resources-metrics.txt). Fixture damage counters are test-only aggregate telemetry and may include overkill; they are never fed to Officer observations. No hidden enemy identity or fixture omniscience is provided to the controller.

## Repeat in another new session

```powershell
python tools/run_combat_test.py --game "C:\path\to\Zero-K" --directory "C:\path\outside-the-game\combat-test"
```

The launcher creates a separate data directory and test mutator, selects a free local port and starts a new visible game process. Use `--headless --seconds 30` for a short engine check that exits automatically. Default visible duration is 120 seconds; it remains open afterward. This launcher does not stop existing matches. Do not reuse a directory while its test session is running.
