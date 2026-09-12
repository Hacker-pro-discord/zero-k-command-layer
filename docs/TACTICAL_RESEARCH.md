# Tactical pressure: research and execution boundary

## What is implemented

`pressure-1` is an experimental, transparent Zero-K rule package in TacticalRules.lua, scheduled by TacticalController.lua and executed only through Officer -> Orders. Explicit **DELEGATE PRESSURE** authorizes sustained activity inside the player's objective corridor. It requires the private-session toggle and exactly one player in the engine roster. Joining another player revokes execution permission. No public/ranked authorization is inferred from approval dialogs or widget loading.

The existing adviser and one-action approvals remain available. Delegation does not manage construction, factories, economy, production, map-wide strategy or unassigned reinforcements. No delegation survives reload. STOP AI, cancellation, a new objective/front directive or disabling the session revokes it. Manual orders remove affected units immediately; explicit Resume restores advice, not previous delegated authority.

## Source -> concept -> game interpretation

These are design interpretations, not claims that historical outcomes predict Zero-K results.

| Public source | Abstract concept | Experimental game rule |
|---|---|---|
| [National Army Museum: Weapons of the Western Front](https://www.nam.ac.uk/explore/weapons-western-front) | Limited actions can gather information. | Revisit corridor edges with a small scout detachment. Prefer points outside current LOS; do not equate unknown with safe. |
| [National Army Museum: 1918, Year of victory](https://www.nam.ac.uk/explore/1918-victory) | Coordinate complementary roles. | Advance the main role formation using native Fight while keeping separate light detachments. Ground formation maintenance yields near combat. |
| [Zero-K Strategy Treatise](https://zero-k.info/mediawiki/Strategy_Treatise) | Initiative, complementary unit roles and avoiding concentrated light units against riots. | Continue bounded advances, widen spacing with two visually identified riots, avoid sending raiders toward heavily protected targets, and consider a lower-observed-resistance side approach. |
| [National Army Museum: Cavalry on the Western Front](https://www.nam.ac.uk/explore/cavalry-western-front) | Retain flexible mobile strength. | Reserve allocation is a **candidate**, not implemented in this pressure controller. |

Historical concepts stay abstract. Distances, fractions and cooldowns below are game design choices requiring playtesting; they are not sourced real-world doctrine parameters.

## Inspectable pressure rules

- At least five units: up to two scouts, approximately 10%, using actual SCOUT/RAIDER roles. At least eight units: up to four harassment raiders, approximately 20%. Remaining units form MAIN. Builders are excluded even when the ordinary formation constructor option is enabled. Artillery is never substituted into a light detachment.
- Losses can be replenished from compatible units already assigned to MAIN. Nothing recruits new production or another force.
- Scouts revisit eight sample locations along the drawn corridor. Current LOS, observed nearby risk, distance and recent visits affect scoring. They use native RAW_MOVE. Harassment uses Fight toward a visually identified vulnerable target or a corridor patrol point. Anonymous radar contacts contribute uncertainty only.
- MAIN advances at most 600 game units per step with native Fight. Arrival authorizes the next step under the still-active grant. At the final line it remains HOLDING; light detachments continue within the corridor. A chosen HOLD front prevents main advance.
- With an ADVANCE front, an intermediate side approach may be chosen if its observed risk score is lower by at least 150. This is not terrain-aware path planning or proof of an exposed flank.
- Damaged light detachments below 40% average health, or under high observed local pressure, can move back within the same corridor. Main forces below 30% average health pause new advances. These heuristics are not reliable combat-odds estimates.
- Decision tick: two seconds. Existing native commands are retained until completion, except a bounded light-detachment emergency response after at least eight seconds. Normal completion cooldown: three seconds for MAIN, twelve for scouts/raiders. Failed motion backs off fifteen seconds; three failures pause that group. Unexpected queues, native retreat, stalled movement or transport exclude affected units until explicit re-delegation.
- Aircraft/ships receive ordinary destinations without ground formation corrections. Navigation still belongs to the engine; impassable terrain, incompatible movement domains and narrow corridors need player review. Narrow corridor slot clamping can reduce spacing.

AI DETAILS exposes rule version, group counts, current visual/radar composition, state and reason. Debug events retain decisions. No neural model, outcome-based learning, autonomous reserve commitment or unrestricted strategic target selection is included.

## Updating proposals

Changed positions, health, membership or observed threats still invalidate an old approval. The adviser can replace an invalid brief after five seconds with a newly calculated offer and explanation. The replaced ID cannot execute. Expired briefs remain readable until refreshed/dismissed. Delegated forces do not generate approval prompts for their own autonomous steps.

## Online research helper

Run outside the game:

```powershell
python tools/research_doctrines.py combined-arms --output docs/research/combined-arms-candidate.json
```

Topics: `reconnaissance`, `combined-arms`, `reserves`. The helper fetches titles and availability from the listed public museum/wiki sources, adds a curated concept-to-game interpretation and writes a **non-executable candidate**. It does not summarize arbitrary pages, generate new tactics, or establish that a source supports a new rule. The initial combined-arms candidate was fetched successfully on 2026-09-12.

Actual rule changes require source review, explicit Zero-K interpretation, regression tests, isolated game testing and code review/version promotion. The widget never opens a network connection or loads candidate JSON. This is the first research hook, not a live web-browsing officer or an automatically learning strategy engine.

## Compatibility evidence

Installed `LuaRules/Utilities/gametype.lua` derives single-player status from `Spring.GetPlayerList()`. We recheck that roster at order dispatch rather than trusting a cached flag. Existing installed command and formation patterns supply RAW_MOVE, Fight, `GetPositionLosState`, command queues and per-unit orders. Stock files remain untouched.

The [Zero-K Code of Conduct](https://zero-k.info/mediawiki/Zero-K:Code_of_Conduct) does not serve as developer approval of this new autonomous controller. Single-player-only execution is deliberate for this experimental revision.
