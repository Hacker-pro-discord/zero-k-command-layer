return function(C)
	local T={last=-100}
	function T.ask(forceID,explicit,wholeArmy)
		local f=C.registry.forces[forceID]
		if not f or not C.U.assisted(C.settings) or not C.U.live() then C.debug.log('LOCKED','Assign an adviser force in local/private testing.'); return nil end
		if f.delegation and f.delegation.active and not wholeArmy then return nil end
		local op=f.operation and C.registry.operations[f.operation]; if op and op.active then return nil end
		if wholeArmy and not f.objective then C.debug.log('OBJECTIVE','Draw the intended army destination first.'); return nil end
		if not explicit and C.U.now()-f.lastSuggestion<C.settings.suggestionInterval then return nil end
		local ids=C.officer.members(f); if #ids==0 then return nil end
		if C.production then f.advice=C.production.recommend(f) end
		local center=C.U.center(ids); local settings=C.U.copy(C.settings); settings.formation=f.formation
		local width=math.min(2048,math.max(256,math.ceil(#ids/2)*settings.spacing))
		local points={{math.max(8,center[1]-width/2),center[2],center[3]},{math.min(Game.mapSizeX-8,center[1]+width/2),center[2],center[3]}}
		local kind='REFORM'; local reason='Restore role zones around the current force position.'
		local maxDistance=0; local health=0
		for _,id in ipairs(ids) do maxDistance=math.max(maxDistance,C.U.distance(center,C.U.position(id))); local h,m=Spring.GetUnitHealth(id); health=health+(h and m and h/math.max(1,m) or 0) end
		if f.front~='HOLD' and f.objective and not f.objectiveReached and (wholeArmy or maxDistance<math.max(500,width)) and health/#ids>.5 then
			kind='PUSH'; points=f.objective; reason='Force is assembled enough for one player-defined advance. Native Fight handles combat.'
		end
		-- A flank approval covers one approach line, never an automatic second attack.
		if not wholeArmy and kind=='PUSH' and (f.front=='FLANK_LEFT' or f.front=='FLANK_RIGHT') then
			local a,b=points[1],points[#points]; local mx,mz=(a[1]+b[1])/2,(a[3]+b[3])/2
			local dx,dz=mx-center[1],mz-center[3]; local distance=math.sqrt(dx*dx+dz*dz)
			if distance>256 then
				local side=f.front=='FLANK_LEFT' and -1 or 1
				local offset=math.min(256,distance*.25); local cx,cz=center[1]+dx*.55-dz/distance*offset*side,center[3]+dz*.55+dx/distance*offset*side
				local half=math.min(width/2,384); local tx,tz=-dz/distance,dx/distance
				local function point(sign) return {math.max(8,math.min(Game.mapSizeX-8,cx+tx*half*sign)),0,math.max(8,math.min(Game.mapSizeZ-8,cz+tz*half*sign))} end
				points={point(-1),point(1)}; kind=f.front
				reason='One '..f.front:gsub('_',' '):lower()..' approach toward your objective. Review the yellow corridor. This does not claim a weak enemy flank or clear terrain. Another approval is required to attack the objective.'
			end
		end
		if not explicit and f.declined[kind] and f.declined[kind]>C.U.now() then return nil end
		if wholeArmy then
			local assessment=C.observations.snapshot(center,Game.mapSizeX+Game.mapSizeZ)
			local value=0; for _,id in ipairs(ids) do local h,m=Spring.GetUnitHealth(id); value=value+C.classify.definition(Spring.GetUnitDefID(id)).cost*(h and m and h/math.max(1,m) or 0) end
			local first,last=f.objective[1],f.objective[#f.objective]
			local goal={(first[1]+last[1])/2,0,(first[3]+last[3])/2}; local known=0
			for _,contact in ipairs(assessment.contacts) do
				if contact.visibility=='VISUAL' and C.U.distance(contact.position,goal)<1500 then known=known+C.classify.definition(contact.defID).cost end
			end
			if value<known*1.25 then kind='REFORM'; reason='Observed opposition exceeds the 1.25 friendly-value margin. Suggest reforming instead of committing the army.' end
			if kind=='PUSH' then reason='Commit the entire assigned army to your objective in one native Fight action. Healthy friendly value '..math.floor(value)..'; nearby identified enemy value '..math.floor(known)..'. This heuristic does not predict victory.' end
			if f.reviewReason then
				kind='REFORM'; settings.formation='ASSAULT'
				reason=f.reviewReason..' Regroup in role zones before considering another attack. This replaces continued pressure with one approved reformation; a later push needs fresh approval.'
			end
			if kind=='REFORM' then points={{math.max(8,center[1]-width/2),0,center[3]},{math.min(Game.mapSizeX-8,center[1]+width/2),0,center[3]}} end
		end
		local ground=C.classify.filter(ids); if #ground==0 then ground=ids end
		local plan=C.formations.plan(ground,points,settings); if not plan then return nil end
		local error=0; for _,id in ipairs(ids) do error=error+C.U.distance(C.U.position(id),(plan.slots[id] or plan.center)) end
		if not explicit and kind=='REFORM' and error/#ids<settings.spacing*2 then f.lastSuggestion=C.U.now(); return nil end
		local observed=C.observations.snapshot(plan.center,math.max(1000,plan.width))
		if (observed.composition.RIOT or 0)>=2 then
			settings.spacing=math.min(256,settings.spacing*1.5); plan=C.formations.plan(ground,points,settings)
			reason=reason..' Widened spacing because at least two riot units are visually identified.'
		end
		if #observed.contacts>0 then reason=reason..' '..#observed.contacts..' visual/radar contacts nearby; this is not a safety assessment.' else reason=reason..' No contact currently observed near the destination; fog remains unknown.' end
		local ax,az=plan.origin[1],plan.origin[3]; local bx,bz=plan.center[1],plan.center[3]; local dx,dz=bx-ax,bz-az; local d=math.max(1,math.sqrt(dx*dx+dz*dz)); local px,pz=-dz/d,dx/d; if d<=1 then px,pz=1,0 end
		local ux,uz=dx/d,dz/d; if d<=1 then ux,uz=0,1 end
		local low,high,left,right=-64,d+64,-plan.width/2-128,plan.width/2+128
		for _,p in pairs(plan.slots) do local x,z=p[1]-ax,p[3]-az; local along=x*ux+z*uz; local across=x*px+z*pz; low=math.min(low,along-64); high=math.max(high,along+64); left=math.min(left,across-64); right=math.max(right,across+64) end
		local function corner(along,across) return {ax+ux*along+px*across,0,az+uz*along+pz*across} end
		plan.corridor={corner(low,left),corner(high,left),corner(high,right),corner(low,right)}
		if wholeArmy and C.rules then
			local sector=C.rules.sector(ids,points)
			if kind=='REFORM' then
				local rear=math.max(8,center[3]-1500); local front=math.min(Game.mapSizeZ-8,center[3]+1500)
				local half=math.min(width/2,center[1]-8,Game.mapSizeX-8-center[1])
				sector={origin={center[1],0,rear},length=front-rear,ux=0,uz=1,px=1,pz=0,half=half,
					corridor={{center[1]-half,0,rear},{center[1]+half,0,rear},{center[1]+half,0,front},{center[1]-half,0,front}}}
			end
			if sector then plan=C.formations.fitCorridor(plan,sector,settings); if not plan then C.debug.log('CAPACITY','Draw a wider objective line for this army.'); return nil end end
		end
		local pid=C.proposals.create(f,kind,plan,reason)
		if pid and wholeArmy then local p=C.proposals.items[pid]; p.wholeArmy=true; p.summary='WHOLE ASSIGNED ARMY — separate delegation ends on approval.\n'..p.summary end
		return pid
	end
	function T.update()
		if not C.U.assisted(C.settings) or C.U.now()-T.last<.5 then return end; T.last=C.U.now()
		for id,f in pairs(C.registry.forces) do
			-- Refresh changed information, but never execute the replacement automatically.
			for _,p in pairs(C.proposals.items) do
				if p.forceID==id and not p.dismissed and p.state=='INVALIDATED' and C.U.now()-f.lastSuggestion>=5 then T.ask(id,true,p.wholeArmy); break end
			end
			local has=false; for _,p in pairs(C.proposals.items) do if p.forceID==id and not p.dismissed and (p.state=='OFFERED' or p.state=='EXPIRED' or p.state=='INVALIDATED') then has=true; break end end
			if not has and C.U.now()-f.lastSuggestion>=C.settings.suggestionInterval then T.ask(id,false) end
		end
	end
	return T
end
