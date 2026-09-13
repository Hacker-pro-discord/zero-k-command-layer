dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end; C.settings.privateSession=true
UnitDefs[1]={name='cheap',iconType='kbotassault',speed=80,metalCost=100}
UnitDefs[2]={name='counter',iconType='kbotassault',speed=50,metalCost=1000}
UnitDefs[3]={name='enemy',iconType='kbotriot',speed=50,metalCost=1000}
UnitDefs[4]={name='factorycheap',isFactory=true,metalCost=700,buildOptions={1}}
UnitDefs[5]={name='factorycounter',isFactory=true,metalCost=700,buildOptions={2}}
UnitDefs[6]={name='constructor',isBuilder=true,speed=50,buildOptions={4,5}}
units[20]={def=6,team=0,x=1000,z=1000}; units[30]={def=4,team=0,x=1200,z=1000}
C.classify.cache={}; Spring.GetTeamUnits=function() return {20,30} end; Spring.GetFactoryCommands=function() return {} end
C.observations={snapshot=function() return {contacts={{id=90,defID=3,role='RIOT',visibility='VISUAL',time=clock}}} end}
C.matchups=loadModule('UnitMatchups')(C,{matrix={cheap={enemy=.7},counter={enemy=1.8}}})
C.enemyModel=loadModule('EnemyModel')(C); C.economyPlan=loadModule('EconomyPlanning')(C)
local w,m=C.enemyModel.weights()
assert(C.enemyModel.score(C.classify.definition(2),w,{},1000,m)>C.enemyModel.score(C.classify.definition(1),w,{},1000,m),'Ten-times dearer actual counter beats cheap unit')
local choices=C.economyPlan.factories(20,{30},{metal={income=40}})
assert(choices[1].name=='factorycounter' and choices[1].preferred,'Choose new factory by its affordable matrix counter')
C.settings.unitMatchups=false; choices=C.economyPlan.factories(20,{30},{metal={income=40}})
assert(choices[1].name=='factorycheap','Unknown/off matrix keeps existing capacity preference')
