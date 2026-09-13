dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
UnitDefs[2]={name='shieldcon',isBuilder=true,speed=50,metalCost=120,buildOptions={3}}
UnitDefs[3]={name='solar',isBuilding=true,energyMake=2,metalCost=70}
units[20]={x=1200,z=1000,team=0,def=2}; units[30]={x=1400,z=1200,team=0,def=3}
Spring.GetTeamUnits=function() return units[30] and {1,2,3,4,5,6,20,30} or {1,2,3,4,5,6,20} end
local money=70
C.observations={nearCombat=function() return false end,snapshot=function() return {contacts={}} end,economy=function() return {metal={current=money,income=10,storage=500},energy={current=100,income=10}} end}
C.economy={enabled=true,workers={[20]=true},release=function(id) C.economy.workers[id]=nil end}
C.recovery=loadModule('Recovery')(C); local r=C.recovery; r.start(); r.update()
assert(r.workers[20] and not C.economy.workers[20],'An idle non-Conjurer economic worker can take recovery duty')
r.destroyed(30); units[30]=nil; Spring.TestBuildOrder=function() return 2 end
clock=32; r.update()
assert(calls[#calls].cmd==-3,'Start reconstruction with exactly the reserved funding, without hidden extra 100 metal')
local task=r.tasks[20]; local tag=queues[20][1].tag
task.removeTag=tag
assert(not r.valid(20,CMD.REMOVE,{tag,999}),'Only one tracked queue tag may be removed')
clock=34; r.update(); clock=72; r.update()
assert(calls[#calls].cmd==CMD.REMOVE and calls[#calls].p[1]==tag)
assert(r.workers[20] and not r.excluded[20] and not r.tasks[20],'A stalled job must not permanently disenroll its builder')
queues[20]={}; clock=120; r.update(); assert(calls[#calls].cmd==-3,'Reconstruction retries without manual reassignment')
-- Resource starvation is not treated as a broken path.
money=0; clock=122; r.update(); local count=#calls; clock=180; r.update(); assert(#calls==count and r.workers[20])
-- Unknown queue changes and explicit override are protected, including near danger.
queues[20]={{id=CMD.MOVE,params={7000,0,7000},tag=999}}; clock=182; r.update()
assert(r.excluded[20] and not r.workers[20] and #calls==count)
r.sites={{point={1400,0,1200},lastThreat=180}}
assert(r.hold({1400,0,1200},200)); assert(not r.hold({1400,0,1200},226))
assert(not r.sites[1].finished and next(r.missing),'Escort expiry does not discard reconstruction')

-- Unseen reconstruction uses short surveys, not full-map blind build approaches.
queues[20]={}; money=500; r.enroll({20}); r.missing={}; r.sites={}; r.requests={}
assert(r.request(3,{6000,0,1000},0,{20}))
Spring.GetPositionLosState=function() return false end
Spring.TestBuildOrder=function() error('No hidden placement queries') end
clock=210; r.update(); local t=r.tasks[20]
assert(t and t.cmd==Spring.Utilities.CMD.RAW_MOVE and C.U.distance(C.U.position(20),t.params)<=500.01)
local buildKey=t.key:gsub('^survey:',''); r.destroyed(20); queues[20]={}
assert(r.retry[buildKey]==300,'Worker loss suppresses both survey and construction keys')
r.enroll({20}); local before=#calls; clock=230; r.update(); assert(#calls==before,'Site-survey fallback cannot bypass a failed reconstruction cooldown')
-- A known threat along the route prevents dispatch even if the destination is clear.
r.retry={}; C.observations.nearCombat=function(p) return p[1]>3000 and p[1]<3500 end
clock=310; r.update(); assert(#calls==before)
