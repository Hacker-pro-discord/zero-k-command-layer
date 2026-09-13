-- Map-wide military objectives from public map geometry and client observations.
return function(C)
	local M={}
	function M.initialize(f)
		local m={cells={},attempts={},visits={},missions={}}; f.mapState=m
		for z=1,5 do for x=1,5 do
			local px,pz=Game.mapSizeX*(x-.5)/5,Game.mapSizeZ*(z-.5)/5
			m.cells[#m.cells+1]={px,Spring.GetGroundHeight(px,pz),pz}
		end end
		return m
	end
	function M.failed(f,now,point)
		local m=f.mapState or M.initialize(f); m.failures=m.failures or {}
		m.failures[#m.failures+1]={point=C.U.copy(point),time=now}; if #m.failures>16 then table.remove(m.failures,1) end
	end
	function M.sector(f,ids,target)
		local origin=C.U.center(ids); local dx,dz=target[1]-origin[1],target[3]-origin[3]
		local length=math.sqrt(dx*dx+dz*dz); if length<1 then dx,dz,length=0,1,1 end
		return {origin=origin,goal=target,length=length,ux=dx/length,uz=dz/length,px=-dz/length,pz=dx/length,
			half=math.max(Game.mapSizeX,Game.mapSizeZ)*.6,corridor={{0,0,0},{Game.mapSizeX,0,0},{Game.mapSizeX,0,Game.mapSizeZ},{0,0,Game.mapSizeZ}}}
	end
	function M.choose(f,group,ids,contacts,now)
		local m=f.mapState or M.initialize(f); local center=C.U.center(ids); m.home=m.home or C.U.copy(center)
		for i,p in ipairs(m.cells) do
			if C.U.distance(center,p)<350 or Spring.GetPositionLosState(p[1],p[2],p[3]) then m.visits[i]=now end
		end
		local best,score,kind,reason,key
		local value=0; for _,id in ipairs(ids) do local h,maxh=Spring.GetUnitHealth(id); value=value+C.classify.definition(Spring.GetUnitDefID(id)).cost*(h and maxh and h/math.max(1,maxh) or 1) end
		local function setback(p) local penalty=0; for _,v in ipairs(m.failures or {}) do if now-v.time<120 and C.U.distance(p,v.point)<900 then penalty=penalty+(120-(now-v.time))*100 end end; return penalty end
		if group~='SCOUT' and C.targeting then
			local v,why=C.targeting.choose(ids,contacts,group,f.delegation and f.delegation.sector,nil,function(contact) return setback(contact.position)==0 end)
			if v then best=v.position; kind='ATTACK CONTACT'; reason=why..'; native Fight approach'; key='visual:'..v.id end
		elseif group~='SCOUT' then
			for _,v in ipairs(contacts) do if v.visibility=='VISUAL' and v.defID then
				local def=C.classify.definition(v.defID); local vulnerable=def.builder or def.range==0 or def.role=='ARTILLERY'
				local risk=C.rules.risk(v.position,contacts,450)
				if (group=='MAIN' and risk<math.max(150,value*1.2) or group~='MAIN' and vulnerable and risk<math.max(200,value*1.5)) and setback(v.position)==0 then
					local s=C.U.distance(center,v.position)+risk*(group=='MAIN' and .15 or 2)-(vulnerable and 500 or 0)
					if not score or s<score then best=v.position; score=s; kind='ATTACK CONTACT'; reason='Attack currently visible enemy contact; native Fight chooses local targets.'; key='visual:'..v.id end
				end
			end end
		end
		-- Public resource locations are useful objectives even before their occupancy is known.
		-- Only our own mexes and current visual enemy contacts establish occupancy.
		if not best and group~='SCOUT' then
			local owned={}; for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do
				local def=UnitDefs[Spring.GetUnitDefID(id)]
				if C.U.owned(id) and def and tonumber((def.customParams or {}).metal_extractor_mult) then owned[#owned+1]=C.U.position(id) end
			end
			m.resourceAttempts=m.resourceAttempts or {}
			for i,spot in ipairs(WG.metalSpots or {}) do
				local p={spot.x,spot.y or Spring.GetGroundHeight(spot.x,spot.z),spot.z}; local held=false
				for _,q in ipairs(owned) do if C.U.distance(p,q)<100 then held=true; break end end
				local risk=C.rules.risk(p,contacts,650); local distance=C.U.distance(center,p)
				local age=now-(m.resourceAttempts[i] or -600); local reserved=false
				for other,mission in pairs(m.missions) do if other~=group and mission.resource==i and now-mission.time<60 then reserved=true end end
				if not held and not reserved and age>=45 and distance>250 and risk<math.max(150,value*1.2) and setback(p)==0 then
					local forward=group=='MAIN' and m.attackPhase and math.min(2400,C.U.distance(m.home,p)) or 0
					local s=distance+ risk*2-math.min(300,age)-forward*.8
					if not score or s<score then best=p; score=s; kind='SECURE RESOURCE'; key='mex:'..i; reason='Advance to public metal node '..i..' and contest access; unseen defenders and occupancy remain unknown.' end
				end
			end
		end
		if not best then
			for i,p in ipairs(m.cells) do
				local age=math.min(600,now-(m.visits[i] or -600)); local tried=now-(m.attempts[i] or -600)
				local reserved=0; for other,mission in pairs(m.missions) do if other~=group and mission.cell==i and now-mission.time<90 then reserved=8000 end end
				local risk=C.rules.risk(p,contacts,600)
				local s=C.U.distance(center,p)*.35-age*8+math.max(0,90-tried)*100+reserved+risk*2+setback(p)
				if risk<math.max(150,value*1.2) and C.U.distance(center,p)>400 and (not score or s<score) then best=p; score=s; key=i; kind=group=='MAIN' and 'SEARCH ADVANCE' or 'SCOUT MAP'; reason='Search least recently observed map sector '..i..'; unseen space is unknown.' end
			end
		end
		if best then
			m.missions[group]={point=C.U.copy(best),cell=type(key)=='number' and key or nil,time=now,kind=kind,target=type(key)=='string' and tonumber(key:match('^visual:(%d+)$')) or nil}
			local resource=type(key)=='string' and tonumber(key:match('^mex:(%d+)$'))
			if resource then m.resourceAttempts[resource]=now; m.missions[group].resource=resource end
			if type(key)=='number' then m.attempts[key]=now end
			C.debug.log('MAP_CONTROL',group..': '..reason)
		end
		return best,kind,reason
	end
	function M.review(f,group,ids,op,contacts,now)
		if not op or not op.active then return end
		local center=C.U.center(ids); if not center then return end
		local nearCombat=C.observations.nearCombat(center,650)
		local mission=f.mapState and f.mapState.missions[group]
		local arrived,total=0,0
		for _,id in ipairs(op.units) do if f.members[id] and C.U.owned(id) then total=total+1; if C.U.distance(C.U.position(id),op.slots[id])<180 then arrived=arrived+1 end end end
		local contactInterrupt=false
		if C.targeting and group~='SCOUT' and now-op.created>=12 and mission and mission.target then
			local best,why,score=C.targeting.choose(ids,contacts,group,f.delegation.sector,900)
			local previous
			for _,v in ipairs(contacts) do if v.id==mission.target then previous=C.targeting.score(v,center,group); if previous then previous=previous-C.rules.risk(v.position,contacts,450)*.3 end; break end end
			if best and best.id~=mission.target and (not previous or score>previous+250) then contactInterrupt=true; C.debug.log('TARGET REVIEW',why) end
		end
		if group=='MAIN' and now-op.created>=12 and mission and mission.kind~='ATTACK CONTACT' then
			-- A remote contact must not restart the same march every 12 seconds.
			for _,v in ipairs(contacts) do if v.visibility=='VISUAL' and C.U.distance(center,v.position)<900 then contactInterrupt=true; break end end
		end
		if not nearCombat and (total>0 and arrived/total>=.7 or now-op.created>=60) or contactInterrupt then
			C.officer.cancel(op.id); op.accounted=true
			f.delegation.next[group]=now; f.delegation.failures[group]=0
		end
	end
	return M
end
