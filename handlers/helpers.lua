-- Returns the greatest numeric key in a table.
function xdecor.maxn(T)
	local n = 0
	for k in pairs(T) do
		if k > n then n = k end
	end
	return n
end

-- Returns the length of an hash table.
function xdecor.tablelen(T)
	local n = 0
	for _ in pairs(T) do n = n + 1 end
	return n
end

-- Deep copy of a table. Borrowed from mesecons mod (https://github.com/Jeija/minetest-mod-mesecons).
function xdecor.tablecopy(T)
	if type(T) ~= "table" then return T end -- No need to copy.
	local new = {}

	for k, v in pairs(T) do
		if type(v) == "table" then
			new[k] = xdecor.tablecopy(v)
		else
			new[k] = v
		end
	end
	return new
end

