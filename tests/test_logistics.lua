local U=dofile(ROOT..'/LuaUI/Widgets/Include/CommandLayer/Util.lua')
CMD={OPT_ALT=128,OPT_CTRL=64,OPT_META=4,OPT_SHIFT=32,OPT_RIGHT=16}
local active=30100
Spring={Utilities={CMD={AREA_MEX=30100}},GetSpectatingState=function()return false end,IsReplay=function()return false end,GetGameFrame=function()return 100 end,GetGameSeconds=function()return 1 end,GetCmdDescIndex=function(id)return id end,GetSelectedUnits=function()return {1,2} end,SetActiveCommand=function(id)active=id end,GetActiveCommand=function()return 1,active end}
WG={metalSpots={},CommandInsert=function()end}
local L=dofile(ROOT..'/LuaUI/Widgets/Include/CommandLayer/Logistics.lua')({U=U,debug={log=function()end}})
for _,count in ipairs({0,1,2,4}) do
	assert(L.arm('MEX'..count)); local o={shift=true,meta=true}; L.notify(30100,{10,0,10,100},o)
	assert(o.ctrl==(count==1 or count==4)); assert(o.alt==(count==2 or count==4)); assert(o.coded==36+(o.ctrl and 64 or 0)+(o.alt and 128 or 0))
end
L.notify(10,{},{}); assert(not L.pending)
