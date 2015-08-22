local worktable = {}
local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots
local concat = table.concat

local material = {
	"cloud", -- Only used for the formspec display.
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
	local inv = meta:get_inventory()

	local f = {"size[8,7;]"..xbg..
		"list[current_player;main;0,3.3;8,4;]"..
		"image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"list[current_player;craft;2,0;3,3;]"..
		"list[current_player;craftpreview;6,1;1,1;]"}
	local formspec = concat(f)
	return formspec
end

function worktable.storage(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	local f = "size[8,7]"..xbg..
		"list[context;storage;0,0;8,2;]list[current_player;main;0,3.25;8,4;]"
	inv:set_size("storage", 8*2)
	return f
end

function worktable.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local row1, row2, row3 = {}, {}, {}

	for i = 1, 4 do
		row1[#row1+1] = "item_image_button["..(i-1)..
				",0;1,1;xdecor:"..def[i][1].."_cloud;"..def[i][1]..";]"
	end
	row1 = concat(row1)
	for j = 5, 8 do
		row2[#row2+1] = "item_image_button["..(j-5)..
				",1;1,1;xdecor:"..def[j][1].."_cloud;"..def[j][1]..";]"
	end
	row2 = concat(row2)
	for k = 9, 12 do
		row3[#row3+1] = "item_image_button["..(k-9)..
				",2;1,1;xdecor:"..def[k][1].."_cloud;"..def[k][1]..";]"
	end
	row3 = concat(row3)

	local fs = {"size[8,7;]"..xbg..
		row1..row2..row3..
		"label[4,1.23;Cut]".."box[3.95,1;1.05,0.9;#555555]"..
		"label[4,2.23;Repair]".."box[3.95,2;1.05,0.9;#555555]"..
		"image[6,1;1,1;xdecor_saw.png]".."image[6,2;1,1;xdecor_anvil.png]"..
		"image[7,2;1,1;hammer_layout.png]"..
		"list[current_name;input;5,1;1,1;]".."list[current_name;output;7,1;1,1;]"..
		"list[current_name;tool;5,2;1,1;]".."list[current_name;hammer;7,2;1,1;]"..
		"button[4,0;2,1;craft;Crafting]"..
		"button[6,0;2,1;storage;Storage]"..
		"list[current_player;main;0,3.25;8,4;]"}
	local formspec = concat(fs)

	meta:set_string("formspec", formspec)
	meta:set_string("infotext", "Work Table")

	local inv = meta:get_inventory()
	inv:set_size("output", 1)
	inv:set_size("input", 1)
	inv:set_size("tool", 1)
	inv:set_size("hammer", 1)
end

function worktable.fields(pos, _, fields, sender)
	local player = sender:get_player_name()
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local inputstack = inv:get_stack("input", 1)
	local outputstack = inv:get_stack("output", 1)
	local outputcount = outputstack:get_count()
	local inputname = inputstack:get_name()
	local outputname = outputstack:get_name()
	local shape, get, outputshape = {}, {}, {}
	local name = dump(fields):match("%w+")

	if outputcount < 99 and fields[name] then
		outputshape = outputname:match(name)
		if name ~= outputshape and outputcount > 0 then return end
		shape = "xdecor:"..name.."_"..inputname:sub(9)
		get = shape.." "..worktable.anz(name)

		if minetest.registered_nodes[shape] then
			inv:add_item("output", get)
			inputstack:take_item()
			inv:set_stack("input", 1, inputstack)
		end
	end
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
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if not inv:is_empty("input") or not inv:is_empty("output") or not
			inv:is_empty("hammer") or not inv:is_empty("tool") or not
			inv:is_empty("storage") then
		return false
	end
	return true
end

function worktable.put(_, listname, _, stack, _)
	local stackname = stack:get_name()
	local count = stack:get_count()
	local mat = concat(material)

	if listname == "output" then return 0 end
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

function worktable.move(_, from_list, _, to_list, _, count, _)
	if from_list == "storage" and to_list == "storage" then
		return count else return 0 end
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
	allow_metadata_inventory_put = worktable.put,
	allow_metadata_inventory_move = worktable.move
})

local function description(m, w)
	if m == "cloud" then return "" end
	return m:gsub("%l", string.upper, 1).." "..w:gsub("%l", string.upper, 1)
end

local function groups(m)
	if m:find("tree") or m:find("wood") or m == "cactus" then
		return {choppy=3, not_in_creative_inventory=1}
	end
	return {cracky=3, not_in_creative_inventory=1}
end

local function shady(w)
	if w:find("stair") or w == "slab" then return false end
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
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local tool = inv:get_stack("tool", 1)
		local hammer = inv:get_stack("hammer", 1)
		local wear = tool:get_wear()

		if tool:is_empty() or hammer:is_empty() or wear == 0 then return end

		tool:add_wear(-500) -- Tool's repairing factor (0-65535 -- 0 = new condition).
		hammer:add_wear(250) -- Hammer's wearing factor (0-65535 -- 0 = new condition).

		inv:set_stack("tool", 1, tool)
		inv:set_stack("hammer", 1, hammer)
	end
})
