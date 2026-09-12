dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
C.observations=loadModule('Observations')(C)
Spring.GetTeamResources=function(_,kind) return 500,1000,0,kind=='energy' and 17 or 6,0 end
Spring.GetTeamRulesParam=function(_,key) return ({OD_energyIncome=45,OD_energyChange=16})[key] end
local economy=C.observations.economy()
assert(economy.energy.income==46 and economy.energy.nativeIncome==17,'Use the native economy panel accounting, not post-overdrive transfers')

local fid=C.officer.ensureForce().id; C.settings.autoAssign=true
C.registry.born(1); assert(C.officer.autoAssign(1,fid))
C.officer.releaseUnits({1}); assert(not C.officer.autoAssign(1,fid),'Live manual exclusion persists')
local previous=C.registry.generation[1]
C.economy={excluded={[1]=true},workers={},tasks={}}
C.registry.born(1); assert(C.registry.generation[1]>previous and not C.economy.excluded[1])
assert(C.officer.autoAssign(1,fid),'A newly created lifetime may auto-recruit')
assert(C.registry.owner[1]==nil,'Creation does not revive an old operation')

UnitDefs[2]={name='builder',isBuilder=true,speed=40,metalCost=120,buildOptions={3}}
UnitDefs[3]={name='factorycloak',isFactory=true,isBuilder=true,metalCost=600,buildOptions={1,2}}
UnitDefNames={factorycloak={id=3}}
units[20]={def=2,team=0,x=1000,z=1000}; units[30]={def=3,team=0,x=1200,z=1000}
local team={1,20,30}; Spring.GetTeamUnits=function() return team end; Spring.GetFactoryCommands=function(id) return queues[id] or {} end
C.economy=loadModule('Economy')(C); C.economy.enroll({20})
assert(C.economy.workerNeed()==0,'First five combat units take precedence over extra economic workers')
team={1,2,3,4,5,20,30}; assert(C.economy.workerNeed()==1)
C.recovery=loadModule('Recovery')(C); assert(C.recovery.enroll({20}))
assert(C.recovery.workers[20] and not C.economy.workers[20],'Builder services cannot own the same worker')
C.economy.enroll({20}); assert(C.economy.workers[20] and not C.recovery.workers[20])

-- With income but less than full unit cost, controlled economy can fund one native queue.
UnitDefs[4]={name='heavy',iconType='kbotassault',speed=40,metalCost=500,maxWeaponRange=300}
UnitDefs[3].buildOptions={4}; C.productionControl=loadModule('ProductionController')(C)
C.observations.snapshot=function() return {contacts={},composition={}} end
C.observations.economy=function() return {metal={current=200,income=10},energy={current=500}} end
C.recovery=nil; C.economy.workerNeed=function() return 0 end
C.productionControl.set(true); C.productionControl.update()
assert(calls[#calls].id==30 and calls[#calls].cmd==-4,'Native streaming prevents expensive roles from permanent affordability starvation')
assert(#queues[30]==1,'One production decision must enqueue exactly one unit under native factory modifier semantics')
local count=#calls; clock=20; C.productionControl.update(); assert(#calls==count,'Occupied factory queue is preserved')

-- A native storage cap must not deadlock recovery or reserve the entire economy.
C.recovery=loadModule('Recovery')(C); C.recovery.enroll({20})
C.observations.economy=function() return {metal={current=250,storage=500,income=6},energy={current=300}} end
Spring.TestBuildOrder=function() return 2 end
assert(C.recovery.request(3,{1700,0,1300},0,{20}))
assert(C.recovery.reserveMetal()==100 and C.recovery.reserveMetal()<500)
clock=50; C.recovery.update(); assert(calls[#calls].id==20 and calls[#calls].cmd==-3)
Spring.GetPositionLosState=function() return false end
assert(C.recovery.reserveMetal()==0,'Unsurveyed reconstruction cannot freeze all production')
