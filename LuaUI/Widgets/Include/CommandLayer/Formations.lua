return function(C)
	local F={names={'LINE','DOUBLE LINE','TRIPLE LINE','COLUMN','WEDGE','ECHELON LEFT','ECHELON RIGHT','BOX','SCREEN','ASSAULT'}}
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
		local shape=s.formation; local ranks=shape=='DOUBLE LINE' and 2 or shape=='TRIPLE LINE' and 3 or 1
		local width=math.max(length,(math.ceil(#ids/ranks)-1)*gap)
		local plan={slots={},units=C.U.copy(ids),origin=center,center=mid,front={nx,nz},tangent={tx,tz},shape=shape,gesture=C.U.copy(gesture),width=width,zones={}}
		local distances={0}; local total=0
		for i=2,#gesture do total=total+C.U.distance(gesture[i],gesture[i-1]); distances[i]=total end
		local function sample(fraction)
			if total<20 then return mid[1]+tx*(fraction-.5)*width,mid[3]+tz*(fraction-.5)*width,nx,nz end
			local d=(fraction-.5)*math.max(total,width)+total/2
			local k=2
			while k<#gesture and distances[k]<d do k=k+1 end
			local pa,pb=gesture[k-1],gesture[k]; local seg=math.max(.01,distances[k]-distances[k-1]); local f=(d-distances[k-1])/seg
			local lx,lz=(pb[1]-pa[1])/seg,(pb[3]-pa[3])/seg; local fnx,fnz=-lz,lx
			if fnx*nx+fnz*nz<0 then fnx,fnz=-fnx,-fnz end
			return pa[1]+(pb[1]-pa[1])*f,pa[3]+(pb[3]-pa[3])*f,fnx,fnz
		end
		local ordered=C.U.copy(ids)
		table.sort(ordered,function(x,y) local p,q=C.U.position(x),C.U.position(y); local px=p and p[1]*tx+p[3]*tz or 0; local py=q and q[1]*tx+q[3]*tz or 0; return px==py and x<y or px<py end)
		local bands={}; local roleBands={SCOUT=0,RAIDER=0,ASSAULT=1,RIOT=1,OTHER=1,ANTI_AIR=2,SUPPORT=2,CONSTRUCTOR=2,SKIRMISHER=3,ARTILLERY=4}
		local roleAware=shape=='ASSAULT' or shape=='SCREEN'
		for i,id in ipairs(ordered) do
			local band=(i-1)%ranks
			if roleAware then band=roleBands[C.classify.definition(Spring.GetUnitDefID(id)).role] or 1; if shape=='SCREEN' and band>0 then band=1 end end
			bands[band]=bands[band] or {}; table.insert(bands[band],id)
		end
		if roleAware then
			width=length
			for _,g in pairs(bands) do width=math.max(width,(#g-1)*gap) end
			plan.width=width
		end
		for band,group in pairs(bands) do
			for i,id in ipairs(group) do
				local fraction=#group==1 and .5 or (i-1)/(#group-1)
				local along=(fraction-.5)*width; local depth=band*s.rankGap
				if shape=='ASSAULT' then depth=({[0]=0,[1]=s.rankGap,[2]=s.supportDepth,[3]=s.skirmDepth,[4]=s.artilleryDepth})[band] end
				local x,z,fx,fz=sample(fraction)
				if shape=='COLUMN' then along=0; depth=(i-1)*gap
				elseif shape=='WEDGE' then local step=math.ceil((i-1)/2); along=(i%2==0 and -1 or 1)*step*gap; depth=step*gap
				elseif shape=='ECHELON LEFT' or shape=='ECHELON RIGHT' then along=(i-1)*gap*(shape=='ECHELON LEFT' and -1 or 1); depth=(i-1)*gap
				elseif shape=='BOX' then
					local w=math.max(gap,width/2); local h=w/2; local d=(i-1)/#group*(2*w+2*h)
					if d<w then along=d-w/2; depth=0 elseif d<w+h then along=w/2; depth=d-w elseif d<2*w+h then along=w/2-(d-w-h); depth=h else along=-w/2; depth=h-(d-2*w-h) end
				end
				if shape=='COLUMN' or shape=='WEDGE' or shape:find('ECHELON') or shape=='BOX' then x,z,fx,fz=mid[1]+tx*along,mid[3]+tz*along,nx,nz end
				x=x-fx*depth; z=z-fz*depth
				x=math.max(8,math.min(Game.mapSizeX-8,x)); z=math.max(8,math.min(Game.mapSizeZ-8,z))
				plan.slots[id]={x,Spring.GetGroundHeight(x,z),z}; plan.zones[id]=band
			end
		end
		return plan
	end
	return F
end
