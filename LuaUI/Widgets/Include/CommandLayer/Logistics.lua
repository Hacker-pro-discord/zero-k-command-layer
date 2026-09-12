return function(C)
	local L={}
	function L.arm(kind)
		if not C.U.live() then return false end
		local id=Spring.Utilities.CMD.AREA_MEX
		local count=tonumber(kind:match('MEX(%d)'))
		if not count then return false end
		local index=Spring.GetCmdDescIndex(id)
		if not index or not WG.CommandInsert or not WG.metalSpots then C.debug.log('UNAVAILABLE','Select constructors with Area Mex available.'); return false end
		L.pending={id=id,kind=kind,count=count,selection=table.concat(Spring.GetSelectedUnits(),',')}
		Spring.SetActiveCommand(index)
		C.debug.log('ARMED',kind..': drag the native area; Shift queues, Space inserts.')
		return true
	end
	function L.notify(id,params,opts)
		local p=L.pending; if not p then return end
		if id~=p.id then L.pending=nil; return end
		if table.concat(Spring.GetSelectedUnits(),',')~=p.selection then L.pending=nil; return end
		opts.ctrl=p.count==1 or p.count==4; opts.alt=p.count==2 or p.count==4
		local encoded=C.U.options(opts); opts.coded=encoded.coded
		C.debug.log('LOGISTICS','Native '..p.kind..' issued')
		if not opts.shift then L.pending=nil end
		-- Continue through stock handlers, including Mex Placement and Command Insert.
	end
	function L.update()
		if L.pending then local _,id=Spring.GetActiveCommand(); if id~=L.pending.id or table.concat(Spring.GetSelectedUnits(),',')~=L.pending.selection then L.pending=nil end end
	end
	return L
end
