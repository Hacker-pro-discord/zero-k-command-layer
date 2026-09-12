-- Test mutator ONLY: supplies equal armies and a scripted native-Fight opponent.
function gadget:GetInfo() return {name='Command Layer Equal Armies Fixture',desc='Isolated combat benchmark',author='Command Layer',layer=100000,enabled=true} end
if not gadgetHandler:IsSyncedCode() then return end
local armies={[0]={},[1]={}}; local value={[0]=0,[1]=0}; local losses={[0]=0,[1]=0}; local damage={[0]=0,[1]=0}; local active=false
local roster={{'cloakraid',18},{'cloakriot',4},{'cloakskirm',4},{'cloakarty',4},{'cloakaa',2}}
local stress=Spring.GetModOptions().cl_test_stress=='1'
if stress then roster={{'cloakraid',240},{'cloakriot',40},{'cloakskirm',40},{'cloakarty',40},{'cloakaa',40}} end
local function report(s) Spring.Echo('[CL-COMBAT] '..s) end
local function metric()
	local totals={}
	for team=0,1 do local m,ms=Spring.GetTeamResources(team,'metal'); local e,es=Spring.GetTeamResources(team,'energy'); report('RESOURCES team='..team..' raw_metal='..math.floor(m)..' raw_energy='..math.floor(e)..' metal_storage='..ms..' energy_storage='..es) end
	for team=0,1 do local count,cost=0,0; for id in pairs(armies[team]) do if Spring.ValidUnitID(id) and not Spring.GetUnitIsDead(id) then count=count+1; cost=cost+UnitDefs[Spring.GetUnitDefID(id)].metalCost end end; totals[team]={count,cost} end
	report('METRIC frame='..Spring.GetGameFrame()..' own_count='..totals[0][1]..' enemy_count='..totals[1][1]..' own_value='..totals[0][2]..' enemy_value='..totals[1][2]..' own_lost='..losses[0]..' enemy_lost='..losses[1]..' own_damage_taken='..math.floor(damage[0])..' enemy_damage_taken='..math.floor(damage[1]))
end
function gadget:GameFrame(frame)
	if frame==30 then
		-- Identical combat rosters, separate from starting commanders.
		for team=0,1 do
			local index=0
			for rank,item in ipairs(roster) do for i=1,item[2] do
				index=index+1; local x=2400+(i-(item[2]+1)/2)*70
				local z=team==0 and (2400-(rank-1)*110) or (4000+(rank-1)*110)
				if stress then x=600+((index-1)%25)*(Game.mapSizeX-1200)/24; z=(team==0 and Game.mapSizeZ*.3 or Game.mapSizeZ*.75)+(team==0 and -1 or 1)*math.floor((index-1)/25)*64 end
				local id=Spring.CreateUnit(item[1],x,Spring.GetGroundHeight(x,z),z,team==0 and 0 or 2,team)
				if id then armies[team][id]={x=x}; value[team]=value[team]+UnitDefs[Spring.GetUnitDefID(id)].metalCost end
			end end
			Spring.SetTeamResource(team,'ms',20000); Spring.SetTeamResource(team,'es',20000)
			Spring.SetTeamResource(team,'metal',15000); Spring.SetTeamResource(team,'energy',15000)
		end
		-- Keep both starting commanders: Zero-K defeat/storage logic depends on them.
		active=true
		report('SETUP equal_value='..tostring(value[0]==value[1])..' own_value='..value[0]..' enemy_value='..value[1]..' resource_grant_raw=15000 visible_storage=10000 each; units_per_side='..(stress and 400 or 32))
	elseif frame==90 and Spring.GetModOptions().cl_test_production=='1' then
		for i,name in ipairs(stress and {'factorycloak','factoryveh','factoryshield','factoryhover'} or {'factorycloak'}) do
			local x=800+i*600; local z=stress and 500 or 1400
			local id=Spring.CreateUnit(name,x,Spring.GetGroundHeight(x,z),z,0,0)
			report('PRODUCTION_FIXTURE factory='..tostring(id)..' type='..name..'; not an equal-army comparison')
		end
	elseif frame==180 then
		for id,p in pairs(armies[1]) do Spring.GiveOrderToUnit(id,CMD.FIGHT,{p.x,Spring.GetGroundHeight(p.x,2400),2400},0) end
		report('ENEMY_ADVANCE native Fight issued')
	elseif active and frame%300==0 then
		metric()
		if frame==30*(tonumber(Spring.GetModOptions().cl_test_duration) or 120) then report('END combat benchmark') end
	end
end
function gadget:UnitDamaged(id,def,team,amount) if active and armies[team] and armies[team][id] then damage[team]=damage[team]+amount end end
function gadget:UnitDestroyed(id,def,team) if active and armies[team] and armies[team][id] then losses[team]=losses[team]+UnitDefs[def].metalCost; armies[team][id]=nil end end
