-- Map-wide military objectives from public map geometry and client observations.
return function(C)
	local M={}
	function M.initialize(f)
		local m={cells={},attempts={},visits={},missions={}}; f.mapState=m
		for z=1,5 do for x=1,5 do
			local px,pz=Game.mapSizeX*(x-.5)/5,Game.mapSizeZ*(z-.5)/5
			m.cells[#m.cells+1]={px,Spring.GetGroundHeight(px,pz),pz}
		end end
		return m
	end
	function M.sector(f,ids,target)
		local origin=C.U.center(ids); local dx,dz=target[1]-origin[1],target[3]-origin[3]
		local length=math.sqrt(dx*dx+dz*dz); if length<1 then dx,dz,length=0,1,1 end
		return {origin=origin,goal=target,length=length,ux=dx/length,uz=dz/length,px=-dz/length,pz=dx/length,
			half=math.max(Game.mapSizeX,Game.mapSizeZ)*.6,corridor={{0,0,0},{Game.mapSizeX,0,0},{Game.mapSizeX,0,Game.mapSizeZ},{0,0,Game.mapSizeZ}}}
	end
	function M.choose(f,group,ids,contacts,now)
		local m=f.mapState or M.initialize(f); local center=C.U.center(ids)
		for i,p in ipairs(m.cells) do
			if C.U.distance(center,p)<350 or Spring.GetPositionLosState(p[1],p[2],p[3]) then m.visits[i]=now end
		end
		local best,score,kind,reason,key
		if group~='SCOUT' then
			local value=0; for _,id in ipairs(ids) do value=value+C.classify.definition(Spring.GetUnitDefID(id)).cost end
			for _,v in ipairs(contacts) do if v.visibility=='VISUAL' and v.defID then
				local def=C.classify.definition(v.defID); local vulnerable=def.builder or def.range==0 or def.role=='ARTILLERY'
				local risk=C.rules.risk(v.position,contacts,450)
				if group=='MAIN' or vulnerable and risk<math.max(200,value*1.5) then
					local s=C.U.distance(center,v.position)+risk*(group=='MAIN' and .15 or 2)-(vulnerable and 500 or 0)
					if not score or s<score then best=v.position; score=s; kind='ATTACK CONTACT'; reason='Attack currently visible enemy contact; native Fight chooses local targets.'; key='visual:'..v.id end
				end
			end end
		end
		if not best then
			for i,p in ipairs(m.cells) do
				local age=math.min(600,now-(m.visits[i] or -600)); local tried=now-(m.attempts[i] or -600)
				local reserved=0; for other,mission in pairs(m.missions) do if other~=group and mission.cell==i and now-mission.time<90 then reserved=8000 end end
				local s=C.U.distance(center,p)*.35-age*8+math.max(0,90-tried)*100+reserved+C.rules.risk(p,contacts,600)
				if C.U.distance(center,p)>400 and (not score or s<score) then best=p; score=s; key=i; kind=group=='MAIN' and 'SEARCH ADVANCE' or 'SCOUT MAP'; reason='Search least recently observed map sector '..i..'; unseen space is unknown.' end
			end
		end
		if best then
			m.missions[group]={point=C.U.copy(best),cell=type(key)=='number' and key or nil,time=now,kind=kind}
			if type(key)=='number' then m.attempts[key]=now end
			C.debug.log('MAP_CONTROL',group..': '..reason)
		end
		return best,kind,reason
	end
	function M.review(f,group,ids,op,contacts,now)
		if not op or not op.active then return end
		local center=C.U.center(ids); if not center then return end
		local nearCombat=C.observations.nearCombat(center,650)
		local mission=f.mapState and f.mapState.missions[group]
		local arrived,total=0,0
		for _,id in ipairs(op.units) do if f.members[id] and C.U.owned(id) then total=total+1; if C.U.distance(C.U.position(id),op.slots[id])<180 then arrived=arrived+1 end end end
		local contactInterrupt=false
		if group=='MAIN' and now-op.created>=12 and mission and mission.kind~='ATTACK CONTACT' then
			for _,v in ipairs(contacts) do if v.visibility=='VISUAL' then contactInterrupt=true; break end end
		end
		if not nearCombat and (total>0 and arrived/total>=.7 or now-op.created>=60) or contactInterrupt then
			C.officer.cancel(op.id); op.accounted=true
			f.delegation.next[group]=now; f.delegation.failures[group]=0
		end
	end
	return M
end
