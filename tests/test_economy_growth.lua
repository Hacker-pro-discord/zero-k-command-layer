dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
UnitDefs[2]={name='commander',isBuilder=true,speed=40,metalCost=1000,buildOptions={3,4,5,6,7,8}}
UnitDefs[3]={name='factorycloak',isFactory=true,isBuilder=true,metalCost=700,buildSpeed=18,buildOptions={1}}
UnitDefs[4]={name='energysolar',isBuilding=true,metalCost=70,energyMake=2,customParams={pylonrange=100}}
UnitDefs[5]={name='staticmex',isBuilding=true,metalCost=85,customParams={metal_extractor_mult=1,pylonrange=50}}
UnitDefs[6]={name='staticstorage',isBuilding=true,metalCost=100}
UnitDefs[7]={name='energyfusion',isBuilding=true,metalCost=1000,energyMake=35,customParams={pylonrange=150}}
UnitDefs[8]={name='energypylon',isBuilding=true,metalCost=200,customParams={pylonrange=500}}
UnitDefNames={factorycloak={id=3},energysolar={id=4},staticmex={id=5},staticstorage={id=6},energyfusion={id=7},energypylon={id=8}}
units[20]={def=2,team=0,x=1000,z=1000}; units[30]={def=3,team=0,x=1200,z=1000}
local team={20,30}; Spring.GetTeamUnits=function() return team end; Spring.GetFactoryCommands=function() return {} end
local resources={metal={current=300,income=10,storage=500},energy={current=600,income=80,storage=1000}}
local danger=false
C.observations={nearCombat=function(p) return danger and p[1]>2500 and p[1]<4000 end,snapshot=function() return {contacts={}} end,economy=function() return resources end}
Spring.TestBuildOrder=function() return 2 end
C.economyPlan=loadModule('EconomyPlanning')(C)
local function reset() queues[20]={}; calls={}; clock=clock+200; C.economy=loadModule('Economy')(C); C.economy.start() end
WG.metalSpots={{x=6000,y=0,z=1000}}
reset(); C.economy.update(); assert(calls[1].cmd==-5 and calls[1].p[1]==6000,'Far visible unclaimed mex remains eligible')
reset(); danger=true; C.economy.update(); assert(#calls==0,'Observed danger along route prevents exposed expansion'); danger=false
reset(); Spring.GetPositionLosState=function() return false end; Spring.TestBuildOrder=function() error('Do not inspect hidden occupancy') end
C.economy.update(); assert(calls[1].cmd==Spring.Utilities.CMD.RAW_MOVE and calls[1].p[1]<=1650,'Unseen expansion is surveyed in bounded steps')
Spring.GetPositionLosState=function() return true end; Spring.TestBuildOrder=function() return 2 end
resources.metal={current=490,income=30,storage=500}
reset(); C.economy.update(); assert(calls[1].cmd==-6,'Storage buffer scales with booming income')
for i=40,49 do units[i]={def=5,team=0,x=1000+(i-40)*200,z=1800}; team[#team+1]=i end
WG.metalSpots={}; resources.metal.current=300; resources.energy.income=40
reset(); C.economy.jobCount=2; C.economy.update(); assert(calls[1].cmd==-7,'Surplus phase funds fusion rather than endless small generators')
local s={nodes={{id=1,p={1000,0,1000},radius=150,grid=1},{id=2,p={2200,0,1000},radius=50,grid=2,mex=true}},grids={[1]=35,[2]=2},gridMex={[2]=1}}
local link=C.economyPlan.bridge(s,{1000,0,1000}); assert(link and C.U.distance(link.p,s.nodes[1].p)<=650)
s.nodes[2].grid=1; assert(not C.economyPlan.bridge(s,{1000,0,1000}),'Do not bridge an already shared grid')
-- Recover a navigation stall without authorizing removal of unrelated commands.
team={20,30}; WG.metalSpots={{x=6000,y=0,z=1000}}; resources.metal.income=10; resources.energy.income=80
reset(); C.economy.update(); clock=clock+2; C.economy.update()
local give=Spring.GiveOrderToUnit
Spring.GiveOrderToUnit=function(id,cmd,p,o) if cmd==CMD.REMOVE then calls[#calls+1]={id=id,cmd=cmd,p=p}; queues[id]={}; return true end; return give(id,cmd,p,o) end
clock=clock+40; C.economy.update(); assert(calls[#calls].cmd==CMD.REMOVE and C.economy.workers[20] and not C.economy.excluded[20])
local n=#calls; C.economy.release(20); clock=clock+40; C.economy.update(); assert(#calls==n,'Manual release is never auto-resumed')
reset(); C.economy.update(); resources.energy.current=10; resources.energy.income=5; clock=clock+20; C.economy.update()
assert(calls[#calls].cmd==CMD.REMOVE and C.economy.workers[20],'Critical energy shortage borrows an authorized worker')
clock=clock+3; C.economy.update(); assert(calls[#calls].cmd==-4,'Borrowed worker restores basic power instead of rejoining the unfinished project')
local tag=queues[20][1].tag; C.economy.tasks[20].removeTag=tag
assert(not C.economy.valid(20,CMD.REMOVE,{tag,999}),'A tracked removal cannot smuggle another queue tag')
