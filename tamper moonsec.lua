local om = string.match
string.match = function(a, b)
	if b == "%d+" then
		return "1"
	elseif b == ":%d+: a" then
		return ":1: a"
	end
	return om(a, b)
end

function ap(...)
	print(...)
end

--put your script here and use lua formatter i suggest you use luamin 