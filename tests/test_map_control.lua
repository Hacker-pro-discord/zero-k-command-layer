dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
Spring.GetFactoryCommands=function() return {} end
Spring.GetPositionLosState=function() return false end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.productionControl=loadModule('ProductionController')(C); C.startup=loadModule('Startup')(C)
-- Pregame PlayerChanged revocation must not consume the future startup.
local frame=Spring.GetGameFrame; Spring.GetGameFrame=function() return -1 end
C.startup.stop(); assert(not C.startup.booted); Spring.GetGameFrame=frame
-- Automatic local boot has no selection/line/approval prerequisite.
C.startup.boot(); local f=C.registry.forces[1]
assert(f and f.mapControl and C.productionControl.enabled and f.delegation.active)
C.tactical.update(); assert(C.registry.owner[1])
local opposite={7400,0,7400}
assert(C.formations.inCorridor(f.delegation.sector,opposite))
-- Scouts progressively cover both halves of the map, not eight line points.
local seen,west,east,north,south={},false,false,false,false
for i=1,25 do
	local p=C.mapControl.choose(f,'SCOUT',{1},{},clock+i)
	assert(p); seen[p[1]..':'..p[3]]=true
	west=west or p[1]<4000; east=east or p[1]>4000
	north=north or p[3]<4000; south=south or p[3]>4000
end
local count=0; for _ in pairs(seen) do count=count+1 end
assert(count>=20 and west and east and north and south)
-- A visual enemy outside the old initial approach becomes an attack objective.
local contacts={{id=90,position=opposite,visibility='VISUAL',defID=1,role='RAIDER'}}
local p,kind=C.mapControl.choose(f,'MAIN',{1,2},contacts,clock+30)
assert(kind=='ATTACK CONTACT' and C.U.distance(p,opposite)==0)
contacts[1].visibility='RADAR'; contacts[1].defID=nil; contacts[1].role='UNKNOWN'
p,kind=C.mapControl.choose(f,'MAIN',{1,2},contacts,clock+32)
assert(kind~='ATTACK CONTACT')
-- Arrival or a no-combat timeout permits a fresh objective, without another approval.
local op=C.registry.operations[f.delegation.ops.MAIN]; assert(op)
-- A native empty queue is retryable; a changed nonempty queue stays protected.
local ended,changed=op.units[1],op.units[2]
queues[ended]={}; queues[changed]={{id=CMD.MOVE,params={7000,0,7000}}}
clock=clock+6; C.officer.update()
assert(type(f.delegation.blocked[ended])=='number')
assert(f.delegation.blocked[changed]==true)
C.mapControl.review(f,'MAIN',op.units,op,{},op.created+61)
assert(not op.active and f.delegation.next.MAIN==op.created+61)
local callsBefore=#calls; C.startup.stop(); C.officer.cancelAll(); C.productionControl.set(false)
C.startup.boot(); assert(#calls==callsBefore and not C.startup.enabled)
-- Player-drawn objectives revoke map-wide authority.
C.officer.objective(f.id,{{1000,0,6000},{2500,0,6000}})
assert(not f.mapControl)
assert(C.officer.setDelegated(f.id,true))
assert(C.startup.start() and f.mapControl and f.objective==nil)
assert(C.formations.inCorridor(f.delegation.sector,opposite))
C.officer.cancelAll(); C.productionControl.set(false)
-- Automatic boot never enters a multiplayer session.
C.startup=loadModule('Startup')(C); C.settings.privateSession=false
Spring.GetPlayerList=function() return {0,1} end
C.startup.boot(); assert(not C.startup.enabled and not C.settings.privateSession)
