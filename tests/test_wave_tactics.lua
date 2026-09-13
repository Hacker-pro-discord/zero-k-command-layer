dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.productionControl=loadModule('ProductionController')(C); C.startup=loadModule('Startup')(C)
assert(loadModule('Settings')(C.U).defaultTactic=='WAVE TACTICS')
C.settings.defaultTactic='WAVE TACTICS'
C.settings.privateSession=true
local team={1}; Spring.GetTeamUnits=function() return team end
assert(C.startup.start()); C.tactical.update()
local f=C.registry.forces[C.registry.activeForce]
assert(f.objectiveMode=='WIN THE GAME' and f.tactic=='WAVE TACTICS')
local main=C.registry.owner[1]; assert(main)
team={1,2}; clock=12; C.startup.update(); C.tactical.update()
assert(not C.registry.owner[2]) -- lone recruit waits for cohort, not immediate trickle
clock=24; C.tactical.update()
assert(C.registry.owner[2] and C.registry.owner[2]~=main)
assert(C.registry.owner[1]==main and f.delegation.waveNumber==2)
team={1,2,3}; clock=26; C.startup.update(); C.tactical.update()
assert(#f.delegation.groups.SCOUT==1) -- scout already at three units
C.officer.releaseUnits({3},'PLAYER_OVERRIDE')
clock=40; C.startup.update(); C.tactical.update()
assert(not f.members[3] and not C.registry.owner[3])
assert(C.officer.setTactic('CONTINUOUS PRESSURE'))
assert(f.tactic=='CONTINUOUS PRESSURE' and C.settings.save().defaultTactic==f.tactic)
assert(not C.officer.setTactic('INVALID'))
C.officer.setDelegated(f.id,false); local n=#calls
clock=60; C.startup.update(); C.tactical.update(); assert(#calls==n)
-- Factory controls go through the Officer, do not clear busy queues.
UnitDefs[2]={name='factory',isFactory=true,isBuilder=true,buildOptions={1},speed=0}
units[20]={x=1000,z=1000,team=0,def=2}; queues[20]={{id=-1,params={},tag=100}}
assert(C.officer.factoryControl('ENROLL',{20}))
assert(C.productionControl.factories[20] and #queues[20]==1)
assert(C.officer.factoryControl('RELEASE',{20}))
assert(not C.productionControl.factories[20] and C.productionControl.excluded[20] and #queues[20]==1)
C.settings.privateSession=false; assert(not C.officer.factoryControl('ENROLL',{20}))
