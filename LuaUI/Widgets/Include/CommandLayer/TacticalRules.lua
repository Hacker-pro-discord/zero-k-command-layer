-- Reviewed, game-only rules. Sources and experimental status: docs/TACTICAL_RESEARCH.md.
return function(C)
	local R={version='pressure-2',scoutFraction=.1,raidFraction=.2,step=600}
	function R.groups(ids)
		local groups={SCOUT={},RAID={},MAIN={}}; local candidates={}
		for _,id in ipairs(ids) do local d=C.classify.definition(Spring.GetUnitDefID(id)); if d.ground and not d.builder and (d.role=='SCOUT' or d.role=='RAIDER') then candidates[#candidates+1]=id end end
		table.sort(candidates,function(a,b)
			local x,y=C.classify.definition(Spring.GetUnitDefID(a)),C.classify.definition(Spring.GetUnitDefID(b))
			if x.role~=y.role then return x.role=='SCOUT' end
			return x.cost==y.cost and a<b or x.cost<y.cost
		end)
		local scouts=#ids>=5 and math.min(2,math.max(1,math.floor(#ids*R.scoutFraction))) or 0
		local raids=#ids>=8 and math.min(4,math.floor(#ids*R.raidFraction)) or 0
		local used={}
		for _,id in ipairs(candidates) do
			if #groups.SCOUT<scouts then groups.SCOUT[#groups.SCOUT+1]=id; used[id]=true
			elseif #groups.RAID<raids and C.classify.definition(Spring.GetUnitDefID(id)).role=='RAIDER' then groups.RAID[#groups.RAID+1]=id; used[id]=true end
		end
		for _,id in ipairs(ids) do if not used[id] then groups.MAIN[#groups.MAIN+1]=id end end
		return groups
	end
	function R.sector(ids,objective)
		local origin=C.U.center(ids); if not origin or not objective or #objective<2 then return nil end
		local a,b=objective[1],objective[#objective]; local goal={(a[1]+b[1])/2,0,(a[3]+b[3])/2}
		local dx,dz=goal[1]-origin[1],goal[3]-origin[3]; local length=math.sqrt(dx*dx+dz*dz)
		if length<128 then return nil end
		local s={origin=origin,goal=goal,length=length,ux=dx/length,uz=dz/length,half=math.max(256,C.U.distance(a,b)/2)}
		s.px,s.pz=-s.uz,s.ux
		local function corner(along,across) return {origin[1]+s.ux*along+s.px*across,0,origin[3]+s.uz*along+s.pz*across} end
		s.corridor={corner(-400,-s.half),corner(length+64,-s.half),corner(length+64,s.half),corner(-400,s.half)}
		return s
	end
	function R.point(s,along,across)
		local p={s.origin[1]+s.ux*along+s.px*across,0,s.origin[3]+s.uz*along+s.pz*across}
		-- Reject off-map points rather than moving the approved boundary.
		if C.U.point(p) and C.formations.inCorridor(s,p) then p[2]=Spring.GetGroundHeight(p[1],p[3]); return p end
	end
	function R.progress(s,p) return (p[1]-s.origin[1])*s.ux+(p[3]-s.origin[3])*s.uz end
	function R.health(ids)
		local health=0; for _,id in ipairs(ids) do local h,m=Spring.GetUnitHealth(id); health=health+(h and m and h/math.max(1,m) or 0) end
		return #ids>0 and health/#ids or 0
	end
	function R.risk(p,contacts,radius)
		local risk=0
		for _,v in ipairs(contacts) do if C.U.distance(p,v.position)<radius then
			if v.visibility=='VISUAL' then local d=C.classify.definition(v.defID); if d.range>0 then risk=risk+math.max(50,d.cost)*(v.role=='RIOT' and 3 or 1) end
			else risk=risk+150 end -- Unidentified contact: uncertainty, not inferred identity.
		end end
		return risk
	end
	function R.scout(s,ids,contacts,visits,now)
		local best,score,key; local center=C.U.center(ids)
		for i=1,4 do for _,side in ipairs({-1,1}) do
			local k=i..':'..side; local p=R.point(s,s.length*i/4,s.half*.7*side)
			if p then
				local los=Spring.GetPositionLosState(p[1],p[2],p[3])
				local value=R.risk(p,contacts,500)+(los and 800 or 0)+C.U.distance(center,p)*.1+math.max(0,60-(now-(visits[k] or -1000)))*30
				if not score or value<score then best,score,key=p,value,k end
			end
		end end
		return best,key
	end
	function R.raid(s,ids,contacts)
		local center=C.U.center(ids); local value=0; for _,id in ipairs(ids) do value=value+C.classify.definition(Spring.GetUnitDefID(id)).cost end
		local target,score
		for _,v in ipairs(contacts) do
			if v.visibility=='VISUAL' and v.defID and C.formations.inCorridor(s,v.position) then
				local d=C.classify.definition(v.defID); local def=UnitDefs[v.defID]
				if d.builder or (def.isBuilding and d.range==0) or v.role=='ARTILLERY' or v.role=='SKIRMISHER' then
					local risk=R.risk(v.position,contacts,450)
					if risk<math.max(100,value*1.25) then local cost=C.U.distance(center,v.position)+risk*2; if not score or cost<score then target,score=v.position,cost end end
				end
			end
		end
		return target
	end
	return R
end
