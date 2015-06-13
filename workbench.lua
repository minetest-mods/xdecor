local material = {
	"cloud", -- only used for the formspec display
	"wood", "junglewood", "pinewood", "stonebrick", "tree", "pinetree",
	"stone", "sandstone", "desert_stone", "obsidian",
	"stonebrick", "sandstonebrick", "desert_stonebrick", "obsidianbrick",
	"copperblock", "bronzeblock", "goldblock", "steelblock", "diamondblock",
	"meselamp", "glass", "obsidian_glass" }

local def = {
	{"nanoslab", "32", {-0.5, -0.5, -0.5, 0, -0.4375, 0}},
	{"microslab_half", "16", {-0.5, -0.5, -0.5, 0.5, -0.4375, 0}},
	{"microslab", "8", {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}},
	{"panel", "4", {-0.5, -0.5, -0.5, 0.5, 0, 0}},
	{"slab", "2", {-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
	{"outerstair", "2", {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, {-0.5, 0, 0, 0, 0.5, 0.5}}},
	{"stair", "2", {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, {-0.5, 0, 0, 0.5, 0.5, 0.5}}},
	{"innerstair", "2", {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, {-0.5, 0, 0, 0.5, 0.5, 0.5}, {-0.5, 0, -0.5, 0, 0.5, 0}}}
}

function xdecor.on_construct(pos)
	local meta = minetest.get_meta(pos)
	local nodespec = ""

	for j=1, #def do
		nodespec = nodespec..
		"item_image_button["..(j-1)..",0.5;1,1;xdecor:"..def[j][1].."_cloud;"..def[j][1]..";]"
	end
	meta:set_string("formspec", "size[8,7;]"..fancy_gui..
		"label[0,0;Cut your material into...]"..
		nodespec..
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
	meta:set_string("infotext", "Work Bench")
	local inv = meta:get_inventory()
	inv:set_size("output", 1)
	inv:set_size("input", 1)
	inv:set_size("src", 1)
	inv:set_size("fuel", 1)
end

function xdecor.on_receive_fields(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local inputstack = inv:get_stack("input", 1)
	local outputstack = inv:get_stack("output", 1)
	local shape = {}
	local give = {}
	local anz = 0

	for _, m in ipairs(material) do
	for _, n in ipairs(def) do
		if (inputstack:get_name() == "default:"..m) and (outputstack:get_count() < 99) then
			if fields[n[1]] then
				anz = n[2]
				shape = "xdecor:"..n[1].."_"..m
				for i=0, anz-1 do
					give[i+1] = inv:add_item("output", shape)
				end
				inputstack:take_item()
				inv:set_stack("input", 1, inputstack)
			end
		end
	end
	end
end

function xdecor.can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:is_empty("input") or not inv:is_empty("output")
		or not inv:is_empty("fuel") or not inv:is_empty("src") then
			return false end
	return true
end

xdecor.register("workbench", {
	description = "Work Bench", infotext = "Work Bench",
	sounds = default.node_sound_wood_defaults(), groups = {snappy=3},
	tiles = {"xdecor_workbench_top.png", "xdecor_workbench_top.png",
		"xdecor_workbench_sides.png", "xdecor_workbench_sides.png",
		"xdecor_workbench_front.png", "xdecor_workbench_front.png"},
	on_construct = xdecor.on_construct,
	on_receive_fields = xdecor.on_receive_fields,
	can_dig = xdecor.can_dig })

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

for _, m in ipairs(material) do
	local light = lightlvl(m)
	local sound = stype(m)
	local tile = tnaming(m)

	for _, n in ipairs(def) do
	xdecor.register(n[1].."_"..m, {
		description = n[1], light_source = light, sounds = sound,
		tiles = {tile}, groups = {snappy=3, not_in_creative_inventory=1},
		on_place = minetest.rotate_node, node_box = {type = "fixed", fixed = n[3]} })
	end
end

-- Repair Tool's code by Krock, modified by kilbith

minetest.register_abm({
	nodenames = {"xdecor:workbench"},
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
