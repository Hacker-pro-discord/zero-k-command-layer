dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
Spring.GetAllUnits=function() return {} end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C); C.advisor=loadModule('TacticalAdvisor')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.productionControl=loadModule('ProductionController')(C); C.startup=loadModule('Startup')(C)
UnitDefs[2]={name='factory',isFactory=true,isBuilder=true,buildOptions={1},speed=0}
units[20]={x=1000,z=1000,team=0,def=2}
local team={20}; Spring.GetTeamUnits=function() return team end
assert(not C.startup.start() and #calls==0) -- No authority from persisted auto-assign.
C.settings.privateSession=true
C.settings.defaultTactic='CONTINUOUS PRESSURE' -- Legacy immediate-reinforcement policy.
assert(C.startup.start())
local f=C.registry.forces[C.registry.activeForce]
assert(f and #C.officer.members(f)==0)
C.productionControl.update(); assert(#calls==1 and calls[1].cmd==-1)
-- First unit moves without selecting or manually creating a force/objective.
team={20,1}; clock=12; C.startup.update(); C.tactical.update()
assert(f.members[1] and f.delegation.active)
assert(C.registry.owner[1] and calls[#calls].id==1 and calls[#calls].cmd==CMD.FIGHT)
-- New recruit catches up while the old main operation is still running.
local old=C.registry.owner[1]
team={20,1,2}; clock=14; C.startup.update(); C.tactical.update()
assert(C.registry.owner[1]==old and C.registry.owner[2])
-- Reconciliation never recaptures manual releases.
C.registry.release({2},'PLAYER_OVERRIDE'); clock=16; C.startup.update()
assert(not f.members[2])
-- Newly completed factories participate; manually released factories stay out.
units[21]={x=1200,z=1000,team=0,def=2}; team={20,21,1,2}
C.productionControl.release(20); queues[20]={}; clock=22; C.productionControl.update()
assert(C.productionControl.factories[21] and not C.productionControl.factories[20])
-- Losing the entire force does not permanently disable an opted-in startup.
C.registry.release({1},'UNIT_LOST'); clock=24; C.tactical.update()
assert(C.startup.enabled and not f.delegation.active)
team={20,21,3}; clock=26; C.startup.update(); C.tactical.update()
assert(f.members[3] and f.delegation.active and C.registry.owner[3])
-- Stop prevents automatic re-delegation even if auto recruitment remains on.
C.officer.setDelegated(f.id,false); C.productionControl.set(false)
local before=#calls; clock=30; C.startup.update(); C.tactical.update(); C.productionControl.update()
assert(not C.startup.enabled and not f.delegation.active and #calls==before)
Spring.GetPlayerList=function() return {0,1} end
assert(not C.startup.start())
