-- Opt-in idle-factory production. Session authority is never persisted.
return function(C)
	local P={enabled=false,factories={},excluded={},created={},last=-100,status='OFF'}
	function P.createdUnit(id,builder)
		if P.enabled and P.factories[builder] and C.U.owned(id) then P.created[id]=P.forceID end
	end
	function P.set(enabled)
		P.enabled=false; P.factories={}; P.excluded={}
		if not enabled then P.status='OFF; existing queues preserved'; return true end
		local f=C.registry.forces[C.registry.activeForce] or C.officer.ensureForce()
		if not f or not C.U.delegationAllowed(C.settings) then P.status='Assign a force in single-player testing first'; return false end
		P.forceID=f.id
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do
			local def=UnitDefs[Spring.GetUnitDefID(id)]
			if C.U.owned(id) and def and def.isFactory then P.factories[id]=true end
		end
		P.enabled=true; P.last=-100; C.officer.setAutoAssign(true); P.status='ON: idle existing factories; manual factory commands release control'
		return true
	end
	function P.enroll(ids)
		if not C.U.delegationAllowed(C.settings) then return false end
		local f=C.registry.forces[P.forceID or C.registry.activeForce] or C.officer.ensureForce(); if not f then return false end
		local count=0
		for _,id in ipairs(ids or Spring.GetSelectedUnits()) do local def=UnitDefs[Spring.GetUnitDefID(id)]; if C.U.owned(id) and def and def.isFactory then P.excluded[id]=nil; P.factories[id]=true; count=count+1 end end
		if count>0 then P.forceID=f.id; P.enabled=true; P.last=-100; C.officer.setAutoAssign(true,f.id); P.status='Re-enrolled '..count..' factories; existing queues preserved' end
		return count>0
	end
	function P.release(id) P.excluded[id]=true; if P.factories[id] then P.factories[id]=nil; P.status='Factory '..id..' released by manual control' end end
	function P.valid(id,unit)
		if not P.enabled or not P.factories[id] or not C.U.delegationAllowed(C.settings) or not C.U.owned(id) then return false end
		local f=C.registry.forces[P.forceID]; if not f then return false end
		local d=UnitDefs[Spring.GetUnitDefID(id)]; local _,_,_,_,built=Spring.GetUnitHealth(id)
		if not d or not d.isFactory or built and built<1 or Spring.GetUnitIsStunned and Spring.GetUnitIsStunned(id) then return false end
		local queue=Spring.GetFactoryCommands(id,1); if not queue or #queue>0 then return false end
		for _,bid in ipairs(d.buildOptions or {}) do if bid==unit then return true end end
		return false
	end
	function P.update()
		if not P.enabled then return end
		if not C.U.delegationAllowed(C.settings) then P.set(false); return end
		local now=C.U.now(); if now-P.last<5 then return end; P.last=now
		local f=C.registry.forces[P.forceID]; if not f then P.set(false); return end
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do local def=UnitDefs[Spring.GetUnitDefID(id)]; if def and def.isFactory and C.U.owned(id) and not P.excluded[id] then P.factories[id]=true end end
		local members=C.officer.members(f); local groups=C.classify.force(members); local desired='ASSAULT'
		local battle=C.observations.snapshot(C.U.center(C.officer.members(f)),2000)
		if #members<5 then desired='RAIDER'
		elseif not groups.ANTI_AIR then desired='ANTI_AIR'
		elseif (battle.composition.RIOT or 0)>=2 then desired='SKIRMISHER'
		elseif not groups.ARTILLERY then desired='ARTILLERY'
		elseif not groups.RIOT then desired='RIOT' end
		local weights,model,friendly,total
		if C.enemyModel then weights,model=C.enemyModel.weights(); friendly,total=C.enemyModel.friendly(); P.intel=model end
		local economy=C.observations.economy(); local metal=economy and economy.metal.current or 0
		if not economy or (economy.energy.current or 0)<100 then P.status='WAIT: retain 100 energy reserve'; return end
		-- Fair round-robin, one addition per idle factory per pass. Reserve spending
		-- locally because Spring resource values can lag several orders in a frame.
		local factories={}; for id in pairs(P.factories) do factories[#factories+1]=id end; table.sort(factories)
		local counterMode=weights and #members>=5
		if weights and not counterMode and C.matchups then
			for _,id in ipairs(factories) do local def=UnitDefs[Spring.GetUnitDefID(id)]
				for _,bid in ipairs(def and def.buildOptions or {}) do local unit=C.classify.definition(bid)
					if unit.mobile and not unit.builder then local _,coverage=C.matchups.bias(unit,model); if coverage>0 then counterMode=true; break end end
				end
				if counterMode then break end
			end
		end
		local workerNeed=C.recovery and C.recovery.workerNeed() or 0
		local economicNeed=C.economy and C.economy.workerNeed() or 0
		local recoveryReserve=C.recovery and C.recovery.reserveMetal() or 0
		local budget=C.militaryBudget and C.militaryBudget.update()
		local catchup=budget and budget.active
		if catchup and budget.builders>0 then workerNeed=0; economicNeed=0 end
		local buffer=catchup and 40 or 100
		local sent=0
		for offset=1,#factories do
			local index=((P.cursor or 0)+offset-1)%#factories+1; local id=factories[index]
			local best
			if C.U.owned(id) then
				local factory=UnitDefs[Spring.GetUnitDefID(id)]
				for _,bid in ipairs(factory and factory.buildOptions or {}) do
					local d=C.classify.definition(bid)
					local economic=economicNeed>0 and d.mobile and d.builder
					local recovery=workerNeed>0 and (C.recovery.workerDefinition and C.recovery.workerDefinition(bid) or UnitDefs[bid].name=='cloakcon')
					local funding=d.cost
					local sustainable=not (C.economy and C.economy.enabled) or d.cost<=math.max(400,(economy.metal.income or 0)*60) or metal>=d.cost+100
					if C.economy and C.economy.enabled then funding=math.min(d.cost,math.max(65,(economy.metal.income or 0)*6)) end
					if sustainable and d.mobile and (not d.builder or recovery or economic) and d.cost>0 and metal>=funding+buffer+((recovery or economic) and 0 or recoveryReserve) and P.valid(id,bid) then
						local score=recovery and -1000000 or economic and -500000+d.cost or counterMode and -C.enemyModel.score(d,weights,friendly,total,model) or d.cost+(d.role==desired and 0 or 100000)
						if not best or score<best.score then best={unit=bid,score=score,role=d.role,cost=d.cost,recovery=recovery,economic=economic,funding=funding} end
					end
				end
			end
			if best and C.orders.production(id,best.unit) then
				metal=metal-best.funding; sent=sent+1; if best.recovery then workerNeed=workerNeed-1 end; if best.economic then economicNeed=economicNeed-1 end
				if friendly then friendly[best.role]=(friendly[best.role] or 0)+best.cost; total=total+best.cost end
				local matchup=''
				if C.matchups and model and counterMode and not best.economic and not best.recovery then local bias,coverage,why=C.matchups.bias(C.classify.definition(best.unit),model); matchup=string.format(' Unit matrix: bias %.3f, effective coverage %.0f%%; %s.',bias,coverage*100,why) end
				C.debug.log('PRODUCTION','Factory '..id..': queued '..(UnitDefs[best.unit].humanName or UnitDefs[best.unit].name)..' ('..best.role..'), '..best.cost..' metal. '..(counterMode and ('Shared counter deficits; intel half-life '..model.halfLife..'s; '..model.unknown..' unknown radar contacts.') or 'Desired role: '..desired)..matchup)
			end
		end
		P.cursor=#factories>0 and ((P.cursor or 0)+1)%#factories or 0
		P.status=(catchup and 'MILITARY CATCH-UP: ' or '')..(sent>0 and ('Queued '..sent..' factories; reserved metal remaining '..math.floor(metal)) or ('WAIT: busy/released factories or insufficient stored resources ('..buffer..' metal reserve)'))
	end
	return P
end
