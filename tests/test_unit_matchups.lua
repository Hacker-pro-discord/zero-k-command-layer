dofile(ROOT..'/tests/fixture.lua')
Spring.GetPlayerList=function() return {0} end
C.settings.privateSession=true
UnitDefs[1].name='cloakraid'
UnitDefs[2]={name='cloakskirm',iconType='kbotraider',speed=90,metalCost=65,maxWeaponRange=450}
UnitDefs[3]={name='cloakriot',iconType='kbotriot',speed=60,metalCost=500,maxWeaponRange=300}
UnitDefs[4]={name='factorycloak',isFactory=true,isBuilder=true,buildOptions={1,2}}
C.classify.cache={}
local contacts={{id=90,defID=3,role='RIOT',visibility='VISUAL',time=clock}}
C.observations={snapshot=function() return {contacts=contacts,time=clock,composition={RIOT=1}} end,economy=function() return {metal={current=5000},energy={current=5000}} end}
C.matchups=loadModule('UnitMatchups')(C,loadModule('CounterMatrixData'))
C.enemyModel=loadModule('EnemyModel')(C)
local weights,model=C.enemyModel.weights()
assert(model.units.cloakriot and model.units.cloakriot.defID==3)
local raider=C.classify.definition(1); local ranged=C.classify.definition(2)
local a=C.matchups.bias(raider,model); local b=C.matchups.bias(ranged,model)
assert(a<0 and b>0) -- candidate row, target column; never transpose
local old=C.enemyModel.score(ranged,weights,{},0)
assert(C.enemyModel.score(ranged,weights,{},0,model)>C.enemyModel.score(raider,weights,{},0,model))
C.settings.unitMatchups=false; assert(C.enemyModel.score(ranged,weights,{},0,model)==old); C.settings.unitMatchups=true
local sparse={units={cloakriot={defID=3,value=500,rawValue=500},new_unit={defID=3,value=1500,rawValue=1500}},unknown=0}
assert(C.matchups.bias(ranged,sparse)<b*.3) -- uncovered intel not normalized away
local unknown={name='not_in_matrix',cost=65,role='RAIDER',domain='GROUND'}
assert(C.matchups.adjust(-100,unknown,model,0)==-100)
local invalid=loadModule('UnitMatchups')(C,{matrix={cloakraid={cloakriot=math.huge}}})
assert(invalid.bias(raider,model)==0)
local neutral=loadModule('UnitMatchups')(C,{matrix={cloakraid={cloakriot=1}}})
assert(neutral.adjust(-100,raider,model,0)==-100) -- neutral reference-cost unit stays comparable with legacy fallback
assert(C.matchups.adjust(-100,ranged,model,0)>-100) -- signed additive bonus never reverses preference on a negative deficit
local aa={name='cloakskirm',cost=65,role='ANTI_AIR',domain='GROUND'}
assert(C.matchups.bias(aa,model)==0) -- numerical preference cannot turn AA into ground counter
contacts={{id=90,defID=1,visibility='RADAR',role='UNKNOWN'}}; clock=100
local stale=C.enemyModel.snapshot(); assert(not stale.units.cloakraid and stale.units.cloakriot)
assert(math.abs(C.matchups.bias(ranged,stale)-b*.5*(500/550))<.00001)
clock=600; assert(next(C.enemyModel.snapshot().units)==nil)
-- Same-role, same-price alternatives isolate the actual unit-pair choice across factories.
clock=610; contacts={{id=90,defID=3,role='RIOT',visibility='VISUAL',time=clock}}
for id=20,23 do units[id]={x=1000,z=500,team=0,def=4} end
Spring.GetTeamUnits=function() return {1,2,3,4,5,6,20,21,22,23} end
Spring.GetFactoryCommands=function(id) return queues[id] or {} end
C.input={}; C.proposals=loadModule('ProposalService')(C); C.officer.assign({1,2,3,4})
C.productionControl=loadModule('ProductionController')(C); C.productionControl.set(true); C.productionControl.update()
assert(#calls==4,'Known counters apply even before five army units exist'); for _,v in ipairs(calls) do assert(v.cmd==-2) end
C.productionControl.release(20); for id=20,23 do queues[id]={} end
clock=616; C.productionControl.update(); assert(#calls==7)
for i=5,7 do assert(calls[i].id~=20 and calls[i].cmd==-2) end
C.production=loadModule('ProductionAdvisor')(C)
local advice=C.production.recommend(C.registry.forces[C.registry.activeForce]); assert(advice:find('Unit matrix') and #calls==7)
C.settings.privateSession=false; assert(C.matchups.bias(ranged,model)==0)
C.settings.load({unitMatchups=false}); assert(C.settings.unitMatchups==false)
