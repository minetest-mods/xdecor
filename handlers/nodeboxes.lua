xdecor.box = {
	slab_y = function(height, shift) return { -0.5, -0.5+(shift or 0), -0.5, 0.5, -0.5+height+(shift or 0), 0.5 } end,
	slab_z = function(depth) return { -0.5, -0.5, -0.5+depth, 0.5, 0.5, 0.5 } end,
	bar_y = function(radius) return {-radius, -0.5, -radius, radius, 0.5, radius} end,
	cuboid = function(radius_x, radius_y, radius_z) return {-radius_x, -radius_y, -radius_z, radius_x, radius_y, radius_z} end
}

xdecor.nodebox = {
	regular = { type="regular" },
	null = { type = "fixed", fixed = { 0, 0, 0, 0, 0, 0 } }
}

local mt = {}
mt.__index = function(table, key)
	local ref = xdecor.box[key]
	local ref_type = type(ref)
	if ref_type == "function" then
		return function(...)
			return { type = "fixed", fixed = ref(...) }
		end
	elseif ref_type == "table" then
		return { type = "fixed", fixed = ref }
	elseif ref_type == "nil" then
		error(key .. "could not be found among nodebox presets and functions")
	end
	error("unexpected datatype " .. tostring(type(ref)) .. " while looking for " .. key)
end
setmetatable(xdecor.nodebox, mt)
