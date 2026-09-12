dofile(ROOT..'/tests/fixture.lua')
CMD.ATTACK=20; CMD.STOCKPILE=100
Spring.GetPlayerList=function() return {0} end; Spring.AreTeamsAllied=function(a,b) return a==b end
C.settings.privateSession=true
WeaponDefs={[1]={stockpile=true,range=10000,damageAreaOfEffect=960,interceptor=0}}
UnitDefs[2]={name='staticnuke',humanName='Trinity',metalCost=8000,customParams={is_nuke='1',stockpilecost='3240'},weapons={{weaponDef=1}}}
UnitDefs[3]={name='enemy',metalCost=4000,customParams={}}
units[20]={def=2,team=0,x=1000,z=1000}; units[30]={def=3,team=1,x=5000,z=5000}
local ready,queued=1,0; local sight=true
Spring.GetUnitStockpile=function() return ready,queued end
Spring.GetUnitLosState=function(id) return {los=id~=30 or sight,radar=true} end
Spring.GetTeamUnits=function() return {20} end
Spring.GetAllUnits=function() return {20,30} end
C.observations=loadModule('Observations')(C); C.arsenal=loadModule('Arsenal')(C)
local native=Spring.GiveOrderToUnit
Spring.GiveOrderToUnit=function(id,cmd,p,o)
 local ok=native(id,cmd,p,o); if cmd==CMD.REMOVE then queues[id]={} end
 if C.orders.event(id,cmd,p,false) then C.arsenal.issued(id,cmd,p,#calls) end
 return ok
end
C.arsenal.update(); assert(#calls==0,'No implicit launcher authorization')
assert(C.arsenal.enroll({20})==1); C.arsenal.update(); assert(#calls==1 and calls[1].cmd==CMD.ATTACK)
clock=11; C.arsenal.update(); assert(#calls==1,'One outstanding shot')
ready=0; clock=12; C.arsenal.update(); assert(calls[2].cmd==CMD.REMOVE and calls[3].cmd==CMD.STOCKPILE,'Remove stale attack before replenishing native ammo')
queues[20]={}; ready=1; sight=false; clock=45; C.arsenal.update(); assert(#calls==3,'Radar-only target must not fire')
sight=true; units[31]={def=1,team=0,x=5000,z=5000}; Spring.GetAllUnits=function() return {20,30,31} end
clock=47; C.arsenal.update(); assert(#calls==3,'Friendly splash exclusion')
units[31].x=1000; units[31].z=1000; clock=49; C.arsenal.update(); assert(#calls==4)
local tag=C.arsenal.shots[20].tag; queues[20]={{id=CMD.ATTACK,params={6000,0,6000},tag=tag+100}}
C.arsenal.release(20); assert(#calls==4,'Manual replacement queue must remain intact')
queues[20]={}; clock=90; C.arsenal.update(); assert(#calls==4,'Manual exclusion persists')
C.arsenal.enroll({20}); C.arsenal.update(); clock=92; C.arsenal.update(); assert(#calls==5)
C.arsenal.stop(); assert(calls[6].cmd==CMD.REMOVE); clock=100; C.arsenal.update(); assert(#calls==6)
-- Authority changes during a widget order callback defeat dispatch.
C.arsenal.enroll({20}); C.arsenal.reservations={}; widgetHandler.UnitCommandNotify=function() C.arsenal.enabled=false; return false end
clock=140; C.arsenal.update(); assert(#calls==6)
-- Silo build queues use the factory API: an empty movement queue is not idle production.
widgetHandler.UnitCommandNotify=function() return false end
UnitDefs[4]={name='staticmissilesilo',isFactory=true,customParams={missile_silo_capacity='4'},buildOptions={5}}
UnitDefs[5]={name='tacnuke',humanName='Eos',metalCost=600,weapons={{weaponDef=2}}}
WeaponDefs[2]={range=3500,damageAreaOfEffect=192,interceptor=0}
units[40]={def=4,team=0,x=2000,z=2000}; units[41]={def=5,team=0,x=3000,z=3000}
local factoryQueue={{id=-5,params={}}}
Spring.GetFactoryCommands=function() return factoryQueue end
Spring.GetTeamUnits=function() return {40,41} end
Spring.GetUnitRulesParam=function(id,k) if id==41 and k=='missile_parentSilo' then return 40 end end
assert(C.arsenal.enroll({40})==1); clock=150; C.arsenal.update(); assert(#calls==7 and calls[7].id==41 and calls[7].cmd==CMD.ATTACK)
C.arsenal.release(40); assert(calls[8].cmd==CMD.REMOVE,'Parent release clears child attack')
queues[41]={}; factoryQueue={}; C.arsenal.enroll({40}); clock=190; C.arsenal.update(); assert(calls[9].id==40 and calls[9].cmd==-5)
factoryQueue={{id=-5,params={}}}; local count=#calls; clock=191; C.arsenal.update(); assert(#calls==count,'Busy silo must not reset native construction')

-- The shared Release button/API also revokes non-formation services.
C.officer.releaseUnits({40},'PLAYER_OVERRIDE'); assert(not C.arsenal.enrolled[40])
