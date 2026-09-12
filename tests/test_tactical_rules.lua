dofile(ROOT..'/tests/fixture.lua')
C.rules=loadModule('TacticalRules')(C)
UnitDefs[2]={name='riot',speed=60,metalCost=250,maxWeaponRange=300,iconType='kbotriot'}
UnitDefs[3]={name='builder',speed=50,isBuilder=true,metalCost=120}
UnitDefs[4]={name='artillery',speed=40,metalCost=400,maxWeaponRange=800,iconType='kbotarty'}
units[10].def=4; units[11].def=4; units[12].def=4
local groups=C.rules.groups({1,2,3,4,5,6,7,8,9,10,11,12})
for _,kind in ipairs({'SCOUT','RAID'}) do for _,id in ipairs(groups[kind]) do assert(id<10) end end
local sector=C.rules.sector({1,2,3,4},{{900,0,4000},{2500,0,4000}})
local target={id=50,visibility='VISUAL',defID=3,role='CONSTRUCTOR',position={1500,0,2200}}
assert(C.rules.raid(sector,{1,2,3},{target})==target.position)
target.visibility='RADAR'; target.defID=nil; target.role='UNKNOWN'
assert(not C.rules.raid(sector,{1,2,3},{target}))
target.visibility='VISUAL'; target.defID=3; target.role='CONSTRUCTOR'
local riot={id=51,visibility='VISUAL',defID=2,role='RIOT',position={1550,0,2250}}
assert(not C.rules.raid(sector,{1,2,3},{target,riot}))
target.position={7000,0,7000}; assert(not C.rules.raid(sector,{1,2,3},{target}))
local point,key=C.rules.scout(sector,{1},{},{},10)
assert(point and C.formations.inCorridor(sector,point))
local other,otherKey=C.rules.scout(sector,{1},{},{[key]=10},10)
assert(other and otherKey~=key)
