return function(U)
	local S={version=1,formation='OFF',mode='LOOSE',spacing=64,rankGap=100,supportDepth=200,skirmDepth=250,artilleryDepth=350,constructors=false,overlays=true,scale=1,x=30,y=240,privateSession=false,debug=false,override='release'}
	function S.load(data)
		if type(data)~='table' then return end
		for _,k in ipairs({'spacing','rankGap','supportDepth','skirmDepth','artilleryDepth','scale','x','y'}) do
			local v=data[k]; if type(v)=='number' and v==v and math.abs(v)<10000 then S[k]=v end
		end
		S.spacing=math.max(32,math.min(256,S.spacing)); S.rankGap=math.max(32,math.min(400,S.rankGap)); S.scale=math.max(.7,math.min(1.6,S.scale))
		for _,k in ipairs({'supportDepth','skirmDepth','artilleryDepth'}) do S[k]=math.max(32,math.min(800,S[k])) end
		for _,k in ipairs({'constructors','overlays','debug'}) do if type(data[k])=='boolean' then S[k]=data[k] end end
		if data.mode=='LOOSE' or data.mode=='STRICT' or data.mode=='ARRIVAL' then S.mode=data.mode end
		if data.override=='suspend' then S.override='suspend' end
		S.privateSession=false -- Never persist authority or a private-match assertion.
	end
	function S.save()
		local t={}; for k,v in pairs(S) do if type(v)~='function' and k~='privateSession' and k~='formation' then t[k]=v end end; return t
	end
	return S
end
