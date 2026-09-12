-- Isolated fixture only. Never shipped into the user's Widgets directory.
function widget:GetInfo() return {name='Command Layer Delegation QA',desc='Single-player isolated QA fixture',author='Command Layer',layer=2000000,enabled=true,handler=true} end
local stage,fid,units,started,initial=0,nil,{},nil,nil
local firstOps
local function report(ok,message) Spring.Echo('[CL-DELEGATION-QA] '..(ok and 'PASS ' or 'FAIL ')..message) end
function widget:Initialize()
	if Spring.GetPlayerInfo(Spring.GetMyPlayerID())~='CommandLayerDelegationTest' then widgetHandler:RemoveWidget(self); return end
	Spring.SendCommands('forcestart')
end
function widget:Update()
	local t=Spring.GetGameSeconds(); local A=WG.CommandLayer
	if not A or Spring.GetGameFrame()<1 then return end
	if not started then started=t end
	local elapsed=t-started
	if stage==0 then Spring.SendCommands('cheat'); stage=1
	elseif stage==1 and elapsed>1 then
		Spring.SendCommands('give 12 cloakraid 0 @2200,0,2400'); stage=2
	elseif stage==2 and elapsed>3 then
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID())) do if UnitDefs[Spring.GetUnitDefID(id)].name=='cloakraid' then units[#units+1]=id end end
		report(#units==12,'twelve mobile fixtures available')
		report(A.SetPrivateTestingSession(true),'private session enabled')
		fid=A.AssignAdvisedForce(units); report(fid~=nil,'army assignment accepted')
		A.SetObjective(fid,{{1600,0,4400},{3200,0,4400}})
		report(A.SetDelegatedControl(fid,true),'explicit sustained authority accepted')
		stage=3
	elseif stage==3 and elapsed>7 then
		local f=A.GetForce(fid); local d=f and f.delegation
		report(d and d.ops.SCOUT and d.ops.RAID and d.ops.MAIN,'three independent detachment operations')
		firstOps=d and d.ops
		local queued=0; for _,id in ipairs(units) do if #(Spring.GetCommandQueue(id,-1) or {})>0 then queued=queued+1 end end
		report(queued>=10,'native orders queued on '..queued..'/12 units')
		initial={}; for _,id in ipairs(units) do local x,y,z=Spring.GetUnitPosition(id); initial[id]={x,z} end
		stage=4
	elseif stage==4 and elapsed>32 then
		local moved=0; for _,id in ipairs(units) do local x,y,z=Spring.GetUnitPosition(id); if x and initial[id] and (x-initial[id][1])^2+(z-initial[id][2])^2>400 then moved=moved+1 end end
		report(moved>=8,'actual engine movement on '..moved..'/12 units')
		local ops=A.GetForce(fid).delegation.ops; report(firstOps and ops.MAIN>firstOps.MAIN and ops.SCOUT>firstOps.SCOUT and ops.RAID>firstOps.RAID,'recurring scouting, harassment patrol and main advances reached engine')
		A.ReleaseUnits({units[1]},'PLAYER_OVERRIDE'); report(not A.GetForce(fid).members[units[1]],'manual override releases unit')
		A.SetDelegatedControl(fid,false); report(not A.GetForce(fid).delegation.active,'stop revokes sustained authority')
		stage=5
	elseif stage==5 and elapsed>34 then
		report(not A.GetForce(fid).delegation.active,'delegation stays stopped after next tick')
		Spring.Echo('[CL-DELEGATION-QA] DONE'); Spring.SendCommands('quitforce'); stage=6
	end
end
