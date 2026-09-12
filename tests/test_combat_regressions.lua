dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.settings.privateSession=true
local fid=C.officer.assign({1,2,3,4,5,6,7,8,9,10,11,12})
C.officer.objective(fid,{{900,0,5000},{2600,0,5000}})
assert(C.officer.setDelegated(fid,true)); clock=12; C.tactical.update()
local f=C.registry.forces[fid]; local raid=f.delegation.groups.RAID; local damaged={}
for _,id in ipairs(raid) do damaged[id]=true end
Spring.GetUnitHealth=function(id) return damaged[id] and 30 or 100,100,0,0,1 end
local count=#calls; clock=22; C.tactical.update()
local op=C.registry.operations[f.delegation.ops.RAID]
assert(op.kind=='WITHDRAW' and op.command==Spring.Utilities.CMD.RAW_MOVE)
for i=count+1,#calls do if damaged[calls[i].id] then assert(calls[i].cmd~=CMD.FIGHT) end end

C.observations.nearCombat=function() return true end
clock=23; C.officer.update(); C.tactical.tick(f,23)
assert(C.registry.operations[f.delegation.ops.MAIN].state=='ENGAGING')
assert(f.delegation.state=='ENGAGING')
for _,id in ipairs(f.delegation.groups.SCOUT) do C.registry.release({id},'UNIT_LOST') end
-- Prevent replacement for this status-only assertion.
f.delegation.groups.MAIN={}
C.tactical.tick(f,24)
assert(f.delegation.decisions.SCOUT.state=='UNAVAILABLE')
