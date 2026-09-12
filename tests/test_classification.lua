dofile(ROOT..'/tests/fixture.lua')
for i,pair in ipairs({{'kbotraider','RAIDER'},{'kbotarty','ARTILLERY'},{'kbotaa','ANTI_AIR'},{'walkerassault','ASSAULT'},{'hoverriot','RIOT'},{'unknown','OTHER'}}) do
	local id=i+20; UnitDefs[id]={iconType=pair[1],speed=60,name='fixture'..id}; assert(C.classify.definition(id).role==pair[2])
end
UnitDefs[50]={iconType='builder',isBuilder=true,speed=50,name='constructor'}; units[50]={x=0,z=0,def=50,team=0}
assert(#C.classify.filter({50})==0); C.settings.constructors=true; assert(#C.classify.filter({50})==1)
