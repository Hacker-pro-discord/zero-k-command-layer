return function(C)
	local R={forces={},owner={},generation={},operations={},nextForce=0,nextOperation=0,activeForce=nil}
	function R.release(ids,reason)
		for _,id in ipairs(ids) do
			local old=R.operations[R.owner[id]]; if old then if C.orders then C.orders.clearCorrection(old,id) end; old.endReason=reason or 'PLAYER_OVERRIDE' end
			R.generation[id]=(R.generation[id] or 0)+1; R.owner[id]=nil
			for _,f in pairs(R.forces) do if f.members[id] then if C.settings.override=='suspend' and reason=='PLAYER_OVERRIDE' then f.suspended=f.suspended or {}; f.suspended[id]=true else f.members[id]=nil end; f.revision=f.revision+1; f.status=reason or 'PLAYER_OVERRIDE' end end
		end
	end
	function R.claim(ids,op)
		for _,id in ipairs(ids) do R.generation[id]=(R.generation[id] or 0)+1; R.owner[id]=op.id; op.generations[id]=R.generation[id] end
	end
	function R.valid(op,id)
		if op and op.grant then
			local f=R.forces[op.forceID]; local d=f and f.delegation
			if not d or not d.active or d.token~=op.grant or not f.members[id] or f.suspended[id] or d.blocked[id] or not C.U.delegationAllowed(C.settings) then return false end
		end
		return op and op.active and R.owner[id]==op.id and op.generations[id]==R.generation[id] and C.U.owned(id) end
	function R.newOperation(ids)
		R.nextOperation=R.nextOperation+1
		local op={id=R.nextOperation,units=C.U.copy(ids),generations={},active=true,state='PLANNING',created=C.U.now(),slots={},tracking={}}
		for key,old in pairs(R.operations) do if not old.active and key<op.id-100 then R.operations[key]=nil end end
		R.operations[op.id]=op; R.claim(ids,op); return op
	end
	function R.finish(op,state)
		if not op.active then return end
		if C.orders then for _,id in ipairs(op.units) do if R.valid(op,id) then C.orders.clearCorrection(op,id) end end end
		op.active=false; op.state=state or 'COMPLETED'; if C.input and C.input.preview==op.plan then C.input.preview=nil end
		if op.forceID and R.forces[op.forceID] then R.forces[op.forceID].status='ADVISER'; if op.kind=='PUSH' and op.state=='COMPLETED' then R.forces[op.forceID].objectiveReached=true end end
		if op.proposalID and C.proposals and C.proposals.items[op.proposalID] then C.proposals.items[op.proposalID].state=op.state end
		for _,id in ipairs(op.units) do if R.owner[id]==op.id then R.owner[id]=nil end end
	end
	return R
end
