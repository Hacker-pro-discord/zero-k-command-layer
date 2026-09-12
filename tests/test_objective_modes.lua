dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
Spring.SetActiveCommand=function() end
Spring.IsGUIHidden=function() return false end; Spring.IsAboveMiniMap=function() return false end
Spring.GetActiveCommand=function() return nil,nil end
Spring.GetModKeyState=function() return false,false,false,false end
local point={1000,0,5000}; Spring.TraceScreenRay=function() return 'ground',point end
C.observations=loadModule('Observations')(C); C.proposals=loadModule('ProposalService')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C); C.input=loadModule('Input')(C)
C.settings.privateSession=true
local fid=C.officer.assign({1,2,3,4,5,6,7,8,9,10,11,12}); local f=C.registry.forces[fid]
C.input.armObjective(fid,'UTTER DESTRUCTION')
assert(not f.delegation and not f.objectiveMode and #calls==0) -- Choosing is not drawing.
assert(C.input.press(10,10,1)); point={3000,0,5000}; C.input.release(100,100,1)
assert(f.objectiveMode=='UTTER DESTRUCTION' and f.delegation.active and C.settings.autoAssign)
assert(#f.delegation.groups.MAIN==12 and #f.delegation.groups.SCOUT==0 and #f.delegation.groups.RAID==0)
C.tactical.tick(f,clock); assert(#calls==12)
C.input.armObjective(fid,'SHOCK AND AWE'); assert(f.objectiveMode=='UTTER DESTRUCTION')
C.officer.setDelegated(fid,false); f.objectiveMode='SHOCK AND AWE'; f.formation='ASSAULT'
assert(C.officer.setDelegated(fid,true)); assert(#f.delegation.groups.SCOUT>0)
local old=C.registry.operations[f.delegation.ops.MAIN]
clock=12; C.tactical.tick(f,clock)
local op=C.registry.operations[f.delegation.ops.MAIN]
assert(op and op.plan.shape=='ASSAULT')
assert(C.rules.progress(f.delegation.sector,op.plan.center)>850)
