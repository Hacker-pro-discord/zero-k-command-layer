dofile(ROOT..'/tests/fixture.lua')
UnitDefs[2]={name='heavy',iconType='kbotassault',speed=40,metalCost=900,xsize=4,zsize=4,maxWeaponRange=400}
UnitDefs[3]={name='arty',iconType='kbotarty',speed=30,metalCost=1200,xsize=4,zsize=4,maxWeaponRange=1000}
units[2].def=2; units[3].def=3
local health={[1]=.1,[2]=.2,[3]=.5,[4]=1,[5]=1,[6]=1}
Spring.GetUnitHealth=function(id) return (health[id] or 1)*100,100,0,0,1 end
local chosen=C.retreatPriority.select({1,2,3,4,5,6})
assert(chosen.priority[2]<chosen.priority[1] and chosen.priority[1]<chosen.priority[3])
assert(chosen.injured==3)
for _,id in ipairs(chosen.cover) do assert(id>=4) end
Spring.GetPlayerList=function() return {0} end; Spring.AreTeamsAllied=function(a,b) return a==b end; Spring.GetAllUnits=function() return {} end
C.observations=loadModule('Observations')(C); C.input={}; C.proposals=loadModule('ProposalService')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C); C.settings.privateSession=true
local fid=C.officer.assign({1,2,3,4,5,6}); local f=C.registry.forces[fid]
C.officer.objective(fid,{{900,0,5000},{2600,0,5000}}); assert(C.officer.setDelegated(fid,true))
C.tactical.beginRecovery(f,clock,'Priority test'); C.tactical.recoveryTick(f,clock)
local r=f.delegation.recovery; assert(r.phase=='EVACUATING' and r.coverOperation)
local retreat=C.registry.operations[r.operation]; assert(retreat and retreat.command==Spring.Utilities.CMD.RAW_MOVE)
local first
for _,order in ipairs(calls) do if order.cmd==Spring.Utilities.CMD.RAW_MOVE then first=first or order.id; assert(order.id~=r.cover[1]) end end
assert(first==2) -- Expensive critical unit dispatched before critical Glaive, both before healthy cover.
local before=#calls; C.registry.release({r.cover[1]},'PLAYER_OVERRIDE'); health[r.cover[2]]=.4
clock=clock+2; C.tactical.recoveryTick(f,clock)
assert(r.phase=='WITHDRAWING')
for i=before+1,#calls do assert(calls[i].id~=r.cover[1]) end
assert(C.proposals.nextID==0)
-- A displaced candidate cannot invalidate the remaining in-corridor cover.
health[5]=1; health[6]=1; units[6].x=7900
C.tactical.beginRecovery(f,clock,'Displaced cover test')
r=f.delegation.recovery
assert(r.phase=='EVACUATING' and r.coverOperation)
for _,id in ipairs(r.cover) do assert(id~=6) end
local found=false; for _,id in ipairs(r.evacuate) do if id==6 then found=true end end
assert(found)
