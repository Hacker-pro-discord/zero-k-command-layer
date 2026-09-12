# Map-wide autonomous control — preview 8

Tested 2026-09-12 against installed Zero-K v1.14.8.0 / engine 2025.06.21.

## Change in authority and behavior

Map-control mode no longer uses a player objective corridor as its operating boundary. Its Officer grant covers the map rectangle. MapControl selects objectives; TacticalController creates local formation plans for those objectives; Officer/Orders still validate ownership and dispatch. Player-drawn lines and explicit front controls switch that force back to bounded operation. Changing from a live corridor operation to map control revokes and replaces the old grant.

With the widget enabled, automatic startup is ON by default for local single-player games. It runs the existing live-player, replay/spectator and autohost checks before creating fresh session authority. It enables recruitment and idle-factory production, including when there are no combat units yet. No extra startup or approval clicks are needed. Stop cancels for the current session; the Settings > Interface > Command Layer automatic-start preference disables future automatic startup. The preference persists, not active grants or assignments.

MapControl uses 25 map sectors, observed/visited times, recent attempts and reservations between groups. Scouts and raiders search independently; MAIN also advances to unexplored sectors. MAIN attacks currently visual contacts; RAID prefers vulnerable visual contacts within its coarse risk budget. Radar-only contacts never supply identity. Coordinates come from map geometry or the existing perspective-filtered observation service. No hidden enemy start positions or omniscient target list are used.

Searches continue after arrival. When out of observed combat, 70% arrival or a 60-second operation timeout permits another objective. A visible enemy can interrupt a MAIN search after a minimum 12-second operation interval. Native combat and recovery remain in charge during engagement. A native empty command queue gets a 30-second retry instead of permanent exclusion; manual release and changed nonempty queues remain protected. Healthy map-control forces that exhaust bounded recovery retries can select another sector instead of requiring a new drawn line.

## Failures found and fixed

1. Pregame PlayerChanged calls disabled assistance and accidentally consumed the new automatic-start opportunity. Stop now only consumes startup after the game is live; the pregame case has a regression.
2. Native empty queues could permanently mark retained force members unavailable. These now use a cooldown in map-control mode. This does not reacquire manually released units.
3. Entering map control from an active corridor could leave its old narrow grant in place. Entry now revokes it first. Startup no longer generates a placeholder opposite-quarter line.

## Regression tests

All **25 Lua 5.1 suites and syntax checks** pass. New checks include automatic boot without selection/line/approval, full-map authorization, searches covering both axes and at least 20 distinct sectors, visible targets outside the old approach, radar identity exclusion, arrival/timeout continuation, empty-queue retry versus changed-queue protection, Stop, multiplayer denial, pregame startup and switching between corridor and map grants. Earlier logistics, formations, production, ownership, recovery and 1,000-unit lifecycle tests remain enabled.

## Engine evidence

- Initial automatic-start run reproduced the pregame cancellation and did not start a force. It is a failed diagnostic run, not a passing test.
- Corrected 32-vs-32 run started automatically and issued scout/raid/main orders at game second 2. It searched successive sectors and selected a visible attack at second 98.
- The 180-second run including empty-queue retries started automatically, selected a visual attack at second 14, and crossed the map: by second 86 the recorded assigned-unit X bounds were 4,595–7,251 (initial bounds at second 6 were 1,696–3,213). At second 150 scout, raid and main selected new search sectors; MAIN selected another visual attack at second 162. At 180 seconds there were 21 original friendly units / 2,150 value versus nine enemy units / 900 value. Starting rosters were identical, 32 units / 3,010 value per side. This is a scripted native-Fight benchmark, not a Circuit-AI match win.
- The 1,000-vs-1,000 map-control run issued a visible attack automatically and moved 958 original units at least 32 units between seconds 6 and 16. The game invoked Autoquit around second 22 and exited around second 31, before the requested 90-second benchmark. No completed-duration or victory claim is made for this run.
- A final zero-army/four-factory startup smoke run checks the removal of the placeholder line and the final code wiring. Its selected log accompanies this report.

The long runs precede the final cleanup of the unused startup line and active-corridor entry fix; those changes have regression coverage and the final boot smoke test. UI status now says MAP-WIDE CONTROL while active; this small text change has not had a separate visual interaction test.

## Limits

The grid and targeting rules are heuristics, not a full strategic planner. They do not guarantee coverage, favorable engagements, terrain reachability, coordinated encirclement or victory. Heavy formations can still congest; native path failures may recur. The AI manages assigned military units and factory queues, not economy construction. Public/ranked autonomous use remains disabled by the existing gate.

```powershell
python tests/run.py
python tools/run_combat_test.py --game "C:\path\to\Zero-K" --directory "C:\test\map" --map-control --headless --seconds 180
python tools/run_combat_test.py --game "C:\path\to\Zero-K" --directory "C:\test\boot" --map-control --startup --headless --seconds 60
```

Only isolated test directories receive the test LuaRules/driver. Original game archives and stock widgets are unchanged.

The final automatic zero-army run completed 60 game seconds, with 18 recruited units by second 58 and recurring map search operations. No Command Layer traceback was observed. Logs: [180-second map run](map-control-engine.txt), [early-ended 1,000-unit run](map-control-1000-engine.txt), [final automatic boot](map-control-boot-engine.txt).
