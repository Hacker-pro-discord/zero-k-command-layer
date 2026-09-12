dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
UnitDefs[2]={name='factory',isFactory=true,isBuilding=true,isBuilder=true,metalCost=600,speed=0}
units[100]={x=1200,z=1200,def=2,team=0}
Spring.GetTeamUnits=function() local t={100}; for i=1,12 do t[#t+1]=i end; return t end
local assetHealth=100
Spring.GetUnitHealth=function(id) return id==100 and assetHealth or 100,100,0,0,1 end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.settings.privateSession=true; C.settings.reservePercent=20
local selected={}; for i=1,12 do selected[i]=i end
local fid=C.officer.assign(selected); local f=C.registry.forces[fid]; f.mapControl=true
assert(#calls==0) -- assignment grants no orders
assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
local d=f.delegation
assert(#d.groups.RESERVE==3 and #d.groups.SCOUT>0 and #d.groups.MAIN>0)
local reserved={}; for _,id in ipairs(d.groups.RESERVE) do reserved[id]=true; assert(C.registry.operations[C.registry.owner[id]].kind=='RESERVE') end
assert(C.U.distance(d.defense.home,{1200,0,1200})==0)
local function disjoint()
 local seen={}; for _,list in pairs(d.groups) do for _,id in ipairs(list) do assert(not seen[id]); seen[id]=true end end
end
disjoint()
-- Damage at home redirects reserve immediately, even within its hold cooldown.
assetHealth=70; clock=12; C.tactical.tick(f,clock)
assert(d.defense.threat and #d.groups.RESERVE==0 and #d.groups.DEFENSE>=4)
for id in pairs(reserved) do assert(C.registry.operations[C.registry.owner[id]].kind=='DEFENSE') end
assert(d.defense.reason:find('identity and position are not inferred'))
assert(C.registry.operations[d.ops.DEFENSE].command==CMD.FIGHT)
disjoint()
-- The player always wins, even during home defense.
local released=d.groups.DEFENSE[1]; C.registry.release({released},'PLAYER_OVERRIDE')
local before=#calls; clock=14; C.tactical.tick(f,clock)
for i=before+1,#calls do assert(calls[i].id~=released) end
-- Radar remains unknown; only its observed position/risk is used.
C.observations.snapshot=function() return {time=clock,contacts={{id=900,position={1300,0,1300},visibility='RADAR',role='UNKNOWN'}}} end
clock=24; C.tactical.tick(f,clock)
assert(d.defense.reason:find('Unidentified radar'))
-- Persistent contact does not spam orders every tick.
before=#calls; clock=26; C.tactical.tick(f,clock); assert(#calls==before)
C.observations.snapshot=function() return {time=clock,contacts={}} end
clock=28; C.tactical.tick(f,clock); assert(d.defense.threat)
clock=48; C.tactical.tick(f,clock)
assert(not d.defense.threat and #d.groups.RESERVE>=2 and #d.groups.DEFENSE==0)
assert(not f.members[released]); disjoint()
local former=C.U.copy(d.groups.RESERVE); C.settings.reservePercent=0; clock=50; C.tactical.tick(f,clock)
assert(#d.groups.RESERVE==0)
for _,id in ipairs(former) do local op=C.registry.owner[id] and C.registry.operations[C.registry.owner[id]]; assert(not op or op.kind~='RESERVE') end
-- Stop revokes everything. Quiet assignment/observation cannot restart defense.
C.officer.setDelegated(fid,false); before=#calls; assetHealth=30; clock=50; C.tactical.tick(f,clock); assert(#calls==before)

-- Five units retain an active scout and main advance while one stays in reserve.
dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; Spring.AreTeamsAllied=function(a,b) return a==b end
C.observations={snapshot=function() return {time=clock,contacts={}} end,nearCombat=function() return false end}; C.input={}
C.proposals=loadModule('ProposalService')(C); C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.settings.privateSession=true; C.settings.reservePercent=20
local fid=C.officer.assign({1,2,3,4,5}); local f=C.registry.forces[fid]; f.mapControl=true
assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
assert(#f.delegation.groups.RESERVE==1 and #f.delegation.groups.SCOUT==1 and #f.delegation.groups.MAIN==3)
assert(f.delegation.ops.MAIN and f.delegation.ops.SCOUT)
-- 1,000-unit allocation remains disjoint and leaves the majority advancing.
for i=6,1000 do units[i]={x=1000+(i%40)*32,z=1000+math.floor(i/40)*32,def=1,team=0}; f.members[i]=true end
assert(C.officer.setDelegated(fid,true)); clock=60; C.tactical.tick(f,clock)
local d=f.delegation; assert(#d.groups.RESERVE==200 and #d.groups.MAIN==794)
local seen={}; for _,list in pairs(d.groups) do for _,id in ipairs(list) do assert(not seen[id]); seen[id]=true end end

local reserveOperation=C.registry.operations[d.ops.RESERVE]; assert(reserveOperation.active)
local reserved={}; for _,id in ipairs(d.groups.RESERVE) do reserved[id]=true end
C.tactical.beginRecovery(f,62,'Test field army fallback')
assert(reserveOperation.active)
for _,list in ipairs({d.recovery.evacuate,d.recovery.cover}) do for _,id in ipairs(list) do assert(not reserved[id]) end end

local settings=loadModule("Settings")(C.U); assert(settings.reservePercent==20)
settings.load({reservePercent=100}); assert(settings.reservePercent==40)
settings.load({reservePercent=0}); assert(settings.reservePercent==0 and settings.save().reservePercent==0)
