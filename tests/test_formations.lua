dofile(ROOT..'/tests/fixture.lua')
local ids={1,2,3,4,5,6,7,8,9,10,11,12}
for _,shape in ipairs(C.formations.names) do
	C.settings.formation=shape
	local p=C.formations.plan(ids,{{1000,0,2500},{1500,0,2600},{2200,0,2500}})
	local count=0; for id,pos in pairs(p.slots) do count=count+1; assert(pos[1]==pos[1] and pos[3]==pos[3]); assert(pos[1]>=0 and pos[1]<=Game.mapSizeX) end; assert(count==12)
end
C.settings.formation='DOUBLE LINE'; local p=C.formations.plan(ids,{{1000,0,2500},{2200,0,2500}})
local bands={}; for _,pos in pairs(p.slots) do bands[pos[3]]=true end
local n=0; for _ in pairs(bands) do n=n+1 end; assert(n==2)

UnitDefs[2]={name='arty',iconType='kbotarty',speed=40}; units[4].def=2
C.settings.formation='ASSAULT'; C.classify.cache={}
local assault=C.formations.plan({1,2,3,4},{{1000,0,2500},{2200,0,2500}})
assert(assault.slots[4][3]<assault.slots[1][3]-300)
