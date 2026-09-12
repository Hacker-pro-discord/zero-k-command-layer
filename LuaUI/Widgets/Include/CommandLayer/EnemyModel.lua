-- Historical sightings, not current hidden state. Never renew identity from radar.
return function(C)
	local E={seen={},last=-100}
	function E.snapshot()
		if not C.U.delegationAllowed(C.settings) then E.seen={}; return {roles={},value={},total=0,unknown=0,halfLife=C.settings.intelHalfLife or 90} end
		local now=C.U.now(); local live=C.observations.snapshot(); local unknown=0
		for _,v in ipairs(live.contacts) do
			if v.visibility=='VISUAL' and v.defID then
				local def=UnitDefs[v.defID]; local role=def and def.canFly and 'AIR' or v.role
				if def and (def.isBuilding or def.isFactory) and C.classify.definition(v.defID).range>0 then role='DEFENSE' end
				E.seen[v.id]={role=role,cost=def and def.metalCost or 0,time=v.time or live.time or now}
			elseif v.visibility=='RADAR' then unknown=unknown+1 end
		end
		local out={roles={},value={},rawValue={},total=0,unknown=unknown,time=now,halfLife=C.settings.intelHalfLife or 90}
		for id,v in pairs(E.seen) do
			local age=math.max(0,now-v.time)
			if age>out.halfLife*6 then E.seen[id]=nil else
				local weight=2^(-age/out.halfLife)
				out.roles[v.role]=(out.roles[v.role] or 0)+weight
				out.rawValue[v.role]=(out.rawValue[v.role] or 0)+math.max(50,v.cost)
				out.value[v.role]=(out.value[v.role] or 0)+math.max(50,v.cost)*weight
				out.total=out.total+math.max(50,v.cost)*weight
			end
		end
		E.latest=out; return out
	end
	function E.destroyed(id) if C.U.delegationAllowed(C.settings) and Spring.GetUnitLosState then local state=Spring.GetUnitLosState(id,Spring.GetMyAllyTeamID(),false); if state and state.los then E.seen[id]=nil end end end
	function E.update() if C.U.now()-E.last>=1 then E.last=C.U.now(); E.snapshot() end end
	function E.weights()
		local model=E.snapshot()
		local weights={RAIDER=3,RIOT=2,SKIRMISHER=2,ASSAULT=3,ARTILLERY=1,ANTI_AIR=1,SUPPORT=.5,OTHER=.5,SCOUT=.3}
		local counters={RAIDER={RIOT=9},SCOUT={RIOT=5},RIOT={SKIRMISHER=9},ASSAULT={SKIRMISHER=7,RAIDER=2},SKIRMISHER={RAIDER=8},ARTILLERY={RAIDER=7},AIR={ANTI_AIR=14},DEFENSE={ARTILLERY=10,ASSAULT=3}}
		local confidenceBase=0; for role,value in pairs(model.rawValue or {}) do if counters[role] then confidenceBase=confidenceBase+value end end
		for role,value in pairs(model.value) do for counter,bias in pairs(counters[role] or {}) do weights[counter]=weights[counter]+bias*value/math.max(300,confidenceBase) end end
		return weights,model
	end
	function E.friendly()
		local roles,total={},0
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do if C.U.owned(id) then
			local v=C.classify.definition(Spring.GetUnitDefID(id)); local _,_,_,_,built=Spring.GetUnitHealth(id)
			if v.mobile and not v.builder and (not built or built>=1) then roles[v.role]=(roles[v.role] or 0)+v.cost; total=total+v.cost end
			local def=UnitDefs[Spring.GetUnitDefID(id)]
			if def and def.isFactory and Spring.GetFactoryCommands then for _,q in ipairs(Spring.GetFactoryCommands(id,-1) or {}) do
				if q.id and q.id<0 then local unit=C.classify.definition(-q.id); if unit.mobile and not unit.builder then local value=unit.cost*(q.params and tonumber(q.params[1]) or 1); roles[unit.role]=(roles[unit.role] or 0)+value; total=total+value end end
			end end
		end end
		return roles,total
	end
	function E.score(unit,weights,friendly,total)
		local sum=0; for _,w in pairs(weights) do sum=sum+w end
		local fraction=(weights[unit.role] or .5)/sum
		-- Shared unmet value demand; cheap units cannot monopolize every factory.
		return (fraction*(total+math.max(500,total*.25))-(friendly[unit.role] or 0))/math.max(100,unit.cost)^.5
	end
	return E
end
