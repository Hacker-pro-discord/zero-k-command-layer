-- Explicit session-only map-control authority. No enemy coordinates are consulted.
return function(C)
	local S={enabled=false,last=-100,booted=false}
	function S.boot()
		if S.booted or not C.U.live() then return end
		S.booted=true
		local gate=C.U.copy(C.settings); gate.privateSession=true
		if C.settings.autoPlay and C.U.delegationAllowed(gate) then C.officer.setSession(true); S.start() end
	end
	function S.stop(forceID)
		if not forceID or S.forceID==forceID then S.enabled=false; if C.recovery then C.recovery.stop() end; if C.arsenal then C.arsenal.stop() end; S.booted=S.booted or C.U.live() end
	end
	function S.start()
		if not C.U.delegationAllowed(C.settings) then C.debug.log('LOCKED','Enable LOCAL / PRIVATE TEST SESSION first; autonomous startup is single-player only.'); return false end
		local f=C.officer.ensureForce(); if not f then return false end
		if f.delegation and f.delegation.active then C.officer.setDelegated(f.id,false) end
		f.objective=nil; f.mapControl=true; if C.mapControl then C.mapControl.initialize(f) end
		C.officer.setAutoAssign(true); S.forceID=f.id; S.enabled=true; S.last=-100
		C.productionControl.set(true); if C.recovery then C.recovery.start() end
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
		f.mapControl=true; f.objectiveMode='MAP CONTROL'
		if not C.officer.setDelegated(f.id,true) then S.stop() end
	end
	return S
end
