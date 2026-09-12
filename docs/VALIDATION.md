# Validation  -  2026-09-12

## Passed automated Lua checks

Run `python tests/run.py` with Python and `lupa` installed. Every production module parses under Lua 5.1. Seven regression suites cover:

- Native Mex 0/1/2/4 and ordinary/persistent repair/reclaim modifiers, including Shift/Space and Ctrl preservation.
- All ten formation layouts, finite in-map slots, Double Line ranks, role classification and rear artillery placement.
- Officer-only dispatch, per-unit Fight commands, Shift queue options and ownership revocation.
- Assignment/objectives/proposals/expiry/decline causing zero orders; exactly-once approval; stale ownership, movement and health rejection.
- Manual override, explicit suspension/resume, cancellation, new objective reset, invalid authority and public/autohost lockout.
- A strict shared ceiling of 60 corrections in a rolling game second.
- Anonymous radar contacts despite retained engine identity flags; spectator observation clearing; production advice with no order calls.

## Passed installed-engine integration

Ran an isolated local match on **Absolution 2**, Zero-K v1.14.8.0, engine 2025.06.21, with a NullAI opponent and a dedicated `CommandLayerTest` player. Local test fixtures contained 12 Glaives, four Slings and two Conjurers. The temporary driver was guarded to run only under that exact test-player name and never installed by the package installer.

The final run verified 21 checks, saved verbatim in [ENGINE_TEST_RESULTS.txt](ENGINE_TEST_RESULTS.txt):

- Chili/widget services loaded; actual Fight commands reached all 16 combat units, leaving constructors untouched.
- A successive line changed destinations.
- Assignment and objective/proposal creation left queues empty.
- Approval issued the displayed operation once; duplicate approval was rejected.
- Manual UnitCommandNotify immediately released that unit from Officer membership.
- Mex +2 reached the installed Mex handler with Alt and queued one mex plus two generators per constructor. The two constructors' queues contained two mex entries and four generator entries in total; these were duplicate cooperative builder queues, not a claim of building two extractors on one spot.
- A projected world Fight drag was captured by Command Layer before CustomFormations2 and dispatched native destinations.
- All four repair/reclaim presets reached native handlers with the correct persistent modifier, retaining native filtering behavior.

Live testing found and fixed two handler-ordering errors: input iteration runs lower layers first, and tree/unit reclaim handlers run before CommandInsert. Final widget priority is -1339. Deprecated builder-field reads were also removed. Final logs contained no Command Layer Lua errors; unrelated stock translation warnings remained.

An in-game screenshot confirmed the formation window and controls rendered. The automated world gesture exercises the game's widget/mouse dispatch path; it is not a claim that every button and every layout was manually clicked and visually reviewed.

## Packaging checks

Installed only the unique main widget and its module directory. An isolated install/uninstall test preserved an unrelated widget, excluded the test driver and retained a deliberately modified suite file. The actual-game uninstall dry run targeted only suite files. Temporary test artifacts were removed after integration. Original game archives and stock LuaRules/widgets were not edited. Work is committed locally.

## Remaining gameplay acceptance checks

These have **not** been established by the automated tests:

- Extended mixed-army combat across hills, chokepoints, water transitions and crowded build sites.
- Visual arrival quality of every geometric shape and sharp curved ranks.
- Long-duration Loose/Strict behavior against active opponents, including path congestion, retreat and transport transitions.
- Complete visual review of Officer/production dialogs at every global UI scale and hotkey combination.
- Public/ranked permission for new assisted functionality; it remains restricted to explicitly identified local/private tests.

Use a local skirmish to judge formation quality before relying on it in a serious match. Strict mode intentionally can interfere with native kiting; Loose avoids corrections near observed combat, but preserving native AI callouts is not proof of identical combat performance.


## Officer feedback revision — 2026-09-12

Added all-military assignment, per-force front directives, bounded left/right approach proposals, persistent stale briefs and configurable 60-second approval / 10-second suggestion defaults. Eight Lua 5.1 test suites pass, including new mixed ground/air ownership, builder/structure/allied exclusion, persistent expiry, explicit refresh, flank direction, single approval, intermediate-versus-final completion and manual override cases.

These changes have not yet been verified in a live match. Earlier Beginner skirmish verified Mex + 2 Energy construction, but computer control was stopped before formation/Officer playtesting. No live-match success is claimed for this revision. Original game files remain untouched; restart the match or reload LuaUI to load the installed update (runtime assignments reset).


## Sustained pressure revision — 2026-09-12

Twelve Lua 5.1 suites pass. New coverage includes zero authority before delegation, three disjoint detachments, bounded slots, repeated main advances, command retention between ticks, manual ownership revocation, stopping and multiplayer/spectator denial, compatible role allocation, anonymous radar exclusion from raid targeting, observed riot protection and automatic fresh advice without approval reuse.

A separate **spring-headless 2025.06.21** process ran the actual Zero-K archive and LuaUI on Absolution 2 with NullAI and twelve controlled test Glaives. All eleven checks passed: fixtures, session gating, assignment, delegation, three detachment operations, native orders on 12/12 units, physical movement on 12/12, recurring scouting/harassment patrol/main advances, manual override, stop and no restart on the next tick. The process exited normally. See DELEGATION_ENGINE_RESULTS.txt. The user's existing spring.exe process was not controlled or restarted.

This was an isolated command/movement test with explicit test-only spawning, not a completed Beginner match or a combat win. Target-choice heuristics pass mocked observation tests but effectiveness against active enemy forces, navigation over difficult terrain and final UI layout remain unverified. Stock translation warnings and the engine's existing GetCommandQueue deprecation notice are not claimed as fixed. New modules contain no direct combat order APIs; Officer and Orders retain dispatch control.

Research helper fetched official museum/wiki metadata and produced a non-executable combined-arms candidate. No model or webpage receives direct game authority. Autonomous tests require single-player; public/ranked use stays disabled.
