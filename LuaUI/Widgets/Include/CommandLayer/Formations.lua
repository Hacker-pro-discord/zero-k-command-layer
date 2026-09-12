return function(C)
	local F={names={'LINE','DOUBLE LINE','TRIPLE LINE','COLUMN','WEDGE','ECHELON LEFT','ECHELON RIGHT','BOX','SCREEN','ASSAULT'}}
	function F.inCorridor(plan,p)
		if not plan.corridor then return true end
		local sign
		for i,a in ipairs(plan.corridor) do local b=plan.corridor[i%#plan.corridor+1]; local cross=(b[1]-a[1])*(p[3]-a[3])-(b[3]-a[3])*(p[1]-a[1]); if math.abs(cross)>.01 then local positive=cross>0; if sign~=nil and positive~=sign then return false end; sign=positive end end
		return true
	end
	function F.plan(ids,gesture,settings)
		if type(gesture)~='table' or #gesture==0 then return nil end
		for _,p in ipairs(gesture) do if not C.U.point(p) then return nil end end
		local s=C.U.copy(C.settings); for k,v in pairs(settings or {}) do s[k]=v end; local center=C.U.center(ids); if not center or #ids==0 then return nil end
		local a=gesture[1]; local b=gesture[#gesture]; if not a or not b then return nil end
		local dx,dz=b[1]-a[1],b[3]-a[3]; local length=math.sqrt(dx*dx+dz*dz)
		if length<20 and #gesture>2 then b=gesture[math.floor(#gesture/2)]; dx,dz=b[1]-a[1],b[3]-a[3]; length=math.sqrt(dx*dx+dz*dz); gesture={a,b} end
		if length<1 then dx,dz,length=1,0,1 end
		local tx,tz=dx/length,dz/length; local nx,nz=-tz,tx
		local mid={(a[1]+b[1])/2,0,(a[3]+b[3])/2}
		if (mid[1]-center[1])*nx+(mid[3]-center[3])*nz<0 then nx,nz=-nx,-nz end
		local gap=s.spacing
		for _,id in ipairs(ids) do gap=math.max(gap,C.classify.definition(Spring.GetUnitDefID(id)).radius*2+8) end
		local shape=s.formation; if shape=='OFF' then return nil end; local ranks=shape=='DOUBLE LINE' and 2 or shape=='TRIPLE LINE' and 3 or 1
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
		local function tangentOrder(x,y) local p,q=C.U.position(x),C.U.position(y); local px=p and p[1]*tx+p[3]*tz or 0; local py=q and q[1]*tx+q[3]*tz or 0; return px==py and x<y or px<py end
		if ranks>1 or shape=='COLUMN' or shape=='WEDGE' or shape:find('ECHELON') then table.sort(ordered,function(x,y) local rx=roleBands[C.classify.definition(Spring.GetUnitDefID(x)).role] or 1; local ry=roleBands[C.classify.definition(Spring.GetUnitDefID(y)).role] or 1; return rx==ry and tangentOrder(x,y) or rx<ry end) end
		for i,id in ipairs(ordered) do
			local band=math.floor((i-1)/math.ceil(#ordered/ranks))
			if roleAware then band=roleBands[C.classify.definition(Spring.GetUnitDefID(id)).role] or 1; if shape=='SCREEN' and band>0 then band=1 end end
			bands[band]=bands[band] or {}; table.insert(bands[band],id)
		end
		if roleAware then
			width=length
			for _,g in pairs(bands) do width=math.max(width,(#g-1)*gap) end
			plan.width=width
		end
		for band,group in pairs(bands) do
			if ranks>1 or roleAware then table.sort(group,tangentOrder) end
			for i,id in ipairs(group) do
				local fraction=#group==1 and .5 or (i-1)/(#group-1)
				local along=(fraction-.5)*width; local depth=band*math.max(gap,s.rankGap)
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
	-- Overflow ranks keep distinct destinations instead of clamping an entire wing
	-- onto one boundary point. Role-zone order survives the compact layout.
	function F.fitCorridor(plan,sector,settings)
		local gap=(settings or C.settings).spacing
		for _,id in ipairs(plan.units) do gap=math.max(gap,C.classify.definition(Spring.GetUnitDefID(id)).radius*2+8) end
		local fits=true
		for i,id in ipairs(plan.units) do
			local p=plan.slots[id]
			if not C.U.point(p) or not F.inCorridor(sector,p) then fits=false; break end
			for j=1,i-1 do if C.U.distance(p,plan.slots[plan.units[j]])<gap*.9 then fits=false; break end end
			if not fits then break end
		end
		plan.corridor=sector.corridor
		if fits then return plan end
		local columns=math.max(1,math.floor((sector.half*2-32)/gap)+1)
		local rankGap=math.max(gap,(settings or C.settings).rankGap)
		local rows=math.ceil(#plan.units/columns)
		local front=math.min(sector.length,math.max(C.rules.progress(sector,plan.center),(rows-1)*rankGap-380))
		local candidates={}
		repeat
			candidates={}
			for row=0,math.floor((front+380)/rankGap) do
				for column=0,columns-1 do
					local p=C.rules.point(sector,front-row*rankGap,(column-(columns-1)/2)*gap)
					if p then candidates[#candidates+1]=p end
				end
			end
			if #candidates>=#plan.units or front>=sector.length then break end
			-- Map edges can clip columns from an oblique corridor. Count actual
			-- usable slots and extend ranks, never pretend the nominal width fits.
			front=math.min(sector.length,front+rankGap)
		until false
		if #candidates<#plan.units then return nil end -- Never merge slots to pretend the army fits.
		local ids=C.U.copy(plan.units)
		table.sort(ids,function(a,b)
			local za,zb=plan.zones[a] or 0,plan.zones[b] or 0
			if za~=zb then return za<zb end
			local pa,pb=C.U.position(a),C.U.position(b)
			local aa=pa[1]*sector.px+pa[3]*sector.pz; local ab=pb[1]*sector.px+pb[3]*sector.pz
			return aa==ab and a<b or aa<ab
		end)
		for i,id in ipairs(ids) do plan.slots[id]=candidates[i] end
		plan.packed=true; plan.width=(columns-1)*gap
		return plan
	end
	return F
end
