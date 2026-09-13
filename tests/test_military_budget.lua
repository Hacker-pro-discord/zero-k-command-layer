dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
UnitDefs[2]={name='mex',isBuilding=true,metalCost=85,customParams={metal_extractor_mult=1}}
UnitDefs[3]={name='enemyheavy',speed=40,metalCost=1000,maxWeaponRange=300}
UnitDefs[4]={name='factory',isFactory=true,metalCost=700,buildSpeed=18,buildOptions={1}}
units[30]={def=4,team=0,x=1000,z=1000}
local own={1,2,30}; Spring.GetTeamUnits=function() return own end
Spring.GetFactoryCommands=function() return {{id=-1}} end
local contact={}; for i=101,103 do contact[#contact+1]={id=i,defID=2,role='OTHER',visibility='VISUAL',time=10} end
contact[#contact+1]={id=104,defID=3,role='ASSAULT',visibility='VISUAL',time=10}
local reads=0; Spring.GetUnitRulesParam=function(id,key) if key=='current_metalIncome' then assert(id>=101 and id<=103); reads=reads+1; return 10 end end
local resources={metal={income=30,current=400,storage=500},energy={income=50,current=400}}
C.observations={snapshot=function() for _,v in ipairs(contact) do v.time=clock end; return {contacts=contact,time=clock} end,economy=function() return resources end}
C.enemyModel=loadModule('EnemyModel')(C); C.economy={enabled=true}; C.productionControl={enabled=true}
local b=loadModule('MilitaryBudget')(C); C.militaryBudget=b
b.update(); assert(not b.active and reads==3)
clock=26; b.update(); assert(b.active and not b.capacityNeeded,'Sustained parity and army deficit enter catch-up')
clock=48; b.update(); assert(b.capacityNeeded,'Busy production below income permits capacity after sustained surplus')
Spring.GetFactoryCommands=function() return {} end; clock=50; b.update(); assert(not b.capacityNeeded,'Idle factories require production, not another factory')
for i=3,14 do units[i]={x=1000,z=1000,def=1,team=0}; own[#own+1]=i end
clock=52; b.update(); assert(b.active); clock=83; b.update(); assert(not b.active,'Recovered army exits after hysteresis')
own={1,2,30}; clock=85; b.update(); clock=101; b.update(); assert(b.active)
for _,v in ipairs(contact) do v.visibility='RADAR'; v.defID=nil; v.role='UNKNOWN' end
local before=reads; clock=200; b.update(); clock=232; b.update()
assert(not b.active and reads==before,'Radar does not refresh income; stale evidence exits catch-up')
C.settings.privateSession=false; b.update(); assert(not b.active and not b.capacityNeeded)

-- Economic spending integration: suppress optional upgrades, allow essential power and capacity.
dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
UnitDefs[2]={name='builder',isBuilder=true,speed=40,metalCost=100,buildOptions={3,4,5}}
UnitDefs[3]={name='factorycloak',isFactory=true,metalCost=700,buildSpeed=18,buildOptions={1,2}}
UnitDefs[4]={name='energysolar',isBuilding=true,metalCost=70,energyMake=2}
UnitDefs[5]={name='staticstorage',isBuilding=true,metalCost=100}
UnitDefNames={factorycloak={id=3},energysolar={id=4},staticstorage={id=5}}
units[20]={def=2,team=0,x=1000,z=1000}; units[30]={def=3,team=0,x=1200,z=1000}
Spring.GetTeamUnits=function() return {1,2,20,30} end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
Spring.TestBuildOrder=function() return 2 end
local resources={metal={income=30,current=490,storage=500},energy={income=80,current=500}}
C.observations={snapshot=function() return {contacts={},composition={}} end,nearCombat=function() return false end,economy=function() return resources end}
local policy={active=true,builders=1,capacityNeeded=false}; C.militaryBudget={update=function() return policy end}
C.economyPlan=loadModule('EconomyPlanning')(C); C.economy=loadModule('Economy')(C); C.economy.start()
C.economy.update(); assert(#calls==0,'Catch-up skips otherwise warranted storage')
policy.capacityNeeded=true; clock=12; C.economy.update(); assert(calls[#calls].cmd==-3,'Catch-up capacity goes through native builder orders')
queues[20]={}; C.economy.tasks={}; policy.capacityNeeded=false; resources.energy.current=10; resources.energy.income=5
clock=14; C.economy.update(); assert(calls[#calls].cmd==-4,'Essential power survives the spending cut')
-- Native unit production wins over optional constructors, with reduced cash buffer.
resources.energy.current=500; resources.energy.income=80; resources.metal.current=110; resources.metal.income=10
C.proposals=loadModule('ProposalService')(C); C.officer.assign({1,2})
C.productionControl=loadModule('ProductionController')(C); C.productionControl.set(true)
C.economy.workerNeed=function() return 3 end; C.recovery={workerNeed=function() return 2 end,reserveMetal=function() return 0 end,workerDefinition=function(id) return id==2 end}
clock=20; C.productionControl.update(); assert(calls[#calls].id==30 and calls[#calls].cmd==-1,'Troop at 65 metal is funded with 40 buffer; no extra builder')
C.productionControl.release(30); local before=#calls; queues[30]={}; clock=30; C.productionControl.update(); assert(#calls==before,'Manual factory override survives catch-up')
