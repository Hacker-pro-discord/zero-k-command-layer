-- Isolated scorekeeper ONLY. Never sends observations/orders to LuaUI or an AI.
function gadget:GetInfo() return {name='Command Layer Benchmark Scorekeeper',layer=100000,enabled=true} end
if not gadgetHandler:IsSyncedCode() then return end
local json=VFS.Include('LuaRules/Utilities/json.lua')
local ended=false; local lost={[0]=0,[1]=0}; local killed={[0]=0,[1]=0}; local combatLost={[0]=0,[1]=0}
local function report(kind,data) Spring.Echo('[CL-BENCH-'..kind..'] '..json.encode(data)) end
local function metric()
	for team=0,1 do
		local m,ms,mp,mi,me=Spring.GetTeamResources(team,'metal'); local e,es,ep,ei,ee=Spring.GetTeamResources(team,'energy')
		local r={time=Spring.GetGameSeconds(),team=team,metal=m,metalIncome=mi,metalExpense=me,energy=e,energyIncome=ei,energyExpense=ee,armyValue=0,economyValue=0,army=0,builders=0,factories=0,mexes=0,lost=lost[team],combatLost=combatLost[team],killed=killed[team],composition={}}
		for _,id in ipairs(Spring.GetTeamUnits(team)) do local d=UnitDefs[Spring.GetUnitDefID(id)]; local _,_,_,_,built=Spring.GetUnitHealth(id); local value=(d.metalCost or 0)*(built or 0); local cp=d.customParams or {}
			if d.isFactory then r.factories=r.factories+1 end
			if tonumber(cp.metal_extractor_mult) then r.mexes=r.mexes+1 end
			if d.isBuilder and (d.speed or 0)>0 then r.builders=r.builders+1 end
			if not d.isBuilder and (d.speed or 0)>0 then r.army=r.army+1; r.armyValue=r.armyValue+value else r.economyValue=r.economyValue+value end
			r.composition[d.name]=(r.composition[d.name] or 0)+1
		end
		report('METRIC',r)
	end
end
function gadget:GameFrame(frame)
	if ended then return end
	if frame==1 then report('START',{map=Game.mapName,width=Game.mapSizeX,height=Game.mapSizeZ,case=Spring.GetModOptions().cl_bench_case}) end
	if frame%300==0 then metric() end
end
function gadget:UnitDestroyed(id,def,team,attacker,attackerDef,attackerTeam)
	if ended or lost[team]==nil then return end
	local value=UnitDefs[def].metalCost or 0; lost[team]=lost[team]+value
	if attackerTeam~=team and killed[attackerTeam]~=nil then killed[attackerTeam]=killed[attackerTeam]+value; combatLost[team]=combatLost[team]+value end
	local x,y,z=Spring.GetUnitPosition(id)
	report('LOSS',{time=Spring.GetGameSeconds(),team=team,unit=UnitDefs[def].name,value=value,attackerTeam=attackerTeam,attacker=attackerDef and UnitDefs[attackerDef].name,x=x,z=z})
end
function gadget:GameOver(winners)
	if ended then return end; metric(); ended=true
	report('RESULT',{time=Spring.GetGameSeconds(),winners=winners,lost=lost,killed=killed,combatLost=combatLost})
end
