dofile(ROOT..'/tests/fixture.lua')
C.observations={snapshot=function() return {contacts={}} end}; C.rules=loadModule('TacticalRules')(C)
local corridor={{800,0,700},{2200,0,700},{2200,0,1300},{800,0,1300}}
units[1].x=1000; units[1].z=1000
local probes=0
Spring.TestMoveOrder=function(def,x,y,z,dx,dy,dz,terrain,objects,center)
 probes=probes+1; assert(terrain and not objects and not center)
 return not (x>=1480 and x<=1520 and z>=900 and z<=1100)
end
local function fresh() return {units={1},slots={[1]={2000,0,1000}},center={2000,0,1000},origin={1000,0,1000},shape='LINE',zones={},front={1,0},gesture={{2000,0,950},{2000,0,1050}},width=100,corridor=corridor} end
local p=C.routing.prepare(fresh(),{corridor=corridor})
assert(p.routes[1] and #p.routes[1]==1 and p.routing.detours==1 and probes>0)
assert(C.formations.inCorridor(p,p.routes[1][1]))
-- Fog must not be queried or labelled impassable; leave unknown terrain to native pathfinding.
Spring.GetPositionLosState=function() return false end; probes=0
p=C.routing.prepare(fresh(),{corridor=corridor}); assert(probes==0 and not p.routes[1])
Spring.GetPositionLosState=function() return true end
Spring.TestMoveOrder=function(_,x,_,z) return math.abs(x-2000)>60 or math.abs(z-1000)>60 end
p=C.routing.prepare(fresh(),{corridor=corridor}); assert(p.routing.adjusted==1 and C.U.distance(p.slots[1],{2000,0,1000})>60)
-- A route is queued before its destination, and rejects out-of-corridor points before dispatch.
C.settings.privateSession=true; C.input={}; C.proposals=loadModule('ProposalService')(C)
local fid=C.officer.assign({1}); local f=C.registry.forces[fid]
Spring.GetPlayerList=function() return {0} end
f.delegation={active=true,token=1,blocked={},sector={corridor=corridor}}
p=fresh(); p.routes={[1]={{1500,0,1200}}}; local op=C.officer.executeDelegated(f,{1},p,'WITHDRAW',Spring.Utilities.CMD.RAW_MOVE)
assert(op and #calls==2 and calls[1].p[1]==1500 and calls[2].p[1]==2000 and calls[2].o==CMD.OPT_SHIFT)
p.routes[1][1]={1500,0,3000}; local before=#calls
assert(not C.officer.executeDelegated(f,{1},p,'WITHDRAW',Spring.Utilities.CMD.RAW_MOVE) and #calls==before)
