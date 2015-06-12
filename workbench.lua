-- Repair Tool's code by Krock, modified by kilbith

xdecor.register("workbench", {
	description = "Work Bench", infotext = "Work Bench",
	sounds = default.node_sound_wood_defaults(), groups = {snappy=3}, 
	tiles = {"xdecor_workbench_top.png", "xdecor_workbench_top.png", 
		"xdecor_workbench_sides.png", "xdecor_workbench_sides.png",
		"xdecor_workbench_front.png", "xdecor_workbench_front.png"},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[8,7;]"..fancy_gui..
			"label[0,0;Cut your wood tile into...]"..
			"label[0,1.5;Input]"..
			"list[current_name;input;0,2;1,1;]"..
			"image[1,2;1,1;xdecor_saw.png]"..
			"label[2,1.5;Output]"..
			"list[current_name;output;2,2;1,1;]"..
			"label[5.5,0;Damaged tool]"..
			"list[current_name;src;6,0.5;1,1;]"..
			"image[4.35,1.1;1.5,1.5;xdecor_hammer.png]"..
			"label[5.8,1.5;Hammer]]"..
			"list[current_name;fuel;6,2;1,1;]"..
			"item_image_button[0,0.5;1,1;xdecor:microslab_wood;microslab; ]"..
			"item_image_button[1,0.5;1,1;xdecor:microslab_half_wood;microslabhalf; ]"..
			"item_image_button[2,0.5;1,1;xdecor:microcube_wood;microcube; ]"..
			"item_image_button[3,0.5;1,1;xdecor:panel_wood;panel; ]"..
			"list[current_player;main;0,3.25;8,4;]")
		meta:set_string("infotext", "Work Bench")
		local inv = meta:get_inventory()
		inv:set_size("output", 1)
		inv:set_size("input", 1)
		inv:set_size("src", 1)
		inv:set_size("fuel", 1)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local shape = {}
		local anz = 0

		if fields["microslab"] then
			anz = "8"
			shape = "xdecor:microslab_wood"
		elseif fields["microslabhalf"] then
			anz = "16"
			shape = "xdecor:microslab_half_wood"
		elseif fields["microcube"] then
			anz = "8"
			shape = "xdecor:microcube_wood"
		elseif fields["panel"] then
			anz = "4"
			shape = "xdecor:panel_wood"
		else return end

		local inputstack = inv:get_stack("input", 1)
		if (inputstack:get_name() == "xdecor:wood_tile") then
			local give = {}
			for i = 0, anz-1 do
				give[i+1] = inv:add_item("output", shape)
			end
			inputstack:take_item()
			inv:set_stack("input", 1, inputstack)
		else return end
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("src") and inv:is_empty("fuel") 
			and inv:is_empty("input") and inv:is_empty("output")
	end
})

local function register_wood_cut(name, desc, box, f_groups)
	f_groups = {}
	f_groups.snappy = 3
	f_groups.not_in_creative_inventory = 1
	xdecor.register(name.."_wood", {
		description = "Wood "..desc,
		tiles = {"xdecor_wood_tile.png"}, groups = f_groups,
		sounds = default.node_sound_wood_defaults(),
		node_box = { type = "fixed", fixed = box } }) end

wood = {}
wood.datas = {
	{"microslab", "Microslab", { -0.5, -0.5, -0.5, 0.5, -0.4375, 0.5 }},
	{"microslab_half", "Half Microslab", { -0.5, -0.5, -0.5, 0.5, -0.4375, 0 }},
	{"microcube", "Microcube", { -0.5, -0.5, -0.5, 0, 0, 0 }},
	{"panel", "Panel", { -0.5, -0.5, -0.5, 0.5, 0, 0 }},
}

for _, item in pairs(wood.datas) do
	register_wood_cut(unpack(item))
end

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
