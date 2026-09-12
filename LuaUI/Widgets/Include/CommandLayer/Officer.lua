return function(C)
	local A={}
	function A.submit(intent,ids)
		if not C.U.live() then return nil end
		ids=ids or Spring.GetSelectedUnits(); local eligible,ordinary=C.classify.filter(ids)
		if #eligible==0 then return nil end
		local plan=intent.plan or C.formations.plan(eligible,intent.gesture,intent.settings)
		if not plan then return nil end
		C.registry.release(eligible,'PLAYER_OVERRIDE')
		local all=C.U.copy(eligible); for _,id in ipairs(ordinary) do all[#all+1]=id end
		local op=C.registry.newOperation(all); op.plan=plan; op.command=intent.command or Spring.Utilities.CMD.RAW_MOVE; op.options=C.U.options(intent.options); op.mode='ARRIVAL'; op.state='EXECUTING'
		for _,id in ipairs(all) do
			local p=plan.slots[id] or plan.center; p={p[1],Spring.GetGroundHeight(p[1],p[3]),p[3]}; op.slots[id]=p
			C.orders.issue(op,id,op.command,p,op.options)
		end
		C.debug.log('EXECUTING','Operation '..op.id..': '..plan.shape..' / '..#eligible..' units')
		C.registry.finish(op); return op.id
	end
	function A.cancel(id) local op=C.registry.operations[id]; if op then C.registry.finish(op,'CANCELLED') end end
	function A.update() end
	return A
end
