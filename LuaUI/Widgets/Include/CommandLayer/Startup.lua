-- Explicit session-only map-control authority. No enemy coordinates are consulted.
return function(C)
	local S={enabled=false,last=-100}
	function S.stop(forceID)
		if not forceID or S.forceID==forceID then S.enabled=false end
	end
	function S.start()
		if not C.U.delegationAllowed(C.settings) then C.debug.log('LOCKED','Enable LOCAL / PRIVATE TEST SESSION first; autonomous startup is single-player only.'); return false end
		local f=C.officer.ensureForce(); if not f then return false end
		C.officer.setAutoAssign(true); S.forceID=f.id; S.enabled=true; S.last=-100
		C.productionControl.set(true)
		S.update(); return true
	end
	function S.update()
		if not C.U.assisted(C.settings) then S.enabled=false; return end
		local now=C.U.now(); if now-S.last<1 then return end; S.last=now
		if C.settings.autoAssign then
			local f=C.registry.forces[C.officer.recruitForce] or C.officer.ensureForce()
			if f then C.officer.recruitForce=f.id; for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do C.officer.autoAssign(id,f.id) end end
		end
		if not S.enabled then return end
		if not C.U.delegationAllowed(C.settings) then S.stop(); return end
		local f=C.registry.forces[S.forceID]; if not f then S.stop(); return end
		local ids=C.officer.members(f); if #ids==0 then f.status='WAITING FOR FIRST MILITARY UNIT'; return end
		if f.delegation and f.delegation.active then return end
		if not f.objective then
			local base=C.U.center(ids); local dx,dz=Game.mapSizeX/2-base[1],Game.mapSizeZ/2-base[3]
			-- Choose the long cardinal approach toward the opposite map quarter.
			local a,b
			if math.abs(dx)>math.abs(dz) then
				local x=Game.mapSizeX*(dx>=0 and .8 or .2)
				a={x,0,Game.mapSizeZ*.1}; b={x,0,Game.mapSizeZ*.9}
			else
				local z=Game.mapSizeZ*(dz>=0 and .8 or .2)
				a={Game.mapSizeX*.1,0,z}; b={Game.mapSizeX*.9,0,z}
			end
			C.officer.objective(f.id,{a,b})
		end
		f.objectiveMode='WIN OBJECTIVE'
		if not C.officer.setDelegated(f.id,true) then S.stop() end
	end
	return S
end
