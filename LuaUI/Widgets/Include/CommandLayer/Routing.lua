-- Local LOS-checked terrain routing, not enemy discovery or a replacement pathfinder.
return function(C)
	local R={}
	function R.prepare(plan,sector)
		local cache,tests={},0; local used={}; local contacts=C.observations.snapshot().contacts
		plan.routes={}; plan.routing={adjusted=0,detours=0,unresolved=0,tests=0}
		local function validPoint(p) return C.U.point(p) and C.formations.inCorridor(sector,p) end
		local function terrain(def,p)
			if not validPoint(p) then return false end
			if not Spring.TestMoveOrder or not Spring.GetPositionLosState(p[1],p[2],p[3]) then return nil end
			local key=def..':'..math.floor(p[1]/8)..':'..math.floor(p[3]/8)
			if cache[key]~=nil then return cache[key] end
			if tests>=2048 then return nil end; tests=tests+1
			-- Terrain only, full footprint. Do not query unit/object occupancy.
			local ok=Spring.TestMoveOrder(def,p[1],p[2],p[3],0,0,0,true,false,false)
			cache[key]=ok; return ok
		end
		local function point(x,z) return {x,Spring.GetGroundHeight(x,z),z} end
		local function clear(def,a,b)
			local count=math.max(1,math.min(12,math.ceil(C.U.distance(a,b)/64)))
			for i=1,count do local t=i/count; if terrain(def,point(a[1]+(b[1]-a[1])*t,a[3]+(b[3]-a[3])*t))==false then return false end end
			return true
		end
		local ids=C.U.copy(plan.units)
		table.sort(ids,function(a,b) return (plan.priority and plan.priority[a] or a)<(plan.priority and plan.priority[b] or b) end)
		for _,id in ipairs(ids) do
			local def=Spring.GetUnitDefID(id); local d=C.classify.definition(def); local goal=plan.slots[id]; local start=C.U.position(id)
			local function free(p)
				for _,prior in ipairs(used) do if C.U.distance(p,prior.p)<d.radius+prior.radius+8 then return false end end
				return true
			end
			if start and d.ground and terrain(def,goal)==false then
				local replacement
				for _,radius in ipairs({48,96,160,256}) do
					for i=0,7 do local p=point(goal[1]+math.cos(i*math.pi/4)*radius,goal[3]+math.sin(i*math.pi/4)*radius)
						if terrain(def,p)==true and free(p) then replacement=p; break end
					end
					if replacement then break end
				end
				if replacement then goal=replacement; plan.slots[id]=goal; plan.routing.adjusted=plan.routing.adjusted+1 else plan.routing.unresolved=plan.routing.unresolved+1 end
			end
			if start and d.ground and not clear(def,start,goal) then
				local dx,dz=goal[1]-start[1],goal[3]-start[3]; local length=math.max(1,math.sqrt(dx*dx+dz*dz)); local best,score
				for _,offset in ipairs({128,-128,256,-256,512,-512}) do
					local via=point((start[1]+goal[1])/2-dz/length*offset,(start[3]+goal[3])/2+dx/length*offset)
					if terrain(def,via)==true and clear(def,start,via) and clear(def,via,goal) then
						local cost=C.U.distance(start,via)+C.U.distance(via,goal)+C.rules.risk(via,contacts,350)
						if not score or cost<score then best,score=via,cost end
					end
				end
				if best then plan.routes[id]={best}; plan.routing.detours=plan.routing.detours+1 else plan.routing.unresolved=plan.routing.unresolved+1 end
			end
			used[#used+1]={p=goal,radius=d.radius or 16}
		end
		plan.routing.tests=tests
		return plan
	end
	return R
end
