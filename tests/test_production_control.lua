dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.productionControl=loadModule('ProductionController')(C)
C.settings.privateSession=true
UnitDefs[2]={name='factory',isFactory=true,isBuilder=true,buildOptions={1},speed=0}
units[20]={x=1000,z=1000,team=0,def=2}
Spring.GetTeamUnits=function() return {1,2,3,4,20} end
local fid=C.officer.assign({1,2,3,4})
C.productionControl.update(); assert(#calls==0)
assert(C.productionControl.set(true)); C.productionControl.update()
assert(#calls==1 and calls[1].id==20 and calls[1].cmd==-1)
clock=16; C.productionControl.update(); assert(#calls==1) -- Preserve existing queue.
queues[20]={}; C.productionControl.release(20)
clock=22; C.productionControl.update(); assert(#calls==1) -- Manual release stays released.
assert(C.productionControl.set(true))
Spring.GetTeamResources=function() return 100,2000,0,0,0 end
clock=28; C.productionControl.update(); assert(#calls==1) -- Do not spend the reserve.
units[21]={x=1200,z=1000,team=0,def=1}
C.productionControl.createdUnit(21,20)
local other=C.officer.assign({5,6}); assert(other~=fid)
assert(C.officer.autoAssign(21,C.productionControl.created[21]))
assert(C.registry.forces[fid].members[21] and not C.registry.forces[other].members[21])
Spring.GetPlayerList=function() return {0,1} end
clock=34; C.productionControl.update(); assert(not C.productionControl.enabled and #calls==1)
