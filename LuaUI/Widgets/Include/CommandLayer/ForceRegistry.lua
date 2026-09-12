return function(C)
	local R={forces={},owner={},generation={},operations={},nextForce=0,nextOperation=0,activeForce=nil}
	function R.release(ids,reason)
		for _,id in ipairs(ids) do
			R.generation[id]=(R.generation[id] or 0)+1; R.owner[id]=nil
			for _,f in pairs(R.forces) do if f.members[id] then f.members[id]=nil; f.revision=f.revision+1; f.status=reason or 'PLAYER_OVERRIDE' end end
		end
	end
	function R.claim(ids,op)
		for _,id in ipairs(ids) do R.generation[id]=(R.generation[id] or 0)+1; R.owner[id]=op.id; op.generations[id]=R.generation[id] end
	end
	function R.valid(op,id) return op and op.active and R.owner[id]==op.id and op.generations[id]==R.generation[id] and C.U.owned(id) end
	function R.newOperation(ids)
		R.nextOperation=R.nextOperation+1
		local op={id=R.nextOperation,units=C.U.copy(ids),generations={},active=true,state='PLANNING',created=C.U.now(),slots={},tracking={}}
		R.operations[op.id]=op; R.claim(ids,op); return op
	end
	function R.finish(op,state)
		op.active=false; op.state=state or 'COMPLETED'
		for _,id in ipairs(op.units) do if R.owner[id]==op.id then R.owner[id]=nil end end
	end
	return R
end
