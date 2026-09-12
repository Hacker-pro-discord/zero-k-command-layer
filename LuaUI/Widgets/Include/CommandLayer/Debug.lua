return function(U)
	local D={events={},message='Officer ready. Formation mode OFF.'}
	function D.log(kind,message)
		D.message=message; D.events[#D.events+1]={time=U.now(),kind=kind,message=message}
		if #D.events>120 then table.remove(D.events,1) end
		Spring.Echo('[CommandLayer] '..kind..': '..message)
	end
	return D
end
