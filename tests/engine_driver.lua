-- Opt-in isolated integration harness. Never installed by tools/install.py.
function widget:GetInfo() return {name='Command Layer Local Test Driver',desc='Isolated engine integration checks',author='Codex',layer=-100,enabled=true,handler=true} end
local fights={}
function widget:UnitCommand(id,def,team,cmd) if cmd==CMD.FIGHT and team==Spring.GetMyTeamID() then fights[id]=true end end
local revision,stage,started,army,cons,fid,pid= nil,0,nil,{},{},nil,nil
local function report(message) Spring.Echo('[CL-QA] '..message); local file=io.open('LuaUI/Config/CommandLayer_QA.txt','a'); if file then file:write(message..'\n'); file:close() end end
local function check(ok,message) report((ok and 'PASS ' or 'FAIL ')..message) end
local function queues(ids) local n=0; for _,id in ipairs(ids) do n=n+#(Spring.GetCommandQueue(id,-1) or {}) end; return n end
function widget:Initialize()
 local name=Spring.GetPlayerInfo(Spring.GetMyPlayerID())
 if name~='CommandLayerTest' or Spring.IsReplay() then widgetHandler:RemoveWidget(self); return end
 started=Spring.GetGameSeconds()
end
function widget:Update()
 local r=VFS.LoadFile('LuaUI/Widgets/Include/CommandLayer/test_revision.txt',VFS.RAW)
 if not revision then revision=r elseif r~=revision then Spring.SendCommands('luaui reload'); return end
 local A=WG.CommandLayer; if not A or not A.SetPrivateTestingSession then return end
 local elapsed=Spring.GetGameSeconds()-started
 if stage==0 and elapsed>3 then
  report('RUN final input-priority integration')
  for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID())) do local d=UnitDefs[Spring.GetUnitDefID(id)]; if d.name=='cloakraid' or d.name=='cloakarty' then army[#army+1]=id elseif d.name=='cloakcon' then cons[#cons+1]=id end end
  check(#army>=4 and #cons>=1,'test units available')
  Spring.GiveOrderToUnitArray(army,CMD.STOP,{},0); Spring.GiveOrderToUnitArray(cons,CMD.STOP,{},0)
  stage=1
 elseif stage==1 and elapsed>4 then
  fights={}
  local all={}; for _,id in ipairs(army) do all[#all+1]=id end; for _,id in ipairs(cons) do all[#all+1]=id end
  local op=A.SubmitPlayerIntent({gesture={{1800,0,2600},{2600,0,2600}},command=CMD.FIGHT,settings={formation='DOUBLE LINE',spacing=64,rankGap=100,supportDepth=200,skirmDepth=250,artilleryDepth=350}},all)
  check(op~=nil,'DOUBLE LINE accepted through Officer'); stage=2
 elseif stage==2 and elapsed>4.3 then
  local n=0; for _,id in ipairs(army) do if fights[id] then n=n+1 end end; check(n==#army,'per-unit native Fight commands reached engine: '..n..'/'..#army); check(queues(cons)==0,'constructors excluded')
  A.SubmitPlayerIntent({gesture={{1800,0,3000},{2600,0,3000}},command=CMD.FIGHT,settings={formation='DOUBLE LINE',spacing=64,rankGap=100,supportDepth=200,skirmDepth=250,artilleryDepth=350}},army)
  stage=3
 elseif stage==3 and elapsed>5 then
  local q=Spring.GetCommandQueue(army[1],-1) or {}; local found=false; for _,c in ipairs(q) do if c.id==CMD.FIGHT and c.params[3] and c.params[3]>2800 then found=true end end
  check(found,'successive line replaces destinations')
  Spring.GiveOrderToUnitArray(army,CMD.STOP,{},0); check(A.SetPrivateTestingSession(true),'local adviser session enabled'); stage=4
 elseif stage==4 and elapsed>6 then
  fid=A.AssignAdvisedForce(army); check(fid and queues(army)==0,'assignment issues zero orders')
  A.SetObjective(fid,{{1800,0,3200},{2600,0,3200}}); pid=A.AskOfficer(fid); check(pid and queues(army)==0,'objective and proposal issue zero orders'); stage=5
 elseif stage==5 and elapsed>7 then
  local p; for _,v in ipairs(A.GetProposals(fid)) do if v.id==pid then p=v end end
  local op=p and A.ApproveProposal(pid,p.revision); check(op~=nil and op~=false,'fresh approval accepted'); check(not A.ApproveProposal(pid,1),'double approval rejected'); stage=6
 elseif stage==6 and elapsed>8 then
  check(queues(army)>0,'approved push produced native orders')
  widgetHandler:UnitCommandNotify(army[1],CMD.STOP,{},{}); Spring.GiveOrderToUnit(army[1],CMD.STOP,{},0)
  check(not A.GetForce(fid).members[army[1]],'manual unit command releases Officer membership')
  local status=A.GetOfficerStatus(fid); if status.operation then A.CancelOperation(status.operation.id) end
  Spring.GiveOrderToUnitArray(army,CMD.STOP,{},0)
  Spring.SelectUnitArray(cons); stage=7
 elseif stage==7 and elapsed>9 then
  local spot=WG.metalSpots and WG.metalSpots[1]
  if spot then
   check(A.ActivateLogisticsPreset('MEX2'),'Mex +2 native preset armed')
   local opts={coded=0}; local used=widgetHandler:CommandNotify(Spring.Utilities.CMD.AREA_MEX,{spot.x,Spring.GetGroundHeight(spot.x,spot.z),spot.z,60},opts)
   check(used and opts.alt and not opts.ctrl,'installed Mex handler consumed +2 modifiers')
  else check(false,'metal spots available') end
  stage=8
 elseif stage==8 and elapsed>9.3 then
  local mex,energy=0,0
  for _,id in ipairs(cons) do for _,q in ipairs(Spring.GetCommandQueue(id,-1) or {}) do if q.id<0 then local d=UnitDefs[-q.id]; if d and d.name=='staticmex' then mex=mex+1 elseif d and (d.name=='energysolar' or d.name=='energywind') then energy=energy+1 end end end end
  check(mex>=1 and energy>=2,'native build queue contains Mex and two generators: mex='..mex..' energy='..energy)
  Spring.GiveOrderToUnitArray(cons,CMD.STOP,{},0); A.SetPrivateTestingSession(false)
  report('core integration sequence finished'); stage=9
 elseif stage==9 and elapsed>11 then
  Spring.SelectUnitArray(army); A.SetFormationPreset('DOUBLE LINE'); Spring.SetCameraTarget(2200,Spring.GetGroundHeight(2200,3600),3600,0); stage=10
 elseif stage==10 and elapsed>12 then
  local index=Spring.GetCmdDescIndex(CMD.FIGHT); Spring.SetActiveCommand(index)
  local x,y=Spring.WorldToScreenCoords(1800,Spring.GetGroundHeight(1800,3600),3600); local x2,y2=Spring.WorldToScreenCoords(2600,Spring.GetGroundHeight(2600,3600),3600)
  local used=widgetHandler:MousePress(x,y,1); local owner=widgetHandler.mouseOwner
  check(used and owner and owner.whInfo.name=='Zero-K Command Layer','world Fight gesture captured before CustomFormations2')
  widgetHandler:MouseMove(x2,y2,x2-x,y2-y,1); widgetHandler:MouseRelease(x2,y2,1); stage=11
 elseif stage==11 and elapsed>13 then
  local q=Spring.GetCommandQueue(army[1],-1) or {}; check(#q>0,'world line dispatched native destination')
  Spring.SelectUnitArray(cons); stage=12
 elseif stage==12 and elapsed>14 then
  for _,kind in ipairs({'AREA_REPAIR','PERSISTENT_REPAIR','AREA_RECLAIM','PERSISTENT_RECLAIM'}) do
   local cmd=kind:find('REPAIR') and CMD.REPAIR or CMD.RECLAIM; local armed=A.ActivateLogisticsPreset(kind); local opts={ctrl=true,coded=CMD.OPT_CTRL}; local params={2200,0,2100,300}; local used=widgetHandler:CommandNotify(cmd,params,opts); if not used then Spring.GiveOrder(cmd,params,opts.coded) end
   check(armed and opts.alt==(kind:find('PERSISTENT')~=nil),'native '..kind..' modifier delivered (native Ctrl filtering retained)')
  end
  Spring.GiveOrderToUnitArray(cons,CMD.STOP,{},0); A.SetFormationPreset('OFF'); report('integration sequence finished'); stage=13; if revision and revision:find('exit') then Spring.SendCommands('quitforce') end
 end
end
