return function(C)
	local K={cache={}}
	function K.definition(id)
		if K.cache[id] then return K.cache[id] end
		local d=UnitDefs[id]; if not d then return {role='OTHER',eligible=false} end
		local icon=(d.iconType or ''):lower()
		local builder=d.isBuilder or d.builder or (d.buildOptions and #d.buildOptions>0)
		local mobile=(d.speed or 0)>0 and not d.isFactory and not d.isBuilding
		local naval=icon:find('^ship') or icon:find('^sub')
		local v={role=builder and 'CONSTRUCTOR' or 'OTHER',reason='Capability classification',builder=builder,mobile=mobile,ground=mobile and not d.canFly and not naval,cost=d.metalCost or 0,radius=math.max(16,(d.xsize or 2)*4,(d.zsize or 2)*4),range=d.maxWeaponRange or 0,defID=id,name=d.name,display=d.humanName or d.name}
		if not builder then
			local rules={{'aa$','ANTI_AIR'},{'scout','SCOUT'},{'raider','RAIDER'},{'lrarty','ARTILLERY'},{'arty','ARTILLERY'},{'sniper','ARTILLERY'},{'tachyon','ARTILLERY'},{'skirm','SKIRMISHER'},{'riot','RIOT'},{'assault','ASSAULT'},{'support','SUPPORT'},{'jammer','SUPPORT'},{'shield','SUPPORT'}}
			for _,r in ipairs(rules) do if icon:find(r[1]) then v.role=r[2]; v.reason='Role icon: '..icon; break end end
			if v.role=='OTHER' then
				local text=(d.tooltip or d.description or ''):lower()
				for _,r in ipairs({{'anti%-air','ANTI_AIR'},{'artillery','ARTILLERY'},{'skirmisher','SKIRMISHER'},{'riot','RIOT'},{'assault','ASSAULT'},{'raider','RAIDER'},{'scout','SCOUT'},{'support','SUPPORT'}}) do if text:find(r[1]) then v.role=r[2]; v.reason='Definition description'; break end end
			end
		end
		K.cache[id]=v; return v
	end
	function K.filter(ids)
		local accepted,ordinary={},{}
		for _,id in ipairs(ids or {}) do
			if C.U.owned(id) then local d=K.definition(Spring.GetUnitDefID(id)); if d.ground and (not d.builder or C.settings.constructors) then accepted[#accepted+1]=id elseif d.mobile and not d.builder then ordinary[#ordinary+1]=id end end
		end
		table.sort(accepted); return accepted,ordinary
	end
	function K.force(ids)
		local groups={}; for _,id in ipairs(ids) do local d=K.definition(Spring.GetUnitDefID(id)); groups[d.role]=groups[d.role] or {}; table.insert(groups[d.role],id) end; return groups
	end
	return K
end
