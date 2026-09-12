dofile(ROOT..'/tests/fixture.lua')
Game.mapSizeX=16000; Game.mapSizeZ=40000
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.settings.privateSession=true
local ids={}; for id=1,1000 do ids[id]=id; units[id]={x=3000+(id%40)*64,z=4000+math.floor(id/40)*64,def=1,team=0} end
local fid=C.officer.assign(ids); local f=C.registry.forces[fid]
C.officer.objective(fid,{{1000,0,30000},{14000,0,30000}})
assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
assert(#calls==1000,tostring(#calls)..' / '..C.debug.message)
local first=f.delegation.ops.MAIN
local removed={}; for id=1,25 do removed[#removed+1]=id end
C.registry.release(removed,'PLAYER_OVERRIDE'); local afterOverride=#calls
local prior=first
for phase=1,6 do
 for _,op in pairs(C.registry.operations) do if op.active then for _,id in ipairs(op.units) do if id>25 then local p=op.slots[id]; units[id].x=p[1]; units[id].z=p[3] end end end end
 clock=clock+1; C.officer.update(); C.tactical.tick(f,clock)
 clock=clock+16; C.tactical.tick(f,clock)
 assert(f.delegation.active and f.delegation.ops.MAIN~=prior)
 prior=f.delegation.ops.MAIN
end
for i=afterOverride+1,#calls do assert(calls[i].id>25) end
assert(#calls>6000)
