dofile(ROOT..'/tests/fixture.lua')
C.openingPlan=loadModule('OpeningPlan')(C)
UnitDefs[20]={name='commander',speed=40,isBuilder=true,buildOptions={30,31,32,33,34},metalCost=1000}
for i,name in ipairs({'factorycloak','factoryveh','factoryhover','factoryspider','factoryship'}) do UnitDefs[29+i]={name=name,isFactory=true,speed=0,metalCost=600,buildOptions={1,2}} end
units[20]={x=1000,z=1000,team=0,def=20}
Game.mapSizeX=4096; Game.mapSizeZ=4096
assert(C.openingPlan.factories(20)[1].name=='factorycloak')
Game.mapSizeX=8192; Game.mapSizeZ=8192
assert(C.openingPlan.factories(20)[1].name=='factoryveh')
Spring.GetGroundHeight=function() return -100 end
assert(C.openingPlan.factories(20)[1].name=='factoryship')
Spring.GetGroundHeight=function(x,z) return x%256 end
assert(C.openingPlan.factories(20)[1].name=='factoryspider')
Spring.GetGroundHeight=function() return 0 end
UnitDefs[2]={name='fastscout',speed=150,metalCost=70,iconType='kbotscout',maxWeaponRange=100}
local state={combat=0,builders=1,scouts=0,roles={}}
assert(C.openingPlan.scout(UnitDefs[30],state)==2)
state.scouts=1; assert(not C.openingPlan.scout(UnitDefs[30],state))
-- No sightings, only 95 metal and 35 energy: first scout can start.
Spring.GetPlayerList=function() return {0} end; Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
units[21]={x=1100,z=1000,team=0,def=30}; local own={20,21}
Spring.GetTeamUnits=function() return own end
C.observations={snapshot=function() return {contacts={},composition={}} end,economy=function() return {metal={current=95,income=10},energy={current=35,income=15}} end}
C.economy={enabled=true,workerNeed=function() return 0 end}
C.productionControl=loadModule('ProductionController')(C); C.settings.privateSession=true
assert(C.productionControl.set(true)); C.productionControl.update()
assert(#calls==1 and calls[1].cmd==-2)
-- A completed scout counts; subsequent no-intel production builds the army.
units[22]={x=1200,z=1000,team=0,def=2}; own[#own+1]=22
Spring.GetUnitHealth=function(id) return 100,100,0,0,id==22 and .5 or 1 end
assert(C.openingPlan.forceState().scouts==1, 'Foundation plus current factory queue must count once')
Spring.GetUnitHealth=function() return 100,100,0,0,1 end
queues[21]={}; clock=11
C.productionControl.update(); assert(#calls==2 and calls[2].cmd==-1)
C.productionControl.release(21); queues[21]={}; clock=12; C.productionControl.update(); assert(#calls==2)
