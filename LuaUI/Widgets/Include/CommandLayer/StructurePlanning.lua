-- Native menu membership; decisions only, Economy/Recovery issue validated orders.
return function(C)
 local P={categories={},status='Defence / Special ready',nextBuild=0}
 if VFS and VFS.Include then
  local ok,_,_,defense,special=pcall(VFS.Include,'LuaUI/Configs/integral_menu_commands_build.lua')
  if ok then
   for category,items in pairs({DEFENCE=defense or {},SPECIAL=special or {}}) do
    for name in pairs(items) do local d=type(name)=='string' and UnitDefNames[name]; if d then P.categories[d.id]=category end end
   end
  else P.status='Native build categories unavailable; automatic structures disabled' end
 end
 function P.catalog(ids,category)
  local found,list={},{}
  for _,id in ipairs(ids or {}) do if C.U.owned(id) then
   local d=UnitDefs[Spring.GetUnitDefID(id)]
   for _,bid in ipairs(d and d.buildOptions or {}) do if P.categories[bid]==category and not found[bid] then found[bid]=true; list[#list+1]=bid end end
  end end
  table.sort(list,function(a,b) return (UnitDefs[a].metalCost or 0)<(UnitDefs[b].metalCost or 0) or (UnitDefs[a].metalCost or 0)==(UnitDefs[b].metalCost or 0) and a<b end)
  return list
 end
 function P.arm(def)
  if not C.U.delegationAllowed(C.settings) or not P.categories[def] then return false end
  local index=Spring.GetCmdDescIndex(-def)
  if not index then P.status='Select a constructor with this native build option'; return false end
  C.recovery.armed=true; Spring.SetActiveCommand(index); P.status='Place the native building ghost; Officer receives this construction request'; return true
 end
 function P.choose(id,own,resources,catchup,now)
  if not C.settings.autoStructures or not C.U.delegationAllowed(C.settings) or catchup or now<P.nextBuild then return end
  local metal,energy=resources.metal,resources.energy
  if metal.current<180 or energy.current<200 or (energy.income or 0)<(metal.income or 0) then return end
  local origin=C.U.position(id); local anchor,nearest; local army,investment=0,0
  for _,u in ipairs(own) do if C.U.owned(u) then
   local def=Spring.GetUnitDefID(u); local raw=UnitDefs[def]; local v=C.classify.definition(def); local pos=C.U.position(u)
   if v.mobile and not v.builder then army=army+v.cost end
   if P.categories[def] then investment=investment+(raw.metalCost or 0) end
   if pos and (raw.isFactory or tonumber((raw.customParams or {}).metal_extractor_mult)) then local dist=C.U.distance(origin,pos); if dist<1400 and (not nearest or dist<nearest) then anchor=pos; nearest=dist end end
  end end
  if not anchor then return end
  local contacts=C.observations.snapshot().contacts; local air,ground,sea=0,0,0
  for _,v in ipairs(contacts) do if v.visibility=='VISUAL' and v.defID and C.U.distance(anchor,v.position)<1800 then
   local d=UnitDefs[v.defID]; if d then if d.canFly then air=air+1 elseif (d.minWaterDepth or 0)>0 then sea=sea+1 else ground=ground+1 end end
  end end
  local options={}; for _,category in ipairs({'DEFENCE','SPECIAL'}) do for _,def in ipairs(P.catalog({id},category)) do options[#options+1]=def end end
  local best,score
  for _,def in ipairs(options) do
   local d=UnitDefs[def]; local cost=d.metalCost or 0; local name=d.name; local priority,reason,radius
   if name=='staticradar' then priority=40; reason='Extend radar coverage around owned infrastructure; radar identities remain unknown'; radius=math.max(900,(d.radarDistance or 0)*.7)
   elseif name=='staticjammer' and army>=4000 and ground>0 then priority=30; reason='Jamming support near observed ground pressure'; radius=900
   elseif name=='staticshield' and army>=4000 and ground>0 then priority=45; reason='Shield support for pressured infrastructure'; radius=700
   elseif name=='turrettorp' and sea>0 then priority=80; reason='Observed naval pressure near infrastructure'; radius=650
   elseif name=='turretaalaser' or name=='turretaaclose' or name=='turretaaflak' then if air>0 then priority=85; reason='Observed air pressure near infrastructure'; radius=700 end
   elseif name=='turretlaser' or name=='turretmissile' or name=='turretriot' or name=='turretgauss' then
    if ground>0 or army>=650 then priority=ground>0 and 65 or 20; reason=ground>0 and 'Observed ground pressure; fortify a clear local site' or 'Light protection for owned resource infrastructure'; radius=650 end
   end
   if priority and cost<=metal.current-100 and investment+cost<=math.max(120,army*.2) then
    local covered=false
    for _,u in ipairs(own) do if C.U.owned(u) then local other=UnitDefs[Spring.GetUnitDefID(u)]; local pos=C.U.position(u)
     if pos and C.U.distance(pos,anchor)<radius and (other.name==name or P.categories[Spring.GetUnitDefID(u)]=='DEFENCE' and P.categories[def]=='DEFENCE' and C.classify.definition(Spring.GetUnitDefID(u)).role==C.classify.definition(def).role) then covered=true; break end
    end end
    local rank=priority-cost*.015
    if not covered and (not score or rank>score) then best={name=name,key='structure '..def..' near '..math.floor(anchor[1]/650)..':'..math.floor(anchor[3]/650),origin=anchor,reason=reason}; score=rank end
   end
  end
  return best
 end
 function P.issued(job,now) P.nextBuild=now+30; P.status=job.reason; C.debug.log('STRUCTURE PLAN',job.name..': '..job.reason) end
 return P
end
