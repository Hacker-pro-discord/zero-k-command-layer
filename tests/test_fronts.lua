dofile(ROOT..'/tests/fixture.lua')
Spring.AreTeamsAllied=function(a,b) return a==b end
C.observations=loadModule('Observations')(C)
C.proposals=loadModule('ProposalService')(C)
C.advisor=loadModule('TacticalAdvisor')(C); C.input={}
C.settings.privateSession=true; C.settings.constructors=true
UnitDefs[2]={speed=80,isBuilder=true}
UnitDefs[3]={speed=160,canFly=true,maxWeaponRange=200}
UnitDefs[4]={speed=0,isBuilding=true,maxWeaponRange=400}
units[2].def=2; units[3].def=3; units[4].def=4
units[5].team=1
Spring.GetTeamUnits=function() return {1,2,3,4,5} end
local fid=C.officer.assignAll()
local f=C.registry.forces[fid]
assert(f.members[1] and f.members[3] and not f.members[2] and not f.members[4] and not f.members[5])
assert(#calls==0)
assert(C.officer.objective(fid,{{1600,0,3000},{2200,0,3000}}))
assert(C.officer.setFront(fid,'FLANK_LEFT'))
local pid=C.advisor.ask(fid,true); local p=C.proposals.items[pid]
assert(p.kind=='FLANK_LEFT' and #calls==0 and p.expires-clock==60)
local left=C.U.copy(p.plan.center)
clock=30; C.proposals.update(); assert(p.state=='OFFERED')
clock=71; C.proposals.update(); assert(p.state=='EXPIRED')
assert(C.proposals.firstOffered()==p and not C.proposals.approve(pid,1) and #calls==0)
C.advisor.update(); assert(C.proposals.nextID==pid) -- Do not replace an unread expired brief.
assert(C.officer.setFront(fid,'FLANK_RIGHT'))
pid=C.advisor.ask(fid,true); p=C.proposals.items[pid]
assert(p.kind=='FLANK_RIGHT' and C.U.distance(left,p.plan.center)>200)
assert(C.proposals.firstOffered()==p)
local opid=C.proposals.approve(pid,1)
assert(opid and #calls==2 and calls[2].id==3)
assert(not C.proposals.approve(pid,1) and #calls==2)
local op=C.registry.operations[opid]
for _,id in ipairs(op.units) do units[id].x=op.slots[id][1]; units[id].z=op.slots[id][3] end
clock=72; C.officer.update()
assert(not op.active and not f.objectiveReached) -- Approach is not the final objective.
assert(C.officer.setFront(fid,'HOLD'))
pid=C.advisor.ask(fid,true); assert(C.proposals.items[pid].kind=='REFORM' and #calls==2)
C.registry.release({1},'PLAYER_OVERRIDE')
assert(not C.proposals.approve(pid,1) and #calls==2)
C.settings.privateSession=false; assert(not C.officer.assignAll())
