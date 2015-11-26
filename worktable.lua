local worktable = {}
screwdriver = screwdriver or {}
local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots..default.get_hotbar_bg(0,3.25)

local nodes = { -- Nodes allowed to be cut. Mod name = {node name}.
	["default"] = {"wood", "junglewood", "pine_wood", "acacia_wood",
		"tree", "jungletree", "pine_tree", "acacia_tree",
		"cobble", "mossycobble", "desert_cobble",
		"stone", "sandstone", "desert_stone", "obsidian",
		"stonebrick", "sandstonebrick", "desert_stonebrick", "obsidianbrick",
		"coalblock", "copperblock", "steelblock", "goldblock", 
		"bronzeblock", "mese", "diamondblock",
		"brick", "cactus", "ice", "meselamp", "glass", "obsidian_glass"},

	["xdecor"] = {"coalstone_tile", "desertstone_tile", "stone_rune", "stone_tile",
		"cactusbrick", "hard_clay", "packed_ice", "moonbrick",
		"woodframed_glass", "wood_tile"},

	["oresplus"] = {"emerald_block", "glowstone"},
}

local def = { -- Nodebox name, yield, definition.
	{"nanoslab", 16, {-.5,-.5,-.5,0,-.4375,0}},
	{"micropanel", 16, {-.5,-.5,-.5,.5,-.4375,0}},
	{"microslab", 8, {-.5,-.5,-.5,.5,-.4375,.5}},
	{"thinstair", 8, {{-.5,-.0625,-.5,.5,0,0},{-.5,.4375,0,.5,.5,.5}}},
	{"cube", 4, {-.5,-.5,0,0,0,.5}},
	{"panel", 4, {-.5,-.5,-.5,.5,0,0}},
	{"slab", 2, {-.5,-.5,-.5,.5,0,.5}},
	{"doublepanel", 2, {{-.5,-.5,-.5,.5,0,0},{-.5,0,0,.5,.5,.5}}},
	{"halfstair", 2, {{-.5,-.5,-.5,0,0,.5},{-.5,0,0,0,.5,.5}}},
	{"outerstair", 1, {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,0,.5,.5}}},
	{"stair", 1, {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,.5,.5,.5}}},
	{"innerstair", 1, {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,.5,.5,.5},{-.5,0,-.5,0,.5,0}}}
}

function worktable.crafting()
	return "size[8,7;]"..xbg..
		"list[current_player;main;0,3.3;8,4;]"..
		"image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"list[current_player;craft;2,0;3,3;]"..
		"list[current_player;craftpreview;6,1;1,1;]"..
		"listring[current_player;main]"..
		"listring[current_player;craft]"
end

function worktable.storage(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	inv:set_size("storage", 8*2)
	return "size[8,7]"..xbg..
		"list[context;storage;0,0;8,2;]"..
		"list[current_player;main;0,3.25;8,4;]"..
		"listring[context;storage]"..
		"listring[current_player;main]"
end

function worktable.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	local formspec = "size[8,7;]"..xbg..
			"label[0.9,1.23;Cut]"..
			"label[0.9,2.23;Repair]"..
			"box[-0.05,1;2.05,0.9;#555555]"..
			"box[-0.05,2;2.05,0.9;#555555]"..
			"image[3,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
			"image[0,1;1,1;worktable_saw.png]"..
			"image[0,2;1,1;worktable_anvil.png]"..
			"image[3,2;1,1;hammer_layout.png]"..
			"list[context;input;2,1;1,1;]"..
			"list[context;tool;2,2;1,1;]"..
			"list[context;hammer;3,2;1,1;]"..
			"list[context;forms;4,0;4,3;]"..
			"list[current_player;main;0,3.25;8,4;]"..
			"button[0,0;2,1;craft;Crafting]"..
			"button[2,0;2,1;storage;Storage]"

	inv:set_size("forms", 4*3)
	inv:set_size("input", 1)
	inv:set_size("tool", 1)
	inv:set_size("hammer", 1)

	meta:set_string("formspec", formspec)
	meta:set_string("infotext", "Work Table")
end

function worktable.fields(pos, _, fields, sender)
	local player = sender:get_player_name()
	local inv = minetest.get_meta(pos):get_inventory()

	if fields.storage then
		minetest.show_formspec(player, "", worktable.storage(pos))
	elseif fields.craft then
		minetest.show_formspec(player, "", worktable.crafting(pos))
	end
end

function worktable.dig(pos, _)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("input") and inv:is_empty("hammer") and
		inv:is_empty("tool") and inv:is_empty("storage")
end

function worktable.contains(table, element)
	if table then
		for _, value in pairs(table) do
			if value == element then return true end
		end
	end
	return false
end

function worktable.put(_, listname, _, stack, _)
	local stn = stack:get_name()
	local count = stack:get_count()
	local mod, node = stn:match("([%w_]+):([%w_]+)")
	local tdef = minetest.registered_tools[stn]
	local twear = stack:get_wear()

	if listname == "input" and
		worktable.contains(nodes[mod], node) then return count
	elseif listname == "hammer" and
		stn == "xdecor:hammer" then return 1
	elseif listname == "tool" and tdef and twear > 0 then
		return 1
	elseif listname == "storage" then
		return count
	end
	return 0
end

function worktable.take(pos, listname, _, stack, player)
	local inv = minetest.get_meta(pos):get_inventory()
	local user_inv = player:get_inventory()
	local inputstack = inv:get_stack("input", 1):get_name()
	local mod, node = inputstack:match("([%w_]+):([%w_]+)")

	if listname == "forms" then
		if worktable.contains(nodes[mod], node) and
			user_inv:room_for_item("main", stack:get_name()) then
			return -1
		end
		return 0
	end
	return stack:get_count()
end

function worktable.move(_, from_list, _, to_list, _, count, _)
	if from_list == "storage" and to_list == "storage" then return count end
	return 0
end

local function update_inventory(inv, inputstack)
	if inv:is_empty("input") then inv:set_list("forms", {}) return end
	local output = {}

	for _, n in pairs(def) do
		local mat = inputstack:get_name()
		local input = inv:get_stack("input", 1)
		local mod, node = mat:match("([%w_]+):([%w_]+)")
		local count = math.min(n[2] * input:get_count(), inputstack:get_stack_max())

		if not worktable.contains(nodes[mod], node) then return end
		output[#output+1] = mat.."_"..n[1].." "..count
	end
	inv:set_list("forms", output)
end

function worktable.on_put(pos, listname, _, stack, _)
	if listname == "input" then
		local inv = minetest.get_meta(pos):get_inventory()
		update_inventory(inv, stack)
	end
end

function worktable.on_take(pos, listname, index, stack, _)
	local inv = minetest.get_meta(pos):get_inventory()
	if listname == "input" then
		update_inventory(inv, stack)
	elseif listname == "forms" then
		local inputstack = inv:get_stack("input", 1)
		inputstack:take_item(math.ceil(stack:get_count() / def[index][2]))
		inv:set_stack("input", 1, inputstack)
		update_inventory(inv, inputstack)
	end
end

xdecor.register("worktable", {
	description = "Work Table",
	groups = {cracky=2, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
	tiles = {
		"xdecor_worktable_top.png", "xdecor_worktable_top.png",
		"xdecor_worktable_sides.png", "xdecor_worktable_sides.png",
		"xdecor_worktable_front.png", "xdecor_worktable_front.png"
	},
	on_rotate = screwdriver.rotate_simple,
	can_dig = worktable.dig,
	on_construct = worktable.construct,
	on_receive_fields = worktable.fields,
	on_metadata_inventory_put = worktable.on_put,
	on_metadata_inventory_take = worktable.on_take,
	allow_metadata_inventory_put = worktable.put,
	allow_metadata_inventory_take = worktable.take,
	allow_metadata_inventory_move = worktable.move
})

for _, d in pairs(def) do
for mod, n in pairs(nodes) do
for _, name in pairs(n) do
	local ndef = minetest.registered_nodes[mod..":"..name]
	if ndef then
		local groups = {}
		groups.not_in_creative_inventory=1

		for k, v in pairs(ndef.groups) do
			if k ~= "wood" and k ~= "stone" and k ~= "level" then
				groups[k] = v
			end
		end

		minetest.register_node(":"..mod..":"..name.."_"..d[1], {
			description = ndef.description.." "..d[1]:gsub("^%l", string.upper),
			paramtype = "light",
			paramtype2 = "facedir",
			drawtype = "nodebox",
			light_source = ndef.light_source,
			sounds = ndef.sounds,
			tiles = {ndef.tiles[1]},
			groups = groups,
			node_box = {type = "fixed", fixed = d[3]},
			sunlight_propagates = true,
			on_place = minetest.rotate_node
		})
	end
	minetest.register_alias("xdecor:"..d[1].."_"..name, mod..":"..name.."_"..d[1])
end
end
end

minetest.register_abm({
	nodenames = {"xdecor:worktable"},
	interval = 3, chance = 1,
	action = function(pos, _, _, _)
		local inv = minetest.get_meta(pos):get_inventory()
		local tool = inv:get_stack("tool", 1)
		local hammer = inv:get_stack("hammer", 1)
		local wear = tool:get_wear()

		if tool:is_empty() or hammer:is_empty() or wear == 0 then return end

		-- Wear : 0-65535 | 0 = new condition.
		tool:add_wear(-500)
		hammer:add_wear(300)

		inv:set_stack("tool", 1, tool)
		inv:set_stack("hammer", 1, hammer)
	end
})

