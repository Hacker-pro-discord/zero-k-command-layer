return function(C)
	local A={}
	function A.submit(intent,ids)
		if not C.U.live() then return nil end
		ids=ids or Spring.GetSelectedUnits(); local eligible,ordinary=C.classify.filter(ids)
		if #eligible==0 then return nil end
		local plan=intent.plan or C.formations.plan(eligible,intent.gesture,intent.settings)
		if not plan then return nil end
		if not intent.approved then C.registry.release(eligible,'PLAYER_OVERRIDE') end
		local all=C.U.copy(eligible); for _,id in ipairs(ordinary) do all[#all+1]=id end
		local op=C.registry.newOperation(all); op.plan=plan; op.command=intent.command or Spring.Utilities.CMD.RAW_MOVE; op.options=C.U.options(intent.options); op.mode=C.settings.privateSession and (intent.mode or C.settings.mode) or 'ARRIVAL'; op.state='EXECUTING'; op.forceID=intent.forceID; op.proposalID=intent.proposalID
		for _,id in ipairs(all) do
			local p=plan.slots[id] or plan.center; p={p[1],Spring.GetGroundHeight(p[1],p[3]),p[3]}; op.slots[id]=p
			C.orders.issue(op,id,op.command,p,op.options)
		end
		C.debug.log('EXECUTING','Operation '..op.id..': '..plan.shape..' / '..#eligible..' units')
		if op.mode=='ARRIVAL' and not intent.approved then C.registry.finish(op) end; return op.id
	end
	function A.members(f)
		local ids={}; if not f then return ids end
		for id in pairs(f.members) do if C.U.owned(id) and not (f.suspended and f.suspended[id]) then ids[#ids+1]=id end end
		table.sort(ids); return ids
	end
	function A.executeProposal(p)
		if p.state~='APPROVED' or not C.settings.privateSession then return false end
		local f=C.registry.forces[p.forceID]; if not f then p.state='INVALIDATED'; return false end
		p.state='EXECUTING'
		local id=A.submit({approved=true,forceID=f.id,proposalID=p.id,plan=p.plan,command=CMD.FIGHT,options={},mode=p.mode},p.units)
		if not id then p.state='ABORTED'; return false end
		f.operation=id; f.status='EXECUTING'; C.registry.operations[id].kind=p.kind; C.input.preview=p.plan
		return id
	end
	function A.assign(ids)
		if not C.settings.privateSession or not C.U.live() then C.debug.log('LOCKED','Enable local/private testing before assigning an adviser.'); return nil end
		local eligible=C.classify.filter(ids); if #eligible==0 then C.debug.log('UNAVAILABLE','Select eligible ground units.'); return nil end
		C.registry.release(eligible,'REASSIGNED'); C.registry.nextForce=C.registry.nextForce+1
		local f={id=C.registry.nextForce,members={},suspended={},revision=1,status='ADVISER',formation=C.settings.formation=='OFF' and 'DOUBLE LINE' or C.settings.formation,lastSuggestion=-100,declined={}}
		for _,id in ipairs(eligible) do f.members[id]=true end
		C.registry.forces[f.id]=f; C.registry.activeForce=f.id; C.debug.log('ASSIGNED','Force '..f.id..' observes only; no orders issued.'); return f.id
	end
	function A.objective(forceID,points)
		local f=C.registry.forces[forceID]; if not f or not points or #points<2 then return false end
		for _,p in ipairs(points) do if type(p)~='table' or type(p[1])~='number' or type(p[3])~='number' then return false end end
		f.objective=C.U.copy(points); f.revision=f.revision+1; C.debug.log('OBJECTIVE','Force '..f.id..' objective set. Await approval; no orders issued.'); return true
	end
	function A.cycle(step)
		local n=C.registry.nextForce; if n>0 then C.registry.activeForce=((C.registry.activeForce or 1)-1+step)%n+1 end
	end
	function A.resume(id)
		local f=C.registry.forces[id]; if f then f.suspended={}; f.revision=f.revision+1; f.status='ADVISER'; C.debug.log('RESUME','Advice resumed; previous approvals stay invalid.') end
	end
	function A.cancelAll() for id in pairs(C.registry.operations) do A.cancel(id) end end

	function A.cancel(id) local op=C.registry.operations[id]; if op then C.registry.finish(op,'CANCELLED') end end
	function A.update()
		local now=C.U.now()
		for _,op in pairs(C.registry.operations) do
			if op.active then
				local live={}; for _,id in ipairs(op.units) do if C.registry.valid(op,id) then live[#live+1]=id end end
				local anchor=C.U.center(live); local remaining=0
				for _,id in ipairs(live) do
					local pos=C.U.position(id); local target=op.slots[id]; local t=op.tracking[id] or {progress=now,lastPos=pos,lastCorrection=0}; op.tracking[id]=t
					local queue=Spring.GetCommandQueue(id,24) or {}; local baseIndex,base
					for i,q in ipairs(queue) do if q.id==op.command and #q.params>=3 and C.U.distance(q.params,target)<2 then baseIndex=i; base=q; break end end
					local release=not C.settings.privateSession or Spring.GetUnitTransporter(id) or Spring.GetUnitRulesParam(id,'retreat')==1
					if C.U.distance(pos,target)<math.max(48,C.classify.definition(Spring.GetUnitDefID(id)).radius*2) then release=true end
					if base then t.seen=true elseif t.seen or now-op.created>5 then release=true end
					if C.U.distance(pos,t.lastPos)>12 then t.progress=now; t.lastPos=pos end
					if baseIndex==1 and now-t.progress>10 then release=true; C.debug.log('STALLED','Released positioning for unit '..id) end
					if release then
						if C.registry.owner[id]==op.id then C.registry.owner[id]=nil end
					else
						remaining=remaining+1
						if t.correction then
							for _,q in ipairs(queue) do
								if #q.params>=3 and q.id==Spring.Utilities.CMD.RAW_MOVE and C.U.distance(q.params,t.correction)<2 then
									if C.U.distance(pos,t.correction)<48 or now-t.lastCorrection>5 then C.orders.unit(op,id,CMD.REMOVE,{q.tag},C.U.options({})); t.correction=nil end
									break
								end
							end
							if baseIndex==1 then t.correction=nil end
						elseif baseIndex==1 and anchor and op.mode~='ARRIVAL' then
							local cooldown=op.mode=='STRICT' and 2 or 5
							local desired={anchor[1]+target[1]-op.plan.center[1],0,anchor[3]+target[3]-op.plan.center[3]}
							local error=C.U.distance(pos,desired)
							local inCombat=C.observations and C.observations.nearCombat(pos,C.classify.definition(Spring.GetUnitDefID(id)).range+180)
							if now-t.lastCorrection>=cooldown and error>(op.mode=='STRICT' and 96 or 240) and (op.mode=='STRICT' or not inCombat) and C.orders.budget() then
								desired[1]=math.max(8,math.min(Game.mapSizeX-8,desired[1])); desired[3]=math.max(8,math.min(Game.mapSizeZ-8,desired[3])); desired[2]=Spring.GetGroundHeight(desired[1],desired[3])
								local los=Spring.GetPositionLosState(desired[1],desired[2],desired[3])
								if not los or not Spring.TestMoveOrder or Spring.TestMoveOrder(Spring.GetUnitDefID(id),desired[1],desired[2],desired[3],0,0,0,true,true,true) then
									C.orders.unit(op,id,CMD.INSERT,{0,Spring.Utilities.CMD.RAW_MOVE,0,desired[1],desired[2],desired[3]},C.U.options({alt=true})); t.correction=desired; t.lastCorrection=now
								end
							end
						end
					end
				end
				if remaining==0 then C.registry.finish(op); C.debug.log('COMPLETED','Operation '..op.id..' released positioning.') end
			end
		end
	end
	return A
end
