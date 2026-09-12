-- Decisions only. Officer validates delegation; Orders is the sole combat executor.
return function(C)
	local T={last=-100}
	function T.start(f)
		local ids={}; for _,id in ipairs(C.officer.members(f)) do if not C.classify.definition(Spring.GetUnitDefID(id)).builder then ids[#ids+1]=id end end; local sector=C.rules.sector(ids,f.objective)
		if not sector then return false,'Draw an objective line at least 128 units from the force.' end
		f.grant=(f.grant or 0)+1
		f.delegation={token=f.grant,active=true,sector=sector,groups=C.rules.groups(ids),ops={},next={},visits={},blocked={},failures={},returning={},decisions={},state='ASSEMBLING',reason='Explicit Scout + Raid + Push delegation.',version=C.rules.version}
		C.input.preview={slots={},zones={},gesture=f.objective,center=sector.goal,front={sector.ux,sector.uz},corridor=sector.corridor}
		return true
	end
	local function members(f,group)
		local ids={}; local d=f.delegation
		for _,id in ipairs(d.groups[group]) do
			if f.members[id] and not f.suspended[id] and not d.blocked[id] and C.U.owned(id) and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1 then ids[#ids+1]=id end
		end
		return ids
	end
	local function rebalance(f)
		local d=f.delegation; local live=#C.officer.members(f)
		local wanted={SCOUT=live>=5 and math.min(2,math.max(1,math.floor(live*.1))) or 0,RAID=live>=8 and math.min(4,math.floor(live*.2)) or 0}
		for _,group in ipairs({'SCOUT','RAID'}) do
			local count=#members(f,group)
			if count<wanted[group] then
				for i=#d.groups.MAIN,1,-1 do
					local id=d.groups.MAIN[i]; local role=C.classify.definition(Spring.GetUnitDefID(id)).role
					if f.members[id] and C.U.owned(id) and not f.suspended[id] and not d.blocked[id] and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1 and (role=='RAIDER' or group=='SCOUT' and role=='SCOUT') then
						table.remove(d.groups.MAIN,i); d.groups[group][#d.groups[group]+1]=id; count=count+1
						if count>=wanted[group] then break end
					end
				end
			end
		end
	end
	local function plan(f,ids,target,group,contacts)
		local s=f.delegation.sector; local settings=C.U.copy(C.settings); settings.formation=group=='MAIN' and f.formation or 'LINE'
		local riots=0; for _,v in ipairs(contacts) do if v.visibility=='VISUAL' and v.role=='RIOT' then riots=riots+1 end end
		if riots>=2 then settings.spacing=math.min(256,settings.spacing*1.5) end
		local half=math.min(s.half*.7,math.max(32,#ids*settings.spacing/4))
		local a={target[1]-s.px*half,0,target[3]-s.pz*half}; local b={target[1]+s.px*half,0,target[3]+s.pz*half}
		if not C.U.point(a) or not C.U.point(b) then return nil end
		local ground=C.classify.filter(ids); if #ground==0 then ground=ids end
		local p=C.formations.plan(ground,{a,b},settings); if not p then return nil end
		p.corridor=s.corridor
		return C.formations.fitCorridor(p,s,settings)
	end
	function T.tick(f,now)
		local d=f.delegation; if not d or not d.active then return end
		if not C.U.delegationAllowed(C.settings) then C.officer.setDelegated(f.id,false); return end
		if #C.officer.members(f)==0 then C.officer.setDelegated(f.id,false); f.status='PLAYER_OVERRIDE'; return end
		-- Congestion gets a bounded retry; manual/unknown queue overrides never do.
		for id,untilTime in pairs(d.blocked) do if type(untilTime)=='number' and now>=untilTime then d.blocked[id]=nil end end
		rebalance(f)
		local forceIDs=C.officer.members(f); local centerNow=C.U.center(forceIDs)
		local progressNow=C.rules.progress(d.sector,centerNow)
		d.review=d.review or {time=now,progress=progressNow,count=#forceIDs}
		if progressNow>d.review.progress+128 then d.review.time=now; d.review.progress=progressNow end
		if not f.objectiveReached and f.front~='HOLD' and (now-d.review.time>=60 or #forceIDs<d.review.count*.75) then
			local why=#forceIDs<d.review.count*.75 and 'At least 25% of assigned units were lost or released.' or 'No substantial forward progress for 60 game seconds.'
			C.officer.setDelegated(f.id,false); f.reviewReason=why; f.status='REVIEW_REQUIRED'
			C.debug.log('REVIEW',why..' Delegation stopped; review a revised plan.')
			if C.advisor then C.advisor.ask(f.id,true,true) end
			return
		end
		local s=d.sector; local snapshot=C.observations.snapshot(); local contacts={}
		for _,v in ipairs(snapshot.contacts) do if C.formations.inCorridor(s,v.position) then contacts[#contacts+1]=v end end
		d.observed=snapshot.time; d.known={}; for _,v in ipairs(contacts) do d.known[v.role]=(d.known[v.role] or 0)+1 end
		for _,group in ipairs({'SCOUT','RAID','MAIN'}) do
			local ids=members(f,group); local op=d.ops[group] and C.registry.operations[d.ops[group]]
			if #ids==0 then d.decisions[group]={state='UNAVAILABLE',reason='No eligible surviving units in this detachment.',time=now} elseif op and op.active and d.decisions[group] then d.decisions[group].state=op.state end
			if op and not op.active and not op.accounted then
				op.accounted=true
				if op.state~='COMPLETED' and not op.arrivals then d.failures[group]=(d.failures[group] or 0)+1 else d.failures[group]=0 end
				d.next[group]=now+(op.state=='COMPLETED' and (group=='MAIN' and 3 or 12) or 15)
			end
			if #ids>0 and (d.failures[group] or 0)<3 then
				local center=C.U.center(ids); local health=C.rules.health(ids); local retreat=group~='MAIN' and (health<.4 or C.rules.risk(center,contacts,350)>math.max(300,#ids*180))
				local emergency=retreat and not d.returning[group] and op and op.active and now-op.created>=8
				if emergency then C.officer.cancel(op.id); op=nil; d.next[group]=now end
				if (not op or not op.active) and now>=(d.next[group] or 0) then
					local target,reason,kind,visit; local returning=false
					if retreat then
						target=C.rules.point(s,math.max(0,C.rules.progress(s,center)-400),0); reason='Damaged/exposed light detachment returns inside its assigned corridor.'; kind='WITHDRAW'; returning=true
					elseif group=='SCOUT' then
						target,visit=C.rules.scout(s,ids,contacts,d.visits,now); reason='Revisit least recently checked corridor flank; prefer unobserved points. Unknown is not safe.'; kind='SCOUT'
					elseif group=='RAID' then
						target=C.rules.raid(s,ids,contacts); kind='HARASS'
						if target then reason='Visible local vulnerable unit; no observed heavy protection at destination.' else target,visit=C.rules.scout(s,ids,contacts,d.visits,now); reason='No suitable visual raid target. Patrol the assigned flank for contacts.' end
					else
						local progress=C.rules.progress(s,center); local nextLine=math.min(s.length,math.max(0,progress)+C.rules.step)
						if f.front=='HOLD' then nextLine=math.max(0,progress) end
						local side=f.front=='FLANK_LEFT' and -1 or f.front=='FLANK_RIGHT' and 1 or 0
						target=C.rules.point(s,nextLine,nextLine<s.length-128 and side*s.half*.4 or 0)
						kind=nextLine>=s.length and 'PUSH' or 'ADVANCE'; reason='Advance main role formation by up to 600 game units; native Fight engages observed opposition.'
						if side==0 and f.front~='HOLD' and target and nextLine<s.length-128 then
							local risk=C.rules.risk(target,contacts,600)
							for _,flank in ipairs({-1,1}) do local alternative=C.rules.point(s,nextLine,flank*s.half*.45); if alternative then local flankRisk=C.rules.risk(alternative,contacts,600); if flankRisk+150<risk then target=alternative; risk=flankRisk; reason='Shift main advance toward less observed resistance inside the corridor. Unobserved opposition may remain.' end end end
						end
						if health<.3 then target=nil; d.state='HOLDING'; d.reason='Main force below 30% average health; player reinforcement or a new objective needed.'
						elseif f.objectiveReached or (progress>=s.length-96 or f.front=='HOLD') and target and C.U.distance(center,target)<200 then target=nil; d.state='HOLDING'; d.reason='Holding current front; scouts and raid detachment continue within the corridor.' end
					end
					if target then
						local p=plan(f,ids,target,group,contacts)
						if p then
							local id=C.officer.executeDelegated(f,ids,p,kind,(group=='SCOUT' or kind=='WITHDRAW') and Spring.Utilities.CMD.RAW_MOVE or CMD.FIGHT)
							if id then d.decisions[group]={state=kind,reason=reason,time=now}; d.ops[group]=id; d.state=kind; d.reason=reason; d.next[group]=now+10; if visit then d.visits[visit]=now end; d.returning[group]=returning; C.debug.log('TACTICAL',group..': '..reason) end
						else d.next[group]=now+15; d.reason='The army needs a wider objective corridor to retain distinct slots. Draw a wider line or review an army push.' end
					end
				end
			elseif (d.failures[group] or 0)>=3 then d.reason=group..' paused after three failed movements. Re-delegate after checking terrain.'; d.decisions[group]={state='PAUSED',reason=d.reason,time=now} end
		end
		local main=d.ops.MAIN and C.registry.operations[d.ops.MAIN]
		if main and main.active then d.state=main.state; d.reason=main.state=='ENGAGING' and 'Main force is exchanging fire under native unit AI; combat movement is not being overwritten.' or 'Main force advancing toward its current phase line.' end
		f.status='DELEGATED / '..d.state
	end
	function T.update()
		local now=C.U.now(); if now-T.last<2 then return end; T.last=now
		for _,f in pairs(C.registry.forces) do T.tick(f,now) end
	end
	return T
end
