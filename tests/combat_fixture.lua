-- Test mutator ONLY: supplies equal armies and a scripted native-Fight opponent.
function gadget:GetInfo() return {name='Command Layer Equal Armies Fixture',desc='Isolated combat benchmark',author='Command Layer',layer=100000,enabled=true} end
if not gadgetHandler:IsSyncedCode() then return end
local armies={[0]={},[1]={}}; local value={[0]=0,[1]=0}; local losses={[0]=0,[1]=0}; local damage={[0]=0,[1]=0}; local active=false
local roster={{'cloakraid',18},{'cloakriot',4},{'cloakskirm',4},{'cloakarty',4},{'cloakaa',2}}
local arsenal=Spring.GetModOptions().cl_test_arsenal=='1'
local launchers={}
if arsenal then roster={} end
local domains=Spring.GetModOptions().cl_test_domains=='1'
if domains then roster={{'cloakraid',5},{'planescout',2},{'planeheavyfighter',3},{'bomberprec',2},{'shiptorpraider',4},{'shipriot',2}} end
local defense=Spring.GetModOptions().cl_test_defense=='1'
local recovery=Spring.GetModOptions().cl_test_recovery=='1'
local recoverySolar; local homeX,homeZ=1400,1400
local homeFactory; local raiders={}
local stress=Spring.GetModOptions().cl_test_stress=='1'
if stress then roster={{'cloakraid',240},{'cloakriot',40},{'cloakskirm',40},{'cloakarty',40},{'cloakaa',40}} end
local thousand=Spring.GetModOptions().cl_test_thousand=='1'
if thousand then roster={{'cloakraid',600},{'cloakriot',100},{'cloakskirm',100},{'cloakarty',100},{'cloakaa',100}} end
local early=Spring.GetModOptions().cl_test_early=='1'
if early then roster={{'cloakraid',5}} end
local startup=Spring.GetModOptions().cl_test_startup=='1'
if startup then roster={} end
local cover=Spring.GetModOptions().cl_test_cover=='1'
if cover then roster={{'cloakraid',4},{'cloakassault',2},{'cloakarty',2},{'cloakriot',2}} end
local function report(s) Spring.Echo('[CL-COMBAT] '..s) end
local function metric()
	local totals={}
	for team=0,1 do local m,ms=Spring.GetTeamResources(team,'metal'); local e,es=Spring.GetTeamResources(team,'energy'); report('RESOURCES team='..team..' raw_metal='..math.floor(m)..' raw_energy='..math.floor(e)..' metal_storage='..ms..' energy_storage='..es) end
	for team=0,1 do local count,cost=0,0; for id in pairs(armies[team]) do if Spring.ValidUnitID(id) and not Spring.GetUnitIsDead(id) then count=count+1; cost=cost+UnitDefs[Spring.GetUnitDefID(id)].metalCost end end; totals[team]={count,cost} end
	report('METRIC frame='..Spring.GetGameFrame()..' own_count='..totals[0][1]..' enemy_count='..totals[1][1]..' own_value='..totals[0][2]..' enemy_value='..totals[1][2]..' own_lost='..losses[0]..' enemy_lost='..losses[1]..' own_damage_taken='..math.floor(damage[0])..' enemy_damage_taken='..math.floor(damage[1]))
end
function gadget:GameFrame(frame)
	if (recovery or arsenal) and frame==1 then
		Spring.SetHeightMapFunc(function() Spring.LevelHeightMap(64,64,math.min(Game.mapSizeX-64,arsenal and 7000 or 3600),math.min(Game.mapSizeZ-64,arsenal and 7000 or 3200),170) end)
		report('RECOVERY_TEST_PAD flat construction pad in isolated test only; not a routing benchmark')
	elseif frame==30 then
		-- Identical combat rosters, separate from starting commanders.
		for team=0,1 do
			local index=0
			for rank,item in ipairs(roster) do for i=1,item[2] do
				index=index+1; local x=2400+(i-(item[2]+1)/2)*70
				local z=team==0 and (2400-(rank-1)*110) or (4000+(rank-1)*110)
				if defense and team==1 then x=6000+(i-10)*50; z=6000+(rank-1)*100 end
				if stress then local columns=thousand and 40 or 25; x=600+((index-1)%columns)*(Game.mapSizeX-1200)/(columns-1); z=(team==0 and Game.mapSizeZ*.3 or Game.mapSizeZ*.75)+(team==0 and -1 or 1)*math.floor((index-1)/columns)*64 end
				if domains then local def=UnitDefs[UnitDefNames[item[1]].id]; if (def.minWaterDepth or 0)>0 then local found=false; for sx=512,Game.mapSizeX*.48,160 do if found then break end; for sz=512,Game.mapSizeZ-512,160 do local tx=team==0 and sx or Game.mapSizeX-sx; local ty=Spring.GetGroundHeight(tx,sz); if ty<-20 and Spring.TestMoveOrder(def.id,tx,ty,sz,0,0,0,true,true,false) then x=tx; z=sz; found=true; break end end end; report('DOMAIN_SEA_SPAWN valid='..tostring(found)..' team='..team..' x='..x..' z='..z) end end
				local id=Spring.CreateUnit(item[1],x,Spring.GetGroundHeight(x,z),z,team==0 and 0 or 2,team)
				if id then armies[team][id]={x=x}; value[team]=value[team]+UnitDefs[Spring.GetUnitDefID(id)].metalCost end
			end end
			Spring.SetTeamResource(team,'ms',20000); Spring.SetTeamResource(team,'es',20000)
			Spring.SetTeamResource(team,'metal',15000); Spring.SetTeamResource(team,'energy',15000)
		end
		-- Keep both starting commanders: Zero-K defeat/storage logic depends on them.
		active=true
		if stress then report('SCALE_FIXTURE commanders protected from damage to prevent early game-over; not a victory benchmark') end
		report('SETUP equal_value='..tostring(value[0]==value[1])..' own_value='..value[0]..' enemy_value='..value[1]..' resource_grant_raw=15000 visible_storage=10000 each; units_per_side='..(startup and 0 or cover and 10 or early and 5 or thousand and 1000 or stress and 400 or 32))
	elseif frame==90 and arsenal then
		for i,name in ipairs({'staticnuke','staticmissilesilo'}) do local x=1000+i*700; local id=Spring.CreateUnit(name,x,170,1000,0,0); launchers[#launchers+1]=id; if name=='staticnuke' then Spring.SetUnitStockpile(id,1,0) end; report('ARSENAL_SETUP '..name..'='..tostring(id)) end
		for i=1,3 do local target=Spring.CreateUnit('staticheavyarty',5900+i*100,170,5000,0,1); Spring.GiveOrderToUnit(target,CMD.FIRE_STATE,{0},0) end
		local scout=Spring.CreateUnit('planescout',6000,170,3700,0,0); report('ARSENAL_SCOUT '..tostring(scout)..' native Owl sight; no full-LOS cheat')
	elseif frame==90 and (defense or Spring.GetModOptions().cl_test_production=='1') then
		for i,name in ipairs((stress or startup) and {'factorycloak','factoryveh','factoryshield','factoryhover'} or {'factorycloak'}) do
			local x=800+i*600; local z=stress and 500 or 1400
			if recovery then local found=false; for sx=640,Game.mapSizeX-640,192 do if found then break end; for sz=640,Game.mapSizeZ*.45,192 do local sy=Spring.GetGroundHeight(sx,sz); local ok,feature=Spring.TestBuildOrder(UnitDefNames[name].id,sx,sy,sz,0); if ok==2 and not feature and math.abs(sy-Spring.GetGroundHeight(sx+250,sz))<10 and math.abs(sy-Spring.GetGroundHeight(sx,sz+250))<10 then x=sx; z=sz; found=true; break end end end; report('RECOVERY_FACTORY valid_site='..tostring(found)..' pos='..x..','..z) end
			local id=Spring.CreateUnit(name,x,Spring.GetGroundHeight(x,z),z,0,0)
			if defense then homeFactory=id; homeX=x; homeZ=z end
			if recovery then
				for j=1,2 do for attempt=1,32 do local angle=(attempt+j*5)*math.pi/8; local cx,cz=x+math.cos(angle)*300,z+math.sin(angle)*300; local cy=Spring.GetGroundHeight(cx,cz); if Spring.TestMoveOrder(UnitDefNames.cloakcon.id,cx,cy,cz,0,0,0,true,true,false) then local builder=Spring.CreateUnit('cloakcon',cx,cy,cz,0,0); report('RECOVERY_BUILDER valid_terrain unit='..tostring(builder)); break end end end
				for attempt=1,32 do local angle=attempt*math.pi/8; local sx,sz=x+math.cos(angle)*250,z+math.sin(angle)*250; local sy=Spring.GetGroundHeight(sx,sz); if math.abs(sy-Spring.GetGroundHeight(x,z))<20 and Spring.TestBuildOrder(UnitDefNames.energysolar.id,sx,sy,sz,0)>0 then recoverySolar=Spring.CreateUnit('energysolar',sx,sy,sz,0,0); break end end
				report('RECOVERY_SETUP two Conjurers; solar='..tostring(recoverySolar))
			end
			report('PRODUCTION_FIXTURE factory='..tostring(id)..' type='..name..'; not an equal-army comparison')
		end
	elseif frame==180 then
		for id,p in pairs(armies[1]) do if early or defense or domains then Spring.GiveOrderToUnit(id,CMD.FIRE_STATE,{0},0) else Spring.GiveOrderToUnit(id,CMD.FIGHT,{p.x,Spring.GetGroundHeight(p.x,2400),2400},0) end end
		report(early and 'PASSIVE_ENEMY hold fire for controlled recovery test' or 'ENEMY_ADVANCE native Fight issued')
	elseif arsenal and frame==2100 then
		local target=Spring.CreateUnit('staticheavyarty',4000,170,3500,0,1); Spring.GiveOrderToUnit(target,CMD.FIRE_STATE,{0},0); local scout=Spring.CreateUnit('planescout',4000,170,2500,0,0); report('ARSENAL_SECOND_TARGET '..tostring(target)..' scout='..tostring(scout)..' for completed Eos test')
	elseif defense and frame==900 then
		for i=1,8 do local x=homeX+300+i*25; local z=homeZ+100; local id=Spring.CreateUnit('cloakraid',x,Spring.GetGroundHeight(x,z),z,0,1); if id then raiders[#raiders+1]=id; Spring.GiveOrderToUnit(id,CMD.FIGHT,{homeX,Spring.GetGroundHeight(homeX,homeZ),homeZ},0) end end
		if homeFactory and Spring.ValidUnitID(homeFactory) then local h=Spring.GetUnitHealth(homeFactory); Spring.SetUnitHealth(homeFactory,h*.8) end
		if recovery and recoverySolar and Spring.ValidUnitID(recoverySolar) then Spring.DestroyUnit(recoverySolar,false,false); report('RECOVERY_DESTROY solar leaves wreck for reconstruction') end
		report('DEFENSE_RAID eight raiders near home factory; controlled initial damage; not an equal-army benchmark')
	elseif defense and frame==1800 then
		for _,id in ipairs(raiders) do if Spring.ValidUnitID(id) and not Spring.GetUnitIsDead(id) then Spring.DestroyUnit(id,false,true) end end
		report('DEFENSE_CLEAR remaining scripted raiders removed; verify reserve rebuild after cooldown')
	elseif early and (frame==900 or frame==1500) then
		local raiders=0
		for id in pairs(armies[0]) do if Spring.ValidUnitID(id) and not Spring.GetUnitIsDead(id) then
			local def=UnitDefs[Spring.GetUnitDefID(id)]; local fraction=frame==900 and .3 or 1
			if cover and frame==900 then if def.name=='cloakraid' then raiders=raiders+1 end; fraction=(def.name=='cloakassault' or def.name=='cloakarty' or def.name=='cloakraid' and raiders<=2) and .05 or .9 end
			local _,max=Spring.GetUnitHealth(id); Spring.SetUnitHealth(id,max*fraction)
			if cover then report('INJURY unit='..id..' type='..def.name..' health_fraction='..fraction) end
		end end
		report(frame==900 and (cover and 'CONTROLLED_DAMAGE six=5% four=90%' or 'CONTROLLED_DAMAGE health=30%') or 'CONTROLLED_HEAL health=100%')
	elseif active and frame%300==0 then
		metric()
		if arsenal then for _,id in ipairs(launchers) do local ready,queued=Spring.GetUnitStockpile(id); report('ARSENAL_AMMO '..id..' ready='..tostring(ready)..' queued='..tostring(queued)) end end
		if recovery then local parts={}; for _,id in ipairs(Spring.GetTeamUnits(0)) do local def=UnitDefs[Spring.GetUnitDefID(id)]; if def.name=='energysolar' or def.name=='factorycloak' or def.name=='cloakcon' then local _,_,_,_,built=Spring.GetUnitHealth(id); parts[#parts+1]=def.name..':'..id..':'..string.format('%.2f',built or 0) end end; table.sort(parts); report('RECOVERY_ASSETS '..table.concat(parts,',')) end
		if frame==30*(tonumber(Spring.GetModOptions().cl_test_duration) or 120) then report('END combat benchmark') end
	end
end
function gadget:UnitDamaged(id,def,team,amount) if active and armies[team] and armies[team][id] then damage[team]=damage[team]+amount end end
function gadget:UnitDestroyed(id,def,team) if active and armies[team] and armies[team][id] then losses[team]=losses[team]+UnitDefs[def].metalCost; armies[team][id]=nil end end

function gadget:ProjectileCreated(id,owner,weapon) if arsenal and owner and Spring.GetUnitTeam(owner)==0 then local w=WeaponDefs[weapon]; if w and (w.stockpile or (w.range or 0)>3000) then report('ARSENAL_PROJECTILE owner='..owner..' weapon='..w.name) end end end

-- Scale fixture protection avoids early game-over; not a combat victory test.
function gadget:UnitPreDamaged(id,def,team,damage)
 if stress and UnitDefs[def].customParams and (UnitDefs[def].customParams.commtype or UnitDefs[def].customParams.dynamic_comm) then return 0 end
 return damage
end
