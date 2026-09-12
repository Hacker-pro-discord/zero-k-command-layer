-- Health takes precedence over price: cheap critical units are never cover.
return function(C)
	local R={}
	function R.select(ids)
		local ordered=C.U.copy(ids); local data={}; local result={evacuate={},cover={},priority={},injured=0}
		for _,id in ipairs(ids) do
			local h,m=Spring.GetUnitHealth(id); local health=h and m and h/math.max(1,m) or 0
			local d=C.classify.definition(Spring.GetUnitDefID(id))
			data[id]={health=health,cost=d.cost or 0,role=d.role,ground=d.ground,range=d.range or 0,
				tier=health<.3 and 0 or health<.6 and 1 or 2}
			if health<.6 then result.injured=result.injured+1 end
		end
		table.sort(ordered,function(a,b)
			local x,y=data[a],data[b]
			if x.tier~=y.tier then return x.tier<y.tier end
			local vx,vy=x.cost*(2-x.health),y.cost*(2-y.health)
			return vx==vy and a<b or vx>vy
		end)
		for i,id in ipairs(ordered) do result.priority[id]=i end
		local candidates={}; local roles={RAIDER=true,RIOT=true,ASSAULT=true,OTHER=true}
		for _,id in ipairs(ids) do local d=data[id]; if d.health>=.65 and d.ground and d.range>0 and roles[d.role] then candidates[#candidates+1]=id end end
		table.sort(candidates,function(a,b) local x,y=data[a],data[b]; return x.cost==y.cost and (x.health==y.health and a<b or x.health>y.health) or x.cost<y.cost end)
		local covering={}; local cap=math.min(#ids-1,math.max(1,math.ceil(#ids*.3)))
		for i=1,math.min(cap,#candidates) do covering[candidates[i]]=true; result.cover[#result.cover+1]=candidates[i] end
		for _,id in ipairs(ordered) do if not covering[id] then result.evacuate[#result.evacuate+1]=id end end
		return result
	end
	return R
end
