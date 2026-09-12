# Milestone evidence

Each entry records checks actually run; automated checks are not a claim of visual gameplay acceptance.

1. Research: installed archive and engine inspected; official documentation and upstream code compared. No original files changed. Architecture and source map saved.

2. Engine log confirms Officer / Chili shell loaded and widget registered; Lua 5.1 syntax passed. UI screenshot inspection initially obscured by a second lobby window.
3. All four Mex modifier presets pass option/queue tests. Native handlers retained; installed for live reload.
4. Repair/reclaim modifier tests pass including Ctrl and Shift preservation. Live reload queued for separate test game; no gameplay completion claim.
5. LINE routes via Officer -> Orders; Lua 5.1 tests verify one Fight order per unit, Shift flags and override/cancel revocation. Dedicated local test driver starts engine and supports reload; UI interaction deferred while user is active in lobby.
6. Persistent preset and operation tracking implemented. Cooldowns, shared budget and tagged correction insertion preserve destination queues. Lua tests pass; live reload requested through isolated-session driver.
7. Geometric layouts and sampled curved ranks pass slot-count/finite-position/bounds tests; Double Line has two distinct ranks. Engine reload logs checked. SCREEN/ASSAULT await role bands in milestone 9.
8. Role-icon classification, description fallback and constructor inclusion tests pass; no unit-name list. Installed and triggered live reload.
9. SCREEN and ASSAULT role bands implemented; test verifies artillery remains over 300 units behind raiders. Engine reload requested. No autonomous target selection.
10. In-engine screenshot confirms all formation controls render in the test match. Runtime logs show clean module reloads. Settings/actions use Epic Menu conventions. Observation service filters radar identity and disables reads while spectating. Full terrain/combat acceptance remains in final QA.
11. Explicit adviser assignment, objective drawing and nonmodal proposal lifecycle implemented; approval has no executor yet (fails closed). No assignment/objective action issues orders. Syntax/regression tests pass; live reload requested.
12. REFORM/PUSH executor enabled only after consumed approval. Tests verify assignment/objectives/no-response/expiry/decline issue zero orders, stale ownership invalidates, double approval issues no extra orders, cancel revokes active operation. Engine reload requested.
