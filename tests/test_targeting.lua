dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; Spring.AreTeamsAllied=function(a,b) return a==b end
C.settings.privateSession=true; C.input={}
UnitDefs[2]={name='conjurer',speed=50,isBuilder=true,metalCost=120,buildOptions={}}
UnitDefs[3]={name='mex',speed=0,isBuilding=true,metalCost=75,customParams={metal_extractor_mult='1'}}
UnitDefs[4]={name='turret',speed=0,isBuilding=true,metalCost=100,maxWeaponRange=400}
for id=101,104 do units[id]={x=1200+(id-101)*10,z=1000,def=id==101 and 2 or id==102 and 3 or id==103 and 4 or 1,team=1} end
C.rules=loadModule('TacticalRules')(C); C.targeting=loadModule('Targeting')(C)
local function contact(id) return {id=id,defID=units[id].def,visibility='VISUAL',time=clock,position=C.U.position(id),role=C.classify.definition(units[id].def).role} end
local support,mex,turret,other=contact(101),contact(102),contact(103),contact(104)
local target,why=C.targeting.choose({1,2,3,4},{other,mex,support},'MAIN')
assert(target.id==101 and why:find('repair%-capable'))
local mf={delegation={sector={corridor={{0,0,0},{8000,0,0},{8000,0,8000},{0,0,8000}}}}}
local point,kind,reason=C.mapControl.choose(mf,'MAIN',{1,2,3,4},{other,mex,support},clock)
assert(kind=='ATTACK CONTACT' and mf.mapState.missions.MAIN.target==101)
target=C.targeting.choose({1,2,3,4},{other,mex},'MAIN'); assert(target.id==102)
turret.recentAttacker=true; target,why=C.targeting.choose({1,2,3,4},{support,mex,turret},'MAIN'); assert(target.id==103 and why:find('damaged'))
local radar={id=103,position=turret.position,visibility='RADAR',role='UNKNOWN'}
assert(not C.targeting.score(radar,{1000,0,1000},'MAIN'))
-- Native priority commands do not touch the movement queue.
local set,cancel=34923,34924; Spring.Utilities.CMD.UNIT_SET_TARGET=set; Spring.Utilities.CMD.UNIT_CANCEL_TARGET=cancel
local targetState={}; Spring.FindUnitCmdDesc=function() return 1 end
Spring.GetUnitRulesParam=function(id,key) local t=targetState[id]; if key=='target_type' then return t and 2 or 0 elseif key=='target_id' then return t end end
local original=Spring.GiveOrderToUnit
Spring.GiveOrderToUnit=function(id,cmd,p,o) if cmd==set or cmd==cancel then calls[#calls+1]={id=id,cmd=cmd,p=p}; targetState[id]=cmd==set and p[1] or nil; return true end; return original(id,cmd,p,o) end
local f={id=1,members={[1]=true},suspended={},revision=1,delegation={active=true,token=1,blocked={},sector={corridor={{0,0,0},{8000,0,0},{8000,0,8000},{0,0,8000}}}}}; C.registry.forces[1]=f
local op=C.registry.newOperation({1}); op.forceID=1; op.grant=1
queues[1]={{id=CMD.FIGHT,params={5000,0,1000},tag=77}}
assert(C.officer.focusTarget(op,1,support))
assert(targetState[1]==101 and queues[1][1].tag==77)
local n=#calls; support.visibility='RADAR'; assert(not C.officer.focusTarget(op,1,support) and #calls==n); support.visibility='VISUAL'
Spring.GetUnitLosState=function(id) return {los=id~=101} end
C.orders.updateFocus(); assert(not targetState[1] and queues[1][1].tag==77)
Spring.GetUnitLosState=function() return {los=true} end
assert(C.officer.focusTarget(op,1,support))
f.delegation.active=false; C.registry.finish(op,'CANCELLED'); assert(not targetState[1] and not C.orders.focus[1])
-- Manual priority targets are neither replaced nor removed.
f.delegation.active=true; op=C.registry.newOperation({1}); op.forceID=1; op.grant=1
targetState[1]=104; assert(not C.officer.focusTarget(op,1,support)); C.registry.release({1},'PLAYER_OVERRIDE'); assert(targetState[1]==104)
-- Visible-only repair observation; never inspect a radar-only builder's work.
C.observations=loadModule('Observations')(C)
Spring.GetAllUnits=function() return {101,102,103} end
Spring.GetUnitLosState=function(id) return {los=id~=103,radar=true} end
local inspected={}; Spring.GetUnitIsBuilding=function(id) inspected[id]=true; return 102 end
Spring.GetUnitHealth=function() return 50,100,0,0,1 end
C.observations.damaged(1,103); assert(not C.observations.attacks[103])
C.observations.update(true)
assert(inspected[101] and not inspected[103])
local snap=C.observations.snapshot(); for _,v in ipairs(snap.contacts) do if v.id==101 then assert(v.repairing) elseif v.id==103 then assert(not v.defID and not v.repairing) end end
