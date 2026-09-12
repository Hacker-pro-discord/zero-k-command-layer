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
			button(p,0,42,185,'SET OBJECTIVE','Draw a line in the world; this does not issue orders.',function() if C.input.armObjective then C.input.armObjective() end end)
			button(p,190,42,185,'ASK OFFICER','Request a tactical proposal and production advice.',function() if C.advisor then C.advisor.ask(C.registry.activeForce,true) end end)
			button(p,0,84,375,'LOCAL / PRIVATE TEST SESSION','Explicitly attest this is local/skirmish or private testing. Resets on reload. Autohost/public metadata stays locked.',function()
				local m=Spring.GetModOptions(); if m.sendspringiedata and m.sendspringiedata~='0' and m.sendspringiedata~=0 then C.debug.log('LOCKED','Assisted testing is locked for autohost matches.'); return end
				C.settings.privateSession=not C.settings.privateSession; C.debug.log('SESSION',C.settings.privateSession and 'Local/private testing enabled for this session.' or 'Assisted testing disabled.'); if not C.settings.privateSession and C.officer.cancelAll then C.officer.cancelAll() end
			end)
			button(p,0,126,185,'PREVIOUS FORCE','Select previous assigned-force record.',function() if C.officer.cycle then C.officer.cycle(-1) end end)
			button(p,190,126,185,'NEXT FORCE','Select next assigned-force record.',function() if C.officer.cycle then C.officer.cycle(1) end end)
			button(p,0,168,185,'CANCEL ACTION','Stop further Officer maintenance for active force.',function() local f=C.registry.forces[C.registry.activeForce]; if f and f.operation then C.officer.cancel(f.operation) end end)
			button(p,190,168,185,'RESUME','Explicitly resume suspended advice membership, never old approval.',function() if C.officer.resume then C.officer.resume(C.registry.activeForce) end end)
			UI.detail=UI.ch.TextBox:New{parent=p,x=4,y=218,width=367,height=170,text='Assigned adviser: no orders without approval.\nFactory and unit advice never changes production.'}
		end
	end
	function UI.initialize()
		if not WG.Chili then return false end; UI.ch=WG.Chili
		UI.window=UI.ch.Window:New{name='CommandLayerWindow',caption='ZERO-K COMMAND LAYER',parent=UI.ch.Screen0,x=C.settings.x,y=C.settings.y,width=410*C.settings.scale,height=610*C.settings.scale,draggable=true,resizable=false,padding={12,30,12,12}}
		for i,tab in ipairs({'LOGISTICS','FORMATIONS','OFFICER'}) do button(UI.window,(i-1)*127,0,122,tab,'Open '..tab:lower(),function() UI.tab=tab; UI.build() end) end
		UI.status=UI.ch.TextBox:New{parent=UI.window,x=0,bottom=0,width='100%',height=118,text='Officer ready.'}
		UI.build(); C.debug.log('LOAD','Officer / Chili controls loaded'); return true
	end
	function UI.update(dt)
		UI.elapsed=UI.elapsed+(dt or .03); if UI.elapsed<.25 then return end; UI.elapsed=0
		if UI.status then
			local text='Formation: '..C.settings.formation..' | '..(C.settings.privateSession and C.settings.mode or 'ARRIVAL (public)')..'\nSpacing: '..C.settings.spacing..' | Constructors: '..tostring(C.settings.constructors)..'\n'..C.debug.message
			if UI.lastStatus~=text then UI.status:SetText(text); UI.lastStatus=text end
		end
		if UI.tab=='OFFICER' and UI.detail then
			local f=C.registry.forces[C.registry.activeForce]; local text='No adviser force selected.'
			if f then local n=0; for _ in pairs(f.members) do n=n+1 end; text='Force '..f.id..' | '..n..' units | '..f.status..'\n'..(f.advice or 'Set an objective or ask for a reform proposal.') end
			if text~=UI.lastDetail then UI.detail:SetText(text); UI.lastDetail=text end
		end
		if C.proposals then UI.showProposal(C.proposals.firstOffered()) end
	end
	function UI.showProposal(p)
		local id=p and p.id
		if id==UI.proposalID then return end
		if UI.dialog then UI.dialog:Dispose(); UI.dialog=nil end; UI.proposalID=id
		if not p then return end
		UI.dialog=UI.ch.Window:New{name='CommandLayerProposal',caption='Officer - Force '..p.forceID,parent=UI.ch.Screen0,x=450,y=160,width=440,height=330,draggable=true,resizable=false,padding={12,30,12,12}}
		UI.ch.TextBox:New{parent=UI.dialog,x=0,y=0,width='100%',height=220,text=p.summary}
		button(UI.dialog,0,240,130,'APPROVE '..p.kind,'Execute exactly this one displayed action.',function() C.proposals.approve(p.id,p.revision) end)
		button(UI.dialog,138,240,120,'DECLINE','No orders. Suppress this suggestion temporarily.',function() C.proposals.decline(p.id) end)
		button(UI.dialog,266,240,140,'SHOW PLAN','Preview destinations; no orders.',function() C.input.preview=p.plan end)
	end
	function UI.shutdown()
		if UI.dialog then UI.dialog:Dispose() end
		if UI.window then C.settings.x=UI.window.x; C.settings.y=UI.window.y; UI.window:Dispose(); UI.window=nil end
	end
	return UI
end
