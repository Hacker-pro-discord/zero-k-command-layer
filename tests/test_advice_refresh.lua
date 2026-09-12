dofile(ROOT..'/tests/fixture.lua')
Spring.AreTeamsAllied=function(a,b) return a==b end
local visible={}
Spring.GetAllUnits=function() return visible end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.settings.privateSession=true
local fid=C.officer.assign({1,2,3,4})
C.officer.objective(fid,{{1000,0,2000},{1800,0,2000}})
local old=C.advisor.ask(fid,true)
UnitDefs[2]={name='visibleRiot',speed=60,iconType='kbotriot',metalCost=250,maxWeaponRange=300}
units[20]={x=1400,z=2200,team=1,def=2}; units[21]={x=1500,z=2200,team=1,def=2}
visible={20,21}; clock=16
C.proposals.update(); assert(C.proposals.items[old].state=='INVALIDATED')
C.advisor.update()
local fresh=C.proposals.firstOffered()
assert(fresh.id~=old and fresh.state=='OFFERED' and fresh.reason:find('Widened spacing'))
assert(#calls==0 and not C.proposals.approve(old,1))
assert(C.proposals.approve(fresh.id,fresh.revision) and #calls==4)
