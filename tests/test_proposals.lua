dofile(ROOT..'/tests/fixture.lua')
Spring.AreTeamsAllied=function(a,b)return a==b end
C.observations=loadModule('Observations')(C); C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C); C.input={}
C.settings.privateSession=true
local fid=C.officer.assign({1,2,3,4}); assert(fid and #calls==0)
C.officer.objective(fid,{{1200,0,2000},{1800,0,2000}}); assert(#calls==0)
local pid=C.advisor.ask(fid,true); assert(pid and #calls==0)
clock=71; C.proposals.update(); assert(C.proposals.items[pid].state=='EXPIRED' and #calls==0)
pid=C.advisor.ask(fid,true); C.registry.release({1},'PLAYER_OVERRIDE'); assert(not C.proposals.approve(pid,1) and #calls==0)
pid=C.advisor.ask(fid,true); local op=C.proposals.approve(pid,1); assert(op and #calls==3)
assert(not C.proposals.approve(pid,1) and #calls==3)
assert(C.registry.operations[op].active)
C.officer.cancel(op); assert(not C.registry.operations[op].active)
pid=C.advisor.ask(fid,true); C.proposals.decline(pid); assert(#calls==3)
C.settings.privateSession=false; assert(not C.officer.assign({2,3}))
