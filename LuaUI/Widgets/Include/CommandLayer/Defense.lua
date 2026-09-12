-- Own assets and player-visible contacts only. All orders pass through Officer.
return function(C)
	local D={}
	local function eligible(f,id)
		local d=f.delegation
		return f.members[id] and not f.suspended[id] and not d.blocked[id] and C.U.owned(id) and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1
	end
	local function suitable(id)
		local v=C.classify.definition(Spring.GetUnitDefID(id)); local h,m=Spring.GetUnitHealth(id)
		return v.ground and not v.builder and v.range>0 and (v.role=='RAIDER' or v.role=='RIOT' or v.role=='ASSAULT' or v.role=='OTHER') and h and m and h/math.max(1,m)>=.5
	end
	local function cost(id) return math.max(1,C.classify.definition(Spring.GetUnitDefID(id)).cost) end
	local function transfer(d,id,to)
		local owner=C.registry.owner[id]; local op=owner and C.registry.operations[owner]
		if op then C.orders.clearCorrection(op,id); C.registry.owner[id]=nil; C.registry.generation[id]=(C.registry.generation[id] or 0)+1 end
		for _,list in pairs(d.groups) do for i=#list,1,-1 do if list[i]==id then table.remove(list,i) end end end
		d.groups[to][#d.groups[to]+1]=id
		d.recruits=d.recruits or {}; d.recruits[id]=to=='MAIN' and true or nil
	end
	local function ids(f,group)
		local result={}; for _,id in ipairs(f.delegation.groups[group]) do if eligible(f,id) then result[#result+1]=id end end; return result
	end
	function D.tick(f,now,makePlan)
		local d=f.delegation
		d.groups.RESERVE=d.groups.RESERVE or {}; d.groups.DEFENSE=d.groups.DEFENSE or {}
		local r=d.defense or {health={},next=0,home=C.U.copy(d.sector.origin)}; d.defense=r
		local assets={}; local anchor,anchorDistance; local contacts=C.observations.snapshot().contacts
		local threat,best= nil,0
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID())) do
			if C.U.owned(id) then
				local def=UnitDefs[Spring.GetUnitDefID(id)]; local v=C.classify.definition(Spring.GetUnitDefID(id))
				if def and (def.isFactory or def.isBuilding or v.builder or v.role=='ARTILLERY' or v.role=='SUPPORT') then
					local p=C.U.position(id); local h,m=Spring.GetUnitHealth(id)
					if p then
						assets[#assets+1]={id=id,point=p,radius=(def.isFactory or def.isBuilding or v.builder) and 800 or 450}
						if def.isFactory then local distance=C.U.distance(p,d.sector.origin); if not anchorDistance or distance<anchorDistance then anchor=p; anchorDistance=distance end end
						local previous=r.health[id]
						if h and previous and h<previous-1 then r.damage={point=C.U.copy(p),untilTime=now+12,id=id} end
						r.health[id]=h
					end
				end
			end
		end
		if anchor then r.home=C.U.copy(anchor) end
		for id in pairs(r.health) do if not C.U.owned(id) then r.health[id]=nil end end
		-- Unknown contacts contribute uncertainty, never an invented unit identity.
		for _,asset in ipairs(assets) do
			for _,v in ipairs(contacts) do
				if C.U.distance(asset.point,v.position)<asset.radius and C.formations.inCorridor(d.sector,v.position) then
					local risk=C.rules.risk(v.position,contacts,600)
					if risk>best then best=risk; threat={point=C.U.copy(v.position),risk=risk,asset=asset.id,reason=v.visibility=='VISUAL' and 'Observed armed enemies near an owned asset.' or 'Unidentified radar contacts near an owned asset; identity unknown.'} end
				end
			end
		end
		if r.damage and now<r.damage.untilTime and C.formations.inCorridor(d.sector,r.damage.point) then
			if not threat then threat={point=r.damage.point,risk=195,asset=r.damage.id,reason='Owned asset lost health; attacker identity and position are not inferred.'} end
		end
		if threat and C.recovery then C.recovery.threat(threat.point) end
		local recoveryHold=not threat and r.threat and C.recovery and C.recovery.hold(r.threat.point,now)
		if recoveryHold then r.reason="Reserve escort: waiting for repairs, reconstruction and wreck clearance." end
		if threat then if not r.threat then r.next=now end; r.threat=threat; r.lastThreat=now end
		if not threat and r.threat and not recoveryHold and now-r.lastThreat>=20 then
			if d.ops.DEFENSE then C.officer.cancel(d.ops.DEFENSE); d.ops.DEFENSE=nil end
			local returning=C.U.copy(d.groups.DEFENSE)
			for _,id in ipairs(returning) do transfer(d,id,'MAIN') end
			r.threat=nil; r.reason=nil; r.next=now; r.signature=nil
			C.debug.log('DEFENSE_CLEAR','No current threat for 20 seconds; rebuild reserve and return reinforcements to main force.')
		end
		local all=C.officer.members(f); local total=0; for _,id in ipairs(all) do total=total+cost(id) end
		local fraction=(C.settings.reservePercent or 20)/100
		r.targetValue=#all>=5 and total*fraction or 0
		local home=r.home
		if not r.threat then
			-- Stable membership: refill losses without rotating the whole reserve.
			local value=0
			for i=#d.groups.RESERVE,1,-1 do local id=d.groups.RESERVE[i]; if not eligible(f,id) or not suitable(id) then transfer(d,id,'MAIN') else value=value+cost(id) end end
			for i=#d.groups.RESERVE,1,-1 do local id=d.groups.RESERVE[i]; if value-cost(id)>=r.targetValue or r.targetValue==0 then value=value-cost(id); transfer(d,id,'MAIN') end end
			local candidates={}; for _,id in ipairs(d.groups.MAIN) do if eligible(f,id) and suitable(id) then candidates[#candidates+1]=id end end
			table.sort(candidates,function(a,b) local x,y=C.U.distance(C.U.position(a),home),C.U.distance(C.U.position(b),home); return x==y and a<b or x<y end)
			for _,id in ipairs(candidates) do if value>=r.targetValue then break end; transfer(d,id,'RESERVE'); value=value+cost(id) end
			r.reserveValue=value; r.state='RESERVE READY'
		else
			local committed=0; for _,id in ipairs(ids(f,'DEFENSE')) do committed=committed+cost(id) end
			local desired=math.min(total*.7,math.max(r.targetValue,r.threat.risk*1.3))
			local reserve=C.U.copy(d.groups.RESERVE)
			for _,id in ipairs(reserve) do if eligible(f,id) and suitable(id) then transfer(d,id,'DEFENSE'); committed=committed+cost(id) end end
			local candidates={}
			for _,group in ipairs({'MAIN','RAID','SCOUT'}) do for _,id in ipairs(d.groups[group]) do if eligible(f,id) and suitable(id) then candidates[#candidates+1]=id end end end
			table.sort(candidates,function(a,b) local x,y=C.U.distance(C.U.position(a),r.threat.point),C.U.distance(C.U.position(b),r.threat.point); return x==y and a<b or x<y end)
			for _,id in ipairs(candidates) do if committed>=desired then break end; transfer(d,id,'DEFENSE'); committed=committed+cost(id) end
			r.committedValue=committed; r.reserveValue=0; r.state=recoveryHold and 'ESCORTING RECOVERY' or 'DEFENDING'; r.reason=recoveryHold and 'Reserve escort: repair/rebuild/reclaim in progress.' or r.threat.reason
		end
		local group=r.threat and 'DEFENSE' or 'RESERVE'; local selected=ids(f,group); table.sort(selected)
		local target=r.threat and r.threat.point or home
		if recoveryHold then local dx,dz=target[1]-home[1],target[3]-home[3]; local length=math.max(1,math.sqrt(dx*dx+dz*dz)); if length<=1 then dx=1; dz=0 end; local offset=400+math.min(600,#selected*8); local x=math.max(16,math.min(Game.mapSizeX-16,target[1]+dx/length*offset)); local z=math.max(16,math.min(Game.mapSizeZ-16,target[3]+dz/length*offset)); target={x,Spring.GetGroundHeight(x,z),z} end
		local signature=table.concat(selected,',')
		local op=d.ops[group] and C.registry.operations[d.ops[group]]
		local changed=signature~=r.signature or r.target and C.U.distance(target,r.target)>200
		local distant=false; for _,id in ipairs(selected) do if C.U.distance(C.U.position(id),op and op.slots[id] or target)>300 then distant=true; break end end
		if #selected>0 and now>=r.next and (changed or (not op or not op.active) and (r.threat or distant)) then
			local p=makePlan(f,selected,target,group,contacts)
			local operation=p and C.officer.executeDelegated(f,selected,p,group,CMD.FIGHT)
			if operation then
				if op and op.active then C.officer.cancel(op.id) end
				d.ops[group]=operation; C.registry.operations[operation].mode='ARRIVAL'
				r.signature=signature; r.target=C.U.copy(target)
				C.debug.log(group,#selected..' units; '..(r.threat and r.threat.reason or 'Hold near home assets; reserved from map-wide pushes.'))
			end
			r.next=now+10
		end
		if not r.threat then r.state=#selected==0 and 'NO STANDING RESERVE' or distant and 'RESERVE ASSEMBLING' or 'RESERVE READY' end
		d.decisions.RESERVE={state=r.threat and 'COMMITTED' or r.state,reason='Target '..math.floor(r.targetValue)..' metal; available '..math.floor(r.reserveValue or 0)..'.',time=now}
		d.decisions.DEFENSE={state=r.threat and 'DEFENDING' or 'WATCHING',reason=r.threat and r.reason or 'Watching owned assets; reserve commits before field reinforcements.',time=now}
	end
	return D
end
