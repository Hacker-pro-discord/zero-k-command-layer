-- Local economic authority, separate from combat and recovery assignments.
return function(C)
	local E={enabled=false,workers={},excluded={},tasks={},retry={},cooldown={},jobCount=0,last=-100,status='Economy OFF',opening='AUTO'}
	local function can(id,def) local d=UnitDefs[Spring.GetUnitDefID(id)]; for _,v in ipairs(d and d.buildOptions or {}) do if v==def then return true end end end
	local function named(name) return UnitDefNames and UnitDefNames[name] and UnitDefNames[name].id end
	function E.release(id) E.workers[id]=nil; E.tasks[id]=nil; E.cooldown[id]=nil; E.excluded[id]=true end
	function E.stop() E.enabled=false; E.workers={}; E.tasks={}; E.status='Economy OFF; native queues preserved' end
	function E.start() if C.U.delegationAllowed(C.settings) then E.enabled=true; return true end; return false end
	function E.setFactory(name) if name=='AUTO' or named(name) and UnitDefs[named(name)].isFactory then E.opening=name; return true end; return false end
	function E.enroll(ids)
		if not C.U.delegationAllowed(C.settings) then return false end
		for _,id in ipairs(ids) do local v=C.classify.definition(Spring.GetUnitDefID(id)); if C.U.owned(id) and v.mobile and v.builder then if C.recovery then C.recovery.release(id) end; C.registry.release({id},'ECONOMY'); E.workers[id]=true; E.excluded[id]=nil end end
		return E.start()
	end
	local function matches(q,t)
		if not q or not t or q.id~=t.cmd then return false end
		if t.cmd==CMD.REPAIR then return q.params and q.params[1]==t.params[1] end
		return q.params and #q.params>=3 and C.U.distance(q.params,t.params)<16
	end
	function E.valid(id,cmd,p)
		local t=E.tasks[id]
		if cmd==CMD.REMOVE then
			local q=C.nativeQueue and C.nativeQueue.current(id,t) or (Spring.GetCommandQueue(id,1) or {})[1]
			return E.enabled and C.U.delegationAllowed(C.settings) and E.workers[id] and not E.excluded[id] and C.U.owned(id) and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1 and #p==1 and t and t.removeTag and p[1]==t.removeTag and q and q.tag==t.removeTag and matches(q,t)
		end
		if not E.enabled or not C.U.delegationAllowed(C.settings) or not E.workers[id] or E.excluded[id] or not C.U.owned(id) or Spring.GetUnitTransporter(id) or Spring.GetUnitRulesParam(id,'retreat')==1 or not t or t.cmd~=cmd or #t.params~=#p then return false end
		for i=1,#p do if p[i]~=t.params[i] then return false end end
		return cmd<0 and can(id,-cmd) or cmd==Spring.Utilities.CMD.RAW_MOVE or cmd==CMD.REPAIR
	end
	local function issue(id,cmd,p,key)
		E.tasks[id]={cmd=cmd,params=C.U.copy(p),key=key,time=C.U.now(),progress=C.U.now()}
		if C.orders.service('economy',id,cmd,p) then E.status=key; C.debug.log('ECONOMY',id..': '..key); return true end
		E.tasks[id]=nil; return false
	end
	function E.workerNeed()
		if not E.enabled then return 0 end
		local military=0; for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID())) do local v=C.classify.definition(Spring.GetUnitDefID(id)); if v.mobile and not v.builder then military=military+1 end end
		local n=0; for id in pairs(E.workers) do if C.U.owned(id) then n=n+1 end end
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID())) do local d=UnitDefs[Spring.GetUnitDefID(id)]; if d and d.isFactory then for _,q in ipairs(Spring.GetFactoryCommands(id,-1) or {}) do if q.id and q.id<0 then local b=C.classify.definition(-q.id); if b.mobile and b.builder then n=n+1 end end end end end
		local economy=C.observations.economy(); local income=economy and economy.metal.income or 0
		local goal=C.openingPlan and (military<3 and 1 or math.min(10,2+math.floor(income/15))) or (military<5 and 1 or math.min(8,2+math.floor(income/20)))
		return math.max(0,goal-n)
	end
	local function site(id,def,origin,anchor,bridge)
		if not can(id,def) then return end
		for _,r in ipairs({0,64,96,128,160,256,384,544,768,1024}) do for j=0,15 do
			local x,z=origin[1]+r*math.cos(j*math.pi/8),origin[3]+r*math.sin(j*math.pi/8)
			if x>80 and z>80 and x<Game.mapSizeX-80 and z<Game.mapSizeZ-80 then local y=Spring.GetGroundHeight(x,z)
				local pos={x,y,z}; local radius=tonumber((UnitDefs[def].customParams or {}).pylonrange) or 0
				local connected=not anchor or C.U.distance(pos,anchor.p)<=anchor.radius+radius-16
				if bridge then connected=connected and C.U.distance(pos,bridge.target.p)<C.U.distance(bridge.anchor.p,bridge.target.p)-64 end
				if connected and Spring.GetPositionLosState(x,y,z) and not C.observations.nearCombat(pos,700) then local ok,feature=Spring.TestBuildOrder(def,x,y,z,0); if ok and ok>0 and not feature then return {x,y,z,0} end end
			end
		end end
	end
	function E.update()
		if not E.enabled then return end
		if not C.U.delegationAllowed(C.settings) then E.stop(); return end
		local now=C.U.now(); if now-E.last<2 then return end; E.last=now
		local budget=C.militaryBudget and C.militaryBudget.update(); local catchup=budget and budget.active
		local function optional(def)
			local name=UnitDefs[def] and UnitDefs[def].name
			return name=='staticstorage' or name=='energypylon' or name=='energyfusion'
		end
		local own=Spring.GetTeamUnits(Spring.GetMyTeamID()); local structures,unfinished,factories,mexes={}, {},{},{}
		for _,id in ipairs(own) do if C.U.owned(id) then local def=Spring.GetUnitDefID(id); local d=UnitDefs[def]; local _,_,_,_,built=Spring.GetUnitHealth(id); local cp=d.customParams or {}
			if d.isFactory then factories[#factories+1]=id end
			if tonumber(cp.metal_extractor_mult) then mexes[#mexes+1]=C.U.position(id) end
			if (d.isBuilding or d.isFactory or (d.speed or 0)==0) then structures[#structures+1]=id; if built and built<1 then unfinished[#unfinished+1]=id end end
			local v=C.classify.definition(def)
			if v.mobile and v.builder and built==1 and not E.excluded[id] and not (C.recovery and C.recovery.workers[id]) and not E.workers[id] and #(Spring.GetCommandQueue(id,1) or {})==0 then E.workers[id]=true end
		end end
		local available,occupied={},{}
		for id in pairs(E.workers) do if not C.U.owned(id) then E.workers[id]=nil; E.tasks[id]=nil elseif not (C.nativeQueue and C.nativeQueue.paused(E,id)) then
			local q=(Spring.GetCommandQueue(id,1) or {})[1]; local task=E.tasks[id]; local p=C.U.position(id)
			if C.nativeQueue and task then q=C.nativeQueue.current(id,task) or q end
			if task and q and not matches(q,task) then local queue=Spring.GetCommandQueue(id,3) or {}; local detail='Worker '..id..': task '..task.cmd..' ['..table.concat(task.params,',')..']'; for _,item in ipairs(queue) do detail=detail..' queue '..item.id..' ['..table.concat(item.params or {},',')..'] internal='..tostring(item.options and item.options.internal)..' coded='..tostring(item.options and item.options.coded) end; C.debug.log('ECONOMY OVERRIDE',detail..'; manual control preserved'); E.release(id); task=nil end
			if catchup and task and task.cmd<0 and optional(-task.cmd) and matches(q,task) and q.tag then
				local stock=C.observations.economy()
				if stock and (stock.energy.income or 0)>=(stock.metal.income or 0)*1.05 and stock.energy.current>=150 then
					task.removeTag=q.tag
					if C.orders.service('economy',id,CMD.REMOVE,{q.tag}) then E.retry[task.key]=now+30; E.tasks[id]=nil; task=nil; q=nil; E.cooldown[id]=now+2; C.debug.log('MILITARY BUDGET','Paused an owned optional construction order; foundation retained for later completion.') end
				end
			end
			if task and q then
				local value=0; for _,u in ipairs(unfinished) do if task.cmd<0 and Spring.GetUnitDefID(u)==-task.cmd and C.U.distance(C.U.position(u),task.params)<64 then value=Spring.GetUnitHealth(u) or 0; break end end
				if task.cmd==CMD.REPAIR and C.U.owned(task.params[1]) then value=Spring.GetUnitHealth(task.params[1]) or 0 end
				if not task.position or C.U.distance(task.position,p)>24 or math.abs(value-(task.value or 0))>1 then task.position=p; task.value=value; task.progress=now end
				local stock=C.observations.economy(); local starved=task.cmd<0 and stock and (stock.metal.current<20 or stock.energy.current<30)
				local smallPower=task.cmd<0 and UnitDefs[-task.cmd] and (UnitDefs[-task.cmd].name=='energysolar' or UnitDefs[-task.cmd].name=='energywind')
				local emergency=stock and stock.energy.current<30 and (stock.energy.income or 0)<(stock.metal.income or 0) and now-task.time>15 and now>=(E.emergencyUntil or 0) and not smallPower and (named('energysolar') and can(id,named('energysolar')) or named('energywind') and can(id,named('energywind')))
				if (now-task.progress>35 and not starved) or emergency then
					if matches(q,task) and q.tag then
						task.removeTag=q.tag
						if C.orders.service('economy',id,CMD.REMOVE,{q.tag}) then E.retry[task.key]=now+120; E.cooldown[id]=now+(emergency and 2 or 20); if emergency then E.emergencyUntil=now+30 end; E.tasks[id]=nil; task=nil; q=nil; C.debug.log(emergency and 'ECONOMY ENERGY' or 'ECONOMY RETRY',emergency and ('Worker '..id..' redirected from its tracked project to restore critically low energy') or ('Worker '..id..' stalled; removed only its tracked order, then try another site after cooldown')) end
					else E.release(id); C.debug.log('ECONOMY STALLED','Unrecognized queue; released for manual control') end
				end
			end
			if E.workers[id] and p and C.observations.nearCombat(p,600) and (not task or now-task.time>10) then
				local danger; for _,c in ipairs(C.observations.snapshot().contacts) do if C.U.distance(p,c.position)<600 then danger=c.position; break end end
				if danger then if task then E.retry[task.key]=now+90 end; local dx,dz=p[1]-danger[1],p[3]-danger[3]; local length=math.max(1,math.sqrt(dx*dx+dz*dz)); local x=math.max(32,math.min(Game.mapSizeX-32,p[1]+dx/length*600)); local z=math.max(32,math.min(Game.mapSizeZ-32,p[3]+dz/length*600)); issue(id,Spring.Utilities.CMD.RAW_MOVE,{x,Spring.GetGroundHeight(x,z),z},'withdraw builder'); q=true end
			end
			if E.workers[id] then if not q then if task then E.retry[task.key]=now+10 end; E.tasks[id]=nil; if now>=(E.cooldown[id] or 0) then available[#available+1]=id end elseif E.tasks[id] then occupied[E.tasks[id].key]=true end end
		end end
		table.sort(available)
		local resources=C.observations.economy(); if not resources then return end
		local state=C.economyPlan and C.economyPlan.snapshot(own)
		local metal=resources.metal.current; local energy=resources.energy.current; local mi=resources.metal.income or 0; local ei=resources.energy.income or 0; local plannedEi=ei+(state and state.pendingPower or 0)
		for _,id in ipairs(available) do local p=C.U.position(id); local job
			for _,u in ipairs(unfinished) do local key='finish:'..u; local pos=C.U.position(u); local name=UnitDefs[Spring.GetUnitDefID(u)].name; local energyEmergency=energy<150 and ei<mi*1.05 and name~='energysolar' and name~='energywind'; if not (catchup and optional(Spring.GetUnitDefID(u))) and not energyEmergency and not occupied[key] and C.U.distance(p,pos)<1400 and not C.observations.nearCombat(pos,700) then job={cmd=CMD.REPAIR,p={u},key=key}; break end end
			local function build(name,key,origin,anchor,bridge)
				local def=named(name); if not def or occupied[key] or now<(E.retry[key] or 0) or metal<50 then return end
				if state and state.pending[name] and (name=='energyfusion' or name=='energypylon' or name=='staticstorage') then return end
				local pos=site(id,def,origin or p,anchor,bridge); if pos then return {cmd=-def,p=pos,key=key} end
			end
			if not job and #factories==0 then
				local factory=E.opening~='AUTO' and E.opening or Spring.GetGroundHeight(p[1],p[3])<-10 and 'factoryship' or 'factorycloak'
				if E.opening=='AUTO' and C.openingPlan then
					for _,candidate in ipairs(C.openingPlan.factories(id)) do job=build(candidate.name,'initial factory '..candidate.name); if job then job.reason=candidate.reason; break end end
				else job=build(factory,'initial factory '..factory) end
			end
			local function power(urgent)
				local anchor=state and C.economyPlan.energyAnchor(state,p); local origin=anchor and anchor.p or p
				local name=Spring.GetGroundHeight(origin[1],origin[3])<-5 and 'energywind' or 'energysolar'
				local fallback=name
				if not catchup and (not urgent or energy>200) and mi>=25 and metal>=200 and named('energyfusion') and ei<mi+math.min(160,#mexes*6)-20 then name='energyfusion' end
				local key='energy '..name..' near '..math.floor(origin[1]/600)..':'..math.floor(origin[3]/600)
				local smallKey='energy '..fallback..' near '..math.floor(origin[1]/600)..':'..math.floor(origin[3]/600)
				return build(name,key,origin,anchor) or build(name,key) or (name~=fallback and (build(fallback,smallKey,origin,anchor) or build(fallback,smallKey)))
			end
			if not job and #factories>0 and (#mexes>=2 or energy<150 or ei<mi*.8) and (plannedEi<mi*1.05+#factories*2 or energy<150) then job=power(true) end
			if not job and C.structurePlanning and #factories>0 then
				local candidate=C.structurePlanning.choose(id,own,resources,catchup,now)
				if candidate then job=build(candidate.name,candidate.key,candidate.origin); if job then job.structure=candidate end end
			end
			if not job and not catchup and state and C.economyPlan.storageNeeded(state,resources) then job=build('staticstorage','storage buffer') end
			local function invest()
				local upgrade
				if #factories>0 and ((catchup and budget.capacityNeeded) or (not catchup and metal>math.min(400,(resources.metal.storage or 1000)*.6) and mi>(state and state.factoryPower*.9 or #factories*18) and ei>mi)) then
					if C.economyPlan then for _,candidate in ipairs(C.economyPlan.factories(id,factories,resources)) do if candidate.preferred then upgrade=build(candidate.name,'additional factory '..#factories); if upgrade then upgrade.reason=candidate.reason; break end end end end
					if not upgrade then upgrade=build(UnitDefs[Spring.GetUnitDefID(factories[1])].name,'additional factory '..#factories) end
				end
				if not catchup and not upgrade and state and metal>=200 and ei>mi*1.1 and not state.pending.energypylon then
					local bridge=C.economyPlan.bridge(state,p); if bridge then upgrade=build('energypylon','grid bridge',bridge.p,bridge.anchor,bridge) end
				end
				if not catchup and not upgrade and #factories>0 and #mexes>=2 and metal>=100 and plannedEi<mi+math.min(160,#mexes*6) then upgrade=power(false) end
				return upgrade
			end
			local force=C.startup and C.registry.forces[C.startup.forceID]; local expansionFirst=force and force.objectiveMode=='WIN THE GAME'
			if not job and ((expansionFirst and E.jobCount%(C.openingPlan and 6 or 4)==(C.openingPlan and 5 or 3) or not expansionFirst and E.jobCount%3==2) or catchup and budget.capacityNeeded) then job=invest() end
			if not job and #factories>0 and metal>(catchup and math.max(65,mi*6)+125 or 40) then
				local def=named('staticmex'); local best,score
				if def and can(id,def) then for i,spot in ipairs(WG.metalSpots or {}) do local pos={spot.x,spot.y,spot.z}; local key='mex:'..i; local used=false
					for _,m in ipairs(mexes) do if C.U.distance(m,pos)<80 then used=true; break end end
					local distance=C.U.distance(p,pos)
					if not used and not occupied[key] and now>=(E.retry[key] or 0) and not C.observations.nearCombat(pos,900) and (not score or distance<score) and (not C.economyPlan or C.economyPlan.safeRoute(p,pos)) then best={pos=pos,key=key}; score=distance end
				end end
				if best then
					if not Spring.GetPositionLosState(best.pos[1],best.pos[2],best.pos[3]) then local distance=C.U.distance(p,best.pos); local t=math.min(1,650/math.max(1,distance)); local x,z=p[1]+(best.pos[1]-p[1])*t,p[3]+(best.pos[3]-p[3])*t
						job={cmd=Spring.Utilities.CMD.RAW_MOVE,p={x,Spring.GetGroundHeight(x,z),z},key=best.key}
					else local ok,feature=Spring.TestBuildOrder(def,best.pos[1],best.pos[2],best.pos[3],0); if ok and ok>0 and not feature then job={cmd=-def,p={best.pos[1],best.pos[2],best.pos[3],0},key=best.key} else E.retry[best.key]=now+30 end end
				end
			end
			if not job then job=invest() end
			if job then if issue(id,job.cmd,job.p,job.key) then E.jobCount=E.jobCount+1; if job.structure then C.structurePlanning.issued(job.structure,now) end; if job.reason then C.debug.log('FACTORY PLAN',job.reason) end; occupied[job.key]=true; if job.cmd<0 then metal=metal-math.min(metal,math.min(UnitDefs[-job.cmd].metalCost or 0,math.max(100,mi*6))) end end end
		end
	end
	return E
end
