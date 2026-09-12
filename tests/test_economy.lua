dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
UnitDefs[2]={name='commander',isBuilder=true,speed=40,metalCost=1000,buildOptions={3,4,5}}
UnitDefs[3]={name='factorycloak',isFactory=true,isBuilder=true,metalCost=600,buildOptions={1,2}}
UnitDefs[4]={name='energysolar',isBuilding=true,metalCost=70}
UnitDefs[5]={name='staticmex',isBuilding=true,metalCost=75,customParams={metal_extractor_mult='1'}}
UnitDefNames={factorycloak={id=3},energysolar={id=4},staticmex={id=5}}
units[20]={def=2,team=0,x=1000,z=1000}; local team={20}
Spring.GetTeamUnits=function() return team end; Spring.GetFactoryCommands=function() return {} end
Spring.TestBuildOrder=function() return 2 end
C.observations={nearCombat=function() return false end,snapshot=function() return {contacts={}} end,economy=function() return {metal={current=400,income=6},energy={current=600,income=20}} end}
C.economy=loadModule('Economy')(C); assert(C.economy.start()); C.economy.update()
assert(#calls==1 and calls[1].cmd==-3,'Normal-start factory uses native construction')
clock=12; C.economy.update(); assert(#calls==1,'Busy builder remains untouched')
C.officer.releaseUnits({20}); queues[20]={}; clock=20; C.economy.update(); assert(#calls==1 and C.economy.excluded[20])
units[30]={def=3,team=0,x=1200,z=1000}; team={20,30}; WG.metalSpots={{x=2000,y=0,z=1000,metal=2}}
C.economy.enroll({20}); Spring.GetPositionLosState=function() return false end
clock=24; C.economy.update(); assert(calls[#calls].cmd==Spring.Utilities.CMD.RAW_MOVE,'Unseen public spot gets survey, not occupancy query/build')
queues[20]={}; clock=36; Spring.GetPositionLosState=function() return true end; C.economy.update()
clock=48; C.economy.update(); assert(calls[#calls].cmd==-5)
C.economy.stop(); local count=#calls; clock=60; C.economy.update(); assert(#calls==count)
C.settings.privateSession=false; assert(not C.economy.start())
