dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
C.settings.privateSession=true
local contacts={{id=90,defID=1,role='RAIDER',visibility='VISUAL',time=clock}}
C.observations={snapshot=function() return {contacts=contacts,time=clock} end,economy=function() return {metal={current=5000},energy={current=5000}} end}
C.enemyModel=loadModule('EnemyModel')(C)
local m=C.enemyModel.snapshot(); assert(m.roles.RAIDER==1)
contacts={{id=90,visibility='RADAR',role='UNKNOWN'}}; clock=100
m=C.enemyModel.snapshot(); assert(math.abs(m.roles.RAIDER-.5)<.00001 and m.unknown==1)
clock=191; m=C.enemyModel.snapshot(); assert(m.roles.RAIDER<.25) -- radar never refreshes visual identity
clock=600; m=C.enemyModel.snapshot(); assert(not m.roles.RAIDER)
contacts={}; for i=90,99 do contacts[#contacts+1]={id=i,defID=1,role='RIOT',visibility='VISUAL',time=clock} end
local w=C.enemyModel.weights(); assert(w.SKIRMISHER>w.RIOT)
UnitDefs[2]={name='skirm',iconType='kbotskirm',speed=80,metalCost=90,maxWeaponRange=450}
UnitDefs[3]={name='factory',isFactory=true,isBuilder=true,buildOptions={1,2}}
for id=20,23 do units[id]={x=1000,z=500,team=0,def=3} end
Spring.GetTeamUnits=function() return {1,2,3,4,5,6,20,21,22,23} end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
C.input={}; C.proposals=loadModule('ProposalService')(C); C.officer.assign({1,2,3,4,5,6})
C.productionControl=loadModule('ProductionController')(C); C.productionControl.set(true); C.productionControl.update()
assert(#calls==4); for _,v in ipairs(calls) do assert(v.cmd==-2) end
C.productionControl.release(20); C.productionControl.release(21)
assert(C.productionControl.enroll({20}) and C.productionControl.factories[20] and C.productionControl.excluded[21])
local before=#calls; clock=606; C.productionControl.update(); assert(#calls==before) -- existing queues retained
queues[20]={}; clock=612; C.productionControl.update(); assert(#calls==before+1 and calls[#calls].id==20)
C.settings.privateSession=false; assert(not C.productionControl.enroll({21})); assert(C.enemyModel.snapshot().total==0 and next(C.enemyModel.seen)==nil)
