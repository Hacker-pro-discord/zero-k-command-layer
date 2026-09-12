return function(C)
	local I={}
	function I.armObjective()
		if C.U.assisted(C.settings) and C.registry.activeForce then I.objective=C.registry.activeForce; Spring.SetActiveCommand(nil); C.debug.log('OBJECTIVE','Left-drag an objective line. Escape cancels.') else C.debug.log('LOCKED','Assign an adviser force in a local/private session first.') end
	end
	function I.press(x,y,button)
		if I.drag then if button~=I.drag.button then I.drag=nil end; return true end
		if not C.U.live() or (C.settings.formation=='OFF' and not I.objective) or Spring.IsGUIHidden() or Spring.IsAboveMiniMap(x,y) then return false end
		local scale=WG.uiScale or 1
		if WG.Chili and WG.Chili.Screen0:IsAbove(x/scale,y/scale) then return false end
		local _,cmd=Spring.GetActiveCommand(); local explicit=cmd~=nil
		if I.objective then
			if button~=1 then I.objective=nil; return false end
			local _,p=Spring.TraceScreenRay(x,y,true); if not p then return false end
			I.drag={points={p},units=C.officer.members(C.registry.forces[I.objective]),command=CMD.FIGHT,button=1,objective=I.objective}; return true
		end
		if explicit and button~=1 or not explicit and button~=3 then return false end
		if not explicit then _,cmd=Spring.GetDefaultCommand() end
		if cmd~=CMD.MOVE and cmd~=CMD.FIGHT and cmd~=Spring.Utilities.CMD.RAW_MOVE then return false end
		local opts=C.U.currentOptions(); if opts.alt then return false end
		local ids=Spring.GetSelectedUnits(); local eligible=C.classify.filter(ids); if #eligible<2 then return false end
		local _,p=Spring.TraceScreenRay(x,y,true); if not p then return false end
		I.drag={points={p},units=ids,command=cmd==CMD.MOVE and Spring.Utilities.CMD.RAW_MOVE or cmd,button=button,explicit=explicit}
		return true
	end
	function I.move(x,y)
		if not I.drag then return end
		local _,p=Spring.TraceScreenRay(x,y,true); if p and C.U.distance(p,I.drag.points[#I.drag.points])>8 then table.insert(I.drag.points,p); if #I.drag.points>256 then table.remove(I.drag.points,2) end end
	end
	function I.release(x,y,button)
		local d=I.drag; if not d then return false end
		if button~=d.button then I.drag=nil; return true end
		I.move(x,y); I.drag=nil
		local opts=C.U.currentOptions()
		if not d.objective then local current=Spring.GetSelectedUnits(); if #current~=#d.units then return true end; local set={}; for _,id in ipairs(current) do set[id]=true end; for _,id in ipairs(d.units) do if not set[id] then return true end end end
		if d.objective then C.officer.objective(d.objective,d.points); I.objective=nil; return true end
		if #d.points<2 or C.U.distance(d.points[1],d.points[#d.points])<20 then C.officer.nativeCommand(d.command,d.points[1],opts)
		else C.officer.submit({gesture=d.points,command=d.command,options=opts},d.units) end
		if d.explicit and not opts.shift then Spring.SetActiveCommand(nil) end
		return true
	end
	function I.draw()
		if not C.settings.overlays then return end
		local plan=I.preview
		if I.drag then if not I.lastPreview or C.U.now()-I.lastPreview>.05 then local ids=C.classify.filter(I.drag.units); I.dragPreview=C.formations.plan(ids,I.drag.points); I.lastPreview=C.U.now() end; plan=I.dragPreview else I.lastPreview=nil; I.dragPreview=nil end
		if not plan then return end
		gl.DepthTest(false); gl.Color(.25,.85,1,.8); gl.LineWidth(1)
		for id,p in pairs(plan.slots) do local zone=plan.zones[id]; if zone==4 then gl.Color(1,.65,.25,.8) elseif zone==2 then gl.Color(.5,1,.5,.8) else gl.Color(.25,.85,1,.8) end; gl.DrawGroundCircle(p[1],p[2]+3,p[3],12,12) end
		gl.Color(.25,.85,1,.8); gl.BeginEnd(GL.LINE_STRIP,function() for _,p in ipairs(plan.gesture) do gl.Vertex(p[1],Spring.GetGroundHeight(p[1],p[3])+8,p[3]) end end)
		gl.BeginEnd(GL.LINES,function() local m=plan.center; gl.Vertex(m[1],Spring.GetGroundHeight(m[1],m[3])+8,m[3]); gl.Vertex(m[1]+plan.front[1]*100,Spring.GetGroundHeight(m[1],m[3])+8,m[3]+plan.front[2]*100) end)
		if plan.corridor then gl.Color(.9,.7,.2,.6); gl.BeginEnd(GL.LINE_LOOP,function() for _,p in ipairs(plan.corridor) do gl.Vertex(p[1],Spring.GetGroundHeight(p[1],p[3])+8,p[3]) end end) end
		gl.Color(1,1,1,1); gl.DepthTest(false)
	end
	return I
end
