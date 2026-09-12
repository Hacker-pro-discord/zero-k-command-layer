dofile(ROOT..'/tests/fixture.lua')
Spring.AreTeamsAllied=function(a,b)return a==b end
C.observations=loadModule('Observations')(C); C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C); C.input={}
assert(not C.officer.submit({approved=true,plan={},proposalID=99},{1,2}))
assert(not C.officer.submit({command=CMD.REPAIR,gesture={{1,0,1},{2,0,2}}},{1,2}))
assert(not C.officer.submit({gesture={{0/0,0,0}}},{1,2}))
assert(#calls==0)
Spring.GetModOptions=function()return {sendspringiedata='1'} end
assert(not C.officer.setSession(true)); assert(not C.officer.assign({1,2}))
Spring.GetModOptions=function()return {} end
assert(C.officer.setSession(true))
local fid=C.officer.assign({1,2}); C.officer.objective(fid,{{1000,0,2400},{1500,0,2400}})
local pid=C.advisor.ask(fid,true); units[1].x=units[1].x+200
assert(not C.proposals.approve(pid,1) and #calls==0)
pid=C.advisor.ask(fid,true); Spring.GetUnitHealth=function()return 20,100 end
assert(not C.proposals.approve(pid,1) and #calls==0)
Spring.GetUnitHealth=function()return 100,100 end
pid=C.advisor.ask(fid,true); local op=C.proposals.approve(pid,1); assert(op)
C.registry.release({1,2},'PLAYER_OVERRIDE'); clock=clock+1; C.officer.update()
assert(C.registry.operations[op].state=='PLAYER_OVERRIDE' and not C.registry.forces[fid].objectiveReached)
C.registry.forces[fid].objectiveReached=true; C.officer.objective(fid,{{1000,0,2500},{1500,0,2500}})
assert(not C.registry.forces[fid].objectiveReached)
C.settings.override='suspend'; fid=C.officer.assign({1,2}); C.registry.release({1},'PLAYER_OVERRIDE')
assert(#C.officer.members(C.registry.forces[fid])==1); C.officer.resume(fid); assert(#C.officer.members(C.registry.forces[fid])==2)
local before=#calls; C.officer.setSession(false); assert(#calls==before)

for i=1,60 do assert(C.orders.budget()) end; assert(not C.orders.budget()); clock=clock+1; assert(C.orders.budget())
