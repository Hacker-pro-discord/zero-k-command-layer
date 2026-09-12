-- Local economic authority, separate from combat and recovery assignments.
return function(C)
	local E={enabled=false,workers={},excluded={},tasks={},retry={},last=-100,status='Economy OFF',opening='AUTO'}
	local function can(id,def) local d=UnitDefs[Spring.GetUnitDefID(id)]; for _,v in ipairs(d and d.buildOptions or {}) do if v==def then return true end end end
	local function named(name) return UnitDefNames and UnitDefNames[name] and UnitDefNames[name].id end
	function E.release(id) E.workers[id]=nil; E.tasks[id]=nil; E.excluded[id]=true end
	function E.stop() E.enabled=false; E.workers={}; E.tasks={}; E.status='Economy OFF; native queues preserved' end
	function E.start() if C.U.delegationAllowed(C.settings) then E.enabled=true; return true end; return false end
	function E.setFactory(name) if name=='AUTO' or named(name) and UnitDefs[named(name)].isFactory then E.opening=name; return true end; return false end
	function E.enroll(ids)
		if not C.U.delegationAllowed(C.settings) then return false end
		for _,id in ipairs(ids) do local v=C.classify.definition(Spring.GetUnitDefID(id)); if C.U.owned(id) and v.mobile and v.builder then if C.recovery then C.recovery.release(id) end; C.registry.release({id},'ECONOMY'); E.workers[id]=true; E.excluded[id]=nil end end
		return E.start()
	end
	function E.valid(id,cmd,p)
		local t=E.tasks[id]
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
		local goal=military<5 and 1 or math.min(8,2+math.floor(income/20))
		return math.max(0,goal-n)
	end
	local function site(id,def,origin)
		if not can(id,def) then return end
		for _,r in ipairs({160,256,384,544,768,1024}) do for j=0,15 do
			local x,z=origin[1]+r*math.cos(j*math.pi/8),origin[3]+r*math.sin(j*math.pi/8)
			if x>80 and z>80 and x<Game.mapSizeX-80 and z<Game.mapSizeZ-80 then local y=Spring.GetGroundHeight(x,z)
				if Spring.GetPositionLosState(x,y,z) and not C.observations.nearCombat({x,y,z},700) then local ok,feature=Spring.TestBuildOrder(def,x,y,z,0); if ok and ok>0 and not feature then return {x,y,z,0} end end
			end
		end end
	end
	function E.update()
		if not E.enabled then return end
		if not C.U.delegationAllowed(C.settings) then E.stop(); return end
		local now=C.U.now(); if now-E.last<2 then return end; E.last=now
		local own=Spring.GetTeamUnits(Spring.GetMyTeamID()); local structures,unfinished,factories,mexes={}, {},{},{}
		for _,id in ipairs(own) do if C.U.owned(id) then local def=Spring.GetUnitDefID(id); local d=UnitDefs[def]; local _,_,_,_,built=Spring.GetUnitHealth(id); local cp=d.customParams or {}
			if d.isFactory then factories[#factories+1]=id end
			if tonumber(cp.metal_extractor_mult) then mexes[#mexes+1]=C.U.position(id) end
			if (d.isBuilding or d.isFactory or (d.speed or 0)==0) then structures[#structures+1]=id; if built and built<1 then unfinished[#unfinished+1]=id end end
			local v=C.classify.definition(def)
			if v.mobile and v.builder and built==1 and not E.excluded[id] and not (C.recovery and C.recovery.workers[id]) and not E.workers[id] and #(Spring.GetCommandQueue(id,1) or {})==0 then E.workers[id]=true end
		end end
		local available,occupied={},{}
		for id in pairs(E.workers) do if not C.U.owned(id) then E.workers[id]=nil; E.tasks[id]=nil else
			local q=(Spring.GetCommandQueue(id,1) or {})[1]; local task=E.tasks[id]; local p=C.U.position(id)
			if task and q then
				local value=0; for _,u in ipairs(unfinished) do if task.cmd<0 and Spring.GetUnitDefID(u)==-task.cmd and C.U.distance(C.U.position(u),task.params)<64 then value=Spring.GetUnitHealth(u) or 0; break end end
				if task.cmd==CMD.REPAIR and C.U.owned(task.params[1]) then value=Spring.GetUnitHealth(task.params[1]) or 0 end
				if not task.position or C.U.distance(task.position,p)>24 or math.abs(value-(task.value or 0))>1 then task.position=p; task.value=value; task.progress=now end
				if now-task.progress>35 then E.retry[task.key]=now+45; E.release(id); C.debug.log('ECONOMY STALLED','Worker '..id..' released; native queue preserved') end
			end
			if E.workers[id] and p and C.observations.nearCombat(p,600) and (not task or now-task.time>10) then
				local danger; for _,c in ipairs(C.observations.snapshot().contacts) do if C.U.distance(p,c.position)<600 then danger=c.position; break end end
				if danger then if task then E.retry[task.key]=now+90 end; local dx,dz=p[1]-danger[1],p[3]-danger[3]; local length=math.max(1,math.sqrt(dx*dx+dz*dz)); local x=math.max(32,math.min(Game.mapSizeX-32,p[1]+dx/length*600)); local z=math.max(32,math.min(Game.mapSizeZ-32,p[3]+dz/length*600)); issue(id,Spring.Utilities.CMD.RAW_MOVE,{x,Spring.GetGroundHeight(x,z),z},'withdraw builder'); q=true end
			end
			if E.workers[id] then if not q then if task then E.retry[task.key]=now+10 end; E.tasks[id]=nil; available[#available+1]=id elseif E.tasks[id] then occupied[E.tasks[id].key]=true end end
		end end
		table.sort(available)
		local resources=C.observations.economy(); if not resources then return end
		local metal=resources.metal.current; local energy=resources.energy.current; local mi=resources.metal.income or 0; local ei=resources.energy.income or 0
		for _,id in ipairs(available) do local p=C.U.position(id); local job
			for _,u in ipairs(unfinished) do local key='finish:'..u; local pos=C.U.position(u); if not occupied[key] and C.U.distance(p,pos)<1400 and not C.observations.nearCombat(pos,700) then job={cmd=CMD.REPAIR,p={u},key=key}; break end end
			local function build(name,key)
				local def=named(name); if not def or occupied[key] or now<(E.retry[key] or 0) or metal<50 then return end
				local pos=site(id,def,p); if pos then return {cmd=-def,p=pos,key=key} end
			end
			if not job and #factories==0 then
				local factory=E.opening~='AUTO' and E.opening or Spring.GetGroundHeight(p[1],p[3])<-10 and 'factoryship' or 'factorycloak'
				job=build(factory,'initial factory '..factory)
			end
			if not job and #factories>0 and (#mexes>=2 or energy<150 or ei<mi*.8) and (ei<mi*1.3+#factories*3 or energy<150) then
				job=build(Spring.GetGroundHeight(p[1],p[3])<-5 and 'energywind' or 'energysolar','energy near '..math.floor(p[1]/600)..':'..math.floor(p[3]/600))
			end
			if not job and #factories>0 and metal>math.min(400,(resources.metal.storage or 1000)*.6) and mi>#factories*18 and ei>mi then
				local first=UnitDefs[Spring.GetUnitDefID(factories[1])].name; job=build(first,'additional factory '..#factories)
			end
			if not job and #factories>0 and metal>40 then
				local def=named('staticmex'); local best,score
				if def and can(id,def) then for i,spot in ipairs(WG.metalSpots or {}) do local pos={spot.x,spot.y,spot.z}; local key='mex:'..i; local used=false
					for _,m in ipairs(mexes) do if C.U.distance(m,pos)<80 then used=true; break end end
					local distance=C.U.distance(p,pos)
					if not used and not occupied[key] and now>=(E.retry[key] or 0) and not C.observations.nearCombat(pos,900) and (not score or distance<score) then best={pos=pos,key=key}; score=distance end
				end end
				if best then
					if not Spring.GetPositionLosState(best.pos[1],best.pos[2],best.pos[3]) then job={cmd=Spring.Utilities.CMD.RAW_MOVE,p=best.pos,key=best.key}
					else local ok,feature=Spring.TestBuildOrder(def,best.pos[1],best.pos[2],best.pos[3],0); if ok and ok>0 and not feature then job={cmd=-def,p={best.pos[1],best.pos[2],best.pos[3],0},key=best.key} else E.retry[best.key]=now+30 end end
				end
			end
			if job then if issue(id,job.cmd,job.p,job.key) then occupied[job.key]=true; if job.cmd<0 then metal=metal-math.min(metal,(UnitDefs[-job.cmd].metalCost or 0)) end end end
		end
	end
	return E
end
