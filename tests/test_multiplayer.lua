dofile(ROOT..'/tests/fixture.lua')
local roster={0,1}; local options={sendspringiedata='1',ranked='1'}
Spring.GetPlayerList=function() return roster end
Spring.GetModOptions=function() return options end
Spring.AreTeamsAllied=function(a,b) return a==b or a==0 and b==2 end
Spring.GetAllUnits=function() return {} end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
C.observations=loadModule('Observations')(C); C.input={}
C.proposals=loadModule('ProposalService')(C)
C.rules=loadModule('TacticalRules')(C); C.tactical=loadModule('TacticalController')(C)
C.productionControl=loadModule('ProductionController')(C); C.startup=loadModule('Startup')(C)
C.economy=loadModule('Economy')(C); C.recovery=loadModule('Recovery')(C)
C.startup.boot(); assert(not C.startup.enabled and #calls==0)
assert(not C.officer.setSession(true) and not C.U.delegationAllowed(C.settings))
assert(C.officer.setMultiplayerSession(true) and C.U.delegationAllowed(C.settings) and #calls==0)
assert(C.startup.start()); C.tactical.update()
assert(C.startup.enabled and C.productionControl.enabled and C.economy.enabled and C.recovery.enabled and #calls>0)
local f=C.registry.forces[C.registry.activeForce]; assert(f.delegation.active)
-- Allied/shared LOS never grants ownership of another team's units.
units[30]={x=1100,z=1000,def=1,team=2}; units[31]={x=1200,z=1000,def=1,team=1}
assert(not C.officer.autoAssign(30,f.id) and not C.officer.autoAssign(31,f.id))
for _,call in ipairs(calls) do assert(call.id~=30 and call.id~=31) end
C.officer.releaseUnits({1}); clock=14; C.startup.update(); C.tactical.update(); assert(not f.members[1])
roster={0,1,2,3}; clock=16; C.tactical.update(); assert(f.delegation.active)
local saved=C.settings.save(); assert(saved.multiplayerSession==nil and saved.privateSession==nil)
local loaded=loadModule('Settings')(C.U); loaded.load({multiplayerSession=true,privateSession=true}); assert(not loaded.multiplayerSession and not loaded.privateSession)
-- Explicit off revokes production, builders and all combat grants.
C.officer.setMultiplayerSession(false)
assert(not C.settings.multiplayerSession and not C.startup.enabled and not C.economy.enabled and not C.productionControl.enabled and not f.delegation.active)
local n=#calls; clock=20; C.tactical.update(); C.startup.update(); C.productionControl.update(); assert(#calls==n)
-- Server prohibition, spectators and replays remain hard gates.
options.disable_local_widgets='1'; assert(not C.officer.setMultiplayerSession(true))
options.disable_local_widgets='0'; Spring.GetSpectatingState=function() return true end; assert(not C.officer.setMultiplayerSession(true))
Spring.GetSpectatingState=function() return false end; Spring.IsReplay=function() return true end; assert(not C.officer.setMultiplayerSession(true))
Spring.IsReplay=function() return false end
assert(C.officer.setMultiplayerSession(true)); assert(C.startup.start())
options.disable_local_widgets='1'; clock=24; C.tactical.update(); C.productionControl.update(); assert(not C.U.delegationAllowed(C.settings) and not C.productionControl.enabled)
-- Ordinary boot never silently grants multiplayer authority, even after reload.
C.settings.privateSession=false; C.settings.multiplayerSession=false; options.disable_local_widgets=nil
C.startup.booted=false; C.startup.enabled=false; C.startup.boot(); assert(not C.startup.enabled)
