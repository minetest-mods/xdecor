-- Code by Sokomine (https://github.com/Sokomine/xconnected)
-- License : GPLv3
-- Optimized by kilbith

local xwall = {}
screwdriver = screwdriver or {}

xwall.get_candidate = {}
local profiles = {
	{0, "_c0", 0},	{1, "_c1", 1},	{2, "_c1", 0},  {4, "_c1", 3},
	{8, "_c1", 2},	{5, "_ln", 1},	{10, "_ln", 0}, {3, "_c2", 0},
	{6, "_c2", 3},	{12, "_c2", 2}, {9, "_c2", 1},	{7, "_c3", 3},
	{11, "_c3", 0}, {13, "_c3", 1}, {14, "_c3", 2}, {15, "_c4", 1}
}

for _, p in pairs(profiles) do
	xwall.get_candidate[p[1]] = {p[2], p[3]}
end

local directions = {
	{x=1, y=0, z=0},  {x=0, y=0, z=1},
	{x=-1, y=0, z=0}, {x=0, y=0, z=-1}
}

function xwall.update_one_node(pos, name, digged)
	if not pos or not name or not minetest.registered_nodes[name] then return end
	local candidates = {0, 0, 0, 0}
	local pow2 = {1, 2, 4, 8}
	local id = 0

	for i, dir in pairs(directions) do
		local node = minetest.get_node(vector.add(pos, dir))
		local ndef = minetest.registered_nodes[node.name]

		if node and node.name and ndef then
			if ndef.drop == name or (ndef.groups and ndef.groups.xwall) then
				candidates[i] = node.name
				id = id + pow2[i]
			end
		end
	end

	if digged then return candidates end
	local newnode = xwall.get_candidate[id]

	if newnode and newnode[1] then
		local newname = name:sub(1, name:len()-3)..newnode[1]
		local regnode = minetest.registered_nodes[newname]

		if newname and regnode then
			minetest.swap_node(pos, {name=newname, param2=newnode[2]})
		elseif newnode[1] == '_c0' and not regnode then
			minetest.swap_node(pos, {name=name, param2=0})
		end
	end

	return candidates
end

function xwall.update(pos, name, active, has_been_digged)
	if not pos or not name or not minetest.registered_nodes[name] then return end

	local c = xwall.update_one_node(pos, name, has_been_digged)
	for j, dir2 in pairs(directions) do
		if c[j] ~= 0 and c[j] ~= "ignore" then
			xwall.update_one_node(vector.add(pos, dir2), c[j], false)
		end
	end
end

function xwall.construct_nodebox(nodebox_list, center_nodebox_list, nodebox_line)
	local res = {}
	res.c0, res.c1, res.c2, res.c3, res.c4 = {}, {}, {}, {}, {}

	for _, v in pairs(nodebox_list) do
		res.c1[#res.c1+1] = v
		res.c2[#res.c2+1] = v
		res.c3[#res.c3+1] = v
		res.c4[#res.c4+1] = v
	end

	for _, v in pairs(nodebox_list) do
		res.c2[#res.c2+1] = {v[3], v[2], v[1], v[6], v[5], v[4]}
		res.c3[#res.c3+1] = {v[3], v[2], v[1], v[6], v[5], v[4]}
		res.c4[#res.c4+1] = {v[3], v[2], v[1], v[6], v[5], v[4]}
	end

	for _, v in pairs(nodebox_list) do
		res.c3[#res.c3+1] = {v[4], v[2], v[3]-0.5, v[1], v[5], v[6]-0.5}
		res.c4[#res.c4+1] = {v[4], v[2], v[3]-0.5, v[1], v[5], v[6]-0.5}
	end

	for _, v in pairs(nodebox_list) do
		res.c4[#res.c4+1] = {v[3]-0.5, v[2], v[4], v[6]-0.5, v[5], v[1]}
	end

	for _, v in pairs(center_nodebox_list) do
		res.c0[#res.c0+1] = v
		res.c1[#res.c1+1] = v
		res.c2[#res.c2+1] = v
		res.c3[#res.c3+1] = v
		res.c4[#res.c4+1] = v
	end	

	if #res.c0 < 1 then
		res.c0 = nil
	end

	res.ln = nodebox_line
	return res
end

function xwall.register_wall(name, tiles)
	local groups, def = {}, {}
	local nodebox_data = xwall.construct_nodebox(
		{{-.1875,-.6875,0,.1875,.3125,.5}},
		{{-.25,-.6875,-.25,.25,.5,.25}},
		{{-.1875,-.6875,-.5,.1875,.3125,.5}}
	)

	local function group(k)
		groups = {xwall=1, cracky=3}
		if k ~= "ln" then
			groups.not_in_creative_inventory=1
		end
		return groups
	end

	for k, v in pairs(nodebox_data) do
		def = { 
			description = name:gsub("^%l", string.upper).." Wall",
			drawtype = "nodebox",
			paramtype = "light",
			paramtype2 = "facedir",
			tiles = {tiles},
			drop = "xdecor:"..name.."_wall_ln",
			node_box = {type = "fixed", fixed = nodebox_data[k]},
			sounds = default.node_sound_stone_defaults(),
			groups = group(k),
			sunlight_propagates = true,
			on_rotate = screwdriver.disallow,
			collision_box = {
				type = "fixed",
				fixed = {-.5,-.5,-.25,.5,1,.25}
			},
			on_construct = function(pos)
				return xwall.update(pos, "xdecor:"..name.."_wall_ln", true, nil)
			end,
			after_dig_node = function(pos, _, _, _)
				return xwall.update(pos, "xdecor:"..name.."_wall_ln", true, true)
			end
		}
		minetest.register_node("xdecor:"..name.."_wall_"..k, def)
	end
end

xwall.register_wall("cobble", "default_cobble.png")
xwall.register_wall("mossycobble", "default_mossycobble.png")
