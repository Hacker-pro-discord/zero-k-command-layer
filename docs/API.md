# Service contracts

`WG.CommandLayer` exists while loaded. Call methods with dots. This is a local integration API, not a security boundary against other installed widgets. UI/input use the same Officer pipeline. Only Orders writes combat commands.

- `SetFormationPreset(name)`: one of the ten names or `OFF`; does not move units.
- `SubmitPlayerIntent({gesture={{x,y,z},...}, command=CMD.FIGHT, options={shift=true}}, unitIDs)` / `IssueFormationMove(...)`: explicit direct instruction, returning operation ID. Only Move, RAW_MOVE and Fight accepted. Raw approved intents without an internally consumed proposal are rejected.
- `ApplyFormation(unitIDs, gesture, settings)`: geometry only. Slots, role zones, center, facing and source gesture returned.
- `GetSelectedForce()`: eligible selection; unsupported ordinary mobiles as second return value.
- `ClassifyForce(unitIDs)`: grouped roles.
- `SetPrivateTestingSession(true)`: explicitly attest authorized local/private testing. Fails with autohost metadata, replay or spectator state. False revokes assisted control.
- `AssignAdvisedForce(unitIDs)`: explicit eligible membership, no orders; returns force ID.
- `AssignAllMilitary()`: snapshot completed owned mobile non-builders into a new adviser force, no orders. Does not auto-recruit future units.
- `SetFront(forceID, front)`: `ADVANCE`, `HOLD`, `FLANK_LEFT`, `FLANK_RIGHT`. Invalidates pending proposals and cancels maintenance; no new orders.
- `SetDelegatedControl(forceID, enabled)`: explicit sustained Scout + Raid + Push authority for the assigned force and current objective corridor. Single-player roster plus private-session gate required. False stops every parallel detachment. Grants reset on reload. `GetForce` includes delegation groups, operation IDs, rule version, observed composition, state and reason.
- `SetObjective(forceID, points)`: new line invalidates old approval and cancels prior active maintenance. No orders.
- `AskOfficer(forceID)`: advice request; returns proposal ID when available. No orders.
- `GetForce(forceID)`, `GetOfficerStatus(forceID)`, `GetProposals(forceID)`: copied inspection data. Proposals include retained terminal history and current offers.
- `ApproveProposal(proposalID, revision)`: fresh validation and one consumed operation; returns operation ID or false. `DeclineProposal(proposalID)` never executes.
- `ReleaseUnits(unitIDs, reason)`, `CancelOperation(operationID)`: revoke authority, preserve unrelated native orders.
- `GetVisibleBattleState(center,radius)`: current contacts, composition, timestamp, uncertainty and contact signature. Radar has `defID=nil`, `role=UNKNOWN`; spectator/replay data is empty.
- `GetKnownEnemyComposition(center,radius)`, `GetKnownThreats(center,radius)`: filtered observation views.
- `GetEconomyState()`: own resources and exposed overdrive accounting. `GetAvailableConstructors()` lists owned builder units without selecting/commanding them.
- `ActivateLogisticsPreset(kind)`: `MEX0/1/2/4`, `AREA_REPAIR`, `PERSISTENT_REPAIR`, `AREA_RECLAIM`, `PERSISTENT_RECLAIM`; arms native command and transient options. Player area gestures still issue the command.

Proposals freeze explicit units, ownership generations, force revision, positions, health and threat signature. Approval rechecks all of them and expiry. Orders checks authority immediately before each dispatch. Operation history retains the latest 100 terminal records; active records remain.
# Autonomous startup extension (preview 7)

`WG.CommandLayer.StartAutonomous()` requires explicit current single-player/private-test authority. It enables recruitment and factory production, creates an empty receiving force if necessary, and starts a default map-control corridor when the first military unit becomes available. Returns false while locked. It does not enable the session toggle, inspect hidden enemy locations, or persist authority.

`SetAutoAssign(enabled, forceID?)` pins recruitment to the supplied force or current receiving force selection. Completion events and one-second reconciliation share Officer validation; manual releases are not recaptured. `SetAutoProduction(true)` can create an empty receiving force and includes newly completed idle factories. Existing manual queues remain untouched.

Startup owns session orchestration only. Officer still owns membership and dispatch, TacticalController supplies immediate recruit catch-up plans, and Orders validates each command. Startup is revoked on explicit delegation stop/cancellation. Merely reaching zero members does not revoke an opted-in startup; it can restart a fresh tactical controller for later recruits.
