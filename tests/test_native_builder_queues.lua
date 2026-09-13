dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
Spring.Utilities.CMD.RAW_BUILD=31110 -- Fixture constant; production resolves the installed command table.
UnitDefs[2]={name='cloakcon',isBuilder=true,speed=40,metalCost=120,buildOptions={3}}
UnitDefs[3]={name='energysolar',isBuilding=true,metalCost=70,energyMake=2}
units[20]={x=1000,z=1000,team=0,def=2}; units[30]={x=4000,z=1000,team=0,def=3}
Spring.GetTeamUnits=function() return {1,2,3,4,5,20,30} end
C.observations={nearCombat=function() return false end,snapshot=function() return {contacts={}} end,economy=function() return {metal={current=500,income=10},energy={current=500,income=20}} end}
Spring.TestBuildOrder=function() return 2 end
C.recovery=loadModule('Recovery')(C); local r=C.recovery; r.enroll({20}); r.request(3,{5000,0,1000},0)
clock=12; r.update(); assert(r.tasks[20].cmd==-3)
local base=queues[20][1]; local wrapper={id=Spring.Utilities.CMD.RAW_BUILD,params={5000,0,1000,128,30},tag=999}
queues[20]={wrapper,base}
clock=14; r.update(); assert(r.workers[20] and not r.excluded[20],'Native approach does not release recovery ownership')
clock=51; r.update(); assert(calls[#calls].cmd==CMD.REMOVE and calls[#calls].p[1]==base.tag,'Stall removes only the owned build, not an arbitrary wrapper tag')
assert(r.workers[20] and not r.excluded[20])
-- Wrong coordinates or an unrelated command in second place are not native authority.
local task={cmd=-3,params={5000,0,1000,0}}
queues[20]={wrapper,{id=CMD.MOVE,params={5000,0,1000},tag=800}}
assert(not C.nativeQueue.current(20,task))
queues[20]={wrapper,base}; wrapper.params[1]=6000; assert(not C.nativeQueue.current(20,task)); wrapper.params[1]=5000
queues[20]={{id=CMD.MOVE,params={5153,0,1000},options={internal=true},tag=810},base}
assert(C.nativeQueue.current(20,task),'Engine internal clearance move preserves the underlying build')
queues[20][1].options.internal=false; assert(not C.nativeQueue.current(20,task),'Ordinary player move is not a native build wrapper')
queues[20][1].options.internal=true; queues[20][1].params[1]=7000; assert(not C.nativeQueue.current(20,task),'Unrelated internal movement is not accepted')
-- Static repair and visible feature reclaim use the same stock approach wrapper.
wrapper.params[1]=4000; queues[20]={wrapper,{id=CMD.REPAIR,params={30},tag=800}}
assert(C.nativeQueue.current(20,{cmd=CMD.REPAIR,params={30}}))
Game.maxUnits=32000; Spring.GetFeaturePosition=function() return 4000,0,1000 end
queues[20]={wrapper,{id=CMD.RECLAIM,params={32007},tag=801}}
assert(C.nativeQueue.current(20,{cmd=CMD.RECLAIM,params={32007}}))
Spring.GetPositionLosState=function() return false end
assert(not C.nativeQueue.current(20,{cmd=CMD.RECLAIM,params={32007}}))
Spring.GetPositionLosState=function() return true end
-- Economy recognizes the same wrapper and keeps stalled workers enrolled.
C.economy=loadModule('Economy')(C); local e=C.economy; e.enroll({20}); e.tasks[20]=task; task.key='test solar'; task.time=clock; task.progress=clock
wrapper.params[1]=5000; queues[20]={wrapper,base}; clock=53; e.update(); assert(e.workers[20])
clock=90; e.update(); assert(e.workers[20] and calls[#calls].cmd==CMD.REMOVE)

-- Idle automatic recovery workers lend to economy; explicitly assigned workers stay put.
C.economy={enabled=true,workers={},excluded={},release=function(id) C.economy.workers[id]=nil; C.economy.excluded[id]=true end}
r=loadModule('Recovery')(C); C.recovery=r; queues[20]={}; r.enroll({20},true)
clock=100; r.update(); clock=116; r.update()
assert(C.economy.workers[20] and not r.workers[20] and not C.economy.excluded[20])
clock=118; r.update(); assert(not r.workers[20],'Loan cooldown prevents ownership ping-pong')
r.enroll({20}); clock=120; r.update(); clock=140; r.update(); assert(r.workers[20] and not C.economy.workers[20])
r.release(20); e.release(20); clock=160; r.update(); assert(not r.workers[20],'Manual release stays permanent')

-- Native retreat is temporary; it must not turn into a permanent combat block.
dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
C.observations={snapshot=function() return {contacts={}} end,nearCombat=function() return false end}; C.input={}
C.proposals=loadModule('ProposalService')(C); C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
local fid=C.officer.assign({1,2,3,4}); local f=C.registry.forces[fid]; f.mapControl=true; assert(C.officer.setDelegated(fid,true)); C.tactical.tick(f,clock)
Spring.GetUnitRulesParam=function(id,key) if id==1 and key=='retreat' then return 1 end end
clock=11; C.officer.update(); assert(type(f.delegation.blocked[1])=='number' and f.members[1])
local mark=#calls; clock=20; C.tactical.tick(f,clock); for i=mark+1,#calls do assert(calls[i].id~=1) end
Spring.GetUnitRulesParam=function() return nil end
for _,op in pairs(C.registry.operations) do C.officer.cancel(op.id); op.accounted=true end
f.delegation.next.MAIN=0; clock=22; C.tactical.tick(f,clock); assert(C.registry.owner[1],'Healed unit returns to army control')

-- Constructor native retreat drains its native queue before resuming tasks.
local service={tasks={[2]={cmd=-3}},workers={[2]=true}}
Spring.GetUnitRulesParam=function(id,key) if id==2 and key=='retreat' then return 1 end end
assert(C.nativeQueue.paused(service,2))
Spring.GetUnitRulesParam=function() return nil end; queues[2]={{id=CMD.MOVE,params={1000,0,1000}}}
assert(C.nativeQueue.paused(service,2))
queues[2]={}; assert(not C.nativeQueue.paused(service,2) and not service.tasks[2] and service.workers[2])
-- The stock Move-to-RawMove substitution retains an identical destination.
local operation=C.officer.submit({gesture={{1000,0,3000},{1800,0,3000}},command=CMD.MOVE},{1,2})
local op=C.registry.operations[operation]; assert(op)
for _,id in ipairs(op.units) do queues[id]={{id=Spring.Utilities.CMD.RAW_MOVE,params=op.slots[id]}} end
clock=24; C.officer.update(); assert(op.active)
clock=30; C.officer.update(); assert(op.active,'Native movement replacement does not lose order ownership')
