-- Opt-in idle-factory production. Session authority is never persisted.
return function(C)
	local P={enabled=false,factories={},created={},last=-100,status='OFF'}
	function P.createdUnit(id,builder)
		if P.enabled and P.factories[builder] and C.U.owned(id) then P.created[id]=P.forceID end
	end
	function P.set(enabled)
		P.enabled=false; P.factories={}
		if not enabled then P.status='OFF; existing queues preserved'; return true end
		local f=C.registry.forces[C.registry.activeForce]
		if not f or not C.U.delegationAllowed(C.settings) then P.status='Assign a force in single-player testing first'; return false end
		P.forceID=f.id
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do
			local def=UnitDefs[Spring.GetUnitDefID(id)]
			if C.U.owned(id) and def and def.isFactory then P.factories[id]=true end
		end
		P.enabled=true; C.settings.autoAssign=true; P.status='ON: idle existing factories; manual factory commands release control'
		return true
	end
	function P.release(id) if P.factories[id] then P.factories[id]=nil; P.status='Factory '..id..' released by manual control' end end
	function P.valid(id,unit)
		if not P.enabled or not P.factories[id] or not C.U.delegationAllowed(C.settings) or not C.U.owned(id) then return false end
		local f=C.registry.forces[P.forceID]; if not f or #C.officer.members(f)==0 then return false end
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
		local f=C.registry.forces[P.forceID]; if not f or #C.officer.members(f)==0 then P.set(false); return end
		local groups=C.classify.force(C.officer.members(f)); local desired='ASSAULT'
		local battle=C.observations.snapshot(C.U.center(C.officer.members(f)),2000)
		if not groups.ANTI_AIR then desired='ANTI_AIR'
		elseif (battle.composition.RIOT or 0)>=2 then desired='SKIRMISHER'
		elseif not groups.ARTILLERY then desired='ARTILLERY'
		elseif not groups.RIOT then desired='RIOT' end
		local economy=C.observations.economy(); local metal=economy and economy.metal.current or 0
		if not economy or (economy.energy.current or 0)<100 then P.status='WAIT: retain 100 energy reserve'; return end
		-- Fair round-robin, one addition per idle factory per pass. Reserve spending
		-- locally because Spring resource values can lag several orders in a frame.
		local factories={}; for id in pairs(P.factories) do factories[#factories+1]=id end; table.sort(factories)
		local sent=0
		for offset=1,#factories do
			local index=((P.cursor or 0)+offset-1)%#factories+1; local id=factories[index]
			local best
			if C.U.owned(id) then
				local factory=UnitDefs[Spring.GetUnitDefID(id)]
				for _,bid in ipairs(factory and factory.buildOptions or {}) do
					local d=C.classify.definition(bid)
					if d.mobile and not d.builder and d.cost>0 and metal>=d.cost+100 and P.valid(id,bid) then
						local score=d.cost+(d.role==desired and 0 or 100000)
						if not best or score<best.score then best={unit=bid,score=score,role=d.role,cost=d.cost} end
					end
				end
			end
			if best and C.orders.production(id,best.unit) then
				metal=metal-best.cost; sent=sent+1
				C.debug.log('PRODUCTION','Factory '..id..': queued '..(UnitDefs[best.unit].humanName or UnitDefs[best.unit].name)..' ('..best.role..'), '..best.cost..' metal. Desired role: '..desired)
			end
		end
		P.cursor=#factories>0 and ((P.cursor or 0)+1)%#factories or 0
		P.status=sent>0 and ('Queued '..sent..' factories; reserved metal remaining '..math.floor(metal)) or 'WAIT: busy/released factories or insufficient stored resources (100 metal reserve)'
	end
	return P
end
