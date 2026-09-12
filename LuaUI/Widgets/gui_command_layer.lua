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
	C.ui=module('UI')(C); ready=C.ui.initialize()
	WG.CommandLayer={version=1,GetOfficerStatus=function() return {state='IDLE',message=C.debug.message} end}
end
function widget:Update(dt) if ready then C.ui.update() end end
function widget:Shutdown() if C.ui then C.ui.shutdown() end; WG.CommandLayer=nil end
