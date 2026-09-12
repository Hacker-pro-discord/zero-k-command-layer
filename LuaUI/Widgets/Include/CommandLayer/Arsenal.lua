-- Explicit launcher authority. Native ammunition/build costs and visibility still apply.
return function(C)
	local A={enabled=false,enrolled={},excluded={},tasks={},shots={},last=-100,reservations={},status='Strategic fire OFF; select launchers and arm them explicitly.'}
	local function queue(id)
		local d=UnitDefs[Spring.GetUnitDefID(id)]
		if d and (d.isFactory or d.customParams and d.customParams.missile_silo_capacity) and Spring.GetFactoryCommands then return Spring.GetFactoryCommands(id,1) or {} end
		return Spring.GetCommandQueue(id,1) or {}
	end
	local function own(id) return C.U.owned(id) and select(5,Spring.GetUnitHealth(id))==1 end
	local function weapon(id)
		local d=UnitDefs[Spring.GetUnitDefID(id)]; if not d then return end
		for _,w in ipairs(d.weapons or {}) do local v=WeaponDefs[w.weaponDef]; if v and (v.interceptor or 0)==0 and (v.stockpile or d.customParams and d.customParams.missile_silo_projectile) then return v,d end end
		-- Silo children are identified by the native parent rule, not a guessed unit list.
		if Spring.GetUnitRulesParam(id,'missile_parentSilo') then for _,w in ipairs(d.weapons or {}) do local v=WeaponDefs[w.weaponDef]; if v and (v.range or 0)>100 then return v,d end end end
	end
	local function authority(id)
		local parent=Spring.GetUnitRulesParam(id,'missile_parentSilo')
		return not A.excluded[id] and (A.enrolled[id] or parent and A.enrolled[parent])
	end
	local function visible(id)
		local s=Spring.GetUnitLosState(id,Spring.GetMyAllyTeamID(),false)
		return s and s.los and Spring.GetUnitTeam(id) and not Spring.AreTeamsAllied(Spring.GetUnitTeam(id),Spring.GetMyTeamID())
	end
	local function safe(id,p,w,d)
		local origin=C.U.position(id); if not origin or C.U.distance(origin,p)>(w.range or 0) then return false end
		local radius=(w.damageAreaOfEffect or 0)+160
		for _,u in ipairs(Spring.GetAllUnits()) do local team=Spring.GetUnitTeam(u); if team and Spring.AreTeamsAllied(team,Spring.GetMyTeamID()) then local q=C.U.position(u); if q and C.U.distance(q,p)<radius then return false end end end
		if d.customParams and d.customParams.is_nuke then
			for _,c in ipairs(C.observations.snapshot().contacts) do if c.visibility=='VISUAL' and c.defID and visible(c.id) then
				local cp=UnitDefs[c.defID].customParams or {}; local r=tonumber(cp.nuke_coverage)
				if r then local vx,vz=p[1]-origin[1],p[3]-origin[3]; local t=math.max(0,math.min(1,((c.position[1]-origin[1])*vx+(c.position[3]-origin[3])*vz)/math.max(1,vx*vx+vz*vz))); if C.U.distance(c.position,{origin[1]+vx*t,0,origin[3]+vz*t})<r then return false end end
			end end
		end
		return true
	end
	function A.valid(id,cmd,params)
		if not C.U.delegationAllowed(C.settings) or not own(id) or Spring.GetUnitIsStunned and Spring.GetUnitIsStunned(id) then return false end
		local t=A.tasks[id]; if not t or t.cmd~=cmd or #t.params~=#params then return false end
		for i=1,#params do if params[i]~=t.params[i] then return false end end
		if cmd==CMD.REMOVE then for _,q in ipairs(Spring.GetCommandQueue(id,32) or {}) do if q.tag==params[1] and q.id==CMD.ATTACK and A.shots[id] and C.U.distance(q.params,A.shots[id].point)<1 then return true end end; return false end
		if not A.enabled or not authority(id) then return false end
		if cmd==CMD.ATTACK then
			local w,d=weapon(id); local stock=w and w.stockpile and (Spring.GetUnitStockpile(id) or 0) or 1
			local point=t.target and visible(t.target) and C.U.position(t.target)
			return w and stock>0 and point and C.U.distance(point,params)<100 and safe(id,params,w,d) and #queue(id)==0
		end
		if cmd==CMD.STOCKPILE then local n,q=Spring.GetUnitStockpile(id); return (n or 0)+(q or 0)<1 end
		if cmd<0 then local d=UnitDefs[Spring.GetUnitDefID(id)]; for _,def in ipairs(d.buildOptions or {}) do if def==-cmd then return #queue(id)==0 end end end
		return false
	end
	local function send(id,cmd,p,target)
		A.tasks[id]={cmd=cmd,params=p,target=target}; local ok=C.officer.executeStrategic(id,cmd,p); A.tasks[id]=nil; return ok
	end
	function A.issued(id,cmd,p,tag)
		local shot=A.shots[id]; if shot and cmd==CMD.ATTACK and C.U.distance(p,shot.point)<1 and C.U.now()-shot.time<5 then shot.tag=tag end
	end
	local function clear(id)
		local shot=A.shots[id]; if shot and shot.tag then send(id,CMD.REMOVE,{shot.tag}) end; A.shots[id]=nil
	end
	function A.release(id)
		clear(id); for child in pairs(A.shots) do if Spring.GetUnitRulesParam(child,'missile_parentSilo')==id then clear(child) end end
		A.enrolled[id]=nil; A.excluded[id]=true
	end
	function A.stop() for id in pairs(A.shots) do clear(id) end; A.enabled=false; A.enrolled={}; A.status='Strategic fire OFF; native ammunition queues preserved.' end
	function A.enroll(ids)
		if not C.U.delegationAllowed(C.settings) then return false end
		local n=0
		for _,id in ipairs(ids) do if own(id) then local d=UnitDefs[Spring.GetUnitDefID(id)]; if weapon(id) or d.customParams and d.customParams.missile_silo_capacity then
			C.registry.release({id},'STRATEGIC_LAUNCHER'); A.enrolled[id]=true; A.excluded[id]=nil; n=n+1
		end end end
		A.enabled=A.enabled or n>0; A.status=n..' launchers enrolled. Native ammunition; visual targets only.'; return n
	end
	function A.update()
		if not A.enabled then return end
		if not C.U.delegationAllowed(C.settings) then A.stop(); return end
		local now=C.U.now(); if now-A.last<1 then return end; A.last=now
		for id,s in pairs(A.shots) do
			if not own(id) then A.shots[id]=nil
			elseif now-s.time>10 or s.stock and (Spring.GetUnitStockpile(id) or 0)<s.stock or not visible(s.target) then clear(id) end
		end
		local team=Spring.GetTeamUnits(Spring.GetMyTeamID()); local contacts=C.observations.snapshot().contacts
		local candidates={}; for _,c in ipairs(contacts) do if c.visibility=='VISUAL' and c.defID then candidates[#candidates+1]=c end end
		table.sort(candidates,function(a,b) return (UnitDefs[a.defID].metalCost or 0)>(UnitDefs[b.defID].metalCost or 0) end)
		while #candidates>32 do table.remove(candidates) end
		local budget=Spring.GetTeamResources(Spring.GetMyTeamID(),'metal') or 0
		for _,id in ipairs(team) do if own(id) and authority(id) and not A.shots[id] and #queue(id)==0 then
			local w,d=weapon(id); d=d or UnitDefs[Spring.GetUnitDefID(id)]; local cp=d.customParams or {}
			if cp.missile_silo_capacity then
				local count=0; for _,child in ipairs(team) do if Spring.GetUnitRulesParam(child,'missile_parentSilo')==id then count=count+1 end end
				if count<tonumber(cp.missile_silo_capacity) then for _,def in ipairs(d.buildOptions or {}) do local b=UnitDefs[def]; if b.name=='tacnuke' and budget>=(b.metalCost or 600) then if send(id,-def,{}) then budget=budget-(b.metalCost or 600) end; break end end end
			elseif w then
				local stock,queued=1,0; if w.stockpile then stock,queued=Spring.GetUnitStockpile(id); stock=stock or 0; queued=queued or 0 end
				if stock<1 then if queued<1 then send(id,CMD.STOCKPILE,{}) end
				else
					local best,score=nil,math.max(200,tonumber(cp.stockpilecost) or d.metalCost or 200)*.75
					for _,c in ipairs(candidates) do if c.visibility=='VISUAL' and c.defID and not UnitDefs[c.defID].canFly and visible(c.id) and safe(id,c.position,w,d) then
						local reserved=false; for _,r in ipairs(A.reservations) do if r.untilTime>now and C.U.distance(r.point,c.position)<math.max(300,w.damageAreaOfEffect or 0) then reserved=true end end
						local value=0; for _,e in ipairs(contacts) do if e.visibility=='VISUAL' and e.defID and visible(e.id) and C.U.distance(e.position,c.position)<math.max(100,w.damageAreaOfEffect or 0) then value=value+(UnitDefs[e.defID].metalCost or 0) end end
						if not reserved and value>score then best=c; score=value end
					end end
					if best then
						A.shots[id]={point=C.U.copy(best.position),target=best.id,time=now,stock=w.stockpile and stock or nil}
						if send(id,CMD.ATTACK,best.position,best.id) then A.reservations[#A.reservations+1]={point=best.position,untilTime=now+30}; A.status='Firing '..(d.humanName or d.name)..' at visible value '..math.floor(score)..'. Unknown interception remains possible.'
						else A.shots[id]=nil end
					end
				end
			end
		end end
		for i=#A.reservations,1,-1 do if A.reservations[i].untilTime<=now then table.remove(A.reservations,i) end end
	end
	return A
end
