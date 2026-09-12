dofile(ROOT..'/tests/fixture.lua')
local intent={gesture={{1000,0,2000},{1800,0,2000}},command=CMD.FIGHT,options={shift=true}}
local id=C.officer.submit(intent,{1,2,3,4}); assert(id and #calls==4)
for _,o in ipairs(calls) do assert(o.cmd==CMD.FIGHT and o.o==CMD.OPT_SHIFT) end
local op=C.registry.newOperation({1,2}); C.registry.release({1},'PLAYER_OVERRIDE')
assert(not C.orders.unit(op,1,CMD.MOVE,{0,0,0},C.U.options({})))
assert(C.orders.unit(op,2,CMD.MOVE,{0,0,0},C.U.options({})))
C.registry.finish(op,'CANCELLED'); assert(not C.orders.unit(op,2,CMD.MOVE,{0,0,0},C.U.options({})))
