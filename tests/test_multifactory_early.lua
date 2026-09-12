dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.productionControl=loadModule('ProductionController')(C); C.settings.privateSession=true
UnitDefs[2]={name='factory',isFactory=true,isBuilder=true,buildOptions={1},speed=0}
for id=20,23 do units[id]={x=1000,z=500,team=0,def=2} end
Spring.GetTeamUnits=function() return {1,2,3,4,5,6,20,21,22,23} end
local fid=C.officer.assign({1,2,3,4,5,6}); local f=C.registry.forces[fid]
assert(C.productionControl.set(true)); C.productionControl.update()
assert(#calls==4); local sent={}; for _,v in ipairs(calls) do sent[v.id]=true end
for id=20,23 do assert(sent[id]) end
clock=16; C.productionControl.update(); assert(#calls==4) -- Never overwrite busy queues.
for id=20,23 do queues[id]={} end
Spring.GetTeamResources=function(_,resource) return resource=='metal' and 230 or 1000,2000,0,0,0 end
clock=22; C.productionControl.update(); assert(#calls==6) -- 2*65 + 100 reserve, not four stale-resource checks.
for id=20,23 do queues[id]={} end
C.productionControl.release(20); units[21].team=1
clock=28; C.productionControl.update(); assert(#calls==8)
assert(calls[7].id>=22 and calls[8].id>=22)
-- Six early units do not wait for a large army or production to finish.
C.officer.objective(fid,{{900,0,5000},{2600,0,5000}})
local before=#calls; assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
assert(#calls==before+6 and #f.delegation.groups.SCOUT==1)
local main=C.registry.operations[f.delegation.ops.MAIN]
assert(main and C.rules.progress(f.delegation.sector,main.plan.center)>=590)
for i=before+1,#calls do assert(calls[i].p[3]>1000) end
