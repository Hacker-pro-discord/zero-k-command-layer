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
function U.now() return Spring.GetGameSeconds() end
return U
