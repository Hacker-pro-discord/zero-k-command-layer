return function(C)
	local UI={tab='LOGISTICS',elapsed=0}
	local function button(parent,x,y,w,caption,tip,fn)
		return UI.ch.Button:New{parent=parent,x=x,y=y,width=w,height=34,caption=caption,tooltip=tip,OnClick={fn}}
	end
	function UI.build()
		if UI.body then UI.body:Dispose() end
		UI.body=UI.ch.Panel:New{parent=UI.window,x=0,y=46,width='100%',bottom=125,padding={0,0,0,0}}
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
			button(p,190,0,185,'RELEASE','Release selected units and cancel their pending authority.',function() C.registry.release(selected(),'PLAYER_OVERRIDE'); C.debug.log('RELEASE','Selected units released') end)
			button(p,0,42,185,'SET OBJECTIVE','Draw a line in the world; this does not issue orders.',function() UI.showObjectives() end)
			button(p,190,42,185,'ASK OFFICER','Request a tactical proposal and production advice.',function() if C.advisor then C.advisor.ask(C.registry.activeForce,true) end end)
			button(p,0,84,375,'LOCAL / PRIVATE TEST SESSION','Explicitly attest this is local/skirmish or private testing. Resets on reload. Autohost/public metadata stays locked.',function()
				C.officer.setSession(not C.settings.privateSession)
			end)
			button(p,0,126,185,'PREVIOUS FORCE','Select previous assigned-force record.',function() if C.officer.cycle then C.officer.cycle(-1) end end)
			button(p,190,126,185,'NEXT FORCE','Select next assigned-force record.',function() if C.officer.cycle then C.officer.cycle(1) end end)
			button(p,0,168,185,'CANCEL ACTION','Stop further Officer maintenance for active force.',function() local f=C.registry.forces[C.registry.activeForce]; if f and f.delegation and f.delegation.active then C.officer.setDelegated(f.id,false) elseif f and f.operation then C.officer.cancel(f.operation) end end)
			button(p,190,168,185,'RESUME','Explicitly resume suspended advice membership, never old approval.',function() if C.officer.resume then C.officer.resume(C.registry.activeForce) end end)
			button(p,0,210,185,'SHOW DETAILS','Read production advice and its limitations; no build commands.',function() UI.showAdvice() end)
			button(p,190,210,185,'DISMISS ADVICE','Dismiss the current production recommendation.',function() local f=C.registry.forces[C.registry.activeForce]; if f then f.advice=nil end end)
			button(p,0,252,375,'ASSIGN ALL MILITARY','Assign all your completed mobile military units now, including air/naval. Excludes builders and structures. No automatic recruitment; no orders.',function() C.officer.assignAll() end)
			for i,front in ipairs({'ADVANCE','HOLD','FLANK_LEFT','FLANK_RIGHT'}) do local directive=front; button(p,(i-1)*95,294,91,front:gsub('_',' '),'Set this force front approach. Cancels maintenance; next action still needs approval. Set an objective line for this front.',function() C.officer.setFront(C.registry.activeForce,directive) end) end
			button(p,0,338,185,'DELEGATE PRESSURE','Single-player only. Continuously scout, raid and push assigned units inside your objective corridor until stopped. This explicitly authorizes repeated orders.',function() C.officer.setDelegated(C.registry.activeForce,true) end)
			button(p,190,338,90,'STOP AI','Stop delegation and production; existing native orders remain.',function() C.productionControl.set(false); C.officer.setDelegated(C.registry.activeForce,false) end)
			button(p,285,338,90,'AI DETAILS','Read groups, observed evidence and current decision.',function() UI.showTactical() end)
			button(p,0,380,185,'REVIEW ARMY PUSH','Propose one Fight action by the entire assigned force. Draw an objective first. Approval required; delegation ends on approval.',function() C.advisor.ask(C.registry.activeForce,true,true) end)
			button(p,190,380,185,'AUTO ASSIGN: '..(C.settings.autoAssign and 'ON' or 'OFF'),'Opt in to assigning newly completed military units to the active force. Existing approvals never expand.',function() C.settings.autoAssign=not C.settings.autoAssign; UI.build() end)
			UI.lastDetail=nil
			UI.detail=UI.ch.TextBox:New{parent=p,x=4,y=420,width=367,height=40,text='Assigned adviser: no orders without approval.\nFactory and unit advice never changes production.'}
		end
	end
	function UI.initialize()
		if not WG.Chili then return false end; UI.ch=WG.Chili
		UI.window=UI.ch.Window:New{name='CommandLayerWindow',caption='ZERO-K COMMAND LAYER',parent=UI.ch.Screen0,x=C.settings.x,y=C.settings.y,width=410,height=680,draggable=true,resizable=false,padding={12,30,12,12}}
		for i,tab in ipairs({'LOGISTICS','FORMATIONS','OFFICER'}) do button(UI.window,(i-1)*127,0,122,tab,'Open '..tab:lower(),function() UI.tab=tab; UI.build() end) end
		UI.status=UI.ch.TextBox:New{parent=UI.window,x=0,bottom=0,width='100%',height=118,text='Officer ready.'}
		UI.build(); C.debug.log('LOAD','Officer / Chili controls loaded'); return true
	end
	function UI.update(dt)
		UI.elapsed=UI.elapsed+(dt or .03); if UI.elapsed<.25 then return end; UI.elapsed=0
		if UI.status then
			local text='Formation: '..C.settings.formation..' | '..(C.settings.privateSession and C.settings.mode or 'ARRIVAL (public)')..'\nSpacing: '..C.settings.spacing..' | Constructors: '..tostring(C.settings.constructors)..'\n'..C.debug.message
			if C.productionControl then text=text..'\nProduction: '..C.productionControl.status end
			if UI.lastStatus~=text then UI.status:SetText(text); UI.lastStatus=text end
		end
		if UI.tab=='OFFICER' and UI.detail then
			local f=C.registry.forces[C.registry.activeForce]; local text='No adviser force selected.'
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
			text='Force '..f.id..' | '..(d.active and 'DELEGATED' or 'STOPPED')..' | '..d.state..'\nRules: '..d.version..' (experimental)\n\n'
			for _,group in ipairs({'SCOUT','RAID','MAIN'}) do local n=0; for _,id in ipairs(d.groups[group]) do if f.members[id] and not f.suspended[id] and not d.blocked[id] and C.U.owned(id) then n=n+1 end end; local decision=d.decisions and d.decisions[group]; text=text..group..': '..n..' available units'..(decision and ' | '..decision.state..'\n'..decision.reason:sub(1,100) or '')..'\n' end
			text=text..'\nObserved contacts (radar stays UNKNOWN):\n'; local keys={}; for role in pairs(d.known or {}) do keys[#keys+1]=role end; table.sort(keys); for _,role in ipairs(keys) do text=text..role..': '..d.known[role]..'  ' end
			text=text..'\n\nCurrent decision: '..(d.reason or '')..'\n\nFinal line: hold under control. Manual orders release units. Recruitment follows AUTO ASSIGN.\nResearch rules: docs/TACTICAL_RESEARCH.md. No runtime web execution.'
		end
		if text~=UI.tacticalLast then UI.tacticalText:SetText(text); UI.tacticalLast=text end
	end
	function UI.showTactical()
		if UI.tacticalDialog then UI.tacticalDialog:Dispose() end
		UI.tacticalForce=C.registry.activeForce; UI.tacticalLast=nil
		UI.tacticalDialog=UI.ch.Window:New{name='CommandLayerTactical',caption='Tactical Officer - live decisions',parent=UI.ch.Screen0,x=450,y=100,width=520,height=570,draggable=true,resizable=false,padding={12,30,12,12}}
		UI.tacticalText=UI.ch.TextBox:New{parent=UI.tacticalDialog,x=0,y=0,width='100%',height=440,text=''}
		button(UI.tacticalDialog,0,470,185,'STOP THIS FORCE','Revoke sustained authority.',function() C.officer.setDelegated(UI.tacticalForce,false) end)
		button(UI.tacticalDialog,195,470,185,'CLOSE','Close details; keep current authority.',function() UI.tacticalDialog:Dispose(); UI.tacticalDialog=nil; UI.tacticalText=nil end)
		UI.updateTactical()
	end
	function UI.showObjectives()
		local f=C.registry.forces[C.registry.activeForce]; if not f then C.debug.log('OBJECTIVE','Assign an army first.'); return end
		if UI.objectiveDialog then UI.objectiveDialog:Dispose() end
		UI.objectiveDialog=UI.ch.Window:New{name='CommandLayerObjectives',caption='Objective / Force '..f.id,parent=UI.ch.Screen0,x=450,y=100,width=540,height=470,draggable=true,padding={12,30,12,12}}
		local w=UI.objectiveDialog
		UI.ch.TextBox:New{parent=w,x=0,y=0,width='100%',height=105,text='Choose a policy, then draw its territory/objective line. Autonomous policies start after drawing in single-player testing. All policies stay inside your corridor. Manual orders override control. No fog reveal or automatic map-wide victory search.'}
		local modes={'ADVICE ONLY','WIN OBJECTIVE','UTTER DESTRUCTION','SHOCK AND AWE'}
		local tips={'Draw a line and review individual proposals.','Balanced scout, raid and main advances; hold at the final line.','Commit all assigned military units together; no detached raids. Fight only within your corridor.','Faster 900-unit phases with Assault role zones; scout/raid support. This does not guarantee a breakthrough.'}
		for i,name in ipairs(modes) do local mode=name; button(w,0,105+(i-1)*40,490,name,tips[i],function()
			if mode~='ADVICE ONLY' and not C.U.delegationAllowed(C.settings) then C.debug.log('LOCKED','Autonomous objectives require single-player testing.'); return end
			UI.objectiveDialog:Dispose(); UI.objectiveDialog=nil; C.input.armObjective(f.id,mode~='ADVICE ONLY' and mode or nil)
		end) end
		button(w,0,275,490,'AUTO PRODUCTION: '..(C.productionControl.enabled and 'ON' or 'OFF'),'Opt in to existing idle factories for this force. One affordable unit per five seconds; manual factory commands release it. No factory construction.',function() C.productionControl.set(not C.productionControl.enabled); UI.showObjectives() end)
		button(w,0,315,240,'STOP PRODUCTION','Stop future queue additions; existing queues remain.',function() C.productionControl.set(false); UI.showObjectives() end)
		button(w,250,315,240,'CLOSE','Keep current settings and close.',function() UI.objectiveDialog:Dispose(); UI.objectiveDialog=nil end)
		UI.ch.TextBox:New{parent=w,x=0,y=360,width=490,height=60,text=C.productionControl.status}
	end
	function UI.showAdvice()
		local f=C.registry.forces[C.registry.activeForce]; if not f or not f.advice then return end
		if UI.adviceDialog then UI.adviceDialog:Dispose() end
		UI.adviceDialog=UI.ch.Window:New{name='CommandLayerAdvice',caption='Production advice - Force '..f.id,parent=UI.ch.Screen0,x=450,y=130,width=480,height=460,draggable=true,resizable=false,padding={12,30,12,12}}
		UI.ch.TextBox:New{parent=UI.adviceDialog,x=0,y=0,width='100%',height=350,text=f.advice}
		button(UI.adviceDialog,0,365,200,'DISMISS','No production changes.',function() f.advice=nil; UI.adviceDialog:Dispose(); UI.adviceDialog=nil end)
	end
	function UI.shutdown()
		if UI.objectiveDialog then UI.objectiveDialog:Dispose() end
		if UI.tacticalDialog then UI.tacticalDialog:Dispose() end
		if UI.adviceDialog then UI.adviceDialog:Dispose() end
		if UI.dialog then UI.dialog:Dispose() end
		if UI.window then C.settings.x=UI.window.x; C.settings.y=UI.window.y; UI.window:Dispose(); UI.window=nil end
	end
	return UI
end
