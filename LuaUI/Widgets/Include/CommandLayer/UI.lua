return function(C)
	local UI={}
	function UI.initialize()
		local ch=WG.Chili; if not ch then return false end
		UI.ch=ch
		UI.window=ch.Window:New{name='CommandLayerWindow',caption='ZERO-K COMMAND LAYER',parent=ch.Screen0,x=C.settings.x,y=C.settings.y,width=350,height=190,draggable=true,resizable=false,padding={10,30,10,10}}
		UI.status=ch.TextBox:New{parent=UI.window,x=0,y=0,width='100%',height=105,text='Officer ready.\nPlayer-directed control.\nLogistics and formations loading.'}
		C.debug.log('LOAD','Officer / Chili shell loaded')
		return true
	end
	function UI.update() if UI.status then UI.status:SetText(C.debug.message) end end
	function UI.shutdown()
		if UI.window then C.settings.x=UI.window.x; C.settings.y=UI.window.y; UI.window:Dispose(); UI.window=nil end
	end
	return UI
end
