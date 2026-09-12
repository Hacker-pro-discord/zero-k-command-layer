# v0.1.0-preview.9 — reserves and defensive response

- Keep approximately 20% of assigned military value in a suitable ground reserve near home assets; configurable from 0–40%.
- Respond to threats near own factories, buildings, constructors/commander and vulnerable artillery/support using legitimate observations and own health changes.
- Commit the reserve first, reinforce from nearby field troops when needed, and rebuild the reserve after the threat clears.
- Preserve defenders during field fallback and preserve player override during every reassignment.
- Show reserve and defense counts/reasons in AI DETAILS.
- Prevent retry-blocked scouting/raiding detachments from growing repeatedly.

Local single-player automation only. Existing public-play restrictions remain. Includes 26 passing Lua suites and isolated engine defense/early-five evidence; see docs/DEFENSE_TEST.md for limits.

Install by replacing gui_command_layer.lua and the complete Include/CommandLayer directory, then use /luaui reload or start a new game. Default reserve is 20%; settings are under Settings > Interface > Command Layer.
