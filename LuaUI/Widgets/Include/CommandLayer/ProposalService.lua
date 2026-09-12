return function(C)
	local P={items={},nextID=0}
	function P.create(f,kind,plan,reason)
		if not C.settings.privateSession or not C.U.live() then return nil end
		for _,old in pairs(P.items) do if old.forceID==f.id and old.state=='OFFERED' then old.state='INVALIDATED' end end
		P.nextID=P.nextID+1
		local p={id=P.nextID,revision=1,forceID=f.id,forceRevision=f.revision,kind=kind,plan=C.U.copy(plan),units=C.officer.members(f),generations={},state='OFFERED',created=C.U.now(),expires=C.U.now()+15,reason=reason,mode=C.settings.mode}
		for _,id in ipairs(p.units) do p.generations[id]=C.registry.generation[id] or 0 end
		local a,b=plan.origin,plan.center; p.observeCenter={(a[1]+b[1])/2,0,(a[3]+b[3])/2}; p.observeRadius=C.U.distance(a,b)/2+math.max(1000,plan.width)
		p.observation=C.observations.snapshot(p.observeCenter,p.observeRadius)
		p.summary=kind..' using '..plan.shape..'\n'..#p.units..' ground units. Destination: '..math.floor(b[1])..', '..math.floor(b[3])..'\n\nReason: '..reason..'\n\nUncertainty: '..p.observation.uncertainty..'\n\nEnds on arrival, cancellation or override. One action only. Expires in 15 game seconds.'
		P.items[p.id]=p; f.lastSuggestion=C.U.now(); C.debug.log('PROPOSAL','Force '..f.id..': '..kind..' awaiting approval.'); return p.id
	end
	function P.valid(p)
		if not p or p.state~='OFFERED' or not C.settings.privateSession or not C.U.live() then return false,'INVALIDATED' end
		if C.U.now()>=p.expires then return false,'EXPIRED' end
		local f=C.registry.forces[p.forceID]; if not f or f.revision~=p.forceRevision then return false,'INVALIDATED' end
		local ids=C.officer.members(f); if #ids~=#p.units then return false,'INVALIDATED' end
		for i,id in ipairs(ids) do if id~=p.units[i] or (C.registry.generation[id] or 0)~=p.generations[id] then return false,'INVALIDATED' end end
		C.observations.update(true)
		if C.observations.snapshot(p.observeCenter,p.observeRadius).signature~=p.observation.signature then return false,'INVALIDATED' end
		return true
	end
	function P.approve(id,revision)
		local p=P.items[id]; if not p or p.revision~=revision then return false end
		local ok,reason=P.valid(p); if not ok then if p.state=='OFFERED' then p.state=reason end; C.debug.log('EXPIRED','Proposal changed or expired. Ask Officer for a fresh plan.'); return false end
		-- Consume before execution: callbacks and repeated clicks cannot reuse approval.
		p.state='APPROVED'
		if not C.officer.executeProposal then p.state='CANCELLED'; return false end
		return C.officer.executeProposal(p)
	end
	function P.decline(id)
		local p=P.items[id]; if not p or p.state~='OFFERED' then return end
		p.state='DECLINED'; local f=C.registry.forces[p.forceID]; if f then f.declined[p.kind]=C.U.now()+60 end
		C.input.preview=nil
	end
	function P.firstOffered()
		for id=1,P.nextID do local p=P.items[id]; if p.state=='OFFERED' then return p end end
	end
	function P.update()
		for _,p in pairs(P.items) do if p.state=='OFFERED' then local ok,why=P.valid(p); if not ok then p.state=why; if C.input then C.input.preview=nil end end end end
	end
	return P
end
