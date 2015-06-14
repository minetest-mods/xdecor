local material = {
	"cloud", -- only used for the formspec display
	"wood", "junglewood", "pinewood", "tree", "pinetree",
	"stone", "sandstone", "desert_stone", "obsidian",
	"stonebrick", "sandstonebrick", "desert_stonebrick", "obsidianbrick",
	"copperblock", "bronzeblock", "goldblock", "steelblock", "diamondblock",
	"meselamp", "glass", "obsidian_glass" }

local def = { -- node name, yield, nodebox shape
	{"nanoslab", "16", {-0.5, -0.5, -0.5, 0, -0.4375, 0}},
	{"microslab_half", "16", {-0.5, -0.5, -0.5, 0.5, -0.4375, 0}},
	{"microslab", "8", {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}},
	{"panel", "4", {-0.5, -0.5, -0.5, 0.5, 0, 0}},
	{"slab", "2", {-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
	{"outerstair", "1", {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, {-0.5, 0, 0, 0, 0.5, 0.5}}},
	{"stair", "1", {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, {-0.5, 0, 0, 0.5, 0.5, 0.5}}},
	{"innerstair", "1", {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, {-0.5, 0, 0, 0.5, 0.5, 0.5}, {-0.5, 0, -0.5, 0, 0.5, 0}}}
}

local function xconstruct(pos)
	local meta = minetest.get_meta(pos)
	local nodebtn = {}

	for i=1, #def do
		nodebtn[#nodebtn+1] = "item_image_button["..(i-1)..",0.5;1,1;xdecor:"..def[i][1].."_cloud;"..def[i][1]..";]"
	end
	nodebtn = table.concat(nodebtn)

	meta:set_string("formspec", "size[8,7;]"..fancy_gui..
		"label[0,0;Cut your material into...]"..
		nodebtn..
		"label[0,1.5;Input]"..
		"list[current_name;input;0,2;1,1;]"..
		"image[1,2;1,1;xdecor_saw.png]"..
		"label[2,1.5;Output]"..
		"list[current_name;output;2,2;1,1;]"..
		"label[4.5,1.5;Damaged tool]"..
		"list[current_name;src;5,2;1,1;]"..
		"image[6,2;1,1;xdecor_hammer.png]"..
		"label[6.8,1.5;Hammer]]"..
		"list[current_name;fuel;7,2;1,1;]"..
		"list[current_player;main;0,3.25;8,4;]")
	meta:set_string("infotext", "Work Table")
	local inv = meta:get_inventory()
	inv:set_size("output", 1)
	inv:set_size("input", 1)
	inv:set_size("src", 1)
	inv:set_size("fuel", 1)
end

local function xfields(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local inputstack = inv:get_stack("input", 1)
	local outputstack = inv:get_stack("output", 1)
	local shape = {}
	local get = {}
	local anz = 0

	for m=1, #material do
	for n=1, #def do
		local v = material[m]
		local w = def[n]
		if (inputstack:get_name() == "default:"..v) and (outputstack:get_count() < 99) then
			if fields[w[1]] then
				shape = "xdecor:"..w[1].."_"..v
				anz = w[2]
				get = shape.." "..anz

				inv:add_item("output", get)
				inputstack:take_item()
				inv:set_stack("input", 1, inputstack)
			end
		end
	end
	end
end

local function xdig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:is_empty("input") or not inv:is_empty("output")
		or not inv:is_empty("fuel") or not inv:is_empty("src") then
			return false end
	return true
end

xdecor.register("worktable", {
	description = "Work Table", groups = {snappy=3},
	sounds = default.node_sound_wood_defaults(),
	tiles = {"xdecor_worktable_top.png", "xdecor_worktable_top.png",
		"xdecor_worktable_sides.png", "xdecor_worktable_sides.png",
		"xdecor_worktable_front.png", "xdecor_worktable_front.png"},
	on_construct = xconstruct,
	on_receive_fields = xfields,
	can_dig = xdig })

local function lightlvl(material)
	if (material == "meselamp") then return 12 else return 0 end
end

local function stype(material)
	if string.find(material, "glass") or string.find(material, "lamp") then
		return default.node_sound_glass_defaults()
	elseif string.find(material, "wood") or string.find(material, "tree") then
		return default.node_sound_wood_defaults()
	else
		return default.node_sound_stone_defaults()
	end
end

local function tnaming(material)
	if string.find(material, "block") then
		local newname = string.gsub(material, "(block)", "_%1")
		return "default_"..newname..".png"
	elseif string.find(material, "brick") then
		local newname = string.gsub(material, "(brick)", "_%1")
		return "default_"..newname..".png"
	else return "default_"..material..".png" end
end

for m=1, #material do
	local v = material[m]
	local light = lightlvl(v)
	local sound = stype(v)
	local tile = tnaming(v)

	for n=1, #def do
	local w = def[n]
	xdecor.register(w[1].."_"..v, {
		description = w[1], light_source = light, sounds = sound,
		tiles = {tile}, groups = {snappy=3, not_in_creative_inventory=1},
		on_place = minetest.rotate_node, node_box = {type = "fixed", fixed = w[3]} })
	end
end

-- Repair Tool's code by Krock, modified by kilbith

minetest.register_abm({
	nodenames = {"xdecor:worktable"},
	interval = 5, chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local src = inv:get_stack("src", 1)
		local wear = src:get_wear()
		local repair = -1400

		if (src:is_empty() or wear == 0 or wear == 65535) then return end
		local fuel = inv:get_stack("fuel", 1)
		if (fuel:is_empty() or fuel:get_name() ~= "xdecor:hammer") then return end

		if (wear + repair < 0) then src:add_wear(repair + wear)
		else src:add_wear(repair) end

		inv:set_stack("src", 1, src)
		inv:remove_item("fuel", "xdecor:hammer 1")
	end
})
