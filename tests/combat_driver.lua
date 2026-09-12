-- Runs only in the separately named test session; never installed with the suite.
function widget:GetInfo() return {name='Command Layer Combat Test',desc='Equal-army combat driver',author='Command Layer',layer=2000000,enabled=true} end
local fid,started,last,stopped=nil,false,-100,false
local initial={}; local bootConfigured=false
function widget:Initialize()
	if Spring.GetPlayerInfo(Spring.GetMyPlayerID())~='CommandLayerCombatTest' then widgetHandler:RemoveWidget(self); return end
	Spring.SendCommands('forcestart')
end
function widget:Update()
	local A=WG.CommandLayer; local now=Spring.GetGameSeconds(); if not A then return end
	if not bootConfigured then bootConfigured=true; if Spring.GetModOptions().cl_test_mapcontrol~='1' then A.SetAutomaticMapControl(false) end end
	if not started and now>=6 and Spring.GetModOptions().cl_test_mapcontrol=='1' then started=true; fid=1; local f=A.GetForce(1); if f then for id in pairs(f.members) do local x,_,z=Spring.GetUnitPosition(id); initial[id]={x,z} end end; Spring.Echo('[CL-MAP] automatic startup force='..tostring(A.GetForce(1)~=nil)) end
	if not started and now>=6 and Spring.GetModOptions().cl_test_startup=='1' then
		started=true; A.SetPrivateTestingSession(true); Spring.Echo('[CL-STARTUP] start='..tostring(A.StartAutonomous())); fid=1
	end
	if not started and now>=6 then
		started=true; A.SetPrivateTestingSession(true); A.SetFormationPreset('ASSAULT'); fid=A.AssignAllMilitary()
		if fid then
			local stress=Spring.GetModOptions().cl_test_stress=='1'
			A.SetObjective(fid,stress and {{512,0,Game.mapSizeZ*.7},{Game.mapSizeX-512,0,Game.mapSizeZ*.7}} or {{1500,0,4000},{3300,0,4000}})
			for id in pairs(A.GetForce(fid).members) do local x,_,z=Spring.GetUnitPosition(id); initial[id]={x,z} end
			Spring.Echo('[CL-COMBAT-CLIENT] delegated='..tostring(A.SetDelegatedControl(fid,true)))
		end
		if fid and Spring.GetModOptions().cl_test_production=='1' then Spring.Echo('[CL-COMBAT-CLIENT] production='..tostring(A.SetAutoProduction(true))) end
		Spring.SetCameraTarget(2400,Spring.GetGroundHeight(2400,3100),3100,1)
	end
	if fid and now-last>=(Spring.GetModOptions().cl_test_startup=='1' and 2 or 10) then
		last=now; local f=A.GetForce(fid); local d=f and f.delegation
		if Spring.GetModOptions().cl_test_startup=='1' then local n,q=0,0; for id in pairs(f.members) do n=n+1; if #(Spring.GetCommandQueue(id,1) or {})>0 then q=q+1 end end; Spring.Echo('[CL-STARTUP] time='..math.floor(now)..' assigned='..n..' queued='..q) end
		local alive,moved,queued,advance=0,0,0,0
		for id,p in pairs(initial) do local x,_,z=Spring.GetUnitPosition(id); if x and not Spring.GetUnitIsDead(id) then alive=alive+1; if (x-p[1])^2+(z-p[2])^2>32^2 then moved=moved+1 end; advance=advance+z-p[2]; if #(Spring.GetCommandQueue(id,1) or {})>0 then queued=queued+1 end end end
		Spring.Echo('[CL-STRESS] t='..math.floor(now)..' alive='..alive..' moved32='..moved..' queued='..queued..' mean_forward='..math.floor(advance/math.max(1,alive)))
		if d and f.mapControl then local minX,maxX,minZ,maxZ=Game.mapSizeX,0,Game.mapSizeZ,0; for id in pairs(f.members) do local x,_,z=Spring.GetUnitPosition(id); if x then minX=math.min(minX,x); maxX=math.max(maxX,x); minZ=math.min(minZ,z); maxZ=math.max(maxZ,z) end end; Spring.Echo('[CL-MAP] t='..math.floor(now)..' bounds='..math.floor(minX)..','..math.floor(maxX)..','..math.floor(minZ)..','..math.floor(maxZ)) end
		if d then
			for _,group in ipairs({'SCOUT','RAID','MAIN','RESERVE','DEFENSE'}) do local n=0; for _,id in ipairs(d.groups[group] or {}) do if f.members[id] and Spring.ValidUnitID(id) then n=n+1 end end; Spring.Echo('[CL-COMBAT-CLIENT] group='..group..' alive='..n..' op='..tostring(d.ops[group])) end
			if d.defense then local r=d.defense; local n,near=0,0; for _,group in ipairs({'RESERVE','DEFENSE'}) do for _,id in ipairs(d.groups[group] or {}) do local x,_,z=Spring.GetUnitPosition(id); if x and f.members[id] then n=n+1; local target=r.threat and r.threat.point or r.home; if (x-target[1])^2+(z-target[3])^2<500^2 then near=near+1 end end end end; Spring.Echo('[CL-DEFENSE] t='..math.floor(now)..' state='..r.state..' allocated='..n..' within500='..near..' value='..(r.reserveValue or 0)..' reason='..(r.reason or 'reserve')) end
			local blocked=0; for _ in pairs(d.blocked) do blocked=blocked+1 end
			Spring.Echo('[CL-COMBAT-CLIENT] t='..math.floor(now)..' state='..d.state..' blocked='..blocked..' main_op='..tostring(d.ops.MAIN)..' reason='..d.reason)
		end
	end
	if fid and now>=(tonumber(Spring.GetModOptions().cl_test_duration) or 120) and not stopped then stopped=true; A.SetDelegatedControl(fid,false); Spring.Echo('[CL-COMBAT-CLIENT] COMPLETE'); if Spring.GetModOptions().cl_test_exit=='1' then Spring.SendCommands('quitforce') end end
end
