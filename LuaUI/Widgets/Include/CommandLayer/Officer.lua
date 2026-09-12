return function(C)
	local A={}
	function A.nativeCommand(command,position,options)
		if command~=CMD.MOVE and command~=CMD.FIGHT and command~=Spring.Utilities.CMD.RAW_MOVE then return false end
		if not C.U.live() or not C.U.point(position) then return false end
		return C.orders.native(command,position,options)
	end
	function A.submit(intent,ids)
		if not C.U.live() or type(intent)~='table' then return nil end
		local cmd=intent.command or Spring.Utilities.CMD.RAW_MOVE
		if cmd~=CMD.MOVE and cmd~=CMD.FIGHT and cmd~=Spring.Utilities.CMD.RAW_MOVE then return nil end
		if intent.approved and not (C.proposals and C.proposals.items[intent.proposalID] and C.proposals.items[intent.proposalID].state=='EXECUTING' and C.proposals.items[intent.proposalID].dispatching) then return nil end
		if intent.delegated then
			local f=C.registry.forces[intent.forceID]; local d=f and f.delegation
			if not d or not d.active or d.token~=intent.grant or not C.U.delegationAllowed(C.settings) then return nil end
			for _,id in ipairs(ids or {}) do if not f.members[id] or f.suspended[id] or d.blocked[id] or not C.U.owned(id) then return nil end end
			if not intent.plan or not C.formations.inCorridor(d.sector,intent.plan.center) then return nil end
			for _,slot in pairs(intent.plan.slots) do if not C.formations.inCorridor(d.sector,slot) then return nil end end
			for _,route in pairs(intent.plan.routes or {}) do for _,via in ipairs(route) do if not C.U.point(via) or not C.formations.inCorridor(d.sector,via) then return nil end end end
		end
		for _,route in pairs(intent.plan and intent.plan.routes or {}) do for _,via in ipairs(route) do if not C.U.point(via) or not C.formations.inCorridor(intent.plan,via) then return nil end end end
		if intent.gesture then for _,p in ipairs(intent.gesture) do if not C.U.point(p) then return nil end end end
		ids=ids or Spring.GetSelectedUnits(); local eligible,ordinary=C.classify.filter(ids)
		if #eligible+#ordinary==0 then return nil end
		local plan=intent.plan or C.formations.plan(#eligible>0 and eligible or ordinary,intent.gesture,intent.settings)
		if not plan or not C.U.point(plan.center) then return nil end
		for _,id in ipairs(eligible) do if not C.U.point(plan.slots[id]) then return nil end end
		local all=C.U.copy(eligible); for _,id in ipairs(ordinary) do all[#all+1]=id end
		if not intent.approved and not intent.delegated then C.registry.release(all,'PLAYER_OVERRIDE') end
		local op=C.registry.newOperation(all); op.ordinary={}; for _,id in ipairs(ordinary) do op.ordinary[id]=true end; op.plan=plan; op.command=intent.command or Spring.Utilities.CMD.RAW_MOVE; op.options=C.U.options(intent.options); op.mode=C.U.assisted(C.settings) and (intent.mode or C.settings.mode) or 'ARRIVAL'; op.state='EXECUTING'; op.forceID=intent.forceID; op.proposalID=intent.proposalID; op.grant=intent.delegated and intent.grant or nil
		-- Packed transit ranks use native movement without conflicting anchor corrections.
		if plan.packed then op.mode='ARRIVAL' end
		if plan.priority then table.sort(all,function(a,b) return (plan.priority[a] or math.huge)<(plan.priority[b] or math.huge) end) end
		for _,id in ipairs(all) do
			local p=plan.slots[id] or plan.center; p={p[1],Spring.GetGroundHeight(p[1],p[3]),p[3]}; op.slots[id]=p
			local options=op.options
			for _,via in ipairs(plan.routes and plan.routes[id] or {}) do
				if C.U.point(via) and C.formations.inCorridor(plan,via) then C.orders.issue(op,id,op.command,via,options); options=C.U.copy(options); options.shift=true; options=C.U.options(options) end
			end
			C.orders.issue(op,id,op.command,p,options)
		end
		C.debug.log('EXECUTING','Operation '..op.id..': '..plan.shape..' / '..#eligible..' units')
		if op.mode=='ARRIVAL' and not intent.approved and not intent.delegated then C.registry.finish(op) end; return op.id
	end
	function A.setFormation(name)
		local valid=name=='OFF'; for _,v in ipairs(C.formations.names) do if v==name then valid=true end end
		if not valid then return false end; C.settings.formation=name; if name=='OFF' then A.cancelAll() end; return true
	end
	function A.members(f)
		local ids={}; if not f then return ids end
		for id in pairs(f.members) do if C.U.owned(id) and not (f.suspended and f.suspended[id]) then ids[#ids+1]=id end end
		table.sort(ids); return ids
	end
	function A.executeProposal(p)
		if p.state~='APPROVED' or not C.U.assisted(C.settings) then return false end
		local f=C.registry.forces[p.forceID]; if not f then p.state='INVALIDATED'; return false end
		-- Consume approval before revoking competing detachment authority.
		if p.wholeArmy and f.delegation and f.delegation.active then A.setDelegated(f.id,false) end
		p.state='EXECUTING'; p.dispatching=true
		local id=A.submit({approved=true,forceID=f.id,proposalID=p.id,plan=p.plan,command=CMD.FIGHT,options={},mode=p.mode},p.units)
		p.dispatching=nil
		if not id then p.state='ABORTED'; return false end
		f.operation=id; f.status='EXECUTING'; f.reviewReason=nil; C.registry.operations[id].kind=p.kind; C.input.preview=p.plan
		return id
	end
	function A.executeDelegated(f,ids,plan,kind,command)
		local d=f.delegation; if not d or not d.active then return nil end
		local id=A.submit({delegated=true,grant=d.token,forceID=f.id,plan=plan,command=command,mode='LOOSE',options={}},ids)
		if id then local op=C.registry.operations[id]; op.kind=kind; C.input.preview=plan end; return id
	end
	function A.setDelegated(forceID,enabled)
		local f=C.registry.forces[forceID]; if not f then return false end
		if enabled and (not C.U.delegationAllowed(C.settings) or not C.tactical) then C.debug.log('LOCKED','Autonomous testing requires a single-player game and private-session toggle.'); return false end
		-- Revoke first, including every parallel detachment operation.
		if f.delegation then f.delegation.active=false end
		for _,op in pairs(C.registry.operations) do if op.forceID==forceID then A.cancel(op.id) end end
		f.revision=f.revision+1; f.status='ADVISER'
		if C.proposals then for _,p in pairs(C.proposals.items) do if p.forceID==forceID and p.state=='OFFERED' then p.state='INVALIDATED'; p.dismissed=true end end end
		if enabled then
			local ok,why=C.tactical.start(f); if not ok then C.debug.log('OBJECTIVE',why); return false end
			C.debug.log('DELEGATED','Scout + Raid + Push enabled. Assigned units only; manual orders release units.'); return true
		end
		C.debug.log('DELEGATED','Autonomous control stopped. Native destination orders remain.'); return true
	end
	function A.assign(ids)
		if not C.U.assisted(C.settings) or not C.U.live() then C.debug.log('LOCKED','Enable local/private testing before assigning an adviser.'); return nil end
		local eligible,ordinary=C.classify.filter(ids); for _,id in ipairs(ordinary) do eligible[#eligible+1]=id end; if #eligible==0 then C.debug.log('UNAVAILABLE','Select mobile military units.'); return nil end
		C.registry.release(eligible,'REASSIGNED'); C.registry.nextForce=C.registry.nextForce+1
		local f={id=C.registry.nextForce,members={},suspended={},revision=1,status='ADVISER',front='ADVANCE',formation=C.settings.formation=='OFF' and 'DOUBLE LINE' or C.settings.formation,lastSuggestion=-100,declined={}}
		for _,id in ipairs(eligible) do f.members[id]=true end
		C.registry.forces[f.id]=f; C.registry.activeForce=f.id; C.debug.log('ASSIGNED','Force '..f.id..' observes only; no orders issued.'); return f.id
	end
	function A.autoAssign(id,forceID)
		local f=C.registry.forces[forceID or C.registry.activeForce]
		if not C.settings.autoAssign or not f or not C.U.assisted(C.settings) or not C.U.live() or not C.U.owned(id) then return false end
		local d=C.classify.definition(Spring.GetUnitDefID(id)); local _,_,_,_,built=Spring.GetUnitHealth(id)
		if not d.mobile or d.builder or built and built<1 or (C.registry.generation[id] or 0)>0 or Spring.GetUnitTransporter(id) or Spring.GetUnitRulesParam(id,'retreat')==1 then return false end
		for _,other in pairs(C.registry.forces) do if other.members[id] then return false end end
		f.members[id]=true -- Additional recruits do not change the frozen units of an existing approval.
		if f.delegation and f.delegation.active then f.delegation.groups.MAIN[#f.delegation.groups.MAIN+1]=id end
		C.debug.log('REINFORCEMENT','Completed military unit '..id..' assigned to Force '..f.id..'; joins its next authorized movement.')
		return true
	end
	function A.assignAll()
		if not C.U.live() then return nil end
		local ids={}
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do
			local d=C.classify.definition(Spring.GetUnitDefID(id))
			local _,_,_,_,built=Spring.GetUnitHealth(id)
			if C.U.owned(id) and d.mobile and not d.builder and (not built or built>=1) then ids[#ids+1]=id end
		end
		return A.assign(ids) -- Snapshot only: newly produced units require another explicit assignment.
	end
	function A.setFront(forceID,front)
		local f=C.registry.forces[forceID]
		if not f or not ({ADVANCE=true,HOLD=true,FLANK_LEFT=true,FLANK_RIGHT=true})[front] then return false end
		if f.delegation and f.delegation.active then A.setDelegated(forceID,false) end; if f.operation then A.cancel(f.operation) end
		f.front=front; f.revision=f.revision+1; f.lastSuggestion=-100
		C.debug.log('FRONT',front..': ask Officer to review the next bounded action.'); return true
	end
	function A.objective(forceID,points)
		local f=C.registry.forces[forceID]; if not f or not points or #points<2 then return false end
		for _,p in ipairs(points) do if not C.U.point(p) then return false end end
		if f.delegation and f.delegation.active then A.setDelegated(forceID,false) end; if f.operation then A.cancel(f.operation) end; f.lastSuggestion=-100; f.objectiveReached=false; f.objective=C.U.copy(points); f.revision=f.revision+1; C.debug.log('OBJECTIVE','Force '..f.id..' objective set. Await approval; no orders issued.'); return true
	end
	function A.cycle(step)
		local n=C.registry.nextForce; if n>0 then C.registry.activeForce=((C.registry.activeForce or 1)-1+step)%n+1 end
	end
	function A.resume(id)
		local f=C.registry.forces[id]; if f then if f.delegation and f.delegation.active then A.setDelegated(id,false) end; f.suspended={}; f.revision=f.revision+1; f.status='ADVISER'; C.debug.log('RESUME','Advice resumed; previous approvals stay invalid.') end
	end
	function A.setSession(enabled)
		if not enabled and C.productionControl then C.productionControl.set(false) end
		C.settings.privateSession=enabled==true
		if enabled and not C.U.assisted(C.settings) then C.settings.privateSession=false; C.debug.log('LOCKED','Requires active local/private testing; autohost matches stay locked.'); return false end
		if not enabled then A.cancelAll(); for _,p in pairs(C.proposals.items) do if p.state=='OFFERED' then p.state='INVALIDATED' end end end
		C.debug.log('SESSION',enabled and 'Local/private testing enabled for this session.' or 'Assisted testing disabled.'); return true
	end
	function A.cancelAll() for _,f in pairs(C.registry.forces) do if f.delegation then f.delegation.active=false end end; for id in pairs(C.registry.operations) do A.cancel(id) end; if C.input then C.input.preview=nil end end

	function A.cancel(id) local op=C.registry.operations[id]; if op then C.registry.finish(op,'CANCELLED') end end
	function A.update()
		local now=C.U.now(); if A.lastUpdate and now-A.lastUpdate<.1 then return end; A.lastUpdate=now
		for _,op in pairs(C.registry.operations) do
			if op.active then
				if op.grant then op.state='ADVANCING' end
				local live={}; for _,id in ipairs(op.units) do if C.registry.valid(op,id) then live[#live+1]=id end end
				local positioned={}; for _,id in ipairs(live) do if not op.ordinary[id] then positioned[#positioned+1]=id end end; local anchor=C.U.center(positioned) or C.U.center(live); local remaining=0
				for _,id in ipairs(live) do
					local pos=C.U.position(id); local target=op.slots[id]; local t=op.tracking[id] or {progress=now,lastPos=pos,lastCorrection=0}; op.tracking[id]=t
					local queue=Spring.GetCommandQueue(id,24) or {}; local baseIndex,base
					for i,q in ipairs(queue) do if q.id==op.command and #q.params>=3 and C.U.distance(q.params,target)<2 then baseIndex=i; base=q; break end end
					local arrived=C.U.distance(pos,target)<math.max(48,C.classify.definition(Spring.GetUnitDefID(id)).radius*2)
					local inObservedCombat=op.grant and C.observations.nearCombat(pos,C.classify.definition(Spring.GetUnitDefID(id)).range+180)
					if inObservedCombat then op.state='ENGAGING' end
					local release=not C.U.assisted(C.settings) or Spring.GetUnitTransporter(id) or Spring.GetUnitRulesParam(id,'retreat')==1
					if arrived then release=true; op.arrivals=(op.arrivals or 0)+1 end
					if base then t.seen=true elseif t.seen or now-op.created>5 then release=true end
					if C.U.distance(pos,t.lastPos)>12 then t.progress=now; t.lastPos=pos end
					local stalled=baseIndex==1 and now-t.progress>10 and not inObservedCombat
					if stalled then release=true; C.debug.log('STALLED','Released positioning for unit '..id) end
					if release then
						C.orders.clearCorrection(op,id)
						if not arrived then op.endReason=op.endReason or 'ABORTED'; if op.grant then local f=C.registry.forces[op.forceID]; if f and f.delegation then f.delegation.blocked[id]=stalled and now+30 or true end end end
						if C.registry.owner[id]==op.id then C.registry.owner[id]=nil end
					else
						remaining=remaining+1
						if t.correction then
							for _,q in ipairs(queue) do
								if #q.params>=3 and q.id==Spring.Utilities.CMD.RAW_MOVE and C.U.distance(q.params,t.correction)<2 then
									t.correctionTag=q.tag
									if C.U.distance(pos,t.correction)<48 or now-t.lastCorrection>5 then C.orders.unit(op,id,CMD.REMOVE,{q.tag},C.U.options({})); t.correction=nil end
									break
								end
							end
							if baseIndex==1 then t.correction=nil end
						elseif baseIndex==1 and anchor and op.mode~='ARRIVAL' and not op.ordinary[id] then
							local cooldown=op.mode=='STRICT' and 2 or 5
							local desired={anchor[1]+target[1]-op.plan.center[1],0,anchor[3]+target[3]-op.plan.center[3]}
							local error=C.U.distance(pos,desired)
							local inCombat=C.observations and C.observations.nearCombat(pos,C.classify.definition(Spring.GetUnitDefID(id)).range+180)
							if C.formations.inCorridor(op.plan,desired) and now-t.lastCorrection>=cooldown and error>(op.mode=='STRICT' and 96 or 240) and (op.mode=='STRICT' or not inCombat) and C.orders.budget() then
								desired[1]=math.max(8,math.min(Game.mapSizeX-8,desired[1])); desired[3]=math.max(8,math.min(Game.mapSizeZ-8,desired[3])); desired[2]=Spring.GetGroundHeight(desired[1],desired[3])
								local los=Spring.GetPositionLosState(desired[1],desired[2],desired[3])
								if not los or not Spring.TestMoveOrder or Spring.TestMoveOrder(Spring.GetUnitDefID(id),desired[1],desired[2],desired[3],0,0,0,true,false,false) then
									C.orders.unit(op,id,CMD.INSERT,{0,Spring.Utilities.CMD.RAW_MOVE,0,desired[1],desired[2],desired[3]},C.U.options({alt=true})); t.correction=desired; t.lastCorrection=now
								end
							end
						end
					end
				end
				if remaining==0 then C.registry.finish(op,op.endReason); C.debug.log(op.endReason or 'COMPLETED','Operation '..op.id..' released positioning.') end
			end
		end
	end
	return A
end
