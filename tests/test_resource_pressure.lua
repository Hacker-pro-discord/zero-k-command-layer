dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
C.observations={snapshot=function() return {contacts={}} end,nearCombat=function() return false end}
C.input={}; C.proposals=loadModule('ProposalService')(C); C.rules=loadModule('TacticalRules')(C)
C.tactical=loadModule('TacticalController')(C)
local fid=C.officer.assign({1,2,3,4,5,6}); local f=C.registry.forces[fid]; f.mapControl=true
assert(C.officer.setDelegated(fid,true))
WG.metalSpots={{x=2000,y=0,z=2000},{x=3500,y=0,z=2000},{x=5000,y=0,z=2000}}
UnitDefs[2]={name='mex',speed=0,isBuilding=true,customParams={metal_extractor_mult='1'}}
units[30]={x=2000,z=2000,team=0,def=2}
Spring.GetTeamUnits=function() return {1,2,3,4,5,6,30} end
local p,kind=C.mapControl.choose(f,'MAIN',{1,2,3},{},10)
assert(kind=='SECURE RESOURCE' and p[1]==3500,'Claimable public nodes take precedence over generic squares; own mex skipped')
local raid=C.mapControl.choose(f,'RAID',{4,5},{},12)
assert(raid[1]==5000,'Detachments must spread between resource nodes')
UnitDefs[3]={name='fort',metalCost=5000,maxWeaponRange=800,speed=0,isBuilding=true}
local danger={{id=99,position={3500,0,2000},visibility='VISUAL',defID=3,role='OTHER'}}
p=C.mapControl.choose(f,'MAIN',{1,2,3},danger,100)
assert(C.U.distance(p,danger[1].position)>650,'Observed overwhelming defense redirects resource pressure')
-- Remote sightings do not continually cancel an otherwise progressing resource march.
local op={id=90,active=true,created=100,units={1,2,3},slots={[1]={3500,0,2000},[2]={3500,0,2100},[3]={3500,0,2200}}}
local cancelled=false; C.officer.cancel=function() cancelled=true end
C.mapControl.review(f,'MAIN',{1,2,3},op,{{visibility='VISUAL',position={7000,0,7000}}},114)
assert(not cancelled)
C.mapControl.review(f,'MAIN',{1,2,3},op,{},161); assert(cancelled,'Quiet stalled mission gets bounded replanning')

-- Defense catches destruction between samples, without refreshing its own incident forever.
C.recovery={sites={{point={1200,0,1200},lastThreat=clock}},threat=function() error('Synthetic incident must not refresh itself') end,hold=function() return false end}
C.settings.reservePercent=20
local function makePlan(_,ids,target) local slots={}; for _,id in ipairs(ids) do slots[id]=target end; return {slots=slots,units=ids,center=target,origin=target,front={0,1},gesture={target},zones={}} end
C.officer.executeDelegated=function() return nil end
C.defense.tick(f,10,makePlan); assert(f.delegation.defense.threat)
C.defense.tick(f,50,makePlan); assert(not f.delegation.defense.threat,'Incident eventually clears')

-- Main-force recovery does not cancel or absorb map-control scouts/raiders.
dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
C.observations={snapshot=function() return {contacts={}} end,nearCombat=function() return false end}; C.input={}
C.proposals=loadModule('ProposalService')(C); C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
local fid=C.officer.assign({1,2,3,4,5,6,7,8,9,10}); local f=C.registry.forces[fid]; f.mapControl=true
assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
local d=f.delegation; local scout=C.registry.operations[d.ops.SCOUT]; local raid=C.registry.operations[d.ops.RAID]
assert(scout and raid and scout.active and raid.active)
C.tactical.beginRecovery(f,clock,'Field loss'); assert(scout.active and raid.active)
local detached={}; for _,g in ipairs({'SCOUT','RAID'}) do for _,id in ipairs(d.groups[g]) do detached[id]=true end end
for _,g in ipairs({d.recovery.evacuate,d.recovery.cover}) do for _,id in ipairs(g) do assert(not detached[id]) end end
C.officer.cancel(scout.id); scout.accounted=true; d.next.SCOUT=0
clock=12; C.tactical.tick(f,clock)
assert(d.recovery and d.ops.SCOUT~=scout.id and C.registry.operations[d.ops.SCOUT].active,'Scout receives another mission during main recovery')
