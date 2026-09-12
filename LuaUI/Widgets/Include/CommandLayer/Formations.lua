return function(C)
	local F={names={'LINE'}}
	function F.plan(ids,gesture,settings)
		local s=settings or C.settings; local center=C.U.center(ids); if not center or #ids==0 then return nil end
		local a=gesture[1]; local b=gesture[#gesture]; if not a or not b then return nil end
		local dx,dz=b[1]-a[1],b[3]-a[3]; local length=math.sqrt(dx*dx+dz*dz)
		if length<1 then dx,dz,length=1,0,1 end
		local tx,tz=dx/length,dz/length; local nx,nz=-tz,tx
		local mid={(a[1]+b[1])/2,0,(a[3]+b[3])/2}
		if (mid[1]-center[1])*nx+(mid[3]-center[3])*nz<0 then nx,nz=-nx,-nz end
		local gap=s.spacing
		for _,id in ipairs(ids) do gap=math.max(gap,C.classify.definition(Spring.GetUnitDefID(id)).radius*2+8) end
		local width=math.max(length,(#ids-1)*gap)
		local plan={slots={},units=C.U.copy(ids),origin=center,center=mid,front={nx,nz},tangent={tx,tz},shape=s.formation,gesture=C.U.copy(gesture),width=width}
		local ordered=C.U.copy(ids)
		table.sort(ordered,function(x,y) local p,q=C.U.position(x),C.U.position(y); local px=p and p[1]*tx+p[3]*tz or 0; local py=q and q[1]*tx+q[3]*tz or 0; return px==py and x<y or px<py end)
		for i,id in ipairs(ordered) do local along=#ids==1 and 0 or (i-1)/(#ids-1)*width-width/2; local x,z=mid[1]+tx*along,mid[3]+tz*along; x=math.max(8,math.min(Game.mapSizeX-8,x)); z=math.max(8,math.min(Game.mapSizeZ-8,z)); plan.slots[id]={x,Spring.GetGroundHeight(x,z),z} end
		return plan
	end
	return F
end
