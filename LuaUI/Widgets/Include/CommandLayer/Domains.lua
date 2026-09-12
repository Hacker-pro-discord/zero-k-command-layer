-- Independent air/naval destinations; combat authority stays with Officer.
return function(C)
	local D={probes=0}
	function D.group(id) local v=C.classify.definition(Spring.GetUnitDefID(id)); return v.domain=='AIR' and 'AIR' or v.domain=='SEA' and 'SEA' or 'MAIN' end
	function D.groups(ids,allMain)
		local ground,air,sea={},{},{}
		for _,id in ipairs(ids) do local group=D.group(id); local list=group=='AIR' and air or group=='SEA' and sea or ground; list[#list+1]=id end
		local result=allMain and {SCOUT={},RAID={},MAIN=ground} or C.rules.groups(ground)
		result.AIR=air; result.SEA=sea; return result
	end
	function D.add(f,id)
		local d=f.delegation; local group=D.group(id); d.groups[group]=d.groups[group] or {}; d.groups[group][#d.groups[group]+1]=id
		if group=='MAIN' then d.recruits=d.recruits or {}; d.recruits[id]=true end
	end
	function D.waterPoint(id,target,maxDistance)
		local def=Spring.GetUnitDefID(id); local raw=UnitDefs[def]; local depth=math.max(2,raw.minWaterDepth or 0)
		local function valid(x,z)
			if x<32 or z<32 or x>Game.mapSizeX-32 or z>Game.mapSizeZ-32 then return end
			local y=Spring.GetGroundHeight(x,z); if y>-depth then return end
			-- Public terrain only. Never query hidden object occupancy.
			if D.probes>=2048 then return end; D.probes=D.probes+1
			if Spring.TestMoveOrder and not Spring.TestMoveOrder(def,x,y,z,0,0,0,true,false,false) then return end
			return {x,y,z}
		end
		local exact=valid(target[1],target[3]); if exact then return exact end
		for _,r in ipairs({64,128,256,512,1024,2048}) do if r<=(maxDistance or 2048) then
			for i=0,11 do local p=valid(target[1]+math.cos(i*math.pi/6)*r,target[3]+math.sin(i*math.pi/6)*r); if p then return p end end
		end end
	end
	function D.plan(f,ids,target,group)
		local d=f.delegation; local center=C.U.center(ids)
		local plan={slots={},units={},origin=center,center=target,front={d.sector.ux,d.sector.uz},shape=group,zones={},gesture={center,target},corridor=d.sector.corridor,width=0}
		local columns=math.max(2,math.min(32,math.ceil(math.sqrt(#ids))))
		for i,id in ipairs(ids) do
			local x=math.max(32,math.min(Game.mapSizeX-32,target[1]+((i-1)%columns-(columns-1)/2)*80)); local z=math.max(32,math.min(Game.mapSizeZ-32,target[3]+(math.floor((i-1)/columns)-(math.ceil(#ids/columns)-1)/2)*80))
			local p={x,Spring.GetGroundHeight(x,z),z}; if group=='SEA' then p=D.waterPoint(id,p,256) end
			if p and C.formations.inCorridor(d.sector,p) then plan.units[#plan.units+1]=id; plan.slots[id]=p end
		end
		return plan
	end
	function D.tick(f,now)
		D.probes=0
		local d=f.delegation; d.domains=d.domains or {}
		local contacts=C.observations.snapshot().contacts
		for _,group in ipairs({'AIR','SEA'}) do
			local ids={}; for _,id in ipairs(d.groups[group] or {}) do if f.members[id] and not f.suspended[id] and not d.blocked[id] and C.U.owned(id) and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1 and not (group=='AIR' and ((Spring.GetUnitRulesParam(id,'noammo') or 0)>0 or Spring.GetUnitRulesParam(id,'airpadReservation')==1)) then ids[#ids+1]=id end end
			if #ids>0 then
				local state=d.domains[group] or {visits={},next=0}; d.domains[group]=state
				local op=d.ops[group] and C.registry.operations[d.ops[group]]
				local emergency=d.defense and d.defense.threat and ('defend:'..tostring(d.defense.threat.asset)) or d.recovery and ('recover:'..d.recovery.created)
				if op and op.active then
					local recruits={}; for _,id in ipairs(ids) do if not C.registry.owner[id] and C.U.distance(C.U.position(id),op.slots[id] or op.plan.center)>200 then recruits[#recruits+1]=id end end
					if #recruits>0 then local p=D.plan(f,recruits,op.plan.center,group); local reinforcement=#p.units>0 and C.officer.executeDelegated(f,p.units,p,group,CMD.FIGHT); if reinforcement then C.registry.operations[reinforcement].mode='ARRIVAL' end end
					local arrived=0; for _,id in ipairs(ids) do if op.slots[id] and C.U.distance(C.U.position(id),op.slots[id])<200 then arrived=arrived+1 end end
					if emergency~=state.emergency and (not state.emergency or now>=state.next) or not C.observations.nearCombat(C.U.center(ids),600) and (arrived/#ids>=.7 or now-op.created>=60) then C.officer.cancel(op.id); state.next=now end
				end
				if (not op or not op.active) and now>=state.next then
					local center=C.U.center(ids); local target,reason,best
					local function reachable(p,limit)
						if not C.formations.inCorridor(d.sector,p) then return end
						local q=group=='SEA' and D.waterPoint(ids[1],p,limit) or p
						if q and C.formations.inCorridor(d.sector,q) then return q end
					end
					if d.defense and d.defense.threat then target=reachable(d.defense.threat.point,C.classify.definition(Spring.GetUnitDefID(ids[1])).range); reason='Respond to the current rear-area threat from a compatible position.' end
					if not target and d.recovery then target=reachable(d.recovery.target or d.sector.origin); reason='Support field recovery using this movement domain.' end
					if not target then for _,v in ipairs(contacts) do if v.visibility=='VISUAL' and v.defID then
						local point=reachable(v.position,group=='SEA' and C.classify.definition(Spring.GetUnitDefID(ids[1])).range or nil)
						if point then local score=C.U.distance(center,point); if not best or score<best then best=score; target=point; reason='Native Fight toward an observed contact; terrain-compatible destination.' end end
					end end end
					if not target then
						for x=1,10 do for z=1,10 do local index=x*10+z; local point=reachable({Game.mapSizeX*(x-.5)/10,0,Game.mapSizeZ*(z-.5)/10},group=='SEA' and 64 or nil)
							if point then local score=C.U.distance(center,point)*.2+math.max(0,180-(now-(state.visits[index] or -1000)))*50; if not best or score<best then best=score; target=point; state.chosen=index; reason='Search successive '..group:lower()..' sectors with native movement.' end end
						end end
					end
					if target then
						local plan=D.plan(f,ids,target,group)
						local operation=#plan.units>0 and C.officer.executeDelegated(f,plan.units,plan,group,CMD.FIGHT)
						if operation then C.registry.operations[operation].mode='ARRIVAL'; d.ops[group]=operation; d.state=group..' OPERATIONS'; d.reason=reason; d.decisions[group]={state=emergency and 'RESPONDING' or 'SEARCH / ATTACK',reason=reason,time=now}; state.emergency=emergency; if state.chosen then state.visits[state.chosen]=now; state.chosen=nil end; C.debug.log(group,reason..' '..#plan.units..' units.') end
					else d.decisions[group]={state='NO COMPATIBLE DESTINATION',reason='No reachable domain point inside this force objective; native queues preserved.',time=now} end
					state.next=now+12
				end
			end
		end
	end
	return D
end
