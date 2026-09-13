-- Optional unit-pair preferences supplement shared role demand; never issue orders.
return function(C,data)
	local M={revision='draft-2026-09-12',matrix=data and data.matrix or {}}
	function M.bias(unit,model)
		local row=M.matrix[unit.name]; local delta,covered,denominator=0,0,0; local strongest,impact
		if C.settings.unitMatchups==false or not C.U.delegationAllowed(C.settings) or not row or unit.builder then return 0,0,'legacy role fallback' end
		for name,enemy in pairs(model.units or {}) do
			denominator=denominator+enemy.rawValue
			local target=C.classify.definition(enemy.defID); local value=row[name]
			-- Conservative capability gates. Unsupported pairs retain the role model.
			local compatible=(target.domain~='AIR' or unit.role=='ANTI_AIR') and (unit.role~='ANTI_AIR' or target.domain=='AIR')
			local targetDef=UnitDefs[enemy.defID]
			if targetDef and (targetDef.iconType or ''):find('^sub') and unit.domain=='GROUND' then compatible=false end
			if compatible and type(value)=='number' and value==value and value>=.05 and value<=1.95 then
				local contribution=(value-1)*enemy.value; delta=delta+contribution; covered=covered+enemy.value
				if not impact or math.abs(contribution)>impact then impact=math.abs(contribution); strongest=name..'='..string.format('%.2f',value) end
			end
		end
		-- Full raw intel, including uncovered identities, prevents sparse coverage or
		-- stale sightings from becoming a full-strength replacement model.
		denominator=math.max(300,denominator+(model.unknown or 0)*50)
		return delta/denominator,covered/denominator,strongest or 'legacy role fallback'
	end
	function M.adjust(base,unit,model,total)
		local bias,coverage,why=M.bias(unit,model)
		-- Keep score units comparable with the legacy 100-metal reference unit.
		local scale=(total+math.max(500,total*.25))/10
		local unpriced=base*math.max(100,unit.cost)^.5/10
		return base*(1-coverage)+unpriced*coverage+1.5*scale*bias, {bias=bias,coverage=coverage,reason=why,revision=M.revision}
	end
	return M
end
