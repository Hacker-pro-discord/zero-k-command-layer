-- Runs only in the separately named test session; never installed with the suite.
function widget:GetInfo() return {name='Command Layer Combat Test',desc='Equal-army combat driver',author='Command Layer',layer=2000000,enabled=true} end
local fid,started,last,stopped=nil,false,-100,false
local initial={}
function widget:Initialize()
	if Spring.GetPlayerInfo(Spring.GetMyPlayerID())~='CommandLayerCombatTest' then widgetHandler:RemoveWidget(self); return end
	Spring.SendCommands('forcestart')
end
function widget:Update()
	local A=WG.CommandLayer; local now=Spring.GetGameSeconds(); if not A then return end
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
	if fid and now-last>=10 then
		last=now; local f=A.GetForce(fid); local d=f and f.delegation
		local alive,moved,queued,advance=0,0,0,0
		for id,p in pairs(initial) do local x,_,z=Spring.GetUnitPosition(id); if x and not Spring.GetUnitIsDead(id) then alive=alive+1; if (x-p[1])^2+(z-p[2])^2>32^2 then moved=moved+1 end; advance=advance+z-p[2]; if #(Spring.GetCommandQueue(id,1) or {})>0 then queued=queued+1 end end end
		Spring.Echo('[CL-STRESS] t='..math.floor(now)..' alive='..alive..' moved32='..moved..' queued='..queued..' mean_forward='..math.floor(advance/math.max(1,alive)))
		if d then
			for _,group in ipairs({'SCOUT','RAID','MAIN'}) do local n=0; for _,id in ipairs(d.groups[group]) do if f.members[id] and Spring.ValidUnitID(id) then n=n+1 end end; Spring.Echo('[CL-COMBAT-CLIENT] group='..group..' alive='..n..' op='..tostring(d.ops[group])) end
			local blocked=0; for _ in pairs(d.blocked) do blocked=blocked+1 end
			Spring.Echo('[CL-COMBAT-CLIENT] t='..math.floor(now)..' state='..d.state..' blocked='..blocked..' main_op='..tostring(d.ops.MAIN)..' reason='..d.reason)
		end
	end
	if fid and now>=(tonumber(Spring.GetModOptions().cl_test_duration) or 120) and not stopped then stopped=true; A.SetDelegatedControl(fid,false); Spring.Echo('[CL-COMBAT-CLIENT] COMPLETE'); if Spring.GetModOptions().cl_test_exit=='1' then Spring.SendCommands('quitforce') end end
end
