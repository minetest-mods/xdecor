local worktable = {}
local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots

local material = {
	"wood", "junglewood", "pine_wood", "acacia_wood",
	"tree", "jungletree", "pine_tree", "acacia_tree",
	"cobble", "mossycobble", "desert_cobble",
	"stone", "sandstone", "desert_stone", "obsidian",
	"stonebrick", "sandstonebrick", "desert_stonebrick", "obsidianbrick",
	"coalblock", "copperblock", "steelblock", "goldblock", 
	"bronzeblock", "mese", "diamondblock",
	"brick", "cactus", "ice", "meselamp",
	"glass", "obsidian_glass"
}

local def = { -- Node name, nodebox shape.
	{"nanoslab", {-.5,-.5,-.5,0,-.4375,0}},
	{"micropanel", {-.5,-.5,-.5,.5,-.4375,0}},
	{"microslab", {-.5,-.5,-.5,.5,-.4375,.5}},
	{"thinstair", {{-.5,-.0625,-.5,.5,0,0},{-.5,.4375,0,.5,.5,.5}}},
	{"cube", {-.5,-.5,0,0,0,.5}},
	{"panel", {-.5,-.5,-.5,.5,0,0}},
	{"slab", {-.5,-.5,-.5,.5,0,.5}},
	{"doublepanel", {{-.5,-.5,-.5,.5,0,0},{-.5,0,0,.5,.5,.5}}},
	{"halfstair", {{-.5,-.5,-.5,0,0,.5},{-.5,0,0,0,.5,.5}}},
	{"outerstair", {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,0,.5,.5}}},
	{"stair", {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,.5,.5,.5}}},
	{"innerstair", {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,.5,.5,.5},{-.5,0,-.5,0,.5,0}}}
}

function worktable.crafting(pos)
	local meta = minetest.get_meta(pos)
	return "size[8,7;]"..xbg..
		"list[current_player;main;0,3.3;8,4;]"..
		"image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"list[current_player;craft;2,0;3,3;]"..
		"list[current_player;craftpreview;6,1;1,1;]"
end

function worktable.storage(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	local f = "size[8,7]"..xbg..
		"list[context;storage;0,0;8,2;]list[current_player;main;0,3.25;8,4;]"
	inv:set_size("storage", 8*2)
	return f
end

function worktable.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	inv:set_size("forms", 4*3)
	inv:set_size("input", 1)
	inv:set_size("tool", 1)
	inv:set_size("hammer", 1)

	local formspec = "size[8,7;]"..xbg..
		"list[context;forms;4,0;4,3;]" ..
		"label[0.95,1.23;Cut]box[-0.05,1;2.05,0.9;#555555]"..
		"image[3,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"label[0.95,2.23;Repair]box[-0.05,2;2.05,0.9;#555555]"..
		"image[0,1;1,1;xdecor_saw.png]image[0,2;1,1;xdecor_anvil.png]"..
		"image[3,2;1,1;hammer_layout.png]"..
		"list[current_name;input;2,1;1,1;]"..
		"list[current_name;tool;2,2;1,1;]list[current_name;hammer;3,2;1,1;]"..
		"button[0,0;2,1;craft;Crafting]"..
		"button[2,0;2,1;storage;Storage]"..
		"list[current_player;main;0,3.25;8,4;]"

	meta:set_string("formspec", formspec)
	meta:set_string("infotext", "Work Table")
end

function worktable.fields(pos, _, fields, sender)
	local player = sender:get_player_name()
	local inv = minetest.get_meta(pos):get_inventory()

	if fields.storage then
		minetest.show_formspec(player, "", worktable.storage(pos))
	end
	if fields.craft then
		minetest.show_formspec(player, "", worktable.crafting(pos))
	end
end

function worktable.anz(n)
	if n == "nanoslab" or n == "micropanel" then return 16
	elseif n == "microslab" or n == "thinstair" then return 8
	elseif n == "panel" or n == "cube" then return 4
	elseif n == "slab" or n == "halfstair" or n == "doublepanel" then return 2
	else return 1 end
end

function worktable.dig(pos, _)
	local inv = minetest.get_meta(pos):get_inventory()
	if not inv:is_empty("input") or not inv:is_empty("forms") or not
			inv:is_empty("hammer") or not inv:is_empty("tool") or not
			inv:is_empty("storage") then
		return false
	end
	return true
end

function worktable.put(pos, listname, _, stack, _)
	local stackname = stack:get_name()
	local count = stack:get_count()
	local mat = table.concat(material)

	if listname == "forms" then return 0 end
	if listname == "input" then
		if stackname:find("default:") and mat:match(stackname:sub(9)) then
			return count
		else return 0 end
	end
	if listname == "hammer" then
		if not (stackname == "xdecor:hammer") then return 0 end
	end
	if listname == "tool" then
		local tdef = minetest.registered_tools[stackname]
		local twear = stack:get_wear()
		if not (tdef and twear > 0) then return 0 end
	end

	return count
end

function worktable.take(pos, listname, index, stack, player)
	if listname == "forms" then return -1 end
	return stack:get_count()
end

function worktable.move(_, from_list, _, to_list, _, count, _)
	if from_list == "storage" and to_list == "storage" then
		return count else return 0 end
end

local function update_form_inventory(inv, input_stack)
	if inv:is_empty("input") then inv:set_list("forms", {}) return end

	local form_inv_list = {}
	for _, form in pairs(def) do
		local material_name = input_stack:get_name():match("%a+:(.+)")
		local form_name = form[1]
		local count = math.min(worktable.anz(form_name) * inv:get_stack("input", 1):get_count(), input_stack:get_stack_max())

		form_inv_list[#form_inv_list+1] = string.format("xdecor:%s_%s %d", form_name, material_name, count)
	end
	inv:set_list("forms", form_inv_list)
end

function worktable.on_put(pos, listname, _, stack, _)
	if listname == "input" then
		local inv = minetest.get_meta(pos):get_inventory()
		update_form_inventory(inv, stack)
	end
end

function worktable.on_take(pos, listname, index, stack, player)
	local inv = minetest.get_meta(pos):get_inventory()
	if listname == "input" then
		update_form_inventory(inv, stack)
	elseif listname == "forms" then
		local form_name = stack:get_name():match("%a+:(%a+)_%a+")
		local input_stack = inv:get_stack("input", 1)

		input_stack:take_item(math.ceil(stack:get_count() / worktable.anz(form_name)))
		inv:set_stack("input", 1, input_stack)
		update_form_inventory(inv, input_stack)
	end
end

xdecor.register("worktable", {
	description = "Work Table",
	groups = {cracky=2, choppy=2},
	sounds = default.node_sound_wood_defaults(),
	tiles = {
		"xdecor_worktable_top.png", "xdecor_worktable_top.png",
		"xdecor_worktable_sides.png", "xdecor_worktable_sides.png",
		"xdecor_worktable_front.png", "xdecor_worktable_front.png"
	},
	can_dig = worktable.dig,
	on_construct = worktable.construct,
	on_receive_fields = worktable.fields,
	on_metadata_inventory_put = worktable.on_put,
	on_metadata_inventory_take = worktable.on_take,
	allow_metadata_inventory_put = worktable.put,
	allow_metadata_inventory_take = worktable.take,
	allow_metadata_inventory_move = worktable.move
})

local function description(m, w)
	local d = m:gsub("%W", "")
	return d:gsub("^%l", string.upper).." "..w:gsub("^%l", string.upper)
end

local function groups(m)
	if m:find("tree") or m:find("wood") or m == "cactus" then
		return {choppy=3, not_in_creative_inventory=1}
	end
	return {cracky=3, not_in_creative_inventory=1}
end

local function shady(w)
	if w == "stair" or w == "slab" or w == "innerstair" or
			w == "outerstair" then return false end
	return true
end

for n = 1, #def do
for m = 1, #material do
	local w, x = def[n], material[m]
	local nodename = "default:"..x
	local ndef = minetest.registered_nodes[nodename]
	if not ndef then break end

	xdecor.register(w[1].."_"..x, {
		description = description(x, w[1]),
		light_source = ndef.light_source,
		sounds = ndef.sounds,
		tiles = ndef.tiles,
		groups = groups(x),
		node_box = {type = "fixed", fixed = w[2]},
		sunlight_propagates = shady(w[1]),
		on_place = minetest.rotate_node
	})
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

		-- Wear : 0-65535	0 = new condition.
		tool:add_wear(-500)
		hammer:add_wear(250)

		inv:set_stack("tool", 1, tool)
		inv:set_stack("hammer", 1, hammer)
	end
})
