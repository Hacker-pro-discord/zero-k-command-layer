dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.settings.privateSession=true
local ids={}
for id=1,400 do units[id]={x=3000+(id%20)*32,z=1000+math.floor(id/20)*32,def=1,team=0}; ids[#ids+1]=id end
local fid=C.officer.assign(ids); local f=C.registry.forces[fid]
C.officer.objective(fid,{{2000,0,6500},{5000,0,6500}})
assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
local main=C.registry.operations[f.delegation.ops.MAIN]
assert(main and #main.units==394 and main.plan.packed)
assert(#calls==400) -- No cap silently drops the back of the force.
for i,id in ipairs(main.units) do
 assert(C.formations.inCorridor(f.delegation.sector,main.slots[id]))
 for j=1,i-1 do assert(C.U.distance(main.slots[id],main.slots[main.units[j]])>=63) end
end
local count=#calls
local pid=C.advisor.ask(fid,true,true)
assert(pid and #calls==count and f.delegation.active)
local p=C.proposals.items[pid]; assert(p.wholeArmy and #p.units==400 and p.kind=='PUSH')
local approved=C.proposals.approve(pid,1)
assert(approved and not f.delegation.active and #calls==count+400)
assert(not C.proposals.approve(pid,1) and #calls==count+400)
-- Arrival ends this one action. It does not restart delegation.
local op=C.registry.operations[approved]
for _,id in ipairs(op.units) do units[id].x=op.slots[id][1]; units[id].z=op.slots[id][3] end
clock=11; C.officer.update(); assert(not op.active and f.objectiveReached)
count=#calls; clock=20; C.tactical.update(); assert(#calls==count)

-- New completions are opt-in and never expand an already offered approval.
C.officer.objective(fid,{{2000,0,7400},{5000,0,7400}})
pid=C.advisor.ask(fid,true,true); assert(pid)
units[401]={x=3100,z=2000,def=1,team=0}
assert(not C.officer.autoAssign(401))
C.settings.autoAssign=true
assert(C.officer.autoAssign(401) and f.members[401] and #calls==count)
assert(#C.proposals.items[pid].units==400 and C.proposals.valid(C.proposals.items[pid],true))
C.registry.release({401},'PLAYER_OVERRIDE'); assert(not C.officer.autoAssign(401))
assert(C.settings.save().autoAssign)

-- Prolonged stalled delegation now falls back under the existing grant, without a proposal.
C.officer.objective(fid,{{2000,0,7400},{5000,0,7400}})
assert(C.officer.setDelegated(fid,true)); clock=30; C.tactical.tick(f,clock)
count=#calls; local proposalCount=C.proposals.nextID; clock=91; C.tactical.tick(f,clock)
assert(f.delegation.active and f.delegation.recovery and f.delegation.strategy.step<600)
assert(C.proposals.nextID==proposalCount)
