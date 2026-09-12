return function(C)
	local UI={}
	function UI.initialize()
		local ch=WG.Chili; if not ch then return false end
		UI.ch=ch
		UI.window=ch.Window:New{name='CommandLayerWindow',caption='ZERO-K COMMAND LAYER',parent=ch.Screen0,x=C.settings.x,y=C.settings.y,width=370,height=270,draggable=true,resizable=false,padding={10,30,10,10}}
		for i,count in ipairs({0,1,2,4}) do
			local kind='MEX'..count
			ch.Button:New{parent=UI.window,x=((i-1)%2)*170,y=math.floor((i-1)/2)*40,width=165,height=36,caption=count==0 and 'MEX ONLY' or 'MEX + '..count..' ENERGY',tooltip='Native Area Mex with '..count..' generator placement attempts per spot.',OnClick={function() C.logistics.arm(kind) end}}
		end
		for i,kind in ipairs({'AREA_REPAIR','PERSISTENT_REPAIR','AREA_RECLAIM','PERSISTENT_RECLAIM'}) do
			ch.Button:New{parent=UI.window,x=((i-1)%2)*170,y=80+math.floor((i-1)/2)*40,width=165,height=36,caption=kind:gsub('_',' '),tooltip='Drag a native area. Persistent areas wait for new targets; Ctrl retains native secondary behavior.',OnClick={function() C.logistics.arm(kind) end}}
		end
		UI.window:Resize(370,360)
		UI.status=ch.TextBox:New{parent=UI.window,x=0,y=175,width='100%',height=110,text='Officer ready.'}
		C.debug.log('LOAD','Officer / Chili shell loaded')
		return true
	end
	function UI.update() if UI.status then UI.status:SetText(C.debug.message) end end
	function UI.shutdown()
		if UI.window then C.settings.x=UI.window.x; C.settings.y=UI.window.y; UI.window:Dispose(); UI.window=nil end
	end
	return UI
end
