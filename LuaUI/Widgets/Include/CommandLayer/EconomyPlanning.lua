-- Read-only economy/grid and factory planning. Economy owns all builder orders.
return function(C)
	local P={}
	function P.snapshot(ids)
		local s={nodes={},grids={},gridMex={},counts={},pending={},pendingPower=0,factoryPower=0}
		for _,id in ipairs(ids) do if C.U.owned(id) then
			local d=UnitDefs[Spring.GetUnitDefID(id)]; local _,_,_,_,built=Spring.GetUnitHealth(id)
			s.counts[d.name]=(s.counts[d.name] or 0)+1; if built and built<1 then s.pending[d.name]=true; s.pendingPower=s.pendingPower+(d.energyMake or 0) end
			if d.isFactory then s.factoryPower=s.factoryPower+math.max(10,d.buildSpeed or 18) end
			local r=tonumber((d.customParams or {}).pylonrange)
			if r and built==1 and Spring.GetUnitRulesParam(id,'disarmed')~=1 then
				local grid=Spring.GetUnitRulesParam(id,'gridNumber'); local energy=Spring.GetUnitRulesParam(id,'current_energyIncome') or d.energyMake or 0
				local node={id=id,p=C.U.position(id),radius=r,grid=grid,energy=energy,mex=tonumber((d.customParams or {}).metal_extractor_mult)~=nil}
				if node.p then s.nodes[#s.nodes+1]=node end
				if grid and grid>0 then s.grids[grid]=(s.grids[grid] or 0)+energy; if node.mex then s.gridMex[grid]=(s.gridMex[grid] or 0)+1 end end
			end
		end end
		return s
	end
	function P.safeRoute(a,b)
		local n=math.max(1,math.ceil(C.U.distance(a,b)/320))
		for i=1,n do local t=i/n; local p={a[1]+(b[1]-a[1])*t,0,a[3]+(b[3]-a[3])*t}; p[2]=Spring.GetGroundHeight(p[1],p[3]); if C.observations.nearCombat(p,800) then return false end end
		return true -- No observed threat, never a claim that unseen ground is safe.
	end
	function P.energyAnchor(state,worker)
		local best,score
		for _,n in ipairs(state.nodes) do if n.mex or n.radius>=400 then
			local distance=C.U.distance(worker,n.p); local power=state.grids[n.grid] or 0
			local value=distance+math.min(2000,power*20)
			if not C.observations.nearCombat(n.p,800) and (not score or value<score) then best=n; score=value end
		end end
		return best
	end
	function P.bridge(state,worker)
		local candidates={}
		for _,a in ipairs(state.nodes) do if a.grid and (state.grids[a.grid] or 0)>=10 then
			for _,b in ipairs(state.nodes) do if b.mex and b.grid and b.grid~=a.grid and (state.grids[b.grid] or 0)/math.max(1,(state.gridMex or {})[b.grid] or 0)<(state.grids[a.grid] or 0)/math.max(1,(state.gridMex or {})[a.grid] or 0)*.8 then
				local distance=C.U.distance(a.p,b.p)
				if distance>a.radius+b.radius and distance<1800 then
					local step=math.min(distance/2,a.radius+500-48); local t=step/distance
					local pos={a.p[1]+(b.p[1]-a.p[1])*t,0,a.p[3]+(b.p[3]-a.p[3])*t}; pos[2]=Spring.GetGroundHeight(pos[1],pos[3])
					local value=distance+C.U.distance(worker,pos)
					candidates[#candidates+1]={p=pos,anchor=a,target=b,score=value}
				end
			end end
		end end
		table.sort(candidates,function(a,b) return a.score<b.score end)
		for i=1,math.min(32,#candidates) do local c=candidates[i]; if P.safeRoute(c.anchor.p,c.target.p) then return c end end
	end
	function P.storageNeeded(s,r)
		if s.pending.staticstorage or (s.counts.staticstorage or 0)>=6 then return false end
		local m,e=r.metal,r.energy; local capacity=m.storage or 500
		return (m.income or 0)>=15 and capacity<math.min(3500,math.max(750,(m.income or 0)*20)) and m.current>capacity*.75
			or (e.income or 0)>=60 and (e.storage or 1000)<math.min(3500,e.income*10) and e.current>(e.storage or 1000)*.95 and m.current>200
	end
	function P.factories(worker,existing,r)
		local d=UnitDefs[Spring.GetUnitDefID(worker)]; local choices={}; local weights,model,friendly,total
		if C.enemyModel then weights,model=C.enemyModel.weights(); friendly,total=C.enemyModel.friendly() end
		local owned={}; for _,id in ipairs(existing) do owned[Spring.GetUnitDefID(id)]=true end
		for _,fid in ipairs(d.buildOptions or {}) do local factory=UnitDefs[fid]
			if factory and factory.isFactory then
				local best=-math.huge; local explanation='existing production capacity'; local hasCoverage=false
				for _,uid in ipairs(factory.buildOptions or {}) do local unit=C.classify.definition(uid)
					-- A new factory must have a counter that current income can actually fund.
					if unit.mobile and not unit.builder and unit.cost>0 and unit.cost<=math.max(300,(r.metal.income or 0)*45) then
						local score,detail=0,nil; if weights then score,detail=C.enemyModel.score(unit,weights,friendly,total,model) end
												if score>best then best=score; hasCoverage=detail and detail.coverage>0 or false; explanation=(unit.display or unit.name)..'; '..(detail and detail.reason or 'role deficit') end
					end
				end
				if best>-math.huge then choices[#choices+1]={name=factory.name,score=best,existing=owned[fid],covered=hasCoverage,reason=explanation,cost=factory.metalCost or 0} end
			end
		end
		local incumbent=-math.huge
		for _,v in ipairs(choices) do if v.existing then incumbent=math.max(incumbent,v.score) end end
		for _,v in ipairs(choices) do
			-- Pay for a new capability only with a meaningful advantage over existing options.
			v.preferred=v.existing or v.covered and v.score>incumbent+math.max(1,math.abs(incumbent)*.12)
		end
		table.sort(choices,function(a,b) if a.preferred~=b.preferred then return a.preferred end; if a.score~=b.score then return a.score>b.score end; if a.existing~=b.existing then return a.existing==true end; return a.name<b.name end)
		return choices
	end
	return P
end
