dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
UnitDefs[2]={name='cloakcon',isBuilder=true,speed=50,metalCost=120,buildOptions={3,4}}
UnitDefs[3]={name='solar',isBuilding=true,energyMake=2,metalCost=70,iconType='energy'}
UnitDefs[4]={name='factory',isFactory=true,isBuilder=true,metalCost=600,buildOptions={1,2}}
units[20]={x=1200,z=1000,team=0,def=2}; units[21]={x=1220,z=1000,team=0,def=2}; units[30]={x=1400,z=1200,team=0,def=3}; units[31]={x=1500,z=1200,team=0,def=4}
Spring.GetTeamUnits=function() local t={1,2,3,4,5,6,20,21}; if units[30] then t[#t+1]=30 end; if units[31] then t[#t+1]=31 end; return t end
local hp=100; Spring.GetUnitHealth=function(id) return id==30 and hp or 100,100,0,0,1 end
local blocked=false; Spring.TestBuildOrder=function() return blocked and 0 or 2 end
Game.maxUnits=32000; FeatureDefs={[1]={customParams={fromunit='1'}}}; Spring.GetFeatureDefID=function() return 1 end; local wreck=true; Spring.GetFeaturesInRectangle=function() return wreck and {7} or {} end
Spring.GetFeaturePosition=function() return 1500,0,1200 end; Spring.GetFeatureResources=function() return 100 end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
local enemy=false; C.observations={nearCombat=function() return enemy end,snapshot=function() return {contacts={},composition={}} end,economy=function() return {metal={current=5000},energy={current=5000}} end}
C.input={}; C.recovery=loadModule('Recovery')(C); C.recovery.start(); C.recovery.update(); assert(C.recovery.workers[20] and C.recovery.workers[21])
hp=40; C.recovery.threat({1400,0,1200}); local before=#calls
clock=20; C.recovery.update(); assert(#calls==before) -- no builders into active incident
clock=32; C.recovery.update(); assert(calls[#calls-1].cmd==CMD.REPAIR or calls[#calls].cmd==CMD.REPAIR)
assert(C.recovery.hold({1400,0,1200},clock))
-- Remember a destroyed factory; clear blocking wreck before the native build.
C.recovery.destroyed(31); units[31]=nil; hp=100; queues[20]={}; queues[21]={}; wreck=true; blocked=true
clock=54; C.recovery.update(); assert(next(C.recovery.missing))
local reclaimed=false; for _,v in ipairs(calls) do if v.cmd==CMD.RECLAIM and v.p[1]==32007 then reclaimed=true end end; assert(reclaimed)
wreck=false; blocked=false; queues[20]={}; queues[21]={}; clock=66; C.recovery.update()
local rebuilt=false; for _,v in ipairs(calls) do if v.cmd==-4 and v.p[1]==1500 and v.p[3]==1200 then rebuilt=true end end; assert(rebuilt)
-- Manual overrides stay excluded; explicit re-enrollment preserves their queue.
C.recovery.release(20); queues[20]={{id=CMD.MOVE,params={7000,0,7000}}}; before=#calls
clock=78; C.recovery.update(); for i=before+1,#calls do assert(calls[i].id~=20) end
assert(C.recovery.enroll({20})); clock=80; C.recovery.update(); assert(queues[20][1].id==CMD.MOVE)
assert(C.recovery.request(3,{1700,0,1300},0,{21})); assert(not C.recovery.request(1,{1700,0,1300},0,{21}))
C.recovery.stop(); before=#calls; clock=90; C.recovery.update(); assert(#calls==before)
-- Automatic worker production respects real build options and its 1–2 cap.
C.recovery=loadModule('Recovery')(C); C.recovery.start(); units[20]=nil; units[21]=nil
units[31]={x=1000,z=1000,team=0,def=4}; Spring.GetTeamUnits=function() return {1,2,3,4,5,6,31} end
C.proposals=loadModule('ProposalService')(C); C.officer.assign({1,2,3,4,5,6})
C.productionControl=loadModule('ProductionController')(C); C.productionControl.set(true); queues[31]={}; C.productionControl.update(); assert(calls[#calls].cmd==-2)
assert(C.recovery.workerNeed()==0) -- queued Conjurer satisfies early goal
C.settings.privateSession=false; assert(not C.recovery.enroll({31})); assert(not C.orders.service('recovery',31,-3,{1,0,1,0}))
