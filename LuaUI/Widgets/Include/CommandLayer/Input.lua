return function(C)
	local I={}
	function I.press(x,y,button)
		if not C.U.live() or C.settings.formation=='OFF' or Spring.IsGUIHidden() or Spring.IsAboveMiniMap(x,y) then return false end
		local scale=WG.uiScale or 1
		if WG.Chili and WG.Chili.Screen0:IsAbove(x/scale,y/scale) then return false end
		local _,cmd=Spring.GetActiveCommand(); local explicit=cmd~=nil
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
		if #d.points<2 or C.U.distance(d.points[1],d.points[#d.points])<20 then C.orders.native(d.command,d.points[1],opts)
		else C.officer.submit({gesture=d.points,command=d.command,options=opts},d.units) end
		if d.explicit and not opts.shift then Spring.SetActiveCommand(nil) end
		return true
	end
	function I.draw()
		if not C.settings.overlays then return end
		local plan=I.preview
		if I.drag then local ids=C.classify.filter(I.drag.units); plan=C.formations.plan(ids,I.drag.points) end
		if not plan then return end
		gl.DepthTest(false); gl.Color(.25,.85,1,.8); gl.LineWidth(1)
		for _,p in pairs(plan.slots) do gl.DrawGroundCircle(p[1],p[2]+3,p[3],12,12) end
		gl.BeginEnd(GL.LINES,function() local m=plan.center; gl.Vertex(m[1],Spring.GetGroundHeight(m[1],m[3])+8,m[3]); gl.Vertex(m[1]+plan.front[1]*100,Spring.GetGroundHeight(m[1],m[3])+8,m[3]+plan.front[2]*100) end)
		gl.Color(1,1,1,1); gl.DepthTest(false)
	end
	return I
end
