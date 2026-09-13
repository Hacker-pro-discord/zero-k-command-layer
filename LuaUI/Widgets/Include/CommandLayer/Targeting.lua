-- Visible target priorities. No orders, enemy queues or hidden unit state.
return function(C)
 local T={cursor=0}
 function T.score(v,center,group)
  if v.visibility~='VISUAL' or not v.defID then return end
  local raw=UnitDefs[v.defID]; if not raw then return end
  local d=C.classify.definition(v.defID); local distance=C.U.distance(center,v.position)
  local priority,reason=0,'Visible combat unit'
  if tonumber((raw.customParams or {}).metal_extractor_mult) then priority=650; reason='Visible mex: deny metal income'
  elseif d.builder and not raw.isFactory then priority=v.repairing and 1000 or 750; reason=v.repairing and 'Visible constructor repairing a completed target' or 'Visible repair-capable constructor: remove local support'
  elseif d.role=='SUPPORT' then priority=500; reason='Visible support unit'
  elseif raw.isFactory then priority=400; reason='Visible factory: deny production' end
  if v.recentAttacker then priority=priority+1200; reason='Recently damaged our units; '..reason end
  if (raw.isBuilding or (raw.speed or 0)==0) and d.range>0 and distance<=d.range+300 then priority=math.max(priority,800); reason=v.recentAttacker and 'Visible turret recently damaged our units' or 'Visible turret threatens this approach (range estimate)' end
  if group=='RAID' and d.range>0 and not d.builder and d.role~='ARTILLERY' then priority=priority-500 end
  return priority-distance*.45,reason,priority
 end
 function T.choose(ids,contacts,group,sector,limit,filter)
  local center=C.U.center(ids); if not center then return end
  local best,score,reason; local value=0
  for _,id in ipairs(ids) do local h,m=Spring.GetUnitHealth(id); value=value+C.classify.definition(Spring.GetUnitDefID(id)).cost*(h and m and h/math.max(1,m) or 1) end
  for _,v in ipairs(contacts) do
   if v.visibility=='VISUAL' and v.defID and (not sector or C.formations.inCorridor(sector,v.position)) and (not limit or C.U.distance(center,v.position)<=limit) and (not filter or filter(v)) then
    local risk=C.rules.risk(v.position,contacts,450)
    if risk<math.max(150,value*(group=='RAID' and 1.1 or 1.5)) then
     local s,r=T.score(v,center,group); s=s-risk*.3
     if not score or s>score or s==score and v.id<best.id then best=v; score=s; reason=r end
    end
   end
  end
  return best,reason,score
 end
 function T.focus(f,now)
  if not f.delegation or not f.delegation.active or f.delegation.recovery then return end
  local ids=C.officer.members(f); if #ids==0 then return end
  local contacts=C.observations.snapshot().contacts; local sent=0
  -- Bounded rotating scan: large forces do not monopolize a frame.
  local cursor=f.targetCursor or 0
  for _=1,math.min(128,#ids) do
   cursor=cursor%#ids+1; local id=ids[cursor]; local op=C.registry.operations[C.registry.owner[id]]
   local own=C.classify.definition(Spring.GetUnitDefID(id)); local prior=C.orders.focus[id]
   if op and op.grant and C.registry.valid(op,id) and not Spring.GetUnitTransporter(id) and Spring.GetUnitRulesParam(id,'retreat')~=1 and not (prior and now-prior.time<6) and own.range>0 then
    local center=C.U.position(id); local best,score,reason
    for _,v in ipairs(contacts) do
     local raw=v.visibility=='VISUAL' and v.defID and UnitDefs[v.defID]
     if raw and C.formations.inCorridor(f.delegation.sector,v.position) and C.U.distance(center,v.position)<=own.range and (own.role~='ANTI_AIR' or raw.canFly) and (not raw.canFly or own.role=='ANTI_AIR') then
      local s,r,priority=T.score(v,center,'MAIN'); if priority>0 and (not score or s>score) then best=v; score=s; reason=r end
     end
    end
    if best and (not prior or prior.target~=best.id) then
     -- Keep a still-visible current target unless the alternative is materially better.
     local oldScore
     if prior then for _,v in ipairs(contacts) do if v.id==prior.target then oldScore=T.score(v,center,'MAIN'); break end end end
     if (not oldScore or score>oldScore+200) and C.officer.focusTarget(op,id,best) then
      sent=sent+1; f.targetReason=reason; C.debug.log('TARGET',id..' -> '..best.id..': '..reason)
     end
    end
   end
   if sent>=40 then break end
  end
  f.targetCursor=cursor
 end
 return T
end
