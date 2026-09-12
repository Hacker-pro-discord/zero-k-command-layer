return function(C)
	local P={items={},nextID=0}
	function P.create(f,kind,plan,reason)
		if not C.U.assisted(C.settings) or not C.U.live() then return nil end
		for _,old in pairs(P.items) do if old.forceID==f.id and old.state=='OFFERED' then old.state='INVALIDATED' end; if old.forceID==f.id then old.dismissed=true end end
		P.nextID=P.nextID+1
		local p={id=P.nextID,revision=1,forceID=f.id,forceRevision=f.revision,kind=kind,plan=C.U.copy(plan),units=C.officer.members(f),generations={},positions={},health={},state='OFFERED',created=C.U.now(),expires=C.U.now()+C.settings.proposalLifetime,reason=reason,mode=C.settings.mode}
		for _,id in ipairs(p.units) do p.generations[id]=C.registry.generation[id] or 0; p.positions[id]=C.U.position(id); local h,m=Spring.GetUnitHealth(id); p.health[id]=h and m and h/math.max(1,m) or 0 end
		local a,b=plan.origin,plan.center; p.observeCenter={(a[1]+b[1])/2,0,(a[3]+b[3])/2}; p.observeRadius=C.U.distance(a,b)/2+math.max(1000,plan.width)
		p.observation=C.observations.snapshot(p.observeCenter,p.observeRadius)
		p.summary=kind..' using native Fight / '..plan.shape..'\n'..#p.units..' mobile units. Destination: '..math.floor(b[1])..', '..math.floor(b[3])..'\n\nReason: '..reason..'\n\nUncertainty: '..p.observation.uncertainty..'\n\nEnds on arrival, cancellation or override. One action only. Approval valid for '..C.settings.proposalLifetime..' game seconds. Aircraft/ships receive ordinary Fight destinations.'
		for key,old in pairs(P.items) do if key<p.id-100 and old.state~='OFFERED' and old.state~='EXECUTING' then P.items[key]=nil end end
		P.items[p.id]=p; f.lastSuggestion=C.U.now(); C.debug.log('PROPOSAL','Force '..f.id..': '..kind..' awaiting approval.'); return p.id
	end
	function P.valid(p,fresh)
		if not p or p.state~='OFFERED' or not C.U.assisted(C.settings) or not C.U.live() then return false,'INVALIDATED' end
		if C.U.now()>=p.expires then return false,'EXPIRED' end
		local f=C.registry.forces[p.forceID]; if not f or f.revision~=p.forceRevision then return false,'INVALIDATED' end
		local ids=p.units -- Approval covers its snapshot; added recruits never enlarge it.
		for _,id in ipairs(ids) do if not f.members[id] or f.suspended[id] or not C.U.owned(id) or (C.registry.generation[id] or 0)~=p.generations[id] then return false,'INVALIDATED' end end
		for _,id in ipairs(ids) do local pos=C.U.position(id); local h,m=Spring.GetUnitHealth(id); local health=h and m and h/math.max(1,m) or 0; if not pos or C.U.distance(pos,p.positions[id])>128 or health<p.health[id]-.15 then return false,'INVALIDATED' end end
		C.observations.update(fresh)
		if C.observations.snapshot(p.observeCenter,p.observeRadius).signature~=p.observation.signature then return false,'INVALIDATED' end
		return true
	end
	function P.approve(id,revision)
		local p=P.items[id]; if not p or p.revision~=revision then return false end
		local ok,reason=P.valid(p,true); if not ok then if p.state=='OFFERED' then p.state=reason end; C.debug.log('EXPIRED','Proposal changed or expired. Ask Officer for a fresh plan.'); return false end
		-- Consume before execution: callbacks and repeated clicks cannot reuse approval.
		p.state='APPROVED'
		if not C.officer.executeProposal then p.state='CANCELLED'; return false end
		return C.officer.executeProposal(p)
	end
	function P.dismiss(id) local p=P.items[id]; if p then p.dismissed=true; if p.state=='OFFERED' then P.decline(id) end end end
	function P.decline(id)
		local p=P.items[id]; if not p or p.state~='OFFERED' then return end
		p.state='DECLINED'; local f=C.registry.forces[p.forceID]; if f then f.declined[p.kind]=C.U.now()+60 end
		C.input.preview=nil
	end
	function P.firstOffered()
		for id=1,P.nextID do local p=P.items[id]; if p and not p.dismissed and (p.state=='OFFERED' or p.state=='EXPIRED' or p.state=='INVALIDATED') then return p end end
	end
	function P.update()
		local now=C.U.now(); if P.lastUpdate and now-P.lastUpdate<.5 then return end; P.lastUpdate=now
		for _,p in pairs(P.items) do if p.state=='OFFERED' then local ok,why=P.valid(p); if not ok then p.state=why; if C.input then C.input.preview=nil end end end end
	end
	return P
end
