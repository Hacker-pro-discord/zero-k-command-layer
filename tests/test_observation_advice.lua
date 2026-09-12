dofile(ROOT..'/tests/fixture.lua')
Spring.AreTeamsAllied=function(a,b)return a==b end
units[20]={x=1300,z=1200,def=1,team=1}
Spring.GetAllUnits=function()return {1,2,20} end
Spring.GetUnitLosState=function(id)return id==20 and {radar=true,typed=true} or {los=true} end
C.observations=loadModule('Observations')(C); C.observations.update(true)
local b=C.observations.snapshot(); assert(#b.contacts==1 and b.contacts[1].role=='UNKNOWN' and b.contacts[1].defID==nil)
UnitDefs[2]={name='factory',humanName='Test Factory',isFactory=true,buildOptions={3},metalCost=600}
UnitDefs[3]={name='aa',humanName='Test AA',speed=60,iconType='kbotaa',metalCost=150}
units[5]={x=1200,z=1200,def=2,team=0}; Spring.GetTeamUnits=function()return {1,2,5} end
C.settings.privateSession=true; local id=C.officer.assign({1,2}); C.production=loadModule('ProductionAdvisor')(C)
local advice=C.production.recommend(C.registry.forces[id]); assert(advice:find('Test AA') and advice:find('existing factory')); assert(#calls==0)
Spring.GetSpectatingState=function()return true end; C.observations.update(true); assert(#C.observations.contacts==0 and C.observations.economy()==nil)
