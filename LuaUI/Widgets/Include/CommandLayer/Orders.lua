return function(C)
	local O={sending=false,pending={},focus={},tokens=60,last=C.U.now()}
	local function same(a,b) if not a or not b or #a~=#b then return false end; for i=1,#a do if math.abs(a[i]-b[i])>.1 then return false end end; return true end
	local function currentFocus(id,t)
		return t and C.U.owned(id) and C.registry.generation[id]==t.generation and Spring.GetUnitRulesParam(id,'target_type')==2 and Spring.GetUnitRulesParam(id,'target_id')==t.target
	end
	function O.clearFocus(id)
		local t=O.focus[id]; O.focus[id]=nil
		local cmd=Spring.Utilities.CMD.UNIT_CANCEL_TARGET
		if not cmd or not C.U.live() or not currentFocus(id,t) then return end
		local opts=C.U.options({}); O.sending=true
		local used=widgetHandler:UnitCommandNotify(id,cmd,{},opts)
		if not used and currentFocus(id,t) then
			O.pending[id]=O.pending[id] or {}; table.insert(O.pending[id],{cmd=cmd,params={},untilTime=C.U.now()+5})
			Spring.GiveOrderToUnit(id,cmd,{},opts.coded)
		end
		O.sending=false
	end
	function O.setFocus(op,id,v)
		local cmd=Spring.Utilities.CMD.UNIT_SET_TARGET
		if not cmd or not Spring.FindUnitCmdDesc or not Spring.FindUnitCmdDesc(id,cmd) or not op.grant or not C.registry.valid(op,id) then return false end
		local old=O.focus[id]; local kind=Spring.GetUnitRulesParam(id,'target_type') or 0
		if kind~=0 and not currentFocus(id,old) then return false end -- Preserve existing manual priority targets.
		local function valid()
			if not C.registry.valid(op,id) or Spring.GetUnitTransporter(id) or Spring.GetUnitRulesParam(id,'retreat')==1 or v.visibility~='VISUAL' or not v.time or C.U.now()-v.time>1 then return false end
			local los=Spring.GetUnitLosState(v.id,Spring.GetMyAllyTeamID(),false)
			if not los or not los.los or Spring.GetUnitDefID(v.id)~=v.defID then return false end
			local team=Spring.GetUnitTeam(v.id); if not team or Spring.AreTeamsAllied(team,Spring.GetMyTeamID()) then return false end
			local p=C.U.position(v.id); local f=C.registry.forces[op.forceID]
			return p and f and C.formations.inCorridor(f.delegation.sector,p) and C.U.distance(C.U.position(id),p)<=C.classify.definition(Spring.GetUnitDefID(id)).range
		end
		if not valid() then return false end
		local opts=C.U.options({}); O.sending=true
		local used=widgetHandler:UnitCommandNotify(id,cmd,{v.id},opts); local ok=false
		if not used and valid() then
			O.pending[id]=O.pending[id] or {}; table.insert(O.pending[id],{cmd=cmd,params={v.id},untilTime=C.U.now()+5})
			ok=Spring.GiveOrderToUnit(id,cmd,{v.id},opts.coded)
			if ok then O.focus[id]={target=v.id,generation=C.registry.generation[id],operation=op.id,time=C.U.now()} end
		end
		O.sending=false; return ok
	end
	function O.updateFocus()
		for id,t in pairs(O.focus) do
			local op=C.registry.operations[t.operation]
			local los=C.U.live() and Spring.GetUnitLosState(t.target,Spring.GetMyAllyTeamID(),false)
			local p=los and los.los and C.U.position(t.target)
			if not op or not C.registry.valid(op,id) or not p or not C.formations.inCorridor(C.registry.forces[op.forceID].delegation.sector,p) or Spring.GetUnitTransporter(id) or Spring.GetUnitRulesParam(id,'retreat')==1 or C.U.distance(C.U.position(id),p)>C.classify.definition(Spring.GetUnitDefID(id)).range or C.U.now()-t.time>=12 then O.clearFocus(id) end
		end
	end
	function O.native(id,params,opts)
		if not C.U.live() then return false end
		C.officer.releaseUnits(Spring.GetSelectedUnits(),'PLAYER_OVERRIDE')
		O.sending=true; local used=widgetHandler:CommandNotify(id,params,opts); if not used then Spring.GiveOrder(id,params,opts.coded) end; O.sending=false; return true
	end
	function O.unit(op,id,cmd,params,opts)
		if not C.registry.valid(op,id) then return false end
		O.sending=true
		local handled=widgetHandler:UnitCommandNotify(id,cmd,params,opts)
		local ok=false
		if not handled and C.registry.valid(op,id) then
			O.pending[id]=O.pending[id] or {}; table.insert(O.pending[id],{cmd=cmd,params=C.U.copy(params),untilTime=C.U.now()+5})
			ok=Spring.GiveOrderToUnit(id,cmd,params,opts.coded)
		end
		O.sending=false; return ok
	end
	function O.issue(op,id,cmd,pos,opts)
		local params=pos; local sendCmd=cmd; local sendOpts=opts
		if opts.meta then
			local index=0
			if opts.shift then
				local queue=Spring.GetCommandQueue(id,-1) or {}; local previous=C.U.position(id); local best=math.huge
				for i=0,#queue do
					local nextp=queue[i+1] and queue[i+1].params
					if previous then local cost=C.U.distance(previous,pos); if nextp and #nextp>=3 then cost=cost+C.U.distance(pos,nextp)-C.U.distance(previous,nextp) end; if cost<best then best=cost; index=i end end
					if nextp and #nextp>=3 then previous=nextp end
				end
			end
			params={index,cmd,opts.coded,pos[1],pos[2],pos[3]}; sendCmd=CMD.INSERT; sendOpts=C.U.options({alt=true})
		end
		return O.unit(op,id,sendCmd,params,sendOpts)
	end
	function O.clearCorrection(op,id)
		local t=op.tracking[id]; if not t or not t.correctionTag then return end
		for _,q in ipairs(Spring.GetCommandQueue(id,24) or {}) do
			if q.tag==t.correctionTag and q.id==Spring.Utilities.CMD.RAW_MOVE and t.correction and C.U.distance(q.params,t.correction)<2 then
				O.unit(op,id,CMD.REMOVE,{q.tag},C.U.options({})); break
			end
		end
		t.correction=nil; t.correctionTag=nil
	end
	function O.event(id,cmd,params,fromSynced)
		local list=O.pending[id] or {}
		for i=#list,1,-1 do local p=list[i]; if p.untilTime<C.U.now() then table.remove(list,i) elseif p.cmd==cmd and same(p.params,params) then table.remove(list,i); return true end end
		return fromSynced==true -- Native gadget orders are not player override.
	end
	function O.service(name,id,cmd,params)
		if name~='recovery' and name~='arsenal' and name~='economy' then return false end
		local service=C[name]; if not service or not service.valid(id,cmd,params) then return false end
		local opts=C.U.options({}); O.sending=true
		local handled=widgetHandler:UnitCommandNotify(id,cmd,params,opts); local ok=false
		if not handled and service.valid(id,cmd,params) then
			O.pending[id]=O.pending[id] or {}; table.insert(O.pending[id],{cmd=cmd,params=C.U.copy(params),untilTime=C.U.now()+5})
			ok=Spring.GiveOrderToUnit(id,cmd,params,opts.coded)
		end
		O.sending=false; return ok
	end
	function O.production(id,unit)
		if not C.productionControl or not C.productionControl.valid(id,unit) then return false end
		-- Native factory build commands append by default. Shift multiplies quantity by five.
		local cmd=-unit; local opts=C.U.options({})
		O.sending=true
		local handled=widgetHandler:UnitCommandNotify(id,cmd,{},opts)
		local ok=false
		if not handled and C.productionControl.valid(id,unit) then
			O.pending[id]=O.pending[id] or {}; table.insert(O.pending[id],{cmd=cmd,params={},untilTime=C.U.now()+5})
			ok=Spring.GiveOrderToUnit(id,cmd,{},opts.coded)
		end
		O.sending=false; return ok
	end
	function O.budget()
		local now=C.U.now(); O.corrections=O.corrections or {}
		while O.corrections[1] and O.corrections[1]<=now-1 do table.remove(O.corrections,1) end
		if #O.corrections>=60 then return false end
		O.corrections[#O.corrections+1]=now; return true
	end
	return O
end
