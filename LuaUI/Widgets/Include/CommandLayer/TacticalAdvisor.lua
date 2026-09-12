return function(C)
	local T={last=-100}
	function T.ask(forceID,explicit)
		local f=C.registry.forces[forceID]
		if not f or not C.settings.privateSession or not C.U.live() then C.debug.log('LOCKED','Assign an adviser force in local/private testing.'); return nil end
		local op=f.operation and C.registry.operations[f.operation]; if op and op.active then return nil end
		if not explicit and C.U.now()-f.lastSuggestion<30 then return nil end
		local ids=C.officer.members(f); if #ids==0 then return nil end
		if C.production then f.advice=C.production.recommend(f) end
		local center=C.U.center(ids); local settings=C.U.copy(C.settings); settings.formation=f.formation
		local width=math.max(256,math.ceil(#ids/2)*settings.spacing)
		local points={{center[1]-width/2,center[2],center[3]},{center[1]+width/2,center[2],center[3]}}
		local kind='REFORM'; local reason='Restore role zones around the current force position.'
		local maxDistance=0; local health=0
		for _,id in ipairs(ids) do maxDistance=math.max(maxDistance,C.U.distance(center,C.U.position(id))); local h,m=Spring.GetUnitHealth(id); health=health+(h and m and h/math.max(1,m) or 0) end
		if f.objective and not f.objectiveReached and maxDistance<math.max(500,width) and health/#ids>.5 then
			kind='PUSH'; points=f.objective; reason='Force is assembled enough for one player-defined advance. Native Fight handles combat.'
		end
		if not explicit and f.declined[kind] and f.declined[kind]>C.U.now() then return nil end
		local plan=C.formations.plan(ids,points,settings); if not plan then return nil end
		local error=0; for _,id in ipairs(ids) do error=error+C.U.distance(C.U.position(id),plan.slots[id]) end
		if not explicit and kind=='REFORM' and error/#ids<settings.spacing*2 then f.lastSuggestion=C.U.now(); return nil end
		local observed=C.observations.snapshot(plan.center,math.max(1000,plan.width))
		if #observed.contacts>0 then reason=reason..' '..#observed.contacts..' visual/radar contacts nearby; this is not a safety assessment.' else reason=reason..' No contact currently observed near the destination; fog remains unknown.' end
		local ax,az=plan.origin[1],plan.origin[3]; local bx,bz=plan.center[1],plan.center[3]; local dx,dz=bx-ax,bz-az; local d=math.max(1,math.sqrt(dx*dx+dz*dz)); local px,pz=-dz/d,dx/d; if d<=1 then px,pz=1,0 end
		local half=plan.width/2+128
		plan.corridor={{ax+px*half,0,az+pz*half},{bx+px*half,0,bz+pz*half},{bx-px*half,0,bz-pz*half},{ax-px*half,0,az-pz*half}}
		return C.proposals.create(f,kind,plan,reason)
	end
	function T.update()
		if not C.settings.privateSession or C.U.now()-T.last<.5 then return end; T.last=C.U.now()
		for id,f in pairs(C.registry.forces) do
			local has=false; for _,p in pairs(C.proposals.items) do if p.forceID==id and p.state=='OFFERED' then has=true; break end end
			if not has and C.U.now()-f.lastSuggestion>=30 then T.ask(id,false) end
		end
	end
	return T
end
