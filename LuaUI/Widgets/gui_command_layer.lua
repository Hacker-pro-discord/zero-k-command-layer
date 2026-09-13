function widget:GetInfo()
	return {name='Zero-K Command Layer',desc='Officer-centered logistics, formations and approved tactical assistance',author='Command Layer contributors',license='GPL v2 or later',layer=-1339,enabled=true,handler=true}
end
local root='LuaUI/Widgets/Include/CommandLayer/'
local function module(name) return VFS.Include(root..name..'.lua',nil,VFS.RAW_FIRST) end
local U=module('Util')
local C={U=U,settings=module('Settings')(U),debug=module('Debug')(U)}
local ready=false
options_path='Settings/Interface/Command Layer'
options={}
for _,key in ipairs({'spacing','rankGap','supportDepth','skirmDepth','artilleryDepth'}) do
	local k=key; options[k]={name=k,type='number',value=C.settings[k],min=32,max=800,step=16,OnChange=function(self) C.settings[k]=self.value end}
end
options.toggle={name='Toggle formation mode',type='button',OnChange=function() C.settings.formation=C.settings.formation=='OFF' and 'LINE' or 'OFF'; if C.settings.formation=='OFF' and C.officer then C.officer.cancelAll() end end}
options.stop={name='Cancel Officer operations',type='button',OnChange=function() if C.officer then for id in pairs(C.registry.operations) do C.officer.cancel(id) end end end}
for _,shape in ipairs({'LINE','DOUBLE LINE','TRIPLE LINE','COLUMN','WEDGE','ECHELON LEFT','ECHELON RIGHT','BOX','SCREEN','ASSAULT'}) do
	local name=shape; options['formation_'..name:gsub(' ','_')]={name='Formation: '..name,type='button',OnChange=function() C.settings.formation=name end}
end
for _,kind in ipairs({'MEX0','MEX1','MEX2','MEX4','AREA_REPAIR','PERSISTENT_REPAIR','AREA_RECLAIM','PERSISTENT_RECLAIM'}) do
	local k=kind; options['logistics_'..k]={name=k:gsub('_',' '),type='button',OnChange=function() if C.logistics then C.logistics.arm(k) end end}
end
options.assign={name='Assign selected army to Officer',type='button',OnChange=function() if C.officer then C.officer.assign(Spring.GetSelectedUnits()) end end}
options.proposalLifetime={name='Officer approval lifetime (game seconds)',type='number',value=60,min=30,max=180,step=15,OnChange=function(self) C.settings.proposalLifetime=self.value end}
options.suggestionInterval={name='Officer suggestion interval (game seconds)',type='number',value=10,min=5,max=60,step=5,OnChange=function(self) C.settings.suggestionInterval=self.value end}
options.autoEconomy={name='Automatic economic expansion in local single-player',type='bool',value=true,OnChange=function(self) C.settings.autoEconomy=self.value; if C.economy then if self.value then C.economy.start() else C.economy.stop() end end end}
options.unitMatchups={name='Unit-by-unit counter matrix (unfinished draft)',type='bool',value=true,OnChange=function(self) C.settings.unitMatchups=self.value end}
options.intelHalfLife={name='Enemy intel half-life (game seconds)',type='number',value=90,min=30,max=300,step=15,OnChange=function(self) C.settings.intelHalfLife=self.value end}
options.reservePercent={name='Reserve combat value (%)',type='number',value=20,min=0,max=40,step=5,OnChange=function(self) C.settings.reservePercent=self.value end}
options.autoPlay={name='Automatically start map-control AI in local single-player',type='bool',value=true,OnChange=function(self) C.settings.autoPlay=self.value; if not self.value and C.startup then C.startup.stop(); C.productionControl.set(false); C.officer.cancelAll() end end}
options.assign_all={name='Assign all military to Officer',type='button',OnChange=function() if C.officer then C.officer.assignAll() end end}
options.ask={name='Ask Officer',type='button',OnChange=function() if C.advisor then C.advisor.ask(C.registry.activeForce,true) end end}
options.objective={name='Set Officer objective line',type='button',OnChange=function() if C.input then C.input.armObjective() end end}
options.suspend={name='Manual override suspends membership until Resume',type='bool',value=false,OnChange=function(self) C.settings.override=self.value and 'suspend' or 'release' end}
function widget:SetConfigData(data) C.settings.load(data); options.suspend.value=C.settings.override=='suspend'; options.autoPlay.value=C.settings.autoPlay; options.autoEconomy.value=C.settings.autoEconomy; options.unitMatchups.value=C.settings.unitMatchups; for k,o in pairs(options) do if o.type=='number' then o.value=C.settings[k] end end end
function widget:GetConfigData()
	if C.ui and C.ui.window then C.settings.x=C.ui.window.x; C.settings.y=C.ui.window.y end
	return C.settings.save()
end
function widget:Initialize()
	local disabled=Spring.GetModOptions().disable_local_widgets
	if disabled and disabled~='0' and disabled~=0 then widgetHandler:RemoveWidget(self); return end
	C.logistics=module('Logistics')(C)
	C.classify=module('UnitClassification')(C); C.registry=module('ForceRegistry')(C); C.formations=module('Formations')(C); C.orders=module('Orders')(C); C.officer=module('Officer')(C); C.input=module('Input')(C); C.observations=module('Observations')(C); C.proposals=module('ProposalService')(C); C.advisor=module('TacticalAdvisor')(C); C.production=module('ProductionAdvisor')(C)
	C.economy=module('Economy')(C); C.arsenal=module('Arsenal')(C); C.recovery=module('Recovery')(C); C.matchups=module('UnitMatchups')(C,module('CounterMatrixData')); C.enemyModel=module('EnemyModel')(C); C.productionControl=module('ProductionController')(C); C.startup=module('Startup')(C); C.mapControl=module('MapControl')(C)
	C.rules=module('TacticalRules')(C); C.domains=module('Domains')(C); C.retreatPriority=module('RetreatPriority')(C); C.routing=module('Routing')(C); C.defense=module('Defense')(C); C.tactical=module('TacticalController')(C)
	C.ui=module('UI')(C); ready=C.ui.initialize()
	WG.CommandLayer={version=1,SetEconomyFactory=function(name) return C.economy.setFactory(name) end,SetAutoEconomy=function(on) C.settings.autoEconomy=on==true; if on then return C.economy.start() else C.economy.stop() end end,GetEconomyAutomationStatus=function() return {enabled=C.economy.enabled,status=C.economy.status} end,EnrollEconomyBuilders=function(ids) return C.economy.enroll(ids) end,EnrollLaunchers=function(ids) return C.arsenal.enroll(ids) end,StopStrategicFire=function() C.arsenal.stop() end,GetStrategicFireStatus=function() return C.arsenal.status end,SetFormationPreset=C.officer.setFormation,SetPrivateTestingSession=C.officer.setSession,ActivateLogisticsPreset=C.logistics.arm,SubmitPlayerIntent=C.officer.submit,IssueFormationMove=C.officer.submit,CancelOperation=C.officer.cancel,GetSelectedForce=function() return C.classify.filter(Spring.GetSelectedUnits()) end,ClassifyForce=C.classify.force,ApplyFormation=C.formations.plan,AskOfficer=function(id) return C.advisor.ask(id,true) end,AssignAdvisedForce=C.officer.assign,AssignAllMilitary=C.officer.assignAll,ReviewArmyPush=function(id) return C.advisor.ask(id,true,true) end,GetProductionStatus=function() return {enabled=C.productionControl.enabled,forceID=C.productionControl.forceID,message=C.productionControl.status} end,EnrollBuilders=function(ids) return C.recovery.enroll(ids) end,RequestConstruction=function(def,p,facing,ids) return C.recovery.request(def,p,facing,ids) end,GetRecoveryStatus=function() return C.recovery.status end,EnrollFactories=function(ids) return C.productionControl.enroll(ids) end,GetEnemyCompositionModel=function() return C.enemyModel.snapshot() end,SetAutoProduction=function(enabled) return C.productionControl.set(enabled) end,SetAutomaticMapControl=function(enabled) C.settings.autoPlay=enabled==true; if not enabled then C.startup.stop(); C.productionControl.set(false); C.officer.cancelAll() end end,StartAutonomous=C.startup.start,SetAutoAssign=C.officer.setAutoAssign,SetFront=C.officer.setFront,SetDelegatedControl=C.officer.setDelegated,SetObjective=C.officer.objective,ReleaseUnits=C.officer.releaseUnits,ApproveProposal=C.proposals.approve,DeclineProposal=C.proposals.decline,GetForce=function(id) return C.U.copy(C.registry.forces[id]) end,GetProposals=function(id) local list={}; for _,p in pairs(C.proposals.items) do if not id or p.forceID==id then list[#list+1]=C.U.copy(p) end end; return list end,GetVisibleBattleState=C.observations.snapshot,GetEconomyState=C.observations.economy,GetKnownEnemyComposition=function(p,r) return C.observations.snapshot(p,r).composition end,GetKnownThreats=function(p,r) return C.observations.snapshot(p,r).contacts end,GetAvailableConstructors=function() local ids={}; if C.U.live() then for _,id in ipairs(Spring.GetTeamUnits(Spring.GetMyTeamID())) do if C.classify.definition(Spring.GetUnitDefID(id)).builder then ids[#ids+1]=id end end end; return ids end,GetOfficerStatus=function(id) local f=C.registry.forces[id]; local op=f and f.operation and C.registry.operations[f.operation]; return {message=C.debug.message,state=op and op.active and op.state or f and f.status or 'IDLE',operation=C.U.copy(op),events=C.U.copy(C.debug.events)} end}
end
function widget:CommandNotify(id,params,opts)
	if C.recovery and C.recovery.armed and id<0 and #params>=3 and not C.orders.sending then C.recovery.armed=nil; return C.recovery.request(-id,{params[1],params[2],params[3]},params[4] or 0,Spring.GetSelectedUnits()) end
	if C.recovery and not C.orders.sending and id==CMD.RECLAIM and #params==1 then C.recovery.forget(params[1]) end
	if C.registry and not C.orders.sending then for _,unit in ipairs(Spring.GetSelectedUnits()) do if C.productionControl then C.productionControl.release(unit) end; if C.recovery then C.recovery.release(unit) end; if C.economy then C.economy.release(unit) end; if C.arsenal then C.arsenal.release(unit) end end; C.registry.release(Spring.GetSelectedUnits(),'PLAYER_OVERRIDE') end
	if C.logistics then C.logistics.notify(id,params,opts) end; return false
end
function widget:UnitCommandNotify(id) if C.registry and not C.orders.sending then if C.productionControl then C.productionControl.release(id) end; if C.recovery then C.recovery.release(id) end; if C.economy then C.economy.release(id) end; if C.arsenal then C.arsenal.release(id) end; C.registry.release({id},'PLAYER_OVERRIDE') end; return false end
function widget:UnitCommand(id,def,team,cmd,params,opts,tag,player,fromSynced,fromLua)
	local ours=C.orders and C.orders.event(id,cmd,params,fromSynced)
	if ours and C.arsenal then C.arsenal.issued(id,cmd,params,tag) end
	local nativeStockpile=fromLua and cmd==CMD.STOCKPILE and C.arsenal and C.arsenal.enrolled[id]
	if C.orders and not ours and not nativeStockpile then if C.productionControl then C.productionControl.release(id) end; if C.recovery then C.recovery.release(id) end; if C.economy then C.economy.release(id) end; if C.arsenal then C.arsenal.release(id) end; C.registry.release({id},'EXTERNAL_ORDER') end
end
function widget:MousePress(x,y,b) return C.input and C.input.press(x,y,b) end
function widget:MouseMove(x,y) if C.input then C.input.move(x,y) end end
function widget:MouseRelease(x,y,b) return C.input and C.input.release(x,y,b) end
function widget:DrawWorld() if C.input then C.input.draw() end end
function widget:KeyPress(key) if key==27 then if C.recovery then C.recovery.armed=nil end; if C.input then C.input.drag=nil; C.input.objective=nil end; if C.logistics then C.logistics.pending=nil end end end
function widget:Update(dt) if not ready and C.ui then ready=C.ui.initialize() end; if ready then C.logistics.update(); C.observations.update(); C.enemyModel.update(); C.startup.boot(); C.startup.update(); C.recovery.update(); C.economy.update(); C.arsenal.update(); C.officer.update(); C.proposals.update(); C.advisor.update(); C.tactical.update(); C.productionControl.update(); C.ui.update(dt) end end
function widget:UnitCreated(id,def,team,builder) if C.registry and C.U.owned(id) then C.registry.born(id) end; if C.productionControl then C.productionControl.createdUnit(id,builder) end end
function widget:UnitFinished(id)
	if C.officer then C.officer.autoAssign(id,C.productionControl and C.productionControl.created[id]) end
	if C.productionControl then C.productionControl.created[id]=nil end
end
function widget:UnitDestroyed(id) if C.economy then C.economy.release(id) end; if C.arsenal then C.arsenal.release(id) end; if C.enemyModel then C.enemyModel.destroyed(id) end; if C.recovery then C.recovery.destroyed(id) end; if C.registry then C.registry.release({id},'UNIT_LOST') end end
function widget:UnitTaken(id) if C.economy then C.economy.release(id) end; if C.arsenal then C.arsenal.release(id) end; if C.recovery then C.recovery.forget(id); C.recovery.release(id) end; if C.registry then C.registry.release({id},'TRANSFERRED') end end
function widget:PlayerChanged() if C.officer and not C.U.live() then C.officer.setSession(false); C.observations.update() end end
function widget:Shutdown() if C.economy then C.economy.stop() end; if C.arsenal then C.arsenal.stop() end; if C.productionControl then C.productionControl.set(false) end; if C.officer then C.officer.cancelAll() end; if C.ui then C.ui.shutdown() end; WG.CommandLayer=nil end
