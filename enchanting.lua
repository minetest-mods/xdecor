local function enchconstruct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", "size[8,7;]"..xdecor.fancy_gui..
		"label[0.65,-0.15;Enchant]"..
		"image[0.4,0.2;2,2;default_book.png]"..
		"image[1.3,2;1,1;ench_mese_layout.png]"..
		"list[current_name;tool;0.3,2;1,1;]"..
		"list[current_name;mese;1.3,2;1,1;]"..
		"image_button[2.5,0;5.3,1.1;ench_bg.png;durable;Durable]"..
		"image_button[2.5,1;5.3,1.1;ench_bg.png;fast;Fast]"..
		"image_button[2.5,2;5.3,1.1;ench_bg.png;luck;Luck]"..
		"list[current_player;main;0,3.3;8,4;]")
	meta:set_string("infotext", "Enchantment Table")

	local inv = meta:get_inventory()
	inv:set_size("tool", 1)
	inv:set_size("mese", 1)
end

local function enchdig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if not inv:is_empty("tool") or not inv:is_empty("mese") then
		return false
	end
	return true
end

local function enchput(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if listname == "mese" then
		if stack:get_name() == "default:mese_crystal" then
			return stack:get_count()
		else
			return 0
		end
	end
	if listname == "tool" then
		local tname = stack:get_name()
		local tdef = minetest.registered_tools[tname]

		if tdef then return 1 else return 0 end
	end

	return stack:get_count()
end

xdecor.register("enchantment_table", {
	description = "Enchantment Table",
	tiles = {
		"xdecor_enchantment_top.png",
		"xdecor_enchantment_bottom.png",
		"xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png",
	},
	groups = {cracky=1},
	sounds = xdecor.stone,
	on_construct = enchconstruct,
	can_dig = enchdig,
	allow_metadata_inventory_put = enchput
})
