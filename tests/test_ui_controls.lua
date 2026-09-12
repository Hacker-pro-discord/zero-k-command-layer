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
local production=find('PRODUCTION: OFF'); assert(production and production.parent==C.ui.body)
assert(production.y+production.height<=C.ui.detail.y)
production.OnClick[1](); assert(C.productionControl.enabled and find('PRODUCTION: ON'))
find('START MAP CONTROL').OnClick[1](); assert(C.testStarted)
C.settings.autoAssign=true; C.settings.privateSession=false; C.ui.build()
assert(find('AUTO ASSIGN: WAIT'))
C.ui.update(1); assert(C.ui.detail.text:find('enable LOCAL / PRIVATE'))

C.productionControl.enroll=function(ids) C.enrolled=ids; return true end
C.recovery={status='Recovery test',enroll=function(ids) C.builders=ids end,cancelRequests=function() C.cancelled=true end,stop=function() C.recoveryStopped=true end}
C.ui.showManagement(); find('RE-ENROLL SELECTED FACTORIES').OnClick[1](); assert(C.enrolled[1]==1)
find('ADD SELECTED BUILDERS').OnClick[1](); assert(C.builders[1]==1)
find('ADD BUILD REQUEST').OnClick[1](); assert(C.recovery.armed)

C.arsenal={status='Arsenal test',enroll=function(ids) C.launchers=ids end,stop=function() C.fireStopped=true end}
C.ui.showManagement(); find('ARM SELECTED LAUNCHERS').OnClick[1](); assert(C.launchers[1]==1)
find('STOP STRATEGIC FIRE').OnClick[1](); assert(C.fireStopped)
