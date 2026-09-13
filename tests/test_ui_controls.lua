dofile(ROOT..'/tests/fixture.lua')
local controls={}
local class={New=function(self,o)
	o.Dispose=function() end; o.SetText=function(self,text) self.text=text end
	controls[#controls+1]=o; return o
end}
WG.Chili={Panel=class,Button=class,Window=class,TextBox=class,Screen0={}}
C.productionControl={enabled=false,status='OFF',set=function(value) C.productionControl.enabled=value; return true end}
C.startup={start=function() C.testStarted=true end}
C.ui=loadModule('UI')(C); assert(C.ui.initialize()); C.ui.tab='OFFICER'; C.ui.build()
local function find(caption) for i=#controls,1,-1 do if controls[i].caption==caption then return controls[i] end end end
Spring.GetPlayerList=function() return {0} end
Spring.AreTeamsAllied=function(a,b) return a==b end
C.settings.privateSession=true
local production=find('PRODUCTION: OFF'); assert(production and production.parent==C.ui.body)
assert(production.y+production.height<=C.ui.detail.y)
production.OnClick[1](); assert(C.productionControl.enabled and find('PRODUCTION: ON'))
find('WIN THE GAME').OnClick[1](); assert(C.testStarted)
C.settings.autoAssign=true; C.settings.privateSession=false; C.ui.build()
assert(find('AUTO ASSIGN: WAIT'))
C.ui.update(1); assert(C.ui.detail.text:find('enable LOCAL / PRIVATE'))

C.productionControl.enroll=function(ids) C.enrolled=ids; return true end
C.recovery={status='Recovery test',enroll=function(ids) C.builders=ids end,cancelRequests=function() C.cancelled=true end,stop=function() C.recoveryStopped=true end}
C.settings.privateSession=true
C.ui.showManagement(); find('RE-ENROLL SELECTED FACTORIES').OnClick[1](); assert(C.enrolled[1]==1)
find('ADD SELECTED BUILDERS').OnClick[1](); assert(C.builders[1]==1)
find('ADD BUILD REQUEST').OnClick[1](); assert(C.recovery.armed)

C.arsenal={status='Arsenal test',enroll=function(ids) C.launchers=ids end,stop=function() C.fireStopped=true end}
C.ui.showManagement(); find('ARM SELECTED LAUNCHERS').OnClick[1](); assert(C.launchers[1]==1)
find('STOP STRATEGIC FIRE').OnClick[1](); assert(C.fireStopped)

C.economy={enabled=false,status='Economy test',start=function() C.economy.enabled=true; return true end,stop=function() C.economy.enabled=false end,enroll=function(ids) C.economyBuilders=ids end}
C.ui.showManagement(); find('ECONOMY: OFF').OnClick[1](); assert(C.economy.enabled and C.settings.autoEconomy)
find('ADD ECONOMY BUILDERS').OnClick[1](); assert(C.economyBuilders[1]==1)
find('ECONOMY: ON').OnClick[1](); assert(not C.economy.enabled and not C.settings.autoEconomy)

C.structurePlanning={status='Ready',catalog=function(ids,category) C.requestedCategory=category; return {1} end,arm=function(def) C.armedDefinition=def; return true end}
C.ui.showManagement(); find('DEFENCE / SPECIAL BUILDS').OnClick[1]()
assert(C.requestedCategory=='DEFENCE')
find('SPECIAL').OnClick[1](); assert(C.requestedCategory=='SPECIAL')
local caption=(UnitDefs[1].humanName or UnitDefs[1].name)..' | '..UnitDefs[1].metalCost..' metal'
find(caption).OnClick[1](); assert(C.armedDefinition==1 and not C.ui.structures)
C.ui.showManagement(); find('AUTO STRUCTURES: ON').OnClick[1](); assert(not C.settings.autoStructures)

Spring.GetPlayerList=function() return {0,1} end
C.settings.multiplayerSession=false; C.settings.privateSession=false
C.officer.setMultiplayerSession=function(on) C.settings.multiplayerSession=on; C.multiplayerChoice=on; return true end
C.testStarted=false; C.ui.tab='OFFICER'; C.ui.build()
find('ENABLE MULTIPLAYER AI').OnClick[1](); assert(C.multiplayerChoice and C.testStarted)
find('MULTIPLAYER AI: ON / DISABLE').OnClick[1](); assert(C.multiplayerChoice==false)
