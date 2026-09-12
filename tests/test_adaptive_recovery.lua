dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.settings.privateSession=true
local fid=C.officer.assign({1,2,3,4,5}); local f=C.registry.forces[fid]
C.officer.objective(fid,{{900,0,5000},{2600,0,5000}})
assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
assert(#calls==5 and #f.delegation.groups.SCOUT==1 and #f.delegation.groups.MAIN==4)
local old=C.registry.operations[f.delegation.ops.MAIN]; assert(old.command==CMD.FIGHT)
local proposals=C.proposals.nextID; local before=#calls
clock=71; C.tactical.tick(f,clock)
local d=f.delegation; assert(d.active and d.recovery.phase=='WITHDRAWING' and #calls==before+5)
assert(d.strategy.step==390 and d.strategy.side~=0 and d.strategy.spacing>C.settings.spacing)
for i=before+1,#calls do assert(calls[i].cmd==Spring.Utilities.CMD.RAW_MOVE) end
local function arrive()
 local op=C.registry.operations[d.recovery.operation]; assert(op and op.active)
 for _,id in ipairs(op.units) do if f.members[id] then units[id].x=op.slots[id][1]; units[id].z=op.slots[id][3] end end
 clock=clock+1; C.officer.update(); C.tactical.tick(f,clock)
end
-- A released scout never returns through regroup/reassignment.
C.registry.release({1},'PLAYER_OVERRIDE'); local mark=#calls
arrive(); assert(d.recovery.phase=='HOLDING') -- operation reports player override: bounded retry, not reacquisition
clock=clock+21; C.tactical.tick(f,clock); assert(d.recovery.operation)
arrive(); assert(d.recovery.phase=='HOLDING' and d.recovery.ready)
clock=clock+9; C.tactical.tick(f,clock); assert(not d.recovery and d.active)
clock=clock+2; C.tactical.tick(f,clock)
local nextOp=C.registry.operations[d.ops.MAIN]; assert(nextOp and nextOp.active and nextOp.command==CMD.FIGHT)
assert(C.rules.progress(d.sector,nextOp.plan.center)<math.max(0,C.rules.progress(d.sector,C.U.center(C.officer.members(f))))+400)
for i=mark+1,#calls do assert(calls[i].id~=1) end
assert(C.proposals.nextID==proposals)
-- Low health delays a retry even after geometry arrives; no per-tick order spam.
Spring.GetUnitHealth=function() return 30,100,0,0,1 end
C.tactical.beginRecovery(f,clock,'Test injury'); C.tactical.recoveryTick(f,clock)
arrive(); clock=clock+4; C.tactical.tick(f,clock); arrive()
local waiting=#calls; clock=clock+25; C.tactical.tick(f,clock)
assert(d.recovery and d.recovery.phase=='HOLDING' and #calls==waiting)
Spring.GetUnitHealth=function() return 90,100,0,0,1 end
clock=clock+21; C.tactical.tick(f,clock); assert(not d.recovery and d.active)
C.officer.setDelegated(fid,false); before=#calls; clock=clock+80; C.tactical.tick(f,clock); assert(#calls==before)
-- A retreat keeps the artillery on the rear side of the original front.
UnitDefs[2]={name='arty',iconType='kbotarty',speed=40,metalCost=500,xsize=2,zsize=2,maxWeaponRange=1000}
units[5].def=2; for id=2,5 do units[id].x=1300+id*64; units[id].z=2200 end
local second=C.officer.assign({2,3,4,5}); local force=C.registry.forces[second]
C.officer.objective(second,{{900,0,5000},{2600,0,5000}}); assert(C.officer.setDelegated(second,true))
for id=2,5 do units[id].z=3200 end
C.tactical.beginRecovery(force,clock,'Role-facing test'); C.tactical.recoveryTick(force,clock)
local retreat=C.registry.operations[force.delegation.recovery.operation]; assert(retreat)
assert(C.rules.progress(force.delegation.sector,retreat.slots[5])<C.rules.progress(force.delegation.sector,retreat.slots[2])-250)
-- Known resistance on the left selects the right lane; no hidden targets needed.
local sector=force.delegation.sector
local contact=C.rules.point(sector,C.rules.progress(sector,C.U.center(C.officer.members(force)))+300,-sector.half*.4)
C.observations.snapshot=function() return {contacts={{visibility='VISUAL',defID=2,role='ARTILLERY',position=contact}}} end
C.tactical.beginRecovery(force,clock,'Observed left resistance')
assert(force.delegation.strategy.side==1)
-- Four of five arrivals allow recovery to progress without overwriting a straggler each tick.
local third=C.officer.assign({1,2,3,4,5}); local regroup=C.registry.forces[third]
C.officer.objective(third,{{900,0,5000},{2600,0,5000}}); assert(C.officer.setDelegated(third,true))
C.tactical.beginRecovery(regroup,clock,'Straggler threshold'); C.tactical.recoveryTick(regroup,clock)
local stage=C.registry.operations[regroup.delegation.recovery.operation]; assert(stage)
for i,id in ipairs(stage.units) do units[id].x=stage.slots[id][1]; units[id].z=stage.slots[id][3]+(i==5 and 1000 or 0) end
before=#calls; clock=clock+1; C.tactical.recoveryTick(regroup,clock)
assert(regroup.delegation.recovery.phase=='REFORMING' and #calls==before)
