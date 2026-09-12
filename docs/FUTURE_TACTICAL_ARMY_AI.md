# Future Tactical Army AI

Planning only. The autonomous controller is not implemented in V1.

## Architecture and data flow

Extend the existing Officer with a fourth authority level: explicit, sustained delegation of a named force and bounded objective. Do not introduce another combat controller. Player intent or approved doctrine â†’ Officer state machine â†’ observation snapshot and role-zone plan â†’ ownership-validated Orders â†’ native Zero-K unit AI.

ForceRegistry, classification, geometry, observations, settings and diagnostics remain independent services. Logistics remains independent of combat decisions. ProductionAdvisor continues to offer advice only. The Officer does not manage economy, choose construction sites, expand, recruit automatically or take over production.

Extend force records with doctrine/version, current phase line, confidence, subgroup membership, reserve budget, loss history and retreat policy. Extend observation snapshots with timestamped stale contacts, uncertainty, attributable losses, friendly combat value and terrain constraints. Stale contacts must never be presented as current observation; radar-only identity remains unknown. Clear perspective-dependent history on spectator/replay/team changes.

## State machine and doctrine model

Use an explicit state machine initially: ASSEMBLING, REFORMING, ADVANCING, ENGAGING, HOLDING, REINFORCING, WITHDRAWING, bounded PURSUING, OBJECTIVE_REACHED, PLAYER_OVERRIDE and ABORTED. A behavior tree adds complexity without clear benefit at this scale; small ranked rule evaluators can choose transitions within the state machine.

A doctrine is a versioned game-specific data package: role-zone depths, suitable subgroup roles, phase progression criteria, observation requirements, reserve percentage, commitment triggers, retreat thresholds, cooldowns and explanations. A decision is a typed high-level intent, never arbitrary Lua or downloaded instructions. Orders validates its force generation, authority scope and budget before execution.

Start with HOLD POSITION, then ARTILLERY PUSH. Expand ASSAULT, WAVE ASSAULT, DEFENSIVE LINE, DEFENSE IN DEPTH, SCREEN AND SUPPORT, BREAKTHROUGH, MOBILE DEFENSE, FIGHTING WITHDRAWAL, RAID and RESERVE RESPONSE only after those baselines are measured.

## Ownership and formation maintenance

Control only explicit force membership. Manual orders release affected units immediately, or suspend them until explicit Resume. Membership/ownership generations invalidate queued decisions. Never replace casualties by silently recruiting nearby units or consuming autogroups/factory output.

Delegated maintenance differs from V1 Loose/Strict corrections: it can deliberately recompute compatible role zones after casualties, reform after terrain bottlenecks and change spacing in response to observed threats. Geometry remains a shared service. Units are not permanently tied to slots; reassignment stays within compatible roles. Never fill missing screen positions with artillery merely to preserve a shape.

Keep one outstanding correction, hysteresis, cooldowns and shared dispatch budgets. Track progress and stop oscillating commands. Preserve native weapon behavior, ordinary target acquisition, dodging and kiting wherever the doctrine does not explicitly prioritize positioning.

## Target boundaries and phase lines

The player defines an operation corridor, objectives and sequential phase lines. Local target selection may consider currently visual targets inside that accepted area; it cannot invent a cross-map strategic objective. Pursuit has explicit distance/time/area limits. Revalidate authority and visibility before dispatching a target-specific order.

Advance to Line A, reform, then Line B and the final objective. Aggressive progression tolerates more separation; Balanced reforms at major boundaries; Cautious waits for screen/support/artillery readiness. Terrain contraction and reformation use the same role-zone geometry. A delegated final objective transitions to **HOLDING under AI control until cancellation**. This never extends a V1 approved one-action push, which returns to adviser status.

## Reserves and preservation

Start with 20% of eligible mobile combat value, configurable to 10â€“30%. Keep compatible reserve units behind the engagement. Commit according to explicit triggers: frontline collapse, local breakthrough, threatened flank/support or a validated push opportunity. Record the reason and amount committed. Rebalance after losses without repurposing protected artillery or support as a disposable screen.

Retreat rules combine unit value, health, observed nearby friendly/enemy value, isolation and loss rate. Prioritize expensive units and endangered artillery/support. Require distinct enter/exit thresholds and cooldowns. Withdrawal destinations must lie within a player-authorized policy/area; V1 does not choose them. Respect native retreat and release conflicting higher-level control.

## Explainability, research and learning

Expose force, doctrine version, state, phase, confidence, subgroup counts, visual composition, anonymous radar count, decision, evidence, uncertainty, next action and control-ending condition. Maintain a bounded decision trace. An explanation must cite actual evaluated rule inputs, not a generated post-hoc justification.

Research stays outside execution: public source â†’ abstract concept â†’ Zero-K interpretation â†’ candidate rule â†’ offline validation â†’ promoted doctrine version. For example, reserve theory becomes a percentage of suitable Zero-K combat value and explicit game-state triggers. No real-world targeting or weapons planning; no web content can issue game commands.

Begin learning with transparent outcome statistics and reviewable weight-change proposals. Record damage/value loss, objective success, artillery survival and reserve use only when legitimately observable and attributable. Stratify comparisons by force/enemy composition and uncertainty; do not treat a small sample as proof. Investigate a small model only after a measured rules baseline, with high-level outputs such as HOLD, REFORM or COMMIT_RESERVE. Orders and ownership remain authoritative.

## Multiplayer and milestones

Autonomous delegation stays disabled in public/ranked matches unless Zero-K developers explicitly approve it. Initial testing is local/skirmish or explicitly authorized private testing. No concealment and no bypass of local-widget restrictions.

1. Extend copied force/observation schemas and replayable decision fixtures.
2. Implement explicit delegation/revocation with zero-order ownership tests.
3. Validate HOLD POSITION, terrain reformation and manual override.
4. Validate ARTILLERY PUSH and sequential lines with role-compatible reserves.
5. Add bounded local targeting and preservation with hysteresis.
6. Add multi-force coordination without automatic recruitment.
7. Measure doctrines, add explainable statistics and reviewable weights.
8. Validate research promotion offline; only then evaluate whether a small neural model offers measurable benefit.

Each stage must preserve the ordinary Logistics, direct formation and one-action approval acceptance tests from V1.


## Implemented experimental subset (2026-09-12)

The single-player pressure controller now implements explicit sustained authority, scout/raid/main detachments, bounded repeated advances, compatible replacement from assigned main units, local visual raid opportunities, information-aware side approaches and simple light-detachment preservation. See TACTICAL_RESEARCH.md for implemented scope and limitations. It extends the existing Officer; full doctrine libraries, reserves, multi-front coordination and learning remain future work.
