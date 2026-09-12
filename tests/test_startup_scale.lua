dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
Spring.GetFactoryCommands=function(id) return {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.productionControl=loadModule('ProductionController')(C); C.startup=loadModule('Startup')(C)
C.settings.privateSession=true
local ids={}
for id=1,1000 do ids[id]=id; units[id]={x=500+((id-1)%40)*100,z=1000+math.floor((id-1)/40)*50,def=1,team=0} end
Spring.GetTeamUnits=function() return ids end
assert(C.startup.start()); C.tactical.update()
local f=C.registry.forces[C.registry.activeForce]
assert(#C.officer.members(f)==1000)
for id=1,1000 do assert(C.registry.owner[id],'Unordered unit '..id) end
local callsBefore=#calls
-- Repeated reconciliation is idempotent; no recruitment/order storm.
for i=1,20 do clock=clock+1; C.startup.update() end
assert(#calls==callsBefore and #C.officer.members(f)==1000)
C.registry.release({1,2,3},'PLAYER_OVERRIDE'); clock=clock+1; C.startup.update()
assert(#C.officer.members(f)==997 and not C.registry.owner[1])
C.officer.setDelegated(f.id,false); C.productionControl.set(false)
for _,op in pairs(C.registry.operations) do assert(not op.active) end
