-- Read-only spending policy; never reads opponent team resources or issues orders.
return function(C)
	local B={active=false,last=-100,status='NORMAL'}
	function B.update()
		local now=C.U.now()
		if not C.U.delegationAllowed(C.settings) or not (C.economy and C.economy.enabled and C.productionControl and C.productionControl.enabled) then
			B.active=false; B.since=nil; B.clearSince=nil; B.capacitySince=nil; B.capacityNeeded=false; B.status='NORMAL'; B.last=-100; return B
		end
		if now-B.last<2 then return B end; B.last=now
		local model=C.enemyModel.snapshot(); local resources=C.observations.economy(); if not resources then return B end
		local army,builders,capacity,busy,factories,pending=0,0,0,0,0,false
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do if C.U.owned(id) then
			local defID=Spring.GetUnitDefID(id); local raw=UnitDefs[defID]; local v=C.classify.definition(defID); local _,_,_,_,built=Spring.GetUnitHealth(id)
			if built==nil or built>=1 then
				if v.mobile and not v.builder then army=army+v.cost end
				if v.mobile and v.builder then builders=builders+1 end
				if raw.isFactory then
					capacity=capacity+math.max(10,raw.buildSpeed or 18); factories=factories+1
					if #(Spring.GetFactoryCommands(id,1) or {})>0 then busy=busy+1 end
				end
			elseif raw.isFactory then pending=true end
		end end
		local enemyArmy=model.militaryValue or 0; local enemyIncome=model.observedIncome or 0
		local income=resources.metal.income or 0
		local credible=(model.incomeSamples or 0)>=3 and (model.incomeWeight or 0)/math.max(1,model.incomeSamples or 0)>=.5
		local parity=credible and enemyIncome>0 and income>=enemyIncome*.8 and income<=enemyIncome*1.5
		local behind=enemyArmy>=600 and army<enemyArmy*.65
		local was=B.active
		if not B.active then
			if parity and behind then B.since=B.since or now; if now-B.since>=15 then B.active=true; B.started=now; B.clearSince=nil end else B.since=nil end
		else
			local clear=not parity or enemyArmy<600 or army>=enemyArmy*.85
			if clear then B.clearSince=B.clearSince or now; if now-B.clearSince>=30 then B.active=false; B.since=nil; B.clearSince=nil end else B.clearSince=nil end
		end
		local saturated=B.active and factories>0 and busy/factories>=.75 and not pending and income>capacity*1.1 and resources.metal.current>=math.max(150,income*5) and (resources.energy.income or 0)>=income and resources.energy.current>=100
		if saturated then B.capacitySince=B.capacitySince or now else B.capacitySince=nil end
		B.capacityNeeded=B.capacitySince~=nil and now-B.capacitySince>=20
		B.army=army; B.enemyArmy=enemyArmy; B.enemyIncome=enemyIncome; B.builders=builders; B.capacity=capacity
		B.status=B.active and string.format('MILITARY CATCH-UP: army %.0f / observed %.0f; income %.1f / observed mex %.1f. %s',army,enemyArmy,income,enemyIncome,B.capacityNeeded and 'Add saturated production capacity.' or 'Defer optional infrastructure; prioritize counter units.') or 'NORMAL: no sustained, sufficiently observed parity/army-deficit trigger.'
		if was~=B.active then C.debug.log('MILITARY BUDGET',B.status) end
		return B
	end
	return B
end
