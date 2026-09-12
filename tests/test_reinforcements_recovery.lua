dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.settings.privateSession=true; C.settings.autoAssign=true
local fid=C.officer.assign({1,2,3,4}); local f=C.registry.forces[fid]
C.officer.objective(fid,{{900,0,5000},{2600,0,5000}})
assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
local op=C.registry.operations[f.delegation.ops.MAIN]
units[13]={x=1200,z=1000,def=1,team=0}
local before=#calls; assert(C.officer.autoAssign(13))
assert(#calls==before and #op.units==4 and #f.delegation.groups.MAIN==5)
-- Transport/native retreat/unfinished/non-owned units do not gain new authority.
units[14]={x=1200,z=1000,def=1,team=1}; assert(not C.officer.autoAssign(14))
local health=Spring.GetUnitHealth
Spring.GetUnitHealth=function(id) if id==15 then return 50,100,0,0,.5 end; return health(id) end
units[15]={x=1200,z=1000,def=1,team=0}; assert(not C.officer.autoAssign(15))
UnitDefs[2]={name='builder',speed=40,isBuilder=true,buildOptions={1},xsize=2,zsize=2}
units[16]={x=1200,z=1000,def=2,team=0}; assert(not C.officer.autoAssign(16))
C.settings.mode='ARRIVAL'; op.mode='ARRIVAL'
clock=11; C.officer.update() -- begin position tracking
clock=22; C.officer.update()
assert(not op.active and type(f.delegation.blocked[1])=='number')
clock=23; C.tactical.tick(f,clock); assert(f.delegation.blocked[1])
clock=53; C.tactical.tick(f,clock); assert(not f.delegation.blocked[1])
local resumed=C.registry.operations[f.delegation.ops.MAIN]
assert(resumed.active and #resumed.units==4 and #f.delegation.groups.SCOUT==1)
C.registry.release({1},'PLAYER_OVERRIDE'); before=#calls
assert(not C.officer.autoAssign(1))
assert(not C.orders.unit(resumed,1,CMD.FIGHT,{1000,0,2000},C.U.options({})) and #calls==before)
