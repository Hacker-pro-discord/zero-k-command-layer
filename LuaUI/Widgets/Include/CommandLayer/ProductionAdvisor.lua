return function(C)
	local A={}
	function A.recommend(f)
		if not C.U.assisted(C.settings) or not C.U.live() then return 'Production advice is available only in a local/private test session.' end
		local counterWeights,counterModel,counterFriendly,counterTotal
		local ids=C.officer.members(f); local groups=C.classify.force(ids); local center=C.U.center(ids)
		local battle=C.observations.snapshot(center,1600); local desired,reason='ASSAULT','Add a durable frontline capability.'
		local air=0; for _,contact in ipairs(battle.contacts) do if contact.defID and UnitDefs[contact.defID].canFly then air=air+1 end end
		if air>0 and not groups.ANTI_AIR then desired='ANTI_AIR'; reason='Visible aircraft and no AA in this assigned force.'
		elseif (battle.composition.RIOT or 0)>=2 then desired='SKIRMISHER'; reason='Visible riot concentration favors adding ranged support.'
		elseif (battle.composition.RAIDER or 0)>=3 and not groups.RIOT then desired='RIOT'; reason='Visible raiders and no riot capability in this force.'
		elseif not groups.ANTI_AIR then desired='ANTI_AIR'; reason='The assigned force lacks AA; this is a composition gap, not evidence of enemy air.'
		elseif not groups.ARTILLERY then desired='ARTILLERY'; reason='The assigned force lacks long-range support.' end
		if C.enemyModel and C.U.delegationAllowed(C.settings) then
			local weights,model=C.enemyModel.weights(); local friendly,total=C.enemyModel.friendly(); local sum=0; for _,weight in pairs(weights) do sum=sum+weight end
			counterWeights,counterModel,counterFriendly,counterTotal=weights,model,friendly,total
			local deficit=-math.huge; for role,weight in pairs(weights) do local missing=(total+1000)*weight/math.max(1,sum)-(friendly[role] or 0); if missing>deficit then desired=role; deficit=missing end end
			reason='Shared army/queue composition gap with decaying visual counter intel (half-life '..model.halfLife..'s). '..model.unknown..' radar contacts remain unidentified. Role weights are a heuristic.'
		end
		local existing={}; local buildable={}
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID())) do
			local defID=Spring.GetUnitDefID(id); local d=defID and UnitDefs[defID]
			if d then
				if d.isFactory then existing[defID]=true end
				if d.isBuilder then for _,bid in ipairs(d.buildOptions or {}) do if UnitDefs[bid] and UnitDefs[bid].isFactory then buildable[bid]=true end end end
			end
		end
		local function candidate(factories)
			local best,matrixBest,covered
			for factory in pairs(factories) do
				for _,uid in ipairs(UnitDefs[factory].buildOptions or {}) do
					local d=C.classify.definition(uid)
					if C.matchups and counterModel and d.mobile and not d.builder and d.cost>0 then
						local score,detail=C.enemyModel.score(d,counterWeights,counterFriendly,counterTotal,counterModel)
						if detail and detail.coverage>0 then covered=true end
						if not matrixBest or score>matrixBest.score or score==matrixBest.score and uid<matrixBest.unit then matrixBest={factory=factory,unit=uid,cost=d.cost,score=score,detail=detail} end
					end
					if d.role==desired and d.mobile then
						local cost=d.cost; if not best or cost<best.cost or cost==best.cost and uid<best.unit then best={factory=factory,unit=uid,cost=cost} end
					end
				end
			end
			return covered and matrixBest or best
		end
		local chosen=candidate(existing); local newFactory=false
		if not chosen then chosen=candidate(buildable); newFactory=chosen~=nil end
		if not chosen then return 'Advice: '..desired..'. '..reason..' No matching currently known factory/build option. Check unlocks and available production. Unknown radar contacts are not identified.' end
		if chosen.detail then reason=reason..string.format(' Unit matrix %s: %s; effective coverage %.0f%%. Draft preferences, not measured win probabilities.',chosen.detail.revision,chosen.detail.reason,chosen.detail.coverage*100) end
		local factory=UnitDefs[chosen.factory]; local unit=UnitDefs[chosen.unit]
		local economy=C.observations.economy(); local stock=economy and economy.metal.current
		local text='ADVICE ONLY: '..(unit.humanName or unit.name)..' from '..(factory.humanName or factory.name)..'. '..reason
		text=text..' Unit: '..math.floor(chosen.cost)..' metal.'
		if newFactory then text=text..' New factory investment: '..math.floor(factory.metalCost or 0)..' metal. No existing factory offers the requested role.' else text=text..' Uses an existing factory.' end
		text=text..' Stored metal: '..(stock and math.floor(stock) or 'unknown')..'; income also funds other queues. Terrain/unlocks and energy may limit construction. Radar and fog remain uncertain.'
		return text
	end
	return A
end
