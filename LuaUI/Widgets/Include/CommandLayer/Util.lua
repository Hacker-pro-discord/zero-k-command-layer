local U = {}
function U.copy(v)
	if type(v) ~= 'table' then return v end
	local out = {}; for k, x in pairs(v) do out[k] = U.copy(x) end; return out
end
function U.distance(a, b)
	return math.sqrt((a[1]-b[1])^2 + (a[3]-b[3])^2)
end
function U.position(id)
	local x, y, z = Spring.GetUnitPosition(id)
	return x and {x, y, z}
end
function U.center(ids)
	local p, n = {0,0,0}, 0
	for _, id in ipairs(ids) do local q=U.position(id); if q then for j=1,3 do p[j]=p[j]+q[j] end; n=n+1 end end
	if n==0 then return nil end
	for j=1,3 do p[j]=p[j]/n end; return p
end
function U.options(o)
	o=U.copy(o or {}); o.coded=0
	for _, k in ipairs({'alt','ctrl','meta','shift','right'}) do if o[k] then o.coded=o.coded+CMD['OPT_'..k:upper()] end end
	return o
end
function U.currentOptions()
	local a,c,m,s=Spring.GetModKeyState(); return U.options({alt=a,ctrl=c,meta=m,shift=s})
end
function U.live()
	return not Spring.GetSpectatingState() and not Spring.IsReplay() and Spring.GetGameFrame()>0
end
function U.owned(id)
	return U.live() and Spring.ValidUnitID(id) and not Spring.GetUnitIsDead(id) and Spring.GetUnitTeam(id)==Spring.GetMyTeamID()
end
function U.point(p)
	return type(p)=='table' and type(p[1])=='number' and type(p[3])=='number' and p[1]==p[1] and p[3]==p[3] and p[1]>=0 and p[3]>=0 and p[1]<=Game.mapSizeX and p[3]<=Game.mapSizeZ
end
function U.assisted(settings)
	local m=Spring.GetModOptions and Spring.GetModOptions() or {}
	return settings.privateSession and U.live() and (not m.sendspringiedata or m.sendspringiedata=='0' or m.sendspringiedata==0)
end
function U.delegationAllowed(settings)
	-- Installed LuaRules/Utilities/gametype.lua uses this same single-player criterion.
	-- Query it live too: joining players must revoke autonomous authority.
	return U.assisted(settings) and Spring.GetPlayerList and #(Spring.GetPlayerList() or {})==1
end
function U.now() return Spring.GetGameSeconds() end
return U
