return function(C)
	local L={}
	function L.arm(kind)
		if not C.U.live() or not ({MEX0=true,MEX1=true,MEX2=true,MEX4=true,AREA_REPAIR=true,PERSISTENT_REPAIR=true,AREA_RECLAIM=true,PERSISTENT_RECLAIM=true})[kind] then return false end
		local id=Spring.Utilities.CMD.AREA_MEX
		local count=tonumber(kind:match('MEX(%d)'))
		if not count then id=kind:find('REPAIR') and CMD.REPAIR or CMD.RECLAIM end
		local index=Spring.GetCmdDescIndex(id)
		if not index or (count and (not WG.CommandInsert or not WG.metalSpots)) then C.debug.log('UNAVAILABLE','Select constructors with this native command available.'); return false end
		L.pending={id=id,kind=kind,count=count,selection=table.concat(Spring.GetSelectedUnits(),',')}
		Spring.SetActiveCommand(index)
		C.debug.log('ARMED',kind..': drag the native area; Shift queues, Space inserts.')
		return true
	end
	function L.notify(id,params,opts)
		local p=L.pending; if not p then return end
		if id~=p.id then L.pending=nil; return end
		if table.concat(Spring.GetSelectedUnits(),',')~=p.selection then L.pending=nil; return end
		if p.count then
			opts.ctrl=p.count==1 or p.count==4; opts.alt=p.count==2 or p.count==4
		else
			opts.alt=p.kind:find('PERSISTENT')~=nil
		end
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
