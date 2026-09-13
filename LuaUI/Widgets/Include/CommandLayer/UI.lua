return function(C)
	local UI={tab='LOGISTICS',elapsed=0}
	local function button(parent,x,y,w,caption,tip,fn)
		return UI.ch.Button:New{parent=parent,x=x,y=y,width=w,height=34,caption=caption,tooltip=tip,OnClick={fn}}
	end
	function UI.build()
		UI.controlState=tostring(C.settings.autoAssign)..':'..tostring(C.settings.privateSession)..':'..tostring(C.productionControl.enabled)
		if UI.body then UI.body:Dispose() end
		UI.body=UI.ch.Panel:New{parent=UI.window,x=0,y=46,width='100%',bottom=105,padding={0,0,0,0}}
		local p=UI.body
		if UI.tab=='LOGISTICS' then
			for i,count in ipairs({0,1,2,4}) do local kind='MEX'..count; button(p,((i-1)%2)*190,math.floor((i-1)/2)*40,185,count==0 and 'MEX ONLY' or 'MEX + '..count..' ENERGY','Native Area Mex. Drag region; Shift queues, Space inserts.',function() C.logistics.arm(kind) end) end
			for i,kind in ipairs({'AREA_REPAIR','PERSISTENT_REPAIR','AREA_RECLAIM','PERSISTENT_RECLAIM'}) do button(p,((i-1)%2)*190,100+math.floor((i-1)/2)*40,185,kind:gsub('_',' '),'Persistent waits for new targets. Ctrl retains native repair/reclaim filtering.',function() C.logistics.arm(kind) end) end
			UI.ch.TextBox:New{parent=p,x=4,y=205,width=365,height=140,text='Select constructors, choose a command, then drag its native area.\n\nEnergy buttons use Zero-K placement and terrain substitutions. Blocked structures may not be built.\n\nThese commands do not assign units to the Officer.'}
		elseif UI.tab=='FORMATIONS' then
			for i,name in ipairs(C.formations.names) do button(p,((i-1)%2)*190,math.floor((i-1)/2)*38,185,name,'Persistent preset for subsequent Move/Fight lines.',function() C.settings.formation=name; C.debug.log('FORMATION',name..' active; draw a movement or Fight line.') end) end
			button(p,0,198,375,'FORMATION OFF','Stop further maintenance; preserve native orders.',function() C.settings.formation='OFF'; for id in pairs(C.registry.operations) do C.officer.cancel(id) end end)
			for i,mode in ipairs({'STRICT','LOOSE','ARRIVAL'}) do button(p,(i-1)*127,240,122,mode,mode=='STRICT' and 'Position priority may interrupt kiting/dodging. Private test session only.' or 'Public matches always use arrival-only placement.',function() C.settings.mode=mode; C.debug.log('MODE',mode..' selected') end) end
			button(p,0,282,185,'SPACING -','Minimum slot separation in game units.',function() C.settings.spacing=math.max(32,C.settings.spacing-16) end)
			button(p,190,282,185,'SPACING +','Minimum slot separation in game units.',function() C.settings.spacing=math.min(256,C.settings.spacing+16) end)
			button(p,0,322,185,'CONSTRUCTORS','Toggle constructor inclusion; excluded by default.',function() C.settings.constructors=not C.settings.constructors end)
			button(p,190,322,185,'OVERLAYS','Toggle previews and assigned slots.',function() C.settings.overlays=not C.settings.overlays end)
		else
			local function selected() return Spring.GetSelectedUnits() end
			button(p,0,0,185,'ASSIGN TO OFFICER','Observe and suggest only. Assignment never moves units.',function() if C.officer.assign then C.officer.assign(selected()) end end)
			button(p,190,0,185,'RELEASE','Release selected units and cancel their pending authority.',function() C.officer.releaseUnits(selected(),'PLAYER_OVERRIDE'); C.debug.log('RELEASE','Selected units released') end)
			button(p,0,42,185,'SET OBJECTIVE','Draw a line in the world; this does not issue orders.',function() UI.showObjectives() end)
			button(p,190,42,185,'ASK OFFICER','Request a tactical proposal and production advice.',function() if C.advisor then C.advisor.ask(C.registry.activeForce,true) end end)
			button(p,0,84,375,'LOCAL / PRIVATE TEST SESSION','Explicitly attest this is local/skirmish or private testing. Resets on reload. Autohost/public metadata stays locked.',function()
				C.officer.setSession(not C.settings.privateSession); UI.build()
			end)
			button(p,0,126,185,'FACTORY / ECONOMY','Re-enroll factories and manage construction, air/sea and strategic weapons.',function() UI.showManagement() end)
			button(p,190,126,185,'NEXT FORCE','Select next assigned-force record.',function() if C.officer.cycle then C.officer.cycle(1) end end)
			button(p,0,168,185,'CANCEL ACTION','Stop further Officer maintenance for active force.',function() local f=C.registry.forces[C.registry.activeForce]; if f and f.delegation and f.delegation.active then C.officer.setDelegated(f.id,false) elseif f and f.operation then C.officer.cancel(f.operation) end end)
			button(p,190,168,185,'RESUME','Explicitly resume suspended advice membership, never old approval.',function() if C.officer.resume then C.officer.resume(C.registry.activeForce) end end)
			button(p,0,210,185,'SHOW DETAILS','Read production advice and its limitations; no build commands.',function() UI.showAdvice() end)
			button(p,190,210,185,'DISMISS ADVICE','Dismiss the current production recommendation.',function() local f=C.registry.forces[C.registry.activeForce]; if f then f.advice=nil end end)
			button(p,0,252,375,'ASSIGN ALL MILITARY','Assign all your completed mobile military units now, including air/naval. Excludes builders and structures. No orders until delegated; Auto Assign handles subsequent recruits.',function() C.officer.assignAll() end)
			for i,front in ipairs({'ADVANCE','HOLD','FLANK_LEFT','FLANK_RIGHT'}) do local directive=front; button(p,(i-1)*95,294,91,front:gsub('_',' '),'Set this force front approach. Cancels maintenance; next action still needs approval. Set an objective line for this front.',function() C.officer.setFront(C.registry.activeForce,directive) end) end
			button(p,0,338,185,'DELEGATE PRESSURE','Single-player only. Continuously scout, raid and push assigned units inside your objective corridor until stopped. This explicitly authorizes repeated orders.',function() C.officer.setDelegated(C.registry.activeForce,true) end)
			button(p,190,338,90,'STOP AI','Stop delegation and production; existing native orders remain.',function() C.productionControl.set(false); if C.recovery then C.recovery.stop() end; if C.arsenal then C.arsenal.stop() end; C.officer.setDelegated(C.registry.activeForce,false) end)
			button(p,285,338,90,'AI DETAILS','Read groups, observed evidence and current decision.',function() UI.showTactical() end)
			button(p,0,380,185,'REVIEW ARMY PUSH','Propose one Fight action by the entire assigned force. Draw an objective first. Approval required; delegation ends on approval.',function() C.advisor.ask(C.registry.activeForce,true,true) end)
			button(p,190,380,185,'AUTO ASSIGN: '..(C.settings.autoAssign and (C.U.assisted(C.settings) and 'ON' or 'WAIT') or 'OFF'),'Recruit existing unassigned and newly completed military units into a fixed receiving force. Manual releases stay released. Existing approvals never expand.',function() C.officer.setAutoAssign(not C.settings.autoAssign); UI.build() end)
			button(p,0,420,185,'PRODUCTION: '..(C.productionControl.enabled and 'ON' or 'OFF'),'Control existing idle factories. Requires local/private testing; works before your first military unit.',function() C.officer.factoryControl(C.productionControl.enabled and 'OFF' or 'ON'); UI.build() end)
			button(p,190,420,185,'WIN THE GAME','Single-player map-wide control: recruit, produce, search successive sectors and attack visible enemies. Enabled automatically by default. STOP AI cancels for this session.',function() C.startup.start(); UI.build() end)
			UI.lastDetail=nil
			UI.detail=UI.ch.TextBox:New{parent=p,x=4,y=458,width=367,height=40,text='Assigned adviser: no orders without approval.\nFactory and unit advice never changes production.'}
		end
	end
	function UI.showManagement()
		if UI.management then UI.management:Dispose() end
		local p=UI.ch.Window:New{name='CommandLayerManagement',caption='Officer control and logistics',parent=UI.ch.Screen0,x=440,y=80,width=560,height=690,draggable=true,resizable=false,padding={12,30,12,12}}; UI.management=p
		button(p,0,0,510,'RE-ENROLL SELECTED FACTORIES','Explicitly return selected factories to AI production. Busy queues stay intact. Other manual exclusions stay excluded.',function() C.officer.factoryControl('ENROLL'); UI.showManagement() end)
		button(p,0,45,250,'PRODUCTION: '..(C.productionControl.enabled and 'ON' or 'OFF'),'Toggle automatic production; existing queues remain.',function() C.officer.factoryControl(C.productionControl.enabled and 'OFF' or 'ON'); UI.showManagement() end)
		button(p,260,45,250,'RELEASE SELECTED FACTORIES','Keep native queues; prevent future AI additions until explicitly re-enrolled.',function() C.officer.factoryControl('RELEASE'); UI.showManagement() end)
		if C.recovery then
			button(p,0,92,250,'ADD SELECTED BUILDERS','Enroll selected constructors for recovery and requested construction. Manual orders release them again.',function() C.recovery.enroll(Spring.GetSelectedUnits()); UI.showManagement() end)
			button(p,260,92,250,'ADD BUILD REQUEST','Select constructors, click this, then choose and place one native build command. The AI receives that explicit build request; Escape cancels.',function() C.recovery.armed=true; C.debug.log('BUILD REQUEST','Choose a building in the native build menu and place it. Escape cancels.'); p:Dispose(); UI.management=nil end)
			button(p,0,136,250,'CANCEL BUILD REQUESTS','Cancel pending reconstruction and manual requests. Native orders already issued remain.',function() C.recovery.cancelRequests(); UI.showManagement() end)
			button(p,260,136,250,'STOP RECOVERY','Release builders from automation; existing native queues remain.',function() C.recovery.stop(); UI.showManagement() end)
		end
		if C.arsenal then
			button(p,0,180,250,'ARM SELECTED LAUNCHERS','Authorize automatic native ammunition production and visual-target fire for selected launchers. Mobile launchers leave army movement control. Manual orders release them.',function() C.arsenal.enroll(Spring.GetSelectedUnits()); UI.showManagement() end)
			button(p,260,180,250,'STOP STRATEGIC FIRE','Remove only AI attack orders; retain native ammunition queues.',function() C.arsenal.stop(); UI.showManagement() end)
		end
		if C.economy then
			button(p,0,540,250,C.economy.enabled and 'ECONOMY: ON' or 'ECONOMY: OFF','Toggle ongoing automatic expansion in this local session. Manual builder orders always win.',function() C.settings.autoEconomy=not C.economy.enabled; if C.settings.autoEconomy then C.economy.start() else C.economy.stop() end; UI.showManagement() end)
			button(p,260,540,250,'ADD ECONOMY BUILDERS','Return selected constructors to expansion control.',function() C.economy.enroll(Spring.GetSelectedUnits()); UI.showManagement() end)
		end
		local text=(C.economy and ('Economy: '..C.economy.status..'\n') or '')..(C.arsenal and C.arsenal.status..'\n' or '')..C.productionControl.status..(C.recovery and ('\n'..C.recovery.status) or '')
		if C.enemyModel then local model=C.enemyModel.snapshot(); text=text..'\n\nRolling visual intel (half-life '..model.halfLife..'s):'; local keys={}; for role in pairs(model.roles) do keys[#keys+1]=role end; table.sort(keys); for _,role in ipairs(keys) do text=text..'\n'..role..': '..string.format('%.1f',model.roles[role])..' weighted sightings' end; text=text..'\nUnknown radar contacts: '..model.unknown..'\nOld sightings decay; this is not a current hidden-army count.' end
		button(p,0,228,250,'DEFENCE / SPECIAL BUILDS','Select builders; request any native Defence or Special building, or toggle automatic structures.',function() UI.showStructures('DEFENCE',1) end)
		button(p,260,228,250,'AUTO STRUCTURES: '..(C.settings.autoStructures and 'ON' or 'OFF'),'Automatic affordable local defenses, radar and support. Existing queues remain.',function() C.settings.autoStructures=not C.settings.autoStructures; UI.showManagement() end)
		UI.ch.TextBox:New{parent=p,x=0,y=274,width=510,height=255,text=text}
		button(p,0,590,250,'REFRESH','Refresh current control and intel information.',function() UI.showManagement() end)
		button(p,260,590,250,'CLOSE','Keep current controls.',function() p:Dispose(); UI.management=nil end)
	end
	function UI.showStructures(category,page)
		if not C.structurePlanning then return end
		if UI.structures then UI.structures:Dispose() end
		local w=UI.ch.Window:New{name='CommandLayerStructures',caption='Officer construction: '..category,parent=UI.ch.Screen0,x=440,y=70,width=560,height=580,draggable=true,padding={12,30,12,12}}; UI.structures=w
		button(w,0,0,250,'DEFENCE','Native Defence build options of selected builders.',function() UI.showStructures('DEFENCE',1) end)
		button(w,260,0,250,'SPECIAL','Native Special buildings; terraform remains native manual control.',function() UI.showStructures('SPECIAL',1) end)
		local list=C.structurePlanning.catalog(Spring.GetSelectedUnits(),category)
		for i=(page-1)*10+1,math.min(#list,page*10) do local def=list[i]; local d=UnitDefs[def]
			button(w,0,45+(i-(page-1)*10-1)*38,510,(d.humanName or d.name)..' | '..(d.metalCost or 0)..' metal','Place a native building ghost. Adds a specific Officer construction request; launcher firing is separately controlled.',function() if C.structurePlanning.arm(def) then w:Dispose(); UI.structures=nil end end)
		end
		UI.ch.TextBox:New{parent=w,x=0,y=433,width=510,height=42,text=#list==0 and 'Select constructors with these native build options, then reopen this menu.' or 'Manual orders override builders. Strategic launchers require separate arming. '..C.structurePlanning.status}
		button(w,0,480,160,'PREVIOUS','Previous page.',function() UI.showStructures(category,math.max(1,page-1)) end)
		button(w,170,480,160,'NEXT','Next page.',function() UI.showStructures(category,math.min(math.max(1,math.ceil(#list/10)),page+1)) end)
		button(w,340,480,160,'CLOSE','Close without ordering.',function() w:Dispose(); UI.structures=nil end)
	end
	function UI.initialize()
		if not WG.Chili then return false end; UI.ch=WG.Chili
		UI.window=UI.ch.Window:New{name='CommandLayerWindow',caption='ZERO-K COMMAND LAYER',parent=UI.ch.Screen0,x=C.settings.x,y=C.settings.y,width=410,height=700,draggable=true,resizable=false,padding={12,30,12,12}}
		for i,tab in ipairs({'LOGISTICS','FORMATIONS','OFFICER'}) do button(UI.window,(i-1)*127,0,122,tab,'Open '..tab:lower(),function() UI.tab=tab; UI.build() end) end
		UI.status=UI.ch.TextBox:New{parent=UI.window,x=0,bottom=0,width='100%',height=98,text='Officer ready.'}
		UI.build(); C.debug.log('LOAD','Officer / Chili controls loaded'); return true
	end
	function UI.update(dt)
		UI.elapsed=UI.elapsed+(dt or .03); if UI.elapsed<.25 then return end; UI.elapsed=0
		local controls=tostring(C.settings.autoAssign)..':'..tostring(C.settings.privateSession)..':'..tostring(C.productionControl.enabled)
		if UI.tab=='OFFICER' and controls~=UI.controlState then UI.build() end
		if UI.status then
			local text=(C.startup and C.startup.enabled and 'AI: MAP-WIDE CONTROL' or 'Formation: '..C.settings.formation)..' | '..(C.settings.privateSession and C.settings.mode or 'ARRIVAL (public)')..'\nSpacing: '..C.settings.spacing..' | Constructors: '..tostring(C.settings.constructors)..'\n'..C.debug.message
			if C.productionControl then text=text..'\nProduction: '..C.productionControl.status end
			if UI.lastStatus~=text then UI.status:SetText(text); UI.lastStatus=text end
		end
		if UI.tab=='OFFICER' and UI.detail then
			local f=C.registry.forces[C.registry.activeForce]; local text=C.settings.autoAssign and (C.U.assisted(C.settings) and 'Waiting for receiving force.' or 'AUTO ASSIGN waiting: enable LOCAL / PRIVATE TEST SESSION.') or 'No force yet. Enable local testing, then START MAP CONTROL.'
			if f then local n=0; for _ in pairs(f.members) do n=n+1 end; text='Force '..f.id..' ['..(f.objectiveMode or 'ADVICE')..'] | '..n..' units | '..f.status..' | '..(f.front or 'ADVANCE')..'\n'..(f.advice and 'Production recommendation available. SHOW DETAILS to read evidence, cost and alternatives.' or 'Set an objective or ask for a reform proposal.') end
			if text~=UI.lastDetail then UI.detail:SetText(text); UI.lastDetail=text end
		end
		if UI.tacticalText then UI.updateTactical() end
		if C.proposals then UI.showProposal(C.proposals.firstOffered()) end
	end
	function UI.showProposal(p)
		local id=p and (p.id..':'..p.state)
		if id==UI.proposalID then return end
		if UI.dialog then UI.dialog:Dispose(); UI.dialog=nil end; UI.proposalID=id
		if not p then return end
		UI.dialog=UI.ch.Window:New{name='CommandLayerProposal',caption='Officer - Force '..p.forceID,parent=UI.ch.Screen0,x=450,y=160,width=500,height=540,draggable=true,resizable=false,padding={12,30,12,12}}
		UI.ch.TextBox:New{parent=UI.dialog,x=0,y=0,width='100%',height=415,text=(p.state=='OFFERED' and '' or p.state..' - this brief is no longer executable. Refresh to review a new plan.\n\n')..p.summary}
		button(UI.dialog,0,450,130,p.state=='OFFERED' and 'APPROVE' or 'REFRESH','Approve one displayed action; outdated briefs require a fresh review.',function() if p.state=='OFFERED' then C.proposals.approve(p.id,p.revision) else C.advisor.ask(p.forceID,true,p.wholeArmy) end end)
		button(UI.dialog,138,450,120,'DISMISS','No orders. Decline and suppress this suggestion temporarily.',function() C.proposals.decline(p.id); C.proposals.dismiss(p.id) end)
		button(UI.dialog,266,450,140,'SHOW PLAN','Preview destinations; no orders.',function() C.input.preview=p.plan end)
	end
	function UI.updateTactical()
		local f=C.registry.forces[UI.tacticalForce]; local d=f and f.delegation
		local text='No delegated operation for this force.'
		if d then
			text='Force '..f.id..' | '..(d.active and 'DELEGATED' or 'STOPPED')..' | '..d.state..'\nTactic: '..(f.tactic or 'CONTINUOUS PRESSURE')..' | Wave '..(d.waveNumber or 1)..'\nRules: '..d.version..' (experimental)\n\n'
			if d.strategy then text=text..'Revision '..d.strategy.revision..': '..d.strategy.formation..', step '..math.floor(d.strategy.step)..', spacing '..math.floor(d.strategy.spacing)..', lane '..(d.strategy.side<0 and 'left' or 'right')..'\n' end
			if d.recovery and d.recovery.evacuate then text=text..'Retreat: '..d.recovery.injured..' injured; '..#d.recovery.evacuate..' first wave; '..#d.recovery.cover..' temporary cover\n' end
			for _,group in ipairs({'SCOUT','RAID','MAIN','RESERVE','DEFENSE','AIR','SEA'}) do local n=0; for _,id in ipairs(d.groups[group] or {}) do if f.members[id] and not f.suspended[id] and not d.blocked[id] and C.U.owned(id) then n=n+1 end end; local decision=d.decisions and d.decisions[group]; text=text..group..': '..n..' available units'..(decision and ' | '..decision.state..'\n'..decision.reason:sub(1,100) or '')..'\n' end
			text=text..'\nObserved contacts (radar stays UNKNOWN):\n'; local keys={}; for role in pairs(d.known or {}) do keys[#keys+1]=role end; table.sort(keys); for _,role in ipairs(keys) do text=text..role..': '..d.known[role]..'  ' end
			text=text..'\nTarget priority: '..(f.targetReason or 'Native target selection')
			text=text..'\n\nCurrent decision: '..(d.reason or '')..'\n\nMap Control searches the whole map; drawn-line mode holds at its objective. Manual orders release units. Recruitment follows AUTO ASSIGN.\nResearch rules: docs/TACTICAL_RESEARCH.md. No runtime web execution.'
		end
		if text~=UI.tacticalLast then UI.tacticalText:SetText(text); UI.tacticalLast=text end
	end
	function UI.showTactical()
		if UI.tacticalDialog then UI.tacticalDialog:Dispose() end
		UI.tacticalForce=C.registry.activeForce; UI.tacticalLast=nil
		UI.tacticalDialog=UI.ch.Window:New{name='CommandLayerTactical',caption='Tactical Officer - live decisions',parent=UI.ch.Screen0,x=450,y=100,width=560,height=690,draggable=true,resizable=false,padding={12,30,12,12}}
		UI.tacticalText=UI.ch.TextBox:New{parent=UI.tacticalDialog,x=0,y=0,width='100%',height=550,text=''}
		button(UI.tacticalDialog,0,590,185,'STOP THIS FORCE','Revoke sustained authority.',function() C.officer.setDelegated(UI.tacticalForce,false) end)
		button(UI.tacticalDialog,195,590,185,'CLOSE','Close details; keep current authority.',function() UI.tacticalDialog:Dispose(); UI.tacticalDialog=nil; UI.tacticalText=nil end)
		UI.updateTactical()
	end
	function UI.showObjectives()
		local f=C.registry.forces[C.registry.activeForce]; if not f then C.debug.log('OBJECTIVE','Assign an army first.'); return end
		if UI.objectiveDialog then UI.objectiveDialog:Dispose() end
		UI.objectiveDialog=UI.ch.Window:New{name='CommandLayerObjectives',caption='Objective / Force '..f.id,parent=UI.ch.Screen0,x=450,y=100,width=540,height=560,draggable=true,padding={12,30,12,12}}
		local w=UI.objectiveDialog
		UI.ch.TextBox:New{parent=w,x=0,y=0,width='100%',height=105,text='WIN THE GAME starts map-wide scouting, expansion and observed-enemy attacks. Other objectives use a drawn corridor. Wave tactics batches follow-up troops every 12 seconds; manual orders always override.'}
		local modes={'WIN THE GAME','ADVICE ONLY','WIN OBJECTIVE','UTTER DESTRUCTION','SHOCK AND AWE'}
		local tips={'Start map-wide control using legitimate observations; no objective line required.','Draw a line and review individual proposals.','Balanced scout, raid and main advances; hold at the final line.','Commit all assigned military units together; no detached raids. Fight only within your corridor.','Faster 900-unit phases with Assault role zones; scout/raid support. This does not guarantee a breakthrough.'}
		for i,name in ipairs(modes) do local mode=name; button(w,0,105+(i-1)*40,490,name,tips[i],function()
			if mode~='ADVICE ONLY' and not C.U.delegationAllowed(C.settings) then C.debug.log('LOCKED','Autonomous objectives require single-player testing.'); return end
			UI.objectiveDialog:Dispose(); UI.objectiveDialog=nil; if mode=='WIN THE GAME' then C.startup.start(); return end; C.input.armObjective(f.id,mode~='ADVICE ONLY' and mode or nil)
		end) end
		button(w,0,315,490,'AUTO PRODUCTION: '..(C.productionControl.enabled and 'ON' or 'OFF'),'Opt in to existing idle factories for this force. One affordable unit per idle factory per five seconds; manual factory commands release it. No factory construction.',function() C.officer.factoryControl(C.productionControl.enabled and 'OFF' or 'ON'); UI.showObjectives() end)
		button(w,0,355,240,'STOP PRODUCTION','Stop future queue additions; existing queues remain.',function() C.productionControl.set(false); UI.showObjectives() end)
		button(w,250,355,240,'CLOSE','Keep current settings and close.',function() UI.objectiveDialog:Dispose(); UI.objectiveDialog=nil end)
		button(w,0,395,490,'TACTIC: '..(f.tactic or C.settings.defaultTactic),'Choose wave batches or continuous reinforcement; applies to this force and future startup.',function() C.officer.setTactic((f.tactic or C.settings.defaultTactic)=='WAVE TACTICS' and 'CONTINUOUS PRESSURE' or 'WAVE TACTICS'); UI.showObjectives() end)
		UI.ch.TextBox:New{parent=w,x=0,y=440,width=490,height=60,text=C.productionControl.status}
	end
	function UI.showAdvice()
		local f=C.registry.forces[C.registry.activeForce]; if not f or not f.advice then return end
		if UI.adviceDialog then UI.adviceDialog:Dispose() end
		UI.adviceDialog=UI.ch.Window:New{name='CommandLayerAdvice',caption='Production advice - Force '..f.id,parent=UI.ch.Screen0,x=450,y=130,width=480,height=460,draggable=true,resizable=false,padding={12,30,12,12}}
		UI.ch.TextBox:New{parent=UI.adviceDialog,x=0,y=0,width='100%',height=350,text=f.advice}
		button(UI.adviceDialog,0,365,200,'DISMISS','No production changes.',function() f.advice=nil; UI.adviceDialog:Dispose(); UI.adviceDialog=nil end)
	end
	function UI.shutdown() if UI.structures then UI.structures:Dispose() end; if UI.management then UI.management:Dispose() end;
		if UI.objectiveDialog then UI.objectiveDialog:Dispose() end
		if UI.tacticalDialog then UI.tacticalDialog:Dispose() end
		if UI.adviceDialog then UI.adviceDialog:Dispose() end
		if UI.dialog then UI.dialog:Dispose() end
		if UI.window then C.settings.x=UI.window.x; C.settings.y=UI.window.y; UI.window:Dispose(); UI.window=nil end
	end
	return UI
end
