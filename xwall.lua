-- Code by Sokomine (https://github.com/Sokomine/xconnected)
-- License : GPLv3
-- Optimized by kilbith

local xwall = {}

xwall.get_candidate = {}
local profiles = {
	{0, "_c0", 0}, {1, "_c1", 1}, {2, "_c1", 0}, {4, "_c1", 3},
	{8, "_c1", 2}, {5, "_ln", 1}, {10, "_ln", 0}, {3, "_c2", 0},
	{6, "_c2", 3}, {12, "_c2", 2}, {9, "_c2", 1}, {7, "_c3", 3},
	{11, "_c3", 0}, {13, "_c3", 1}, {14, "_c3", 2}, {15, "_c4", 1}
}

for i = 1, #profiles do
	local p = profiles[i]
	local p1, p2, p3 = p[1], p[2], p[3]
	xwall.get_candidate[p1] = {p2, p3}
end

local directions = {
	{x = 1, y = 0, z = 0}, {x = 0, y = 0, z = 1},
	{x = -1, y = 0, z = 0}, {x = 0, y = 0, z = -1}
}

function xwall.update_one_node(pos, name, digged)
	if not pos or not name or not minetest.registered_nodes[name] then return end
	local candidates = {0, 0, 0, 0}
	local pow2 = {1, 2, 4, 8}
	local id = 0

	for i = 1, #directions do
		local dir = directions[i]
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
	for j = 1, #directions do
		local dir2 = directions[j]
		if c[j] ~= 0 and c[j] ~= "ignore" then
			xwall.update_one_node(vector.add(pos, dir2), c[j], false)
		end
	end
end

function xwall.register(name, def, node_box_data)
	for k, v in pairs(node_box_data) do
		def.drawtype = "nodebox"
		def.paramtype = "light"
		def.paramtype2 = "facedir"
		def.drop = name.."_ln"
		def.node_box = {type = "fixed", fixed = node_box_data[k]}

		if not def.tiles then def.tiles = def.textures end
		if not def.groups then
			def.groups = {xwall=1, cracky=3}
		else def.groups.xwall = 1 end

		local newdef = table.copy(def)
		if k == "ln" then
			newdef.on_construct = function(pos)
				return xwall.update(pos, name.."_ln", true, nil)
			end
		else newdef.groups.not_in_creative_inventory = 1 end

		newdef.after_dig_node = function(pos, _, _, _)
			return xwall.update(pos, name.."_ln", true, true)
		end

		minetest.register_node(name.."_"..k, newdef)
	end
end

function xwall.construct_node_box_data(node_box_list, center_node_box_list, node_box_line)
	local res = {}
	res.c0, res.c1, res.c2, res.c3, res.c4 = {}, {}, {}, {}, {}

	for _, v in pairs(node_box_list) do
		res.c1[#res.c1+1] = v
		res.c2[#res.c2+1] = v
		res.c3[#res.c3+1] = v
		res.c4[#res.c4+1] = v
	end

	for _, v in pairs(node_box_list) do
		res.c2[#res.c2+1] = {v[3], v[2], v[1], v[6], v[5], v[4]}
		res.c3[#res.c3+1] = {v[3], v[2], v[1], v[6], v[5], v[4]}
		res.c4[#res.c4+1] = {v[3], v[2], v[1], v[6], v[5], v[4]}
	end

	for _, v in pairs(node_box_list) do
		res.c3[#res.c3+1] = {v[4], v[2], v[3]-0.5,  v[1], v[5], v[6]-0.5}
		res.c4[#res.c4+1] = {v[4], v[2], v[3]-0.5,  v[1], v[5], v[6]-0.5}
	end

	for _, v in pairs(node_box_list) do
		res.c4[#res.c4+1] = {v[3]-0.5, v[2], v[4], v[6]-0.5, v[5], v[1]}
	end

	for _, v in pairs(center_node_box_list) do
		res.c0[#res.c0+1] = v
		res.c1[#res.c1+1] = v
		res.c2[#res.c2+1] = v
		res.c3[#res.c3+1] = v
		res.c4[#res.c4+1] = v
	end	

	if #res.c0 < 1 then res.c0 = nil end

	res.ln = node_box_line
	return res
end

function xwall.register_wall(name, tiles, def)
	local node_box_data = xwall.construct_node_box_data(
		{{-.1875,-.5,0,.1875,.3125,.5}},{{-.25,-.5,-.25,.25,.5,.25}},
		{{-.1875,-.5,-.5,.1875,.3125,.5}}
	)

	if def then return end
	def = { 
		description = string.sub(name:gsub("%l", string.upper, 7), 8, -6).." Wall",
		textures = {tiles, tiles, tiles, tiles},
		sounds = default.node_sound_stone_defaults(),
		groups = {cracky=3, stone=1, pane=1},
		sunlight_propagates = true,
		collision_box = {
			type = "fixed",
			fixed = {-.5, -.5, -.25, .5, 1, .25}
		}
	}
	xwall.register(name, def, node_box_data)
end

xwall.register_wall("xdecor:cobble_wall", "default_cobble.png")
xwall.register_wall("xdecor:mossycobble_wall", "default_mossycobble.png")
