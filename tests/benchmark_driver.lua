-- Live telemetry is strictly player-perspective; scoring gadget has no connection here.
function widget:GetInfo() return {name='Command Layer Benchmark Driver',layer=2000000,enabled=true} end
local json=Spring.Utilities.json
local configured=false; local last=-100; local seen={}; local scoutSeen={}; local states={}; local over
local function report(kind,data) Spring.Echo('[CL-BENCH-'..kind..'] '..json.encode(data)) end
function widget:Initialize()
	if Spring.GetPlayerInfo(Spring.GetMyPlayerID())~='CommandLayerBenchmark' then widgetHandler:RemoveWidget(self); return end
	Spring.SendCommands('forcestart'); local speed=tonumber(Spring.GetModOptions().cl_bench_speed) or 8
	Spring.SendCommands('setmaxspeed '..speed); Spring.SendCommands('setminspeed '..speed)
end
function widget:GameOver(winners) over=Spring.GetTimer(); report('CLIENT_RESULT',{time=Spring.GetGameSeconds(),winners=winners}) end
function widget:Update()
	local A=WG.CommandLayer; local now=Spring.GetGameSeconds(); if not A then return end
	if not configured then configured=true; A.SetEconomyFactory(Spring.GetModOptions().cl_bench_factory or 'AUTO') end
	if over then if Spring.DiffTimers(Spring.GetTimer(),over)>2 then Spring.SendCommands('quitforce') end; return end
	if now>=(tonumber(Spring.GetModOptions().cl_bench_duration) or 1200) then report('LIMIT',{time=now}); Spring.SendCommands('quitforce'); return end
	if now-last<10 or Spring.GetSpectatingState() or Spring.IsReplay() then return end; last=now
	local current=0; local own=Spring.GetTeamUnits(Spring.GetMyTeamID()); local groups=A.ClassifyForce(own); local force=A.GetForce(1); local scouts=force and force.delegation and force.delegation.groups.SCOUT or groups.SCOUT or {}
	for x=1,16 do for z=1,16 do local px,pz=Game.mapSizeX*(x-.5)/16,Game.mapSizeZ*(z-.5)/16; local key=x*16+z
		if Spring.GetPositionLosState(px,Spring.GetGroundHeight(px,pz),pz) then current=current+1; seen[key]=true end
		for _,id in ipairs(scouts) do local ux,_,uz=Spring.GetUnitPosition(id); if ux and (ux-px)^2+(uz-pz)^2<512^2 then scoutSeen[key]=true; break end end
	end end
	local explored,scouted=0,0; for _ in pairs(seen) do explored=explored+1 end; for _ in pairs(scoutSeen) do scouted=scouted+1 end
	local factoryQueues={}; local readyArmy=0; local grid={}; local completedStructures={}
	for _,id in ipairs(own) do local def=UnitDefs[Spring.GetUnitDefID(id)]; local _,_,_,_,built=Spring.GetUnitHealth(id)
		if built and built>=1 and (def.isBuilding or def.isFactory or (def.speed or 0)==0) then completedStructures[def.name]=(completedStructures[def.name] or 0)+1 end
		local gid=Spring.GetUnitRulesParam(id,'gridNumber')
		if gid and gid>0 and built and built>=1 then local g=grid[tostring(gid)] or {power=0,mexes=0,drain=0}; grid[tostring(gid)]=g; g.power=g.power+(Spring.GetUnitRulesParam(id,'current_energyIncome') or 0); g.drain=g.drain+(Spring.GetUnitRulesParam(id,'overdrive_energyDrain') or 0); if tonumber((def.customParams or {}).metal_extractor_mult) then g.mexes=g.mexes+1 end end
		if def.isFactory then local q=Spring.GetFactoryCommands(id,-1) or {}; local states=Spring.GetUnitStates(id) or {}; local item={id=id,queued=#q,repeatState=states['repeat'],types={}}; for _,cmd in ipairs(q) do if cmd.id and cmd.id<0 and UnitDefs[-cmd.id] then local name=UnitDefs[-cmd.id].name; item.types[name]=(item.types[name] or 0)+1 end end; factoryQueues[#factoryQueues+1]=item end
		if not def.isBuilder and (def.speed or 0)>0 and built and built>=1 then readyArmy=readyArmy+1 end
	end
	local f=A.GetForce(1); local d=f and f.delegation; local snapshot=A.GetVisibleBattleState(); local known={}; for _,c in ipairs(snapshot.contacts or {}) do known[c.role]=(known[c.role] or 0)+1 end
	local r={grid=grid,completedStructures=completedStructures,overdriveMetal=Spring.GetTeamRulesParam(Spring.GetMyTeamID(),'OD_metalOverdrive'),overdriveEnergy=Spring.GetTeamRulesParam(Spring.GetMyTeamID(),'OD_energyOverdrive'),time=now,readyArmy=readyArmy,factoryQueues=factoryQueues,los=current/256,explored=explored/256,scoutVisited=scouted/256,known=known,economy=A.GetEconomyAutomationStatus(),production=A.GetProductionStatus()}
	if d then r.state=d.state; r.reason=d.reason; r.defense=d.defense and d.defense.state; r.recovery=d.recovery and d.recovery.phase; r.strategy=d.strategy; r.groups={}; for name,ids in pairs(d.groups) do r.groups[name]=#ids end
		local key=(r.state or '')..'|'..(r.defense or '')..'|'..(r.recovery or '')..'|'..(r.reason or '')
		if key~=states[1] then states[1]=key; report('DECISION',r) end
	end
	report('CLIENT',r)
end
