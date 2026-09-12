-- Decisions only. Officer validates delegation; Orders is the sole combat executor.
return function(C)
	local T={last=-100}
	function T.start(f)
		local ids={}; for _,id in ipairs(C.officer.members(f)) do if not C.classify.definition(Spring.GetUnitDefID(id)).builder then ids[#ids+1]=id end end; local sector=C.rules.sector(ids,f.objective)
		if not sector then return false,'Draw an objective line at least 128 units from the force.' end
		f.grant=(f.grant or 0)+1
		f.delegation={token=f.grant,active=true,sector=sector,groups=f.objectiveMode=='UTTER DESTRUCTION' and {SCOUT={},RAID={},MAIN=ids} or C.rules.groups(ids),ops={},next={},visits={},blocked={},failures={},returning={},decisions={},state='ASSEMBLING',reason='Explicit Scout + Raid + Push delegation.',version=C.rules.version}
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
		local d=f.delegation; if f.objectiveMode=='UTTER DESTRUCTION' then return end; local live=#C.officer.members(f)
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
		local s=f.delegation.sector; local settings=C.U.copy(C.settings); settings.formation=group=='MAIN' and (f.delegation.strategy and f.delegation.strategy.formation or f.formation) or 'LINE'
		if f.delegation.strategy then settings.spacing=f.delegation.strategy.spacing end
		local riots=0; for _,v in ipairs(contacts) do if v.visibility=='VISUAL' and v.role=='RIOT' then riots=riots+1 end end
		if riots>=2 then settings.spacing=math.min(256,settings.spacing*1.5) end
		local half=math.min(s.half*.7,math.max(32,#ids*settings.spacing/4))
		local a={target[1]-s.px*half,0,target[3]-s.pz*half}; local b={target[1]+s.px*half,0,target[3]+s.pz*half}
		-- A broad corridor near an edge must still reach the packing planner.
		for _,point in ipairs({a,b}) do point[1]=math.max(8,math.min(Game.mapSizeX-8,point[1])); point[3]=math.max(8,math.min(Game.mapSizeZ-8,point[3])) end
		if not C.U.point(a) or not C.U.point(b) then return nil end
		local ground=C.classify.filter(ids); if #ground==0 then ground=ids end
		local p=C.formations.plan(ground,{a,b},settings); if not p then return nil end
		-- Falling back must not flip artillery to the enemy-facing side of the screen.
		if f.delegation.recovery and p.front[1]*s.ux+p.front[2]*s.uz<0 then
			for _,slot in pairs(p.slots) do local depth=(slot[1]-p.center[1])*p.front[1]+(slot[3]-p.center[3])*p.front[2]; slot[1]=slot[1]-2*depth*p.front[1]; slot[3]=slot[3]-2*depth*p.front[2] end
			p.front={s.ux,s.uz}
		end
		p.corridor=s.corridor
		p=C.formations.fitCorridor(p,s,settings)
		if p and C.routing then
			p.priority=f.delegation.recovery and f.delegation.recovery.priority
			p=C.routing.prepare(p,s)
			if p.routing.adjusted+p.routing.detours+p.routing.unresolved>0 then C.debug.log('ROUTING',p.routing.adjusted..' adjusted slots; '..p.routing.detours..' detours; '..p.routing.unresolved..' unresolved terrain checks (native pathfinding remains active).') end
		end
		return p
	end
	local function recoveryIDs(f)
		local ids={}; local d=f.delegation
		for _,id in ipairs(C.officer.members(f)) do
			if not d.blocked[id] and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1 then ids[#ids+1]=id end
		end
		return ids
	end
	function T.beginRecovery(f,now,why)
		local d=f.delegation; local center=C.U.center(C.officer.members(f)); local old=d.strategy
		for _,op in pairs(C.registry.operations) do if op.forceID==f.id and op.active then C.officer.cancel(op.id) end end
		for id,blocked in pairs(d.blocked) do if type(blocked)=='number' then d.blocked[id]=nil end end
		local contacts=C.observations.snapshot().contacts; local along=math.min(d.sector.length,C.rules.progress(d.sector,center)+300)
		local side=old and -old.side or -1; local best=math.huge
		for _,candidate in ipairs({side,-side}) do
			local p=C.rules.point(d.sector,along,candidate*d.sector.half*.4)
			if p then local risk=C.rules.risk(p,contacts,600); if risk<best then best=risk; side=candidate end end
		end
		local previousStep=old and old.step or f.objectiveMode=='SHOCK AND AWE' and 900 or f.objectiveMode=='UTTER DESTRUCTION' and 750 or C.rules.step
		d.strategy={revision=(old and old.revision or 0)+1,formation='ASSAULT',spacing=math.min(256,(old and old.spacing or C.settings.spacing)*1.2),step=math.max(240,previousStep*.65),side=side,reason=why}
		d.ops={}; d.failures={}; d.next={}; d.returning={}
		d.recovery={phase='WITHDRAWING',target=C.rules.point(d.sector,math.max(0,C.rules.progress(d.sector,center)-450),0),created=now,attempts=0,next=now,reason=why}
		local selection=C.retreatPriority.select(recoveryIDs(f))
		-- Units pushed outside the authorized corridor must return, not invalidate
		-- the covering action for every healthy unit still inside it.
		local cover={}
		for _,id in ipairs(selection.cover) do
			if C.formations.inCorridor(d.sector,C.U.position(id)) then cover[#cover+1]=id
			else selection.evacuate[#selection.evacuate+1]=id end
		end
		selection.cover=cover
		d.recovery.priority=selection.priority; d.recovery.evacuate=selection.evacuate; d.recovery.cover=selection.cover
		d.recovery.injured=selection.injured
		if selection.injured>0 and #selection.cover>0 and #selection.evacuate>0 then
			d.recovery.phase='EVACUATING'; d.recovery.coverUntil=now+12
			local coverCenter=C.U.center(selection.cover)
			local coverPlan={slots={},units=C.U.copy(selection.cover),origin=coverCenter,center=coverCenter,front={d.sector.ux,d.sector.uz},shape='COVER',zones={},gesture={coverCenter},corridor=d.sector.corridor,width=0}
			for _,id in ipairs(selection.cover) do coverPlan.slots[id]=C.U.position(id) end
			local covered=C.officer.executeDelegated(f,selection.cover,coverPlan,'COVER',CMD.FIGHT)
			if covered then
				C.registry.operations[covered].mode='ARRIVAL'; d.recovery.coverOperation=covered
				C.debug.log('COVER',#selection.cover..' healthy cover units; '..selection.injured..' injured first. Cover lasts at most 12 seconds.')
			else d.recovery.phase='WITHDRAWING'; C.debug.log('COVER_UNAVAILABLE','Cover plan rejected; withdraw the force immediately.') end
		end
		d.reason=why..' Automatic fallback, role regroup, then a shorter alternate-lane advance. Unknown terrain remains uncertain.'
		C.debug.log('ADAPT',d.reason)
	end
	function T.recoveryTick(f,now)
		local d=f.delegation; local r=d.recovery; local ids=recoveryIDs(f)
		if #ids==0 then d.state='HOLDING'; d.reason='No eligible units for recovery; native retreat/manual override retained.'; f.status='DELEGATED / HOLDING'; return end
		if r.phase=='EVACUATING' then
			local ready=0; local total=0; local exposed=false
			for _,id in ipairs(r.evacuate) do if f.members[id] and C.U.owned(id) then total=total+1; if r.target and C.rules.progress(d.sector,C.U.position(id))<=C.rules.progress(d.sector,r.target)+150 then ready=ready+1 end end end
			for _,id in ipairs(r.cover) do if f.members[id] and C.U.owned(id) then local h,m=Spring.GetUnitHealth(id); if h and m and h/m<.6 then exposed=true end end end
			if exposed or now>=r.coverUntil or total==0 or r.operation and total>0 and ready/total>=.8 then
				if r.coverOperation then C.officer.cancel(r.coverOperation); r.coverOperation=nil end
				if r.operation then C.officer.cancel(r.operation); r.operation=nil end
				r.phase='WITHDRAWING'; r.next=now; d.reason='Damaged units had first exit; covering units now fall back.'; C.debug.log('COVER_RELEASE',exposed and 'Cover taking damage: withdraw immediately.' or 'Evacuation head start complete; withdraw cover.')
			end
		end
		local op=r.operation and C.registry.operations[r.operation]
		if op and op.active then
			local arrived,total=0,0
			for _,id in ipairs(op.units) do
				if f.members[id] and not f.suspended[id] and C.U.owned(id) and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1 then
					total=total+1; if C.U.distance(C.U.position(id),op.slots[id])<96 then arrived=arrived+1 end
				end
			end
			-- A few congested stragglers must not freeze a recovered army.
			if total>0 and arrived/total>=.8 then C.registry.finish(op,'COMPLETED') end
		end
		if op and op.active and now-op.created>45 then C.officer.cancel(op.id); op.state='ABORTED' end
		if op and not op.active then
			r.operation=nil
			if op.state=='COMPLETED' then
				if r.phase=='EVACUATING' then if r.coverOperation then C.officer.cancel(r.coverOperation); r.coverOperation=nil end; r.phase='WITHDRAWING'; r.next=now
				elseif r.phase=='WITHDRAWING' then r.phase='REFORMING'; r.target=C.U.center(ids); r.next=now+3; d.reason='Fallback complete; assemble revised role zones before another advance.'
				else r.phase='HOLDING'; r.ready=true; r.next=now+8; d.reason='Regroup complete; stabilize for eight seconds and recover above 50% average health.' end
			else
				r.attempts=r.attempts+1; d.reason=r.phase..' incomplete ('..op.state..'); recovery failure '..r.attempts..'/3. Wait 20 seconds before regroup retry.'
				r.phase='HOLDING'; r.next=now+20; r.ready=false; C.debug.log('RECOVERY_RETRY',d.reason)
			end
		end
		if r.phase~='EVACUATING' and r.coverOperation then
			C.officer.cancel(r.coverOperation); r.coverOperation=nil; r.phase='WITHDRAWING'; r.next=now
		end
		if r.phase=='HOLDING' and now>=r.next then
			if r.ready and C.rules.health(ids)>=.5 then
				d.review={time=now,progress=C.rules.progress(d.sector,C.U.center(ids)),count=#C.officer.members(f)}
				d.recoverAfter=now+30; d.recovery=nil; d.state='ADVANCING'; d.reason='Regroup complete: shorter phases, wider role zones and revised approach lane.'
				C.debug.log('ADAPT_RESUME',d.reason); f.status='DELEGATED / ADVANCING'; return
			elseif not r.ready and r.attempts<3 then r.phase='REFORMING'; r.target=C.U.center(ids)
			else r.next=now+20; d.reason=r.ready and 'Regrouped; wait for average health above 50% before another advance.' or 'Recovery route repeatedly failed; holding without order spam. A new objective can restart movement.' end
		end
		if r.phase~='HOLDING' and not r.operation and now>=r.next then
			local moving=ids
			if r.phase=='EVACUATING' then local allowed={}; for _,id in ipairs(r.evacuate) do allowed[id]=true end; moving={}; for _,id in ipairs(ids) do if allowed[id] then moving[#moving+1]=id end end end
			local target=r.target or C.U.center(ids); local p=#moving>0 and plan(f,moving,target,'MAIN',C.observations.snapshot().contacts)
			local operation=p and C.officer.executeDelegated(f,moving,p,r.phase,Spring.Utilities.CMD.RAW_MOVE)
			if operation then C.registry.operations[operation].mode='ARRIVAL'; r.operation=operation; C.debug.log('RECOVERY',r.phase..': '..#moving..' units; native movement, strategy revision '..d.strategy.revision)
			else r.attempts=r.attempts+1; r.phase='HOLDING'; r.next=now+20; d.reason='No valid recovery geometry; holding before retry.' end
		end
		d.state=r.phase; f.status='DELEGATED / '..r.phase
	end
	function T.tick(f,now)
		local d=f.delegation; if not d or not d.active then return end
		if not C.U.delegationAllowed(C.settings) then C.officer.setDelegated(f.id,false); return end
		if #C.officer.members(f)==0 then if C.startup and C.startup.enabled and C.startup.forceID==f.id then d.active=false; d.state='WAITING FOR UNITS'; return end; C.officer.setDelegated(f.id,false); f.status='PLAYER_OVERRIDE'; return end
		-- Congestion gets a bounded retry; manual/unknown queue overrides never do.
		for id,untilTime in pairs(d.blocked) do if type(untilTime)=='number' and now>=untilTime then d.blocked[id]=nil end end
		rebalance(f)
		local forceIDs=C.officer.members(f); local centerNow=C.U.center(forceIDs)
		local progressNow=C.rules.progress(d.sector,centerNow)
		d.review=d.review or {time=now,progress=progressNow,count=#forceIDs}
		if progressNow>d.review.progress+128 then d.review.time=now; d.review.progress=progressNow end
		if d.recovery then T.recoveryTick(f,now); return end
		if not f.objectiveReached and f.front~='HOLD' and now>=(d.recoverAfter or 0) and (now-d.review.time>=60 or #forceIDs<d.review.count*.75 or C.rules.health(forceIDs)<.4) then
			local why=#forceIDs<d.review.count*.75 and 'More than 25% of the review force was lost/released.' or C.rules.health(forceIDs)<.4 and 'Average force health below 40%.' or 'No substantial forward progress for 60 game seconds.'
			T.beginRecovery(f,now,why); T.recoveryTick(f,now); return
		end
		-- Catch new recruits up without restarting the army's active movement.
		local main=d.ops.MAIN and C.registry.operations[d.ops.MAIN]
		if d.recruits and main and main.active then
			local recruits={}
			for id in pairs(d.recruits) do if f.members[id] and not f.suspended[id] and not d.blocked[id] and C.U.owned(id) and not C.registry.owner[id] then recruits[#recruits+1]=id end end
			table.sort(recruits)
			if #recruits>0 then
				local p=plan(f,recruits,main.plan.center,'MAIN',C.observations.snapshot().contacts)
				if p and C.officer.executeDelegated(f,recruits,p,'REINFORCE',CMD.FIGHT) then for _,id in ipairs(recruits) do d.recruits[id]=nil end end
			end
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
						local progress=C.rules.progress(s,center); local nextLine=math.min(s.length,math.max(0,progress)+(d.strategy and d.strategy.step or f.objectiveMode=='SHOCK AND AWE' and 900 or f.objectiveMode=='UTTER DESTRUCTION' and 750 or C.rules.step))
						if f.front=='HOLD' then nextLine=math.max(0,progress) end
						local side=f.front=='FLANK_LEFT' and -1 or f.front=='FLANK_RIGHT' and 1 or d.strategy and d.strategy.side or 0
						target=C.rules.point(s,nextLine,nextLine<s.length-128 and side*s.half*.4 or 0)
						kind=nextLine>=s.length and 'PUSH' or 'ADVANCE'; reason='Advance the selected objective policy phase; native Fight handles combat. Packed ranks may extend within the corridor.'
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
