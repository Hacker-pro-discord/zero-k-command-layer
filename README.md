# Zero-K Command Layer

Experimental local widgets for **Zero-K v1.14.8.0 / engine 2025.06.21**: logistics shortcuts, persistent formations, an approval-based Officer, and optional military, production and economic automation in local games or explicitly enabled multiplayer.

Choose an army/objective yourself, or explicitly start automatic map control in a local skirmish. Native Zero-K unit AI still handles firing, aiming and ordinary combat behavior. Normal installation adds uniquely named local widgets; it does not edit stock widgets, game archives or LuaRules. This is a community experiment, not an official Zero-K component or a competitive-play recommendation.

## Install

Manual installation needs no Python.

1. Download a ZIP from [Releases](https://github.com/Hacker-pro-discord/zero-k-command-layer/releases), or **Code > Download ZIP**, and extract it.
2. Find the Zero-K **data directory**, containing `games` and `LuaUI`. Steam installations commonly use `steamapps/common/Zero-K`; use your actual location, not the engine-version directory.
3. Copy the package's `LuaUI/Widgets/gui_command_layer.lua` and entire `LuaUI/Widgets/Include/CommandLayer/` directory into the matching paths. Create missing folders. The result should be:

   ```text
   Zero-K/
     LuaUI/
       Widgets/
         gui_command_layer.lua
         Include/
           CommandLayer/
             Officer.lua
             UI.lua
             ...all other included modules...
   ```

   Do not leave an extra project-name folder between `Widgets` and these files. Do not install files from `tests` as ordinary widgets.
4. Start a **local skirmish**. Open **F10 > Settings**, disable **Simple Settings**, then under **Misc** enable **Show Advanced Settings**. Open **Local Widget Config**, enable local widgets, close the dialog and enter `/luaui reload` in the game command/chat input.
5. Open **Alt+F11**, or **Settings > Misc > Widget List**, and enable **Zero-K Command Layer** under **User local**. Keep Chili Framework, Mex Placement, CommandInsert and CustomFormations2 enabled.

See the [official widget configuration guide](https://zero-k.info/mediawiki/Widget_Configuration). Match restrictions can prohibit local widgets; the suite honors them.

Alternatively, with Python 3.9+ in the extracted package:

```powershell
python tools/install.py --game "C:\path\to\Zero-K"
```

The installer copies only production widget files and expects `games/zk-stable.sdz`. Manual installation is available for other layouts, but compatibility is unverified. Windows is the tested platform.

## Faster opening, scouting and field attacks

The Officer now chooses an **AUTO starting factory from public terrain**: mobility for open land, rough terrain or water, filtered through the builder's actual options and native placement. A manually selected opening or existing factory is preserved.

Factories check idle queues every second, keep smaller funding buffers, and prioritize an affordable fast scout/raider. Before identified enemy combat/defense intel, they build an initial raider/riot/skirmisher/assault mix. A mex sighting alone does not end that opening. Once combat intel exists, the existing unit counter matrix resumes its role. Construction and production still require resources; this does not grant extra income.

Expansion gets five of six discretionary job turns before optional upgrades, earlier additional builders, and fewer early static-defense diversions. Urgent energy still wins. At **25 and 50 healthy ground troops**, the map-control Officer combines main troops and raiders into a field attack; reserve/scout duties remain separate. Smaller groups continue their existing actions rather than waiting for 25. Terrain, manual override, native retreat and observed threats still apply.

See [opening rules and native tests](docs/AGGRESSIVE_OPENING.md).

## Multiplayer, including ranked

The project owner reported permission for the full suite, including ranked, on September 13, 2026. The single-player-only lock has been replaced with a per-match opt-in. No public approval link has been supplied; this records the reported scope rather than claiming official endorsement.

In the **OFFICER** tab, click **ENABLE MULTIPLAYER AI**. This starts map-wide army control, recruitment and production, plus economy/recovery according to their settings. Existing arsenal and explicit strategic-construction controls retain their separate controls. Use **MULTIPLAYER AI: ON / DISABLE** to revoke the session, or **STOP AI** to stop current automation.

Multiplayer authority is not saved: enable it again after joining another match or reloading LuaUI. Local single-player automatic startup remains unchanged. Native server restrictions on local widgets are still honored. See [multiplayer behavior and validation](docs/MULTIPLAYER.md).

## Basic target priorities

The delegated Officer now prioritizes **visible repair/support units, threatening turrets and exposed mexes**, with distance and observed defenses considered. It can give nearby units native priority targets without replacing their movement queues. Confirmed visible repair work and recent damage to our units strengthen priority. Radar contacts stay unidentified; manual targets and manual orders win. **AI DETAILS** shows the last targeting reason.

See [target selection, limits and tests](docs/TARGET_PRIORITIES.md).

## Defence and Special construction

Open **OFFICER > FACTORY / ECONOMY > DEFENCE / SPECIAL BUILDS** with constructors selected. The menu lists their actual native build options. Pick a building and place its native ghost to add an Officer construction request. This includes expensive strategic structures when the selected builders support them. Terraform commands remain in the native interface. Launcher construction and launcher firing are separate controls.

**AUTO STRUCTURES**, enabled by default during automatic economy control, adds affordable local ground/AA/naval defenses, radar, and conditional jammer/shield support. It respects observed threats, coverage, army investment, energy and military catch-up priorities. It does not automatically choose nukes, superweapons or long-range artillery yet. Existing Defence/Special buildings are also eligible for tracked repair/rebuilding after loss. Manual overrides remain authoritative.

See [scope, budgets and tests](docs/STRUCTURE_CONSTRUCTION.md).

## Default objective and wave tactics

Local automatic startup now uses **WIN THE GAME** with **WAVE TACTICS**. This means map-wide scouting, resource contests, expansion and attacks on legitimately observed enemies until stopped or the match ends. It is an objective, not a promise of victory. Drawn objectives still restrict operations to their corridor.

Open **OFFICER > FACTORY / ECONOMY** to toggle production, re-enroll selected factories, release selected factories, and manage builders. Existing queues remain intact. Manual commands release a factory until you explicitly return it to AI control.

**SET OBJECTIVE** includes a **WIN THE GAME** button (no line required) and a tactic selector. Wave tactics groups follow-up ground troops for the current front: three ready recruits can launch a batch, successive batches are at least 12 seconds apart, and a lone recruit waits at most 12 seconds when a valid operation can be issued. The opening force moves immediately; native combat, defenses, retreats and manual overrides remain authoritative. Air/naval units retain their separate domain controllers. Choose **CONTINUOUS PRESSURE** for immediate reinforcement instead. The tactic preference persists.

Suitable scouts detach at three military units, increasing to four scout units and eight raiders as the army grows. Missing suitable units can limit these groups. Expansion gets first consideration on three of four discretionary job turns instead of two of three; urgent power and military catch-up capacity retain priority. Unknown territory is still surveyed and observed threats still constrain constructor routes.

See [wave behavior and validation](docs/WAVE_DEFAULTS.md).

## Resource pressure, defense and rebuilding

Constructor continuity fixes recognize native build approaches and internal clearance moves, retain workers through those queue changes, and return idle automatic recovery builders to economic work. Healed military units can rejoin after native retreat. Manual overrides remain authoritative. See [causes and tests](docs/BUILDER_CONTINUITY.md).

In delegated map control, the main army and raiders contest public metal nodes while scouts keep exploring. Main-army regrouping leaves those detachments active. Reserves respond to observed infrastructure incidents and, with twenty or more assigned units, rotate among owned sites. Quiet recovery escorts shrink and expire so they do not indefinitely tie up the field army.

Recovery uses available mobile constructors from actual factory build options, retries stalled tracked jobs without dropping its workers, and starts rebuilding when its reserved initial funding is available. Manual orders still override it. See [behavior and native test results](docs/PRESSURE_RECOVERY.md).

## Expanding economy, overdrive and counter factories

**Military catch-up:** when recent scouting suggests roughly comparable income but our completed army value is far behind, a temporary spending mode favors counter troops, defers optional infrastructure and adds factory capacity only after sustained saturation. It exits when the army recovers or the evidence no longer qualifies. It never reads hidden enemy resources. See [thresholds, diagnostics and tests](docs/MILITARY_BUDGET.md).

In local single-player, automatic map control also starts economic expansion by default. The Officer keeps considering unclaimed public mex spots across the map, checks the approach against observed threats and surveys unseen approaches in steps. A stalled tracked order can be removed and retried elsewhere without permanently abandoning the builder. Manual release remains permanent until explicit re-enrollment.

It adds storage when income outgrows a nearly full buffer, develops solar/tidal generation into fusion, and links useful grids with pylons using the game's actual grid IDs and connection radii. Pending generation is counted, and a severe energy shortage can redirect one authorized builder to basic power. Expansion and discretionary upgrades alternate rather than letting upgrades consume every available builder.

When income exceeds existing factory capacity, new factory choices use their affordable unit-by-unit counters. A new factory type must materially improve on available production; otherwise capacity is added to a suitable existing type. Covered unit matchups no longer receive a cheap-unit discount. Shared role/queue demand, affordability, native build options and manual overrides remain in force. See [economy growth behavior and tests](docs/ECONOMY_GROWTH.md).

Open **OFFICER > FACTORY / ECONOMY** for **ECONOMY: ON/OFF** and **ADD ECONOMY BUILDERS**. The latter explicitly returns selected constructors to expansion control. Recovery builders and expansion builders have separate duties. Disabling economy preserves native orders already issued. Disable **Automatic economic expansion in authorized sessions** in widget settings to keep the preference off in later matches. **STOP AI** ends the current automatic session.

This is experimental. The [Circuit Brutal campaign](docs/BENCHMARK_RESULTS.md) uses normal commander starts and lets the Officer run its economy without scripted help. The 32-match baseline recorded zero wins, 25 losses and seven time limits; the full corrected rerun recorded zero wins, 20 losses and 12 time limits. **It is not a reliable Brutal-beating AI.** Time limits are not wins. The three holdout maps remain unused pending a stronger training candidate. Results, curves, production checks and remaining failure priorities are published in the report. The newly enabled [unit-by-unit matrix](docs/UNIT_MATCHUPS.md) is a later experimental change; it was not used in those benchmark results.

## Unit-by-unit counter production (experimental)

The supplied unit matchup matrix is now **enabled by default** alongside the corrected economy/production logic. It biases candidate units against individually identified enemy types, using decaying visual sightings. Missing rows/pairs, unsupported targets and invalid values retain the existing role logic. The matrix's generic class fallback columns are not used. Exact values of 1.00 are neutral; other values are provisional preferences, not measured combat probabilities.

All controlled factories share army/queue deficits; builders, resource limits, actual build options and manual overrides retain priority. The cheap early opening remains only until five units exist or a covered visual matchup is known. Production choices and read-only recommendations include the unit-pair bias. Factory decisions log the strongest contributing pair, effective coverage and bias. For the matrix-covered share, role demand is compared without a unit-price discount; missing coverage retains the old score. Expensive units are limited by sustainable income or sufficient stored metal, not automatically rejected for being dearer.

Disable **Unit-by-unit counter matrix (unfinished draft)** in Command Layer settings to restore legacy scoring. This setting persists; control authority does not. No new autonomous targeting or visibility access is added. See [implementation and testing](docs/UNIT_MATCHUPS.md). **The previous benchmark improvements did not evaluate this matrix.**

## Adaptive production and expanded control (preview 10)

Open **OFFICER > FACTORY / ECONOMY**. These features require a local session or explicit multiplayer opt-in. Manual orders release affected units; explicit re-enrollment returns them to AI control.

| Control | Behavior |
|---|---|
| RE-ENROLL SELECTED FACTORIES | Return selected factories to shared AI production. Preserve busy queues and other factories' manual exclusions. |
| ADD SELECTED BUILDERS | Enroll mobile constructors for recovery and requested construction; let existing queues finish. |
| ADD BUILD REQUEST | Select a capable constructor, click this, then choose/place one building in the native build menu. Escape cancels placement. |
| CANCEL BUILD REQUESTS | Clear pending requests/reconstruction; retain native orders already issued. |
| STOP RECOVERY | Release workers; retain native queues. |
| ARM SELECTED LAUNCHERS | Authorize native ammunition production and automatic visual-target fire for selected launchers/silos. Mobile launchers leave army movement control while armed. |
| STOP STRATEGIC FIRE | Remove only tracked AI attack orders; retain native ammunition queues. |

**Shared counter production.** The army-wide model remembers visual sightings with a default 90-game-second half-life and six-half-life expiry. Radar never refreshes identity. All controlled factories share counter-role weights and completed/queued friendly combat value; each purchase updates the deficit before another factory chooses. Counter weights themselves decay with old intel. Newly completed factories join while production is on. Set **Enemy intel half-life** under Settings > Interface > Command Layer. The panel shows weighted sightings and unknown radar contacts. This is a transparent role heuristic, not a guaranteed best unit matchup or hidden enemy count.

**Rear-area recovery.** The service records own mex/energy/factory sites and retains a reserve escort after attacks. Workers repair, clear blocking wrecks, reconstruct recorded structures and reclaim visible unit wrecks. It requests one recovery constructor at five mobile units and two at twenty, using actual factory build options. Available idle mobile constructors can fill this duty; a Cloakbot Factory is not required. Other builders can be enrolled manually. Destroyed factories return at their recorded location/facing; ongoing expansion is now handled by the separate Economy service when enabled; explicit requests remain available. Resources, unlocks, LOS and native placement still apply. Manual single-target reclaim suppresses reconstruction of that asset.

Workers withdraw from observed nearby threats and screen recovery routes. After 35 seconds without movement/work progress, a non-starved stalled job can remove only its tracked queue tag, retain the worker, and retry after cooldown. Escort duty ends when recovery finishes or 45 seconds after the last threat; pending requests remain afterward. Uneven terrain, congestion and inaccessible islands can still prevent recovery. The successful construction test used an explicitly flattened test pad, not arbitrary-terrain routing.

**Air and sea.** Aircraft and ships/submarines use separate detachments and native Fight destinations. Aircraft yield to native rearm/repair states. Ships receive water-compatible destinations using public terrain checks. Both can respond to rear threats where their domain permits, and new recruits join their own detachment. Air/sea positioning is arrival-only; standing reserves remain ground-focused. This does not implement transport loading, carrier aircraft management or every special ability. A compatible water destination is not proof of a connected route.

**Missiles and nukes.** Armed silos build native Eos missiles and fire completed children. Stockpile launchers use actual native ammunition. Targets must be currently visually identified, in weapon range and valuable enough for the role heuristic, without friendlies in the blast exclusion area. Known visible anti-nuke coverage is checked; hidden interception remains unknown. Radar/stale identities never become firing targets. One tracked shot per launcher and temporary target reservations limit duplicate fire. Old AI attacks are removed after firing, loss of visual contact or a short timeout. Native Zero-K stockpile widgets may maintain their own ammunition queue targets; those queues remain intact. Launcher grants are not saved across matches/reloads.

The existing Logistics, ground formations, manual override and approval controls remain available. Public/ranked autonomous use remains disabled. See [preview 10 test evidence and limitations](docs/PREVIEW10_TEST.md) and [source notes](docs/ADAPTIVE_RECOVERY_RESEARCH.md). Earlier preview sections below describe the development history; this section describes the current expanded behavior.

## Automatic map-control AI

With the widget enabled, **map-control AI now starts automatically in local single-player games**, including after `/luaui reload`. No unit selection, drawn line, private-session button or separate production click is required. The local single-player/autohost/spectator checks run before automatic startup.

It recruits your eligible military units, queues idle factories and searches successive sectors across the whole map. Scouts and harassment groups choose separate sectors; the main force searches too and redirects to currently visible enemies. It does not stop at the first line. Completed searches pick another sector; native empty queues can retry after a cooldown rather than permanently abandoning those units. Unexpected nonempty queues and manual releases remain protected.

The search planner uses a 5x5 map grid, visit/attempt history, group reservations and legitimately observed contacts. It does not know where hidden enemies are. RAID prefers vulnerable observed contacts; MAIN uses native Fight toward observed positions. Arrival and no-contact timeouts allow new objectives; native combat and damaged-unit recovery still have priority. This is an experimental heuristic, not a strategic search guarantee.

**STOP AI** stops the active force and production for this session. To prevent automatic startup in future sessions/reloads, disable **Automatically start map-control AI in local single-player** under Settings > Interface > Command Layer, or disable the widget. **WIN THE GAME** explicitly restarts it. Automatic startup is a saved preference; active assignments, operations and approvals are still not serialized.

Player-drawn objectives and explicit front controls revoke that force's map-wide mode and retain bounded corridor behavior. This gives you an explicit way to direct one force while using autonomous search elsewhere.

**PRODUCTION: ON/OFF** is directly visible on the Officer panel and can be enabled even before any military unit exists. It controls eligible idle factories, including newly completed factories. Manual factory commands release that factory. It preserves existing queues. The separate Recovery service can produce recovery constructors, reconstruct recorded infrastructure and execute your explicit building requests, as described below.

**AUTO ASSIGN: WAIT** means local testing is disabled; **ON** means recruitment is enabled. It creates a receiving force and checks existing unassigned and newly completed military units once per game second. Previously manually released units remain released. Toggling recruitment on pins the receiving force; merely cycling the viewed force does not redirect recruits. Production recruits retain their production-force association.

**STOP AI** stops future combat automation and production for the active force and prevents automatic restart. Existing native orders can finish; issue a manual Stop to halt those too. Changing objectives, fronts or cancelling delegation retains player priority. Individual grants are never saved; the enabled automatic-start preference creates a fresh grant after local-game checks on reload/new matches. Manual orders always override it.

This now includes experimental native economic expansion as well as military control and factory queues. It is not a guarantee of victory. Explicitly drawn-line forces hold at their final objective; map-control forces keep searching. Terrain and heavy-army congestion remain limitations.

See [map-control evidence](docs/MAP_CONTROL_TEST.md) and [earlier startup/UI stress tests](docs/STARTUP_TEST.md).

## Reserves and defensive response

Autonomous forces now keep **approximately 20% of assigned military metal value** in suitable healthy ground combat units. Small forces guard home; map-control forces of twenty or more units rotate the reserve among owned infrastructure. This starts at five units: one reserves, one scouts and three advance. Unit costs are indivisible, and a force lacking suitable defenders can miss the target. Artillery, builders and support are not used as disposable reserve troops.

The Officer watches your factories, buildings, constructors/commander and vulnerable artillery/support. Observed armed enemies near these assets, unidentified radar contacts nearby, or a measured loss of asset health trigger defense. It commits the reserve first and redirects nearby compatible troops when more help is needed, targeting up to 70% of assigned value for the response. Damage without a visible attacker sends defenders to the damaged asset; it never reveals the attacker.

When no threat is currently observed, active recovery retains a smaller escort, targeting ten percent of assigned value. Once work finishes and the threat-clear delay passes, or 45 seconds after the last incident, temporary defenders return to the main force and the reserve is rebuilt. Defense and reserve orders use native Fight, a ten-second routine redispatch cooldown and the validated executor. A new incident location can trigger an immediate response. Manual releases, native retreat and Stop AI still win. Reserve/defense units are excluded from the field army's automatic fallback so a stalled push does not pull home defenders away.

Set **Reserve combat value (%)** under **Settings > Interface > Command Layer** (0-40%; default 20%). Zero disables the standing reserve, not emergency defense. **AI DETAILS** shows RESERVE and DEFENSE counts, availability and the response reason. In drawn-line mode, defensive destinations still respect that force's authorized corridor; map-control mode can defend anywhere on the map.

This is an experimental ground-defense response, not a guarantee against every attack; it does not yet choose specialized anti-air reserves or coordinate separate forces' defenses. See [defense test evidence](docs/DEFENSE_TEST.md).

## Logistics

Select constructors, click a preset, then draw the normal native area command.

| Buttons | Behavior |
|---|---|
| MEX ONLY; MEX + 1 / 2 / 4 ENERGY | Native Area Mex with the installed game's Ctrl/Alt variations supplied automatically. |
| AREA REPAIR; PERSISTENT REPAIR | Native repair area; persistent uses Alt. |
| AREA RECLAIM; PERSISTENT RECLAIM | Native reclaim area; persistent uses Alt. |

Native placement, generator substitution, target filtering and blocked-placement behavior remain in charge. Shift queues; Space uses native insertion. Incompatible command/selection changes cancel a pending preset. A preset does not guarantee every requested structure will fit.

**Example:** select constructors, click **MEX + 2 ENERGY**, then drag the Area Mex region.

## Persistent formations

Shapes: **LINE, DOUBLE LINE, TRIPLE LINE, COLUMN, WEDGE, ECHELON LEFT, ECHELON RIGHT, BOX, SCREEN and ASSAULT**.

Select an army, choose a formation, then right-drag a movement line or activate Fight and left-drag a line. Draw another line to advance and reform without choosing the preset again. Rank formations follow sampled curves; other shapes use the overall axis. Native single-unit/Alt path gestures and unrelated commands remain native.

ASSAULT separates light units, heavier frontline/riot units, AA/support and rear ranged units. Classification uses capabilities, role icons and descriptions; unknown units remain OTHER. Ground, hover and amphibious units receive formation geometry. Aircraft/ships receive ordinary destinations without ground formation corrections. Constructors, including builder commanders, are excluded by default.

| Mode | Behavior |
|---|---|
| ARRIVAL | Positions once, then leaves behavior to the game. |
| LOOSE | Default private-test maintenance: occasional substantial drift corrections; yields near observed combat. |
| STRICT | Prioritizes relative positions; corrections can interrupt native kiting/dodging. |

Ordinary non-private operation falls back to ARRIVAL. Corrections use per-unit cooldowns (five seconds Loose, two Strict), one outstanding correction per unit and a shared budget of 60 corrections/second. Arrival, overrides, unexpected queues, loss, transfer, transport, retreat and stalled movement release maintenance. Delegated native Fight can continue while nearby contacts remain.

Optional previews show positions, facing, role zones and corridors. Geometry is approximate: cliffs, narrow corridors, tight curves and map edges can cause poor placement or compressed spacing. The engine handles navigation.

## Officer with approval

Enable **LOCAL / PRIVATE TEST SESSION** for authorized local/private testing, then:

1. **ASSIGN TO OFFICER** assigns selected eligible units for advice only. **ASSIGN ALL MILITARY** captures your completed mobile military units, excluding builders, structures, unfinished units and allied units.
2. **SET OBJECTIVE** opens a policy chooser, then arms a left-drag objective line. **ASK OFFICER** requests tactical and production advice.
3. Read the brief, inspect **SHOW PLAN**, and approve one displayed action or dismiss it.

Assignment, silence and declined proposals issue no orders. Approval covers one reform, push or side approach, not the next attack. Briefs allow 60 game seconds by default and remain readable after expiry. Removal/override of reviewed units, ownership, position, health, objective or observed-threat changes invalidate approval. Newly recruited units do not invalidate or enlarge the frozen approval snapshot. Invalid offers can refresh after five seconds; the replacement requires new approval. Repeated approval cannot execute twice.

**ADVANCE / HOLD / FLANK LEFT / FLANK RIGHT** choose a force's approach. Adviser flank proposals are geometric side approaches, not proof of an exposed enemy flank. Separate assignments/objectives can represent fronts; PREVIOUS/NEXT FORCE changes the active record. There is no coordinated multi-front strategic planner.

Production advice uses actual factory build options, friendly capability gaps and legitimately observed enemies. **SHOW DETAILS** explains evidence, cost and alternatives. Advice never places buildings, queues units or selects constructors.

### Whole-army pushes and reinforcements (preview 2)

- **REVIEW ARMY PUSH** reviews one Fight action by the entire assigned force, including its scout/raid detachments, toward your drawn objective. Inspect the destination and slots, then approve. Approval ends separate delegation; completion returns to advice. It never invents an enemy-base destination or authorizes a second attack.
- The push heuristic requires average health above 50% and healthy friendly metal value at least 1.25 times visually identified enemy value near the objective. Otherwise it proposes reforming. This is a coarse comparison, not a prediction of victory; radar and unobserved territory remain uncertain.
- **AUTO ASSIGN: ON/OFF** is an opt-in, persistent setting in the Officer panel, OFF by default. Existing unassigned and newly completed owned mobile military units join the receiving force chosen when recruitment was enabled. Builders, structures, unfinished units and manually released units are excluded. Toggle it OFF to stop recruitment. A once-per-second sweep catches existing eligible units and missed completion events; use Assign All to explicitly reassign manually released units.
- New recruits silently join membership without replacing the offered brief or expanding an approved action. Under explicit delegation, reinforcements catch up to an active main phase and join subsequent group movements. Adviser membership alone issues no orders. Selection changes do not change which force is active; use Previous/Next Force.
- Large delegated/whole-army layouts use additional distinct ranks when the requested shape overflows the corridor. Role-zone order is retained; the precise geometric shape may change. Packed ranks use native movement without anchor corrections. If the army cannot fit, the Officer asks for a wider line rather than merging destinations. Terrain navigation still belongs to the engine.
- Congestion-stalled units retry after 30 game seconds. Unknown queues and manual overrides are not treated as congestion. Partial arrival no longer counts as total group failure.
- Under explicit delegation, 60 seconds without 128 units of forward progress, loss/release of over 25% of the review membership, or average health below 40% now triggers **automatic fallback and regroup**. No additional approval is needed for this recovery. Adviser-only/one-shot-approved control does not gain this authority. See the preview 5 recovery policy below.

## Delegated pressure: authorized sessions

For sustained control:

**LOCAL / PRIVATE TEST SESSION > ASSIGN ALL MILITARY (or selected force) > SET OBJECTIVE > DELEGATE PRESSURE**

This explicitly authorizes repeated actions for that force inside the drawn corridor:

- Small SCOUT/RAIDER detachments revisit corridor edges, preferring unobserved and less recently checked points.
- Small raider groups approach suitable **visually identified** local targets or patrol for opportunities.
- MAIN repeatedly advances with native Fight, considering intermediate side approaches with less observed resistance and wider spacing against visible riots.
- Compatible units already assigned to MAIN can replace lost light detachments. Artillery is not substituted as disposable scouts.
- Damaged/exposed light detachments can withdraw with native movement. New main advances pause at very low average health.
- At the final line MAIN holds under control; light detachments may continue within the corridor.

**AI DETAILS** shows group availability, observed composition, rule version, state and reasons. **STOP AI** revokes sustained authority. Manual orders release affected units. Changing the objective/front requires explicit delegation again. Future production joins only when **AUTO ASSIGN** is enabled.

Delegation requires local session authority or **ENABLE MULTIPLAYER AI** for the current match. Economy and factory automation are available through their existing controls. Neural models and learned doctrine weights are not implemented.

The widget does not browse the web or learn strategies during a match. The separate [research helper](docs/TACTICAL_RESEARCH.md) fetches public source metadata and writes review-only candidates. Those files cannot issue orders or automatically change doctrine rules.

## Objective policies and optional production (preview 3)

**SET OBJECTIVE** now shows:

| Policy | Behavior after drawing the line |
|---|---|
| ADVICE ONLY | Keep one-action approval control. |
| WIN OBJECTIVE | Start balanced scout/raid/main delegation; hold at the final line. |
| UTTER DESTRUCTION | Commit the entire assigned force together, without scout/raid detachments; 750-unit phases. |
| SHOCK AND AWE | Assault role zones, light detachments and faster 900-unit phases. |

The three autonomous choices explicitly start authorized delegation after the line is drawn and turn Auto Assign on. Choosing a policy without drawing does not change the active operation. Names describe **in-game behavior inside the drawn corridor**, not an automatic map-wide win plan. They neither identify hidden targets nor promise victory. Progress/loss/health checks can automatically withdraw and regroup inside the accepted corridor.

The same chooser contains **AUTO PRODUCTION** and **STOP PRODUCTION**. Production defaults OFF and is session-only. Enabling it authorizes existing and newly completed idle factories for the receiving force; manually released factories stay excluded until a fresh opt-in. The controller:

- Uses actual factory build options and friendly gaps/visible riot contacts to choose a mobile military unit. It prefers the requested role, with an affordable military fallback.
- Queues at most one unit per controlled idle factory every five game seconds, reserving their combined metal cost and rotating priority when funds are limited, only into an empty native factory queue. It preserves busy queues and never constructs a factory or changes rally points.
- Requires the full unit metal cost plus 100 metal in storage and at least 100 stored energy. These are simple reserves, not a complete economic forecast.
- Releases a factory when you issue a manual command to it. Turning production off preserves already queued units. It disables on losing session authority or deletion of the receiving-force record; an empty force can still receive production.
- Routes completed units from its factories back to its assigned force even if you browse another force in the UI. Existing approval snapshots remain unchanged.

The main status area shows production decisions and waiting reasons. Use PRODUCTION on the main Officer panel to stop or re-enable it; the objective chooser retains the secondary controls. Ordinary production advice remains read-only; this controller has separate explicit authority.

## Five-unit pressure and automatic recovery (preview 5)

Five assigned mobile combat units can start immediately after you draw/delegate an objective. With suitable scouts/raiders, the balanced policy sends one scout and four main units; it does not wait for a larger force or for production. Utter Destruction keeps them together. This is military pressure/reconnaissance inside your objective corridor, not automated mex expansion or a promise of map ownership.

Delegated recovery follows **EVACUATING (when injured units need cover) > WITHDRAWING > REFORMING > HOLDING > ADVANCING**:

- Evacuate critical units below 30% health first, then wounded units below 60%, then healthy units. Within each health tier, prioritize cost weighted by damage. A critical Glaive withdraws before a healthier expensive unit.
- Healthy armed raiders/riots/assault units can cover from their current positions for up to 12 seconds (at most 30% of the force). Artillery and support are not selected as cover. Cover withdraws sooner when the first wave clears or any covering unit drops below 60% health. Units displaced outside the objective corridor join evacuation. No injured unit is deliberately assigned to cover.
- Fall back up to 450 units toward the corridor origin using native movement. Keep artillery behind the original facing, not at the front of a reversed formation.
- Regroup in Assault role zones. Continue when at least 80% of surviving eligible stage units reach within 96 units of their slots, so a few stragglers do not freeze the force.
- Hold at least eight seconds after regroup and wait for average health of at least 50% before resuming.
- Change the next attempt: reduce phase length to 65% (minimum 240), widen spacing by 20% (maximum 256), and choose an alternate lane, preferring less currently observed resistance. Unknown terrain remains uncertain. Revisions are visible in AI Details.
- Recovery moves time out after 45 seconds; retry after 20 seconds, at most three failures, then hold under control until the player supplies a new objective. No repeated order spam or new approval popup.
- After resuming, allow a 30-second recovery cooldown. Manual override, native retreat, transport and session restrictions still take priority. New strategic territory still requires your objective.

Delegated plans now check visible terrain for blocked slots and short corridor-bounded detours. Unknown terrain remains native pathfinding territory. Probes ignore object occupancy, are cached, and have a 2,048-call per-plan ceiling. Intermediate waypoints preserve the Move/Fight command and append the final destination. This is a local route helper, not a complete terrain or congestion planner. See [covered withdrawal and routing tests](docs/COVER_ROUTING_TEST.md).

These are transparent tactical adaptations, not learned or globally optimal strategy. The tests verify changed commands and recovery behavior; they do not prove that every revised approach wins. See [recovery test evidence](docs/ADAPTIVE_TEST.md).

## Settings, stopping and removal

Move the Chili window by its title bar. Settings and bindable actions are under **Settings > Interface > Command Layer**: spacing, rank/support/artillery depth, constructors, overlays, maintenance mode, approval lifetime and suggestion interval. Use Zero-K's normal hotkey interface; existing keys are not overwritten. UI sizing follows the global Chili scale.

Settings and window position persist. **Assignments, proposals, operations and private/delegated authority do not.** The automatic-start preference can create fresh local single-player map authority on load. Formation mode starts OFF after reload. Choose the adviser formation before assignment; reassign to capture a different preset.

Cancel/Stop/OFF ends future Officer control. It does **not** erase ordinary destination orders already in native queues. Issue a normal Stop/manual command if you also want units to stop moving. Optional suspension requires Resume, which restores advice only.

To update, replace the same production files and reload LuaUI or restart the match. Back up local edits first: the installer overwrites this suite's files.

To disable, use the widget list. To uninstall, disable first and remove only `gui_command_layer.lua` and `Include/CommandLayer/`, or run:

```powershell
python tools/uninstall.py --game "C:\path\to\Zero-K" --dry-run
python tools/uninstall.py --game "C:\path\to\Zero-K"
```

The uninstaller retains files differing from this checkout and leaves unrelated widgets and native configuration alone.

## Multiplayer and information boundaries

The owner reports approval for the full suite in multiplayer, including ranked. Use the explicit multiplayer session control; autohost metadata alone no longer blocks an opted-in session. Ordinary helpers remain separate from automation, and local-widget prohibitions still apply.

There are no orders or observation collection while spectating/replaying. Enemy identity is read only with visual contact; radar-only contacts stay UNKNOWN. The suite does not expose fog-of-war data, conceal control or bypass local-widget restrictions.

## Multi-factory / scale validation (preview 4)

The production scheduler now serves every controlled idle factory per pass instead of one global winner. An edge-of-map formation rejection found with 1,000 units is fixed. A live 400-vs-400 test queued all four factory types and moved 398 original units by game second 16. Heavy losses triggered the expected approval pause at second 48; this was not a victorious autonomous match. See [detailed results](docs/SCALE_TEST.md).

## Test evidence and limitations

- Twenty-five Lua 5.1 regression suites cover ownership, stale/duplicate approvals, radar anonymity, logistics modifiers, geometry, delegation, withdrawal, status, 400-unit plans, reinforcement membership and stall recovery.
- Preview 2 includes a separate 30-game-second headless engine smoke test. The 400-unit and new approval/recruitment cases are mocked Lua regressions, not a demonstrated 400-unit live battle. The two new buttons have not yet had visual in-game interaction testing.
- Isolated engine tests verified native orders, actual movement, repeated scout/raid/main operations and cancellation.
- A visible equal-army test started with 32 identical units and 3,010 metal of combat value each. The corrected two-minute run ended with **nine units and 910 value each**: a stalemate, not a victory or completed objective. The opponent was scripted native Fight, not a full Circuit AI match.
- UI panels and live details were inspected. Broad terrain coverage, long-match strength, other versions/platforms and live network multiplayer reliability are not established by the local harness.

Read [combat results and reproduction](docs/COMBAT_TEST.md) and [validation history](docs/VALIDATION.md). For local regressions:

```powershell
python -m pip install lupa
python tests/run.py
```

The [separate-session launcher](tools/run_combat_test.py) uses test-only LuaRules fixtures outside the installed game. Never install those fixtures into a normal match. Supply both `--game` and a separate `--directory` when using that launcher.

## Architecture, contributions and license

UI/input > Officer > observation/classification/formation services > ownership-validated Orders > native Zero-K unit AI. Logistics uses native handlers independently. RetreatPriority selects evacuation/cover groups; Routing prepares destinations and waypoints without issuing orders. TacticalRules and TacticalController extend the same Officer and do not issue raw combat orders directly.

Read the [API](docs/API.md), [architecture](docs/ARCHITECTURE.md), [tactical rules/research](docs/TACTICAL_RESEARCH.md), [future design](docs/FUTURE_TACTICAL_ARMY_AI.md) and [attribution](docs/ATTRIBUTION.md). Bug reports should include game/engine versions, exact steps, whether delegation was enabled and relevant `[CommandLayer]` log lines. Review logs for private information before sharing.

Licensed **GPL-2.0-or-later**; see [LICENSE](LICENSE) and [NOTICE]. Credit to Zero-K, Chili and engine contributors whose conventions and services this builds upon.
