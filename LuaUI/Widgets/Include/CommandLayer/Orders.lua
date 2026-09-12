return function(C)
	local O={sending=false,pending={},tokens=60,last=C.U.now()}
	local function same(a,b) if not a or not b or #a~=#b then return false end; for i=1,#a do if math.abs(a[i]-b[i])>.1 then return false end end; return true end
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
		local cmd=-unit; local opts=C.U.options({shift=true})
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
