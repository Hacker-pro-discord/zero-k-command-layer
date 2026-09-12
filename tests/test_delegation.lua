dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetTeamUnits=function() local ids={}; for id,u in pairs(units) do if u.team==0 then ids[#ids+1]=id end end; return ids end
Spring.GetAllUnits=function() return {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.settings.privateSession=true
local fid=C.officer.assignAll(); local f=C.registry.forces[fid]
assert(not C.officer.setDelegated(fid,true) and #calls==0) -- Explicit objective required.
C.officer.objective(fid,{{900,0,5000},{2600,0,5000}})
C.tactical.update(); assert(#calls==0) -- Assignment/objective still have zero authority.
assert(C.officer.setDelegated(fid,true))
clock=12; C.tactical.update()
local d=f.delegation
assert(#d.groups.SCOUT==1 and #d.groups.RAID==2 and #d.groups.MAIN==9)
assert(#calls==12 and d.ops.SCOUT and d.ops.RAID and d.ops.MAIN)
local scouts={}; for _,id in ipairs(d.groups.SCOUT) do scouts[id]=true end
for _,o in ipairs(calls) do assert(o.cmd==(scouts[o.id] and Spring.Utilities.CMD.RAW_MOVE or CMD.FIGHT)); assert(C.formations.inCorridor(d.sector,o.p)) end
local count=#calls
clock=14; C.tactical.update(); assert(#calls==count) -- No periodic replacement of live commands.
local released=d.groups.MAIN[1]; local old=C.registry.operations[d.ops.MAIN]
C.registry.release({released},'PLAYER_OVERRIDE')
assert(not C.registry.valid(old,released))
assert(not C.orders.unit(old,released,CMD.MOVE,{1000,0,1000},C.U.options({})))
-- Simulate native arrivals, then verify sustained next phase without new approval.
for _,op in pairs(C.registry.operations) do for _,id in ipairs(op.units) do if id~=released then units[id].x=op.slots[id][1]; units[id].z=op.slots[id][3] end end end
clock=15; C.officer.update(); C.tactical.tick(f,15)
clock=31; C.tactical.tick(f,31)
assert(#calls>count)
for i=count+1,#calls do assert(calls[i].id~=released) end
local newOp=C.registry.operations[d.ops.MAIN]
assert(C.officer.setDelegated(fid,false))
count=#calls; clock=40; C.tactical.update(); assert(#calls==count and not d.active)
assert(not C.orders.unit(newOp,d.groups.MAIN[2],CMD.MOVE,{1000,0,1000},C.U.options({})))
-- Multiplayer and spectators cannot delegate; joining revokes an existing grant.
Spring.GetPlayerList=function() return {0,1} end
assert(not C.officer.setDelegated(fid,true))
Spring.GetPlayerList=function() return {0} end
assert(C.officer.setDelegated(fid,true)); Spring.GetPlayerList=function() return {0,1} end
clock=42; C.tactical.update(); assert(not f.delegation.active)
Spring.GetPlayerList=function() return {0} end
Spring.GetSpectatingState=function() return true end
assert(not C.officer.setDelegated(fid,true))

-- Direct mixed-domain formation gestures must release aircraft advice membership too.
Spring.GetSpectatingState=function() return false end
UnitDefs[2]={speed=160,canFly=true,metalCost=120,maxWeaponRange=300}
units[12].def=2
local mixed=C.officer.assign({2,12})
C.officer.submit({gesture={{1000,0,4000},{1800,0,4000}},command=CMD.FIGHT},{2,12})
assert(not C.registry.forces[mixed].members[2] and not C.registry.forces[mixed].members[12])
