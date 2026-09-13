-- Recognize the installed cmd_raw_move.lua constructor wrapper, not arbitrary Lua orders.
return function(C)
	local Q={}
	function Q.paused(service,id)
		service.nativePause=service.nativePause or {}
		if Spring.GetUnitTransporter(id) or Spring.GetUnitRulesParam(id,'retreat')==1 then service.nativePause[id]=true; return true end
		local task=service.tasks[id]
		if task and task.cmd<0 then
			local queue=Spring.GetCommandQueue(id,2) or {}; local head=queue[1]; local def=UnitDefs[-task.cmd]
			local clearance=math.max(256,def and math.max(def.xsize or 2,def.zsize or 2)*8+64 or 256)
			-- The engine may finish/drop the build before its internal clearance move drains.
			if #queue==1 and head.id==CMD.MOVE and head.options and head.options.internal==true and head.params and #head.params>=3 and C.U.distance(head.params,task.params)<clearance then service.nativePause[id]=true; return true end
		end
		if service.nativePause[id] then
			if #(Spring.GetCommandQueue(id,1) or {})>0 then return true end
			service.nativePause[id]=nil; service.tasks[id]=nil
		end
		return false
	end
	function Q.matches(q,t)
		if not q or not t or q.id~=t.cmd or not q.params then return false end
		if t.cmd==CMD.REPAIR or t.cmd==CMD.RECLAIM then return #q.params==1 and q.params[1]==t.params[1] end
		return #q.params>=3 and #t.params>=3 and C.U.distance(q.params,t.params)<16
	end
	function Q.current(id,t)
		local queue=Spring.GetCommandQueue(id,2) or {}; local head=queue[1]
		if Q.matches(head,t) then return head end
		if not head or not Q.matches(queue[2],t) then return nil end
		local rawBuild=Spring.Utilities.CMD.RAW_BUILD and head.id==Spring.Utilities.CMD.RAW_BUILD
		local internalMove=head.id==CMD.MOVE and head.options and head.options.internal==true
		if not rawBuild and not internalMove then return nil end
		local goal
		if t.cmd<0 then goal=t.params
		elseif t.cmd==CMD.REPAIR and C.U.owned(t.params[1]) then goal=C.U.position(t.params[1])
		elseif t.cmd==CMD.RECLAIM and t.goal then goal=t.goal
		elseif t.cmd==CMD.RECLAIM and Spring.GetFeaturePosition then
			local x,y,z=Spring.GetFeaturePosition(t.params[1]-Game.maxUnits)
			if x and Spring.GetPositionLosState(x,y,z) then goal={x,y,z} end
		end
		local clearance=16
		if internalMove then local def=t.cmd<0 and UnitDefs[-t.cmd]; clearance=math.max(256,def and math.max(def.xsize or 2,def.zsize or 2)*8+64 or 256) end
		if goal and head.params and #head.params>=3 and C.U.distance(head.params,goal)<clearance then return queue[2],head end
	end
	function Q.status()
		local result={}
		if not C.U.live() then return result end
		for _,name in ipairs({'economy','recovery'}) do local service=C[name]; local s={controlled=0,idle=0,wrapped=0,paused=0,excluded=0}; result[name]=s
			if service then
				for id in pairs(service.workers) do if C.U.owned(id) then
					s.controlled=s.controlled+1; if #(Spring.GetCommandQueue(id,1) or {})==0 then s.idle=s.idle+1 end
					local _,wrapper=Q.current(id,service.tasks[id]); if wrapper then s.wrapped=s.wrapped+1 end
					if service.nativePause and service.nativePause[id] then s.paused=s.paused+1 end
				end end
				for id in pairs(service.excluded) do if C.U.owned(id) and C.classify.definition(Spring.GetUnitDefID(id)).builder then s.excluded=s.excluded+1 end end
			end
		end
		return result
	end
	return Q
end
