return function(C)
	local B={contacts={},last=-100,signature=''}
	function B.update(force)
		if not C.U.live() then B.contacts={}; B.signature=''; return end
		if not force and C.U.now()-B.last<.5 then return end; B.last=C.U.now()
		local contacts={}; local digest={}
		for _,id in ipairs(Spring.GetAllUnits()) do
			local team=Spring.GetUnitTeam(id)
			if team and not Spring.AreTeamsAllied(team,Spring.GetMyTeamID()) then
				local state=Spring.GetUnitLosState(id,Spring.GetMyAllyTeamID(),false)
				if state and (state.los or state.radar) then
					local p=C.U.position(id)
					if p then
						local def=state.los and Spring.GetUnitDefID(id) or nil
						local role=def and C.classify.definition(def).role or 'UNKNOWN'
						contacts[#contacts+1]={id=id,position=p,visibility=state.los and 'VISUAL' or 'RADAR',defID=def,role=role,time=B.last}
						digest[#digest+1]=id..':'..role..':'..math.floor(p[1]/256)..':'..math.floor(p[3]/256)
					end
				end
			end
		end
		table.sort(digest); B.signature=table.concat(digest,'|'); B.contacts=contacts
	end
	function B.nearCombat(p,r)
		for _,contact in ipairs(B.contacts) do if C.U.distance(p,contact.position)<r then return true end end; return false
	end
	function B.snapshot(center,radius)
		B.update(); local result={time=C.U.now(),contacts={},composition={},signature='',uncertainty='Unobserved space is unknown; radar contacts are not identified.'}; local keys={}
		for _,v in ipairs(B.contacts) do
			if not center or C.U.distance(center,v.position)<(radius or 1500) then
				result.contacts[#result.contacts+1]=C.U.copy(v); result.composition[v.role]=(result.composition[v.role] or 0)+1
				keys[#keys+1]=v.id..':'..v.role..':'..math.floor(v.position[1]/256)..':'..math.floor(v.position[3]/256)
			end
		end
		table.sort(keys); result.signature=table.concat(keys,'|'); return result
	end
	function B.economy()
		if not C.U.live() then return nil end
		local out={}
		for _,resource in ipairs({'metal','energy'}) do local current,storage,pull,income,expense=Spring.GetTeamResources(Spring.GetMyTeamID(),resource); out[resource]={current=current,storage=storage,pull=pull,income=income,expense=expense} end
		out.overdrive={energyChange=Spring.GetTeamRulesParam(Spring.GetMyTeamID(),'OD_energyChange'),energyIncome=Spring.GetTeamRulesParam(Spring.GetMyTeamID(),'OD_energyIncome'),energyOverdrive=Spring.GetTeamRulesParam(Spring.GetMyTeamID(),'OD_energyOverdrive')}
		-- Match the native Chili economy panel: remove OD transfer, restore gross generation.
		if out.overdrive.energyIncome~=nil then out.energy.nativeIncome=out.energy.income; out.energy.income=out.energy.income-math.max(0,out.overdrive.energyChange or 0)+out.overdrive.energyIncome end
		return out
	end
	return B
end
