-- Public terrain and own production only. Never requires enemy composition.
return function(C)
 local P={}
 function P.factories(worker)
  local origin=C.U.position(worker); local water,rough,n=0,0,0
  for x=1,7 do for z=1,7 do
   local px,pz=Game.mapSizeX*x/8,Game.mapSizeZ*z/8
   local h=Spring.GetGroundHeight(px,pz); water=water+(h< -5 and 1 or 0)
   rough=rough+math.abs(h-Spring.GetGroundHeight(math.min(Game.mapSizeX-1,px+128),pz))/128; n=n+1
  end end
  water=water/n; rough=rough/n
  local under=Spring.GetGroundHeight(origin[1],origin[3])< -5
  local preferred=under and water>.5 and 'factoryship' or water>.25 and 'factoryhover' or rough>.25 and 'factoryspider' or Game.mapSizeX*Game.mapSizeZ>=24000000 and 'factoryveh' or 'factorycloak'
  local rank={[preferred]=100,factorycloak=20,factoryhover=water>.15 and 60 or 10,factoryamph=under and 80 or 5,factoryship=under and 70 or -100,factoryspider=rough>.15 and 65 or 10}
  rank[preferred]=100
  local list={}; local def=UnitDefs[Spring.GetUnitDefID(worker)]
  for _,id in ipairs(def and def.buildOptions or {}) do local d=UnitDefs[id]
   if d and d.isFactory and d.name~='striderhub' then list[#list+1]={name=d.name,score=rank[d.name] or 0,reason=string.format('Public terrain: %.0f%% sampled water, roughness %.2f; opening mobility preference %s',water*100,rough,preferred)} end
  end
  table.sort(list,function(a,b) return a.score>b.score or a.score==b.score and a.name<b.name end)
  return list
 end
 function P.forceState()
  local s={combat=0,builders=0,scouts=0,roles={}}
  local function count(def)
   local v=C.classify.definition(def)
   if v.mobile then
    if v.builder then s.builders=s.builders+1 else s.combat=s.combat+1; s.roles[v.role]=(s.roles[v.role] or 0)+1; if (v.role=='SCOUT' or v.role=='RAIDER') and (UnitDefs[def].speed or 0)>=70 then s.scouts=s.scouts+1 end end
   end
  end
  for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID()) or {}) do if C.U.owned(id) then
   local _,_,_,_,built=Spring.GetUnitHealth(id); if not built or built>=1 then count(Spring.GetUnitDefID(id)) end; local d=UnitDefs[Spring.GetUnitDefID(id)]
   if d.isFactory and Spring.GetFactoryCommands then for _,q in ipairs(Spring.GetFactoryCommands(id,-1) or {}) do if q.id and q.id<0 then count(-q.id) end end end
  end end
  return s
 end
 function P.scout(factory,state)
  if state.scouts>= (state.combat>=25 and 2 or 1) then return end
  local best,score
  for _,def in ipairs(factory.buildOptions or {}) do local v=C.classify.definition(def); local d=UnitDefs[def]
   if v.mobile and not v.builder and (v.role=='SCOUT' or v.role=='RAIDER') and (d.speed or 0)>=70 and v.cost<=240 then
    local rank=(v.role=='SCOUT' and 5 or 0)+(d.speed or 0)/math.max(1,v.cost)^.3
    if not score or rank>score then best=def; score=rank end
   end
  end
  return best
 end
 function P.score(unit,state)
  local weight={RAIDER=.4,RIOT=.25,SKIRMISHER=.2,ASSAULT=.15,ARTILLERY=.03,OTHER=.05,ANTI_AIR=0,SUPPORT=.01,SCOUT=.01}
  return ((weight[unit.role] or .01)*(state.combat+4)-(state.roles[unit.role] or 0))*100-unit.cost*.03
 end
 return P
end
