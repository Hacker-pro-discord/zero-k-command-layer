function widget:GetInfo()
	return {name='Zero-K Command Layer',desc='Officer-centered logistics, formations and approved tactical assistance',author='Command Layer contributors',license='GPL v2 or later',layer=1000001,enabled=true,handler=true}
end
local root='LuaUI/Widgets/Include/CommandLayer/'
local function module(name) return VFS.Include(root..name..'.lua',nil,VFS.RAW_FIRST) end
local U=module('Util')
local C={U=U,settings=module('Settings')(U),debug=module('Debug')(U)}
local ready=false
function widget:SetConfigData(data) C.settings.load(data) end
function widget:GetConfigData()
	if C.ui and C.ui.window then C.settings.x=C.ui.window.x; C.settings.y=C.ui.window.y end
	return C.settings.save()
end
function widget:Initialize()
	local disabled=Spring.GetModOptions().disable_local_widgets
	if disabled and disabled~='0' and disabled~=0 then widgetHandler:RemoveWidget(self); return end
	C.logistics=module('Logistics')(C)
	C.classify=module('UnitClassification')(C); C.registry=module('ForceRegistry')(C); C.formations=module('Formations')(C); C.orders=module('Orders')(C); C.officer=module('Officer')(C); C.input=module('Input')(C)
	C.ui=module('UI')(C); ready=C.ui.initialize()
	WG.CommandLayer={version=1,SubmitPlayerIntent=C.officer.submit,IssueFormationMove=C.officer.submit,CancelOperation=C.officer.cancel,GetSelectedForce=function() return C.classify.filter(Spring.GetSelectedUnits()) end,ClassifyForce=C.classify.force,ApplyFormation=C.formations.plan,GetOfficerStatus=function() return {message=C.debug.message} end}
end
function widget:CommandNotify(id,params,opts)
	if C.registry and not C.orders.sending then C.registry.release(Spring.GetSelectedUnits(),'PLAYER_OVERRIDE') end
	if C.logistics then C.logistics.notify(id,params,opts) end; return false
end
function widget:UnitCommandNotify(id) if C.registry and not C.orders.sending then C.registry.release({id},'PLAYER_OVERRIDE') end; return false end
function widget:UnitCommand(id,def,team,cmd,params,opts,tag,player,fromSynced,fromLua)
	if C.orders and not C.orders.event(id,cmd,params,fromSynced) then C.registry.release({id},'EXTERNAL_ORDER') end
end
function widget:MousePress(x,y,b) return C.input and C.input.press(x,y,b) end
function widget:MouseMove(x,y) if C.input then C.input.move(x,y) end end
function widget:MouseRelease(x,y,b) return C.input and C.input.release(x,y,b) end
function widget:DrawWorld() if C.input then C.input.draw() end end
function widget:KeyPress(key) if key==27 then if C.input then C.input.drag=nil end; if C.logistics then C.logistics.pending=nil end end end
function widget:Update(dt) if ready then C.logistics.update(); C.officer.update(); C.ui.update() end end
function widget:Shutdown() if C.ui then C.ui.shutdown() end; WG.CommandLayer=nil end
