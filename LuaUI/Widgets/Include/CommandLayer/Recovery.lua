-- Explicit builder service; owns only enrolled workers and its own native orders.
return function(C)
	local R={enabled=false,workers={},excluded={},assets={},ignored={},missing={},sites={},requests={},tasks={},retry={},cooldown={},last=-100,status='Recovery idle'}
	local function matches(q,t)
		if not q or not t or q.id~=t.cmd or not q.params then return false end
		if t.cmd==CMD.REPAIR or t.cmd==CMD.RECLAIM then return q.params[1]==t.params[1] end
		return #q.params>=3 and C.U.distance(q.params,t.params)<16
	end
	function R.workerDefinition(def)
		local v=C.classify.definition(def); local raw=UnitDefs[def]
		return raw and v.mobile and v.builder and #(raw.buildOptions or {})>0 and v.cost<800
	end
	local function infrastructure(def)
		local cp=def.customParams or {}; local icon=(def.iconType or ''):lower()
		return def.isFactory or tonumber(cp.metal_extractor_mult) or (def.energyMake or 0)>0 or icon:find('^energy')
	end
	local function key(def,p) return def..':'..math.floor(p[1])..':'..math.floor(p[3]) end
	local function delay(job,untilTime)
		R.retry[job]=untilTime
		-- A survey and its eventual build share failure suppression.
		R.retry[job:gsub('^survey:','')]=untilTime
	end
	local function routeClear(a,b)
		if not a or not b then return false end
		local steps=math.max(1,math.ceil(C.U.distance(a,b)/320))
		for i=0,steps do local t=i/steps; local x,z=a[1]+(b[1]-a[1])*t,a[3]+(b[3]-a[3])*t
			if C.observations.nearCombat({x,Spring.GetGroundHeight(x,z),z},700) then return false end
		end
		return true
	end
	local function survey(id,p,k)
		if C.U.now()<(R.retry[k] or 0) then return end
		local from=C.U.position(id); local distance=C.U.distance(from,p); local fraction=math.min(1,500/math.max(1,distance))
		local x,z=from[1]+(p[1]-from[1])*fraction,from[3]+(p[3]-from[3])*fraction
		return {cmd=Spring.Utilities.CMD.RAW_MOVE,params={x,Spring.GetGroundHeight(x,z),z},key=k}
	end
	local function canBuild(id,def)
		local d=UnitDefs[Spring.GetUnitDefID(id)]; for _,bid in ipairs(d and d.buildOptions or {}) do if bid==def then return true end end; return false
	end
	function R.enroll(ids,automatic)
		if not C.U.delegationAllowed(C.settings) then return false end
		local n=0
		for _,id in ipairs(ids or Spring.GetSelectedUnits()) do local v=C.classify.definition(Spring.GetUnitDefID(id))
			if C.U.owned(id) and v.mobile and v.builder and (not automatic or not R.excluded[id]) then
				if C.economy then C.economy.release(id) end; C.registry.release({id},'RECOVERY ASSIGNMENT'); R.excluded[id]=nil; R.workers[id]=true; n=n+1
			end
		end
		if n>0 then R.enabled=true; R.status='Enrolled '..n..' builders; existing queues preserved' end; return n>0
	end
	function R.release(id) if R.workers[id] then R.workers[id]=nil; R.tasks[id]=nil end; R.cooldown[id]=nil; R.excluded[id]=true end
	function R.stop() R.enabled=false; R.workers={}; R.tasks={}; R.status='Recovery stopped; native queues preserved' end
	function R.start() if C.U.delegationAllowed(C.settings) then R.enabled=true end end
	function R.threat(p)
		if not R.enabled then return end
		local now=C.U.now()
		for _,site in ipairs(R.sites) do if C.U.distance(site.point,p)<900 then site.lastThreat=now; site.finished=nil; return site end end
		local site={point=C.U.copy(p),lastThreat=now,created=now}; R.sites[#R.sites+1]=site; return site
	end
	function R.destroyed(id)
		if R.tasks[id] then delay(R.tasks[id].key,C.U.now()+90) end
		local asset=R.assets[id]; R.assets[id]=nil; R.workers[id]=nil; R.tasks[id]=nil; R.ignored[id]=nil
		if R.enabled and asset and C.U.delegationAllowed(C.settings) then R.missing[key(asset.def,asset.point)]=asset; R.threat(asset.point) end
	end
	function R.forget(id) R.assets[id]=nil; R.ignored[id]=true end -- explicit player dismantling
	function R.request(def,p,facing,builders)
		if not C.U.delegationAllowed(C.settings) or not UnitDefs[def] or not C.U.point(p) or #R.requests>=64 then return false end
		if builders then R.enroll(builders) end
		local capable=false; for id in pairs(R.workers) do if C.U.owned(id) and canBuild(id,def) then capable=true end end
		if not capable then R.status='No enrolled builder can construct that definition'; return false end
		R.enabled=true; R.sites[#R.sites+1]={point=C.U.copy(p),lastThreat=C.U.now()-30,created=C.U.now()}; R.requests[#R.requests+1]={def=def,point=C.U.copy(p),facing=facing or 0,manual=true}; R.status='Construction request added; native placement and resources still apply'; return true
	end
	function R.cancelRequests() R.requests={}; R.missing={}; R.sites={}; R.status='Pending reconstruction and build requests cancelled; existing native orders preserved' end
	function R.workerNeed()
		if not R.enabled or not C.U.delegationAllowed(C.settings) then return 0 end
		local count,military=0,0
		for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do if C.U.owned(id) then
			local def=UnitDefs[Spring.GetUnitDefID(id)]; local v=C.classify.definition(Spring.GetUnitDefID(id))
			if R.workers[id] or R.workerDefinition(Spring.GetUnitDefID(id)) and not R.excluded[id] and #(Spring.GetCommandQueue(id,1) or {})==0 then count=count+1 end
			if v.mobile and not v.builder then military=military+1 end
			if def.isFactory and Spring.GetFactoryCommands then for _,q in ipairs(Spring.GetFactoryCommands(id,-1) or {}) do if q.id and q.id<0 and R.workerDefinition(-q.id) then count=count+1 end end end
		end end
		local goal=military>=20 and 2 or military>=5 and 1 or 0
		return math.max(0,goal-count)
	end
	function R.valid(id,cmd,params)
		local t=R.tasks[id]; local v=C.classify.definition(Spring.GetUnitDefID(id)); local _,_,_,_,built=Spring.GetUnitHealth(id)
		if cmd==CMD.REMOVE then
			local q=(Spring.GetCommandQueue(id,1) or {})[1]
			return R.enabled and C.U.delegationAllowed(C.settings) and R.workers[id] and not R.excluded[id] and C.U.owned(id) and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1 and #params==1 and t and t.removeTag and params[1]==t.removeTag and q and q.tag==t.removeTag and matches(q,t)
		end
		if not v.mobile or not v.builder or built and built<1 then return false end
		if not R.enabled or not C.U.delegationAllowed(C.settings) or not R.workers[id] or R.excluded[id] or not C.U.owned(id) or Spring.GetUnitTransporter(id) or Spring.GetUnitRulesParam(id,'retreat')==1 or not t or t.cmd~=cmd or #t.params~=#params then return false end
		for i,v in ipairs(params) do if t.params[i]~=v then return false end end
		if cmd<0 then return canBuild(id,-cmd) end
		return cmd==CMD.REPAIR or cmd==CMD.RECLAIM or cmd==Spring.Utilities.CMD.RAW_MOVE
	end
	local function issue(id,cmd,params,job)
		R.tasks[id]={cmd=cmd,params=C.U.copy(params),key=job,time=C.U.now()}
		local ok=C.orders.service('recovery',id,cmd,params)
		if not ok then R.tasks[id]=nil else C.debug.log('RECOVERY WORK','Builder '..id..': '..job) end; return ok
	end
	local function funding(def,economy)
		local cost=(UnitDefs[def] or {}).metalCost or 0; local m=economy and economy.metal
		if m and (m.income or 0)>0 then return math.min(cost,math.max(100,m.income*8),math.max(50,(m.storage or cost*2)*.4)) end
		return cost
	end
	function R.reserveMetal()
		if not R.enabled or not next(R.workers) then return 0 end
		local need=0; local economy=C.observations.economy()
		local function consider(job)
			if Spring.GetPositionLosState(job.point[1],job.point[2],job.point[3]) and not C.observations.nearCombat(job.point,900) then
				for id in pairs(R.workers) do if C.U.owned(id) and canBuild(id,job.def) then need=math.max(need,funding(job.def,economy)); break end end
			end
		end
		for _,job in ipairs(R.requests) do consider(job) end; for _,job in pairs(R.missing) do consider(job) end
		return need
	end
	function R.hold(p,now)
		if not R.enabled then return false end
		for _,site in ipairs(R.sites) do if not site.finished and C.U.distance(site.point,p)<900 then
			-- Release the combat escort independently of pending civil work.
			if now-site.lastThreat>45 then return false end
			return true
		end end
		return false
	end
	function R.update()
		if not R.enabled then return end
		if not C.U.delegationAllowed(C.settings) then R.stop(); R.assets={}; R.missing={}; R.sites={}; return end
		local now=C.U.now(); if now-R.last<2 then return end; R.last=now
		local own=Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}; local military=0; for _,u in ipairs(own) do local v=C.classify.definition(Spring.GetUnitDefID(u)); if v.mobile and not v.builder then military=military+1 end end; local autoGoal=C.economy and C.economy.enabled and (military>=20 and 2 or military>=5 and 1 or 0) or 2; local present={}; local damaged={}; local workerCount=0; for id in pairs(R.workers) do if C.U.owned(id) then workerCount=workerCount+1 end end
		for _,id in ipairs(own) do if C.U.owned(id) then
			local defID=Spring.GetUnitDefID(id); local def=UnitDefs[defID]; local p=C.U.position(id); local h,m,_,_,built=Spring.GetUnitHealth(id)
			if p and infrastructure(def) and not R.ignored[id] then
				local record={def=defID,point=p,facing=Spring.GetUnitBuildFacing and Spring.GetUnitBuildFacing(id) or 0}
				R.assets[id]=record; present[key(defID,p)]=id
				if h and m and (h<m*.95 or built and built<1) then damaged[#damaged+1]={id=id,point=p} end
			end
			if workerCount<autoGoal and R.workerDefinition(defID) and not R.workers[id] and not R.excluded[id] and (not built or built>=1) and #(Spring.GetCommandQueue(id,1) or {})==0 then if R.enroll({id},true) then workerCount=workerCount+1 end end
		end end
		-- Native build snapping may differ by a few game units from a clicked point.
		local function exists(job)
			if present[key(job.def,job.point)] then return present[key(job.def,job.point)] end
			for _,id in ipairs(own) do if C.U.owned(id) and Spring.GetUnitDefID(id)==job.def and C.U.distance(C.U.position(id),job.point)<48 then return id end end
		end
		for k,job in pairs(R.missing) do if exists(job) then R.missing[k]=nil end end
		for i=#R.requests,1,-1 do local id=exists(R.requests[i]); if id then local _,_,_,_,built=Spring.GetUnitHealth(id); if not built or built>=1 then table.remove(R.requests,i) else R.requests[i].target=id end end end
		local occupied={}; local available={}
		for id in pairs(R.workers) do
			if not C.U.owned(id) then R.workers[id]=nil; R.tasks[id]=nil else
				local q=Spring.GetCommandQueue(id,1) or {}; local task=R.tasks[id]
				local position=C.U.position(id)
				local external=#q>0 and (not task or not matches(q[1],task))
				if external and task then R.release(id); task=nil end
				if not external and position and C.observations.nearCombat(position,600) and (not task or task.cmd~=Spring.Utilities.CMD.RAW_MOVE or now-task.time>=10) then
					local danger,nearest
					for _,contact in ipairs(C.observations.snapshot().contacts) do local distance=C.U.distance(position,contact.position); if distance<700 and (not nearest or distance<nearest) then danger=contact.position; nearest=distance end end
					if danger then
						local dx,dz=position[1]-danger[1],position[3]-danger[3]; local length=math.sqrt(dx*dx+dz*dz); if length<1 then dx=1; dz=0; length=1 end
						local x=math.max(16,math.min(Game.mapSizeX-16,position[1]+dx/length*500)); local z=math.max(16,math.min(Game.mapSizeZ-16,position[3]+dz/length*500))
						if task then delay(task.key,now+60) end
						issue(id,Spring.Utilities.CMD.RAW_MOVE,{x,Spring.GetGroundHeight(x,z),z},'builder withdrawal'); task=R.tasks[id]; q=Spring.GetCommandQueue(id,1) or {}
					end
				end
				local stalled=false
				if task and #q>0 then
					local metric=0
					if task.cmd==CMD.REPAIR and C.U.owned(task.params[1]) then metric=Spring.GetUnitHealth(task.params[1]) or 0
					elseif task.cmd==CMD.RECLAIM and Spring.GetFeatureResources then local fid=task.params[1]-Game.maxUnits; local x,y,z=Spring.GetFeaturePosition(fid); if x and Spring.GetPositionLosState(x,y,z) then metric=Spring.GetFeatureResources(fid) or 0 end
					elseif task.cmd<0 then for _,other in ipairs(own) do if C.U.owned(other) and Spring.GetUnitDefID(other)==-task.cmd and C.U.distance(C.U.position(other),task.params)<48 then metric=Spring.GetUnitHealth(other) or 0; break end end end
					local goal=(task.cmd<0 or task.cmd==Spring.Utilities.CMD.RAW_MOVE) and task.params or nil; if task.cmd==CMD.REPAIR and C.U.owned(task.params[1]) then goal=C.U.position(task.params[1]) end
					local distance=goal and C.U.distance(position,goal) or nil
					if not task.position or (distance and distance<(task.distance or math.huge)-16) or not distance and C.U.distance(task.position,position)>16 or math.abs(metric-(task.metric or 0))>.1 then task.position=C.U.copy(position); task.distance=distance; task.metric=metric; task.progress=now end
					local stock=C.observations.economy(); local starved=(task.cmd<0 or task.cmd==CMD.REPAIR) and stock and (stock.metal.current<20 or stock.energy.current<30)
					if now-(task.progress or task.time)>35 and not starved and matches(q[1],task) and q[1].tag then
						task.removeTag=q[1].tag
						if C.orders.service('recovery',id,CMD.REMOVE,{task.removeTag}) then stalled=true; delay(task.key,now+45); R.cooldown[id]=now+10; R.tasks[id]=nil; C.debug.log('RECOVERY RETRY','Removed only stalled tracked order for builder '..id..'; worker retained for another job.') end
					end
				end
				if not external and not stalled and now>=(R.cooldown[id] or 0) and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1 then
					if #q==0 then if task then R.retry[task.key]=now+10; R.tasks[id]=nil end; available[#available+1]=id
					elseif task then occupied[task.key]=true end
				end
			end
		end
		table.sort(available)
		local economy=C.observations.economy(); local budget=economy and economy.metal.current or 0
		local jobs={}; for _,job in ipairs(R.requests) do jobs[#jobs+1]=job end; for _,job in pairs(R.missing) do jobs[#jobs+1]=job end
		local function buildSite(p) for _,job in ipairs(jobs) do if C.U.distance(p,job.point)<1000 then return true end end end
		for _,id in ipairs(available) do
			local selected
			table.sort(jobs,function(a,b) return C.U.distance(C.U.position(id),a.point)<C.U.distance(C.U.position(id),b.point) end)
			-- Repairs before rebuilding; only own targets in a cleared incident area.
			for _,asset in ipairs(damaged) do for _,site in ipairs(R.sites) do
				local k='repair:'..asset.id
				if not site.finished and now-site.lastThreat>=20 and C.U.distance(site.point,asset.point)<1000 and not C.observations.nearCombat(asset.point,700) and not occupied[k] and now>=(R.retry[k] or 0) and routeClear(C.U.position(id),asset.point) then selected={cmd=CMD.REPAIR,params={asset.id},key=k}; break end
			end; if selected then break end end
			if not selected then for _,job in ipairs(jobs) do
				local k='build:'..key(job.def,job.point); local clear=not C.observations.nearCombat(job.point,900)
				for _,site in ipairs(R.sites) do if C.U.distance(site.point,job.point)<1000 and now-site.lastThreat<20 then clear=false end end
				if clear and canBuild(id,job.def) and not occupied[k] and now>=(R.retry[k] or 0) and routeClear(C.U.position(id),job.point) then
					if job.target and C.U.owned(job.target) then selected={cmd=CMD.REPAIR,params={job.target},key=k}
					elseif not Spring.GetPositionLosState(job.point[1],job.point[2],job.point[3]) then selected=survey(id,job.point,'survey:'..k)
					elseif Spring.TestBuildOrder then
						local allowed,feature=Spring.TestBuildOrder(job.def,job.point[1],job.point[2],job.point[3],job.facing)
						if feature then local x,y,z=Spring.GetFeaturePosition(feature); local fk='wreck:'..feature; if x and Spring.GetPositionLosState(x,y,z) and not occupied[fk] and now>=(R.retry[fk] or 0) then selected={cmd=CMD.RECLAIM,params={feature+Game.maxUnits},key=fk} end
						elseif allowed and allowed>0 and budget>=funding(job.def,economy) then selected={cmd=-job.def,params={job.point[1],job.point[2],job.point[3],job.facing},key=k}; budget=budget-funding(job.def,economy) end
					end
				end
				if selected then break end
			end end
			if not selected then for _,site in ipairs(R.sites) do local p=site.point; local k='survey:'..key(0,p); if not site.finished and not buildSite(p) and now-site.lastThreat>=20 and not C.observations.nearCombat(p,900) and not Spring.GetPositionLosState(p[1],p[2],p[3]) and not occupied[k] and now>=(R.retry[k] or 0) and routeClear(C.U.position(id),p) then selected=survey(id,p,k); if selected then break end end end end
			if not selected and Spring.GetFeaturesInRectangle then for _,site in ipairs(R.sites) do
				if not site.finished and now-site.lastThreat>=20 and not C.observations.nearCombat(site.point,900) and routeClear(C.U.position(id),site.point) then
					local p=site.point; local features=Spring.GetFeaturesInRectangle(p[1]-700,p[3]-700,p[1]+700,p[3]+700) or {}
					for _,fid in ipairs(features) do local x,y,z=Spring.GetFeaturePosition(fid)
						if x and Spring.GetPositionLosState(x,y,z) then local fd=Spring.GetFeatureDefID and FeatureDefs[Spring.GetFeatureDefID(fid)]; local fromUnit=fd and fd.customParams and tonumber(fd.customParams.fromunit)==1; local metal=fromUnit and Spring.GetFeatureResources(fid) or 0; local k='wreck:'..fid
							if metal and metal>0 and not occupied[k] and now>=(R.retry[k] or 0) then selected={cmd=CMD.RECLAIM,params={fid+Game.maxUnits},key=k}; break end
						end
					end
				end
				if selected then break end
			end end
			if selected then if issue(id,selected.cmd,selected.params,selected.key) then occupied[selected.key]=true end end
		end
		for _,site in ipairs(R.sites) do if now-site.lastThreat>=20 and not site.finished then
			local pending=false
			for _,job in ipairs(jobs) do if C.U.distance(job.point,site.point)<1000 then pending=true end end
			for _,asset in ipairs(damaged) do if C.U.distance(asset.point,site.point)<1000 then pending=true end end
			if next(R.tasks) then pending=true end
			if not Spring.GetPositionLosState(site.point[1],site.point[2],site.point[3]) then pending=true end
			-- Wait for workers to inspect/reclaim before releasing the escort.
			if not pending and next(R.workers) and now-site.lastThreat>=30 then site.finished=true end
		end end
		local count=0; for _ in pairs(R.workers) do count=count+1 end
		R.status='Recovery: '..count..' builders; '..#jobs..' pending rebuild/build requests; '..#available..' idle'
	end
	return R
end
