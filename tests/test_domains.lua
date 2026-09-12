dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; Spring.AreTeamsAllied=function(a,b) return a==b end
C.settings.privateSession=true; C.settings.reservePercent=20
UnitDefs[2]={name='air',iconType='planefighter',canFly=true,speed=150,metalCost=150,maxWeaponRange=500}
UnitDefs[3]={name='boat',iconType='shipraider',speed=60,metalCost=200,minWaterDepth=5,maxWeaponRange=350}
for i=6,8 do units[i].def=2 end; for i=9,12 do units[i].def=3; units[i].x=5000 end
Spring.GetGroundHeight=function(x) return x>=4000 and -100 or 100 end
Spring.TestMoveOrder=function(def,x) return def~=3 or x>=4000 end
Spring.GetTeamUnits=function() local t={}; for i=1,12 do t[i]=i end; return t end
Spring.GetAllUnits=function() return {} end
C.observations=loadModule('Observations')(C); C.input={}; C.proposals=loadModule('ProposalService')(C)
C.rules=loadModule('TacticalRules')(C); C.domains=loadModule('Domains')(C); C.tactical=loadModule('TacticalController')(C)
local fid=C.officer.assignAll(); local f=C.registry.forces[fid]; f.mapControl=true
assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
local d=f.delegation; assert(#d.groups.AIR==3 and #d.groups.SEA==4)
for _,id in ipairs(d.groups.AIR) do assert(C.registry.owner[id] and C.registry.operations[C.registry.owner[id]].kind=='AIR') end
for _,id in ipairs(d.groups.SEA) do local op=C.registry.operations[C.registry.owner[id]]; assert(op and op.kind=='SEA' and op.slots[id][1]>=4000 and op.mode=='ARRIVAL') end
for _,id in ipairs(d.groups.MAIN) do assert(units[id].def==1) end
-- No per-tick retargeting; manual release beats domain operations.
local before=#calls; clock=12; C.tactical.tick(f,clock); assert(#calls==before)
C.registry.release({6},'PLAYER_OVERRIDE'); before=#calls; clock=14; C.tactical.tick(f,clock); for i=before+1,#calls do assert(calls[i].id~=6) end
-- Native aircraft rearm is yielded to and does not permanently block the aircraft.
Spring.GetUnitRulesParam=function(id,name) if id==7 and name=='noammo' then return 2 end end
clock=16; C.officer.update(); assert(type(d.blocked[7])=='number')
before=#calls; clock=22; C.tactical.tick(f,clock); for i=before+1,#calls do assert(calls[i].id~=7) end
Spring.GetUnitRulesParam=function() return nil end; clock=28; C.tactical.tick(f,clock); assert(C.registry.owner[7])
-- New air units join without restarting the existing detachment.
units[13]={x=1200,z=1000,team=0,def=2}; C.settings.autoAssign=true
assert(C.officer.autoAssign(13,fid)); local previous=d.ops.AIR; clock=30; C.tactical.tick(f,clock); assert(C.registry.owner[13] and d.ops.AIR==previous)
-- No water means no naval land orders.
Spring.GetGroundHeight=function() return 100 end; assert(not C.domains.waterPoint(9,{1000,100,1000}))
