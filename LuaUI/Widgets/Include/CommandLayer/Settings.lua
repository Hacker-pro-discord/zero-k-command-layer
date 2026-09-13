return function(U)
	local S={version=1,defaultObjective='WIN THE GAME',defaultTactic='WAVE TACTICS',formation='OFF',mode='LOOSE',spacing=64,rankGap=100,supportDepth=200,skirmDepth=250,artilleryDepth=350,autoAssign=false,autoPlay=true,autoEconomy=true,reservePercent=20,intelHalfLife=90,unitMatchups=true,constructors=false,overlays=true,scale=1,x=30,y=240,privateSession=false,debug=false,override='release',proposalLifetime=60,suggestionInterval=10}
	function S.load(data)
		if type(data)~='table' then return end
		for _,k in ipairs({'spacing','rankGap','supportDepth','skirmDepth','artilleryDepth','scale','x','y','proposalLifetime','suggestionInterval','reservePercent','intelHalfLife'}) do
			local v=data[k]; if type(v)=='number' and v==v and math.abs(v)<10000 then S[k]=v end
		end
		S.spacing=math.max(32,math.min(256,S.spacing)); S.rankGap=math.max(32,math.min(400,S.rankGap)); S.scale=math.max(.7,math.min(1.6,S.scale))
		for _,k in ipairs({'supportDepth','skirmDepth','artilleryDepth'}) do S[k]=math.max(32,math.min(800,S[k])) end
		for _,k in ipairs({'unitMatchups','autoPlay','autoEconomy','autoAssign','constructors','overlays','debug'}) do if type(data[k])=='boolean' then S[k]=data[k] end end
		if data.mode=='LOOSE' or data.mode=='STRICT' or data.mode=='ARRIVAL' then S.mode=data.mode end
		if data.defaultTactic=='WAVE TACTICS' or data.defaultTactic=='CONTINUOUS PRESSURE' then S.defaultTactic=data.defaultTactic end
		if data.override=='suspend' then S.override='suspend' end
		S.proposalLifetime=math.max(30,math.min(180,S.proposalLifetime)); S.suggestionInterval=math.max(5,math.min(60,S.suggestionInterval))
		S.intelHalfLife=math.max(30,math.min(300,S.intelHalfLife))
		S.reservePercent=math.max(0,math.min(40,S.reservePercent))
		S.privateSession=false -- Never persist authority or a private-match assertion.
	end
	function S.save()
		local t={}; for k,v in pairs(S) do if type(v)~='function' and k~='privateSession' and k~='formation' then t[k]=v end end; return t
	end
	return S
end
