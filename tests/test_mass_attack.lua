dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
Spring.GetFactoryCommands=function() return {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.openingPlan=loadModule('OpeningPlan')(C)
C.productionControl=loadModule('ProductionController')(C); C.startup=loadModule('Startup')(C)
C.settings.privateSession=true; C.settings.reservePercent=20
local own={}; for id=1,50 do units[id]={x=1000+id*20,z=1000,def=1,team=0}; if id<=25 then own[#own+1]=id end end
Spring.GetTeamUnits=function() return own end
assert(C.startup.start()); C.tactical.update()
local f=C.registry.forces[C.registry.activeForce]; local d=f.delegation
assert(d.massAttack and d.massSize==25 and #d.groups.RAID==0)
assert(#d.groups.RESERVE>0 and #d.groups.SCOUT>0)
assert(d.ops.MAIN and C.registry.operations[d.ops.MAIN].active)
for id=26,50 do own[#own+1]=id end
clock=60; C.startup.update(); C.tactical.update()
assert(d.massSize==50 and #d.groups.RAID==0)
C.officer.releaseUnits({26},'PLAYER_OVERRIDE'); clock=62; C.startup.update(); C.tactical.update()
assert(not f.members[26] and not C.registry.owner[26])
C.officer.setDelegated(f.id,false); local n=#calls; clock=65; C.tactical.update(); assert(#calls==n)
