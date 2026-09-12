# Milestone evidence

Each entry records checks actually run; automated checks are not a claim of visual gameplay acceptance.

1. Research: installed archive and engine inspected; official documentation and upstream code compared. No original files changed. Architecture and source map saved.

2. Engine log confirms Officer / Chili shell loaded and widget registered; Lua 5.1 syntax passed. UI screenshot inspection initially obscured by a second lobby window.
3. All four Mex modifier presets pass option/queue tests. Native handlers retained; installed for live reload.
4. Repair/reclaim modifier tests pass including Ctrl and Shift preservation. Live reload queued for separate test game; no gameplay completion claim.
5. LINE routes via Officer -> Orders; Lua 5.1 tests verify one Fight order per unit, Shift flags and override/cancel revocation. Dedicated local test driver starts engine and supports reload; UI interaction deferred while user is active in lobby.
6. Persistent preset and operation tracking implemented. Cooldowns, shared budget and tagged correction insertion preserve destination queues. Lua tests pass; live reload requested through isolated-session driver.
