dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
C.settings.privateSession=true
UnitDefs[2]={name='builder',speed=40,isBuilder=true,buildOptions={3,4,5},metalCost=120}
UnitDefs[3]={name='turretlaser',humanName='Lotus',isBuilding=true,metalCost=90,iconType='defense',speed=0}
UnitDefs[4]={name='staticradar',humanName='Radar',isBuilding=true,metalCost=100,radarDistance=2000,speed=0}
UnitDefs[5]={name='staticnuke',humanName='Trinity',isBuilding=true,metalCost=8000,speed=0}
UnitDefs[6]={name='factorycloak',isFactory=true,speed=0,metalCost=600}
UnitDefNames={turretlaser={id=3},staticradar={id=4},staticnuke={id=5}}
VFS={Include=function() return {},{},{turretlaser={}},{staticradar={},staticnuke={},[123]={}} end}
units[20]={def=2,team=0,x=1000,z=1000}; units[21]={def=6,team=0,x=1000,z=1100}
local own={20,21,1,2,3,4,5,6,7,8,9,10,11,12}
Spring.GetTeamUnits=function() return own end
Spring.TestBuildOrder=function() return 2 end
Spring.GetFactoryCommands=function() return {} end
local resources={metal={current=1000,income=15},energy={current=1000,income=30}}
local contacts={}
C.observations={snapshot=function() return {contacts=contacts} end,nearCombat=function() return false end,economy=function() return resources end}
C.structurePlanning=loadModule('StructurePlanning')(C)
C.economy=loadModule('Economy')(C); C.recovery=loadModule('Recovery')(C)
assert(#C.structurePlanning.catalog({20},'DEFENCE')==1)
assert(#C.structurePlanning.catalog({20},'SPECIAL')==2)
assert(#C.structurePlanning.catalog({1},'SPECIAL')==0)
local job=C.structurePlanning.choose(20,own,resources,false,clock)
assert(job and job.name=='staticradar' and #calls==0)
resources.metal.current=120; assert(not C.structurePlanning.choose(20,own,resources,false,clock)); resources.metal.current=1000
resources.energy.current=50; assert(not C.structurePlanning.choose(20,own,resources,false,clock)); resources.energy.current=1000
assert(not C.structurePlanning.choose(20,own,resources,true,clock))
C.settings.autoStructures=false; assert(not C.structurePlanning.choose(20,own,resources,false,clock)); C.settings.autoStructures=true
assert(C.economy.start()); C.economy.update()
assert(calls[#calls].cmd==-4 and C.economy.tasks[20].key:find('structure'))
local n=#calls; clock=12; C.economy.update(); assert(#calls==n)
C.officer.releaseUnits({20}); queues[20]={}; clock=44; C.economy.update(); assert(#calls==n)
-- Completed/pending coverage suppresses another radar; allow light defense instead.
units[22]={def=4,team=0,x=1000,z=1200}; own[#own+1]=22
job=C.structurePlanning.choose(20,own,resources,false,clock)
assert(not job or job.name~='staticradar')
local activated
Spring.GetCmdDescIndex=function(cmd) if cmd==-5 then return 9 end end
Spring.SetActiveCommand=function(index) activated=index end
assert(C.structurePlanning.arm(5) and C.recovery.armed and activated==9 and #calls==n)
-- All native Special buildings are requestable, including costly explicit requests.
assert(C.recovery.request(5,{1500,0,1500},0,{20}))
assert(C.recovery.requests[1].def==5)
C.settings.privateSession=false
assert(not C.structurePlanning.arm(5) and not C.structurePlanning.choose(20,own,resources,false,80))
C.settings.privateSession=true; C.recovery.update()
assert(C.recovery.assets[22] and C.recovery.assets[22].def==4)
C.recovery.destroyed(22); assert(next(C.recovery.missing))
